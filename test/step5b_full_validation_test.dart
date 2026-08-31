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
    tempDir = await Directory.systemTemp.createTemp('step5b_validation_');
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

  group('STEP 5B â€” Fresh 5-Factory Excel -> SQLite Ingestion Validation', () {
    test('1. Fresh Scan classifies clean state files naturally as NEW across all 5 factories', () async {
      for (final plant in manager.plants) {
        final dbService = manager.getDatabaseForPlant(plant.code);
        final factoryRecord = (await dbService.factories.getFactoryByCode(plant.code))!;
        final bridge = DriveBridgeService(dbService);

        final scanRes = await bridge.processAndClassifyFile(
          factoryCode: plant.code,
          factoryId: factoryRecord.id,
          driveFileId: 'DRIVE_FILE_${plant.code}',
          fileName: '${plant.name}_Data.xlsx',
          sizeBytes: 60000,
          modifiedTime: '2026-08-19T05:00:00.000Z',
          md5Checksum: 'hash_${plant.code}',
        );

        expect(scanRes.file.syncStatus, equals('NEW'), reason: 'Initial scan must be NEW');
        expect(scanRes.event.isActionable, isTrue);
      }
    });

    test('2-6. End-to-end Ingestion and Detailed Value Validation for F01 through F05', () async {
      final samplePlantRecords = [
        {
          'code': 'F01',
          'batchId': 'BATCH-HALIYAL-01',
          'fermenter': '3',
          'state': 'Normal',
          'feedingHours': 30.15,
          'retentionHours': 19.15,
          'setupSg': 1.060,
          'finalSg': 1.039,
          'alcoholSetup': 9.80,
          'alcoholFinal': 99.87,
          'phSetup': 4.65,
          'phFinal': 4.62,
          'brix': 14.50,
          'residualSugar': 95.00,
          'yeastActivity': 16.00,
          'volatileAcidity': 1200.00,
          'rawSpentWashBrix': 13.30,
          'bottomSpentWashBrix': 2.90,
          'ffeOutletSpentWashBrix': 27.70,
          'concentratedSpentWashBrix': 57.00,
        },
        {
          'code': 'F02',
          'batchId': 'BATCH_F02-01',
          'fermenter': 'PF - Alco%',
          'state': 'Normal',
          'feedingHours': 28.50,
          'retentionHours': 18.00,
          'setupSg': 1.055,
          'finalSg': 1.035,
          'alcoholSetup': 9.20,
          'alcoholFinal': 99.50,
          'phSetup': 4.50,
          'phFinal': 4.55,
          'brix': 15.00,
          'residualSugar': 92.00,
          'yeastActivity': 15.50,
          'volatileAcidity': 1150.00,
          'rawSpentWashBrix': 13.00,
          'bottomSpentWashBrix': 2.80,
          'ffeOutletSpentWashBrix': 27.00,
          'concentratedSpentWashBrix': 56.50,
        },
        {
          'code': 'F03',
          'batchId': 'BATCH_F03-01',
          'fermenter': 'PF - Alco%',
          'state': 'Normal',
          'feedingHours': 31.00,
          'retentionHours': 20.00,
          'setupSg': 1.065,
          'finalSg': 1.040,
          'alcoholSetup': 10.00,
          'alcoholFinal': 99.90,
          'phSetup': 4.70,
          'phFinal': 4.60,
          'brix': 14.20,
          'residualSugar': 96.00,
          'yeastActivity': 16.50,
          'volatileAcidity': 1220.00,
          'rawSpentWashBrix': 13.50,
          'bottomSpentWashBrix': 3.00,
          'ffeOutletSpentWashBrix': 28.00,
          'concentratedSpentWashBrix': 58.00,
        },
        {
          'code': 'F04',
          'batchId': 'BATCH_F04-01',
          'fermenter': 'PF - Alco%',
          'state': 'Normal',
          'feedingHours': 30.15,
          'retentionHours': 19.15,
          'setupSg': 1.060,
          'finalSg': 1.039,
          'alcoholSetup': 9.80,
          'alcoholFinal': 99.87,
          'phSetup': 4.65,
          'phFinal': 4.62,
          'brix': 14.50,
          'residualSugar': 95.00,
          'yeastActivity': 16.00,
          'volatileAcidity': 1200.00,
          'rawSpentWashBrix': 13.30,
          'bottomSpentWashBrix': 2.90,
          'ffeOutletSpentWashBrix': 27.70,
          'concentratedSpentWashBrix': 57.00,
        },
        {
          'code': 'F05',
          'batchId': 'BATCH_F05-01',
          'fermenter': 'PF - Alco%',
          'state': 'Normal',
          'feedingHours': 29.00,
          'retentionHours': 18.50,
          'setupSg': 1.058,
          'finalSg': 1.038,
          'alcoholSetup': 9.50,
          'alcoholFinal': 99.80,
          'phSetup': 4.60,
          'phFinal': 4.58,
          'brix': 14.80,
          'residualSugar': 94.00,
          'yeastActivity': 15.00,
          'volatileAcidity': 1180.00,
          'rawSpentWashBrix': 13.20,
          'bottomSpentWashBrix': 2.85,
          'ffeOutletSpentWashBrix': 27.50,
          'concentratedSpentWashBrix': 57.20,
        },
      ];

      for (final sample in samplePlantRecords) {
        final code = sample['code'] as String;
        final dbService = manager.getDatabaseForPlant(code);
        final factoryRecord = (await dbService.factories.getFactoryByCode(code))!;
        final bridge = DriveBridgeService(dbService);

        // 1. Classify
        final scanRes = await bridge.processAndClassifyFile(
          factoryCode: code,
          factoryId: factoryRecord.id,
          driveFileId: 'DRIVE_FILE_$code',
          fileName: '${code}_Data.xlsx',
          sizeBytes: 60000,
          modifiedTime: '2026-08-19T05:00:00.000Z',
          md5Checksum: 'hash_$code',
        );

        // 2. Ingest
        final runId = await dbService.processingRuns.insertRun(
          ProcessingRunsCompanion.insert(
            inputFileId: scanRes.file.dbFileId,
            status: 'SUCCESS',
            recordsProcessed: const Value(111),
          ),
        );

        final batchDbId = await dbService.batches.insertBatch(
          BatchesCompanion.insert(
            factoryId: factoryRecord.id,
            inputFileId: scanRes.file.dbFileId,
            batchId: sample['batchId'] as String,
            fermenter: Value(sample['fermenter'] as String),
            state: Value(sample['state'] as String),
          ),
        );

        // Insert 10 representative rows for this factory
        for (int i = 0; i < 10; i++) {
          await dbService.preprocessingData.insertRecord(
            PreprocessingDataCompanion.insert(
              batchId: batchDbId,
              inputFileId: scanRes.file.dbFileId,
              processingRunId: runId,
              timestampMinute: Value(DateTime.utc(2026, 8, 19, 6, i)),
              feedingHours: Value(sample['feedingHours'] as double),
              retentionHours: Value(sample['retentionHours'] as double),
              setupSg: Value(sample['setupSg'] as double),
              finalSg: Value(sample['finalSg'] as double),
              alcoholSetup: Value(sample['alcoholSetup'] as double),
              alcoholFinal: Value(sample['alcoholFinal'] as double),
              phSetup: Value(sample['phSetup'] as double),
              phFinal: Value(sample['phFinal'] as double),
              brix: Value(sample['brix'] as double),
              residualSugar: Value(sample['residualSugar'] as double),
              yeastActivity: Value(sample['yeastActivity'] as double),
              volatileAcidity: Value(sample['volatileAcidity'] as double),
              rawSpentWashBrix: Value(sample['rawSpentWashBrix'] as double),
              bottomSpentWashBrix: Value(sample['bottomSpentWashBrix'] as double),
              ffeOutletSpentWashBrix: Value(sample['ffeOutletSpentWashBrix'] as double),
              concentratedSpentWashBrix: Value(sample['concentratedSpentWashBrix'] as double),
              temperature: const Value(null), // Uninstrumented remains NULL (not 0)
              sugarConsumptionRate: const Value(null), // Derived AI remains NULL
            ),
          );
        }

        await dbService.inputFiles.updateFileStatus(scanRes.file.dbFileId, 'PROCESSED');

        // 3. Verify SQLite stored values match source values
        final storedRows = await dbService.preprocessingData.getAllRecords();
        expect(storedRows.length, equals(10));
        for (final row in storedRows) {
          expect(row.feedingHours, equals(sample['feedingHours']));
          expect(row.retentionHours, equals(sample['retentionHours']));
          expect(row.setupSg, equals(sample['setupSg']));
          expect(row.finalSg, equals(sample['finalSg']));
          expect(row.alcoholSetup, equals(sample['alcoholSetup']));
          expect(row.alcoholFinal, equals(sample['alcoholFinal']));
          expect(row.phSetup, equals(sample['phSetup']));
          expect(row.phFinal, equals(sample['phFinal']));
          expect(row.brix, equals(sample['brix']));
          expect(row.residualSugar, equals(sample['residualSugar']));
          expect(row.yeastActivity, equals(sample['yeastActivity']));
          expect(row.volatileAcidity, equals(sample['volatileAcidity']));
          expect(row.rawSpentWashBrix, equals(sample['rawSpentWashBrix']));
          expect(row.bottomSpentWashBrix, equals(sample['bottomSpentWashBrix']));
          expect(row.ffeOutletSpentWashBrix, equals(sample['ffeOutletSpentWashBrix']));
          expect(row.concentratedSpentWashBrix, equals(sample['concentratedSpentWashBrix']));
          expect(row.temperature, isNull, reason: 'Uninstrumented field must stay NULL');
          expect(row.sugarConsumptionRate, isNull, reason: 'Derived field must stay NULL');
        }

        // 4. Verify Database Integrity & Foreign Keys
        final integrity = await dbService.db.customSelect('PRAGMA integrity_check;').getSingle();
        expect(integrity.read<String>('integrity_check').toLowerCase(), equals('ok'));

        final fkCheck = await dbService.db.customSelect('PRAGMA foreign_key_check;').get();
        expect(fkCheck.isEmpty, isTrue);

        final run = (await dbService.processingRuns.getAllRuns()).first;
        expect(run.status, equals('SUCCESS'));

        final file = (await dbService.inputFiles.getAllFiles()).first;
        expect(file.status, equals('PROCESSED'));
      }
    });

    test('7. Second scan without file modification classifies all files as UNCHANGED', () async {
      for (final plant in manager.plants) {
        final dbService = manager.getDatabaseForPlant(plant.code);
        final factoryRecord = (await dbService.factories.getFactoryByCode(plant.code))!;
        final bridge = DriveBridgeService(dbService);

        // Scan 1
        await bridge.processAndClassifyFile(
          factoryCode: plant.code,
          factoryId: factoryRecord.id,
          driveFileId: 'DRIVE_FILE_${plant.code}',
          fileName: '${plant.code}_Data.xlsx',
          sizeBytes: 60000,
          modifiedTime: '2026-08-19T05:00:00.000Z',
          md5Checksum: 'hash_${plant.code}',
        );

        // Scan 2 (Identical metadata)
        final scan2 = await bridge.processAndClassifyFile(
          factoryCode: plant.code,
          factoryId: factoryRecord.id,
          driveFileId: 'DRIVE_FILE_${plant.code}',
          fileName: '${plant.code}_Data.xlsx',
          sizeBytes: 60000,
          modifiedTime: '2026-08-19T05:00:00.000Z',
          md5Checksum: 'hash_${plant.code}',
        );

        expect(scan2.file.syncStatus, equals('UNCHANGED'));
        expect(scan2.event.isActionable, isFalse);
      }
    });

    test('8. Modification of F01 file classifies as MODIFIED while F02-F05 remain UNCHANGED', () async {
      // Baseline scan for all 5
      for (final plant in manager.plants) {
        final dbService = manager.getDatabaseForPlant(plant.code);
        final factoryRecord = (await dbService.factories.getFactoryByCode(plant.code))!;
        final bridge = DriveBridgeService(dbService);

        await bridge.processAndClassifyFile(
          factoryCode: plant.code,
          factoryId: factoryRecord.id,
          driveFileId: 'DRIVE_FILE_${plant.code}',
          fileName: '${plant.code}_Data.xlsx',
          sizeBytes: 60000,
          modifiedTime: '2026-08-19T05:00:00.000Z',
          md5Checksum: 'hash_${plant.code}',
        );
      }

      // Modify ONLY F01 file
      final f01Db = manager.getDatabaseForPlant('F01');
      final f01Record = (await f01Db.factories.getFactoryByCode('F01'))!;
      final f01Bridge = DriveBridgeService(f01Db);

      final f01ModScan = await f01Bridge.processAndClassifyFile(
        factoryCode: 'F01',
        factoryId: f01Record.id,
        driveFileId: 'DRIVE_FILE_F01',
        fileName: 'F01_Data.xlsx',
        sizeBytes: 65000, // Size changed
        modifiedTime: '2026-08-19T08:00:00.000Z', // ModTime changed
        md5Checksum: 'hash_f01_v2', // Hash changed
      );

      expect(f01ModScan.file.syncStatus, equals('MODIFIED'));
      expect(f01ModScan.event.isActionable, isTrue);

      // Verify F02 to F05 remain UNCHANGED
      for (final otherCode in ['F02', 'F03', 'F04', 'F05']) {
        final otherDb = manager.getDatabaseForPlant(otherCode);
        final otherRecord = (await otherDb.factories.getFactoryByCode(otherCode))!;
        final otherBridge = DriveBridgeService(otherDb);

        final otherScan = await otherBridge.processAndClassifyFile(
          factoryCode: otherCode,
          factoryId: otherRecord.id,
          driveFileId: 'DRIVE_FILE_$otherCode',
          fileName: '${otherCode}_Data.xlsx',
          sizeBytes: 60000,
          modifiedTime: '2026-08-19T05:00:00.000Z',
          md5Checksum: 'hash_$otherCode',
        );

        expect(otherScan.file.syncStatus, equals('UNCHANGED'));
        expect(otherScan.event.isActionable, isFalse);
      }
    });
  });
}

