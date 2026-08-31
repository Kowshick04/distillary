import 'package:drift/drift.dart';
import 'factories.dart';

/// Tracks Excel files found in Google Drive and supports:
/// NEW, UNCHANGED, MODIFIED, PROCESSED, ERROR
@DataClassName('InputFileData')
@TableIndex(name: 'input_files_factory_status_idx', columns: {#factoryId, #status})
class InputFiles extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get factoryId => integer().references(Factories, #id, onDelete: KeyAction.cascade)();
  TextColumn get driveFileId => text()();
  TextColumn get fileName => text()();
  TextColumn get fileType => text().nullable()();
  Int64Column get fileSizeBytes => int64().nullable()();
  DateTimeColumn get driveModifiedAt => dateTime().nullable()();
  TextColumn get fileHash => text().nullable()();
  TextColumn get status => text()();
  DateTimeColumn get firstSeenAt => dateTime().nullable()();
  DateTimeColumn get lastSeenAt => dateTime().nullable()();
  DateTimeColumn get lastProcessedAt => dateTime().nullable()();
  TextColumn get errorMessage => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  List<Set<Column>> get uniqueKeys => [
    {factoryId, driveFileId},
  ];
}
