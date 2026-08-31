// ignore_for_file: avoid_print

import









'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
import '../../services/database_service.dart';
import '../../services/distillery_service.dart';
import '../../services/factory_database_manager.dart';
import '../../services/distillery_background_worker.dart';
import '../../services/drive_bridge_service.dart';
import '../../services/excel_ingestion_service.dart';
import

'../../services/google_drive_sync_service.dart';
import '../../database/database.dart' hide Column;
import '../../utils/app_colors.dart';

class DatabaseExplorerScreen extends StatefulWidget {
  const DatabaseExplorerScreen({super.key});

  @override
  State<DatabaseExplorerScreen> createState() => _DatabaseExplorerPageState();
}

class _DatabaseExplorerPageState extends State<DatabaseExplorerScreen> {
  int _selectedTableIndex = 0;
  bool _isBackingUp = false;

  final List<Map<String, dynamic>> _tables = [
    {'name': 'Factories', 'icon': Icons.factory_rounded, 'code': 'factories'},
    {'name': 'Input Files', 'icon': Icons.description_rounded, 'code': 'input_files'},
    {'name': 'Batches', 'icon': Icons.layers_rounded, 'code': 'batches'},
    {'name': 'Processing Runs', 'icon': Icons.play_circle_fill_rounded, 'code': 'processing_runs'},
    {'name': 'Preprocessing Data', 'icon': Icons.analytics_rounded, 'code': 'preprocessing_data'},
    {'name': 'AI Models', 'icon': Icons.memory_rounded, 'code': 'ai_models'},
    {'name': 'Predictions', 'icon': Icons.insights_rounded, 'code': 'predictions'},
    {'name': 'MQTT Publish Log', 'icon': Icons.send_rounded, 'code': 'mqtt_publish_log'},
    {'name': 'Backup History', 'icon': Icons.backup_rounded, 'code': 'backup_history'},
  ];

  DatabaseService get dbService => distilleryService.factoryManager.activeDatabase;
  PlantFactoryInfo get activePlant => distilleryService.factoryManager.activePlant;

  void _showGoogleDriveModal() {
    final List<String> backupLogs = [];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (modalCtx) => StatefulBuilder(
        builder: (modalCtx, setModalState) {
          final client = distilleryService.factoryManager.driveClient;
          final user = client?.currentUser;

          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                      children: [
                        Icon(Icons.cloud_upload_rounded, color: Color(0xFF1E3A8A), size: 28),
                        SizedBox(width: 10),
                        Text(
                          'Google Drive Backup',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(modalCtx),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: user != null ? Colors.green.shade50 : Colors.amber.shade50,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: user != null ? Colors.green.shade300 : Colors.amber.shade300),
                  ),
                  child: Row(
                    children: [
                      Icon(user != null ? Icons.check_circle : Icons.account_circle, color: user != null ? Colors.green.shade700 : Colors.amber.shade800),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user != null ? 'Signed In: ${user.email}' : 'Sign In Required for Real Google Drive Upload',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: user != null ? Colors.green.shade900 : Colors.amber.shade900),
                            ),
                            Text(
                              user != null ? 'Active Plant: ${activePlant.name} (${activePlant.dbFileName})' : 'Tap to sign in with Google Account',
                              style: const TextStyle(fontSize: 11, color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                      if (client != null)
                        TextButton(
                          onPressed: () async {
                            if (user == null) {
                              await client.signIn();
                            } else {
                              await client.signOut();
                            }
                            setModalState(() {});
                            setState(() {});
                          },
                          child: Text(user == null ? 'Sign In' : 'Sign Out'),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E3A8A),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    icon: _isBackingUp
                        ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Icon(Icons.cloud_upload_rounded),
                    label: Text(_isBackingUp ? 'Processing Backup...' : 'Backup ${activePlant.code} / ${activePlant.name} Now'),
                    onPressed: _isBackingUp
                        ? null
                        : () async {
                            setModalState(() {
                              _isBackingUp = true;
                              backupLogs.clear();
                            });
                            setState(() => _isBackingUp = true);

                            final res = await dbService.backupService.backupFactory(
                              factoryCode: activePlant.code,
                              plantName: activePlant.name,
                              dbPrefix: activePlant.name.toLowerCase(),
                              targetFolderId: activePlant.backupFolderId,
                              onProgress: (msg) {
                                print(msg);
                                setModalState(() {
                                  backupLogs.add(msg);
                                });
                              },
                            );

                            setModalState(() => _isBackingUp = false);
                            setState(() => _isBackingUp = false);

                            if (!mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(res.isSuccess ? 'Backup verified & stored on Google Drive!' : 'Backup failed: ${res.errorMessage}'),
                                backgroundColor: res.isSuccess ? Colors.green : Colors.red,
                              ),
                            );
                          },
                  ),
                ),
                if (!kReleaseMode) ...[
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.amber,
                        side: const BorderSide(color: AppColors.amber, width: 1.5),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      icon: const Icon(Icons.cleaning_services_rounded),
                      label: const Text('Test 7-Day Pruning (Development Only)'),
                      onPressed: _isBackingUp
                          ? null
                          : () async {
                              setModalState(() {
                                _isBackingUp = true;
                                backupLogs.clear();
                              });
                              setState(() => _isBackingUp = true);

                              backupLogs.add('[PRUNE_TEST] Seeding controlled 7-day retention test records (1d, 6d, 7d, 8d, 30d)...');
                              await dbService.backupService.seedRetentionTestFixtures(factoryCode: activePlant.code);

                              backupLogs.add('[PRUNE_TEST] Triggering safe 7-day pruning engine for ${activePlant.code} / ${activePlant.name}...');
                              final pruneRes = await dbService.backupService.pruneHistoricalData(
                                factoryCode: activePlant.code,
                                onProgress: (msg) {
                                  print(msg);
                                  setModalState(() {
                                    backupLogs.add(msg);
                                  });
                                },
                              );

                              setModalState(() => _isBackingUp = false);
                              setState(() => _isBackingUp = false);

                              if (!mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(pruneRes.isSuccess
                                      ? 'Pruning completed! Deleted ${pruneRes.deletedRecordsCount} old records (FKs: 0 violations, integrity: OK).'
                                      : 'Pruning blocked/failed: ${pruneRes.errorMessage}'),
                                  backgroundColor: pruneRes.isSuccess ? Colors.green : Colors.amber.shade900,
                                ),
                              );
                            },
                    ),
                  ),
                ],
                if (backupLogs.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  const Row(
                    children: [
                      Icon(Icons.terminal, size: 16, color: Color(0xFF1E3A8A)),
                      SizedBox(width: 6),
                      Text(
                        'Live SQLite Backup Stream',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1E3A8A)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceDeep,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: backupLogs.map((log) {
                        Color textColor = Colors.greenAccent;
                        if (log.contains('FAILED') || log.contains('error') || log.contains('violation')) {
                          textColor = Colors.redAccent;
                        } else if (log.contains('Downloading') || log.contains('Uploading')) {
                          textColor = Colors.lightBlueAccent;
                        } else if (log.contains('integrity') || log.contains('foreign_key')) {
                          textColor = Colors.amberAccent;
                        }
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Text(
                            log,
                            style: TextStyle(fontFamily: 'monospace', fontSize: 11, color: textColor),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
                const SizedBox(height: 10),
              ],
            ),
          ),
        );
      },
    ),
  );
}

  void _showPythonScannerModal() {
    GoogleDriveScanResult? scanResult;
    bool isScanning = false;
    final List<String> ingestionLogs = [];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (modalCtx) => StatefulBuilder(
        builder: (modalCtx, setModalState) {
          final client = distilleryService.factoryManager.driveClient;
          final user = client?.currentUser;

          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.terminal_rounded, color: Color(0xFF1E3A8A), size: 28),
                          SizedBox(width: 10),
                          Text(
                            'Python Drive Scanner & Ingestion',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(modalCtx),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Active Plant: ${activePlant.name} (${activePlant.code}) | DB: ${activePlant.dbFileName}',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A)),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: user != null ? Colors.green.shade50 : Colors.amber.shade50,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: user != null ? Colors.green.shade300 : Colors.amber.shade300),
                    ),
                    child: Row(
                      children: [
                        Icon(user != null ? Icons.check_circle : Icons.account_circle, color: user != null ? Colors.green.shade700 : Colors.amber.shade800),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user != null ? 'Connected: ${user.email}' : 'Sign In required to scan Google Drive',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: user != null ? Colors.green.shade900 : Colors.amber.shade900),
                              ),
                              const Text('Scope: drive.readonly (Read-only Excel discovery)', style: TextStyle(fontSize: 10, color: Colors.grey)),
                            ],
                          ),
                        ),
                        if (client != null)
                          TextButton(
                            onPressed: () async {
                              if (user == null) {
                                await client.signIn();
                              } else {
                                await client.reAuthenticate();
                              }
                              setModalState(() {});
                              setState(() {});
                            },
                            child: Text(user == null ? 'Sign In' : 'Re-Auth'),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1E3A8A),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      icon: isScanning
                          ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Icon(Icons.search_rounded),
                      label: Text(isScanning ? 'Auto Pipeline Ingesting...' : 'Scan & Ingest All 5 Factories'),
                      onPressed: isScanning
                          ? null
                          : () async {
                              setModalState(() {
                                isScanning = true;
                                ingestionLogs.clear();
                              });

                              String? token = await client?.getAccessToken();
                              if (token == null && client != null) {
                                final acc = await client.signIn();
                                if (acc != null) {
                                  token = await client.getAccessToken();
                                }
                              }

                              if (token == null || token.isEmpty) {
                                setModalState(() => isScanning = false);
                                if (!mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Please sign in to Google first.')),
                                );
                                return;
                              }

                              drive.DriveApi? driveApi;
                              if (client != null) {
                                final authClient = await client.googleSignIn.authenticatedClient();
                                if (authClient != null) {
                                  driveApi = drive.DriveApi(authClient);
                                }
                              }

                              final Map<String, FactoryScanSummary> combinedFactorySummaries = {};
                              int totalNew = 0;
                              int totalMod = 0;
                              int totalUnchanged = 0;
                              String? authAccount;

                              for (final plant in distilleryService.factoryManager.plants) {
                                final plantDbService = distilleryService.factoryManager.getDatabaseForPlant(plant.code);
                                final plantFactories = await plantDbService.factories.getAllFactories();
                                final plantBridge = DriveBridgeService(plantDbService);

                                final existingRows = await plantDbService.inputFiles.getAllFiles();
                                debugPrint('===============================================================');
                                debugPrint('  SCANNING PLANT: ${plant.displayName}');
                                debugPrint('  Database File: ${plant.dbFileName}');
                                debugPrint('  Current input_files row count: ${existingRows.length}');
                                debugPrint('===============================================================');

                                final plantScanRes = await plantBridge.scanAndSyncFactoryFiles(
                                  accessToken: token,
                                  factories: plantFactories,
                                  driveApi: driveApi,
                                  forceReingest: false,
                                );

                                if (plantScanRes.authenticatedAccount != null) {
                                  authAccount = plantScanRes.authenticatedAccount;
                                }
                                totalNew += plantScanRes.totalNewFiles;
                                totalMod += plantScanRes.totalModifiedFiles;
                                totalUnchanged += plantScanRes.totalUnchangedFiles;
                                combinedFactorySummaries.addAll(plantScanRes.factories);

                                if (plantScanRes.totalActionableFiles > 0) {
                                  final plantIngestionService = ExcelIngestionService(
                                    dbService: plantDbService,
                                    driveBridgeService: plantBridge,
                                  );

                                  final sub = plantIngestionService.onProgress.listen((prog) {
                                    setModalState(() {
                                      ingestionLogs.add(prog.message);
                                    });
                                  });

                                  await plantIngestionService.ingestScanResult(
                                    accessToken: token,
                                    scanResult: plantScanRes,
                                    driveApi: driveApi,
                                  );

                                  await sub.cancel();
                                }
                              }

                              setModalState(() {
                                scanResult = GoogleDriveScanResult(
                                  success: true,
                                  authenticatedAccount: authAccount ?? (client?.currentUserEmail ?? 'Google Account'),
                                  factories: combinedFactorySummaries,
                                  totalNewFiles: totalNew,
                                  totalModifiedFiles: totalMod,
                                  totalUnchangedFiles: totalUnchanged,
                                );
                                isScanning = false;
                              });
                              setState(() {});
                            },
                    ),
                  ),
                  if (scanResult != null) ...[
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          scanResult!.success
                              ? 'Scan Complete (New: ${scanResult!.totalNewFiles}, Mod: ${scanResult!.totalModifiedFiles}, Unchanged: ${scanResult!.totalUnchangedFiles})'
                              : 'Scan Failed',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: scanResult!.success ? Colors.green.shade800 : Colors.red.shade800),
                        ),
                        if (scanResult!.authenticatedAccount != null)
                          Text(
                            'Auth: ${scanResult!.authenticatedAccount}',
                            style: const TextStyle(fontSize: 11, color: Colors.grey),
                          ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    ...scanResult!.factories.entries.map((e) {
                      final f = e.value;
                      return Card(
                        elevation: 0,
                        margin: const EdgeInsets.only(bottom: 10),
                        color: const Color(0xFFF8FAFC),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: const BorderSide(color: AppColors.textPrimary),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '${distilleryService.factoryManager.plants.firstWhere((p) => p.code == f.factoryCode, orElse: () => distilleryService.factoryManager.activePlant).name} (${f.factoryCode})',
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1E3A8A)),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: f.statusCode == 'EXCEL_FOUND'
                                          ? Colors.green.shade50
                                          : (f.statusCode == 'EMPTY_FOLDER' ? Colors.blue.shade50 : Colors.amber.shade50),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      '${f.statusCode} (${f.files.length} Excel / ${f.totalItemsInFolder} items)',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: f.statusCode == 'EXCEL_FOUND'
                                            ? Colors.green.shade800
                                            : (f.statusCode == 'EMPTY_FOLDER' ? Colors.blue.shade800 : Colors.amber.shade900),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              if (f.diagnosticMessage != null)
                                Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Text(
                                    f.diagnosticMessage!,
                                    style: TextStyle(fontSize: 11, color: Colors.grey.shade700),
                                  ),
                                ),
                              if (f.folderId != null)
                                Padding(
                                  padding: const EdgeInsets.only(top: 2),
                                  child: Text(
                                    'Folder ID: ${f.folderId}',
                                    style: const TextStyle(fontSize: 10, color: Colors.grey, fontFamily: 'monospace'),
                                  ),
                                ),
                              ...f.files.map((file) => Container(
                                margin: const EdgeInsets.only(top: 6),
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: AppColors.textPrimary),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(Icons.table_chart_rounded, size: 16, color: Colors.green),
                                        const SizedBox(width: 6),
                                        Expanded(
                                          child: Text(file.fileName, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: file.syncStatus == 'NEW'
                                                ? Colors.blue.shade50
                                                : (file.syncStatus == 'MODIFIED' ? Colors.orange.shade50 : Colors.grey.shade100),
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: Text(
                                            file.syncStatus,
                                            style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                              color: file.syncStatus == 'NEW'
                                                  ? Colors.blue.shade800
                                                  : (file.syncStatus == 'MODIFIED' ? Colors.orange.shade900 : Colors.grey.shade700),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text('Drive ID: ${file.driveFileId}', style: const TextStyle(fontSize: 10, color: Colors.grey, fontFamily: 'monospace')),
                                    Text('Size: ${file.sizeBytes != null ? '${file.sizeBytes} bytes' : 'unknown'} | Modified: ${file.modifiedTime ?? 'unknown'}',
                                        style: const TextStyle(fontSize: 10, color: Colors.grey)),
                                  ],
                                ),
                              )),
                            ],
                          ),
                        ),
                      );
                    }),
                  ],
                  if (ingestionLogs.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    const Row(
                      children: [
                        Icon(Icons.terminal, size: 16, color: Color(0xFF1E3A8A)),
                        SizedBox(width: 6),
                        Text(
                          'Automatic Ingestion Pipeline Stream',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1E3A8A)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceDeep,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: ingestionLogs.map((log) {
                          Color textColor = Colors.greenAccent;
                          if (log.contains('[FAILED]') || log.contains('[ERROR]')) {
                            textColor = Colors.redAccent;
                          } else if (log.contains('[INGESTION]')) {
                            textColor = Colors.lightBlueAccent;
                          } else if (log.contains('[DATABASE]')) {
                            textColor = Colors.amberAccent;
                          }
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Text(
                              log,
                              style: TextStyle(fontFamily: 'monospace', fontSize: 11, color: textColor),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                  const SizedBox(height: 10),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isCompact = screenWidth < 720;
    final selectedTable = _tables[_selectedTableIndex];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.surfaceDeep,
        foregroundColor: Colors.white,
        elevation: 1,
        title: Row(
          children: [
            const Icon(Icons.local_bar_rounded, color: Colors.amberAccent, size: 22),
            const SizedBox(width: 10),
            Expanded(
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: distilleryService.factoryManager.activePlantCode,
                  dropdownColor: const Color(0xFF1E293B),
                  icon: const Icon(Icons.arrow_drop_down, color: Colors.amberAccent),
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                  isExpanded: true,
                  items: distilleryService.factoryManager.plants.map((plant) {
                    return DropdownMenuItem<String>(
                      value: plant.code,
                      child: Row(
                        children: [
                          const Icon(Icons.factory_rounded, size: 16, color: Colors.amberAccent),
                          const SizedBox(width: 8),
                          Text('${plant.name} [${plant.dbFileName}]', overflow: TextOverflow.ellipsis),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (newCode) {
                    if (newCode != null) {
                      setState(() {
                        distilleryService.factoryManager.setActivePlant(newCode);
                      });
                    }
                  },
                ),
              ),
            ),
          ],
        ),
        actions: [
          if (kDebugMode)
            IconButton(
              icon: const Icon(Icons.cleaning_services_rounded, color: Colors.orangeAccent),
              tooltip: 'Development Database Reset (All 5 DBs)',
              onPressed: () async {
                final messenger = ScaffoldMessenger.of(context);
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Development Database Reset'),
                    content: const Text('Are you sure you want to clear all test data across all 5 factory databases? Schema and factory metadata will be preserved.'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                        onPressed: () => Navigator.pop(ctx, true),
                        child: const Text('Reset All 5 DBs'),
                      ),
                    ],
                  ),
                );
                if (confirm == true) {
                  await _executeOnDeviceDevelopmentReset(distilleryService.factoryManager);
                  setState(() {});
                  messenger.showSnackBar(
                    const SnackBar(content: Text('All 5 development databases reset successfully!'), backgroundColor: Colors.green),
                  );
                }
              },
            ),
          IconButton(
            icon: const Icon(Icons.sync_rounded, color: Colors.cyanAccent),
            tooltip: 'Trigger Background Worker (WorkManager One-Off)',
            onPressed: () async {
              final messenger = ScaffoldMessenger.of(context);
              await DistilleryBackgroundWorker.triggerImmediateSync();
              messenger.showSnackBar(
                const SnackBar(
                  content: Text('Triggered WorkManager background worker task! Check logs.'),
                  backgroundColor: Colors.indigo,
                ),
              );
            },
          ),
          if (kDebugMode)
            IconButton(
              icon: const Icon(Icons.backup_rounded, color: Colors.lightGreenAccent),
              tooltip: 'Backup ${activePlant.name} Now',
              onPressed: _showGoogleDriveModal,
            ),
          IconButton(
            icon: const Icon(Icons.document_scanner_rounded),
            tooltip: 'Scan Google Drive & Ingestion',
            onPressed: _showPythonScannerModal,
          ),
          IconButton(
            icon: const Icon(Icons.cloud_upload_rounded),
            tooltip: 'Google Drive Backup',
            onPressed: _showGoogleDriveModal,
          ),
        ],
      ),
      body: Row(
        children: [
          // Sidebar Table Navigator
          NavigationRail(
            backgroundColor: const Color(0xFF1E293B),
            selectedIndex: _selectedTableIndex,
            onDestinationSelected: (index) {
              setState(() => _selectedTableIndex = index);
            },
            labelType: isCompact ? NavigationRailLabelType.none : NavigationRailLabelType.all,
            selectedIconTheme: const IconThemeData(color: Colors.amberAccent),
            unselectedIconTheme: const IconThemeData(color: Colors.white60),
            selectedLabelTextStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11),
            unselectedLabelTextStyle: const TextStyle(color: Colors.white60, fontSize: 10),
            destinations: _tables.map((t) {
              return NavigationRailDestination(
                icon: Icon(t['icon'] as IconData),
                label: Text(t['name'] as String),
              );
            }).toList(),
          ),
          const VerticalDivider(thickness: 1, width: 1, color: Color(0xFF334155)),
          // Main Table Content
          Expanded(
            child: Container(
              color: const Color(0xFFF8FAFC),
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(selectedTable['icon'] as IconData, color: const Color(0xFF1E3A8A), size: 24),
                                const SizedBox(width: 8),
                                Flexible(
                                  child: Text(
                                    '${activePlant.name} - ${selectedTable['name']}',
                                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.surfaceDeep),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              'Active SQLite DB: ${activePlant.dbFileName} | Region: ${activePlant.stateRegion}',
                              style: const TextStyle(fontSize: 11, color: Colors.grey),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1E3A8A),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        icon: const Icon(Icons.refresh_rounded, size: 16),
                        label: const Text('Refresh'),
                        onPressed: () => setState(() {}),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: const BorderSide(color: AppColors.textPrimary),
                      ),
                      color: Colors.white,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: _buildTableViewer(selectedTable['code'] as String),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableViewer(String tableCode) {
    switch (tableCode) {
      case 'factories':
        return _buildGenericStreamTable(
          stream: dbService.factories.watchAllFactories(),
          columns: const ['ID', 'Code', 'Name', 'Drive Folder ID', 'Active'],
          rowMapper: (f) => [
            f.id.toString(),
            f.factoryCode,
            f.factoryName,
            f.driveFolderId,
            f.isActive.toString(),
          ],
        );
      case 'input_files':
        return _buildGenericStreamTable(
          stream: dbService.inputFiles.watchAllFiles(),
          columns: const ['ID', 'Factory', 'File Name', 'Drive ID', 'Status', 'Drive Modified', 'First Seen', 'Processed At'],
          rowMapper: (f) => [
            f.id.toString(),
            'F0${f.factoryId}',
            f.fileName,
            f.driveFileId,
            f.status,
            f.driveModifiedAt?.toIso8601String() ?? '-',
            f.firstSeenAt?.toIso8601String() ?? '-',
            f.lastProcessedAt?.toIso8601String() ?? '-',
          ],
        );
      case 'batches':
        return _buildGenericStreamTable(
          stream: dbService.batches.getAllBatches().asStream(),
          columns: const ['ID', 'Batch ID', 'Fermenter', 'State', 'Start Time', 'End Time', 'Created At'],
          rowMapper: (b) => [
            b.id.toString(),
            b.batchId,
            b.fermenter ?? '-',
            b.state ?? '-',
            b.batchStartTime?.toIso8601String() ?? '-',
            b.batchEndTime?.toIso8601String() ?? '-',
            b.createdAt.toIso8601String(),
          ],
        );
      case 'processing_runs':
        return _buildGenericStreamTable(
          stream: dbService.processingRuns.getAllRuns().asStream(),
          columns: const ['ID', 'Input File ID', 'Batch ID', 'Status', 'Records Processed', 'Started At', 'Completed At'],
          rowMapper: (r) => [
            r.id.toString(),
            r.inputFileId.toString(),
            r.batchId?.toString() ?? '-',
            r.status,
            r.recordsProcessed?.toString() ?? '0',
            r.startedAt.toIso8601String(),
            r.completedAt?.toIso8601String() ?? '-',
          ],
        );
      case 'preprocessing_data':
        return _buildGenericStreamTable(
          stream: dbService.db.select(dbService.db.preprocessingData).get().asStream(),
          columns: const ['ID', 'Batch ID', 'Timestamp', 'Temp (°C)', 'Brix', 'Residual Sugar', 'Sugar Rate', 'Setup SG', 'Cooling Valve'],
          rowMapper: (p) => [
            p.id.toString(),
            p.batchId.toString(),
            p.timestampMinute?.toIso8601String() ?? '-',
            p.temperature?.toStringAsFixed(1) ?? '-',
            p.brix?.toStringAsFixed(1) ?? '-',
            p.residualSugar?.toStringAsFixed(2) ?? '-',
            p.sugarConsumptionRate?.toStringAsFixed(2) ?? '-',
            p.setupSg?.toStringAsFixed(3) ?? '-',
            p.coolingValve?.toStringAsFixed(1) ?? '-',
          ],
        );
      case 'ai_models':
        return _buildGenericStreamTable(
          stream: dbService.aiModels.getAllModels().asStream(),
          columns: const ['ID', 'Model Name', 'Version', 'Type', 'Active', 'Created At'],
          rowMapper: (m) => [
            m.id.toString(),
            m.modelName,
            m.modelVersion,
            m.modelType,
            m.isActive.toString(),
            m.createdAt.toIso8601String(),
          ],
        );
      case 'predictions':
        return _buildGenericStreamTable(
          stream: dbService.predictions.getAllPredictions().asStream(),
          columns: const ['ID', 'Batch ID', 'Label', 'Confidence', 'Pred Efficiency', 'Actual Efficiency'],
          rowMapper: (p) => [
            p.id.toString(),
            p.batchId.toString(),
            p.predictionLabel,
            p.predictionConfidence?.toStringAsFixed(2) ?? '-',
            p.predictedFermenterEfficiency?.toStringAsFixed(2) ?? '-',
            p.actualFermenterEfficiency?.toStringAsFixed(2) ?? '-',
          ],
        );
      case 'mqtt_publish_log':
        return _buildGenericStreamTable(
          stream: dbService.mqttPublishLog.getAllLogs().asStream(),
          columns: const ['ID', 'Topic', 'QoS', 'Status', 'Published At', 'Retry Count'],
          rowMapper: (l) => [
            l.id.toString(),
            l.topic,
            l.qos.toString(),
            l.status,
            l.publishedAt.toIso8601String(),
            l.retryCount.toString(),
          ],
        );
      case 'backup_history':
        return _buildGenericStreamTable(
          stream: dbService.backupHistory.getAllBackups().asStream(),
          columns: const ['ID', 'File Name', 'Location', 'Cloud Provider', 'Size (Bytes)', 'Status', 'Started At'],
          rowMapper: (b) => [
            b.id.toString(),
            b.backupFileName,
            b.backupLocation,
            b.cloudProvider,
            b.databaseSizeBytes?.toString() ?? '-',
            b.status,
            b.backupStartedAt.toIso8601String(),
          ],
        );
      default:
        return const Center(child: Text('Select a table from sidebar'));
    }
  }

  Widget _buildGenericStreamTable<T>({
    required Stream<List<T>> stream,
    required List<String> columns,
    required List<String> Function(T) rowMapper,
  }) {
    return StreamBuilder<List<T>>(
      stream: stream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error loading table: ${snapshot.error}'));
        }

        final data = snapshot.data ?? [];
        if (data.isEmpty) {
          return const Center(
            child: Text('No records in this SQLite table yet.', style: TextStyle(color: Colors.grey)),
          );
        }

        return SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowColor: WidgetStateProperty.all(const Color(0xFFF1F5F9)),
              columns: columns.map((c) => DataColumn(label: Text(c, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)))).toList(),
              rows: data.map((item) {
                final cells = rowMapper(item);
                return DataRow(
                  cells: cells.map((val) => DataCell(Text(val, style: const TextStyle(fontSize: 11)))).toList(),
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }
}


Future<void> _executeOnDeviceDevelopmentReset(FactoryDatabaseManager factoryManager) async {
  print('\n===============================================================');
  print('  STEP 5A ? DEVELOPMENT DATABASE RESET (5 FACTORY DATABASES)');
  print('===============================================================');

  try {
    final appDir = await getApplicationSupportDirectory();

    for (final plant in factoryManager.plants) {
      final dbPath = p.join(appDir.path, plant.dbFileName);
      final dbService = factoryManager.getDatabaseForPlant(plant.code);

      // 1. Read Before Counts
      final beforeFiles = (await dbService.inputFiles.getAllFiles()).length;
      final beforeBatches = (await dbService.batches.getAllBatches()).length;
      final beforeRuns = (await dbService.processingRuns.getAllRuns()).length;
      final beforeData = (await dbService.preprocessingData.getAllRecords()).length;
      final beforePredictions = (await dbService.predictions.getAllPredictions()).length;
      final beforeLogs = (await dbService.mqttPublishLog.getAllLogs()).length;
      final beforeBackups = (await dbService.backupHistory.getAllBackups()).length;

      // 2. Perform Foreign-Key-Safe Atomic Reset
      await dbService.developmentResetDatabase();
      await factoryManager.initializeAll(); // Ensures factory record is intact

      // 3. Read After Counts
      final afterFactories = (await dbService.factories.getAllFactories()).length;
      final afterFiles = (await dbService.inputFiles.getAllFiles()).length;
      final afterBatches = (await dbService.batches.getAllBatches()).length;
      final afterRuns = (await dbService.processingRuns.getAllRuns()).length;
      final afterData = (await dbService.preprocessingData.getAllRecords()).length;
      final afterPredictions = (await dbService.predictions.getAllPredictions()).length;
      final afterLogs = (await dbService.mqttPublishLog.getAllLogs()).length;
      final afterBackups = (await dbService.backupHistory.getAllBackups()).length;

      final integrity = await dbService.db.customSelect('PRAGMA integrity_check;').getSingle();
      final integrityStatus = integrity.read<String>('integrity_check');
      final fkViolations = await dbService.db.customSelect('PRAGMA foreign_key_check;').get();

      print('? [FACTORY ${plant.code}] ${plant.name} (${plant.stateRegion})');
      print('   - Runtime DB Path : $dbPath');
      print('   - BEFORE Reset    : files=$beforeFiles, batches=$beforeBatches, runs=$beforeRuns, data=$beforeData, predictions=$beforePredictions, mqtt=$beforeLogs, backups=$beforeBackups');
      print('   - AFTER Reset     : factories=$afterFactories (PRESERVED), files=$afterFiles, batches=$afterBatches, runs=$afterRuns, data=$afterData, predictions=$afterPredictions, mqtt=$afterLogs, backups=$afterBackups');
      print('   - Integrity       : $integrityStatus | FK Violations: ${fkViolations.length}');
      print('   - Next Scan State : input_files cleared -> ALL DRIVE FILES WILL CLASSIFY AS NEW');
    }

    print('===============================================================\n');
  } catch (e, stack) {
    print('! Development Database Reset Error: $e\n$stack');
  }
}
