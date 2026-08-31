import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import '../database/database.dart';
import 'database_service.dart';
import 'distillery_excel_parser.dart';
import 'drive_bridge_service.dart';

/// Progress states during automatic Excel ingestion.
enum IngestionStage {
  idle,
  downloading,
  validating,
  parsing,
  databaseTransaction,
  success,
  failed,
}

/// Detailed log event emitted during the automatic ingestion pipeline.
class IngestionProgressEvent {
  final String factoryCode;
  final String fileName;
  final String driveFileId;
  final IngestionStage stage;
  final String message;
  final int? recordsCount;
  final String? error;
  final DateTime timestamp;

  const IngestionProgressEvent({
    required this.factoryCode,
    required this.fileName,
    required this.driveFileId,
    required this.stage,
    required this.message,
    this.recordsCount,
    this.error,
    required this.timestamp,
  });

  @override
  String toString() => '[$stage] $factoryCode / $fileName: $message';
}

/// Result of an automatic Excel ingestion operation.
class IngestionResult {
  final bool success;
  final int inputFileId;
  final int? processingRunId;
  final int? batchId;
  final int recordsInserted;
  final String? error;

  const IngestionResult({
    required this.success,
    required this.inputFileId,
    this.processingRunId,
    this.batchId,
    this.recordsInserted = 0,
    this.error,
  });

  factory IngestionResult.failed({required int inputFileId, required String error, int? processingRunId}) {
    return IngestionResult(
      success: false,
      inputFileId: inputFileId,
      processingRunId: processingRunId,
      error: error,
    );
  }
}

/// Dedicated service responsible for end-to-end automatic Google Drive Excel ingestion:
/// 1. Download via Google Drive service to Android-private storage.
/// 2. Validate file integrity.
/// 3. Parse worksheets and map columns in pure Dart.
/// 4. Atomic Drift SQLite transaction: batches -> preprocessing_data -> input_files -> processing_runs.
/// 5. Temporary file cleanup.
class ExcelIngestionService {
  final DatabaseService dbService;
  final DriveBridgeService driveBridgeService;
  final Directory? customTempDir;

  final _progressStreamController = StreamController<IngestionProgressEvent>.broadcast();
  Stream<IngestionProgressEvent> get onProgress => _progressStreamController.stream;

  ExcelIngestionService({
    required this.dbService,
    required this.driveBridgeService,
    this.customTempDir,
  });

  void dispose() {
    _progressStreamController.close();
  }

  void _emitProgress({
    required String factoryCode,
    required String fileName,
    required String driveFileId,
    required IngestionStage stage,
    required String message,
    int? recordsCount,
    String? error,
  }) {
    final event = IngestionProgressEvent(
      factoryCode: factoryCode,
      fileName: fileName,
      driveFileId: driveFileId,
      stage: stage,
      message: message,
      recordsCount: recordsCount,
      error: error,
      timestamp: DateTime.now(),
    );
    debugPrint('[INGESTION] $event');
    _progressStreamController.add(event);
  }

  /// Automatically ingests all actionable (NEW or MODIFIED) files returned from a Drive scan.
  Future<List<IngestionResult>> ingestScanResult({
    required String accessToken,
    required GoogleDriveScanResult scanResult,
    drive.DriveApi? driveApi,
  }) async {
    final results = <IngestionResult>[];

    for (final entry in scanResult.factories.entries) {
      final factorySummary = entry.value;
      for (final detectedFile in factorySummary.files) {
        if (detectedFile.syncStatus == 'NEW' || detectedFile.syncStatus == 'MODIFIED') {
          final result = await ingestSingleFile(
            accessToken: accessToken,
            factoryCode: factorySummary.factoryCode,
            factoryId: factorySummary.factoryId,
            driveFileId: detectedFile.driveFileId,
            fileName: detectedFile.fileName,
            dbFileId: detectedFile.dbFileId,
            driveApi: driveApi,
          );
          results.add(result);
        }
      }
    }

    return results;
  }

  /// Ingests a single Google Drive Excel file into the SQLite database with full transaction safety.
  Future<IngestionResult> ingestSingleFile({
    required String accessToken,
    required String factoryCode,
    required int factoryId,
    required String driveFileId,
    required String fileName,
    int? dbFileId,
    drive.DriveApi? driveApi,
    File? existingLocalFile, // For local automated testing
    bool deleteAfterIngestion = true,
  }) async {
    final now = DateTime.now();

    // 1. Ensure input_files entry exists
    int inputFileId = dbFileId ?? 0;
    if (inputFileId <= 0) {
      final existingDbFile = await dbService.inputFiles.getFileByDriveId(factoryId, driveFileId);
      if (existingDbFile != null) {
        inputFileId = existingDbFile.id;
      } else {
        inputFileId = await dbService.inputFiles.insertFile(
          InputFilesCompanion.insert(
            factoryId: factoryId,
            driveFileId: driveFileId,
            fileName: fileName,
            status: 'NEW',
            firstSeenAt: Value(now),
            lastSeenAt: Value(now),
          ),
        );
      }
    }

    File? tempFile;
    int? processingRunId;

    try {
      // -----------------------------------------------------------------------
      // STAGE 1: AUTOMATIC DOWNLOAD
      // -----------------------------------------------------------------------
      _emitProgress(
        factoryCode: factoryCode,
        fileName: fileName,
        driveFileId: driveFileId,
        stage: IngestionStage.downloading,
        message: '[INGESTION] Downloading $fileName from Google Drive...',
      );

      if (existingLocalFile != null && await existingLocalFile.exists()) {
        tempFile = existingLocalFile;
      } else {
        final tempDir = customTempDir ?? Directory.systemTemp;
        final downloadDir = Directory('${tempDir.path}/distillery_excel_downloads');
        if (!await downloadDir.exists()) {
          await downloadDir.create(recursive: true);
        }

        final targetPath = '${downloadDir.path}/${driveFileId}_$fileName';
        final downloadResult = await driveBridgeService.downloadDriveFile(
          accessToken: accessToken,
          driveFileId: driveFileId,
          destinationPath: targetPath,
          driveApi: driveApi,
        );

        if (!downloadResult.success) {
          throw FormatException('Google Drive download failed: ${downloadResult.error}');
        }

        tempFile = File(targetPath);
      }

      // -----------------------------------------------------------------------
      // STAGE 2: FILE VALIDATION
      // -----------------------------------------------------------------------
      _emitProgress(
        factoryCode: factoryCode,
        fileName: fileName,
        driveFileId: driveFileId,
        stage: IngestionStage.validating,
        message: '[INGESTION] Validating downloaded Excel file...',
      );

      if (!await tempFile.exists()) {
        throw FormatException('Downloaded file does not exist at ${tempFile.path}');
      }

      final fileLength = await tempFile.length();
      if (fileLength == 0) {
        throw const FormatException('Downloaded Excel file is empty (0 bytes).');
      }

      final isExcelExt = fileName.toLowerCase().endsWith('.xlsx') || fileName.toLowerCase().endsWith('.xls');
      if (!isExcelExt) {
        throw FormatException('Invalid file extension for Excel ingestion: $fileName');
      }

      // -----------------------------------------------------------------------
      // STAGE 3: AUTOMATIC EXCEL PARSING
      // -----------------------------------------------------------------------
      _emitProgress(
        factoryCode: factoryCode,
        fileName: fileName,
        driveFileId: driveFileId,
        stage: IngestionStage.parsing,
        message: '[INGESTION] Parsing Excel workbook...',
      );

      final parsedWorkbook = await DistilleryExcelParser.parseFile(
        tempFile,
        defaultBatchPrefix: 'BATCH_$factoryCode',
      );

      if (parsedWorkbook.rows.isEmpty) {
        throw const FormatException('Excel workbook has 0 valid process rows.');
      }

      // -----------------------------------------------------------------------
      // STAGE 4: ATOMIC SQLITE DATABASE TRANSACTION
      // -----------------------------------------------------------------------
      _emitProgress(
        factoryCode: factoryCode,
        fileName: fileName,
        driveFileId: driveFileId,
        stage: IngestionStage.databaseTransaction,
        message: '[DATABASE] Beginning SQLite atomic transaction for ${parsedWorkbook.validRowsCount} rows...',
      );

      int createdBatchId = 0;
      int insertedRecordsCount = 0;

      await dbService.db.transaction(() async {
        // 4a. Create ProcessingRun (status: RUNNING)
        processingRunId = await dbService.processingRuns.insertRun(
          ProcessingRunsCompanion.insert(
            inputFileId: inputFileId,
            status: 'RUNNING',
            pipelineVersion: const Value('1.0.0-ingestion'),
          ),
        );

        _emitProgress(
          factoryCode: factoryCode,
          fileName: fileName,
          driveFileId: driveFileId,
          stage: IngestionStage.databaseTransaction,
          message: '[DATABASE] Processing run created (ID: $processingRunId)',
        );

        // 4b. Find or Create Batch
        final existingBatch = await dbService.batches.getBatchByBatchId(factoryId, parsedWorkbook.batchId);
        if (existingBatch != null) {
          createdBatchId = existingBatch.id;
        } else {
          createdBatchId = await dbService.batches.insertBatch(
            BatchesCompanion.insert(
              factoryId: factoryId,
              inputFileId: inputFileId,
              batchId: parsedWorkbook.batchId,
              fermenter: parsedWorkbook.fermenter != null ? Value(parsedWorkbook.fermenter) : const Value.absent(),
              state: parsedWorkbook.state != null ? Value(parsedWorkbook.state) : const Value.absent(),
              batchStartTime: parsedWorkbook.batchStartTime != null ? Value(parsedWorkbook.batchStartTime) : const Value.absent(),
              batchEndTime: parsedWorkbook.batchEndTime != null ? Value(parsedWorkbook.batchEndTime) : const Value.absent(),
            ),
          );
        }

        // Link batchId to processing run
        await (dbService.db.update(dbService.db.processingRuns)..where((tbl) => tbl.id.equals(processingRunId!))).write(
          ProcessingRunsCompanion(batchId: Value(createdBatchId)),
        );

        // Remove old rows for this file if re-ingesting
        await (dbService.db.delete(dbService.db.preprocessingData)..where((tbl) => tbl.inputFileId.equals(inputFileId))).go();

        // 4c. Bulk Insert PreprocessingData Rows
        final companionRecords = parsedWorkbook.rows.map((r) {
          return PreprocessingDataCompanion.insert(
            batchId: createdBatchId,
            inputFileId: inputFileId,
            processingRunId: processingRunId!,
            timestampMinute: r.timestampMinute != null ? Value(r.timestampMinute) : const Value.absent(),
            serverTimestamp: r.serverTimestamp != null ? Value(r.serverTimestamp) : const Value.absent(),
            sugarConsumptionRate: r.sugarConsumptionRate != null ? Value(r.sugarConsumptionRate) : const Value.absent(),
            feedingHours: r.feedingHours != null ? Value(r.feedingHours) : const Value.absent(),
            retentionHours: r.retentionHours != null ? Value(r.retentionHours) : const Value.absent(),
            setupSg: r.setupSg != null ? Value(r.setupSg) : const Value.absent(),
            finalSg: r.finalSg != null ? Value(r.finalSg) : const Value.absent(),
            sgDifference: r.sgDifference != null ? Value(r.sgDifference) : const Value.absent(),
            alcoholSetup: r.alcoholSetup != null ? Value(r.alcoholSetup) : const Value.absent(),
            alcoholFinal: r.alcoholFinal != null ? Value(r.alcoholFinal) : const Value.absent(),
            phSetup: r.phSetup != null ? Value(r.phSetup) : const Value.absent(),
            phFinal: r.phFinal != null ? Value(r.phFinal) : const Value.absent(),
            rawSpentWashBrix: r.rawSpentWashBrix != null ? Value(r.rawSpentWashBrix) : const Value.absent(),
            bottomSpentWashBrix: r.bottomSpentWashBrix != null ? Value(r.bottomSpentWashBrix) : const Value.absent(),
            ffeOutletSpentWashBrix: r.ffeOutletSpentWashBrix != null ? Value(r.ffeOutletSpentWashBrix) : const Value.absent(),
            concentratedSpentWashBrix: r.concentratedSpentWashBrix != null ? Value(r.concentratedSpentWashBrix) : const Value.absent(),
            temperature: r.temperature != null ? Value(r.temperature) : const Value.absent(),
            brix: r.brix != null ? Value(r.brix) : const Value.absent(),
            residualSugar: r.residualSugar != null ? Value(r.residualSugar) : const Value.absent(),
            yeastActivity: r.yeastActivity != null ? Value(r.yeastActivity) : const Value.absent(),
            volatileAcidity: r.volatileAcidity != null ? Value(r.volatileAcidity) : const Value.absent(),
            coolingValve: r.coolingValve != null ? Value(r.coolingValve) : const Value.absent(),
            agitatorRpm: r.agitatorRpm != null ? Value(r.agitatorRpm) : const Value.absent(),
            steamValve: r.steamValve != null ? Value(r.steamValve) : const Value.absent(),
            tankLevelPercent: r.tankLevelPercent != null ? Value(r.tankLevelPercent) : const Value.absent(),
            tankWeightKg: r.tankWeightKg != null ? Value(r.tankWeightKg) : const Value.absent(),
            co2FlowKgph: r.co2FlowKgph != null ? Value(r.co2FlowKgph) : const Value.absent(),
            headspacePressureBar: r.headspacePressureBar != null ? Value(r.headspacePressureBar) : const Value.absent(),
          );
        }).toList();

        await dbService.preprocessingData.insertBatchRecords(companionRecords);
        insertedRecordsCount = companionRecords.length;

        _emitProgress(
          factoryCode: factoryCode,
          fileName: fileName,
          driveFileId: driveFileId,
          stage: IngestionStage.databaseTransaction,
          message: '[DATABASE] preprocessing_data inserted: $insertedRecordsCount records',
          recordsCount: insertedRecordsCount,
        );

        // 4d. Update input_files processing status to PROCESSED
        await dbService.inputFiles.updateFileStatus(
          inputFileId,
          'PROCESSED',
          processedAt: DateTime.now(),
        );

        // 4e. Complete ProcessingRun as SUCCESS
        await dbService.processingRuns.updateRunStatus(
          processingRunId!,
          'SUCCESS',
          completedAt: DateTime.now(),
          recordsProcessed: insertedRecordsCount,
        );
      });

      // -----------------------------------------------------------------------
      // STAGE 5: TEMPORARY FILE CLEANUP
      // -----------------------------------------------------------------------
      if (deleteAfterIngestion && await tempFile.exists()) {
        try {
          await tempFile.delete();
          debugPrint('[INGESTION] Cleaned up temporary file: ${tempFile.path}');
        } catch (ce) {
          debugPrint('[INGESTION] Temp file cleanup warning: $ce');
        }
      }

      _emitProgress(
        factoryCode: factoryCode,
        fileName: fileName,
        driveFileId: driveFileId,
        stage: IngestionStage.success,
        message: '[SUCCESS] Excel processing completed ($insertedRecordsCount records stored)',
        recordsCount: insertedRecordsCount,
      );

      return IngestionResult(
        success: true,
        inputFileId: inputFileId,
        processingRunId: processingRunId,
        batchId: createdBatchId,
        recordsInserted: insertedRecordsCount,
      );

    } catch (e, stackTrace) {
      final errorMsg = e.toString();
      debugPrint('[INGESTION ERROR] Failed to ingest $fileName ($driveFileId): $errorMsg\n$stackTrace');

      // Update failure records outside rolled-back transaction
      try {
        if (processingRunId != null) {
          await dbService.processingRuns.updateRunStatus(
            processingRunId!,
            'FAILED',
            completedAt: DateTime.now(),
            errorMessage: errorMsg,
          );
        }

        await dbService.inputFiles.updateFileStatus(
          inputFileId,
          'ERROR',
          errorMessage: errorMsg,
        );
      } catch (dbError) {
        debugPrint('[INGESTION ERROR] Error recording failure in database: $dbError');
      }

      _emitProgress(
        factoryCode: factoryCode,
        fileName: fileName,
        driveFileId: driveFileId,
        stage: IngestionStage.failed,
        message: '[FAILED] Excel processing failed: $errorMsg',
        error: errorMsg,
      );

      return IngestionResult.failed(
        inputFileId: inputFileId,
        processingRunId: processingRunId,
        error: errorMsg,
      );
    }
  }
}
