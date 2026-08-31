import 'package:drift/drift.dart';
import 'batches.dart';
import 'input_files.dart';
import 'processing_runs.dart';

/// Stores selected AI/preprocessing features and process context extracted from Excel.
@DataClassName('PreprocessingDataRecord')
@TableIndex(name: 'preprocessing_data_batch_idx', columns: {#batchId})
@TableIndex(name: 'preprocessing_data_input_file_idx', columns: {#inputFileId})
@TableIndex(name: 'preprocessing_data_processing_run_idx', columns: {#processingRunId})
class PreprocessingData extends Table {
  // Identification
  IntColumn get id => integer().autoIncrement()();
  IntColumn get batchId => integer().references(Batches, #id, onDelete: KeyAction.cascade)();
  IntColumn get inputFileId => integer().references(InputFiles, #id, onDelete: KeyAction.cascade)();
  IntColumn get processingRunId => integer().references(ProcessingRuns, #id, onDelete: KeyAction.cascade)();
  DateTimeColumn get timestampMinute => dateTime().nullable()();
  DateTimeColumn get serverTimestamp => dateTime().nullable()();

  // Core AI/preprocessing features
  RealColumn get sugarConsumptionRate => real().nullable()();
  RealColumn get feedingHours => real().nullable()();
  RealColumn get retentionHours => real().nullable()();
  RealColumn get setupSg => real().nullable()();
  RealColumn get finalSg => real().nullable()();
  RealColumn get sgDifference => real().nullable()();
  RealColumn get alcoholSetup => real().nullable()();
  RealColumn get alcoholFinal => real().nullable()();
  RealColumn get phSetup => real().nullable()();
  RealColumn get phFinal => real().nullable()();
  RealColumn get rawSpentWashBrix => real().nullable()();
  RealColumn get bottomSpentWashBrix => real().nullable()();
  RealColumn get ffeOutletSpentWashBrix => real().nullable()();
  RealColumn get concentratedSpentWashBrix => real().nullable()();

  // Important process/context values
  RealColumn get temperature => real().nullable()();
  RealColumn get brix => real().nullable()();
  RealColumn get residualSugar => real().nullable()();
  RealColumn get yeastActivity => real().nullable()();
  RealColumn get volatileAcidity => real().nullable()();
  RealColumn get coolingValve => real().nullable()();
  RealColumn get agitatorRpm => real().nullable()();
  RealColumn get steamValve => real().nullable()();
  RealColumn get tankLevelPercent => real().nullable()();
  RealColumn get tankWeightKg => real().nullable()();
  RealColumn get co2FlowKgph => real().nullable()();
  RealColumn get headspacePressureBar => real().nullable()();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}
