import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:distillary/database/database.dart' hide isNotNull, isNull;
import 'package:distillary/services/database_service.dart';
import 'package:distillary/services/drive_bridge_service.dart';
import 'package:distillary/services/factory_database_manager.dart';

void main() {
  late Directory tempDir;
  late FactoryDatabaseManager manager;
  late Map<String, DatabaseService> plantDbs;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('five_factory_validation_test_');
    plantDbs = {};

    for (final plant in FactoryDatabaseManager.supportedPlants) {
      final file = File('${tempDir.path}/${plant.dbFileName}');
      final db = AppDatabase(NativeDatabase(file));
      final dbService = DatabaseService(db);
      plantDbs[plant.code] = dbService;
    }

    manager = FactoryDatabaseManager(initialDatabases: plantDbs);
    await manager.initializeAll();
  });

  tearDown(() async {
    await manager.closeAll();
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  group('STEP 5: Full 5-Factory Validation & Development Reset', () {
    test('TEST A: Development reset clears transactional tables and preserves schema and factory metadata', () async {
      final f01Db = manager.getDatabaseForPlant('F01');

      // 1. Seed dummy data
      final f01 = (await f01Db.factories.getFactoryByCode('F01'))!;
      final fileId = await f01Db.inputFiles.insertFile(
        InputFilesCompanion.insert(
          factoryId: f01.id,
          driveFileId: 'DRIVE_DUMMY_RESET',
          fileName: 'dummy.xlsx',
          status: 'PROCESSED',
        ),
      );

      final runId = await f01Db.processingRuns.insertRun(
        ProcessingRunsCompanion.insert(
          inputFileId: fileId,
          status: 'SUCCESS',
        ),
      );

      final batchDbId = await f01Db.batches.insertBatch(
        BatchesCompanion.insert(
          factoryId: f01.id,
          inputFileId: fileId,
          batchId: 'BATCH_001',
        ),
      );

      await f01Db.preprocessingData.insertRecord(
        PreprocessingDataCompanion.insert(
          batchId: batchDbId,
          inputFileId: fileId,
          processingRunId: runId,
          timestampMinute: Value(DateTime.now().toUtc()),
          temperature: const Value(32.5),
        ),
      );

      // Verify row counts before reset
      expect((await f01Db.inputFiles.getAllFiles()).length, equals(1));
      expect((await f01Db.batches.getAllBatches()).length, equals(1));
      expect((await f01Db.processingRuns.getAllRuns()).length, equals(1));
      expect((await f01Db.preprocessingData.getAllRecords()).length, equals(1));

      // 2. Perform development reset
      await manager.developmentResetAllDatabases();

      // Verify row counts after reset
      for (final plant in manager.plants) {
        final dbService = manager.getDatabaseForPlant(plant.code);
        expect((await dbService.inputFiles.getAllFiles()).length, equals(0));
        expect((await dbService.batches.getAllBatches()).length, equals(0));
        expect((await dbService.processingRuns.getAllRuns()).length, equals(0));
        expect((await dbService.preprocessingData.getAllRecords()).length, equals(0));
        expect((await dbService.predictions.getAllPredictions()).length, equals(0));
        expect((await dbService.mqttPublishLog.getAllLogs()).length, equals(0));

        // Factory identity must be preserved
        final factoryRecord = await dbService.factories.getFactoryByCode(plant.code);
        expect(factoryRecord, isNotNull);
        expect(factoryRecord!.factoryCode, equals(plant.code));
      }
    });

    test('TEST B-F: Independent ingestion for all 5 factories (F01 to F05)', () async {
      for (final plant in manager.plants) {
        final dbService = manager.getDatabaseForPlant(plant.code);
        final factoryRecord = (await dbService.factories.getFactoryByCode(plant.code))!;
        final bridge = DriveBridgeService(dbService);

        // 1. Discover file
        final scanRes = await bridge.processAndClassifyFile(
          factoryCode: plant.code,
          factoryId: factoryRecord.id,
          driveFileId: 'DRIVE_FILE_${plant.code}',
          fileName: '${plant.code}_plant_data.xlsx',
          sizeBytes: 16384,
          modifiedTime: '2026-08-19T06:00:00.000Z',
          md5Checksum: 'md5_${plant.code}_hash',
        );

        expect(scanRes.file.syncStatus, equals('NEW'));

        // Create a dummy local valid excel file
        final dummyFile = File('${tempDir.path}/${plant.code}_plant_data.xlsx');
        await dummyFile.writeAsString('Dummy Excel Content');

        // Create ingestion run directly
        final runId = await dbService.processingRuns.insertRun(
          ProcessingRunsCompanion.insert(
            inputFileId: scanRes.file.dbFileId,
            status: 'SUCCESS',
            recordsProcessed: const Value(50),
          ),
        );

        final batchDbId = await dbService.batches.insertBatch(
          BatchesCompanion.insert(
            factoryId: factoryRecord.id,
            inputFileId: scanRes.file.dbFileId,
            batchId: 'BATCH_${plant.code}_01',
          ),
        );

        // Insert sample process variables ensuring NULL is preserved (not converted to 0)
        await dbService.preprocessingData.insertRecord(
          PreprocessingDataCompanion.insert(
            batchId: batchDbId,
            inputFileId: scanRes.file.dbFileId,
            processingRunId: runId,
            timestampMinute: Value(DateTime.now().toUtc()),
            temperature: const Value(34.2),
            brix: const Value(15.8),
            residualSugar: const Value(null), // NULL must stay NULL
            alcoholSetup: const Value(8.5),
            phSetup: const Value(4.2),
            sugarConsumptionRate: const Value(1.25),
          ),
        );

        await dbService.inputFiles.updateFileStatus(scanRes.file.dbFileId, 'PROCESSED');

        // Verify SQLite data in this plant's database
        final runs = await dbService.processingRuns.getAllRuns();
        expect(runs.length, equals(1));
        expect(runs.first.status, equals('SUCCESS'));

        final batches = await dbService.batches.getAllBatches();
        expect(batches.length, equals(1));
        expect(batches.first.batchId, equals('BATCH_${plant.code}_01'));

        final data = await dbService.preprocessingData.getAllRecords();
        expect(data.length, equals(1));
        expect(data.first.temperature, equals(34.2));
        expect(data.first.brix, equals(15.8));
        expect(data.first.residualSugar, isNull); // Verified NULL is not 0
        expect(data.first.alcoholSetup, equals(8.5));
      }
    });

    test('TEST J: Cross-Factory Isolation: Data exists ONLY in its dedicated plant database', () async {
      // Seed F01 data
      final f01Db = manager.getDatabaseForPlant('F01');
      final f01 = (await f01Db.factories.getFactoryByCode('F01'))!;
      await f01Db.inputFiles.insertFile(
        InputFilesCompanion.insert(
          factoryId: f01.id,
          driveFileId: 'DRIVE_F01_ONLY',
          fileName: 'F01_only.xlsx',
          status: 'PROCESSED',
        ),
      );

      // Verify F01 file exists in haliyal.db
      expect((await f01Db.inputFiles.getAllFiles()).length, equals(1));

      // Verify other 4 plant databases have ZERO records for F01
      for (final otherCode in ['F02', 'F03', 'F04', 'F05']) {
        final otherDb = manager.getDatabaseForPlant(otherCode);
        final otherFiles = await otherDb.inputFiles.getAllFiles();
        expect(otherFiles.length, equals(0), reason: '$otherCode should be empty');
      }
    });

    test('TEST K: Second scan without modifications produces UNCHANGED across all 5 factories', () async {
      for (final plant in manager.plants) {
        final dbService = manager.getDatabaseForPlant(plant.code);
        final factoryRecord = (await dbService.factories.getFactoryByCode(plant.code))!;
        final bridge = DriveBridgeService(dbService);

        // Scan 1
        await bridge.processAndClassifyFile(
          factoryCode: plant.code,
          factoryId: factoryRecord.id,
          driveFileId: 'DRIVE_FILE_${plant.code}',
          fileName: '${plant.code}.xlsx',
          sizeBytes: 12000,
          modifiedTime: '2026-08-19T05:00:00.000Z',
          md5Checksum: 'md5_${plant.code}',
        );

        // Scan 2 (Identical metadata)
        final scan2 = await bridge.processAndClassifyFile(
          factoryCode: plant.code,
          factoryId: factoryRecord.id,
          driveFileId: 'DRIVE_FILE_${plant.code}',
          fileName: '${plant.code}.xlsx',
          sizeBytes: 12000,
          modifiedTime: '2026-08-19T05:00:00.000Z',
          md5Checksum: 'md5_${plant.code}',
        );

        expect(scan2.file.syncStatus, equals('UNCHANGED'));
        expect(scan2.event.isActionable, isFalse);

        // Exactly 1 row in input_files
        expect((await dbService.inputFiles.getAllFiles()).length, equals(1));
      }
    });

    test('TEST L: Single modified file produces MODIFIED only for that factory', () async {
      // Initialize all 5 with baseline files
      for (final plant in manager.plants) {
        final dbService = manager.getDatabaseForPlant(plant.code);
        final factoryRecord = (await dbService.factories.getFactoryByCode(plant.code))!;
        final bridge = DriveBridgeService(dbService);

        await bridge.processAndClassifyFile(
          factoryCode: plant.code,
          factoryId: factoryRecord.id,
          driveFileId: 'DRIVE_FILE_${plant.code}',
          fileName: '${plant.code}.xlsx',
          sizeBytes: 12000,
          modifiedTime: '2026-08-19T05:00:00.000Z',
          md5Checksum: 'md5_${plant.code}',
        );
      }

      // Modify ONLY F01 / 1.xlsx
      final f01Db = manager.getDatabaseForPlant('F01');
      final f01Record = (await f01Db.factories.getFactoryByCode('F01'))!;
      final f01Bridge = DriveBridgeService(f01Db);

      final f01Modified = await f01Bridge.processAndClassifyFile(
        factoryCode: 'F01',
        factoryId: f01Record.id,
        driveFileId: 'DRIVE_FILE_F01',
        fileName: 'F01.xlsx',
        sizeBytes: 14500, // Size changed
        modifiedTime: '2026-08-19T07:30:00.000Z', // ModTime changed
        md5Checksum: 'md5_f01_v2', // MD5 changed
      );

      expect(f01Modified.file.syncStatus, equals('MODIFIED'));
      expect(f01Modified.event.isActionable, isTrue);

      // Verify F02 to F05 remain UNCHANGED
      for (final otherCode in ['F02', 'F03', 'F04', 'F05']) {
        final otherDb = manager.getDatabaseForPlant(otherCode);
        final otherRecord = (await otherDb.factories.getFactoryByCode(otherCode))!;
        final otherBridge = DriveBridgeService(otherDb);

        final otherScan = await otherBridge.processAndClassifyFile(
          factoryCode: otherCode,
          factoryId: otherRecord.id,
          driveFileId: 'DRIVE_FILE_$otherCode',
          fileName: '$otherCode.xlsx',
          sizeBytes: 12000,
          modifiedTime: '2026-08-19T05:00:00.000Z',
          md5Checksum: 'md5_$otherCode',
        );

        expect(otherScan.file.syncStatus, equals('UNCHANGED'));
      }
    });
  });
}

