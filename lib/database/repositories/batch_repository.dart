import '../database.dart';

class BatchRepository {
  final AppDatabase db;

  BatchRepository(this.db);

  Future<List<BatchData>> getAllBatches() => db.select(db.batches).get();

  Future<List<BatchData>> getBatchesByFactory(int factoryId) =>
      (db.select(db.batches)..where((tbl) => tbl.factoryId.equals(factoryId))).get();

  Future<BatchData?> getBatchByBatchId(int factoryId, String batchId) =>
      (db.select(db.batches)
            ..where((tbl) => tbl.factoryId.equals(factoryId) & tbl.batchId.equals(batchId)))
          .getSingleOrNull();

  Future<int> insertBatch(BatchesCompanion companion) =>
      db.into(db.batches).insert(companion);

  Future<int> deleteBatch(int id) =>
      (db.delete(db.batches)..where((tbl) => tbl.id.equals(id))).go();
}
