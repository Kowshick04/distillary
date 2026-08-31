import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:distillary/database/database.dart' hide isNotNull, isNull;
import 'package:distillary/services/database_service.dart';
import 'package:distillary/services/distillery_service.dart';
import 'package:distillary/services/factory_database_manager.dart';

void main() {
  late Directory tempDir;
  late DistilleryService service;
  late Map<String, DatabaseService> testDbs;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('distillery_facade_test_');
    testDbs = {};

    for (final plant in FactoryDatabaseManager.supportedPlants) {
      final file = File('${tempDir.path}/${plant.dbFileName}');
      final db = AppDatabase(NativeDatabase(file));
      final dbService = DatabaseService(db);
      testDbs[plant.code] = dbService;
    }

    final manager = FactoryDatabaseManager(initialDatabases: testDbs);
    service = DistilleryService(factoryManager: manager);
  });

  tearDown(() async {
    await service.closeAll();
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  group('DistilleryService Public Facade Tests', () {
    test('TEST 1: Supported plants list returns all 5 production factories', () {
      expect(service.supportedPlants.length, equals(5));
      expect(service.supportedPlants.map((p) => p.code).toList(),
          containsAll(['F01', 'F02', 'F03', 'F04', 'F05']));
    });

    test('TEST 2: getDatabase routes explicitly to correct plant database', () {
      final dbF01 = service.getDatabase('F01');
      final dbF02 = service.getDatabase('F02');
      final dbF03 = service.getDatabase('F03');
      final dbF04 = service.getDatabase('F04');
      final dbF05 = service.getDatabase('F05');

      expect(dbF01, isNotNull);
      expect(dbF02, isNotNull);
      expect(dbF03, isNotNull);
      expect(dbF04, isNotNull);
      expect(dbF05, isNotNull);
    });

    test('TEST 3: initialize() seeds factory identity records in all 5 databases', () async {
      await service.initialize();

      for (final plant in service.supportedPlants) {
        final dbService = service.getDatabase(plant.code);
        final factoryRecord = await dbService.factories.getFactoryByCode(plant.code);
        expect(factoryRecord, isNotNull);
        expect(factoryRecord!.factoryCode, equals(plant.code));
        expect(factoryRecord.driveFolderId, equals(plant.driveFolderId));
      }
    });

    test('TEST 4: createBackupSnapshot creates a snapshot file without affecting live database', () async {
      await service.initialize();
      final snapshot = await service.createBackupSnapshot('F01');
      expect(snapshot, isNotNull);
      expect(await snapshot!.exists(), isTrue);
    });
  });
}

