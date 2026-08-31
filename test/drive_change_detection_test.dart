import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:distillary/database/database.dart' hide isNull, isNotNull;
import 'package:distillary/services/database_service.dart';
import 'package:distillary/services/drive_bridge_service.dart';

void main() {
  late Directory tempDir;
  late File dbFile;
  late AppDatabase db;
  late DatabaseService dbService;
  late DriveBridgeService bridgeService;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('drive_change_detection_test_');
    dbFile = File('${tempDir.path}/distillery.db');
    db = AppDatabase(NativeDatabase(dbFile));
    dbService = DatabaseService(db);
    await dbService.seedInitialFactories();
    bridgeService = DriveBridgeService(dbService);
  });

  tearDown(() async {
    bridgeService.dispose();
    await db.close();
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  group('STEP 2B: Google Drive Change Detection & Drift Persistence', () {
    test('TEST 1: First scan of 1.xlsx -> NEW and persists in SQLite input_files', () async {
      final f01 = await dbService.factories.getFactoryByCode('F01');
      expect(f01, isNotNull);

      final result = await bridgeService.processAndClassifyFile(
        factoryCode: 'F01',
        factoryId: f01!.id,
        driveFileId: 'DRIVE_FILE_ID_001',
        fileName: '1.xlsx',
        mimeType: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
        sizeBytes: 8192,
        modifiedTime: '2026-08-18T10:00:00.000Z',
      );

      // Classification & Event Check
      expect(result.file.syncStatus, equals('NEW'));
      expect(result.event.changeType, equals(FileChangeType.newFile));
      expect(result.event.isActionable, isTrue);

      // SQLite Drift input_files verification
      final allFiles = await dbService.inputFiles.getAllFiles();
      expect(allFiles.length, equals(1));
      expect(allFiles.first.driveFileId, equals('DRIVE_FILE_ID_001'));
      expect(allFiles.first.fileName, equals('1.xlsx'));
      expect(allFiles.first.status, equals('NEW'));
      expect(allFiles.first.fileSizeBytes, equals(BigInt.from(8192)));
      expect(allFiles.first.driveModifiedAt, isNotNull);
    });

    test('TEST 2: Second scan without Drive modification -> UNCHANGED', () async {
      final f01 = (await dbService.factories.getFactoryByCode('F01'))!;

      // 1. Initial scan
      await bridgeService.processAndClassifyFile(
        factoryCode: 'F01',
        factoryId: f01.id,
        driveFileId: 'DRIVE_FILE_ID_001',
        fileName: '1.xlsx',
        mimeType: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
        sizeBytes: 8192,
        modifiedTime: '2026-08-18T10:00:00.000Z',
      );

      // 2. Second scan with identical Drive timestamp and size
      final secondScan = await bridgeService.processAndClassifyFile(
        factoryCode: 'F01',
        factoryId: f01.id,
        driveFileId: 'DRIVE_FILE_ID_001',
        fileName: '1.xlsx',
        mimeType: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
        sizeBytes: 8192,
        modifiedTime: '2026-08-18T10:00:00.000Z',
      );

      expect(secondScan.file.syncStatus, equals('UNCHANGED'));
      expect(secondScan.event.changeType, equals(FileChangeType.unchanged));
      expect(secondScan.event.isActionable, isFalse);

      // Verify no duplicate row created
      final allFiles = await dbService.inputFiles.getAllFiles();
      expect(allFiles.length, equals(1));
      expect(allFiles.first.status, equals('UNCHANGED'));
    });

    test('TEST 3: Modify 1.xlsx in Google Drive -> scan -> MODIFIED', () async {
      final f01 = (await dbService.factories.getFactoryByCode('F01'))!;

      // 1. Initial scan
      await bridgeService.processAndClassifyFile(
        factoryCode: 'F01',
        factoryId: f01.id,
        driveFileId: 'DRIVE_FILE_ID_001',
        fileName: '1.xlsx',
        sizeBytes: 8192,
        modifiedTime: '2026-08-18T10:00:00.000Z',
      );

      // 2. File modified in Google Drive (updated timestamp and size)
      final modifiedScan = await bridgeService.processAndClassifyFile(
        factoryCode: 'F01',
        factoryId: f01.id,
        driveFileId: 'DRIVE_FILE_ID_001',
        fileName: '1.xlsx',
        sizeBytes: 10240,
        modifiedTime: '2026-08-18T11:30:00.000Z',
      );

      expect(modifiedScan.file.syncStatus, equals('MODIFIED'));
      expect(modifiedScan.event.changeType, equals(FileChangeType.modified));
      expect(modifiedScan.event.isActionable, isTrue);

      // Verify SQLite row updated in-place (no duplicate)
      final allFiles = await dbService.inputFiles.getAllFiles();
      expect(allFiles.length, equals(1));
      expect(allFiles.first.status, equals('MODIFIED'));
      expect(allFiles.first.fileSizeBytes, equals(BigInt.from(10240)));
      expect(allFiles.first.driveModifiedAt!.toUtc(), equals(DateTime.parse('2026-08-18T11:30:00.000Z')));
    });

    test('TEST 4: Restart application -> scan the same unchanged file -> UNCHANGED', () async {
      final f01 = (await dbService.factories.getFactoryByCode('F01'))!;

      // 1. First scan in Session 1
      await bridgeService.processAndClassifyFile(
        factoryCode: 'F01',
        factoryId: f01.id,
        driveFileId: 'DRIVE_FILE_ID_001',
        fileName: '1.xlsx',
        sizeBytes: 8192,
        modifiedTime: '2026-08-18T10:00:00.000Z',
      );

      // 2. Simulate Cold App Restart (close db connection and reopen fresh)
      bridgeService.dispose();
      await db.close();

      final reopenedDb = AppDatabase(NativeDatabase(dbFile));
      final reopenedDbService = DatabaseService(reopenedDb);
      final reopenedBridge = DriveBridgeService(reopenedDbService);

      try {
        final postRestartScan = await reopenedBridge.processAndClassifyFile(
          factoryCode: 'F01',
          factoryId: f01.id,
          driveFileId: 'DRIVE_FILE_ID_001',
          fileName: '1.xlsx',
          sizeBytes: 8192,
          modifiedTime: '2026-08-18T10:00:00.000Z',
        );

        expect(postRestartScan.file.syncStatus, equals('UNCHANGED'));
        expect(postRestartScan.event.isActionable, isFalse);

        final files = await reopenedDbService.inputFiles.getAllFiles();
        expect(files.length, equals(1));
      } finally {
        reopenedBridge.dispose();
        await reopenedDb.close();
      }
    });

    test('TEST 5: Restart application after modifying the file -> scan -> MODIFIED', () async {
      final f01 = (await dbService.factories.getFactoryByCode('F01'))!;

      // 1. Initial scan in Session 1
      await bridgeService.processAndClassifyFile(
        factoryCode: 'F01',
        factoryId: f01.id,
        driveFileId: 'DRIVE_FILE_ID_001',
        fileName: '1.xlsx',
        sizeBytes: 8192,
        modifiedTime: '2026-08-18T10:00:00.000Z',
      );

      // 2. Simulate Cold App Restart
      bridgeService.dispose();
      await db.close();

      final reopenedDb = AppDatabase(NativeDatabase(dbFile));
      final reopenedDbService = DatabaseService(reopenedDb);
      final reopenedBridge = DriveBridgeService(reopenedDbService);

      try {
        // 3. Scan with updated modification timestamp in Google Drive
        final postRestartModifiedScan = await reopenedBridge.processAndClassifyFile(
          factoryCode: 'F01',
          factoryId: f01.id,
          driveFileId: 'DRIVE_FILE_ID_001',
          fileName: '1.xlsx',
          sizeBytes: 12288,
          modifiedTime: '2026-08-18T14:00:00.000Z',
        );

        expect(postRestartModifiedScan.file.syncStatus, equals('MODIFIED'));
        expect(postRestartModifiedScan.event.isActionable, isTrue);

        final files = await reopenedDbService.inputFiles.getAllFiles();
        expect(files.length, equals(1));
        expect(files.first.status, equals('MODIFIED'));
        expect(files.first.fileSizeBytes, equals(BigInt.from(12288)));
      } finally {
        reopenedBridge.dispose();
        await reopenedDb.close();
      }
    });

    test('TEST 6: Verify only ONE logical input_files record exists per Drive file ID', () async {
      final f01 = (await dbService.factories.getFactoryByCode('F01'))!;

      // Run 5 consecutive scans with varying modifications
      await bridgeService.processAndClassifyFile(
        factoryCode: 'F01',
        factoryId: f01.id,
        driveFileId: 'DRIVE_FILE_ID_001',
        fileName: '1.xlsx',
        sizeBytes: 8192,
        modifiedTime: '2026-08-18T10:00:00.000Z',
      );

      await bridgeService.processAndClassifyFile(
        factoryCode: 'F01',
        factoryId: f01.id,
        driveFileId: 'DRIVE_FILE_ID_001',
        fileName: '1.xlsx',
        sizeBytes: 8192,
        modifiedTime: '2026-08-18T10:00:00.000Z',
      );

      await bridgeService.processAndClassifyFile(
        factoryCode: 'F01',
        factoryId: f01.id,
        driveFileId: 'DRIVE_FILE_ID_001',
        fileName: '1.xlsx',
        sizeBytes: 9000,
        modifiedTime: '2026-08-18T11:00:00.000Z',
      );

      await bridgeService.processAndClassifyFile(
        factoryCode: 'F01',
        factoryId: f01.id,
        driveFileId: 'DRIVE_FILE_ID_001',
        fileName: '1.xlsx',
        sizeBytes: 9000,
        modifiedTime: '2026-08-18T11:00:00.000Z',
      );

      await bridgeService.processAndClassifyFile(
        factoryCode: 'F01',
        factoryId: f01.id,
        driveFileId: 'DRIVE_FILE_ID_001',
        fileName: '1.xlsx',
        sizeBytes: 9500,
        modifiedTime: '2026-08-18T12:00:00.000Z',
      );

      final files = await dbService.inputFiles.getAllFiles();
      expect(files.length, equals(1)); // Exactly 1 row in SQLite!
    });

    test('TEST 7: Verify F01-F05 independently tracked', () async {
      final f01 = (await dbService.factories.getFactoryByCode('F01'))!;
      final f02 = (await dbService.factories.getFactoryByCode('F02'))!;
      final f03 = (await dbService.factories.getFactoryByCode('F03'))!;
      final f04 = (await dbService.factories.getFactoryByCode('F04'))!;
      final f05 = (await dbService.factories.getFactoryByCode('F05'))!;

      final factories = [f01, f02, f03, f04, f05];

      for (final f in factories) {
        final res = await bridgeService.processAndClassifyFile(
          factoryCode: f.factoryCode,
          factoryId: f.id,
          driveFileId: 'DRIVE_FILE_${f.factoryCode}',
          fileName: '${f.factoryCode}_data.xlsx',
          sizeBytes: 8192,
          modifiedTime: '2026-08-18T10:00:00.000Z',
        );
        expect(res.file.syncStatus, equals('NEW'));
      }

      final allFiles = await dbService.inputFiles.getAllFiles();
      expect(allFiles.length, equals(5));

      // Modify only F03 and verify only F03 is MODIFIED while others remain UNCHANGED
      final resF03 = await bridgeService.processAndClassifyFile(
        factoryCode: 'F03',
        factoryId: f03.id,
        driveFileId: 'DRIVE_FILE_F03',
        fileName: 'F03_data.xlsx',
        sizeBytes: 15000,
        modifiedTime: '2026-08-18T16:00:00.000Z',
      );
      expect(resF03.file.syncStatus, equals('MODIFIED'));

      final resF01 = await bridgeService.processAndClassifyFile(
        factoryCode: 'F01',
        factoryId: f01.id,
        driveFileId: 'DRIVE_FILE_F01',
        fileName: 'F01_data.xlsx',
        sizeBytes: 8192,
        modifiedTime: '2026-08-18T10:00:00.000Z',
      );
      expect(resF01.file.syncStatus, equals('UNCHANGED'));
    });

    test('TEST 8: Verify unchanged file does NOT trigger downstream processing', () async {
      final f01 = (await dbService.factories.getFactoryByCode('F01'))!;

      // Seed initial file
      await bridgeService.processAndClassifyFile(
        factoryCode: 'F01',
        factoryId: f01.id,
        driveFileId: 'DRIVE_FILE_ID_001',
        fileName: '1.xlsx',
        sizeBytes: 8192,
        modifiedTime: '2026-08-18T10:00:00.000Z',
      );

      final eventList = <DriveFileChangeEvent>[];
      final subscription = bridgeService.onFileChangeEvent.listen((e) => eventList.add(e));

      // Scan same file
      final scanResult = await bridgeService.processAndClassifyFile(
        factoryCode: 'F01',
        factoryId: f01.id,
        driveFileId: 'DRIVE_FILE_ID_001',
        fileName: '1.xlsx',
        sizeBytes: 8192,
        modifiedTime: '2026-08-18T10:00:00.000Z',
      );

      await Future.delayed(const Duration(milliseconds: 10));
      await subscription.cancel();

      expect(scanResult.event.isActionable, isFalse);
      expect(eventList.single.isActionable, isFalse);
      expect(eventList.single.changeType, equals(FileChangeType.unchanged));
    });

    test('TEST 9: Verify NEW and MODIFIED produce clear processing trigger/event', () async {
      final f01 = (await dbService.factories.getFactoryByCode('F01'))!;

      final emittedEvents = <DriveFileChangeEvent>[];
      final subscription = bridgeService.onFileChangeEvent.listen((e) => emittedEvents.add(e));

      // 1. Emit NEW
      await bridgeService.processAndClassifyFile(
        factoryCode: 'F01',
        factoryId: f01.id,
        driveFileId: 'DRIVE_FILE_ID_001',
        fileName: '1.xlsx',
        sizeBytes: 8192,
        modifiedTime: '2026-08-18T10:00:00.000Z',
      );

      // 2. Emit MODIFIED
      await bridgeService.processAndClassifyFile(
        factoryCode: 'F01',
        factoryId: f01.id,
        driveFileId: 'DRIVE_FILE_ID_001',
        fileName: '1.xlsx',
        sizeBytes: 9999,
        modifiedTime: '2026-08-18T15:00:00.000Z',
      );

      await Future.delayed(const Duration(milliseconds: 10));
      await subscription.cancel();

      expect(emittedEvents.length, equals(2));
      expect(emittedEvents[0].changeType, equals(FileChangeType.newFile));
      expect(emittedEvents[0].isActionable, isTrue);
      expect(emittedEvents[0].fileName, equals('1.xlsx'));

      expect(emittedEvents[1].changeType, equals(FileChangeType.modified));
      expect(emittedEvents[1].isActionable, isTrue);
      expect(emittedEvents[1].sizeBytes, equals(9999));
    });

    test('TEST 10: Verify MD5 hash changes -> MODIFIED even if timestamp matches', () async {
      final f01 = (await dbService.factories.getFactoryByCode('F01'))!;

      // 1. Initial scan with MD5 hash
      final res1 = await bridgeService.processAndClassifyFile(
        factoryCode: 'F01',
        factoryId: f01.id,
        driveFileId: 'DRIVE_FILE_MD5_TEST',
        fileName: 'md5_test.xlsx',
        sizeBytes: 8192,
        modifiedTime: '2026-08-18T10:00:00.000Z',
        md5Checksum: 'hash_v1_abc123',
      );
      expect(res1.file.syncStatus, equals('NEW'));

      // 2. Second scan with identical timestamp and size, but changed MD5
      final res2 = await bridgeService.processAndClassifyFile(
        factoryCode: 'F01',
        factoryId: f01.id,
        driveFileId: 'DRIVE_FILE_MD5_TEST',
        fileName: 'md5_test.xlsx',
        sizeBytes: 8192,
        modifiedTime: '2026-08-18T10:00:00.000Z',
        md5Checksum: 'hash_v2_xyz999',
      );
      expect(res2.file.syncStatus, equals('MODIFIED'));
      expect(res2.event.isActionable, isTrue);

      // Verify updated in SQLite
      final fileInDb = await dbService.inputFiles.getFileByDriveId(f01.id, 'DRIVE_FILE_MD5_TEST');
      expect(fileInDb?.fileHash, equals('hash_v2_xyz999'));
    });

    test('TEST 11: Verify classification queries existing SQLite record strictly before mutation', () async {
      final f01 = (await dbService.factories.getFactoryByCode('F01'))!;

      // Verify no record exists before first scan
      final beforeFirstScan = await dbService.inputFiles.getFileByDriveId(f01.id, 'DRIVE_FILE_ORDER_TEST');
      expect(beforeFirstScan, isNull);

      // First scan -> NEW
      final scan1 = await bridgeService.processAndClassifyFile(
        factoryCode: 'F01',
        factoryId: f01.id,
        driveFileId: 'DRIVE_FILE_ORDER_TEST',
        fileName: 'order_test.xlsx',
        sizeBytes: 5000,
        modifiedTime: '2026-08-18T10:00:00.000Z',
      );
      expect(scan1.file.syncStatus, equals('NEW'));

      // Verify record now exists in SQLite with status NEW
      final afterFirstScan = await dbService.inputFiles.getFileByDriveId(f01.id, 'DRIVE_FILE_ORDER_TEST');
      expect(afterFirstScan, isNotNull);
      expect(afterFirstScan!.status, equals('NEW'));

      // Second scan without modification -> UNCHANGED
      final scan2 = await bridgeService.processAndClassifyFile(
        factoryCode: 'F01',
        factoryId: f01.id,
        driveFileId: 'DRIVE_FILE_ORDER_TEST',
        fileName: 'order_test.xlsx',
        sizeBytes: 5000,
        modifiedTime: '2026-08-18T10:00:00.000Z',
      );
      expect(scan2.file.syncStatus, equals('UNCHANGED'));
      expect(scan2.event.isActionable, isFalse);
    });

    test('TEST 12: Sub-second / microsecond precision normalization prevents false MODIFIED', () async {
      final f01 = (await dbService.factories.getFactoryByCode('F01'))!;

      // 1. Initial scan with 6-digit microsecond timestamp from Google Drive
      final res1 = await bridgeService.processAndClassifyFile(
        factoryCode: 'F01',
        factoryId: f01.id,
        driveFileId: 'DRIVE_FILE_PRECISION_TEST',
        fileName: 'precision_test.xlsx',
        sizeBytes: 15120,
        modifiedTime: '2026-08-19T04:35:12.839123Z',
        md5Checksum: 'abc123def456',
      );
      expect(res1.file.syncStatus, equals('NEW'));

      // 2. Second scan with slightly truncated sub-seconds or exact same instant
      final res2 = await bridgeService.processAndClassifyFile(
        factoryCode: 'F01',
        factoryId: f01.id,
        driveFileId: 'DRIVE_FILE_PRECISION_TEST',
        fileName: 'precision_test.xlsx',
        sizeBytes: 15120,
        modifiedTime: '2026-08-19T04:35:12.839000Z',
        md5Checksum: 'ABC123DEF456', // uppercase variant
      );
      expect(res2.file.syncStatus, equals('UNCHANGED'));
      expect(res2.event.isActionable, isFalse);
    });

    test('TEST 13: Missing stored hash + present current hash does NOT trigger false MODIFIED', () async {
      final f01 = (await dbService.factories.getFactoryByCode('F01'))!;

      // 1. Initial scan without MD5 (e.g. from local or legacy record)
      final res1 = await bridgeService.processAndClassifyFile(
        factoryCode: 'F01',
        factoryId: f01.id,
        driveFileId: 'DRIVE_FILE_NULL_HASH_TEST',
        fileName: 'null_hash.xlsx',
        sizeBytes: 10000,
        modifiedTime: '2026-08-19T04:00:00.000Z',
        md5Checksum: null,
      );
      expect(res1.file.syncStatus, equals('NEW'));

      // 2. Second scan with MD5 available now, but identical timestamp & size
      final res2 = await bridgeService.processAndClassifyFile(
        factoryCode: 'F01',
        factoryId: f01.id,
        driveFileId: 'DRIVE_FILE_NULL_HASH_TEST',
        fileName: 'null_hash.xlsx',
        sizeBytes: 10000,
        modifiedTime: '2026-08-19T04:00:00.000Z',
        md5Checksum: 'newly_available_md5_hash',
      );
      expect(res2.file.syncStatus, equals('UNCHANGED'));
      expect(res2.event.isActionable, isFalse);
    });

    test('TEST 14: Two files scanned: File A unchanged -> UNCHANGED, File B modified -> MODIFIED', () async {
      final f01 = (await dbService.factories.getFactoryByCode('F01'))!;

      // Scan 1: Both files discovered as NEW
      final a1 = await bridgeService.processAndClassifyFile(
        factoryCode: 'F01',
        factoryId: f01.id,
        driveFileId: 'DRIVE_FILE_A',
        fileName: 'File_A.xlsx',
        sizeBytes: 20000,
        modifiedTime: '2026-08-19T01:00:00.000Z',
        md5Checksum: 'hash_a_1',
      );
      final b1 = await bridgeService.processAndClassifyFile(
        factoryCode: 'F01',
        factoryId: f01.id,
        driveFileId: 'DRIVE_FILE_B',
        fileName: 'File_B.xlsx',
        sizeBytes: 30000,
        modifiedTime: '2026-08-19T01:00:00.123456Z',
        md5Checksum: 'hash_b_1',
      );
      expect(a1.file.syncStatus, equals('NEW'));
      expect(b1.file.syncStatus, equals('NEW'));

      // Scan 2: Neither file modified -> BOTH UNCHANGED
      final a2 = await bridgeService.processAndClassifyFile(
        factoryCode: 'F01',
        factoryId: f01.id,
        driveFileId: 'DRIVE_FILE_A',
        fileName: 'File_A.xlsx',
        sizeBytes: 20000,
        modifiedTime: '2026-08-19T01:00:00.000Z',
        md5Checksum: 'hash_a_1',
      );
      final b2 = await bridgeService.processAndClassifyFile(
        factoryCode: 'F01',
        factoryId: f01.id,
        driveFileId: 'DRIVE_FILE_B',
        fileName: 'File_B.xlsx',
        sizeBytes: 30000,
        modifiedTime: '2026-08-19T01:00:00.123000Z',
        md5Checksum: 'hash_b_1',
      );
      expect(a2.file.syncStatus, equals('UNCHANGED'));
      expect(b2.file.syncStatus, equals('UNCHANGED'));

      // Scan 3: Modify ONLY File B in Google Drive
      final a3 = await bridgeService.processAndClassifyFile(
        factoryCode: 'F01',
        factoryId: f01.id,
        driveFileId: 'DRIVE_FILE_A',
        fileName: 'File_A.xlsx',
        sizeBytes: 20000,
        modifiedTime: '2026-08-19T01:00:00.000Z',
        md5Checksum: 'hash_a_1',
      );
      final b3 = await bridgeService.processAndClassifyFile(
        factoryCode: 'F01',
        factoryId: f01.id,
        driveFileId: 'DRIVE_FILE_B',
        fileName: 'File_B.xlsx',
        sizeBytes: 35000, // Size changed
        modifiedTime: '2026-08-19T03:30:00.000Z', // Time changed
        md5Checksum: 'hash_b_2', // MD5 changed
      );
      expect(a3.file.syncStatus, equals('UNCHANGED'));
      expect(b3.file.syncStatus, equals('MODIFIED'));

      // Scan 4: Scan again without modifications -> BOTH UNCHANGED
      final a4 = await bridgeService.processAndClassifyFile(
        factoryCode: 'F01',
        factoryId: f01.id,
        driveFileId: 'DRIVE_FILE_A',
        fileName: 'File_A.xlsx',
        sizeBytes: 20000,
        modifiedTime: '2026-08-19T01:00:00.000Z',
        md5Checksum: 'hash_a_1',
      );
      final b4 = await bridgeService.processAndClassifyFile(
        factoryCode: 'F01',
        factoryId: f01.id,
        driveFileId: 'DRIVE_FILE_B',
        fileName: 'File_B.xlsx',
        sizeBytes: 35000,
        modifiedTime: '2026-08-19T03:30:00.000Z',
        md5Checksum: 'hash_b_2',
      );
      expect(a4.file.syncStatus, equals('UNCHANGED'));
      expect(b4.file.syncStatus, equals('UNCHANGED'));
    });
  });
}

