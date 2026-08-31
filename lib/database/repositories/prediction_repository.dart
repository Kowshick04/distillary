import '../database.dart';

class PredictionRepository {
  final AppDatabase db;

  PredictionRepository(this.db);

  Future<List<PredictionData>> getAllPredictions() => db.select(db.predictions).get();

  Future<List<PredictionData>> getPredictionsByBatch(int batchId) =>
      (db.select(db.predictions)..where((tbl) => tbl.batchId.equals(batchId))).get();

  Future<List<PredictionData>> getPredictionsByRun(int runId) =>
      (db.select(db.predictions)..where((tbl) => tbl.processingRunId.equals(runId))).get();

  Future<int> insertPrediction(PredictionsCompanion companion) =>
      db.into(db.predictions).insert(companion);

  Future<int> deletePrediction(int id) =>
      (db.delete(db.predictions)..where((tbl) => tbl.id.equals(id))).go();
}
