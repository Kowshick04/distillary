// ignore_for_file: avoid_print

import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:workmanager/workmanager.dart';

import 'distillery_service.dart';

/// Top-level entry point for the Android WorkManager background dispatcher.
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((taskName, inputData) async {
    print('[BACKGROUND] ===================================================');
    print('[BACKGROUND] WORKER START');
    print('[BACKGROUND] WorkManager Task Started: $taskName');
    print('[BACKGROUND] ===================================================');

    WidgetsFlutterBinding.ensureInitialized();
    print('[BACKGROUND] WORKER INITIALIZATION: WidgetsFlutterBinding initialized.');
    final worker = DistilleryBackgroundWorker();
    final result = await worker.executePeriodicSync();

    print('[BACKGROUND] ===================================================');
    print('[BACKGROUND] WORKER COMPLETE with result: $result');
    print('[BACKGROUND] ===================================================');

    return result;
  });
}

/// Result metadata returned by a background sync execution run.
class BackgroundSyncRunReport {
  final bool success;
  final bool requiresRetry;
  final int factoriesProcessed;
  final int factoriesSucceeded;
  final int totalNewFiles;
  final int totalModifiedFiles;
  final int totalUnchangedFiles;
  final int totalRecordsInserted;
  final Map<String, String> factoryStatuses;
  final String? errorMessage;

  const BackgroundSyncRunReport({
    required this.success,
    required this.requiresRetry,
    required this.factoriesProcessed,
    required this.factoriesSucceeded,
    required this.totalNewFiles,
    required this.totalModifiedFiles,
    required this.totalUnchangedFiles,
    required this.totalRecordsInserted,
    required this.factoryStatuses,
    this.errorMessage,
  });
}

/// Android Background Execution Engine for the Distillery Module.
/// 
/// Orchestrates periodic, bounded background scanning and ingestion across
/// all 5 dedicated plant databases (F01–F05) using Android WorkManager.
class DistilleryBackgroundWorker {
  static const String periodicTaskUniqueName = 'distillery_periodic_sync_task';
  static const String periodicTaskTag = 'distillery_background_sync';

  /// Default background synchronization frequency (15 minutes on Android WorkManager).
  static const Duration productionInterval = Duration(minutes: 15);
  /// Development sync frequency.
  static const Duration developmentInterval = Duration(minutes: 15);

  /// Atomic mutual exclusion flag to prevent concurrent background runs.
  static bool _isSyncLocked = false;
  /// Exposes current mutex state for diagnostic and testing purposes.
  static bool get isSyncLocked => _isSyncLocked;

  /// Resets the concurrency lock (for testing or emergency cleanup).
  static void resetSyncLock() {
    _isSyncLocked = false;
  }

  final bool _ownsDistilleryService;
  final DistilleryService _distilleryService;
  final GoogleSignIn _googleSignIn;

  DistilleryBackgroundWorker({
    DistilleryService? distilleryService,
    GoogleSignIn? googleSignIn,
  })  : _ownsDistilleryService = distilleryService == null,
        _distilleryService = distilleryService ?? DistilleryService(),
        _googleSignIn = googleSignIn ??
            GoogleSignIn(
              scopes: [
                drive.DriveApi.driveReadonlyScope,
                drive.DriveApi.driveFileScope,
              ],
            );

  /// Initializes the Android WorkManager dispatcher.
  static Future<void> initialize() async {
    try {
      await Workmanager().initialize(
        callbackDispatcher,
      );
      print('[BACKGROUND] WorkManager dispatcher initialized successfully.');
    } catch (e) {
      print('[BACKGROUND] WorkManager initialization warning: $e');
    }
  }

  /// Schedules the periodic background synchronization with network constraints.
  static Future<void> schedulePeriodicSync({
    Duration frequency = productionInterval,
    bool requiresCharging = false,
  }) async {
    try {
      await Workmanager().registerPeriodicTask(
        periodicTaskUniqueName,
        periodicTaskTag,
        frequency: frequency,
        constraints: Constraints(
          networkType: NetworkType.connected,
          requiresCharging: requiresCharging,
          requiresDeviceIdle: false,
        ),
        backoffPolicy: BackoffPolicy.exponential,
        backoffPolicyDelay: const Duration(minutes: 5),
        existingWorkPolicy: ExistingPeriodicWorkPolicy.keep,
      );
      print('[BACKGROUND] Registered periodic background sync (interval: ${frequency.inMinutes}m, network: CONNECTED)');
    } catch (e) {
      print('[BACKGROUND] Failed to register periodic background task: $e');
    }
  }

  /// Triggers an immediate one-off background synchronization via WorkManager for testing.
  static Future<void> triggerImmediateSync() async {
    try {
      await Workmanager().registerOneOffTask(
        'distillery_one_off_sync_${DateTime.now().millisecondsSinceEpoch}',
        'distillery_one_off_sync',
        constraints: Constraints(
          networkType: NetworkType.connected,
        ),
      );
      print('[BACKGROUND] Registered immediate one-off WorkManager task.');
    } catch (e) {
      print('[BACKGROUND] Failed to register immediate one-off task: $e');
    }
  }

  /// Cancels the scheduled periodic background synchronization.
  static Future<void> cancelPeriodicSync() async {
    try {
      await Workmanager().cancelByUniqueName(periodicTaskUniqueName);
      print('[BACKGROUND] Periodic background sync task cancelled.');
    } catch (e) {
      print('[BACKGROUND] Cancel task error: $e');
    }
  }

  /// Executes a single full background synchronization cycle across all 5 plants.
  /// 
  /// Returns `true` if completed or safely skipped, or `false` to request a WorkManager retry.
  Future<bool> executePeriodicSync({
    drive.DriveApi? driveApiOverride,
    String? accessTokenOverride,
  }) async {
    final report = await runFullSyncCycle(
      driveApiOverride: driveApiOverride,
      accessTokenOverride: accessTokenOverride,
    );
    return !report.requiresRetry;
  }

  /// Runs the full 5-plant synchronization cycle and returns a detailed report.
  Future<BackgroundSyncRunReport> runFullSyncCycle({
    drive.DriveApi? driveApiOverride,
    String? accessTokenOverride,
  }) async {
    // 1. Concurrency Check
    if (_isSyncLocked) {
      print('[BACKGROUND] Skipped: Sync already in progress (Concurrency Lock active).');
      return const BackgroundSyncRunReport(
        success: true,
        requiresRetry: false,
        factoriesProcessed: 0,
        factoriesSucceeded: 0,
        totalNewFiles: 0,
        totalModifiedFiles: 0,
        totalUnchangedFiles: 0,
        totalRecordsInserted: 0,
        factoryStatuses: {},
        errorMessage: 'Skipped due to concurrent sync lock.',
      );
    }

    _isSyncLocked = true;
    print('[BACKGROUND] Acquired sync lock. Starting background synchronization...');

    drive.DriveApi? driveApi = driveApiOverride;
    String? accessToken = accessTokenOverride;

    try {
      // 2. Authentication Resolution
      if (driveApi == null) {
        print('[BACKGROUND] GOOGLE AUTHENTICATION: Checking GoogleSignIn credentials...');
        GoogleSignInAccount? account = _googleSignIn.currentUser;
        if (account == null) {
          print('[BACKGROUND] GoogleSignIn.currentUser is null. Attempting signInSilently()...');
          account = await _googleSignIn.signInSilently();
        }

        if (account == null) {
          print('[BACKGROUND] GOOGLE AUTHENTICATION: FAILURE (No active Google account cached. User must sign in via UI first).');
          return const BackgroundSyncRunReport(
            success: false,
            requiresRetry: true,
            factoriesProcessed: 0,
            factoriesSucceeded: 0,
            totalNewFiles: 0,
            totalModifiedFiles: 0,
            totalUnchangedFiles: 0,
            totalRecordsInserted: 0,
            factoryStatuses: {},
            errorMessage: 'Google Sign-In credentials unavailable in background.',
          );
        }

        print('[BACKGROUND] GOOGLE AUTHENTICATION: SUCCESS (Account: ${account.email})');
        print('[BACKGROUND] DRIVE CLIENT CREATION: Obtaining authenticated HTTP client...');
        final authClient = await _googleSignIn.authenticatedClient();
        if (authClient == null) {
          print('[BACKGROUND] DRIVE CLIENT CREATION: FAILURE (Failed to obtain authClient)');
          return const BackgroundSyncRunReport(
            success: false,
            requiresRetry: true,
            factoriesProcessed: 0,
            factoriesSucceeded: 0,
            totalNewFiles: 0,
            totalModifiedFiles: 0,
            totalUnchangedFiles: 0,
            totalRecordsInserted: 0,
            factoryStatuses: {},
            errorMessage: 'Failed to create authenticated HTTP client.',
          );
        }

        print('[BACKGROUND] DRIVE CLIENT CREATION: SUCCESS');
        driveApi = drive.DriveApi(authClient);
      }

      // 3. Initialize Database Manager & Tables
      await _distilleryService.initialize();

      int totalNew = 0;
      int totalModified = 0;
      int totalUnchanged = 0;
      int totalInserted = 0;
      int succeededPlants = 0;
      final Map<String, String> plantStatuses = {};

      // 4. Iterate 5 Dedicated Plants (F01 to F05) with Fault Isolation
      for (final plant in _distilleryService.supportedPlants) {
        final code = plant.code;
        print('[BACKGROUND] ---------------------------------------------------');
        print('[BACKGROUND] [$code] Processing Factory: $code (${plant.name}) -> ${plant.dbFileName}');

        try {
          String runtimeDbPath = 'memory';
          try {
            final dbFolder = await getApplicationSupportDirectory();
            runtimeDbPath = p.join(dbFolder.path, plant.dbFileName);
          } catch (_) {
            runtimeDbPath = plant.dbFileName;
          }

          print('[BACKGROUND][$code] $code DATABASE OPEN: factory = $code, database = ${plant.dbFileName}, path = $runtimeDbPath');

          final dbService = _distilleryService.getDatabase(code);

          // Stale Run Recovery (If previous execution was killed mid-run)
          final recovered = await dbService.processingRuns.recoverStaleRunningRuns(
            staleThreshold: const Duration(minutes: 15),
          );
          if (recovered > 0) {
            print('[BACKGROUND][$code] Recovered $recovered stale RUNNING processing runs.');
          }

          // A. Scan Factory Folder
          print('[BACKGROUND][$code] $code SCAN: Drive Folder ID = ${plant.driveFolderId}');
          final scanReport = await _distilleryService.scanFactory(
            factoryCode: code,
            driveApi: driveApi,
            accessToken: accessToken,
          );

          if (scanReport.status == 'ERROR' ||
              scanReport.status == 'SCAN_ERROR' ||
              scanReport.errorMessage != null) {
            print('[BACKGROUND][$code] $code SCAN: FAILURE (${scanReport.errorMessage ?? scanReport.status})');
            plantStatuses[code] = 'FAILED: ${scanReport.errorMessage ?? scanReport.status}';
            continue;
          }

          totalNew += scanReport.newFiles;
          totalModified += scanReport.modifiedFiles;
          totalUnchanged += scanReport.unchangedFiles;

          print('[BACKGROUND][$code] $code CLASSIFICATION: NEW=${scanReport.newFiles}, MODIFIED=${scanReport.modifiedFiles}, UNCHANGED=${scanReport.unchangedFiles}');
          for (final f in scanReport.detectedFiles) {
            print('[BACKGROUND][$code] File: ${f.fileName} (ID: ${f.driveFileId}, size: ${f.sizeBytes}, modified: ${f.modifiedTime}) -> ${f.syncStatus}');
          }

          // B. Ingest Actionable Files
          if (scanReport.hasActionableFiles) {
            print('[BACKGROUND][$code] $code DOWNLOAD & PARSE: Actionable files detected. Beginning atomic ingestion...');
            final ingestionReport = await _distilleryService.ingestPendingFiles(
              factoryCode: code,
              driveApi: driveApi,
              scanReport: scanReport,
              accessToken: accessToken,
              onProgress: (msg) => print('[BACKGROUND][$code] $msg'),
            );

            totalInserted += ingestionReport.totalRecordsInserted;
            if (ingestionReport.success) {
              print('[BACKGROUND][$code] $code DATABASE INSERT: SUCCESS (${ingestionReport.totalRecordsInserted} records inserted)');
              print('[BACKGROUND][$code] $code PROCESSING_RUN: Created and marked COMPLETED');
              print('[BACKGROUND][$code] $code preprocessing_data: ${ingestionReport.totalRecordsInserted} records stored');
              plantStatuses[code] = 'SUCCESS (${ingestionReport.totalRecordsInserted} records)';
              succeededPlants++;
            } else {
              print('[BACKGROUND][$code] $code DATABASE INSERT: FAILURE (${ingestionReport.errorMessage})');
              plantStatuses[code] = 'INGESTION_ERROR: ${ingestionReport.errorMessage}';
            }
          } else {
            print('[BACKGROUND][$code] $code CLASSIFICATION: All files UNCHANGED (0 new records to insert)');
            plantStatuses[code] = 'UNCHANGED (0 records)';
            succeededPlants++;
          }

          // C. Automatic 7-Day Backup & Safe Pruning Workflow
          print('[BACKGROUND][$code] Evaluating 7-day backup due check...');
          final backupClient = _distilleryService.factoryManager.driveClient;
          if (backupClient == null) {
            print('[BACKGROUND][$code] Automated backup check skipped: GoogleDriveBackupClient is not configured.');
          } else {
            final backupDue = await _distilleryService.isBackupDue(factoryCode: code);
            if (backupDue) {
              print('[BACKGROUND][$code] 7-Day Backup IS DUE for $code. Executing automated backup + remote verification + pruning...');
              final autoReport = await _distilleryService.performAutomatedBackupAndPruning(
                factoryCode: code,
                customClient: backupClient,
                onProgress: (msg) => print('[BACKGROUND][$code] $msg'),
              );
              if (autoReport.isSuccess) {
                print('[BACKGROUND][$code] Automated backup & pruning SUCCESS: Deleted ${autoReport.totalDeleted} records (${autoReport.auditBreakdown})');
              } else {
                print('[BACKGROUND][$code] Automated backup/pruning NOTICE: ${autoReport.errorMessage ?? 'Completed without deletion'}');
              }
            } else {
              print('[BACKGROUND][$code] 7-Day Backup is NOT due yet (verified backup is within 7 days). Skipping backup.');
            }
          }

          // Query and log actual database row counts
          final inputFilesCount = await dbService.inputFiles.getAllFiles().then((l) => l.length);
          final runsCount = await dbService.processingRuns.getAllRuns().then((l) => l.length);
          final batchesCount = await dbService.batches.getAllBatches().then((l) => l.length);
          final prepCount = await dbService.db.customSelect('SELECT COUNT(*) AS c FROM preprocessing_data').getSingle().then((r) => r.read<int>('c'));
          final backupCount = await dbService.backupHistory.getAllBackups().then((l) => l.length);
          print('[BACKGROUND][$code]');
          print('[BACKGROUND][$code] database = ${plant.dbFileName}');
          print('[BACKGROUND][$code] input_files = $inputFilesCount');
          print('[BACKGROUND][$code] processing_runs = $runsCount');
          print('[BACKGROUND][$code] batches = $batchesCount');
          print('[BACKGROUND][$code] preprocessing_data = $prepCount');
          print('[BACKGROUND][$code] backup_history = $backupCount');

        } catch (plantError, stack) {
          print('[BACKGROUND] ! Error processing factory $code: $plantError\n$stack');
          plantStatuses[code] = 'FAILED: $plantError';
          // Fault isolation: continue to next factory without aborting the worker
        }
      }

      print('[BACKGROUND] ---------------------------------------------------');
      print('[BACKGROUND] Background Cycle Summary:');
      print('[BACKGROUND] - Factories Succeeded: $succeededPlants / ${_distilleryService.supportedPlants.length}');
      print('[BACKGROUND] - Total Files: NEW=$totalNew, MODIFIED=$totalModified, UNCHANGED=$totalUnchanged');
      print('[BACKGROUND] - Total Records Inserted: $totalInserted');

      return BackgroundSyncRunReport(
        success: succeededPlants == _distilleryService.supportedPlants.length,
        requiresRetry: false,
        factoriesProcessed: _distilleryService.supportedPlants.length,
        factoriesSucceeded: succeededPlants,
        totalNewFiles: totalNew,
        totalModifiedFiles: totalModified,
        totalUnchangedFiles: totalUnchanged,
        totalRecordsInserted: totalInserted,
        factoryStatuses: plantStatuses,
      );
    } catch (e, stack) {
      print('[BACKGROUND] Fatal background execution error: $e\n$stack');
      return BackgroundSyncRunReport(
        success: false,
        requiresRetry: true,
        factoriesProcessed: 0,
        factoriesSucceeded: 0,
        totalNewFiles: 0,
        totalModifiedFiles: 0,
        totalUnchangedFiles: 0,
        totalRecordsInserted: 0,
        factoryStatuses: {},
        errorMessage: e.toString(),
      );
    } finally {
      // Cleanly close database handles if worker owns the service instance
      if (_ownsDistilleryService) {
        await _distilleryService.closeAll();
      }
      _isSyncLocked = false;
      print('[BACKGROUND] Released sync lock. Background worker finished.');
    }
  }
}
