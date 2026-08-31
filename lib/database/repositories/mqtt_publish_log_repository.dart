import '../database.dart';

class MqttPublishLogRepository {
  final AppDatabase db;

  MqttPublishLogRepository(this.db);

  Future<List<MqttPublishLogData>> getAllLogs() => db.select(db.mqttPublishLog).get();

  Future<List<MqttPublishLogData>> getLogsByPrediction(int predictionId) =>
      (db.select(db.mqttPublishLog)..where((tbl) => tbl.predictionId.equals(predictionId))).get();

  Future<List<MqttPublishLogData>> getLogsByStatus(String status) =>
      (db.select(db.mqttPublishLog)..where((tbl) => tbl.status.equals(status))).get();

  Future<int> insertLog(MqttPublishLogCompanion companion) =>
      db.into(db.mqttPublishLog).insert(companion);

  Future<int> updateLogStatus(
    int id,
    String status, {
    int? retryCount,
    String? errorMessage,
  }) {
    return (db.update(db.mqttPublishLog)..where((tbl) => tbl.id.equals(id))).write(
      MqttPublishLogCompanion(
        status: Value(status),
        retryCount: retryCount != null ? Value(retryCount) : const Value.absent(),
        errorMessage: Value(errorMessage),
      ),
    );
  }

  Future<int> deleteLog(int id) =>
      (db.delete(db.mqttPublishLog)..where((tbl) => tbl.id.equals(id))).go();
}
