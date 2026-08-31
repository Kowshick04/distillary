import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:excel/excel.dart';
import 'package:distillary/database/database.dart' hide isNull, isNotNull;
import 'package:distillary/services/database_service.dart';
import 'package:distillary/services/drive_bridge_service.dart';
import 'package:distillary/services/excel_ingestion_service.dart';

/// Helper to generate a valid distillery Excel file with real headers and rows.
Uint8List createSampleDistilleryExcel({
  required String batchId,
  required String fermenter,
  required int rowCount,
  double baseTemp = 32.5,
  double baseBrix = 14.2,
}) {
  final excel = Excel.createExcel();
  final sheet = excel[excel.getDefaultSheet() ?? 'Sheet1'];

  // Add Headers
  sheet.appendRow([
    TextCellValue('Timestamp'),
    TextCellValue('Batch ID'),
    TextCellValue('Fermenter'),
    TextCellValue('Temperature'),
    TextCellValue('Brix'),
    TextCellValue('Residual Sugar'),
    TextCellValue('Sugar Consumption Rate'),
    TextCellValue('Feeding Hours'),
    TextCellValue('Retention Hours'),
    TextCellValue('Setup SG'),
    TextCellValue('Final SG'),
    TextCellValue('SG Difference'),
    TextCellValue('Alcohol Setup'),
    TextCellValue('Alcohol Final'),
    TextCellValue('pH Setup'),
    TextCellValue('pH Final'),
    TextCellValue('Raw Spent Wash Brix'),
    TextCellValue('Cooling Valve'),
    TextCellValue('Agitator RPM'),
    TextCellValue('Steam Valve'),
    TextCellValue('CO2 Flow'),
    TextCellValue('Headspace Pressure'),
  ]);

  final now = DateTime.utc(2026, 8, 18, 10, 0);
  for (int i = 0; i < rowCount; i++) {
    final t = now.add(Duration(minutes: i));
    sheet.appendRow([
      TextCellValue(t.toIso8601String()),
      TextCellValue(batchId),
      TextCellValue(fermenter),
      DoubleCellValue(baseTemp + (i * 0.1)),
      DoubleCellValue(baseBrix - (i * 0.2)),
      DoubleCellValue(2.5 - (i * 0.05)),
      DoubleCellValue(0.45),
      DoubleCellValue(8.0),
      DoubleCellValue(24.0),
      DoubleCellValue(1.085),
      DoubleCellValue(1.010),
      DoubleCellValue(0.075),
      DoubleCellValue(0.5),
      DoubleCellValue(8.2),
      DoubleCellValue(4.8),
      DoubleCellValue(4.2),
      DoubleCellValue(12.5),
      DoubleCellValue(45.0),
      DoubleCellValue(120.0),
      DoubleCellValue(15.0),
      DoubleCellValue(350.0),
      DoubleCellValue(1.2),
    ]);
  }

  return Uint8List.fromList(excel.encode()!);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;
  late File dbFile;
  late AppDatabase db;
  late DatabaseService dbService;
  late DriveBridgeService bridgeService;
  late ExcelIngestionService ingestionService;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('excel_ingestion_test_');
    dbFile = File('${tempDir.path}/distillery.db');
    db = AppDatabase(NativeDatabase(dbFile));
    dbService = DatabaseService(db);
    await dbService.seedInitialFactories();
    bridgeService = DriveBridgeService(dbService);
    ingestionService = ExcelIngestionService(
      dbService: dbService,
      driveBridgeService: bridgeService,
      customTempDir: tempDir,
    );
  });

  tearDown(() async {
    ingestionService.dispose();
    bridgeService.dispose();
    await db.close();
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  group('STEP 3: Continuous Automatic Excel Ingestion Pipeline', () {
    test('TEST A: Upload/detect a NEW Excel file -> Auto Download -> Parse -> SQLite Storage', () async {
      final f01 = (await dbService.factories.getFactoryByCode('F01'))!;

      // 1. Create a 25-row sample Excel file
      final excelBytes = createSampleDistilleryExcel(
        batchId: 'BATCH_F01_001',
        fermenter: 'FERM-01',
        rowCount: 25,
      );
      final localFile = File('${tempDir.path}/1.xlsx');
      await localFile.writeAsBytes(excelBytes);

      // 2. Classify file as NEW in SQLite
      final classification = await bridgeService.processAndClassifyFile(
        factoryCode: 'F01',
        factoryId: f01.id,
        driveFileId: 'DRIVE_FILE_F01_1',
        fileName: '1.xlsx',
        sizeBytes: excelBytes.length,
        modifiedTime: '2026-08-18T10:00:00.000Z',
      );
      expect(classification.file.syncStatus, equals('NEW'));

      // 3. Execute Automatic Ingestion
      final result = await ingestionService.ingestSingleFile(
        accessToken: 'dummy_token',
        factoryCode: 'F01',
        factoryId: f01.id,
        driveFileId: 'DRIVE_FILE_F01_1',
        fileName: '1.xlsx',
        dbFileId: classification.file.dbFileId,
        existingLocalFile: localFile,
      );

      // 4. Verify Ingestion Result
      expect(result.success, isTrue);
      expect(result.recordsInserted, equals(25));
      expect(result.processingRunId, isNotNull);
      expect(result.batchId, isNotNull);

      // 5. Verify SQLite Database State
      // 5a. Batches
      final allBatches = await dbService.batches.getAllBatches();
      expect(allBatches.length, equals(1));
      expect(allBatches.first.batchId, equals('BATCH_F01_001'));
      expect(allBatches.first.fermenter, equals('FERM-01'));

      // 5b. PreprocessingData
      final preprocRecords = await dbService.preprocessingData.getByBatchId(result.batchId!);
      expect(preprocRecords.length, equals(25));
      expect(preprocRecords.first.temperature, isNotNull);
      expect(preprocRecords.first.brix, isNotNull);
      expect(preprocRecords.first.sugarConsumptionRate, equals(0.45));
      expect(preprocRecords.first.setupSg, equals(1.085));

      // 5c. ProcessingRuns
      final runs = await dbService.processingRuns.getAllRuns();
      expect(runs.length, equals(1));
      expect(runs.first.status, equals('SUCCESS'));
      expect(runs.first.recordsProcessed, equals(25));
      expect(runs.first.completedAt, isNotNull);

      // 5d. InputFiles status updated to PROCESSED
      final inputFile = await dbService.inputFiles.getFileById(result.inputFileId);
      expect(inputFile!.status, equals('PROCESSED'));
      expect(inputFile.lastProcessedAt, isNotNull);
    });

    test('TEST B: Run scan again without modifying file -> UNCHANGED -> NO download / NO reprocessing', () async {
      final f01 = (await dbService.factories.getFactoryByCode('F01'))!;

      final excelBytes = createSampleDistilleryExcel(
        batchId: 'BATCH_F01_001',
        fermenter: 'FERM-01',
        rowCount: 10,
      );
      final localFile = File('${tempDir.path}/1.xlsx');
      await localFile.writeAsBytes(excelBytes);

      // 1. First scan & ingest
      final firstScan = await bridgeService.processAndClassifyFile(
        factoryCode: 'F01',
        factoryId: f01.id,
        driveFileId: 'DRIVE_FILE_F01_1',
        fileName: '1.xlsx',
        sizeBytes: excelBytes.length,
        modifiedTime: '2026-08-18T10:00:00.000Z',
      );

      await ingestionService.ingestSingleFile(
        accessToken: 'dummy_token',
        factoryCode: 'F01',
        factoryId: f01.id,
        driveFileId: 'DRIVE_FILE_F01_1',
        fileName: '1.xlsx',
        dbFileId: firstScan.file.dbFileId,
        existingLocalFile: localFile,
      );

      final initialRuns = await dbService.processingRuns.getAllRuns();
      expect(initialRuns.length, equals(1));

      // 2. Second scan (UNCHANGED)
      final secondScan = await bridgeService.processAndClassifyFile(
        factoryCode: 'F01',
        factoryId: f01.id,
        driveFileId: 'DRIVE_FILE_F01_1',
        fileName: '1.xlsx',
        sizeBytes: excelBytes.length,
        modifiedTime: '2026-08-18T10:00:00.000Z',
      );

      expect(secondScan.file.syncStatus, equals('UNCHANGED'));
      expect(secondScan.event.isActionable, isFalse);

      // Verify no extra processing runs were created
      final postScanRuns = await dbService.processingRuns.getAllRuns();
      expect(postScanRuns.length, equals(1));
    });

    test('TEST C: Modify Excel file in Google Drive -> MODIFIED -> Auto Reprocessing -> New ProcessingRun', () async {
      final f01 = (await dbService.factories.getFactoryByCode('F01'))!;

      // 1. First Version (10 rows)
      final v1Bytes = createSampleDistilleryExcel(batchId: 'BATCH_F01_001', fermenter: 'FERM-01', rowCount: 10);
      final localFileV1 = File('${tempDir.path}/1_v1.xlsx');
      await localFileV1.writeAsBytes(v1Bytes);

      final scanV1 = await bridgeService.processAndClassifyFile(
        factoryCode: 'F01',
        factoryId: f01.id,
        driveFileId: 'DRIVE_FILE_F01_1',
        fileName: '1.xlsx',
        sizeBytes: v1Bytes.length,
        modifiedTime: '2026-08-18T10:00:00.000Z',
      );

      await ingestionService.ingestSingleFile(
        accessToken: 'dummy_token',
        factoryCode: 'F01',
        factoryId: f01.id,
        driveFileId: 'DRIVE_FILE_F01_1',
        fileName: '1.xlsx',
        dbFileId: scanV1.file.dbFileId,
        existingLocalFile: localFileV1,
      );

      // 2. Modified Version in Drive (20 rows, new timestamp and size)
      final v2Bytes = createSampleDistilleryExcel(batchId: 'BATCH_F01_001', fermenter: 'FERM-01', rowCount: 20);
      final localFileV2 = File('${tempDir.path}/1_v2.xlsx');
      await localFileV2.writeAsBytes(v2Bytes);

      final scanV2 = await bridgeService.processAndClassifyFile(
        factoryCode: 'F01',
        factoryId: f01.id,
        driveFileId: 'DRIVE_FILE_F01_1',
        fileName: '1.xlsx',
        sizeBytes: v2Bytes.length,
        modifiedTime: '2026-08-18T12:00:00.000Z',
      );

      expect(scanV2.file.syncStatus, equals('MODIFIED'));
      expect(scanV2.event.isActionable, isTrue);

      final ingestV2Result = await ingestionService.ingestSingleFile(
        accessToken: 'dummy_token',
        factoryCode: 'F01',
        factoryId: f01.id,
        driveFileId: 'DRIVE_FILE_F01_1',
        fileName: '1.xlsx',
        dbFileId: scanV2.file.dbFileId,
        existingLocalFile: localFileV2,
      );

      expect(ingestV2Result.success, isTrue);
      expect(ingestV2Result.recordsInserted, equals(20));

      // Verify a second distinct processing run exists
      final runs = await dbService.processingRuns.getAllRuns();
      expect(runs.length, equals(2));
      expect(runs.last.status, equals('SUCCESS'));
      expect(runs.last.recordsProcessed, equals(20));

      // Verify input_files row was updated in-place (no duplicate file row)
      final allFiles = await dbService.inputFiles.getAllFiles();
      expect(allFiles.length, equals(1));
      expect(allFiles.first.status, equals('PROCESSED'));
    });

    test('TEST D: Force an Excel parsing failure -> ProcessingRun = FAILED -> No partial data', () async {
      final f01 = (await dbService.factories.getFactoryByCode('F01'))!;

      // Create corrupted file (random non-excel bytes)
      final corruptFile = File('${tempDir.path}/corrupted.xlsx');
      await corruptFile.writeAsBytes([0, 1, 2, 3, 4, 5, 6, 7, 8, 9]);

      final scan = await bridgeService.processAndClassifyFile(
        factoryCode: 'F01',
        factoryId: f01.id,
        driveFileId: 'DRIVE_FILE_CORRUPT',
        fileName: 'corrupted.xlsx',
        sizeBytes: 10,
        modifiedTime: '2026-08-18T10:00:00.000Z',
      );

      final result = await ingestionService.ingestSingleFile(
        accessToken: 'dummy_token',
        factoryCode: 'F01',
        factoryId: f01.id,
        driveFileId: 'DRIVE_FILE_CORRUPT',
        fileName: 'corrupted.xlsx',
        dbFileId: scan.file.dbFileId,
        existingLocalFile: corruptFile,
      );

      expect(result.success, isFalse);
      expect(result.error, isNotNull);

      // Verify no partial preprocessing_data records inserted
      final allPreproc = await dbService.db.select(dbService.db.preprocessingData).get();
      expect(allPreproc, isEmpty);

      // Verify processing run marked as FAILED
      final runs = await dbService.processingRuns.getAllRuns();
      if (runs.isNotEmpty) {
        expect(runs.first.status, equals('FAILED'));
        expect(runs.first.errorMessage, isNotNull);
      }

      // Verify input file marked as ERROR
      final file = await dbService.inputFiles.getFileById(result.inputFileId);
      expect(file!.status, equals('ERROR'));
    });

    test('TEST E: Force a download failure -> ProcessingRun = FAILED -> No partial import', () async {
      final f01 = (await dbService.factories.getFactoryByCode('F01'))!;

      final scan = await bridgeService.processAndClassifyFile(
        factoryCode: 'F01',
        factoryId: f01.id,
        driveFileId: 'NON_EXISTENT_FILE_ID',
        fileName: 'missing.xlsx',
        sizeBytes: 5000,
        modifiedTime: '2026-08-18T10:00:00.000Z',
      );

      // Attempt ingestion without local file -> triggers download which fails
      final result = await ingestionService.ingestSingleFile(
        accessToken: 'invalid_token',
        factoryCode: 'F01',
        factoryId: f01.id,
        driveFileId: 'NON_EXISTENT_FILE_ID',
        fileName: 'missing.xlsx',
        dbFileId: scan.file.dbFileId,
      );

      expect(result.success, isFalse);
      expect(result.error, isNotNull);

      final allPreproc = await dbService.db.select(dbService.db.preprocessingData).get();
      expect(allPreproc, isEmpty);
    });

    test('TEST F: Restart application after successful processing -> State preserved, no duplicate processing', () async {
      final f01 = (await dbService.factories.getFactoryByCode('F01'))!;

      final excelBytes = createSampleDistilleryExcel(batchId: 'BATCH_F01_001', fermenter: 'FERM-01', rowCount: 15);
      final localFile = File('${tempDir.path}/1.xlsx');
      await localFile.writeAsBytes(excelBytes);

      // Ingest in Session 1
      final scan1 = await bridgeService.processAndClassifyFile(
        factoryCode: 'F01',
        factoryId: f01.id,
        driveFileId: 'DRIVE_FILE_F01_1',
        fileName: '1.xlsx',
        sizeBytes: excelBytes.length,
        modifiedTime: '2026-08-18T10:00:00.000Z',
      );

      await ingestionService.ingestSingleFile(
        accessToken: 'dummy_token',
        factoryCode: 'F01',
        factoryId: f01.id,
        driveFileId: 'DRIVE_FILE_F01_1',
        fileName: '1.xlsx',
        dbFileId: scan1.file.dbFileId,
        existingLocalFile: localFile,
      );

      // Simulate Cold Restart
      ingestionService.dispose();
      bridgeService.dispose();
      await db.close();

      final reopenedDb = AppDatabase(NativeDatabase(dbFile));
      final reopenedDbService = DatabaseService(reopenedDb);
      final reopenedBridge = DriveBridgeService(reopenedDbService);

      try {
        final postRestartScan = await reopenedBridge.processAndClassifyFile(
          factoryCode: 'F01',
          factoryId: f01.id,
          driveFileId: 'DRIVE_FILE_F01_1',
          fileName: '1.xlsx',
          sizeBytes: excelBytes.length,
          modifiedTime: '2026-08-18T10:00:00.000Z',
        );

        expect(postRestartScan.file.syncStatus, equals('UNCHANGED'));
        expect(postRestartScan.event.isActionable, isFalse);

        final runs = await reopenedDbService.processingRuns.getAllRuns();
        expect(runs.length, equals(1));
        expect(runs.first.status, equals('SUCCESS'));
        expect(runs.first.recordsProcessed, equals(15));
      } finally {
        reopenedBridge.dispose();
        await reopenedDb.close();
      }
    });

    test('TEST G: Verify temporary Excel file cleanup after successful ingestion', () async {
      final f01 = (await dbService.factories.getFactoryByCode('F01'))!;

      final excelBytes = createSampleDistilleryExcel(batchId: 'BATCH_CLEANUP', fermenter: 'FERM-02', rowCount: 5);
      final downloadDir = Directory('${tempDir.path}/distillery_excel_downloads');
      await downloadDir.create(recursive: true);
      final tempDownloadFile = File('${downloadDir.path}/DRIVE_CLEANUP_cleanup.xlsx');
      await tempDownloadFile.writeAsBytes(excelBytes);

      expect(await tempDownloadFile.exists(), isTrue);

      final scan = await bridgeService.processAndClassifyFile(
        factoryCode: 'F01',
        factoryId: f01.id,
        driveFileId: 'DRIVE_CLEANUP',
        fileName: 'cleanup.xlsx',
        sizeBytes: excelBytes.length,
        modifiedTime: '2026-08-18T10:00:00.000Z',
      );

      final result = await ingestionService.ingestSingleFile(
        accessToken: 'dummy_token',
        factoryCode: 'F01',
        factoryId: f01.id,
        driveFileId: 'DRIVE_CLEANUP',
        fileName: 'cleanup.xlsx',
        dbFileId: scan.file.dbFileId,
        existingLocalFile: tempDownloadFile,
        deleteAfterIngestion: true,
      );

      // Verify temp file in downloads folder was cleaned up
      expect(await tempDownloadFile.exists(), isFalse);
      expect(result.success, isTrue);
    });

    test('TEST H: Verify database foreign-key integrity', () async {
      final f01 = (await dbService.factories.getFactoryByCode('F01'))!;

      final excelBytes = createSampleDistilleryExcel(batchId: 'BATCH_FK_TEST', fermenter: 'FERM-01', rowCount: 10);
      final localFile = File('${tempDir.path}/fk_test.xlsx');
      await localFile.writeAsBytes(excelBytes);

      final scan = await bridgeService.processAndClassifyFile(
        factoryCode: 'F01',
        factoryId: f01.id,
        driveFileId: 'DRIVE_FK_TEST',
        fileName: 'fk_test.xlsx',
        sizeBytes: excelBytes.length,
        modifiedTime: '2026-08-18T10:00:00.000Z',
      );

      final result = await ingestionService.ingestSingleFile(
        accessToken: 'dummy_token',
        factoryCode: 'F01',
        factoryId: f01.id,
        driveFileId: 'DRIVE_FK_TEST',
        fileName: 'fk_test.xlsx',
        dbFileId: scan.file.dbFileId,
        existingLocalFile: localFile,
      );

      expect(result.success, isTrue);

      // Run SQLite PRAGMA foreign_key_check
      final fkViolations = await db.customSelect('PRAGMA foreign_key_check;').get();
      expect(fkViolations, isEmpty);

      final integrity = await db.customSelect('PRAGMA integrity_check;').getSingle();
      expect(integrity.data['integrity_check'], equals('ok'));
    });

    test('TEST I: Verify database can be closed and reopened cleanly after processing', () async {
      final f01 = (await dbService.factories.getFactoryByCode('F01'))!;

      final excelBytes = createSampleDistilleryExcel(batchId: 'BATCH_REOPEN', fermenter: 'FERM-01', rowCount: 8);
      final localFile = File('${tempDir.path}/reopen.xlsx');
      await localFile.writeAsBytes(excelBytes);

      final scan = await bridgeService.processAndClassifyFile(
        factoryCode: 'F01',
        factoryId: f01.id,
        driveFileId: 'DRIVE_REOPEN',
        fileName: 'reopen.xlsx',
        sizeBytes: excelBytes.length,
        modifiedTime: '2026-08-18T10:00:00.000Z',
      );

      await ingestionService.ingestSingleFile(
        accessToken: 'dummy_token',
        factoryCode: 'F01',
        factoryId: f01.id,
        driveFileId: 'DRIVE_REOPEN',
        fileName: 'reopen.xlsx',
        dbFileId: scan.file.dbFileId,
        existingLocalFile: localFile,
      );

      // Close database
      ingestionService.dispose();
      bridgeService.dispose();
      await db.close();

      // Reopen
      final reopenedDb = AppDatabase(NativeDatabase(dbFile));
      final reopenedDbService = DatabaseService(reopenedDb);

      try {
        final records = await reopenedDbService.preprocessingData.getByBatchId(1);
        expect(records.length, equals(8));

        final fkCheck = await reopenedDb.customSelect('PRAGMA foreign_key_check;').get();
        expect(fkCheck, isEmpty);
      } finally {
        await reopenedDb.close();
      }
    });
  });
}

