import 'package:drift/drift.dart';

/// Tracks the AI model used to generate predictions.
@DataClassName('AiModelData')
class AiModels extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get modelName => text()();
  TextColumn get modelVersion => text()();
  TextColumn get modelType => text()();
  TextColumn get modelPath => text().nullable()();
  DateTimeColumn get trainedAt => dateTime().nullable()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}
