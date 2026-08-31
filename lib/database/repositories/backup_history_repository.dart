import '../database.dart';

class BackupHistoryRepository {
  final AppDatabase db;

  BackupHistoryRepository(this.db);

  Future<List<BackupHistoryData>> getAllBackups() => db.select(db.backupHistory).get();

  Future<List<BackupHistoryData>> getBackupsByStatus(String status) =>
      (db.select(db.backupHistory)..where((tbl) => tbl.status.equals(status))).get();

  Future<int> insertBackup(BackupHistoryCompanion companion) =>
      db.into(db.backupHistory).insert(companion);

  Future<int> updateBackupStatus(
    int id,
    String status, {
    DateTime? completedAt,
    DateTime? verifiedAt,
    int? deletedLocalRecords,
    String? errorMessage,
  }) {
    return (db.update(db.backupHistory)..where((tbl) => tbl.id.equals(id))).write(
      BackupHistoryCompanion(
        status: Value(status),
        backupCompletedAt: Value(completedAt),
        verifiedAt: Value(verifiedAt),
        deletedLocalRecords:
            deletedLocalRecords != null ? Value(deletedLocalRecords) : const Value.absent(),
        errorMessage: Value(errorMessage),
      ),
    );
  }

  Future<int> deleteBackup(int id) =>
      (db.delete(db.backupHistory)..where((tbl) => tbl.id.equals(id))).go();
}
