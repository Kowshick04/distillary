import 'package:drift/drift.dart';
import 'ai_models.dart';
import 'batches.dart';
import 'processing_runs.dart';

/// Stores AI prediction results and quality metrics.
@DataClassName('PredictionData')
@TableIndex(name: 'predictions_batch_idx', columns: {#batchId})
@TableIndex(name: 'predictions_processing_run_idx', columns: {#processingRunId})
@TableIndex(name: 'predictions_predicted_at_idx', columns: {#predictedAt})
class Predictions extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get batchId => integer().references(Batches, #id, onDelete: KeyAction.cascade)();
  IntColumn get processingRunId => integer().references(ProcessingRuns, #id, onDelete: KeyAction.cascade)();
  IntColumn get modelId => integer().references(AiModels, #id, onDelete: KeyAction.restrict)();

  TextColumn get predictionLabel => text()(); // GOLDEN_BATCH, NORMAL_BATCH, LOW_ALCOHOL
  RealColumn get predictionConfidence => real().nullable()();

  RealColumn get predictedProduction => real().nullable()();
  RealColumn get actualProduction => real().nullable()();

  RealColumn get predictedFermenterEfficiency => real().nullable()();
  RealColumn get actualFermenterEfficiency => real().nullable()();

  RealColumn get predictedEthanolPercentage => real().nullable()();
  RealColumn get actualEthanolPercentage => real().nullable()();

  BoolColumn get fermenterVesselQcAlert => boolean().nullable()();

  DateTimeColumn get predictedAt => dateTime().withDefault(currentDateAndTime)();
}
