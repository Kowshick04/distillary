import '../database.dart';

class FactoryRepository {
  final AppDatabase db;

  FactoryRepository(this.db);

  Future<List<FactoryData>> getAllFactories() => db.select(db.factories).get();

  Stream<List<FactoryData>> watchAllFactories() => db.select(db.factories).watch();

  Future<List<FactoryData>> getActiveFactories() =>
      (db.select(db.factories)..where((tbl) => tbl.isActive.equals(true))).get();

  Future<FactoryData?> getFactoryByCode(String code) =>
      (db.select(db.factories)..where((tbl) => tbl.factoryCode.equals(code))).getSingleOrNull();

  Future<FactoryData?> getFactoryById(int id) =>
      (db.select(db.factories)..where((tbl) => tbl.id.equals(id))).getSingleOrNull();

  Future<int> insertFactory(FactoriesCompanion companion) =>
      db.into(db.factories).insert(companion);

  Future<bool> updateFactory(FactoryData factory) =>
      db.update(db.factories).replace(factory);

  Future<int> deleteFactory(int id) =>
      (db.delete(db.factories)..where((tbl) => tbl.id.equals(id))).go();
}
