import 'dart:convert';
import 'dart:io';
import 'package:excel/excel.dart' as excel;
import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:http/http.dart' as http;
import 'package:distillary/database/database.dart';
import 'package:distillary/services/database_service.dart';
import 'package:distillary/services/distillery_background_worker.dart';
import 'package:distillary/services/distillery_service.dart';
import 'package:distillary/services/factory_database_manager.dart';
import 'package:distillary/services/google_drive_sync_service.dart';

/// Mock HTTP Client that returns Drive API responses for testing
class MockDriveHttpClient extends http.BaseClient {
  final Map<String, List<Map<String, dynamic>>> folderFiles;
  bool isOnline;
  String? failingFolderId;

  MockDriveHttpClient({
    required this.folderFiles,
    this.isOnline = true,
    this.failingFolderId,
  });

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    if (!isOnline) {
      throw http.ClientException('Network is unreachable (Mock Offline)');
    }

    final uri = request.url;
    if (uri.path.contains('/files') && request.method == 'GET') {
      if (uri.queryParameters['alt'] == 'media') {
        final excelDoc = excel.Excel.createExcel();
        final sheet = excelDoc['Sheet1'];
        sheet.appendRow([
          excel.TextCellValue('Timestamp'),
          excel.TextCellValue('Batch ID'),
          excel.TextCellValue('Temperature'),
          excel.TextCellValue('Brix'),
          excel.TextCellValue('Sugar Consumption Rate'),
        ]);
        sheet.appendRow([
          excel.TextCellValue('2026-08-19 06:00:00'),
          excel.TextCellValue('BATCH-01'),
          excel.DoubleCellValue(32.5),
          excel.DoubleCellValue(14.5),
          excel.DoubleCellValue(0.85),
        ]);
        final bytes = excelDoc.encode() ?? [];
        return http.StreamedResponse(
          Stream.value(bytes),
          200,
          headers: {'content-type': 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'},
        );
      }

      // List files in folder
      final query = uri.queryParameters['q'] ?? '';
      String folderId = '';
      final match = RegExp(r"'([^']+)' in parents").firstMatch(query);
      if (match != null) {
        folderId = match.group(1)!;
      }

      if (failingFolderId != null && folderId == failingFolderId) {
        throw http.ClientException('Simulated Google Drive API 500 Server Error for folder $folderId');
      }

      final files = folderFiles[folderId] ?? [];
      final jsonResponse = {
        'kind': 'drive#fileList',
        'files': files,
      };

      final bodyBytes = utf8.encode(json.encode(jsonResponse));
      return http.StreamedResponse(
        Stream.value(bodyBytes),
        200,
        headers: {'content-type': 'application/json; charset=UTF-8'},
      );
    }

    return http.StreamedResponse(Stream.value([]), 404);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory tempDir;
  late FactoryDatabaseManager factoryManager;
  late Map<String, DatabaseService> plantDbs;
  late DistilleryService distilleryService;
  late MockDriveHttpClient mockHttpClient;
  late drive.DriveApi mockDriveApi;

  setUp(() async {
    DistilleryBackgroundWorker.resetSyncLock();
    tempDir = await Directory.systemTemp.createTemp('bg_worker_test_');
    plantDbs = {};

    for (final plant in FactoryDatabaseManager.supportedPlants) {
      final file = File('${tempDir.path}/${plant.dbFileName}');
      final db = AppDatabase(NativeDatabase(file));
      final dbService = DatabaseService(db);
      plantDbs[plant.code] = dbService;
    }

    factoryManager = FactoryDatabaseManager(initialDatabases: plantDbs);
    await factoryManager.initializeAll();

    mockHttpClient = MockDriveHttpClient(
      isOnline: true,
      failingFolderId: null,
      folderFiles: {
        '1n90IQFqwcuv1QpWp65KF2yfN4-3t_SoT': [
          {
            'id': 'F01_DRIVE_01',
            'name': '1.xlsx',
            'mimeType': 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
            'size': '16548',
            'modifiedTime': '2026-08-19T05:00:00.000Z',
            'md5Checksum': 'md5_f01_v1',
          }
        ],
        '1uQcrPhoKxQ-YMyvKq0FIZu0ONd8uwGih': [
          {
            'id': 'F02_DRIVE_01',
            'name': 'Sankili_Data.xlsx',
            'mimeType': 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
            'size': '230185',
            'modifiedTime': '2026-08-19T05:00:00.000Z',
            'md5Checksum': 'md5_f02_v1',
          }
        ],
        '1DGSzzkkw_aC77xHpbnx9rMHQK3qCo1Gt': [
          {
            'id': 'F03_DRIVE_01',
            'name': 'Nellikuppam_Data.xlsx',
            'mimeType': 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
            'size': '60577',
            'modifiedTime': '2026-08-19T05:00:00.000Z',
            'md5Checksum': 'md5_f03_v1',
          }
        ],
        '1VrcVW_GnNvwA-m5fyc7ClxoYsp3bnbeI': [
          {
            'id': 'F04_DRIVE_01',
            'name': 'Sivagangai_Data.xlsx',
            'mimeType': 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
            'size': '60354',
            'modifiedTime': '2026-08-19T05:00:00.000Z',
            'md5Checksum': 'md5_f04_v1',
          }
        ],
        '1G-C6TPduJ8LCoAJq3L-TaQvlZ5rkexHX': [
          {
            'id': 'F05_DRIVE_01',
            'name': 'Bagalkot_Data.xlsx',
            'mimeType': 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
            'size': '60240',
            'modifiedTime': '2026-08-19T05:00:00.000Z',
            'md5Checksum': 'md5_f05_v1',
          }
        ],
      },
    );

    mockDriveApi = drive.DriveApi(mockHttpClient);
    distilleryService = DistilleryService(
      factoryManager: factoryManager,
      syncService: GoogleDriveSyncService(),
    );
  });

  tearDown(() async {
    DistilleryBackgroundWorker.resetSyncLock();
    await factoryManager.closeAll();
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  group('STEP 6 â€” Android Continuous Background Execution Tests', () {
    test('TEST A: Worker starts successfully and executes cycle', () async {
      final worker = DistilleryBackgroundWorker(distilleryService: distilleryService);
      final report = await worker.runFullSyncCycle(driveApiOverride: mockDriveApi);

      expect(report.success, isTrue);
      expect(report.requiresRetry, isFalse);
      expect(report.factoriesProcessed, equals(5));
      expect(report.factoriesSucceeded, equals(5));
      expect(report.totalNewFiles, equals(5));
    });

    test('TEST B: Network available -> Drive scan runs across all 5 plants', () async {
      final worker = DistilleryBackgroundWorker(distilleryService: distilleryService);
      final report = await worker.runFullSyncCycle(driveApiOverride: mockDriveApi);

      expect(report.totalNewFiles, equals(5));
      for (final plant in FactoryDatabaseManager.supportedPlants) {
        expect(report.factoryStatuses.containsKey(plant.code), isTrue);
      }
    });

    test('TEST C: Network unavailable -> Graceful error handling and retry request', () async {
      mockHttpClient.isOnline = false;
      try {
        final worker = DistilleryBackgroundWorker(distilleryService: distilleryService);
        final report = await worker.runFullSyncCycle(driveApiOverride: mockDriveApi);

        // Fault isolation handles plant errors cleanly
        expect(report.factoriesSucceeded, equals(0));
        for (final plant in FactoryDatabaseManager.supportedPlants) {
          expect(report.factoryStatuses[plant.code]?.contains('FAILED'), isTrue);
        }
      } finally {
        mockHttpClient.isOnline = true;
      }
    });

    test('TEST D: Fault isolation: F01 succeeds while F02 throws error -> F03-F05 continue', () async {
      // Simulate F02 folder failure
      mockHttpClient.failingFolderId = '1uQcrPhoKxQ-YMyvKq0FIZu0ONd8uwGih';

      try {
        final worker = DistilleryBackgroundWorker(distilleryService: distilleryService);
        final report = await worker.runFullSyncCycle(driveApiOverride: mockDriveApi);

        expect(report.factoryStatuses['F01']?.contains('SUCCESS'), isTrue);
        expect(report.factoryStatuses['F02']?.contains('FAILED'), isTrue);
        expect(report.factoryStatuses['F03']?.contains('SUCCESS'), isTrue);
        expect(report.factoryStatuses['F04']?.contains('SUCCESS'), isTrue);
        expect(report.factoryStatuses['F05']?.contains('SUCCESS'), isTrue);
        expect(report.factoriesSucceeded, equals(4)); // F01, F03, F04, F05 succeeded
      } finally {
        mockHttpClient.failingFolderId = null;
      }
    });

    test('TEST E & F: Scan 1 is NEW, Scan 2 is UNCHANGED (No duplicate ingestion)', () async {
      final worker = DistilleryBackgroundWorker(distilleryService: distilleryService);

      // Cycle 1: NEW files detected and ingested
      final report1 = await worker.runFullSyncCycle(driveApiOverride: mockDriveApi);
      expect(report1.totalNewFiles, equals(5));
      expect(report1.totalUnchangedFiles, equals(0));
      expect(report1.totalRecordsInserted, equals(5)); // 1 record per plant Excel

      // Cycle 2: UNCHANGED files detected (no modifications)
      final report2 = await worker.runFullSyncCycle(driveApiOverride: mockDriveApi);
      expect(report2.totalNewFiles, equals(0));
      expect(report2.totalModifiedFiles, equals(0));
      expect(report2.totalUnchangedFiles, equals(5));
      expect(report2.totalRecordsInserted, equals(0)); // Zero duplicate rows
    });

    test('TEST G: MODIFIED file triggers actionable detection', () async {
      final worker = DistilleryBackgroundWorker(distilleryService: distilleryService);

      // Cycle 1 baseline
      await worker.runFullSyncCycle(driveApiOverride: mockDriveApi);

      // Update F01 file metadata (Simulate modification in Drive)
      mockHttpClient.folderFiles['1n90IQFqwcuv1QpWp65KF2yfN4-3t_SoT'] = [
        {
          'id': 'F01_DRIVE_01',
          'name': '1.xlsx',
          'mimeType': 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
          'size': '18000', // Changed size
          'modifiedTime': '2026-08-19T09:00:00.000Z', // Changed time
          'md5Checksum': 'md5_f01_v2', // Changed hash
        }
      ];

      // Cycle 2: F01 must be MODIFIED, F02-F05 must be UNCHANGED
      final report2 = await worker.runFullSyncCycle(driveApiOverride: mockDriveApi);
      expect(report2.totalModifiedFiles, equals(1));
      expect(report2.totalUnchangedFiles, equals(4));
      expect(report2.totalRecordsInserted, equals(1)); // Only F01 re-ingested
    });

    test('TEST H & I: Concurrency Lock prevents overlapping executions', () async {
      final worker = DistilleryBackgroundWorker(distilleryService: distilleryService);

      // Start two executions concurrently
      final future1 = worker.runFullSyncCycle(driveApiOverride: mockDriveApi);
      final future2 = worker.runFullSyncCycle(driveApiOverride: mockDriveApi);

      final results = await Future.wait([future1, future2]);

      // Exactly one should proceed and one should be safely skipped via concurrency lock
      final skippedCount = results.where((r) => r.errorMessage?.contains('concurrent sync lock') ?? false).length;
      final completedCount = results.where((r) => r.errorMessage == null).length;

      expect(skippedCount, equals(1));
      expect(completedCount, equals(1));
    });

    test('TEST J: Correct F01-F05 dedicated database routing and isolation', () async {
      final worker = DistilleryBackgroundWorker(distilleryService: distilleryService);
      await worker.runFullSyncCycle(driveApiOverride: mockDriveApi);

      for (final plant in FactoryDatabaseManager.supportedPlants) {
        final dbService = plantDbs[plant.code]!;
        final files = await dbService.inputFiles.getAllFiles();
        expect(files.length, equals(1));
        expect(files.first.driveFileId, startsWith(plant.code));

        final data = await dbService.preprocessingData.getAllRecords();
        expect(data.length, equals(1));
      }
    });

    test('TEST K: Stale RUNNING processing recovery', () async {
      final f01Db = plantDbs['F01']!;
      final f01Record = (await f01Db.factories.getFactoryByCode('F01'))!;

      final fileId = await f01Db.inputFiles.insertFile(
        InputFilesCompanion.insert(
          factoryId: f01Record.id,
          driveFileId: 'STALE_DRIVE_01',
          fileName: 'StaleTest.xlsx',
          status: 'PENDING',
        ),
      );

      // Insert a simulated RUNNING run started 30 minutes ago (stale)
      final staleRunId = await f01Db.processingRuns.insertRun(
        ProcessingRunsCompanion.insert(
          inputFileId: fileId,
          status: 'RUNNING',
          startedAt: Value(DateTime.now().toUtc().subtract(const Duration(minutes: 30))),
        ),
      );

      // Run stale recovery
      final recoveredCount = await f01Db.processingRuns.recoverStaleRunningRuns(
        staleThreshold: const Duration(minutes: 15),
      );

      expect(recoveredCount, equals(1));
      final updatedRuns = await f01Db.processingRuns.getAllRuns();
      final recoveredRun = updatedRuns.firstWhere((r) => r.id == staleRunId);
      expect(recoveredRun.status, equals('FAILED'));
      expect(recoveredRun.errorMessage, contains('stale timeout recovery'));
    });

    test('TEST L: Worker can be initialized after process restart', () async {
      await factoryManager.closeAll();

      // Simulate new app process lifecycle
      final newPlantDbs = <String, DatabaseService>{};
      for (final plant in FactoryDatabaseManager.supportedPlants) {
        final file = File('${tempDir.path}/${plant.dbFileName}');
        final db = AppDatabase(NativeDatabase(file));
        newPlantDbs[plant.code] = DatabaseService(db);
      }

      final newFactoryManager = FactoryDatabaseManager(initialDatabases: newPlantDbs);
      final newDistilleryService = DistilleryService(factoryManager: newFactoryManager);
      final newWorker = DistilleryBackgroundWorker(distilleryService: newDistilleryService);

      final report = await newWorker.runFullSyncCycle(driveApiOverride: mockDriveApi);
      expect(report.success, isTrue);
      expect(report.factoriesProcessed, equals(5));

      await newFactoryManager.closeAll();
    });
  });
}

