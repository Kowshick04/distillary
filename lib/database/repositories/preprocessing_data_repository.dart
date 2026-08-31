import '../database.dart';

class PreprocessingDataRepository {
  final AppDatabase db;

  PreprocessingDataRepository(this.db);

  Future<List<PreprocessingDataRecord>> getAllRecords() => db.select(db.preprocessingData).get();

  Future<List<PreprocessingDataRecord>> getByBatchId(int batchId) =>
      (db.select(db.preprocessingData)..where((tbl) => tbl.batchId.equals(batchId))).get();

  Future<List<PreprocessingDataRecord>> getByProcessingRunId(int runId) =>
      (db.select(db.preprocessingData)..where((tbl) => tbl.processingRunId.equals(runId))).get();

  Future<int> insertRecord(PreprocessingDataCompanion companion) =>
      db.into(db.preprocessingData).insert(companion);

  Future<void> insertBatchRecords(List<PreprocessingDataCompanion> records) {
    return db.batch((batch) {
      batch.insertAll(db.preprocessingData, records);
    });
  }

  Future<int> deleteRecord(int id) =>
      (db.delete(db.preprocessingData)..where((tbl) => tbl.id.equals(id))).go();
}
