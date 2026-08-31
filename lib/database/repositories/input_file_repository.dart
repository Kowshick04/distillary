import '../database.dart';

class InputFileRepository {
  final AppDatabase db;

  InputFileRepository(this.db);

  Future<List<InputFileData>> getAllFiles() => db.select(db.inputFiles).get();

  Stream<List<InputFileData>> watchAllFiles() => db.select(db.inputFiles).watch();

  Future<InputFileData?> getFileById(int id) =>
      (db.select(db.inputFiles)..where((tbl) => tbl.id.equals(id))).getSingleOrNull();

  Future<List<InputFileData>> getFilesByFactory(int factoryId) =>
      (db.select(db.inputFiles)..where((tbl) => tbl.factoryId.equals(factoryId))).get();

  Future<List<InputFileData>> getFilesByStatus(int factoryId, String status) =>
      (db.select(db.inputFiles)
            ..where((tbl) => tbl.factoryId.equals(factoryId) & tbl.status.equals(status)))
          .get();

  Future<InputFileData?> getFileByDriveId(int factoryId, String driveFileId) =>
      (db.select(db.inputFiles)
            ..where((tbl) => tbl.factoryId.equals(factoryId) & tbl.driveFileId.equals(driveFileId)))
          .getSingleOrNull();

  Future<int> insertFile(InputFilesCompanion companion) =>
      db.into(db.inputFiles).insert(companion);

  Future<int> updateFileStatus(
    int id,
    String status, {
    String? errorMessage,
    DateTime? processedAt,
  }) {
    return (db.update(db.inputFiles)..where((tbl) => tbl.id.equals(id))).write(
      InputFilesCompanion(
        status: Value(status),
        errorMessage: Value(errorMessage),
        lastProcessedAt: Value(processedAt),
      ),
    );
  }

  Future<int> updateFileMetadata({
    required int id,
    required String status,
    String? fileName,
    String? fileType,
    BigInt? fileSizeBytes,
    DateTime? driveModifiedAt,
    String? fileHash,
    DateTime? lastSeenAt,
    String? errorMessage,
  }) {
    return (db.update(db.inputFiles)..where((tbl) => tbl.id.equals(id))).write(
      InputFilesCompanion(
        status: Value(status),
        fileName: fileName != null ? Value(fileName) : const Value.absent(),
        fileType: fileType != null ? Value(fileType) : const Value.absent(),
        fileSizeBytes: fileSizeBytes != null ? Value(fileSizeBytes) : const Value.absent(),
        driveModifiedAt: driveModifiedAt != null ? Value(driveModifiedAt) : const Value.absent(),
        fileHash: fileHash != null ? Value(fileHash) : const Value.absent(),
        lastSeenAt: lastSeenAt != null ? Value(lastSeenAt) : const Value.absent(),
        errorMessage: Value(errorMessage),
      ),
    );
  }

  Future<int> updateLastSeen(int id, DateTime lastSeenAt) {
    return (db.update(db.inputFiles)..where((tbl) => tbl.id.equals(id))).write(
      InputFilesCompanion(
        lastSeenAt: Value(lastSeenAt),
      ),
    );
  }

  Future<int> deleteFile(int id) =>
      (db.delete(db.inputFiles)..where((tbl) => tbl.id.equals(id))).go();
}
