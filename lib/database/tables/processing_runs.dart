import 'package:drift/drift.dart';
import 'ai_models.dart';
import 'batches.dart';
import 'input_files.dart';

/// Tracks each Excel preprocessing + AI execution.
@DataClassName('ProcessingRunData')
@TableIndex(name: 'processing_runs_input_file_idx', columns: {#inputFileId})
@TableIndex(name: 'processing_runs_batch_idx', columns: {#batchId})
@TableIndex(name: 'processing_runs_status_idx', columns: {#status})
class ProcessingRuns extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get inputFileId => integer().references(InputFiles, #id, onDelete: KeyAction.cascade)();
  IntColumn get batchId => integer().nullable().references(Batches, #id, onDelete: KeyAction.setNull)();
  DateTimeColumn get startedAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get completedAt => dateTime().nullable()();
  TextColumn get status => text()(); // RUNNING, SUCCESS, FAILED
  TextColumn get pipelineVersion => text().nullable()();
  IntColumn get modelId => integer().nullable().references(AiModels, #id, onDelete: KeyAction.setNull)();
  IntColumn get recordsProcessed => integer().nullable()();
  TextColumn get errorMessage => text().nullable()();
}
