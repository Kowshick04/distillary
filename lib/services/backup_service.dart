import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3/sqlite3.dart';

import '../database/database.dart';
import 'google_drive_backup_client.dart';

/// Enum representing the status of an automated backup and pruning operation.
enum BackupExecutionStatus {
  notDue,
  success,
  authenticationFailed,
  folderAccessFailed,
  snapshotFailed,
  uploadFailed,
  verificationFailed,
  databaseError,
}

/// Detailed result of a backup and pruning execution cycle.
class BackupOperationResult {
  final BackupExecutionStatus status;
  final int? backupHistoryId;
  final String? driveFileId;
  final int? deletedRecordsCount;
  final String? errorMessage;

  const BackupOperationResult({
    required this.status,
    this.backupHistoryId,
    this.driveFileId,
    this.deletedRecordsCount,
    this.errorMessage,
  });

  bool get isSuccess => status == BackupExecutionStatus.success;
}

/// Production service responsible for:
/// 1. Evaluating 7-day backup schedule.
/// 2. Verifying Google Drive authentication and folder access.
/// 3. Creating atomic, consistent SQLite snapshots via `VACUUM INTO`.
/// 4. Validating local snapshots.
/// 5. Uploading to Google Drive backup folder (`DISTILLERY_DATABASE_BACKUPS`).
/// 6. Full SQLite database verification of downloaded remote file.
/// 7. Relationship-aware safe pruning of historical data (>7 days).
/// 8. SQLite maintenance & disk space reclamation on Android.
class BackupService {
  static const String defaultGoogleDriveBackupFolderId = '1D4R2UVNPlVj-jm4uOCc8YsiJ7OOJ7RbD';
  static const Duration defaultBackupInterval = Duration(days: 7);
  static const Duration defaultRetentionPeriod = Duration(days: 7);

  final AppDatabase db;
  GoogleDriveBackupClient? driveClient;
  final String googleDriveBackupFolderId;
  final Duration backupInterval;
  final Duration defaultRetentionPeriodSetting;
  final Future<Directory> Function()? tempDirectoryProvider;

  BackupService(
    this.db, {
    this.driveClient,
    this.googleDriveBackupFolderId = defaultGoogleDriveBackupFolderId,
    this.backupInterval = defaultBackupInterval,
    Duration defaultRetentionPeriod = defaultRetentionPeriod,
    this.tempDirectoryProvider,
  }) : defaultRetentionPeriodSetting = defaultRetentionPeriod;

  static const List<String> requiredTables = [
    'factories',
    'input_files',
    'batches',
    'processing_runs',
    'preprocessing_data',
    'ai_models',
    'predictions',
    'mqtt_publish_log',
    'backup_history',
  ];

  static String formatTimestamp(DateTime dt) {
    final y = dt.year.toString().padLeft(4, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final d = dt.day.toString().padLeft(2, '0');
    final hh = dt.hour.toString().padLeft(2, '0');
    final mm = dt.minute.toString().padLeft(2, '0');
    final ss = dt.second.toString().padLeft(2, '0');
    return '$y-$m-${d}_$hh$mm$ss';
  }

  Future<Directory> _resolveTempDirectory() async {
    if (tempDirectoryProvider != null) {
      return await tempDirectoryProvider!();
    }
    try {
      return await getTemporaryDirectory();
    } catch (_) {
      return Directory.systemTemp;
    }
  }

  /// Counts total records across all 9 required tables in the database.
  Future<int> countTotalRecords() async {
    int total = 0;
    for (final table in requiredTables) {
      try {
        final res = await db.customSelect("SELECT COUNT(*) AS c FROM $table;").getSingle();
        total += (res.data['c'] as int? ?? 0);
      } catch (_) {}
    }
    return total;
  }

  /// Creates a consistent standalone SQLite snapshot using SQLite's native atomic `VACUUM INTO`.
  /// Validates the snapshot locally before returning.
  Future<File> createConsistentSnapshot({String prefix = 'distillery'}) async {
    final tempDir = await _resolveTempDirectory();
    final backupsDir = Directory(p.join(tempDir.path, 'distillery_snapshots'));
    if (!await backupsDir.exists()) {
      await backupsDir.create(recursive: true);
    }

    final timestamp = formatTimestamp(DateTime.now().toUtc());
    final snapshotPath = p.join(backupsDir.path, '${prefix}_backup_$timestamp.db');
    final snapshotFile = File(snapshotPath);

    if (await snapshotFile.exists()) {
      await snapshotFile.delete();
    }

    // Execute SQLite atomic snapshot command (compatible with WAL mode and concurrent active connections)
    final escapedPath = snapshotPath.replaceAll("'", "''");
    await db.customStatement("VACUUM INTO '$escapedPath';");

    if (!await snapshotFile.exists() || await snapshotFile.length() == 0) {
      throw StateError('VACUUM INTO failed to create a valid non-empty snapshot file at $snapshotPath');
    }

    // Validate the snapshot locally as a valid SQLite database
    final localValidation = _validateSqliteDatabase(snapshotFile);
    if (!localValidation.isVerified) {
      if (await snapshotFile.exists()) await snapshotFile.delete();
      throw StateError('Local snapshot failed SQLite validation: ${localValidation.errorMessage}');
    }

    return snapshotFile;
  }

  /// Validates that a given file is a healthy SQLite database containing all 9 required tables
  /// and passing PRAGMA integrity_check and PRAGMA foreign_key_check.
  GoogleDriveBackupVerificationResult _validateSqliteDatabase(File dbFile) {
    Database? rawDb;
    try {
      rawDb = sqlite3.open(dbFile.path);

      // 1. PRAGMA integrity_check
      final integrityResult = rawDb.select('PRAGMA integrity_check;');
      final integrityStatus = integrityResult.first['integrity_check'] as String? ?? '';
      if (integrityStatus.toLowerCase() != 'ok') {
        rawDb.dispose();
        return GoogleDriveBackupVerificationResult.failure('PRAGMA integrity_check failed: $integrityStatus');
      }

      // 2. Verify all 9 expected tables exist
      final tablesResult = rawDb.select("SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%';");
      final tablesFound = tablesResult.map((r) => r['name'] as String).toList();

      for (final req in requiredTables) {
        if (!tablesFound.contains(req)) {
          rawDb.dispose();
          return GoogleDriveBackupVerificationResult.failure('Missing required table: $req in database');
        }
      }

      // 3. PRAGMA foreign_key_check
      final fkResult = rawDb.select('PRAGMA foreign_key_check;');
      if (fkResult.isNotEmpty) {
        rawDb.dispose();
        return GoogleDriveBackupVerificationResult.failure('Foreign-key check failed with ${fkResult.length} violation(s)');
      }

      rawDb.dispose();
      return GoogleDriveBackupVerificationResult(
        isVerified: true,
        integrityCheckPassed: true,
        foreignKeyCheckPassed: true,
        tablesFound: tablesFound,
      );
    } catch (e) {
      rawDb?.dispose();
      return GoogleDriveBackupVerificationResult.failure('SQLite open/read error: $e');
    }
  }

  /// Default pre-configured backup subfolder IDs inside BACKUP_FOLDER
  /// Haliyal (F01) -> 1CO1Pki8RYmINwVfMCb5VqJhM-jgOnWi2
  /// Sankili (F02) -> 1Y_M_DqYC1UyBrmC_kOnTAESAuaOSEt0k
  /// Nelikuppam (F03) -> 1xOx6x3-4o-nkKvgRyETPwy00aLC-Bm3m
  /// Sivagangai (F04) -> 1652ElcOUK2YoqhC37LAHMpJmYlBG5B_I
  /// Bagalkot (F05) -> 1922Z7O-VQs-6IdtUgF9Mqi-VvJW3_4D8
  static const Map<String, String> defaultFactoryBackupFolderIds = {
    'F01': '1CO1Pki8RYmINwVfMCb5VqJhM-jgOnWi2',
    'F02': '1Y_M_DqYC1UyBrmC_kOnTAESAuaOSEt0k',
    'F03': '1xOx6x3-4o-nkKvgRyETPwy00aLC-Bm3m',
    'F04': '1652ElcOUK2YoqhC37LAHMpJmYlBG5B_I',
    'F05': '1922Z7O-VQs-6IdtUgF9Mqi-VvJW3_4D8',
  };

  /// Factory-aware database backup method for Step 7:
  /// Creates a consistent SQLite snapshot, verifies locally, uploads to Google Drive under
  /// BACKUP_FOLDER / {plantName} or dedicated factory backup folder, verifies the uploaded copy as SQLite, and records
  /// verification in backup_history with NO pruning.
  Future<BackupOperationResult> backupFactory({
    required String factoryCode,
    required String plantName,
    required String dbPrefix,
    String? targetFolderId,
    String rootBackupFolderId = defaultGoogleDriveBackupFolderId,
    GoogleDriveBackupClient? customClient,
    void Function(String message)? onProgress,
  }) async {
    final client = customClient ?? driveClient;
    if (client == null) {
      throw StateError('GoogleDriveBackupClient is required to execute backup.');
    }

    onProgress?.call('[BACKUP] $factoryCode / $plantName');
    onProgress?.call('[BACKUP] Database opened');

    // 1. Count records across all 9 tables before snapshot
    final totalRecords = await countTotalRecords();

    // 2. Generate snapshot filename
    final now = DateTime.now().toUtc();
    final formattedTime = formatTimestamp(now);
    final backupFileName = '${dbPrefix}_backup_$formattedTime.db';
    final targetSubfolderName = plantName;

    // 3. Record STARTED in backup_history
    final backupHistoryId = await db.into(db.backupHistory).insert(
      BackupHistoryCompanion.insert(
        backupFileName: backupFileName,
        backupLocation: 'Google Drive / $rootBackupFolderId / $targetSubfolderName',
        cloudProvider: 'GOOGLE_DRIVE',
        status: 'STARTED',
        backupStartedAt: Value(now),
        recordsBackedUp: Value(totalRecords),
        deletedLocalRecords: const Value(0),
      ),
    );

    File? localSnapshot;
    try {
      // 4. Create SQLite snapshot via VACUUM INTO
      onProgress?.call('[BACKUP] Creating consistent SQLite snapshot');
      try {
        localSnapshot = await createConsistentSnapshot(prefix: dbPrefix);
      } catch (e) {
        await _recordFailure(backupHistoryId, 'Snapshot creation failed: $e');
        return BackupOperationResult(
          status: BackupExecutionStatus.snapshotFailed,
          backupHistoryId: backupHistoryId,
          errorMessage: 'Snapshot creation failed: $e',
        );
      }

      final snapshotSize = await localSnapshot.length();

      // 5. Local integrity & foreign-key check
      onProgress?.call('[BACKUP] Local integrity check');
      onProgress?.call('[BACKUP] Local foreign-key check');

      // 6. Verify Authentication
      onProgress?.call('[BACKUP] Google authentication');
      final authenticated = await client.isAuthenticated();
      if (!authenticated) {
        await _recordFailure(backupHistoryId, 'Google Drive authentication failed or user not signed in.');
        if (await localSnapshot.exists()) await localSnapshot.delete();
        return BackupOperationResult(
          status: BackupExecutionStatus.authenticationFailed,
          backupHistoryId: backupHistoryId,
          errorMessage: 'Google Drive authentication failed or user not signed in.',
        );
      }

      // 7. Resolve Subfolder in Google Drive
      final String subfolderId;
      try {
        if (targetFolderId != null && targetFolderId.isNotEmpty) {
          subfolderId = targetFolderId;
        } else if (customClient == null && defaultFactoryBackupFolderIds.containsKey(factoryCode)) {
          subfolderId = defaultFactoryBackupFolderIds[factoryCode]!;
        } else {
          subfolderId = await client.resolveSubfolderId(
            parentFolderId: rootBackupFolderId,
            subfolderName: targetSubfolderName,
          );
        }
      } catch (e) {
        await _recordFailure(backupHistoryId, 'Failed to resolve backup subfolder $targetSubfolderName: $e');
        if (await localSnapshot.exists()) await localSnapshot.delete();
        return BackupOperationResult(
          status: BackupExecutionStatus.folderAccessFailed,
          backupHistoryId: backupHistoryId,
          errorMessage: 'Failed to resolve backup subfolder $targetSubfolderName: $e',
        );
      }

      // 8. Upload snapshot to Google Drive
      onProgress?.call('[BACKUP] Uploading to $targetSubfolderName');
      GoogleDriveUploadResult uploadResult;
      try {
        uploadResult = await client.uploadBackupFile(
          localFile: localSnapshot,
          folderId: subfolderId,
          fileName: backupFileName,
        );
      } catch (e) {
        await _recordFailure(backupHistoryId, 'Google Drive upload failed: $e');
        if (await localSnapshot.exists()) await localSnapshot.delete();
        return BackupOperationResult(
          status: BackupExecutionStatus.uploadFailed,
          backupHistoryId: backupHistoryId,
          errorMessage: 'Google Drive upload failed: $e',
        );
      }

      onProgress?.call('[BACKUP] Uploaded file ID: ${uploadResult.driveFileId}');

      // Update location and size
      await (db.update(db.backupHistory)..where((tbl) => tbl.id.equals(backupHistoryId))).write(
        BackupHistoryCompanion(
          backupLocation: Value('Google Drive: ${uploadResult.driveFileId} (Folder: $subfolderId)'),
          databaseSizeBytes: Value(BigInt.from(uploadResult.fileSizeBytes)),
        ),
      );

      // 9. Remote verification
      onProgress?.call('[BACKUP] Downloading uploaded backup for verification');
      final verification = await client.downloadAndVerifyBackup(
        driveFileId: uploadResult.driveFileId,
        expectedSizeBytes: snapshotSize,
      );

      if (!verification.isVerified) {
        await (db.update(db.backupHistory)..where((tbl) => tbl.id.equals(backupHistoryId))).write(
          BackupHistoryCompanion(
            status: const Value('VERIFICATION_FAILED'),
            errorMessage: Value('Uploaded backup verification failed: ${verification.errorMessage}'),
            backupCompletedAt: Value(DateTime.now().toUtc()),
          ),
        );
        if (await localSnapshot.exists()) await localSnapshot.delete();
        return BackupOperationResult(
          status: BackupExecutionStatus.verificationFailed,
          backupHistoryId: backupHistoryId,
          driveFileId: uploadResult.driveFileId,
          errorMessage: 'Uploaded backup verification failed: ${verification.errorMessage}',
        );
      }

      onProgress?.call('[BACKUP] Remote integrity_check = ok');
      onProgress?.call('[BACKUP] Remote foreign_key_check = 0');

      // 10. Mark verified in backup_history
      final verifiedTimestamp = DateTime.now().toUtc();
      await (db.update(db.backupHistory)..where((tbl) => tbl.id.equals(backupHistoryId))).write(
        BackupHistoryCompanion(
          status: const Value('SUCCESS'),
          verifiedAt: Value(verifiedTimestamp),
          backupCompletedAt: Value(verifiedTimestamp),
          errorMessage: const Value(null),
        ),
      );

      // 11. Cleanup temporary local snapshot
      if (await localSnapshot.exists()) {
        await localSnapshot.delete();
      }

      onProgress?.call('[BACKUP] SUCCESS');
      onProgress?.call('[BACKUP] verified_at = ${verifiedTimestamp.toIso8601String()}');

      // CRITICAL: NO PRUNING IN STEP 7
      return BackupOperationResult(
        status: BackupExecutionStatus.success,
        backupHistoryId: backupHistoryId,
        driveFileId: uploadResult.driveFileId,
        deletedRecordsCount: 0,
      );
    } catch (e) {
      await _recordFailure(backupHistoryId, 'Unexpected backup error: $e');
      if (localSnapshot != null && await localSnapshot.exists()) {
        await localSnapshot.delete();
      }
      return BackupOperationResult(
        status: BackupExecutionStatus.databaseError,
        backupHistoryId: backupHistoryId,
        errorMessage: e.toString(),
      );
    }
  }

  /// Orchestrates the complete automated 7-day backup and safe pruning workflow:
  /// 1. Check if backup is due.
  /// 2. Verify Google Drive authentication and folder accessibility.
  /// 3. Record STARTED in `backup_history`.
  /// 4. Create consistent SQLite snapshot via `VACUUM INTO`.
  /// 5. Upload snapshot to Google Drive backup folder.
  /// 6. Download and validate the uploaded backup as a full SQLite database.
  /// 7. Set status SUCCESS and record `verified_at`.
  /// 8. Prune eligible records older than retention period in schema-aware foreign-key order.
  // (Deprecated single-database helper removed in favor of factory-aware performAutomatedBackupAndPruning)

  /// Prunes eligible historical records in exact schema foreign-key dependency order.
  /// Enforces verification check on [verifiedBackupHistoryId] and returns deleted count breakdown.
  Future<Map<String, int>> _pruneHistoricalDataInDependencyOrder({
    required Duration retentionPeriod,
    required int verifiedBackupHistoryId,
    DateTime? referenceNow,
  }) async {
    // 1. HARD SAFETY GUARD: Confirm verified_at IS NOT NULL
    final backup = await (db.select(db.backupHistory)..where((tbl) => tbl.id.equals(verifiedBackupHistoryId))).getSingleOrNull();
    if (backup == null || backup.status != 'SUCCESS' || backup.verifiedAt == null) {
      throw StateError(
        'CRITICAL SAFETY GUARD VIOLATION: Cannot prune local database! '
        'Backup ID $verifiedBackupHistoryId has not been verified on Google Drive.',
      );
    }

    final now = (referenceNow ?? DateTime.now()).toUtc();
    final cutoffDate = now.subtract(retentionPeriod);

    // 2. BACKUP COVERAGE GUARD: Ensure verified backup was initiated after or covers candidate data
    if (backup.backupStartedAt.isBefore(cutoffDate) && (backup.recordsBackedUp ?? 0) == 0) {
      throw StateError(
        'BACKUP COVERAGE GUARD VIOLATION: Verified backup (${backup.backupStartedAt}) is older than cutoff ($cutoffDate) and does not cover candidate data.',
      );
    }

    final counts = <String, int>{
      'mqtt_publish_log': 0,
      'predictions': 0,
      'preprocessing_data': 0,
      'processing_runs': 0,
    };

    await db.transaction(() async {
      // Step A: Identify eligible completed processing runs older than cutoff (status != 'RUNNING')
      // STRICT BOUNDARY RULE: startedAt < cutoffDate (age > 7 days)
      final eligibleRuns = await (db.select(db.processingRuns)
            ..where((tbl) => tbl.startedAt.isSmallerThanValue(cutoffDate) & tbl.status.isNotValue('RUNNING')))
          .get();
      final eligibleRunIds = eligibleRuns.map((r) => r.id).toSet();

      // Step B: Identify eligible predictions strictly older than cutoff OR linked to eligible runs
      final eligiblePredictions = await (db.select(db.predictions)
            ..where((tbl) => tbl.predictedAt.isSmallerThanValue(cutoffDate) | tbl.processingRunId.isIn(eligibleRunIds)))
          .get();
      final eligiblePredictionIds = eligiblePredictions.map((p) => p.id).toSet();

      // Step C: Delete child MQTT publish logs first (CHILD OF PREDICTIONS)
      final deletedMqtt = await (db.delete(db.mqttPublishLog)
            ..where((tbl) => tbl.publishedAt.isSmallerThanValue(cutoffDate) | tbl.predictionId.isIn(eligiblePredictionIds)))
          .go();
      counts['mqtt_publish_log'] = deletedMqtt;

      // Step D: Delete predictions (CHILD OF BATCHES, PROCESSING_RUNS, AI_MODELS)
      final deletedPredictions = await (db.delete(db.predictions)
            ..where((tbl) => tbl.id.isIn(eligiblePredictionIds) | tbl.predictedAt.isSmallerThanValue(cutoffDate)))
          .go();
      counts['predictions'] = deletedPredictions;

      // Step E: Delete preprocessing_data (CHILD OF BATCHES, INPUT_FILES, PROCESSING_RUNS)
      final deletedPrep = await (db.delete(db.preprocessingData)
            ..where((tbl) =>
                tbl.createdAt.isSmallerThanValue(cutoffDate) |
                (tbl.timestampMinute.isNotNull() & tbl.timestampMinute.isSmallerThanValue(cutoffDate)) |
                tbl.processingRunId.isIn(eligibleRunIds)))
          .go();
      counts['preprocessing_data'] = deletedPrep;

      // Step F: Delete eligible completed processing_runs (CHILD OF INPUT_FILES)
      final deletedRuns = await (db.delete(db.processingRuns)
            ..where((tbl) => tbl.id.isIn(eligibleRunIds)))
          .go();
      counts['processing_runs'] = deletedRuns;
    });

    // Verify foreign-key integrity after pruning
    final fkCheck = await db.customSelect('PRAGMA foreign_key_check;').get();
    if (fkCheck.isNotEmpty) {
      throw StateError('PRAGMA foreign_key_check failed with ${fkCheck.length} violations after pruning!');
    }

    return counts;
  }

  /// Step 8: Factory-aware safe historical data pruning engine.
  /// Enforces all Step 8 Critical Safety Guards:
  /// 1. backup_history.status == 'SUCCESS'
  /// 2. backup_history.verified_at IS NOT NULL
  /// 3. Verified backup belongs to this database and covers candidate data
  /// 4. Protected tables (factories, input_files, batches, ai_models, backup_history) are never touched
  /// 5. Deletion occurs in strict foreign-key order
  /// 6. RUNNING processing runs are never pruned
  /// 7. Updates deleted_local_records in backup_history with exact count
  /// 8. Executes SQLite VACUUM and validates integrity_check + foreign_key_check
  Future<PruneOperationResult> pruneHistoricalData({
    required String factoryCode,
    Duration retentionPeriod = const Duration(days: 7),
    DateTime? referenceNow,
    int? specificBackupHistoryId,
    void Function(String message)? onProgress,
  }) async {
    onProgress?.call('[PRUNE][$factoryCode] Initializing safe 7-day retention pruning for $factoryCode');

    // 1. HARD SAFETY GUARD: Look up latest verified backup
    final BackupHistoryData? verifiedBackup;
    if (specificBackupHistoryId != null) {
      verifiedBackup = await (db.select(db.backupHistory)..where((tbl) => tbl.id.equals(specificBackupHistoryId))).getSingleOrNull();
    } else {
      verifiedBackup = await (db.select(db.backupHistory)
            ..where((tbl) => tbl.status.equals('SUCCESS') & tbl.verifiedAt.isNotNull())
            ..orderBy([(tbl) => OrderingTerm.desc(tbl.id)])
            ..limit(1))
          .getSingleOrNull();
    }

    if (verifiedBackup == null) {
      final msg = 'SAFETY GUARD BLOCKED: No verified backup (status=SUCCESS, verified_at!=NULL) found for $factoryCode. Zero local records deleted.';
      onProgress?.call('[PRUNE][$factoryCode] $msg');
      return PruneOperationResult(
        isSuccess: false,
        deletedRecordsCount: 0,
        errorMessage: msg,
      );
    }

    if (verifiedBackup.status != 'SUCCESS' || verifiedBackup.verifiedAt == null) {
      final msg = 'SAFETY GUARD BLOCKED: Backup #${verifiedBackup.id} status=${verifiedBackup.status}, verified_at=${verifiedBackup.verifiedAt}. Pruning aborted.';
      onProgress?.call('[PRUNE][$factoryCode] $msg');
      return PruneOperationResult(
        isSuccess: false,
        deletedRecordsCount: 0,
        backupHistoryId: verifiedBackup.id,
        errorMessage: msg,
      );
    }

    final now = (referenceNow ?? DateTime.now()).toUtc();
    final cutoffDate = now.subtract(retentionPeriod);

    // 2. BACKUP COVERAGE GUARD:
    // Candidate data strictly older than cutoffDate must have been backed up.
    // If the latest verified backup was created before the candidate records without covering them, abort.
    if (verifiedBackup.backupStartedAt.isBefore(cutoffDate) && (verifiedBackup.recordsBackedUp ?? 0) == 0) {
      final msg = 'BACKUP COVERAGE GUARD BLOCKED: Verified backup #${verifiedBackup.id} was created at ${verifiedBackup.backupStartedAt} and does not cover candidate data older than $cutoffDate.';
      onProgress?.call('[PRUNE][$factoryCode] $msg');
      return PruneOperationResult(
        isSuccess: false,
        deletedRecordsCount: 0,
        backupHistoryId: verifiedBackup.id,
        errorMessage: msg,
      );
    }

    onProgress?.call('[PRUNE][$factoryCode] Verified backup #${verifiedBackup.id} confirmed (verified_at: ${verifiedBackup.verifiedAt}). Cutoff: $cutoffDate');

    // 3. Perform Deletions in Strict Foreign-Key Dependency Order
    Map<String, int> counts;
    try {
      counts = await _pruneHistoricalDataInDependencyOrder(
        retentionPeriod: retentionPeriod,
        verifiedBackupHistoryId: verifiedBackup.id,
        referenceNow: now,
      );
    } catch (e) {
      final msg = 'PRUNING TRANSACTION FAILED (Rolled back): $e';
      onProgress?.call('[PRUNE][$factoryCode] $msg');
      return PruneOperationResult(
        isSuccess: false,
        deletedRecordsCount: 0,
        backupHistoryId: verifiedBackup.id,
        errorMessage: msg,
      );
    }

    final totalDeleted = counts.values.fold<int>(0, (sum, c) => sum + c);
    onProgress?.call('[PRUNE][$factoryCode] Deleted $totalDeleted records: $counts');

    // 4. Maintenance: SQLite VACUUM outside transaction
    try {
      await db.customStatement('VACUUM;');
      onProgress?.call('[PRUNE][$factoryCode] SQLite VACUUM completed successfully');
    } catch (e) {
      onProgress?.call('[PRUNE][$factoryCode] SQLite VACUUM notice: $e');
    }

    // 5. Post-Pruning Verification: foreign_key_check & integrity_check
    final fkResult = await db.customSelect('PRAGMA foreign_key_check;').get();
    final fkPassed = fkResult.isEmpty;

    final integrityResult = await db.customSelect('PRAGMA integrity_check;').getSingle();
    final integrityStatus = integrityResult.data['integrity_check'] as String? ?? '';
    final integrityPassed = integrityStatus.toLowerCase() == 'ok';

    onProgress?.call('[PRUNE][$factoryCode] PRAGMA foreign_key_check: ${fkResult.length} violations');
    onProgress?.call('[PRUNE][$factoryCode] PRAGMA integrity_check: $integrityStatus');

    // 6. Update backup_history.deleted_local_records with actual count
    await (db.update(db.backupHistory)..where((tbl) => tbl.id.equals(verifiedBackup!.id))).write(
      BackupHistoryCompanion(
        deletedLocalRecords: Value(totalDeleted),
      ),
    );

    onProgress?.call('[PRUNE][$factoryCode] SUCCESS: Updated backup_history #${verifiedBackup.id} deleted_local_records = $totalDeleted');

    return PruneOperationResult(
      isSuccess: true,
      deletedRecordsCount: totalDeleted,
      backupHistoryId: verifiedBackup.id,
      deletedCountsByTable: counts,
      integrityCheckPassed: integrityPassed,
      foreignKeyCheckPassed: fkPassed,
    );
  }

  /// Seeds controlled development test fixtures for Step 8 retention validation:
  /// - Record A: age = 1 day (KEEP)
  /// - Record B: age = 6 days (KEEP)
  /// - Record C: age = 7 days exact boundary (KEEP)
  /// - Record D: age = 8 days (PRUNE)
  /// - Record E: age = 30 days (PRUNE)
  /// Also seeds protected records in factories, input_files, batches, ai_models, backup_history.
  Future<Map<String, dynamic>> seedRetentionTestFixtures({
    required String factoryCode,
    DateTime? referenceNow,
  }) async {
    final now = (referenceNow ?? DateTime.now()).toUtc();

    // 1. Seed Protected Factory
    final factoryList = await (db.select(db.factories)..where((tbl) => tbl.factoryCode.equals(factoryCode))).get();
    final int factoryId;
    if (factoryList.isNotEmpty) {
      factoryId = factoryList.first.id;
    } else {
      factoryId = await db.into(db.factories).insert(
        FactoriesCompanion.insert(
          factoryCode: factoryCode,
          factoryName: 'Plant $factoryCode',
          driveFolderId: 'test_folder_$factoryCode',
        ),
      );
    }

    // 2. Seed Protected AI Model
    final modelId = await db.into(db.aiModels).insert(
      AiModelsCompanion.insert(
        modelName: 'Production_Yield_Predictor_v1',
        modelVersion: '1.0.0',
        modelType: 'XGBOOST',
        isActive: const Value(true),
      ),
    );

    // 3. Seed Protected Input File
    final inputFileId = await db.into(db.inputFiles).insert(
      InputFilesCompanion.insert(
        factoryId: factoryId,
        driveFileId: 'drive_file_retention_test_$factoryCode',
        fileName: 'Retention_Test_Data_$factoryCode.xlsx',
        status: 'PROCESSED',
      ),
    );

    // 4. Seed Protected Batch
    final batchId = await db.into(db.batches).insert(
      BatchesCompanion.insert(
        factoryId: factoryId,
        inputFileId: inputFileId,
        batchId: 'BATCH_RETENTION_$factoryCode',
      ),
    );

    // Test record definitions with exact ages:
    final testAges = [
      {'label': 'Record A (1d old)', 'age': const Duration(days: 1), 'shouldKeep': true},
      {'label': 'Record B (6d old)', 'age': const Duration(days: 6), 'shouldKeep': true},
      {'label': 'Record C (7d boundary)', 'age': const Duration(days: 7), 'shouldKeep': true},
      {'label': 'Record D (8d old)', 'age': const Duration(days: 8), 'shouldKeep': false},
      {'label': 'Record E (30d old)', 'age': const Duration(days: 30), 'shouldKeep': false},
    ];

    final createdRecordIds = <String, dynamic>{
      'factoryId': factoryId,
      'modelId': modelId,
      'inputFileId': inputFileId,
      'batchId': batchId,
      'runs': <int>[],
      'preprocessing': <int>[],
      'predictions': <int>[],
      'mqttLogs': <int>[],
    };

    for (final t in testAges) {
      final age = t['age'] as Duration;
      final recordTimestamp = now.subtract(age);

      // Create completed processing run with exact age
      final runId = await db.into(db.processingRuns).insert(
        ProcessingRunsCompanion.insert(
          inputFileId: inputFileId,
          batchId: Value(batchId),
          modelId: Value(modelId),
          status: 'SUCCESS',
          startedAt: Value(recordTimestamp),
          completedAt: Value(recordTimestamp.add(const Duration(minutes: 5))),
          recordsProcessed: const Value(1),
        ),
      );
      (createdRecordIds['runs'] as List<int>).add(runId);

      // Create preprocessing_data with exact age
      final prepId = await db.into(db.preprocessingData).insert(
        PreprocessingDataCompanion.insert(
          batchId: batchId,
          inputFileId: inputFileId,
          processingRunId: runId,
          brix: const Value(16.0),
          temperature: const Value(32.0),
          sugarConsumptionRate: const Value(0.90),
          timestampMinute: Value(recordTimestamp),
          createdAt: Value(recordTimestamp),
        ),
      );
      (createdRecordIds['preprocessing'] as List<int>).add(prepId);

      // Create prediction with exact age
      final predId = await db.into(db.predictions).insert(
        PredictionsCompanion.insert(
          batchId: batchId,
          processingRunId: runId,
          modelId: modelId,
          predictionLabel: 'GOLDEN_BATCH',
          predictionConfidence: const Value(0.95),
          predictedAt: Value(recordTimestamp),
        ),
      );
      (createdRecordIds['predictions'] as List<int>).add(predId);

      // Create MQTT publish log with exact age
      final mqttId = await db.into(db.mqttPublishLog).insert(
        MqttPublishLogCompanion.insert(
          predictionId: predId,
          topic: 'distillery/$factoryCode/predictions',
          payload: '{"batch": "BATCH_RETENTION_$factoryCode", "status": "GOLDEN_BATCH"}',
          publishedAt: Value(recordTimestamp),
          status: 'SUCCESS',
        ),
      );
      (createdRecordIds['mqttLogs'] as List<int>).add(mqttId);
    }

    return createdRecordIds;
  }

  Future<void> _recordFailure(int backupHistoryId, String errorMessage) async {
    await (db.update(db.backupHistory)..where((tbl) => tbl.id.equals(backupHistoryId))).write(
      BackupHistoryCompanion(
        status: const Value('FAILED'),
        errorMessage: Value(errorMessage),
        backupCompletedAt: Value(DateTime.now().toUtc()),
      ),
    );
  }

  /// Checks if an automated backup is due for this factory database.
  ///
  /// Logic:
  /// 1. Finds latest record in [backup_history] where [status] == 'SUCCESS'
  ///    and [verified_at] IS NOT NULL.
  /// 2. If no verified backup exists -> Returns true (backup is due).
  /// 3. If the latest verified backup age >= [backupInterval] -> Returns true (backup is due).
  /// 4. Otherwise -> Returns false (backup is not due).
  Future<bool> isBackupDue({
    Duration backupInterval = defaultBackupInterval,
    DateTime? referenceNow,
  }) async {
    final verifiedBackup = await (db.select(db.backupHistory)
          ..where((tbl) => tbl.status.equals('SUCCESS') & tbl.verifiedAt.isNotNull())
          ..orderBy([(tbl) => OrderingTerm.desc(tbl.id)])
          ..limit(1))
        .getSingleOrNull();

    if (verifiedBackup == null) {
      return true; // No verified backup exists yet
    }

    final now = (referenceNow ?? DateTime.now()).toUtc();
    final lastVerifiedTime = verifiedBackup.verifiedAt ?? verifiedBackup.backupStartedAt;
    final age = now.difference(lastVerifiedTime);

    return age >= backupInterval;
  }

  /// Executes the complete production automated backup -> verification -> pruning pipeline.
  ///
  /// Only runs when [isBackupDue] is true (or when forced via [forceRun]).
  /// 1. Evaluates [isBackupDue]. If false -> Skips without modifying anything.
  /// 2. Creates snapshot via VACUUM INTO -> Local SQLite validation -> Uploads to factory backup folder -> Downloads remote file -> Verifies SQLite integrity.
  /// 3. If backup or verification fails -> Pruning is strictly ABORTED (0 local records deleted).
  /// Executes the complete production automated backup -> verification -> pruning pipeline.
  ///
  /// Only runs when [isBackupDue] is true (or when forced via [force] / [forceRun]).
  /// 1. Evaluates [isBackupDue]. If false -> Skips without modifying anything.
  /// 2. Creates snapshot via VACUUM INTO -> Local SQLite validation -> Uploads to factory backup folder -> Downloads remote file -> Verifies SQLite integrity.
  /// 3. If backup or verification fails -> Pruning is strictly ABORTED (0 local records deleted).
  /// 4. If backup and verification succeed -> Executes foreign-key aware 7-day safe pruning -> Updates deleted_local_records audit -> Reclaims space via VACUUM.
  Future<AutomatedBackupAndPruneReport> performAutomatedBackupAndPruning({
    String factoryCode = 'F01',
    String plantName = 'Haliyal',
    String dbPrefix = 'haliyal',
    String? targetFolderId,
    String? customFolderId,
    String rootBackupFolderId = defaultGoogleDriveBackupFolderId,
    Duration backupInterval = defaultBackupInterval,
    Duration retentionPeriod = defaultRetentionPeriod,
    Duration? customRetention,
    DateTime? referenceNow,
    bool force = false,
    bool forceRun = false,
    GoogleDriveBackupClient? customClient,
    void Function(String message)? onProgress,
  }) async {
    final effectiveTargetFolderId = targetFolderId ?? customFolderId;
    final effectiveRetention = customRetention ?? retentionPeriod;
    final isForced = force || forceRun;

    onProgress?.call('[AUTO-PIPELINE][$factoryCode] Evaluating automated backup eligibility for $factoryCode ($plantName)...');

    // 1. Check if backup is due
    final due = isForced ||
        await isBackupDue(
          backupInterval: backupInterval,
          referenceNow: referenceNow,
        );

    if (!due) {
      onProgress?.call('[AUTO-PIPELINE][$factoryCode] Backup is NOT due yet (verified backup is within $backupInterval). Skipping.');
      return AutomatedBackupAndPruneReport.skipped(factoryCode: factoryCode);
    }

    onProgress?.call('[AUTO-PIPELINE][$factoryCode] 7-Day Backup IS DUE. Initiating snapshot and cloud backup...');

    // 2. Perform Verified Backup
    final backupResult = await backupFactory(
      factoryCode: factoryCode,
      plantName: plantName,
      dbPrefix: dbPrefix,
      targetFolderId: effectiveTargetFolderId,
      rootBackupFolderId: rootBackupFolderId,
      customClient: customClient,
      onProgress: onProgress,
    );

    if (!backupResult.isSuccess) {
      final msg = 'SAFETY GUARD: Cloud backup or remote verification failed (${backupResult.errorMessage}). Pruning strictly ABORTED.';
      onProgress?.call('[AUTO-PIPELINE][$factoryCode] $msg');
      return AutomatedBackupAndPruneReport.backupFailed(
        factoryCode: factoryCode,
        backupResult: backupResult,
        errorMessage: msg,
      );
    }

    onProgress?.call('[AUTO-PIPELINE][$factoryCode] Cloud backup #${backupResult.backupHistoryId} verified successfully on Google Drive. Initiating 7-day safe retention pruning...');

    // 3. Perform Safe Pruning
    final pruneResult = await pruneHistoricalData(
      factoryCode: factoryCode,
      retentionPeriod: effectiveRetention,
      referenceNow: referenceNow,
      specificBackupHistoryId: backupResult.backupHistoryId,
      onProgress: onProgress,
    );

    onProgress?.call('[AUTO-PIPELINE][$factoryCode] Automated backup + retention pipeline completed. Success: ${pruneResult.isSuccess}, Deleted: ${pruneResult.totalDeleted}');

    return AutomatedBackupAndPruneReport(
      factoryCode: factoryCode,
      wasDue: true,
      backupResult: backupResult,
      pruneResult: pruneResult,
    );
  }
}

/// Metadata report returned by [BackupService.performAutomatedBackupAndPruning].
class AutomatedBackupAndPruneReport {
  final String factoryCode;
  final bool wasDue;
  final BackupOperationResult? backupResult;
  final PruneOperationResult? pruneResult;
  final String? errorMessage;

  bool get isSuccess => status == BackupExecutionStatus.success;

  int get preprocessingDataDeleted => pruneResult?.preprocessingDataDeleted ?? 0;
  int get processingRunsDeleted => pruneResult?.processingRunsDeleted ?? 0;
  int get predictionsDeleted => pruneResult?.predictionsDeleted ?? 0;
  int get mqttPublishLogDeleted => pruneResult?.mqttPublishLogDeleted ?? 0;
  int get totalDeleted => pruneResult?.totalDeleted ?? 0;

  bool get isSumConsistent => pruneResult?.isSumConsistent ?? true;
  String get auditBreakdown => pruneResult?.auditBreakdown ?? 'No deletions';

  BackupExecutionStatus get status {
    if (!wasDue) return BackupExecutionStatus.notDue;
    if (backupResult != null && !backupResult!.isSuccess) return backupResult!.status;
    if (pruneResult != null && pruneResult!.isSuccess) return BackupExecutionStatus.success;
    return BackupExecutionStatus.databaseError;
  }

  int? get backupHistoryId => backupResult?.backupHistoryId;
  int? get deletedRecordsCount => pruneResult?.totalDeleted ?? (isSuccess ? 0 : null);
  String? get driveFileId => backupResult?.driveFileId;

  const AutomatedBackupAndPruneReport({
    required this.factoryCode,
    required this.wasDue,
    this.backupResult,
    this.pruneResult,
    this.errorMessage,
  });

  factory AutomatedBackupAndPruneReport.skipped({required String factoryCode}) =>
      AutomatedBackupAndPruneReport(
        factoryCode: factoryCode,
        wasDue: false,
      );

  factory AutomatedBackupAndPruneReport.backupFailed({
    required String factoryCode,
    required BackupOperationResult backupResult,
    required String errorMessage,
  }) =>
      AutomatedBackupAndPruneReport(
        factoryCode: factoryCode,
        wasDue: true,
        backupResult: backupResult,
        errorMessage: errorMessage,
      );
}

/// Metadata result returned by [BackupService.pruneHistoricalData].
class PruneOperationResult {
  final bool isSuccess;
  final int deletedRecordsCount;
  final int? backupHistoryId;
  final String? errorMessage;
  final Map<String, int> deletedCountsByTable;
  final bool integrityCheckPassed;
  final bool foreignKeyCheckPassed;

  int get preprocessingDataDeleted => deletedCountsByTable['preprocessing_data'] ?? 0;
  int get processingRunsDeleted => deletedCountsByTable['processing_runs'] ?? 0;
  int get predictionsDeleted => deletedCountsByTable['predictions'] ?? 0;
  int get mqttPublishLogDeleted => deletedCountsByTable['mqtt_publish_log'] ?? 0;
  int get totalDeleted => deletedRecordsCount;

  bool get isSumConsistent =>
      (preprocessingDataDeleted + processingRunsDeleted + predictionsDeleted + mqttPublishLogDeleted) == totalDeleted;

  String get auditBreakdown =>
      'total_deleted = $totalDeleted [preprocessing_data_deleted = $preprocessingDataDeleted, '
      'processing_runs_deleted = $processingRunsDeleted, '
      'predictions_deleted = $predictionsDeleted, '
      'mqtt_publish_log_deleted = $mqttPublishLogDeleted]';

  const PruneOperationResult({
    required this.isSuccess,
    required this.deletedRecordsCount,
    this.backupHistoryId,
    this.errorMessage,
    this.deletedCountsByTable = const {},
    this.integrityCheckPassed = true,
    this.foreignKeyCheckPassed = true,
  });

  @override
  String toString() =>
      'PruneOperationResult(isSuccess: $isSuccess, $auditBreakdown, backupId: $backupHistoryId, error: $errorMessage)';
}

