// ignore_for_file: avoid_print

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:distillary/database/database.dart' hide isNotNull;
import 'package:distillary/services/database_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;
  late DatabaseService service;

  setUp(() async {
    // Open in-memory SQLite database with foreign keys enabled
    db = AppDatabase(NativeDatabase.memory(
      setup: (rawDb) {
        rawDb.execute('PRAGMA foreign_keys = ON;');
      },
    ));
    service = DatabaseService(db);
  });

  tearDown(() async {
    await db.close();
  });

  test('Database Smoke Test: 16-Step Verification of Schema, CRUD, FKs, and Constraints', () async {
    // -------------------------------------------------------------------------
    // STEP 1 & 2: Start/open Drift database & confirm SQLite connection
    // -------------------------------------------------------------------------
    final ping = await db.customSelect('SELECT 1 AS ping').getSingle();
    expect(ping.data['ping'], equals(1));
    print('[Step 1 & 2 PASSED] Database opened and SQLite connection confirmed.');

    // -------------------------------------------------------------------------
    // STEP 3: Insert test factory
    // -------------------------------------------------------------------------
    final factoryId = await service.factories.insertFactory(
      FactoriesCompanion.insert(
        factoryCode: 'TEST_F01',
        factoryName: 'Test Distillery Facility 01',
        driveFolderId: 'folder_drive_test_123',
        isActive: const Value(true),
      ),
    );
    expect(factoryId, greaterThan(0));
    print('[Step 3 PASSED] Test factory inserted with ID: $factoryId');

    // -------------------------------------------------------------------------
    // STEP 4: Insert test input file
    // -------------------------------------------------------------------------
    final now = DateTime.now().toUtc();
    final inputFileId = await service.inputFiles.insertFile(
      InputFilesCompanion.insert(
        factoryId: factoryId,
        driveFileId: 'drive_file_test_abc123',
        fileName: 'Batch_Fermentation_2026_08_17.xlsx',
        fileType: const Value('xlsx'),
        fileSizeBytes: Value(BigInt.from(1048576)), // 1MB
        driveModifiedAt: Value(now),
        fileHash: const Value('sha256_dummy_hash_for_testing_12345'),
        status: 'NEW',
        firstSeenAt: Value(now),
        lastSeenAt: Value(now),
      ),
    );
    expect(inputFileId, greaterThan(0));
    print('[Step 4 PASSED] Test input file inserted with ID: $inputFileId');

    // -------------------------------------------------------------------------
    // STEP 5: Insert test batch
    // -------------------------------------------------------------------------
    final batchPk = await service.batches.insertBatch(
      BatchesCompanion.insert(
        factoryId: factoryId,
        inputFileId: inputFileId,
        batchId: 'BATCH_20260817_F01_B1',
        fermenter: const Value('FERMENTER_TANK_03'),
        state: const Value('FERMENTING'),
        batchStartTime: Value(now.subtract(const Duration(hours: 12))),
        batchEndTime: Value(now.add(const Duration(hours: 36))),
      ),
    );
    expect(batchPk, greaterThan(0));
    print('[Step 5 PASSED] Test batch inserted with ID: $batchPk');

    // -------------------------------------------------------------------------
    // STEP 6: Insert test AI model
    // -------------------------------------------------------------------------
    final modelId = await service.aiModels.insertModel(
      AiModelsCompanion.insert(
        modelName: 'Fermentation Golden Batch Predictor',
        modelVersion: 'v1.2.0',
        modelType: 'Classification & Regression Ensemble',
        modelPath: const Value('models/xgb_fermentation_v1.2.onnx'),
        trainedAt: Value(now.subtract(const Duration(days: 7))),
        isActive: const Value(true),
      ),
    );
    expect(modelId, greaterThan(0));
    print('[Step 6 PASSED] Test AI model inserted with ID: $modelId');

    // -------------------------------------------------------------------------
    // STEP 7: Insert test processing run
    // -------------------------------------------------------------------------
    final runId = await service.processingRuns.insertRun(
      ProcessingRunsCompanion.insert(
        inputFileId: inputFileId,
        batchId: Value(batchPk),
        status: 'RUNNING',
        pipelineVersion: const Value('pipeline-v2.1.0'),
        modelId: Value(modelId),
        recordsProcessed: const Value(1440), // 1440 minute records
      ),
    );
    expect(runId, greaterThan(0));
    print('[Step 7 PASSED] Test processing run inserted with ID: $runId');

    // -------------------------------------------------------------------------
    // STEP 8: Insert test preprocessing record
    // -------------------------------------------------------------------------
    final prepId = await service.preprocessingData.insertRecord(
      PreprocessingDataCompanion.insert(
        batchId: batchPk,
        inputFileId: inputFileId,
        processingRunId: runId,
        timestampMinute: Value(now),
        serverTimestamp: Value(now),
        // Core features
        sugarConsumptionRate: const Value(0.85),
        feedingHours: const Value(14.5),
        retentionHours: const Value(48.0),
        setupSg: const Value(1.085),
        finalSg: const Value(0.998),
        sgDifference: const Value(0.087),
        alcoholSetup: const Value(0.5),
        alcoholFinal: const Value(8.9),
        phSetup: const Value(5.2),
        phFinal: const Value(4.1),
        rawSpentWashBrix: const Value(12.5),
        bottomSpentWashBrix: const Value(10.2),
        ffeOutletSpentWashBrix: const Value(18.4),
        concentratedSpentWashBrix: const Value(24.0),
        // Context features
        temperature: const Value(32.4),
        brix: const Value(16.8),
        residualSugar: const Value(2.1),
        yeastActivity: const Value(94.2),
        volatileAcidity: const Value(0.35),
        coolingValve: const Value(45.0),
        agitatorRpm: const Value(120.0),
        steamValve: const Value(0.0),
        tankLevelPercent: const Value(88.5),
        tankWeightKg: const Value(25400.0),
        co2FlowKgph: const Value(125.4),
        headspacePressureBar: const Value(0.15),
      ),
    );
    expect(prepId, greaterThan(0));
    print('[Step 8 PASSED] Test preprocessing data record inserted with ID: $prepId');

    // -------------------------------------------------------------------------
    // STEP 9: Insert test prediction
    // -------------------------------------------------------------------------
    final predictionId = await service.predictions.insertPrediction(
      PredictionsCompanion.insert(
        batchId: batchPk,
        processingRunId: runId,
        modelId: modelId,
        predictionLabel: 'GOLDEN_BATCH',
        predictionConfidence: const Value(0.975),
        predictedProduction: const Value(22500.0),
        actualProduction: const Value(22450.0),
        predictedFermenterEfficiency: const Value(96.8),
        actualFermenterEfficiency: const Value(96.5),
        predictedEthanolPercentage: const Value(9.1),
        actualEthanolPercentage: const Value(9.05),
        fermenterVesselQcAlert: const Value(false),
      ),
    );
    expect(predictionId, greaterThan(0));
    print('[Step 9 PASSED] Test prediction record inserted with ID: $predictionId');

    // -------------------------------------------------------------------------
    // STEP 10: Insert test MQTT publish log record
    // -------------------------------------------------------------------------
    final mqttLogId = await service.mqttPublishLog.insertLog(
      MqttPublishLogCompanion.insert(
        predictionId: predictionId,
        topic: 'distillery/factories/TEST_F01/predictions',
        payload: '{"batchId":"BATCH_20260817_F01_B1","label":"GOLDEN_BATCH","confidence":0.975}',
        qos: const Value(1),
        status: 'SUCCESS',
        retryCount: const Value(0),
      ),
    );
    expect(mqttLogId, greaterThan(0));
    print('[Step 10 PASSED] Test MQTT publish log inserted with ID: $mqttLogId');

    // -------------------------------------------------------------------------
    // STEP 11: Insert test backup history record
    // -------------------------------------------------------------------------
    final backupId = await service.backupHistory.insertBackup(
      BackupHistoryCompanion.insert(
        backupFileName: 'distillery_backup_20260817_000000.db',
        backupLocation: 'gs://distillery-backups/backups/distillery_backup_20260817.db',
        cloudProvider: 'Google Cloud Storage',
        databaseSizeBytes: Value(BigInt.from(5242880)), // 5MB
        recordsBackedUp: const Value(15000),
        status: 'SUCCESS',
        verifiedAt: Value(now),
        deletedLocalRecords: const Value(0),
      ),
    );
    expect(backupId, greaterThan(0));
    print('[Step 11 PASSED] Test backup history record inserted with ID: $backupId');

    // -------------------------------------------------------------------------
    // STEP 12: Read records back and verify field values & integrity
    // -------------------------------------------------------------------------
    final fetchedFactory = await service.factories.getFactoryByCode('TEST_F01');
    expect(fetchedFactory, isNotNull);
    expect(fetchedFactory!.factoryName, equals('Test Distillery Facility 01'));
    expect(fetchedFactory.driveFolderId, equals('folder_drive_test_123'));
    expect(fetchedFactory.isActive, isTrue);

    final fetchedFile = await service.inputFiles.getFileByDriveId(factoryId, 'drive_file_test_abc123');
    expect(fetchedFile, isNotNull);
    expect(fetchedFile!.fileName, equals('Batch_Fermentation_2026_08_17.xlsx'));
    expect(fetchedFile.status, equals('NEW'));

    final fetchedBatch = await service.batches.getBatchByBatchId(factoryId, 'BATCH_20260817_F01_B1');
    expect(fetchedBatch, isNotNull);
    expect(fetchedBatch!.fermenter, equals('FERMENTER_TANK_03'));

    final fetchedPrep = await service.preprocessingData.getByBatchId(batchPk);
    expect(fetchedPrep.length, equals(1));
    expect(fetchedPrep.first.sugarConsumptionRate, closeTo(0.85, 0.001));
    expect(fetchedPrep.first.phFinal, closeTo(4.1, 0.001));
    expect(fetchedPrep.first.temperature, closeTo(32.4, 0.001));

    final fetchedPrediction = await service.predictions.getPredictionsByBatch(batchPk);
    expect(fetchedPrediction.length, equals(1));
    expect(fetchedPrediction.first.predictionLabel, equals('GOLDEN_BATCH'));
    expect(fetchedPrediction.first.predictionConfidence, closeTo(0.975, 0.001));

    final fetchedMqtt = await service.mqttPublishLog.getLogsByPrediction(predictionId);
    expect(fetchedMqtt.length, equals(1));
    expect(fetchedMqtt.first.status, equals('SUCCESS'));

    final fetchedBackups = await service.backupHistory.getBackupsByStatus('SUCCESS');
    expect(fetchedBackups.length, equals(1));
    expect(fetchedBackups.first.backupFileName, equals('distillery_backup_20260817_000000.db'));
    print('[Step 12 PASSED] Read records back and verified all field contents.');

    // -------------------------------------------------------------------------
    // STEP 13: Verify foreign-key relationships & constraints
    // -------------------------------------------------------------------------
    // Expect error when inserting input_file with invalid non-existent factory_id
    expect(
      () => service.inputFiles.insertFile(
        InputFilesCompanion.insert(
          factoryId: 999999, // Non-existent foreign key
          driveFileId: 'drive_file_invalid_fk',
          fileName: 'invalid.xlsx',
          status: 'NEW',
        ),
      ),
      throwsA(anything),
    );

    // Expect error when inserting batch with invalid non-existent factory_id
    expect(
      () => service.batches.insertBatch(
        BatchesCompanion.insert(
          factoryId: 999999, // Non-existent foreign key
          inputFileId: inputFileId,
          batchId: 'BATCH_INVALID_FK',
        ),
      ),
      throwsA(anything),
    );

    // Expect error when inserting prediction with invalid non-existent model_id
    expect(
      () => service.predictions.insertPrediction(
        PredictionsCompanion.insert(
          batchId: batchPk,
          processingRunId: runId,
          modelId: 999999, // Non-existent model
          predictionLabel: 'NORMAL_BATCH',
        ),
      ),
      throwsA(anything),
    );

    // Expect ON DELETE RESTRICT to block deleting an AI Model when a Prediction references it
    expect(
      () => service.aiModels.deleteModel(modelId),
      throwsA(anything),
    );
    print('[Step 13 PASSED] Foreign-key constraint enforcement (including ON DELETE RESTRICT) verified.');

    // -------------------------------------------------------------------------
    // STEP 14: Verify unique constraints
    // -------------------------------------------------------------------------
    // Duplicate factory_code violation
    expect(
      () => service.factories.insertFactory(
        FactoriesCompanion.insert(
          factoryCode: 'TEST_F01', // Already exists!
          factoryName: 'Duplicate Test Factory',
          driveFolderId: 'folder_duplicate',
        ),
      ),
      throwsA(anything),
    );

    // Duplicate (factory_id, drive_file_id) violation on input_files
    expect(
      () => service.inputFiles.insertFile(
        InputFilesCompanion.insert(
          factoryId: factoryId,
          driveFileId: 'drive_file_test_abc123', // Already exists for this factory!
          fileName: 'Another_File_Same_Id.xlsx',
          status: 'NEW',
        ),
      ),
      throwsA(anything),
    );
    print('[Step 14 PASSED] Unique constraints verified.');

    // -------------------------------------------------------------------------
    // STEP 15: Delete test records
    // -------------------------------------------------------------------------
    await service.mqttPublishLog.deleteLog(mqttLogId);
    await service.predictions.deletePrediction(predictionId);
    await service.preprocessingData.deleteRecord(prepId);
    await service.processingRuns.deleteRun(runId);
    await service.aiModels.deleteModel(modelId);
    await service.batches.deleteBatch(batchPk);
    await service.inputFiles.deleteFile(inputFileId);
    await service.factories.deleteFactory(factoryId);
    await service.backupHistory.deleteBackup(backupId);

    final remainingFactories = await service.factories.getAllFactories();
    final remainingFiles = await service.inputFiles.getAllFiles();
    final remainingBatches = await service.batches.getAllBatches();
    final remainingBackups = await service.backupHistory.getAllBackups();

    expect(remainingFactories, isEmpty);
    expect(remainingFiles, isEmpty);
    expect(remainingBatches, isEmpty);
    expect(remainingBackups, isEmpty);
    print('[Step 15 PASSED] Test records deleted and tables verified empty.');

    // -------------------------------------------------------------------------
    // STEP 16: Close database (will also be handled by tearDown)
    // -------------------------------------------------------------------------
    await db.close();
    print('[Step 16 PASSED] Database closed cleanly.');
  });

  test('Factory Seeder Test: Seeds F01 through F05', () async {
    await service.seedInitialFactories();

    final allFactories = await service.factories.getAllFactories();
    expect(allFactories.length, equals(5));

    final codes = allFactories.map((f) => f.factoryCode).toList()..sort();
    expect(codes, equals(['F01', 'F02', 'F03', 'F04', 'F05']));

    // Re-running seedInitialFactories should be idempotent
    await service.seedInitialFactories();
    final reChecked = await service.factories.getAllFactories();
    expect(reChecked.length, equals(5));
    print('[Factory Seeder PASSED] Successfully verified F01-F05 seed idempotency.');
  });
}

