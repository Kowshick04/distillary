import 'package:drift/drift.dart';
import 'predictions.dart';

/// Tracks important MQTT prediction publishing events.
@DataClassName('MqttPublishLogData')
@TableIndex(name: 'mqtt_publish_log_prediction_idx', columns: {#predictionId})
@TableIndex(name: 'mqtt_publish_log_status_idx', columns: {#status})
@TableIndex(name: 'mqtt_publish_log_published_at_idx', columns: {#publishedAt})
class MqttPublishLog extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get predictionId => integer().references(Predictions, #id, onDelete: KeyAction.cascade)();
  TextColumn get topic => text()();
  TextColumn get payload => text()();
  IntColumn get qos => integer().withDefault(const Constant(1))();
  DateTimeColumn get publishedAt => dateTime().withDefault(currentDateAndTime)();
  TextColumn get status => text()(); // SUCCESS, FAILED, RETRYING
  IntColumn get retryCount => integer().withDefault(const Constant(0))();
  TextColumn get errorMessage => text().nullable()();
}
