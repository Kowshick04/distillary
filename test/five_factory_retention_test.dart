// ignore_for_file: avoid_print

import 'dart:io';
import 'package:drift/drift.dart' as drift;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:sqlite3/sqlite3.dart' as ffi;

import 'package:distillary/database/database.dart' hide isNull, isNotNull;
import 'package:distillary/services/backup_service.dart';
import 'package:distillary/services/database_service.dart';
import 'package:distillary/services/google_drive_backup_client.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;
  late Directory mockCloudStorageDir;
  late MockGoogleDriveBackupClient mockClient;

  final factories = [
    {'code': 'F01', 'name': 'Haliyal', 'dbFile': 'haliyal.db', 'folderId': '1CO1Pki8RYmINwVfMCb5VqJhM-jgOnWi2'},
    {'code': 'F02', 'name': 'Sankili', 'dbFile': 'sankili.db', 'folderId': '1Y_M_DqYC1UyBrmC_kOnTAESAuaOSEt0k'},
    {'code': 'F03', 'name': 'Nellikuppam', 'dbFile': 'nellikuppam.db', 'folderId': '1xOx6x3-4o-nkKvgRyETPwy00aLC-Bm3m'},
    {'code': 'F04', 'name': 'Sivagangai', 'dbFile': 'sivagangai.db', 'folderId': '1652ElcOUK2YoqhC37LAHMpJmYlBG5B_I'},
    {'code': 'F05', 'name': 'Bagalkot', 'dbFile': 'bagalkot.db', 'folderId': '1922Z7O-VQs-6IdtUgF9Mqi-VvJW3_4D8'},
  ];

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('step9_five_factory_test_');
    mockCloudStorageDir = Directory(p.join(tempDir.path, 'mock_cloud_storage'));
    await mockCloudStorageDir.create(recursive: true);
    mockClient = MockGoogleDriveBackupClient(mockCloudStorageDir: mockCloudStorageDir);
  });

  tearDown(() async {
    if (await tempDir.exists()) {
      try {
        await tempDir.delete(recursive: true);
      } catch (_) {}
    }
  });

  group('STEP 9 â€” 1. isBackupDue() Logic Tests', () {
    test('isBackupDue returns true when no verified backup exists', () async {
      final dbFile = File(p.join(tempDir.path, 'due_test1.db'));
      final db = AppDatabase(NativeDatabase(dbFile));
      final service = DatabaseService(db);

      final isDue = await service.backupService.isBackupDue();
      expect(isDue, isTrue, reason: 'Must be due when no backup exists');

      await db.close();
    });

    test('isBackupDue returns false when verified backup is within 7 days', () async {
      final dbFile = File(p.join(tempDir.path, 'due_test2.db'));
      final db = AppDatabase(NativeDatabase(dbFile));
      final service = DatabaseService(db);

      final now = DateTime.utc(2026, 8, 19, 12, 0, 0);
      final backupTime = now.subtract(const Duration(days: 3)); // 3 days old

      await db.into(db.backupHistory).insert(
        BackupHistoryCompanion.insert(
          backupFileName: 'test_backup.db',
          backupLocation: 'Google Drive / BACKUP_FOLDER / Haliyal',
          cloudProvider: 'GOOGLE_DRIVE',
          status: 'SUCCESS',
          verifiedAt: drift.Value(backupTime),
          backupStartedAt: drift.Value(backupTime),
        ),
      );

      final isDue = await service.backupService.isBackupDue(
        backupInterval: const Duration(days: 7),
        referenceNow: now,
      );
      expect(isDue, isFalse, reason: 'Must NOT be due if verified backup is only 3 days old (< 7d)');

      await db.close();
    });

    test('isBackupDue returns true when verified backup is older than 7 days', () async {
      final dbFile = File(p.join(tempDir.path, 'due_test3.db'));
      final db = AppDatabase(NativeDatabase(dbFile));
      final service = DatabaseService(db);

      final now = DateTime.utc(2026, 8, 19, 12, 0, 0);
      final backupTime = now.subtract(const Duration(days: 7, hours: 1)); // 7d 1h old

      await db.into(db.backupHistory).insert(
        BackupHistoryCompanion.insert(
          backupFileName: 'test_backup.db',
          backupLocation: 'Google Drive / BACKUP_FOLDER / Haliyal',
          cloudProvider: 'GOOGLE_DRIVE',
          status: 'SUCCESS',
          verifiedAt: drift.Value(backupTime),
          backupStartedAt: drift.Value(backupTime),
        ),
      );

      final isDue = await service.backupService.isBackupDue(
        backupInterval: const Duration(days: 7),
        referenceNow: now,
      );
      expect(isDue, isTrue, reason: 'Must be due when verified backup is >= 7 days old');

      await db.close();
    });

    test('isBackupDue returns true when previous backup was FAILED or UNVERIFIED', () async {
      final dbFile = File(p.join(tempDir.path, 'due_test4.db'));
      final db = AppDatabase(NativeDatabase(dbFile));
      final service = DatabaseService(db);

      final now = DateTime.utc(2026, 8, 19, 12, 0, 0);
      final backupTime = now.subtract(const Duration(days: 1));

      // Insert FAILED backup (even if recent)
      await db.into(db.backupHistory).insert(
        BackupHistoryCompanion.insert(
          backupFileName: 'failed_backup.db',
          backupLocation: 'Google Drive / BACKUP_FOLDER / Haliyal',
          cloudProvider: 'GOOGLE_DRIVE',
          status: 'FAILED',
          verifiedAt: const drift.Value(null),
          backupStartedAt: drift.Value(backupTime),
        ),
      );

      final isDue = await service.backupService.isBackupDue(referenceNow: now);
      expect(isDue, isTrue, reason: 'FAILED backups do not satisfy verified backup check');

      await db.close();
    });
  });

  group('STEP 9 â€” 2. Five-Factory Retention & Safety Validation (F01 to F05)', () {
    for (final f in factories) {
      final code = f['code']!;
      final name = f['name']!;
      final dbFileName = f['dbFile']!;
      final folderId = f['folderId']!;

      test('Factory $code ($name): Controlled 7-day retention, protected tables, audit counts & SQLite reopening', () async {
        final dbFile = File(p.join(tempDir.path, '${code}_$dbFileName'));
        var db = AppDatabase(NativeDatabase(
          dbFile,
          setup: (rawDb) {
            rawDb.execute('PRAGMA foreign_keys = ON;');
            rawDb.execute('PRAGMA journal_mode = WAL;');
          },
        ));
        var service = DatabaseService(db);
        service.backupService.driveClient = mockClient;

        final now = DateTime.utc(2026, 8, 19, 12, 0, 0);

        // 1. Seed controlled test fixtures (1d, 6d, 7d, 8d, 30d)
        await service.backupService.seedRetentionTestFixtures(factoryCode: code, referenceNow: now);

        // Verify pre-prune table counts: 5 records in each historical table
        expect((await service.preprocessingData.getAllRecords()).length, equals(5));
        expect((await service.processingRuns.getAllRuns()).length, equals(5));
        expect((await service.predictions.getAllPredictions()).length, equals(5));
        expect((await db.select(db.mqttPublishLog).get()).length, equals(5));

        // 2. Perform Verified Cloud Backup to dedicated factory folder
        final backupResult = await service.backupService.backupFactory(
          factoryCode: code,
          plantName: name,
          dbPrefix: name.toLowerCase(),
          targetFolderId: folderId,
          customClient: mockClient,
        );

        expect(backupResult.isSuccess, isTrue, reason: 'Backup failed: ${backupResult.errorMessage}');
        expect(backupResult.backupHistoryId, isNotNull);

        // 3. Execute 7-Day Safe Pruning
        final pruneResult = await service.backupService.pruneHistoricalData(
          factoryCode: code,
          retentionPeriod: const Duration(days: 7),
          referenceNow: now,
          specificBackupHistoryId: backupResult.backupHistoryId,
        );

        // 4. Verify Pruning Breakdown & Exact Audit Sums
        expect(pruneResult.isSuccess, isTrue);
        expect(pruneResult.totalDeleted, equals(8)); // 2 per table (8d and 30d) * 4 tables
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

        // 5. Verify Exact Boundary Rule: 3 records remain (1d, 6d, 7d boundary)
        final remainingPrep = await service.preprocessingData.getAllRecords();
        expect(remainingPrep.length, equals(3));
        final remainingRuns = await service.processingRuns.getAllRuns();
        expect(remainingRuns.length, equals(3));
        final remainingPreds = await service.predictions.getAllPredictions();
        expect(remainingPreds.length, equals(3));
        final remainingMqtt = await db.select(db.mqttPublishLog).get();
        expect(remainingMqtt.length, equals(3));

        // 6. Verify Protected Tables are 100% UNCHANGED
        expect((await service.factories.getAllFactories()).length, equals(1));
        expect((await service.inputFiles.getAllFiles()).length, equals(1));
        expect((await service.batches.getAllBatches()).length, equals(1));
        expect((await service.aiModels.getAllModels()).length, equals(1));

        // 7. Verify backup_history audit field matches total_deleted
        final history = await service.backupHistory.getAllBackups();
        final backupRecord = history.firstWhere((b) => b.id == backupResult.backupHistoryId);
        expect(backupRecord.deletedLocalRecords, equals(pruneResult.totalDeleted));
        expect(backupRecord.deletedLocalRecords, equals(8));

        // 8. Low-level PRAGMA & Reopen Verification
        await db.close();

        final rawDb = ffi.sqlite3.open(dbFile.path);
        final integrity = rawDb.select('PRAGMA integrity_check;').first['integrity_check'];
        expect(integrity, equals('ok'));

        final fkViolations = rawDb.select('PRAGMA foreign_key_check;');
        expect(fkViolations.isEmpty, isTrue);
        rawDb.close();

        // Reopen with Drift to verify seamless application reload
        db = AppDatabase(NativeDatabase(dbFile));
        service = DatabaseService(db);
        expect((await service.preprocessingData.getAllRecords()).length, equals(3));
        await db.close();
      });
    }
  });

  group('STEP 9 â€” 3. Multi-Factory Isolation & Cross-Factory Protection Tests', () {
    test('Cross-factory protection: F01 verified backup does NOT authorize F02 pruning without F02 backup', () async {
      final f01DbFile = File(p.join(tempDir.path, 'f01_iso.db'));
      final f02DbFile = File(p.join(tempDir.path, 'f02_iso.db'));

      final f01Db = AppDatabase(NativeDatabase(f01DbFile));
      final f02Db = AppDatabase(NativeDatabase(f02DbFile));

      final f01Service = DatabaseService(f01Db);
      final f02Service = DatabaseService(f02Db);

      final now = DateTime.utc(2026, 8, 19, 12, 0, 0);

      // Seed fixtures in both
      await f01Service.backupService.seedRetentionTestFixtures(factoryCode: 'F01', referenceNow: now);
      await f02Service.backupService.seedRetentionTestFixtures(factoryCode: 'F02', referenceNow: now);

      // Create verified backup ONLY in F01
      await f01Db.into(f01Db.backupHistory).insert(
        BackupHistoryCompanion.insert(
          backupFileName: 'haliyal_backup.db',
          backupLocation: 'Google Drive / BACKUP_FOLDER / Haliyal',
          cloudProvider: 'GOOGLE_DRIVE',
          status: 'SUCCESS',
          verifiedAt: drift.Value(now),
          backupStartedAt: drift.Value(now),
        ),
      );

      // Attempt to prune F02 (which has NO verified backup in its database)
      final f02PruneResult = await f02Service.backupService.pruneHistoricalData(
        factoryCode: 'F02',
        referenceNow: now,
      );

      // F02 pruning must be BLOCKED
      expect(f02PruneResult.isSuccess, isFalse);
      expect(f02PruneResult.totalDeleted, equals(0));
      expect(f02PruneResult.errorMessage, contains('SAFETY GUARD BLOCKED'));

      // F02 records must be 100% intact
      expect((await f02Service.preprocessingData.getAllRecords()).length, equals(5));

      await f01Db.close();
      await f02Db.close();
    });
  });

  group('STEP 9 â€” 4. Complete End-to-End Automated Pipeline Tests', () {
    test('performAutomatedBackupAndPruning skips when backup is not due', () async {
      final dbFile = File(p.join(tempDir.path, 'auto_not_due.db'));
      final db = AppDatabase(NativeDatabase(dbFile));
      final service = DatabaseService(db);

      final now = DateTime.utc(2026, 8, 19, 12, 0, 0);

      // Seed backup 2 days ago
      await db.into(db.backupHistory).insert(
        BackupHistoryCompanion.insert(
          backupFileName: 'recent.db',
          backupLocation: 'Google Drive / BACKUP_FOLDER / Haliyal',
          cloudProvider: 'GOOGLE_DRIVE',
          status: 'SUCCESS',
          verifiedAt: drift.Value(now.subtract(const Duration(days: 2))),
          backupStartedAt: drift.Value(now.subtract(const Duration(days: 2))),
        ),
      );

      final report = await service.backupService.performAutomatedBackupAndPruning(
        factoryCode: 'F01',
        plantName: 'Haliyal',
        dbPrefix: 'haliyal',
        backupInterval: const Duration(days: 7),
        referenceNow: now,
        customClient: mockClient,
      );

      expect(report.wasDue, isFalse);
      expect(report.status, equals(BackupExecutionStatus.notDue));
      expect(report.totalDeleted, equals(0));

      await db.close();
    });

    test('performAutomatedBackupAndPruning aborts pruning when cloud upload fails', () async {
      final dbFile = File(p.join(tempDir.path, 'auto_fail.db'));
      final db = AppDatabase(NativeDatabase(dbFile));
      final service = DatabaseService(db);

      final now = DateTime.utc(2026, 8, 19, 12, 0, 0);
      await service.backupService.seedRetentionTestFixtures(factoryCode: 'F01', referenceNow: now);

      // Trigger fail mode on client
      final failClient = MockGoogleDriveBackupClient(
        mockCloudStorageDir: mockCloudStorageDir,
        shouldFailUpload: true,
      );

      final report = await service.backupService.performAutomatedBackupAndPruning(
        factoryCode: 'F01',
        plantName: 'Haliyal',
        dbPrefix: 'haliyal',
        forceRun: true,
        referenceNow: now,
        customClient: failClient,
      );

      expect(report.isSuccess, isFalse);
      expect(report.totalDeleted, equals(0));
      expect(report.errorMessage, contains('Cloud backup or remote verification failed'));

      // Verify ZERO local rows deleted on failure
      expect((await service.preprocessingData.getAllRecords()).length, equals(5));

      await db.close();
    });

    test('performAutomatedBackupAndPruning executes complete backup -> verify -> prune when due', () async {
      final dbFile = File(p.join(tempDir.path, 'auto_success.db'));
      final db = AppDatabase(NativeDatabase(
        dbFile,
        setup: (rawDb) {
          rawDb.execute('PRAGMA foreign_keys = ON;');
          rawDb.execute('PRAGMA journal_mode = WAL;');
        },
      ));
      final service = DatabaseService(db);

      final now = DateTime.utc(2026, 8, 19, 12, 0, 0);
      await service.backupService.seedRetentionTestFixtures(factoryCode: 'F01', referenceNow: now);

      final report = await service.backupService.performAutomatedBackupAndPruning(
        factoryCode: 'F01',
        plantName: 'Haliyal',
        dbPrefix: 'haliyal',
        forceRun: true,
        referenceNow: now,
        customClient: mockClient,
      );

      expect(report.isSuccess, isTrue);
      expect(report.wasDue, isTrue);
      expect(report.totalDeleted, equals(8));
      expect(report.isSumConsistent, isTrue);
      expect((await service.preprocessingData.getAllRecords()).length, equals(3));

      await db.close();
    });
  });
}

