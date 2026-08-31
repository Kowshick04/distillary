import 'dart:io';
import 'package:googleapis/drive/v3.dart' as drive;
import 'backup_service.dart';
import 'database_service.dart';
import 'drive_bridge_service.dart';
import 'excel_ingestion_service.dart';
import 'factory_database_manager.dart';
import 'google_drive_backup_client.dart';
import 'google_drive_sync_service.dart';
import 'real_google_drive_backup_client.dart';

/// Public result object returned by [DistilleryService.scanFactory].
class FactoryScanReport {
  final String factoryCode;
  final String plantName;
  final String dbFileName;
  final int newFiles;
  final int modifiedFiles;
  final int unchangedFiles;
  final List<DetectedDriveFile> detectedFiles;
  final String status;
  final String? errorMessage;
  final GoogleDriveScanResult? rawScanResult;

  const FactoryScanReport({
    required this.factoryCode,
    required this.plantName,
    required this.dbFileName,
    required this.newFiles,
    required this.modifiedFiles,
    required this.unchangedFiles,
    required this.detectedFiles,
    required this.status,
    this.errorMessage,
    this.rawScanResult,
  });

  bool get hasActionableFiles => (newFiles + modifiedFiles) > 0;
}

/// Public result object returned by [DistilleryService.ingestPendingFiles].
class FactoryIngestionReport {
  final String factoryCode;
  final int totalFilesProcessed;
  final int totalRecordsInserted;
  final bool success;
  final List<IngestionResult> results;
  final String? errorMessage;

  const FactoryIngestionReport({
    required this.factoryCode,
    required this.totalFilesProcessed,
    required this.totalRecordsInserted,
    required this.success,
    required this.results,
    this.errorMessage,
  });
}

/// The unified public Facade for the Distillery Module.
/// 
/// Provides a clean, factory-aware API for host Flutter applications:
/// - Explicit 5-plant database routing (F01: haliyal.db, F02: sankili.db, etc.)
/// - On-demand database lifecycle management
/// - Google Drive folder scanning & NEW/UNCHANGED/MODIFIED detection
/// - Pure Dart Excel parsing and transactional SQLite ingestion
/// - SQLite consistent snapshot backup foundation
class DistilleryService {
  final FactoryDatabaseManager _factoryManager;
  final GoogleDriveSyncService _syncService;

  DistilleryService({
    RealGoogleDriveBackupClient? driveClient,
    FactoryDatabaseManager? factoryManager,
    GoogleDriveSyncService? syncService,
  })  : _factoryManager = factoryManager ?? FactoryDatabaseManager(driveClient: driveClient),
        _syncService = syncService ?? GoogleDriveSyncService();

  /// Access to the underlying [FactoryDatabaseManager].
  FactoryDatabaseManager get factoryManager => _factoryManager;

  /// All supported plant configurations (F01 to F05).
  List<PlantFactoryInfo> get supportedPlants => _factoryManager.plants;

  /// Initializes all factory database identity records.
  Future<void> initialize() async {
    await _factoryManager.initializeAll();
  }

  /// Retrieves the dedicated, isolated [DatabaseService] for a specific plant code.
  /// Databases are opened on-demand and cached safely per plant.
  DatabaseService getDatabase(String factoryCode) {
    return _factoryManager.getDatabaseForPlant(factoryCode);
  }

  /// Scans a specific factory folder on Google Drive for Excel files.
  /// Performs persistent NEW / UNCHANGED / MODIFIED classification against that plant's SQLite database.
  Future<FactoryScanReport> scanFactory({
    required String factoryCode,
    required drive.DriveApi driveApi,
    String? accessToken,
    bool forceReingest = false,
  }) async {
    final plant = _factoryManager.plants.firstWhere(
      (p) => p.code == factoryCode,
      orElse: () => throw ArgumentError('Unknown factory code: $factoryCode'),
    );

    final dbService = getDatabase(factoryCode);
    final factories = await dbService.factories.getAllFactories();
    final bridge = DriveBridgeService(dbService, _syncService);

    try {
      final scanRes = await bridge.scanAndSyncFactoryFiles(
        accessToken: accessToken ?? 'authenticated_client',
        factories: factories,
        driveApi: driveApi,
        forceReingest: forceReingest,
      );

      final summary = scanRes.factories[factoryCode];
      return FactoryScanReport(
        factoryCode: factoryCode,
        plantName: plant.name,
        dbFileName: plant.dbFileName,
        newFiles: scanRes.totalNewFiles,
        modifiedFiles: scanRes.totalModifiedFiles,
        unchangedFiles: scanRes.totalUnchangedFiles,
        detectedFiles: summary?.files ?? const [],
        status: summary?.status ?? 'SUCCESS',
        errorMessage: summary?.errorMessage ?? scanRes.error,
        rawScanResult: scanRes,
      );
    } catch (e) {
      return FactoryScanReport(
        factoryCode: factoryCode,
        plantName: plant.name,
        dbFileName: plant.dbFileName,
        newFiles: 0,
        modifiedFiles: 0,
        unchangedFiles: 0,
        detectedFiles: const [],
        status: 'ERROR',
        errorMessage: e.toString(),
      );
    }
  }

  /// Ingests all pending actionable (NEW / MODIFIED) Excel files for a specific plant.
  Future<FactoryIngestionReport> ingestPendingFiles({
    required String factoryCode,
    required drive.DriveApi driveApi,
    FactoryScanReport? scanReport,
    String? accessToken,
    void Function(String message)? onProgress,
  }) async {
    final dbService = getDatabase(factoryCode);
    final factories = await dbService.factories.getAllFactories();
    final bridge = DriveBridgeService(dbService, _syncService);

    // 1. Resolve scan result
    final GoogleDriveScanResult scanRes;
    if (scanReport?.rawScanResult != null) {
      scanRes = scanReport!.rawScanResult!;
    } else {
      scanRes = await bridge.scanAndSyncFactoryFiles(
        accessToken: accessToken ?? 'authenticated_client',
        factories: factories,
        driveApi: driveApi,
        forceReingest: false,
      );
    }

    if (scanRes.totalActionableFiles == 0) {
      return FactoryIngestionReport(
        factoryCode: factoryCode,
        totalFilesProcessed: 0,
        totalRecordsInserted: 0,
        success: true,
        results: const [],
      );
    }

    final ingestionService = ExcelIngestionService(
      dbService: dbService,
      driveBridgeService: bridge,
    );

    final sub = ingestionService.onProgress.listen((prog) {
      if (onProgress != null) {
        onProgress(prog.message);
      }
    });

    try {
      final results = await ingestionService.ingestScanResult(
        accessToken: accessToken ?? 'authenticated_client',
        scanResult: scanRes,
        driveApi: driveApi,
      );

      final totalInserted = results.fold<int>(0, (sum, r) => sum + r.recordsInserted);
      final allSuccess = results.every((r) => r.success);

      return FactoryIngestionReport(
        factoryCode: factoryCode,
        totalFilesProcessed: results.length,
        totalRecordsInserted: totalInserted,
        success: allSuccess,
        results: results,
      );
    } catch (e) {
      return FactoryIngestionReport(
        factoryCode: factoryCode,
        totalFilesProcessed: 0,
        totalRecordsInserted: 0,
        success: false,
        results: const [],
        errorMessage: e.toString(),
      );
    } finally {
      await sub.cancel();
    }
  }

  /// Creates an atomic SQLite `VACUUM INTO` backup snapshot for a specific plant database.
  Future<File?> createBackupSnapshot(String factoryCode) async {
    final plant = _factoryManager.plants.firstWhere(
      (p) => p.code == factoryCode,
      orElse: () => throw ArgumentError('Unknown factory code: $factoryCode'),
    );
    final dbService = getDatabase(factoryCode);
    return dbService.backupService.createConsistentSnapshot(prefix: plant.name.toLowerCase());
  }

  /// Factory-aware Google Drive backup method.
  /// Validates snapshot locally, uploads to Google Drive under dedicated factory folder,
  /// and validates downloaded remote copy with NO local record pruning.
  Future<BackupOperationResult> backupFactory({
    required String factoryCode,
    String? targetFolderId,
    String rootBackupFolderId = BackupService.defaultGoogleDriveBackupFolderId,
    GoogleDriveBackupClient? customClient,
    void Function(String message)? onProgress,
  }) async {
    final plant = _factoryManager.plants.firstWhere(
      (p) => p.code == factoryCode,
      orElse: () => throw ArgumentError('Unknown factory code: $factoryCode'),
    );

    final dbService = getDatabase(factoryCode);
    final dbPrefix = plant.name.toLowerCase();

    return dbService.backupService.backupFactory(
      factoryCode: factoryCode,
      plantName: plant.name,
      dbPrefix: dbPrefix,
      targetFolderId: targetFolderId ?? (plant.backupFolderId.isNotEmpty ? plant.backupFolderId : null),
      rootBackupFolderId: rootBackupFolderId,
      customClient: customClient ?? _factoryManager.driveClient,
      onProgress: onProgress,
    );
  }

  /// Factory-aware safe 7-day local data pruning method.
  /// Enforces backup verification, exact FK-safe deletion order, and zero data loss on protected tables.
  Future<PruneOperationResult> pruneHistoricalData({
    required String factoryCode,
    Duration retentionPeriod = const Duration(days: 7),
    DateTime? referenceNow,
    int? specificBackupHistoryId,
    void Function(String message)? onProgress,
  }) async {
    final plant = _factoryManager.plants.firstWhere(
      (p) => p.code == factoryCode,
      orElse: () => throw ArgumentError('Unknown factory code: $factoryCode'),
    );

    final dbService = getDatabase(plant.code);
    return dbService.backupService.pruneHistoricalData(
      factoryCode: plant.code,
      retentionPeriod: retentionPeriod,
      referenceNow: referenceNow,
      specificBackupHistoryId: specificBackupHistoryId,
      onProgress: onProgress,
    );
  }

  /// Checks if a 7-day automated backup is due for a specific factory.
  Future<bool> isBackupDue({
    required String factoryCode,
    Duration backupInterval = BackupService.defaultBackupInterval,
    DateTime? referenceNow,
  }) async {
    final dbService = getDatabase(factoryCode);
    return dbService.backupService.isBackupDue(
      backupInterval: backupInterval,
      referenceNow: referenceNow,
    );
  }

  /// Executes the complete production automated backup -> verification -> pruning pipeline
  /// for a specific factory database.
  Future<AutomatedBackupAndPruneReport> performAutomatedBackupAndPruning({
    required String factoryCode,
    String? targetFolderId,
    String rootBackupFolderId = BackupService.defaultGoogleDriveBackupFolderId,
    Duration backupInterval = BackupService.defaultBackupInterval,
    Duration retentionPeriod = BackupService.defaultRetentionPeriod,
    DateTime? referenceNow,
    bool forceRun = false,
    GoogleDriveBackupClient? customClient,
    void Function(String message)? onProgress,
  }) async {
    final plant = _factoryManager.plants.firstWhere(
      (p) => p.code == factoryCode,
      orElse: () => throw ArgumentError('Unknown factory code: $factoryCode'),
    );

    final dbService = getDatabase(factoryCode);
    final dbPrefix = plant.name.toLowerCase();

    return dbService.backupService.performAutomatedBackupAndPruning(
      factoryCode: factoryCode,
      plantName: plant.name,
      dbPrefix: dbPrefix,
      targetFolderId: targetFolderId ?? (plant.backupFolderId.isNotEmpty ? plant.backupFolderId : null),
      rootBackupFolderId: rootBackupFolderId,
      backupInterval: backupInterval,
      retentionPeriod: retentionPeriod,
      referenceNow: referenceNow,
      forceRun: forceRun,
      customClient: customClient ?? _factoryManager.driveClient,
      onProgress: onProgress,
    );
  }

  /// Cleanly closes all opened plant SQLite database connections.
  Future<void> closeAll() async {
    await _factoryManager.closeAll();
  }
}


final distilleryService = DistilleryService();
