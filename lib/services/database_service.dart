import 'package:flutter/foundation.dart';
import '../database/database.dart';
import '../database/repositories/ai_model_repository.dart';
import '../database/repositories/backup_history_repository.dart';
import '../database/repositories/batch_repository.dart';
import '../database/repositories/factory_repository.dart';
import '../database/repositories/input_file_repository.dart';
import '../database/repositories/mqtt_publish_log_repository.dart';
import '../database/repositories/prediction_repository.dart';
import '../database/repositories/preprocessing_data_repository.dart';
import '../database/repositories/processing_run_repository.dart';
import 'backup_service.dart';

/// Central database service providing access to all 9 entity repositories,
/// factory seeders, automated backup & pruning, and integration facades.
class DatabaseService {
  final AppDatabase db;

  late final FactoryRepository factories;
  late final InputFileRepository inputFiles;
  late final BatchRepository batches;
  late final ProcessingRunRepository processingRuns;
  late final PreprocessingDataRepository preprocessingData;
  late final AiModelRepository aiModels;
  late final PredictionRepository predictions;
  late final MqttPublishLogRepository mqttPublishLog;
  late final BackupHistoryRepository backupHistory;

  late BackupService backupService;

  DatabaseService([AppDatabase? database, BackupService? customBackupService]) : db = database ?? AppDatabase() {
    factories = FactoryRepository(db);
    inputFiles = InputFileRepository(db);
    batches = BatchRepository(db);
    processingRuns = ProcessingRunRepository(db);
    preprocessingData = PreprocessingDataRepository(db);
    aiModels = AiModelRepository(db);
    predictions = PredictionRepository(db);
    mqttPublishLog = MqttPublishLogRepository(db);
    backupHistory = BackupHistoryRepository(db);

    backupService = customBackupService ?? BackupService(db);
  }

  /// Initial seed data for the 5 distillery factories with real plant names and Google Drive folder IDs
  Future<void> seedInitialFactories() async {
    final defaultFactories = [
      {'code': 'F01', 'name': 'Haliyal - Distillery Plant', 'folder': '1n90IQFqwcuv1QpWp65KF2yfN4-3t_SoT'},
      {'code': 'F02', 'name': 'Sankili - Distillery Plant', 'folder': '1uQcrPhoKxQ-YMyvKq0FIZu0ONd8uwGih'},
      {'code': 'F03', 'name': 'Nellikuppam - Distillery Plant', 'folder': '1DGSzzkkw_aC77xHpbnx9rMHQK3qCo1Gt'},
      {'code': 'F04', 'name': 'Sivagangai - Distillery Plant', 'folder': '1VrcVW_GnNvwA-m5fyc7ClxoYsp3bnbeI'},
      {'code': 'F05', 'name': 'Bagalkot - Distillery Plant', 'folder': '1G-C6TPduJ8LCoAJq3L-TaQvlZ5rkexHX'},
    ];

    for (final f in defaultFactories) {
      final existing = await factories.getFactoryByCode(f['code']!);
      if (existing == null) {
        await factories.insertFactory(
          FactoriesCompanion.insert(
            factoryCode: f['code']!,
            factoryName: f['name']!,
            driveFolderId: f['folder']!,
            isActive: const Value(true),
          ),
        );
      } else {
        // Update name and folder if necessary
        await (db.update(db.factories)..where((tbl) => tbl.id.equals(existing.id))).write(
          FactoriesCompanion(
            factoryName: Value(f['name']!),
            driveFolderId: Value(f['folder']!),
          ),
        );
      }
    }
  }

  // ===========================================================================
  // GOOGLE DRIVE SYNC FACADE
  // ===========================================================================

  /// Registers or updates an Excel file discovered from Google Drive.
  Future<int> registerOrUpdateDriveFile({
    required int factoryId,
    required String driveFileId,
    required String fileName,
    String? fileType,
    BigInt? fileSizeBytes,
    DateTime? driveModifiedAt,
    String? fileHash,
    required String status,
  }) async {
    final existing = await inputFiles.getFileByDriveId(factoryId, driveFileId);
    final now = DateTime.now().toUtc();

    if (existing == null) {
      return await inputFiles.insertFile(
        InputFilesCompanion.insert(
          factoryId: factoryId,
          driveFileId: driveFileId,
          fileName: fileName,
          fileType: Value(fileType),
          fileSizeBytes: Value(fileSizeBytes),
          driveModifiedAt: Value(driveModifiedAt),
          fileHash: Value(fileHash),
          status: status,
          firstSeenAt: Value(now),
          lastSeenAt: Value(now),
        ),
      );
    } else {
      await (db.update(db.inputFiles)..where((tbl) => tbl.id.equals(existing.id))).write(
        InputFilesCompanion(
          fileName: Value(fileName),
          fileSizeBytes: Value(fileSizeBytes),
          driveModifiedAt: Value(driveModifiedAt),
          fileHash: Value(fileHash),
          status: Value(status),
          lastSeenAt: Value(now),
        ),
      );
      return existing.id;
    }
  }

  // ===========================================================================
  // AI PREPROCESSING & INFERENCE FACADE (For AI Pipeline Module)
  // ===========================================================================

  /// Starts a new processing run for a given input file and batch.
  Future<int> startProcessingRun({
    required int inputFileId,
    int? batchId,
    int? modelId,
    String? pipelineVersion,
  }) {
    return processingRuns.insertRun(
      ProcessingRunsCompanion.insert(
        inputFileId: inputFileId,
        batchId: Value(batchId),
        modelId: Value(modelId),
        pipelineVersion: Value(pipelineVersion),
        status: 'RUNNING',
        startedAt: Value(DateTime.now().toUtc()),
      ),
    );
  }

  /// Stores preprocessed feature records in batch.
  Future<void> savePreprocessingRecords(List<PreprocessingDataCompanion> records) {
    return preprocessingData.insertBatchRecords(records);
  }

  /// Stores AI prediction output.
  Future<int> savePrediction(PredictionsCompanion prediction) {
    return predictions.insertPrediction(prediction);
  }

  /// Marks a processing run as completed.
  Future<void> completeProcessingRun({
    required int runId,
    required bool success,
    int? recordsProcessed,
    String? errorMessage,
  }) {
    return processingRuns.updateRunStatus(
      runId,
      success ? 'SUCCESS' : 'FAILED',
      completedAt: DateTime.now().toUtc(),
      recordsProcessed: recordsProcessed,
      errorMessage: errorMessage,
    );
  }

  /// DEVELOPMENT ONLY: Clears all transactional data in this database while preserving schema and factory identity.
  /// Guarded against execution in release production builds.
  Future<void> developmentResetDatabase() async {
    assert(!kReleaseMode, 'developmentResetDatabase() cannot be executed in release mode');
    if (kReleaseMode) {
      throw StateError('Cannot reset database in release production mode.');
    }

    await db.transaction(() async {
      await db.delete(db.mqttPublishLog).go();
      await db.delete(db.predictions).go();
      await db.delete(db.preprocessingData).go();
      await db.delete(db.processingRuns).go();
      await db.delete(db.batches).go();
      await db.delete(db.inputFiles).go();
      await db.delete(db.backupHistory).go();
    });

    // Run SQLite integrity and foreign key checks
    await db.customStatement('PRAGMA integrity_check;');
    await db.customStatement('PRAGMA foreign_key_check;');
  }

  Future<void> close() async {
    await db.close();
  }
}
