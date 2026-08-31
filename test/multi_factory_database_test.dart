import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:excel/excel.dart';
import 'package:distillary/database/database.dart' hide isNull, isNotNull;
import 'package:distillary/services/backup_service.dart';
import 'package:distillary/services/database_service.dart';
import 'package:distillary/services/drive_bridge_service.dart';
import 'package:distillary/services/excel_ingestion_service.dart';
import 'package:distillary/services/factory_database_manager.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;
  late FactoryDatabaseManager factoryManager;
  late Map<String, AppDatabase> databases;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('multi_factory_test_');
    databases = {};
    final customServices = <String, DatabaseService>{};

    for (final plant in FactoryDatabaseManager.supportedPlants) {
      final file = File('${tempDir.path}/${plant.dbFileName}');
      final db = AppDatabase(NativeDatabase(file));
      databases[plant.code] = db;
      customServices[plant.code] = DatabaseService(db, BackupService(db));
    }

    factoryManager = FactoryDatabaseManager(initialDatabases: customServices);
    await factoryManager.initializeAll();
  });

  tearDown(() async {
    for (final db in databases.values) {
      await db.close();
    }
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  group('Multi-Factory 5 Dedicated Databases Verification', () {
    test('1. Verify all 5 plant databases are created with 9 tables and FK integrity', () async {
      expect(factoryManager.plants.length, equals(5));

      final plantCodes = ['F01', 'F02', 'F03', 'F04', 'F05'];
      final expectedNames = ['Haliyal', 'Sankili', 'Nellikuppam', 'Sivagangai', 'Bagalkot'];
      final expectedDbFiles = ['haliyal.db', 'sankili.db', 'nellikuppam.db', 'sivagangai.db', 'bagalkot.db'];

      for (int i = 0; i < plantCodes.length; i++) {
        final code = plantCodes[i];
        final name = expectedNames[i];
        final dbName = expectedDbFiles[i];

        final plant = factoryManager.plants.firstWhere((p) => p.code == code);
        expect(plant.name, equals(name));
        expect(plant.dbFileName, equals(dbName));

        final dbService = factoryManager.getDatabaseForPlant(code);

        // Check 9 tables exist
        final tables = await dbService.db.customSelect(
          "SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%';",
        ).get();
        expect(tables.length, equals(9));

        // Check PRAGMA integrity
        final integrity = await dbService.db.customSelect('PRAGMA integrity_check;').getSingle();
        expect(integrity.data['integrity_check'], equals('ok'));

        // Check PRAGMA foreign_key_check
        final fkViolations = await dbService.db.customSelect('PRAGMA foreign_key_check;').get();
        expect(fkViolations, isEmpty);

        // Verify seeded factory record in that specific plant DB
        final factories = await dbService.factories.getAllFactories();
        expect(factories.length, equals(1));
        expect(factories.first.factoryCode, equals(code));
        expect(factories.first.factoryName, contains(name));
      }
    });

    test('2. Verify strict database isolation (Haliyal vs Sankili vs Bagalkot)', () async {
      final haliyalDb = factoryManager.getDatabaseForPlant('F01');
      final sankiliDb = factoryManager.getDatabaseForPlant('F02');
      final bagalkotDb = factoryManager.getDatabaseForPlant('F05');

      // Insert input file only in Haliyal DB
      final haliyalFileId = await haliyalDb.inputFiles.insertFile(
        InputFilesCompanion.insert(
          factoryId: 1,
          driveFileId: 'DRIVE_HALIYAL_01',
          fileName: 'Haliyal_Data.xlsx',
          status: 'PROCESSED',
        ),
      );
      expect(haliyalFileId, isPositive);

      // Verify record exists in Haliyal
      final haliyalFiles = await haliyalDb.inputFiles.getAllFiles();
      expect(haliyalFiles.length, equals(1));
      expect(haliyalFiles.first.fileName, equals('Haliyal_Data.xlsx'));

      // Verify Sankili and Bagalkot databases remain completely empty
      final sankiliFiles = await sankiliDb.inputFiles.getAllFiles();
      expect(sankiliFiles, isEmpty);

      final bagalkotFiles = await bagalkotDb.inputFiles.getAllFiles();
      expect(bagalkotFiles, isEmpty);
    });

    test('3. Verify active plant switching in FactoryDatabaseManager', () {
      expect(factoryManager.activePlantCode, equals('F01'));
      expect(factoryManager.activePlant.name, equals('Haliyal'));

      factoryManager.setActivePlant('F03');
      expect(factoryManager.activePlantCode, equals('F03'));
      expect(factoryManager.activePlant.name, equals('Nellikuppam'));
      expect(factoryManager.activePlant.dbFileName, equals('nellikuppam.db'));

      factoryManager.setActivePlant('F04');
      expect(factoryManager.activePlantCode, equals('F04'));
      expect(factoryManager.activePlant.name, equals('Sivagangai'));
      expect(factoryManager.activePlant.dbFileName, equals('sivagangai.db'));
    });

    test('4. Verify independent Excel ingestion into Nellikuppam (F03) database', () async {
      final nellikuppamService = factoryManager.getDatabaseForPlant('F03');
      final bridge = DriveBridgeService(nellikuppamService);
      final ingestion = ExcelIngestionService(
        dbService: nellikuppamService,
        driveBridgeService: bridge,
        customTempDir: tempDir,
      );

      // Create a test Excel file
      final excel = Excel.createExcel();
      final sheet = excel[excel.getDefaultSheet() ?? 'Sheet1'];
      sheet.appendRow([
        TextCellValue('Timestamp'),
        TextCellValue('Batch ID'),
        TextCellValue('Temperature'),
        TextCellValue('Brix'),
        TextCellValue('Sugar Consumption Rate'),
      ]);
      sheet.appendRow([
        TextCellValue('2026-08-18T10:00:00.000Z'),
        TextCellValue('BATCH_NEL_01'),
        DoubleCellValue(33.5),
        DoubleCellValue(14.8),
        DoubleCellValue(0.52),
      ]);

      final localFile = File('${tempDir.path}/nellikuppam.xlsx');
      await localFile.writeAsBytes(excel.encode()!);

      final result = await ingestion.ingestSingleFile(
        accessToken: 'dummy_token',
        factoryCode: 'F03',
        factoryId: 1,
        driveFileId: 'DRIVE_NEL_FILE_1',
        fileName: 'nellikuppam.xlsx',
        existingLocalFile: localFile,
        deleteAfterIngestion: false,
      );

      expect(result.success, isTrue);
      expect(result.recordsInserted, equals(1));

      // Verify Nellikuppam DB has the records
      final runs = await nellikuppamService.processingRuns.getAllRuns();
      expect(runs.length, equals(1));
      expect(runs.first.status, equals('SUCCESS'));

      final preproc = await nellikuppamService.db.select(nellikuppamService.db.preprocessingData).get();
      expect(preproc.length, equals(1));
      expect(preproc.first.temperature, equals(33.5));
      expect(preproc.first.brix, equals(14.8));

      // Verify Haliyal DB has 0 records
      final haliyalDb = factoryManager.getDatabaseForPlant('F01');
      final haliyalRuns = await haliyalDb.processingRuns.getAllRuns();
      expect(haliyalRuns, isEmpty);

      ingestion.dispose();
      bridge.dispose();
    });
  });
}

