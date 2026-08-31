// ignore_for_file: avoid_print

import 'dart:io';
import 'package:archive/archive.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Verify Distillery_Module_v1.0.0_Verified.zip package integrity', () {
    final zipFile = File('Distillery_Module_v1.0.0_Verified.zip');
    expect(zipFile.existsSync(), isTrue, reason: 'ZIP file must exist');

    final bytes = zipFile.readAsBytesSync();
    final archive = ZipDecoder().decodeBytes(bytes);

    print('====================================================');
    print('  ZIP PACKAGE CONTENT AUDIT (${archive.length} files)');
    print('====================================================');

    final requiredPaths = [
      'README_INTEGRATION.md',
      'PACKAGE_CONTENTS.md',
      'pubspec.yaml',
      'analysis_options.yaml',
      'lib/services/distillery_service.dart',
      'lib/services/factory_database_manager.dart',
      'lib/services/database_service.dart',
      'lib/services/google_drive_sync_service.dart',
      'lib/services/drive_bridge_service.dart',
      'lib/services/excel_ingestion_service.dart',
      'lib/services/distillery_excel_parser.dart',
      'lib/services/backup_service.dart',
      'lib/database/database.dart',
      'lib/database/database.g.dart',
      'android/app/build.gradle.kts',
      'android/app/src/main/AndroidManifest.xml',
      'test/distillery_service_facade_test.dart',
      'test/step5b_full_validation_test.dart',
    ];

    final archiveFilenames = archive.map((e) => e.name.replaceAll('\\', '/')).toSet();

    for (final req in requiredPaths) {
      expect(archiveFilenames.contains(req), isTrue, reason: 'Missing required file in ZIP: $req');
    }

    final prohibitedPatterns = [
      RegExp(r'\.db$', caseSensitive: false),
      RegExp(r'\.db-wal$', caseSensitive: false),
      RegExp(r'\.db-shm$', caseSensitive: false),
      RegExp(r'^build/'),
      RegExp(r'^\.dart_tool/'),
      RegExp(r'^\.idea/'),
      RegExp(r'^\.vscode/'),
      RegExp(r'credentials\.json$', caseSensitive: false),
      RegExp(r'token\.json$', caseSensitive: false),
      RegExp(r'client_secret\.json$', caseSensitive: false),
    ];

    int prohibitedCount = 0;
    for (final filename in archiveFilenames) {
      for (final pattern in prohibitedPatterns) {
        if (pattern.hasMatch(filename)) {
          print('! PROHIBITED FILE FOUND: $filename');
          prohibitedCount++;
        }
      }
    }

    expect(prohibitedCount, equals(0), reason: 'Zero prohibited files must exist in ZIP');
    print('√ ZIP Archive: Size = ${(bytes.length / 1024 / 1024).toStringAsFixed(2)} MB');
    print('√ All required files present');
    print('√ Zero prohibited database / cache / secret files found');
    print('====================================================');
  });
}
