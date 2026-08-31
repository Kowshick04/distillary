// ignore_for_file: avoid_print

import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:distillary/database/database.dart';
import 'package:distillary/services/database_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('distillery_runtime_test_');

    // Mock path_provider MethodChannel using Flutter's test binary messenger
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/path_provider'),
      (MethodCall methodCall) async {
        return tempDir.path;
      },
    );
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/path_provider_windows'),
      (MethodCall methodCall) async {
        return tempDir.path;
      },
    );
  });

  tearDown(() async {
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  test('Runtime File Database Creation and Path Verification', () async {
    print('[Resolved App Support Path]: ${tempDir.path}');

    final db = AppDatabase();
    final service = DatabaseService(db);

    await service.seedInitialFactories();

    final factories = await service.factories.getAllFactories();
    expect(factories.length, equals(5));

    await db.close();

    // Verify distillery.db was created automatically on disk
    final dbFile = File('${tempDir.path}${Platform.pathSeparator}distillery.db');
    expect(await dbFile.exists(), isTrue);
    print('[Confirmed Database File Created]: ${dbFile.path}');
    print('[Database File Size]: ${await dbFile.length()} bytes');
  });
}

