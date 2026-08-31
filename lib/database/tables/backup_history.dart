import 'package:drift/drift.dart';

/// Tracks automatic 7-day SQLite database backups.
@DataClassName('BackupHistoryData')
@TableIndex(name: 'backup_history_status_idx', columns: {#status})
@TableIndex(name: 'backup_history_backup_started_at_idx', columns: {#backupStartedAt})
class BackupHistory extends Table {
  IntColumn get id => integer().autoIncrement()();
  DateTimeColumn get backupStartedAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get backupCompletedAt => dateTime().nullable()();
  TextColumn get backupFileName => text()();
  TextColumn get backupLocation => text()();
  TextColumn get cloudProvider => text()();
  Int64Column get databaseSizeBytes => int64().nullable()();
  IntColumn get recordsBackedUp => integer().nullable()();
  TextColumn get status => text()(); // STARTED, SUCCESS, FAILED, VERIFICATION_FAILED
  DateTimeColumn get verifiedAt => dateTime().nullable()();
  IntColumn get deletedLocalRecords => integer().nullable().withDefault(const Constant(0))();
  TextColumn get errorMessage => text().nullable()();
}
