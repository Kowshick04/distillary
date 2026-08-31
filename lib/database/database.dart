import 'dart:io';
import 'package:drift/drift.dart';
export 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'tables/ai_models.dart';
import 'tables/backup_history.dart';
import 'tables/batches.dart';
import 'tables/factories.dart';
import 'tables/input_files.dart';
import 'tables/mqtt_publish_log.dart';
import 'tables/predictions.dart';
import 'tables/preprocessing_data.dart';
import 'tables/processing_runs.dart';

part 'database.g.dart';

/// The central production database for the Distillery Windows application.
/// Manages exactly 9 tables with SQLite foreign keys and indexes.
@DriftDatabase(tables: [
  Factories,
  InputFiles,
  Batches,
  ProcessingRuns,
  PreprocessingData,
  AiModels,
  Predictions,
  MqttPublishLog,
  BackupHistory,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? e]) : super(e ?? _openConnection('distillery.db'));

  /// Creates or opens an independent database for a specific factory or name.
  AppDatabase.named(String dbName, [QueryExecutor? e]) : super(e ?? _openConnection(dbName));

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    beforeOpen: (details) async {
      // Enforce SQLite Foreign Key constraints
      await customStatement('PRAGMA foreign_keys = ON;');
    },
  );

  static QueryExecutor _openConnection([String dbName = 'distillery.db']) {
    return LazyDatabase(() async {
      final dbFolder = await getApplicationSupportDirectory();
      final file = File(p.join(dbFolder.path, dbName));
      return NativeDatabase.createInBackground(
        file,
        setup: (rawDb) {
          rawDb.execute('PRAGMA foreign_keys = ON;');
        },
      );
    });
  }
}
