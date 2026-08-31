import '../database.dart';

class AiModelRepository {
  final AppDatabase db;

  AiModelRepository(this.db);

  Future<List<AiModelData>> getAllModels() => db.select(db.aiModels).get();

  Future<List<AiModelData>> getActiveModels() =>
      (db.select(db.aiModels)..where((tbl) => tbl.isActive.equals(true))).get();

  Future<AiModelData?> getModelByNameAndVersion(String name, String version) =>
      (db.select(db.aiModels)
            ..where((tbl) => tbl.modelName.equals(name) & tbl.modelVersion.equals(version)))
          .getSingleOrNull();

  Future<int> insertModel(AiModelsCompanion companion) =>
      db.into(db.aiModels).insert(companion);

  Future<int> deleteModel(int id) =>
      (db.delete(db.aiModels)..where((tbl) => tbl.id.equals(id))).go();
}
