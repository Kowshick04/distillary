// ignore_for_file: avoid_print

import 'dart:io';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:sqlite3/sqlite3.dart';

import 'package:distillary/database/database.dart' hide isNull, isNotNull;
import 'package:distillary/services/backup_service.dart';
import 'package:distillary/services/database_service.dart';
import 'package:distillary/services/google_drive_backup_client.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;
  late Directory mockCloudStorageDir;
  late AppDatabase db;
  late DatabaseService service;
  late MockGoogleDriveBackupClient mockClient;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('distillery_backup_test_');
    mockCloudStorageDir = Directory(p.join(tempDir.path, 'mock_google_drive'));
    await mockCloudStorageDir.create(recursive: true);

    // Create a real file-based SQLite database to test VACUUM INTO and file snapshot behavior
    final dbFile = File(p.join(tempDir.path, 'distillery_source.db'));
    db = AppDatabase(NativeDatabase(
      dbFile,
      setup: (rawDb) {
        rawDb.execute('PRAGMA foreign_keys = ON;');
        rawDb.execute('PRAGMA journal_mode = WAL;');
      },
    ));
    mockClient = MockGoogleDriveBackupClient(mockCloudStorageDir: mockCloudStorageDir);
    service = DatabaseService(db);
    service.backupService = BackupService(
      db,
      driveClient: mockClient,
      tempDirectoryProvider: () async => tempDir,
    );
    await service.seedInitialFactories();
  });

  tearDown(() async {
    await db.close();
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  // ===========================================================================
  // TEST A: Backup not due
  // ===========================================================================
  test('TEST A: Backup not due -> No backup created and no pruning occurs', () async {
    final twoDaysAgo = DateTime.now().toUtc().subtract(const Duration(days: 2));
    await db.into(db.backupHistory).insert(
      BackupHistoryCompanion.insert(
        backupFileName: 'distillery_backup_recent.db',
        backupLocation: 'Google Drive / BACKUP_FOLDER',
        cloudProvider: 'GOOGLE_DRIVE',
        status: 'SUCCESS',
        verifiedAt: Value(twoDaysAgo),
      ),
    );

    final result = await service.backupService.performAutomatedBackupAndPruning(
      customClient: mockClient,
      customRetention: const Duration(days: 7),
    );

    expect(result.status, equals(BackupExecutionStatus.notDue));
    expect(result.isSuccess, isFalse);
  });

  // ===========================================================================
  // TEST B: Authentication Failure
  // ===========================================================================
  test('TEST B: Authentication failure -> Marked FAILED, no pruning, local data preserved', () async {
    mockClient.isUserAuthenticated = false;

    final result = await service.backupService.performAutomatedBackupAndPruning(
      customClient: mockClient,
      force: true,
    );

    expect(result.status, equals(BackupExecutionStatus.authenticationFailed));
    final history = await service.backupHistory.getAllBackups();
    expect(history.isNotEmpty, isTrue);
    expect(history.first.status, equals('FAILED'));
    expect(history.first.verifiedAt, isNull);
  });

  // ===========================================================================
  // TEST C: Backup folder inaccessible
  // ===========================================================================
  test('TEST C: Backup folder inaccessible -> Marked FAILED, no pruning', () async {
    mockClient.folderAccessGranted = false;

    final result = await service.backupService.performAutomatedBackupAndPruning(
      customClient: mockClient,
      force: true,
    );

    expect(result.status, equals(BackupExecutionStatus.folderAccessFailed));
    final history = await service.backupHistory.getAllBackups();
    expect(history.isNotEmpty, isTrue);
    expect(history.first.status, equals('FAILED'));
    expect(history.first.verifiedAt, isNull);
  });

  // ===========================================================================
  // TEST D: Snapshot creation failure handling
  // ===========================================================================
  test('TEST D: Snapshot failure -> Marked FAILED, no pruning, local data untouched', () async {
    final brokenService = BackupService(
      db,
      driveClient: mockClient,
      tempDirectoryProvider: () async => Directory('Z:\\non_existent_drive_folder_12345'),
    );

    final result = await brokenService.performAutomatedBackupAndPruning(
      customClient: mockClient,
      force: true,
    );

    expect(result.status, equals(BackupExecutionStatus.snapshotFailed));
    expect(result.isSuccess, isFalse);
  });

  // ===========================================================================
  // TEST E: Google Drive upload failure
  // ===========================================================================
  test('TEST E: Google Drive upload failure -> Marked FAILED, no pruning, local data preserved', () async {
    mockClient.shouldFailUpload = true;

    final result = await service.backupService.performAutomatedBackupAndPruning(
      customClient: mockClient,
      force: true,
    );

    expect(result.status, equals(BackupExecutionStatus.uploadFailed));

    final history = await service.backupHistory.getAllBackups();
    expect(history.isNotEmpty, isTrue);
    expect(history.first.status, equals('FAILED'));
    expect(history.first.verifiedAt, isNull);
    expect(history.first.deletedLocalRecords, anyOf(isNull, equals(0)));
  });

  // ===========================================================================
  // TEST F: Google Drive verification failure
  // ===========================================================================
  test('TEST F: Google Drive verification failure (corrupt DB) -> Marked VERIFICATION_FAILED, no pruning', () async {
    mockClient.corruptUploadedDb = true;

    final result = await service.backupService.performAutomatedBackupAndPruning(
      customClient: mockClient,
      force: true,
    );

    expect(result.status, equals(BackupExecutionStatus.verificationFailed));

    final history = await service.backupHistory.getAllBackups();
    expect(history.isNotEmpty, isTrue);
    expect(history.first.status, equals('VERIFICATION_FAILED'));
    expect(history.first.verifiedAt, isNull);
    expect(history.first.deletedLocalRecords, anyOf(isNull, equals(0)));
  });

  // ===========================================================================
  // TEST G, H, I, J, K: Full Verified Backup, Pruning, Maintenance, and Reopening
  // ===========================================================================
  test('TEST G, H, I, J, K: Verified backup triggers safe pruning, VACUUM, and temporary cleanup', () async {
    final factories = await service.factories.getAllFactories();
    final factoryId = factories.first.id;

    final now = DateTime.now().toUtc();
    final tenDaysAgo = now.subtract(const Duration(days: 10));
    final twoDaysAgo = now.subtract(const Duration(days: 2));

    // 1. Seed historical data (> 10 days old)
    final oldFileId = await service.inputFiles.insertFile(
      InputFilesCompanion.insert(
        factoryId: factoryId,
        driveFileId: 'drive_file_old_1',
        fileName: 'Batch_Historical.xlsx',
        status: 'PROCESSED',
        lastProcessedAt: Value(tenDaysAgo),
      ),
    );

    final oldBatchId = await service.batches.insertBatch(
      BatchesCompanion.insert(
        factoryId: factoryId,
        inputFileId: oldFileId,
        batchId: 'BATCH_2026_HISTORICAL',
      ),
    );

    final modelId = await service.aiModels.insertModel(
      AiModelsCompanion.insert(
        modelName: 'Production Distillery Model',
        modelVersion: 'v1.0',
        modelType: 'Ensemble',
      ),
    );

    final oldRunId = await service.processingRuns.insertRun(
      ProcessingRunsCompanion.insert(
        inputFileId: oldFileId,
        batchId: Value(oldBatchId),
        modelId: Value(modelId),
        status: 'SUCCESS',
        startedAt: Value(tenDaysAgo),
        completedAt: Value(tenDaysAgo.add(const Duration(minutes: 5))),
      ),
    );

    await service.preprocessingData.insertRecord(
      PreprocessingDataCompanion.insert(
        batchId: oldBatchId,
        inputFileId: oldFileId,
        processingRunId: oldRunId,
        createdAt: Value(tenDaysAgo),
        sugarConsumptionRate: const Value(0.88),
      ),
    );

    final oldPredId = await service.predictions.insertPrediction(
      PredictionsCompanion.insert(
        batchId: oldBatchId,
        processingRunId: oldRunId,
        modelId: modelId,
        predictionLabel: 'GOLDEN_BATCH',
        predictedAt: Value(tenDaysAgo),
      ),
    );

    await service.mqttPublishLog.insertLog(
      MqttPublishLogCompanion.insert(
        predictionId: oldPredId,
        topic: 'distillery/f01/predictions',
        payload: '{"status":"GOLDEN"}',
        status: 'SUCCESS',
        publishedAt: Value(tenDaysAgo),
      ),
    );

    // 2. Seed recent data (2 days old)
    final newFileId = await service.inputFiles.insertFile(
      InputFilesCompanion.insert(
        factoryId: factoryId,
        driveFileId: 'drive_file_new_1',
        fileName: 'Batch_Recent.xlsx',
        status: 'PROCESSED',
        lastProcessedAt: Value(twoDaysAgo),
      ),
    );

    final newBatchId = await service.batches.insertBatch(
      BatchesCompanion.insert(
        factoryId: factoryId,
        inputFileId: newFileId,
        batchId: 'BATCH_2026_RECENT',
      ),
    );

    final newRunId = await service.processingRuns.insertRun(
      ProcessingRunsCompanion.insert(
        inputFileId: newFileId,
        batchId: Value(newBatchId),
        modelId: Value(modelId),
        status: 'SUCCESS',
        startedAt: Value(twoDaysAgo),
        completedAt: Value(twoDaysAgo.add(const Duration(minutes: 5))),
      ),
    );

    await service.preprocessingData.insertRecord(
      PreprocessingDataCompanion.insert(
        batchId: newBatchId,
        inputFileId: newFileId,
        processingRunId: newRunId,
        createdAt: Value(twoDaysAgo),
        sugarConsumptionRate: const Value(0.95),
      ),
    );

    final newPredId = await service.predictions.insertPrediction(
      PredictionsCompanion.insert(
        batchId: newBatchId,
        processingRunId: newRunId,
        modelId: modelId,
        predictionLabel: 'NORMAL_BATCH',
        predictedAt: Value(twoDaysAgo),
      ),
    );

    await service.mqttPublishLog.insertLog(
      MqttPublishLogCompanion.insert(
        predictionId: newPredId,
        topic: 'distillery/f01/predictions',
        payload: '{"status":"NORMAL"}',
        status: 'SUCCESS',
        publishedAt: Value(twoDaysAgo),
      ),
    );

    // 3. Execute Automated Backup & Safe Pruning
    final result = await service.backupService.performAutomatedBackupAndPruning(
      customClient: mockClient,
      force: true,
      customRetention: const Duration(days: 7),
    );

    expect(result.status, equals(BackupExecutionStatus.success));
    expect(result.isSuccess, isTrue);
    expect(result.deletedRecordsCount, greaterThan(0));

    final history = await service.backupHistory.getAllBackups();
    final successfulBackup = history.firstWhere((b) => b.id == result.backupHistoryId);
    expect(successfulBackup.status, equals('SUCCESS'));
    expect(successfulBackup.verifiedAt, isNotNull);
    expect(successfulBackup.deletedLocalRecords, equals(result.deletedRecordsCount));

    // Old eligible records are pruned
    final oldPrep = await (db.select(db.preprocessingData)..where((t) => t.id.equals(1))).getSingleOrNull();
    expect(oldPrep, isNull);

    final oldPred = await (db.select(db.predictions)..where((t) => t.id.equals(oldPredId))).getSingleOrNull();
    expect(oldPred, isNull);

    final oldRun = await (db.select(db.processingRuns)..where((t) => t.id.equals(oldRunId))).getSingleOrNull();
    expect(oldRun, isNull);

    // Recent records (< 7 days) are preserved
    final recentPrep = await service.preprocessingData.getByBatchId(newBatchId);
    expect(recentPrep.length, equals(1));
    expect(recentPrep.first.sugarConsumptionRate, closeTo(0.95, 0.001));

    final recentPred = await service.predictions.getPredictionsByBatch(newBatchId);
    expect(recentPred.length, equals(1));
    expect(recentPred.first.predictionLabel, equals('NORMAL_BATCH'));

    // Protected tables remain intact
    final factoriesCheck = await service.factories.getAllFactories();
    expect(factoriesCheck.length, equals(5));

    final filesCheck = await service.inputFiles.getAllFiles();
    expect(filesCheck.length, equals(2)); // Both input files preserved

    final batchesCheck = await service.batches.getAllBatches();
    expect(batchesCheck.length, equals(2)); // Both batches preserved

    final modelsCheck = await service.aiModels.getAllModels();
    expect(modelsCheck.length, equals(1)); // AI models preserved

    // Foreign-key integrity check passes with 0 violations
    final fkViolations = await db.customSelect('PRAGMA foreign_key_check;').get();
    expect(fkViolations, isEmpty);

    // Database can be closed, reopened, and queried
    await db.close();
    final reopenedDb = AppDatabase(NativeDatabase(
      File(p.join(tempDir.path, 'distillery_source.db')),
      setup: (rawDb) => rawDb.execute('PRAGMA foreign_keys = ON;'),
    ));
    final reopenedService = DatabaseService(reopenedDb);
    final reopenedFactories = await reopenedService.factories.getAllFactories();
    expect(reopenedFactories.length, equals(5));
    await reopenedDb.close();
  });

  // ===========================================================================
  // TEST O: Backup during active database writes & WAL verification
  // ===========================================================================
  test('TEST O: Backup creation during active database writes in WAL mode', () async {
    print('\n--- RUNNING TEST O: BACKUP DURING ACTIVE DATABASE WRITES ---');

    final factories = await service.factories.getAllFactories();
    final factoryId = factories.first.id;

    // 1. Initial write
    final fileId = await service.inputFiles.insertFile(
      InputFilesCompanion.insert(
        factoryId: factoryId,
        driveFileId: 'drive_active_write_test',
        fileName: 'Active_Write.xlsx',
        status: 'NEW',
      ),
    );

    // 2. Perform concurrent writes around snapshot creation
    final batchFutures = <Future<int>>[];
    for (var i = 1; i <= 10; i++) {
      batchFutures.add(service.batches.insertBatch(
        BatchesCompanion.insert(
          factoryId: factoryId,
          inputFileId: fileId,
          batchId: 'BATCH_CONCURRENT_$i',
          fermenter: Value('F-0$i'),
        ),
      ));
    }

    // 3. Initiate SQLite atomic snapshot via VACUUM INTO
    final snapshotFile = await service.backupService.createConsistentSnapshot();

    // 4. Perform additional writes immediately after snapshot request
    for (var i = 11; i <= 20; i++) {
      await service.batches.insertBatch(
        BatchesCompanion.insert(
          factoryId: factoryId,
          inputFileId: fileId,
          batchId: 'BATCH_CONCURRENT_$i',
          fermenter: Value('F-0$i'),
        ),
      );
    }
    await Future.wait(batchFutures);

    // 5. Open and independently validate the generated backup snapshot
    expect(await snapshotFile.exists(), isTrue);
    expect(await snapshotFile.length(), greaterThan(0));

    final rawBackupDb = sqlite3.open(snapshotFile.path);

    // Run PRAGMA integrity_check on backup
    final integrityResult = rawBackupDb.select('PRAGMA integrity_check;');
    final integrityStatus = integrityResult.first['integrity_check'] as String;
    expect(integrityStatus.toLowerCase(), equals('ok'));

    // Run PRAGMA foreign_key_check on backup
    final fkResult = rawBackupDb.select('PRAGMA foreign_key_check;');
    expect(fkResult, isEmpty);

    // Verify all 9 tables exist in backup
    final tables = rawBackupDb.select("SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%';");
    final tableNames = tables.map((r) => r['name'] as String).toList();
    for (final req in BackupService.requiredTables) {
      expect(tableNames.contains(req), isTrue, reason: 'Table $req must exist in backup');
    }

    rawBackupDb.close();

    // 6. Verify source database remains valid and intact
    final totalBatches = await service.batches.getAllBatches();
    expect(totalBatches.length, equals(20));

    final sourceFkViolations = await db.customSelect('PRAGMA foreign_key_check;').get();
    expect(sourceFkViolations, isEmpty);

    print('[TEST O PASSED] SQLite VACUUM INTO atomic snapshot verified successfully with active concurrent writes.');

    if (await snapshotFile.exists()) {
      await snapshotFile.delete();
    }
  });

  // ===========================================================================
  // STEP 7 TESTS: Factory-Aware F01 Backup Tests (NO PRUNING)
  // ===========================================================================

  test('STEP 7 - TEST A: Snapshot creation failure -> FAILED, no verified_at, no pruning', () async {
    final brokenService = BackupService(
      db,
      driveClient: mockClient,
      tempDirectoryProvider: () async => Directory('Z:\\non_existent_folder_99999'),
    );

    final progressLogs = <String>[];
    final result = await brokenService.backupFactory(
      factoryCode: 'F01',
      plantName: 'Haliyal',
      dbPrefix: 'haliyal',
      customClient: mockClient,
      onProgress: progressLogs.add,
    );

    expect(result.status, equals(BackupExecutionStatus.snapshotFailed));
    expect(result.isSuccess, isFalse);

    final history = await service.backupHistory.getAllBackups();
    expect(history.isNotEmpty, isTrue);
    expect(history.first.status, equals('FAILED'));
    expect(history.first.verifiedAt, isNull);
    expect(history.first.deletedLocalRecords, equals(0));
  });

  test('STEP 7 - TEST B: Google authentication failure -> FAILED, no verified_at, no pruning', () async {
    mockClient.isUserAuthenticated = false;

    final progressLogs = <String>[];
    final result = await service.backupService.backupFactory(
      factoryCode: 'F01',
      plantName: 'Haliyal',
      dbPrefix: 'haliyal',
      customClient: mockClient,
      onProgress: progressLogs.add,
    );

    expect(result.status, equals(BackupExecutionStatus.authenticationFailed));
    expect(result.isSuccess, isFalse);

    final history = await service.backupHistory.getAllBackups();
    expect(history.isNotEmpty, isTrue);
    expect(history.first.status, equals('FAILED'));
    expect(history.first.verifiedAt, isNull);
    expect(history.first.deletedLocalRecords, equals(0));
  });

  test('STEP 7 - TEST C: Google Drive upload failure -> FAILED, no verified_at, no pruning', () async {
    mockClient.shouldFailUpload = true;

    final progressLogs = <String>[];
    final result = await service.backupService.backupFactory(
      factoryCode: 'F01',
      plantName: 'Haliyal',
      dbPrefix: 'haliyal',
      customClient: mockClient,
      onProgress: progressLogs.add,
    );

    expect(result.status, equals(BackupExecutionStatus.uploadFailed));
    expect(result.isSuccess, isFalse);

    final history = await service.backupHistory.getAllBackups();
    expect(history.isNotEmpty, isTrue);
    expect(history.first.status, equals('FAILED'));
    expect(history.first.verifiedAt, isNull);
    expect(history.first.deletedLocalRecords, equals(0));
  });

  test('STEP 7 - TEST D: Remote verification failure -> VERIFICATION_FAILED, no verified_at, no pruning', () async {
    mockClient.corruptUploadedDb = true;

    final progressLogs = <String>[];
    final result = await service.backupService.backupFactory(
      factoryCode: 'F01',
      plantName: 'Haliyal',
      dbPrefix: 'haliyal',
      customClient: mockClient,
      onProgress: progressLogs.add,
    );

    expect(result.status, equals(BackupExecutionStatus.verificationFailed));
    expect(result.isSuccess, isFalse);

    final history = await service.backupHistory.getAllBackups();
    expect(history.isNotEmpty, isTrue);
    expect(history.first.status, equals('VERIFICATION_FAILED'));
    expect(history.first.verifiedAt, isNull);
    expect(history.first.deletedLocalRecords, equals(0));
  });

  test('STEP 7 - TEST E: Fully successful F01 / Haliyal backup -> SUCCESS, verified_at != NULL, NO PRUNING', () async {
    final factories = await service.factories.getAllFactories();
    final factoryId = factories.first.id;

    // 1. Seed some realistic records into F01
    final fileId = await service.inputFiles.insertFile(
      InputFilesCompanion.insert(
        factoryId: factoryId,
        driveFileId: 'f01_drive_file_real',
        fileName: 'Haliyal_170KLPD_Data.xlsx',
        status: 'PROCESSED',
      ),
    );

    final batchId = await service.batches.insertBatch(
      BatchesCompanion.insert(
        factoryId: factoryId,
        inputFileId: fileId,
        batchId: 'BATCH_HALIYAL_01',
      ),
    );

    final runId = await service.processingRuns.insertRun(
      ProcessingRunsCompanion.insert(
        inputFileId: fileId,
        batchId: Value(batchId),
        status: 'SUCCESS',
        startedAt: Value(DateTime.now().toUtc()),
      ),
    );

    await service.preprocessingData.insertRecord(
      PreprocessingDataCompanion.insert(
        batchId: batchId,
        inputFileId: fileId,
        processingRunId: runId,
        brix: const Value(16.5),
        temperature: const Value(32.0),
        sugarConsumptionRate: const Value(0.92),
      ),
    );

    final preBackupCount = await service.backupService.countTotalRecords();
    expect(preBackupCount, greaterThan(0));

    final progressLogs = <String>[];
    final result = await service.backupService.backupFactory(
      factoryCode: 'F01',
      plantName: 'Haliyal',
      dbPrefix: 'haliyal',
      customClient: mockClient,
      onProgress: progressLogs.add,
    );

    // 2. Validate Result
    expect(result.status, equals(BackupExecutionStatus.success));
    expect(result.isSuccess, isTrue);
    expect(result.deletedRecordsCount, equals(0)); // NO PRUNING IN STEP 7
    expect(result.driveFileId, isNotNull);

    // 3. Validate Progress Logs contain all structured step traces
    expect(progressLogs.any((l) => l.contains('[BACKUP] F01 / Haliyal')), isTrue);
    expect(progressLogs.any((l) => l.contains('Database opened')), isTrue);
    expect(progressLogs.any((l) => l.contains('Creating consistent SQLite snapshot')), isTrue);
    expect(progressLogs.any((l) => l.contains('Local integrity check')), isTrue);
    expect(progressLogs.any((l) => l.contains('Local foreign-key check')), isTrue);
    expect(progressLogs.any((l) => l.contains('Google authentication')), isTrue);
    expect(progressLogs.any((l) => l.contains('Uploading to Haliyal')), isTrue);
    expect(progressLogs.any((l) => l.contains('Uploaded file ID:')), isTrue);
    expect(progressLogs.any((l) => l.contains('Downloading uploaded backup for verification')), isTrue);
    expect(progressLogs.any((l) => l.contains('Remote integrity_check = ok')), isTrue);
    expect(progressLogs.any((l) => l.contains('Remote foreign_key_check = 0')), isTrue);
    expect(progressLogs.any((l) => l.contains('SUCCESS')), isTrue);
    expect(progressLogs.any((l) => l.contains('verified_at =')), isTrue);

    // 4. Validate backup_history Record in haliyal.db
    final history = await service.backupHistory.getAllBackups();
    final backup = history.firstWhere((b) => b.id == result.backupHistoryId);
    expect(backup.status, equals('SUCCESS'));
    expect(backup.verifiedAt, isNotNull);
    expect(backup.backupFileName.startsWith('haliyal_backup_'), isTrue);
    expect(backup.backupFileName.endsWith('.db'), isTrue);
    expect(backup.cloudProvider, equals('GOOGLE_DRIVE'));
    expect(backup.recordsBackedUp, equals(preBackupCount));
    expect(backup.deletedLocalRecords, equals(0)); // ZERO deleted records

    // 5. Verify local data was NOT pruned
    final postBackupCount = await service.backupService.countTotalRecords();
    // Only difference is +1 row in backup_history
    expect(postBackupCount, equals(preBackupCount + 1));

    final prepData = await service.preprocessingData.getAllRecords();
    expect(prepData.length, equals(1));
    expect(prepData.first.brix, closeTo(16.5, 0.001));

    // 6. Verify temporary snapshot was cleaned up
    final snapshotsDir = Directory(p.join(tempDir.path, 'distillery_snapshots'));
    if (snapshotsDir.existsSync()) {
      final remainingFiles = snapshotsDir.listSync();
      expect(remainingFiles.isEmpty, isTrue, reason: 'Temporary local snapshots must be deleted after upload');
    }
  });
}

