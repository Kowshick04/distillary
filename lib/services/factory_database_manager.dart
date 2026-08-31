import 'package:flutter/foundation.dart';
import '../database/database.dart';
import 'backup_service.dart';
import 'database_service.dart';
import 'real_google_drive_backup_client.dart';

/// Metadata definition for each of the 5 distillery plants.
class PlantFactoryInfo {
  final String code;
  final String name;
  final String dbFileName;
  final String driveFolderId;
  final String backupFolderId;
  final String stateRegion;

  const PlantFactoryInfo({
    required this.code,
    required this.name,
    required this.dbFileName,
    required this.driveFolderId,
    this.backupFolderId = '',
    required this.stateRegion,
  });

  String get displayName => '$name ($code)';

  @override
  String toString() => '$displayName -> $dbFileName';
}

/// Central manager orchestrating 5 dedicated SQLite databases for:
/// 1. Haliyal (haliyal.db)
/// 2. Sankili (sankili.db)
/// 3. Nellikuppam (nellikuppam.db)
/// 4. Sivagangai (sivagangai.db)
/// 5. Bagalkot (bagalkot.db)
class FactoryDatabaseManager extends ChangeNotifier {
  static const List<PlantFactoryInfo> supportedPlants = [
    PlantFactoryInfo(
      code: 'F01',
      name: 'Haliyal',
      dbFileName: 'haliyal.db',
      driveFolderId: '1n90IQFqwcuv1QpWp65KF2yfN4-3t_SoT',
      backupFolderId: '1CO1Pki8RYmINwVfMCb5VqJhM-jgOnWi2',
      stateRegion: 'Karnataka',
    ),
    PlantFactoryInfo(
      code: 'F02',
      name: 'Sankili',
      dbFileName: 'sankili.db',
      driveFolderId: '1uQcrPhoKxQ-YMyvKq0FIZu0ONd8uwGih',
      backupFolderId: '1Y_M_DqYC1UyBrmC_kOnTAESAuaOSEt0k',
      stateRegion: 'Andhra Pradesh',
    ),
    PlantFactoryInfo(
      code: 'F03',
      name: 'Nellikuppam',
      dbFileName: 'nellikuppam.db',
      driveFolderId: '1DGSzzkkw_aC77xHpbnx9rMHQK3qCo1Gt',
      backupFolderId: '1xOx6x3-4o-nkKvgRyETPwy00aLC-Bm3m',
      stateRegion: 'Tamil Nadu',
    ),
    PlantFactoryInfo(
      code: 'F04',
      name: 'Sivagangai',
      dbFileName: 'sivagangai.db',
      driveFolderId: '1VrcVW_GnNvwA-m5fyc7ClxoYsp3bnbeI',
      backupFolderId: '1652ElcOUK2YoqhC37LAHMpJmYlBG5B_I',
      stateRegion: 'Tamil Nadu',
    ),
    PlantFactoryInfo(
      code: 'F05',
      name: 'Bagalkot',
      dbFileName: 'bagalkot.db',
      driveFolderId: '1G-C6TPduJ8LCoAJq3L-TaQvlZ5rkexHX',
      backupFolderId: '1922Z7O-VQs-6IdtUgF9Mqi-VvJW3_4D8',
      stateRegion: 'Karnataka',
    ),
  ];

  final RealGoogleDriveBackupClient? driveClient;
  final Map<String, DatabaseService> _databases = {};
  String _activePlantCode = 'F01'; // Default active plant is Haliyal (F01)

  FactoryDatabaseManager({
    this.driveClient,
    Map<String, DatabaseService>? initialDatabases,
  }) {
    if (initialDatabases != null) {
      _databases.addAll(initialDatabases);
    }
  }

  /// All supported plant configurations.
  List<PlantFactoryInfo> get plants => supportedPlants;

  /// Currently selected plant code.
  String get activePlantCode => _activePlantCode;

  /// Currently selected plant information.
  PlantFactoryInfo get activePlant =>
      supportedPlants.firstWhere((p) => p.code == _activePlantCode, orElse: () => supportedPlants.first);

  /// Database service instance for the currently active plant.
  DatabaseService get activeDatabase => getDatabaseForPlant(_activePlantCode);

  /// Map of all initialized plant databases.
  Map<String, DatabaseService> get allDatabases => Map.unmodifiable(_databases);

  /// Retrieves the dedicated DatabaseService for a specific factory code.
  DatabaseService getDatabaseForPlant(String factoryCode) {
    if (!_databases.containsKey(factoryCode)) {
      final plant = supportedPlants.firstWhere(
        (p) => p.code == factoryCode,
        orElse: () => throw ArgumentError('Unknown factory code: $factoryCode'),
      );

      final db = AppDatabase.named(plant.dbFileName);
      final service = DatabaseService(
        db,
        BackupService(db, driveClient: driveClient),
      );
      _databases[factoryCode] = service;
    }
    return _databases[factoryCode]!;
  }

  /// Changes the active plant in the UI.
  void setActivePlant(String factoryCode) {
    if (_activePlantCode != factoryCode) {
      _activePlantCode = factoryCode;
      notifyListeners();
    }
  }

  /// Initializes and seeds all 5 plant databases with their factory identities.
  Future<void> initializeAll() async {
    for (final plant in supportedPlants) {
      final dbService = getDatabaseForPlant(plant.code);
      await _seedPlantFactoryRecord(dbService, plant);
    }
  }

  /// Seeds factory identity record inside that specific plant's database.
  Future<void> _seedPlantFactoryRecord(DatabaseService dbService, PlantFactoryInfo plant) async {
    final existing = await dbService.factories.getFactoryByCode(plant.code);
    if (existing == null) {
      await dbService.factories.insertFactory(
        FactoriesCompanion.insert(
          factoryCode: plant.code,
          factoryName: '${plant.name} - Distillery Plant',
          driveFolderId: plant.driveFolderId,
          isActive: const Value(true),
        ),
      );
    } else {
      // Update name and folder if necessary
      await (dbService.db.update(dbService.db.factories)..where((tbl) => tbl.id.equals(existing.id))).write(
        FactoriesCompanion(
          factoryName: Value('${plant.name} - Distillery Plant'),
          driveFolderId: Value(plant.driveFolderId),
        ),
      );
    }
  }

  /// DEVELOPMENT ONLY: Clears all transactional test/dev data across all 5 factory databases while preserving factory metadata.
  Future<void> developmentResetAllDatabases() async {
    assert(!kReleaseMode, 'developmentResetAllDatabases() cannot be executed in release mode');
    if (kReleaseMode) {
      throw StateError('Cannot reset databases in release production mode.');
    }

    for (final plant in supportedPlants) {
      final dbService = getDatabaseForPlant(plant.code);
      await dbService.developmentResetDatabase();
      await _seedPlantFactoryRecord(dbService, plant);
    }
  }

  /// Closes all open SQLite databases cleanly.
  Future<void> closeAll() async {
    for (final service in _databases.values) {
      await service.db.close();
    }
    _databases.clear();
  }
}
