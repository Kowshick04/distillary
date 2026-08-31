import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import '../database/database.dart';
import 'database_service.dart';
import 'google_drive_sync_service.dart';

/// Enum representing the change state of an Excel file in Google Drive relative to Drift SQLite.
enum FileChangeType {
  newFile,
  unchanged,
  modified,
}

/// Downstream event emitted when a file is detected/classified.
/// Actionable for NEW and MODIFIED (ready for future processing pipeline).
class DriveFileChangeEvent {
  final String factoryCode;
  final int factoryId;
  final int dbFileId;
  final String driveFileId;
  final String fileName;
  final FileChangeType changeType;
  final bool isActionable;
  final int? sizeBytes;
  final DateTime? driveModifiedAt;
  final DateTime timestamp;

  const DriveFileChangeEvent({
    required this.factoryCode,
    required this.factoryId,
    required this.dbFileId,
    required this.driveFileId,
    required this.fileName,
    required this.changeType,
    required this.isActionable,
    this.sizeBytes,
    this.driveModifiedAt,
    required this.timestamp,
  });

  String get changeTypeString {
    switch (changeType) {
      case FileChangeType.newFile:
        return 'NEW';
      case FileChangeType.unchanged:
        return 'UNCHANGED';
      case FileChangeType.modified:
        return 'MODIFIED';
    }
  }

  @override
  String toString() =>
      'DriveFileChangeEvent($factoryCode: $fileName | Status: $changeTypeString | Actionable: $isActionable | ID: $driveFileId)';
}

/// Representation of an Excel file detected in Google Drive.
class DetectedDriveFile {
  final String driveFileId;
  final String fileName;
  final String? mimeType;
  final int? sizeBytes;
  final String? createdTime;
  final String? modifiedTime;
  final String? md5Checksum;
  final String syncStatus; // 'NEW', 'UNCHANGED', 'MODIFIED'
  final int dbFileId;

  const DetectedDriveFile({
    required this.driveFileId,
    required this.fileName,
    this.mimeType,
    this.sizeBytes,
    this.createdTime,
    this.modifiedTime,
    this.md5Checksum,
    required this.syncStatus,
    this.dbFileId = 0,
  });
}

/// Representation of a factory's scan result with rich diagnostics.
class FactoryScanSummary {
  final String factoryCode;
  final int factoryId;
  final String? folderId;
  final String status;
  final String statusCode; // 'EXCEL_FOUND', 'EMPTY_FOLDER', 'NO_EXCEL_FILES', 'ACCESS_DENIED', 'HTTP_ERROR'
  final String? diagnosticMessage;
  final int totalItemsInFolder;
  final String? errorMessage;
  final List<DetectedDriveFile> files;

  const FactoryScanSummary({
    required this.factoryCode,
    required this.factoryId,
    this.folderId,
    required this.status,
    required this.statusCode,
    this.diagnosticMessage,
    this.totalItemsInFolder = 0,
    this.errorMessage,
    required this.files,
  });
}

/// Overall result of the Google Drive scan with classification totals.
class GoogleDriveScanResult {
  final bool success;
  final String? error;
  final String? authenticatedAccount;
  final Map<String, FactoryScanSummary> factories;
  final int totalNewFiles;
  final int totalModifiedFiles;
  final int totalUnchangedFiles;
  final List<DriveFileChangeEvent> events;

  const GoogleDriveScanResult({
    required this.success,
    this.error,
    this.authenticatedAccount,
    required this.factories,
    this.totalNewFiles = 0,
    this.totalModifiedFiles = 0,
    this.totalUnchangedFiles = 0,
    this.events = const [],
  });

  int get totalActionableFiles => totalNewFiles + totalModifiedFiles;

  factory GoogleDriveScanResult.failure(String error) {
    return GoogleDriveScanResult(
      success: false,
      error: error,
      factories: const {},
    );
  }
}

/// Bridge service between Flutter and Google Drive (Supports 100% pure Dart GoogleDriveSyncService).
/// Responsible for:
/// 1. Scanning Google Drive factory folders for Excel files.
/// 2. Classifying files into NEW / UNCHANGED / MODIFIED against Drift SQLite input_files.
/// 3. Persisting/updating metadata in Drift SQLite input_files table.
/// 4. Emitting DriveFileChangeEvents for downstream pipelines.
class DriveBridgeService {
  static const MethodChannel _channel = MethodChannel('com.distillery.drive_bridge');
  final DatabaseService dbService;
  final GoogleDriveSyncService syncService;

  // StreamController for downstream pipeline triggers
  final _eventStreamController = StreamController<DriveFileChangeEvent>.broadcast();
  Stream<DriveFileChangeEvent> get onFileChangeEvent => _eventStreamController.stream;

  DriveBridgeService(this.dbService, [GoogleDriveSyncService? customSyncService])
      : syncService = customSyncService ?? GoogleDriveSyncService();

  void dispose() {
    _eventStreamController.close();
  }

  /// Classifies and persists a discovered file in Drift SQLite `input_files`.
  /// Returns the DetectedDriveFile with accurate classification and emits an event.
  Future<({DetectedDriveFile file, DriveFileChangeEvent event})> processAndClassifyFile({
    required String factoryCode,
    required int factoryId,
    required String driveFileId,
    required String fileName,
    String? mimeType,
    int? sizeBytes,
    String? createdTime,
    String? modifiedTime,
    String? md5Checksum,
    bool forceReingest = false,
  }) async {
    final now = DateTime.now().toUtc();
    final DateTime? rawParsedModified = modifiedTime != null ? DateTime.tryParse(modifiedTime)?.toUtc() : null;

    // 1. Query existing record in Drift SQLite before mutation
    final existingFile = await dbService.inputFiles.getFileByDriveId(factoryId, driveFileId);

    // 2. Canonical Normalization for Second Precision (matching SQLite storage resolution), Integer Size, and MD5
    final DateTime? normalizedCurrentTime = rawParsedModified != null
        ? DateTime.fromMillisecondsSinceEpoch((rawParsedModified.millisecondsSinceEpoch ~/ 1000) * 1000, isUtc: true)
        : null;
    final DateTime? normalizedStoredTime = existingFile?.driveModifiedAt != null
        ? DateTime.fromMillisecondsSinceEpoch((existingFile!.driveModifiedAt!.toUtc().millisecondsSinceEpoch ~/ 1000) * 1000, isUtc: true)
        : null;

    final int? currentEpochSec = normalizedCurrentTime != null ? (normalizedCurrentTime.millisecondsSinceEpoch ~/ 1000) : null;
    final int? storedEpochSec = normalizedStoredTime != null ? (normalizedStoredTime.millisecondsSinceEpoch ~/ 1000) : null;

    final int? currentSize = sizeBytes;
    final int? storedSize = existingFile?.fileSizeBytes?.toInt();

    final String? currentHash = md5Checksum?.trim().toLowerCase();
    final String? storedHash = existingFile?.fileHash?.trim().toLowerCase();

    // 3. Defensive Comparisons (NULL vs non-NULL or missing metadata does NOT trigger false MODIFIED)
    bool timeChanged = false;
    if (currentEpochSec != null && storedEpochSec != null) {
      timeChanged = (currentEpochSec != storedEpochSec);
    }

    bool sizeChanged = false;
    if (currentSize != null && storedSize != null) {
      sizeChanged = (currentSize != storedSize);
    }

    bool hashChanged = false;
    if (currentHash != null && currentHash.isNotEmpty &&
        storedHash != null && storedHash.isNotEmpty) {
      hashChanged = (currentHash != storedHash);
    }

    final isModified = timeChanged || sizeChanged || hashChanged;

    int dbId;
    String classification;
    FileChangeType changeType;
    bool isActionable;

    if (existingFile == null) {
      // -------------------------------------------------------------
      // CASE 1: Previously Unseen Drive File -> NEW
      // -------------------------------------------------------------
      classification = 'NEW';
      changeType = FileChangeType.newFile;
      isActionable = true;

      dbId = await dbService.inputFiles.insertFile(
        InputFilesCompanion.insert(
          factoryId: factoryId,
          driveFileId: driveFileId,
          fileName: fileName,
          fileType: Value(mimeType),
          fileSizeBytes: sizeBytes != null ? Value(BigInt.from(sizeBytes)) : const Value.absent(),
          driveModifiedAt: normalizedCurrentTime != null ? Value(normalizedCurrentTime) : const Value.absent(),
          fileHash: currentHash != null && currentHash.isNotEmpty ? Value(currentHash) : const Value.absent(),
          status: 'NEW',
          firstSeenAt: Value(now),
          lastSeenAt: Value(now),
        ),
      );
    } else {
      // -------------------------------------------------------------
      // CASE 2 & 3: File Exists in SQLite -> Evaluate Changes
      // -------------------------------------------------------------
      dbId = existingFile.id;

      if (forceReingest) {
        // Explicit force reingest request
        classification = 'NEW';
        changeType = FileChangeType.newFile;
        isActionable = true;

        await (dbService.db.update(dbService.db.inputFiles)..where((tbl) => tbl.id.equals(existingFile.id))).write(
          InputFilesCompanion(
            status: const Value('NEW'),
            lastSeenAt: Value(now),
          ),
        );
      } else if (isModified) {
        // CASE 2: File Modified in Drive -> MODIFIED (Update existing record)
        classification = 'MODIFIED';
        changeType = FileChangeType.modified;
        isActionable = true;

        await dbService.inputFiles.updateFileMetadata(
          id: existingFile.id,
          status: 'MODIFIED',
          fileName: fileName,
          fileType: mimeType,
          fileSizeBytes: currentSize != null ? BigInt.from(currentSize) : null,
          driveModifiedAt: normalizedCurrentTime,
          fileHash: currentHash,
          lastSeenAt: now,
        );
      } else if (existingFile.status == 'ERROR') {
        // CASE 2B: File previously failed processing -> RETRY as actionable NEW
        classification = 'NEW';
        changeType = FileChangeType.newFile;
        isActionable = true;

        await (dbService.db.update(dbService.db.inputFiles)..where((tbl) => tbl.id.equals(existingFile.id))).write(
          InputFilesCompanion(
            status: const Value('NEW'),
            lastSeenAt: Value(now),
          ),
        );
      } else {
        // CASE 3: File Unchanged -> UNCHANGED (Only update lastSeenAt & status)
        classification = 'UNCHANGED';
        changeType = FileChangeType.unchanged;
        isActionable = false;

        await (dbService.db.update(dbService.db.inputFiles)..where((tbl) => tbl.id.equals(existingFile.id))).write(
          InputFilesCompanion(
            status: const Value('UNCHANGED'),
            lastSeenAt: Value(now),
          ),
        );
      }
    }

    // Output Structured Debugging Block
    debugPrint('--------------------------------------------------');
    debugPrint('FILE CHANGE DEBUG');
    debugPrint('Factory: $factoryCode (ID: $factoryId)');
    debugPrint('File: $fileName');
    debugPrint('Drive ID: $driveFileId');
    debugPrint('--------------------------------------------------');
    debugPrint('CURRENT:');
    debugPrint('modifiedTime = $modifiedTime');
    debugPrint('normalizedTime = ${normalizedCurrentTime?.toIso8601String()}');
    debugPrint('size = $currentSize');
    debugPrint('md5 = $currentHash');
    debugPrint('');
    debugPrint('STORED:');
    debugPrint('modifiedTime = ${existingFile?.driveModifiedAt?.toIso8601String()}');
    debugPrint('normalizedTime = ${normalizedStoredTime?.toIso8601String()}');
    debugPrint('size = $storedSize');
    debugPrint('md5 = $storedHash');
    debugPrint('');
    debugPrint('COMPARISON:');
    debugPrint('timeChanged = $timeChanged');
    debugPrint('sizeChanged = $sizeChanged');
    debugPrint('hashChanged = $hashChanged');
    debugPrint('');
    debugPrint('RESULT:');
    debugPrint('$classification (DB ID: $dbId)');
    debugPrint('--------------------------------------------------');

    final event = DriveFileChangeEvent(
      factoryCode: factoryCode,
      factoryId: factoryId,
      dbFileId: dbId,
      driveFileId: driveFileId,
      fileName: fileName,
      changeType: changeType,
      isActionable: isActionable,
      sizeBytes: sizeBytes,
      driveModifiedAt: normalizedCurrentTime,
      timestamp: now,
    );

    _eventStreamController.add(event);

    final detectedFile = DetectedDriveFile(
      driveFileId: driveFileId,
      fileName: fileName,
      mimeType: mimeType,
      sizeBytes: sizeBytes,
      createdTime: createdTime,
      modifiedTime: modifiedTime,
      md5Checksum: currentHash,
      syncStatus: classification,
      dbFileId: dbId,
    );

    return (file: detectedFile, event: event);
  }

  /// Scans F01-F05 on Google Drive and syncs results to SQLite `input_files`.
  /// Supports pure Dart DriveApi execution as well as native fallback.
  Future<GoogleDriveScanResult> scanAndSyncFactoryFiles({
    required String accessToken,
    required List<FactoryData> factories,
    drive.DriveApi? driveApi,
    bool forceReingest = false,
  }) async {
    if (driveApi != null) {
      try {
        final rawSummaries = await syncService.scanFactoryFolders(
          driveApi: driveApi,
          factories: factories,
        );

        final Map<String, FactoryScanSummary> summaryMap = {};
        final List<DriveFileChangeEvent> allEvents = [];
        var newCount = 0;
        var modifiedCount = 0;
        var unchangedCount = 0;

        for (final entry in rawSummaries.entries) {
          final factoryCode = entry.key;
          final summary = entry.value;
          final List<DetectedDriveFile> classifiedFiles = [];

          for (final f in summary.files) {
            final result = await processAndClassifyFile(
              factoryCode: factoryCode,
              factoryId: summary.factoryId,
              driveFileId: f.driveFileId,
              fileName: f.fileName,
              mimeType: f.mimeType,
              sizeBytes: f.sizeBytes,
              createdTime: f.createdTime,
              modifiedTime: f.modifiedTime,
              md5Checksum: f.md5Checksum,
              forceReingest: forceReingest,
            );

            classifiedFiles.add(result.file);
            allEvents.add(result.event);

            if (result.file.syncStatus == 'NEW') {
              newCount++;
            } else if (result.file.syncStatus == 'MODIFIED') {
              modifiedCount++;
            } else if (result.file.syncStatus == 'UNCHANGED') {
              unchangedCount++;
            }
          }

          summaryMap[factoryCode] = FactoryScanSummary(
            factoryCode: factoryCode,
            factoryId: summary.factoryId,
            folderId: summary.folderId,
            status: summary.status,
            statusCode: summary.statusCode,
            diagnosticMessage: summary.diagnosticMessage,
            totalItemsInFolder: summary.totalItemsInFolder,
            errorMessage: summary.errorMessage,
            files: classifiedFiles,
          );
        }

        return GoogleDriveScanResult(
          success: true,
          authenticatedAccount: 'Google Drive Account',
          factories: summaryMap,
          totalNewFiles: newCount,
          totalModifiedFiles: modifiedCount,
          totalUnchangedFiles: unchangedCount,
          events: allEvents,
        );
      } catch (e) {
        return GoogleDriveScanResult.failure('Pure Dart Google Drive scan exception: $e');
      }
    }

    if (accessToken.isEmpty) {
      return GoogleDriveScanResult.failure('Access token is empty. User must be signed in.');
    }

    try {
      final factoriesPayload = jsonEncode(factories.map((f) => {
        'id': f.id,
        'code': f.factoryCode,
        'folder_id': f.driveFolderId,
      }).toList());

      final dynamic rawOutput = await _channel.invokeMethod('scanFactoryFiles', {
        'accessToken': accessToken,
        'factoriesJson': factoriesPayload,
      });

      if (rawOutput == null) {
        return GoogleDriveScanResult.failure('MethodChannel returned null.');
      }

      final Map<String, dynamic> jsonResponse = jsonDecode(rawOutput as String);
      final bool isSuccess = jsonResponse['success'] == true;

      if (!isSuccess) {
        return GoogleDriveScanResult.failure(jsonResponse['error']?.toString() ?? 'Unknown error');
      }

      final authAccount = jsonResponse['authenticated_account'] as String?;
      final Map<String, dynamic> rawFactories = jsonResponse['factories'] as Map<String, dynamic>? ?? {};
      final Map<String, FactoryScanSummary> summaryMap = {};
      final List<DriveFileChangeEvent> allEvents = [];

      var newCount = 0;
      var modifiedCount = 0;
      var unchangedCount = 0;

      for (final entry in rawFactories.entries) {
        final factoryCode = entry.key;
        final factoryData = entry.value as Map<String, dynamic>;
        final factoryId = factoryData['factory_id'] as int? ?? 0;
        final folderId = factoryData['folder_id'] as String?;
        final status = factoryData['status'] as String? ?? 'UNKNOWN';
        final statusCode = factoryData['status_code'] as String? ?? status;
        final diagMsg = factoryData['diagnostic_message'] as String?;
        final totalItems = factoryData['total_items'] as int? ?? 0;
        final error = factoryData['error'] as String?;
        final List<dynamic> rawFiles = factoryData['files'] as List<dynamic>? ?? [];

        final List<DetectedDriveFile> detectedFiles = [];

        for (final fileItem in rawFiles) {
          final f = fileItem as Map<String, dynamic>;
          final driveFileId = f['drive_file_id'] as String;
          final fileName = f['file_name'] as String;
          final mimeType = f['mime_type'] as String?;
          final sizeBytes = f['size_bytes'] as int?;
          final createdTime = f['created_time'] as String?;
          final modifiedTime = f['modified_time'] as String?;

          final result = await processAndClassifyFile(
            factoryCode: factoryCode,
            factoryId: factoryId,
            driveFileId: driveFileId,
            fileName: fileName,
            mimeType: mimeType,
            sizeBytes: sizeBytes,
            createdTime: createdTime,
            modifiedTime: modifiedTime,
            forceReingest: forceReingest,
          );

          detectedFiles.add(result.file);
          allEvents.add(result.event);

          if (result.file.syncStatus == 'NEW') {
            newCount++;
          } else if (result.file.syncStatus == 'MODIFIED') {
            modifiedCount++;
          } else if (result.file.syncStatus == 'UNCHANGED') {
            unchangedCount++;
          }
        }

        summaryMap[factoryCode] = FactoryScanSummary(
          factoryCode: factoryCode,
          factoryId: factoryId,
          folderId: folderId,
          status: status,
          statusCode: statusCode,
          diagnosticMessage: diagMsg,
          totalItemsInFolder: totalItems,
          errorMessage: error,
          files: detectedFiles,
        );
      }

      return GoogleDriveScanResult(
        success: true,
        authenticatedAccount: authAccount,
        factories: summaryMap,
        totalNewFiles: newCount,
        totalModifiedFiles: modifiedCount,
        totalUnchangedFiles: unchangedCount,
        events: allEvents,
      );

    } on PlatformException catch (pe) {
      return GoogleDriveScanResult.failure('MethodChannel Error: ${pe.message} (${pe.details})');
    } catch (e) {
      return GoogleDriveScanResult.failure('Scan exception: $e');
    }
  }

  /// Downloads an Excel file from Google Drive to a local private path using pure Dart or native bridge.
  Future<DriveDownloadResult> downloadDriveFile({
    required String accessToken,
    required String driveFileId,
    required String destinationPath,
    drive.DriveApi? driveApi,
  }) async {
    if (driveApi != null) {
      final res = await syncService.downloadFile(
        driveApi: driveApi,
        driveFileId: driveFileId,
        destinationPath: destinationPath,
      );
      if (res.success) {
        return DriveDownloadResult(
          success: true,
          driveFileId: driveFileId,
          fileName: destinationPath.split(Platform.pathSeparator).last,
          localPath: destinationPath,
          sizeBytes: res.sizeBytes,
        );
      } else {
        return DriveDownloadResult.failure(res.error ?? 'Download failed');
      }
    }

    if (accessToken.isEmpty) {
      return DriveDownloadResult.failure('Access token is empty.');
    }
    if (driveFileId.isEmpty) {
      return DriveDownloadResult.failure('driveFileId is empty.');
    }

    try {
      final dynamic rawOutput = await _channel.invokeMethod('downloadExcelFile', {
        'accessToken': accessToken,
        'driveFileId': driveFileId,
        'destinationPath': destinationPath,
      });

      if (rawOutput == null) {
        return DriveDownloadResult.failure('MethodChannel returned null.');
      }

      final Map<String, dynamic> jsonResponse = jsonDecode(rawOutput as String);
      final bool isSuccess = jsonResponse['success'] == true;

      if (!isSuccess) {
        return DriveDownloadResult.failure(jsonResponse['error']?.toString() ?? 'Unknown download error');
      }

      return DriveDownloadResult(
        success: true,
        driveFileId: jsonResponse['drive_file_id'] as String? ?? driveFileId,
        fileName: jsonResponse['file_name'] as String? ?? '',
        localPath: jsonResponse['local_path'] as String? ?? destinationPath,
        sizeBytes: jsonResponse['size_bytes'] as int? ?? 0,
        md5Checksum: jsonResponse['md5_checksum'] as String?,
      );
    } on PlatformException catch (pe) {
      return DriveDownloadResult.failure('MethodChannel Error: ${pe.message} (${pe.details})');
    } catch (e) {
      return DriveDownloadResult.failure('Download exception: $e');
    }
  }
}

/// Result of downloading a file from Google Drive via Python bridge.
class DriveDownloadResult {
  final bool success;
  final String? driveFileId;
  final String? fileName;
  final String? localPath;
  final int? sizeBytes;
  final String? md5Checksum;
  final String? error;

  const DriveDownloadResult({
    required this.success,
    this.driveFileId,
    this.fileName,
    this.localPath,
    this.sizeBytes,
    this.md5Checksum,
    this.error,
  });

  factory DriveDownloadResult.failure(String error) =>
      DriveDownloadResult(success: false, error: error);
}
