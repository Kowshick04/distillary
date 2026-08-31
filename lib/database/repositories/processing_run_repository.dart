import '../database.dart';

class ProcessingRunRepository {
  final AppDatabase db;

  ProcessingRunRepository(this.db);

  Future<List<ProcessingRunData>> getAllRuns() => db.select(db.processingRuns).get();

  Future<List<ProcessingRunData>> getRunsByInputFile(int inputFileId) =>
      (db.select(db.processingRuns)..where((tbl) => tbl.inputFileId.equals(inputFileId))).get();

  Future<List<ProcessingRunData>> getRunsByBatch(int batchId) =>
      (db.select(db.processingRuns)..where((tbl) => tbl.batchId.equals(batchId))).get();

  Future<int> insertRun(ProcessingRunsCompanion companion) =>
      db.into(db.processingRuns).insert(companion);

  Future<int> updateRunStatus(
    int id,
    String status, {
    DateTime? completedAt,
    int? recordsProcessed,
    String? errorMessage,
  }) {
    return (db.update(db.processingRuns)..where((tbl) => tbl.id.equals(id))).write(
      ProcessingRunsCompanion(
        status: Value(status),
        completedAt: Value(completedAt),
        recordsProcessed: Value(recordsProcessed),
        errorMessage: Value(errorMessage),
      ),
    );
  }

  Future<int> deleteRun(int id) =>
      (db.delete(db.processingRuns)..where((tbl) => tbl.id.equals(id))).go();

  /// Finds any processing runs stuck in 'RUNNING' status older than [staleThreshold]
  /// and marks them as 'FAILED' with a stale timeout notice so subsequent scans can retry.
  Future<int> recoverStaleRunningRuns({Duration staleThreshold = const Duration(minutes: 15)}) async {
    final cutoff = DateTime.now().toUtc().subtract(staleThreshold);
    final staleRuns = await (db.select(db.processingRuns)
      ..where((tbl) => tbl.status.equals('RUNNING') & tbl.startedAt.isSmallerThanValue(cutoff)))
      .get();

    for (final run in staleRuns) {
      await updateRunStatus(
        run.id,
        'FAILED',
        completedAt: DateTime.now().toUtc(),
        errorMessage: 'Process terminated unexpectedly before completion (stale timeout recovery).',
      );
    }
    return staleRuns.length;
  }
}
