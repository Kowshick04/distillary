import 'package:drift/drift.dart';

/// Stores the 5 distillery factories and their Google Drive input folders.
@DataClassName('FactoryData')
class Factories extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get factoryCode => text().unique()();
  TextColumn get factoryName => text()();
  TextColumn get driveFolderId => text()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}
