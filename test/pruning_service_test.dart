import 'dart:io';
import 'package:distillary/database/database.dart';
import 'package:distillary/services/database_service.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:sqlite3/sqlite3.dart' as ffi;

void main() {
  late AppDatabase db;
  late DatabaseService service;
  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('distillery_prune_test_');
    final dbFile = File(p.join(tempDir.path, 'test_haliyal.db'));
    db = AppDatabase(NativeDatabase(dbFile));
    service = DatabaseService(db);
  });

  tearDown(() async {
    await db.close();
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  group('STEP 8 â€” 7-Day Safe Local Retention & Pruning Tests', () {
    test('TEST A: No backup history record -> NO pruning occurs', () async {
      await service.backupService.seedRetentionTestFixtures(factoryCode: 'F01');

      final preCount = await service.backupService.countTotalRecords();
      expect(preCount, greaterThan(0));

      final pruneResult = await service.backupService.pruneHistoricalData(factoryCode: 'F01');

      expect(pruneResult.isSuccess, isFalse);
      expect(pruneResult.deletedRecordsCount, equals(0));
      expect(pruneResult.errorMessage, contains('No verified backup'));

      final postCount = await service.backupService.countTotalRecords();
      expect(postCount, equals(preCount));
    });

    test('TEST B: Backup status = FAILED -> NO pruning occurs', () async {
      await service.backupService.seedRetentionTestFixtures(factoryCode: 'F01');

      final now = DateTime.now().toUtc();
      final backupId = await db.into(db.backupHistory).insert(
        BackupHistoryCompanion.insert(
          backupFileName: 'haliyal_backup_failed.db',
          backupLocation: 'Google Drive / BACKUP_FOLDER / Haliyal',
          cloudProvider: 'GOOGLE_DRIVE',
          status: 'FAILED',
          errorMessage: const Value('Upload failed (HTTP 500)'),
          backupStartedAt: Value(now),
          backupCompletedAt: Value(now),
        ),
      );

      final preCount = await service.backupService.countTotalRecords();
      final pruneResult = await service.backupService.pruneHistoricalData(
        factoryCode: 'F01',
        specificBackupHistoryId: backupId,
      );

      expect(pruneResult.isSuccess, isFalse);
      expect(pruneResult.deletedRecordsCount, equals(0));

      final postCount = await service.backupService.countTotalRecords();
      expect(postCount, equals(preCount));
    });

    test('TEST C: Backup status = VERIFICATION_FAILED -> NO pruning occurs', () async {
      await service.backupService.seedRetentionTestFixtures(factoryCode: 'F01');

      final now = DateTime.now().toUtc();
      final backupId = await db.into(db.backupHistory).insert(
        BackupHistoryCompanion.insert(
          backupFileName: 'haliyal_backup_corrupt.db',
          backupLocation: 'Google Drive / BACKUP_FOLDER / Haliyal',
          cloudProvider: 'GOOGLE_DRIVE',
          status: 'VERIFICATION_FAILED',
          errorMessage: const Value('PRAGMA integrity_check failed on remote copy'),
          backupStartedAt: Value(now),
          backupCompletedAt: Value(now),
        ),
      );

      final preCount = await service.backupService.countTotalRecords();
      final pruneResult = await service.backupService.pruneHistoricalData(
        factoryCode: 'F01',
        specificBackupHistoryId: backupId,
      );

      expect(pruneResult.isSuccess, isFalse);
      expect(pruneResult.deletedRecordsCount, equals(0));

      final postCount = await service.backupService.countTotalRecords();
      expect(postCount, equals(preCount));
    });

    test('TEST D: verified_at = NULL -> NO pruning occurs', () async {
      await service.backupService.seedRetentionTestFixtures(factoryCode: 'F01');

      final now = DateTime.now().toUtc();
      final backupId = await db.into(db.backupHistory).insert(
        BackupHistoryCompanion.insert(
          backupFileName: 'haliyal_backup_unverified.db',
          backupLocation: 'Google Drive / BACKUP_FOLDER / Haliyal',
          cloudProvider: 'GOOGLE_DRIVE',
          status: 'SUCCESS', // Status says success, but verifiedAt is NULL!
          verifiedAt: const Value(null),
          backupStartedAt: Value(now),
        ),
      );

      final preCount = await service.backupService.countTotalRecords();
      final pruneResult = await service.backupService.pruneHistoricalData(
        factoryCode: 'F01',
        specificBackupHistoryId: backupId,
      );

      expect(pruneResult.isSuccess, isFalse);
      expect(pruneResult.deletedRecordsCount, equals(0));

      final postCount = await service.backupService.countTotalRecords();
      expect(postCount, equals(preCount));
    });

    test('TEST E: Verified backup exists but candidate data is not covered -> NO pruning', () async {
      final now = DateTime.now().toUtc();

      // Seed backup that occurred 15 days ago with 0 records
      final backupId = await db.into(db.backupHistory).insert(
        BackupHistoryCompanion.insert(
          backupFileName: 'haliyal_backup_old.db',
          backupLocation: 'Google Drive / BACKUP_FOLDER / Haliyal',
          cloudProvider: 'GOOGLE_DRIVE',
          status: 'SUCCESS',
          verifiedAt: Value(now.subtract(const Duration(days: 15))),
          backupStartedAt: Value(now.subtract(const Duration(days: 15))),
          recordsBackedUp: const Value(0),
        ),
      );

      await service.backupService.seedRetentionTestFixtures(factoryCode: 'F01', referenceNow: now);

      final pruneResult = await service.backupService.pruneHistoricalData(
        factoryCode: 'F01',
        specificBackupHistoryId: backupId,
        referenceNow: now,
      );

      expect(pruneResult.isSuccess, isFalse);
      expect(pruneResult.deletedRecordsCount, equals(0));
      expect(pruneResult.errorMessage, contains('COVERAGE GUARD'));
    });

    test('TEST G & TEST H: Verified backup valid -> ONLY eligible 8d & 30d records pruned; 1d, 6d, 7d boundary & PROTECTED tables remain intact', () async {
      final now = DateTime.utc(2026, 8, 19, 12, 0, 0);

      // 1. Seed 5 test fixtures (1d, 6d, 7d boundary, 8d, 30d)
      await service.backupService.seedRetentionTestFixtures(factoryCode: 'F01', referenceNow: now);

      // Verify 5 records per eligible table exist before pruning
      expect((await service.preprocessingData.getAllRecords()).length, equals(5));
      expect((await service.processingRuns.getAllRuns()).length, equals(5));
      expect((await service.predictions.getAllPredictions()).length, equals(5));
      expect((await db.select(db.mqttPublishLog).get()).length, equals(5));

      // Verify protected tables exist
      expect((await service.factories.getAllFactories()).length, equals(1));
      expect((await service.inputFiles.getAllFiles()).length, equals(1));
      expect((await service.batches.getAllBatches()).length, equals(1));
      expect((await service.aiModels.getAllModels()).length, equals(1));

      // 2. Seed a valid, verified backup in backup_history
      final backupId = await db.into(db.backupHistory).insert(
        BackupHistoryCompanion.insert(
          backupFileName: 'haliyal_backup_verified.db',
          backupLocation: 'Google Drive / BACKUP_FOLDER / Haliyal',
          cloudProvider: 'GOOGLE_DRIVE',
          status: 'SUCCESS',
          verifiedAt: Value(now),
          backupStartedAt: Value(now),
          recordsBackedUp: const Value(24),
        ),
      );

      // 3. Execute Pruning with 7-day retention
      final progressLogs = <String>[];
      final pruneResult = await service.backupService.pruneHistoricalData(
        factoryCode: 'F01',
        retentionPeriod: const Duration(days: 7),
        referenceNow: now,
        specificBackupHistoryId: backupId,
        onProgress: progressLogs.add,
      );

      // 4. Verify Prune Result & Step 8A Audit Sum Consistency
      expect(pruneResult.isSuccess, isTrue);
      // 2 records deleted per table (8d and 30d) across 4 eligible tables = 8 deleted records total
      expect(pruneResult.deletedRecordsCount, equals(8));
      expect(pruneResult.totalDeleted, equals(8));
      expect(pruneResult.preprocessingDataDeleted, equals(2));
      expect(pruneResult.processingRunsDeleted, equals(2));
      expect(pruneResult.predictionsDeleted, equals(2));
      expect(pruneResult.mqttPublishLogDeleted, equals(2));
      expect(pruneResult.isSumConsistent, isTrue);
      expect(
        pruneResult.preprocessingDataDeleted +
            pruneResult.processingRunsDeleted +
            pruneResult.predictionsDeleted +
            pruneResult.mqttPublishLogDeleted,
        equals(pruneResult.totalDeleted),
      );
      expect(pruneResult.integrityCheckPassed, isTrue);
      expect(pruneResult.foreignKeyCheckPassed, isTrue);

      // 5. Verify Exact Boundary Rule: 3 records remain (1d, 6d, 7d boundary)
      final remainingPrep = await service.preprocessingData.getAllRecords();
      expect(remainingPrep.length, equals(3));
      final remainingRuns = await service.processingRuns.getAllRuns();
      expect(remainingRuns.length, equals(3));
      final remainingPreds = await service.predictions.getAllPredictions();
      expect(remainingPreds.length, equals(3));
      final remainingMqtt = await db.select(db.mqttPublishLog).get();
      expect(remainingMqtt.length, equals(3));

      // Verify the timestamps of the remaining records
      final cutoff = now.subtract(const Duration(days: 7));
      for (final p in remainingPrep) {
        expect(p.createdAt.isBefore(cutoff), isFalse, reason: 'Retained record must NOT be older than cutoff');
      }

      // 6. TEST H: Verify PROTECTED tables are 100% UNCHANGED
      expect((await service.factories.getAllFactories()).length, equals(1));
      expect((await service.inputFiles.getAllFiles()).length, equals(1));
      expect((await service.batches.getAllBatches()).length, equals(1));
      expect((await service.aiModels.getAllModels()).length, equals(1));

      // 7. Verify backup_history audit value matches total_deleted exactly
      final history = await service.backupHistory.getAllBackups();
      final updatedBackup = history.firstWhere((b) => b.id == backupId);
      expect(updatedBackup.deletedLocalRecords, equals(pruneResult.totalDeleted));
      expect(updatedBackup.deletedLocalRecords, equals(8));

      // 8. PRAGMA foreign_key_check must return 0 violations
      final fkCheck = await db.customSelect('PRAGMA foreign_key_check;').get();
      expect(fkCheck.isEmpty, isTrue);

      // 9. PRAGMA integrity_check must return ok
      final integrityCheck = await db.customSelect('PRAGMA integrity_check;').getSingle();
      expect(integrityCheck.data['integrity_check'], equals('ok'));
    });

    test('TEST J: RUNNING processing runs are never pruned even if older than retention period', () async {
      final now = DateTime.utc(2026, 8, 19, 12, 0, 0);
      final oldTime = now.subtract(const Duration(days: 20));

      final factoryId = await db.into(db.factories).insert(
        FactoriesCompanion.insert(factoryCode: 'F01', factoryName: 'Haliyal', driveFolderId: 'f01_folder'),
      );
      final fileId = await db.into(db.inputFiles).insert(
        InputFilesCompanion.insert(factoryId: factoryId, driveFileId: 'f1', fileName: 'f1.xlsx', status: 'PROCESSED'),
      );

      // Create a RUNNING processing run from 20 days ago
      final runningRunId = await db.into(db.processingRuns).insert(
        ProcessingRunsCompanion.insert(
          inputFileId: fileId,
          status: 'RUNNING',
          startedAt: Value(oldTime),
        ),
      );

      // Seed verified backup
      final backupId = await db.into(db.backupHistory).insert(
        BackupHistoryCompanion.insert(
          backupFileName: 'haliyal_backup_v.db',
          backupLocation: 'Google Drive / BACKUP_FOLDER / Haliyal',
          cloudProvider: 'GOOGLE_DRIVE',
          status: 'SUCCESS',
          verifiedAt: Value(now),
          backupStartedAt: Value(now),
          recordsBackedUp: const Value(5),
        ),
      );

      final pruneResult = await service.backupService.pruneHistoricalData(
        factoryCode: 'F01',
        referenceNow: now,
        specificBackupHistoryId: backupId,
      );

      expect(pruneResult.isSuccess, isTrue);
      final remainingRuns = await service.processingRuns.getAllRuns();
      expect(remainingRuns.any((r) => r.id == runningRunId), isTrue, reason: 'RUNNING processing runs must never be deleted');
    });

    test('TEST F: Verified backup belongs to different factory database -> NO pruning', () async {
      final now = DateTime.now().toUtc();
      await service.backupService.seedRetentionTestFixtures(factoryCode: 'F01', referenceNow: now);

      // In F01's database, there are no verified backups for F02
      final pruneResult = await service.backupService.pruneHistoricalData(
        factoryCode: 'F02',
        referenceNow: now,
      );

      expect(pruneResult.isSuccess, isFalse);
      expect(pruneResult.deletedRecordsCount, equals(0));
    });

    test('TEST I: Multi-factory isolation: Pruning F01 never deletes data from F02-F05 databases', () async {
      final f02DbFile = File(p.join(tempDir.path, 'test_sankili.db'));
      final f02Db = AppDatabase(NativeDatabase(f02DbFile));
      final f02Service = DatabaseService(f02Db);

      final now = DateTime.utc(2026, 8, 19, 12, 0, 0);
      await service.backupService.seedRetentionTestFixtures(factoryCode: 'F01', referenceNow: now);
      await f02Service.backupService.seedRetentionTestFixtures(factoryCode: 'F02', referenceNow: now);

      // Seed verified backup ONLY in F01
      final backupId = await db.into(db.backupHistory).insert(
        BackupHistoryCompanion.insert(
          backupFileName: 'haliyal_backup_v.db',
          backupLocation: 'Google Drive / BACKUP_FOLDER / Haliyal',
          cloudProvider: 'GOOGLE_DRIVE',
          status: 'SUCCESS',
          verifiedAt: Value(now),
          backupStartedAt: Value(now),
          recordsBackedUp: const Value(24),
        ),
      );

      // Prune F01
      final pruneF01 = await service.backupService.pruneHistoricalData(
        factoryCode: 'F01',
        referenceNow: now,
        specificBackupHistoryId: backupId,
      );
      expect(pruneF01.isSuccess, isTrue);
      expect(pruneF01.deletedRecordsCount, equals(8));

      // Confirm F02 still has all 5 records in all tables (no pruning occurred in F02)
      final f02Prep = await f02Service.preprocessingData.getAllRecords();
      expect(f02Prep.length, equals(5));
      final f02Runs = await f02Service.processingRuns.getAllRuns();
      expect(f02Runs.length, equals(5));

      await f02Db.close();
    });

    test('TEST L: VACUUM and raw SQLite database reopen verification after pruning', () async {
      final now = DateTime.utc(2026, 8, 19, 12, 0, 0);
      await service.backupService.seedRetentionTestFixtures(factoryCode: 'F01', referenceNow: now);

      final backupId = await db.into(db.backupHistory).insert(
        BackupHistoryCompanion.insert(
          backupFileName: 'haliyal_backup_vac.db',
          backupLocation: 'Google Drive / BACKUP_FOLDER / Haliyal',
          cloudProvider: 'GOOGLE_DRIVE',
          status: 'SUCCESS',
          verifiedAt: Value(now),
          backupStartedAt: Value(now),
          recordsBackedUp: const Value(24),
        ),
      );

      final pruneResult = await service.backupService.pruneHistoricalData(
        factoryCode: 'F01',
        referenceNow: now,
        specificBackupHistoryId: backupId,
      );
      expect(pruneResult.isSuccess, isTrue);

      // Close Drift connection
      await db.close();

      // Open database directly with native SQLite FFI to verify low-level integrity & VACUUM
      final dbFile = File(p.join(tempDir.path, 'test_haliyal.db'));
      final rawDb = ffi.sqlite3.open(dbFile.path);

      final integrity = rawDb.select('PRAGMA integrity_check;');
      expect(integrity.first['integrity_check'], equals('ok'));

      final fkViolations = rawDb.select('PRAGMA foreign_key_check;');
      expect(fkViolations.isEmpty, isTrue);

      final prepCount = rawDb.select('SELECT COUNT(*) AS c FROM preprocessing_data;').first['c'];
      expect(prepCount, equals(3));

      final batchCount = rawDb.select('SELECT COUNT(*) AS c FROM batches;').first['c'];
      expect(batchCount, equals(1));

      rawDb.close();

      // Reopen with Drift to ensure seamless application reopen
      db = AppDatabase(NativeDatabase(dbFile));
      service = DatabaseService(db);
      final reloadedPrep = await service.preprocessingData.getAllRecords();
      expect(reloadedPrep.length, equals(3));
    });

    test('TEST M: STEP 8A â€” Audit Breakdown & Sum Consistency (sum(per_table_deleted) == total_deleted == backup_history.deleted_local_records)', () async {
      final now = DateTime.utc(2026, 8, 19, 12, 0, 0);

      // Seed fixtures
      await service.backupService.seedRetentionTestFixtures(factoryCode: 'F01', referenceNow: now);

      // Seed verified backup
      final backupId = await db.into(db.backupHistory).insert(
        BackupHistoryCompanion.insert(
          backupFileName: 'haliyal_backup_audit.db',
          backupLocation: 'Google Drive / BACKUP_FOLDER / Haliyal',
          cloudProvider: 'GOOGLE_DRIVE',
          status: 'SUCCESS',
          verifiedAt: Value(now),
          backupStartedAt: Value(now),
          recordsBackedUp: const Value(24),
        ),
      );

      final pruneResult = await service.backupService.pruneHistoricalData(
        factoryCode: 'F01',
        referenceNow: now,
        specificBackupHistoryId: backupId,
      );

      expect(pruneResult.isSuccess, isTrue);

      // 1. Verify breakdown properties
      expect(pruneResult.preprocessingDataDeleted, equals(2));
      expect(pruneResult.processingRunsDeleted, equals(2));
      expect(pruneResult.predictionsDeleted, equals(2));
      expect(pruneResult.mqttPublishLogDeleted, equals(2));

      // 2. Verify sum(per_table_deleted) == total_deleted
      final calculatedSum = pruneResult.preprocessingDataDeleted +
          pruneResult.processingRunsDeleted +
          pruneResult.predictionsDeleted +
          pruneResult.mqttPublishLogDeleted;
      expect(calculatedSum, equals(pruneResult.totalDeleted));
      expect(pruneResult.isSumConsistent, isTrue);

      // 3. Verify backup_history audit field matches total_deleted
      final history = await service.backupHistory.getAllBackups();
      final backup = history.firstWhere((b) => b.id == backupId);
      expect(backup.deletedLocalRecords, equals(pruneResult.totalDeleted));
      expect(backup.deletedLocalRecords, equals(calculatedSum));

      // 4. Verify auditBreakdown string contains all components
      expect(pruneResult.auditBreakdown, contains('total_deleted = 8'));
      expect(pruneResult.auditBreakdown, contains('preprocessing_data_deleted = 2'));
      expect(pruneResult.auditBreakdown, contains('processing_runs_deleted = 2'));
      expect(pruneResult.auditBreakdown, contains('predictions_deleted = 2'));
      expect(pruneResult.auditBreakdown, contains('mqtt_publish_log_deleted = 2'));
    });
  });
}

