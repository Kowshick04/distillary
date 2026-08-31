import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:distillary/database/database.dart';
import 'package:distillary/main.dart';
import 'package:distillary/services/backup_service.dart';
import 'package:distillary/services/database_service.dart';
import 'package:distillary/services/factory_database_manager.dart';

void main() {
  testWidgets('App launches and displays database UI', (WidgetTester tester) async {
    final customServices = <String, DatabaseService>{};
    final dbs = <AppDatabase>[];

    for (final plant in FactoryDatabaseManager.supportedPlants) {
      final db = AppDatabase(NativeDatabase.memory());
      dbs.add(db);
      customServices[plant.code] = DatabaseService(db, BackupService(db));
    }

    final manager = FactoryDatabaseManager(initialDatabases: customServices);
    await manager.initializeAll();

    await tester.pumpWidget(DistilleryApp(factoryManager: manager));
    await tester.pumpAndSettle();

    expect(find.text('Haliyal [haliyal.db]'), findsOneWidget);
    expect(find.text('Haliyal - Factories'), findsOneWidget);

    for (final db in dbs) {
      await db.close();
    }
  });
}

