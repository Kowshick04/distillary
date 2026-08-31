import 'package:drift/drift.dart';
import 'factories.dart';
import 'input_files.dart';

/// Represents a production batch extracted from Excel.
@DataClassName('BatchData')
@TableIndex(name: 'batches_factory_batch_idx', columns: {#factoryId, #batchId})
class Batches extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get factoryId => integer().references(Factories, #id, onDelete: KeyAction.cascade)();
  IntColumn get inputFileId => integer().references(InputFiles, #id, onDelete: KeyAction.cascade)();
  TextColumn get batchId => text()();
  TextColumn get fermenter => text().nullable()();
  TextColumn get state => text().nullable()();
  DateTimeColumn get batchStartTime => dateTime().nullable()();
  DateTimeColumn get batchEndTime => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}
