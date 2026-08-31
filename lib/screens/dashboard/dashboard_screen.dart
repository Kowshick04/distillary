import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import '../../services/sse_telemetry_service.dart';
import '../../models/telemetry_data_model.dart';
import '../../widgets/common/glass_card.dart';
import '../../widgets/dashboard/liquid_tank_card.dart';
import '../../widgets/dashboard/ai_operator_advisor.dart';
import '../../widgets/dashboard/plant_kpis_panel.dart';
import '../../widgets/dashboard/golden_batch_possibility.dart';
import '../../widgets/assistant/ayam_bot_assist.dart';
import 'distillery_overview_screen.dart';
import '../login/login_screen.dart';
import '../../models/distillery_snapshot_model.dart';
import '../../services/distillery_snapshot_store.dart';
import '../../services/local_pipeline_service.dart';
import '../../services/random_forest_predictor.dart';
import '../../utils/app_colors.dart';

class DashboardScreen extends StatefulWidget {
  final String role;
  final String factoryCode;
  const DashboardScreen({super.key, required this.role, this.factoryCode = 'F01'});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late SseTelemetryService _telemetryService;
  StreamSubscription<TelemetryDataModel>? _telemetrySubscription;
  StreamSubscription<TelemetryDataModel>? _localTelemetrySubscription;
  StreamSubscription<PipelineStatus>? _statusSubscription;
  PipelineStatus _pipelineStatus = const PipelineStatus(
    type: PipelineStatusType.idle,
    message: 'Initialising scanner...',
  );
  String _excelSyncState = 'scanning';
  bool _showScanStatusBanner = true;
  bool _isSimulatedScanning = true;
  late List<List<Map<String, dynamic>>> _factoriesVessels;
  int _selectedFactoryIndex = 0;
  String _currentView = 'dashboard'; // 'dashboard', 'ledger', or 'overview'
  TelemetryDataModel? _latestTelemetry;

  // Live clock
  late Timer _clockTimer;
  String _currentTime = '';
  String _currentDate = '';
  String _lastSyncTime = 'None (Waiting for upload)';
  bool _isRefreshing = false;
  Set<String> _syncedFactories = {}; // True after first real SSE data packet is received
  Timer? _autoRefreshTimer;

  // Fermenters State Data mapping Section 1
  int _selectedFermenterIndex = 2; // Default select Fermenter 3 (infected)

  // Blank "awaiting sync" placeholders â€” all values are zero until the first
  // real SSE data packet arrives from the backend sync daemon.
  static Map<String, dynamic> _awaitingSyncEntry(int idx) => {
    'title': 'Fermentation ${idx + 1}',
    'levelFactor': 0.0,
    'stateText': 'AWAITING SYNC',
    'temperature': 0.0,
    'ph': 0.0,
    'brix': 0.0,
    'qualityFlag': '--',
    'confidence': 0.0,
    'isRecoverable': true,
    'volatileAcidityPpm': 0.0,
    'yeastCount': 0.0,
    'alcohol': 0.0,
    'fermentationEfficiency': 0.0,
    'isEmpty': true,
    'qcActions': <QCEntry>[],
    'brixHistory': <double>[],
    'alcoholHistory': <double>[],
    'tempHistory': <double>[],
  } as Map<String, dynamic>;



  List<QCEntry> getQcActions(double ph, double brix, double temperature, String label) {
    final List<QCEntry> actions = [];
    if (label == 'golden') {
      actions.add(QCEntry(action: 'Maintain current parameters', description: 'Batch parameters are in alignment with golden profile.'));
    } else {
      if (ph > 5.0) {
        actions.add(QCEntry(action: 'Add Sulfuric Acid buffer', description: 'Adjust pH down to target 4.8.'));
      } else if (ph < 4.3) {
        actions.add(QCEntry(action: 'Add Ammonium Hydroxide buffer', description: 'Adjust pH up to target 4.8.'));
      }
      if (temperature > 34.0) {
        actions.add(QCEntry(action: 'Increase cooling water flow rate', description: 'Temperature is elevated, cooling required.'));
      }
      if (brix > 7.0) {
        actions.add(QCEntry(action: 'Check yeast viability', description: 'High residual brix indicates stalling.'));
      }
    }
    return actions;
  }

  void _handleTelemetryPacket(TelemetryDataModel packet) {
    if (_isSimulatedScanning) {
      localPipelineService.lastEmittedPackets[packet.factoryCode] = packet;
      return;
    }
    if (mounted) {
        final String packetFactory = packet.factoryCode;
        final int packetFactoryIdx = (() {
          if (packetFactory == 'F02') return 1;
          if (packetFactory == 'F03') return 2;
          if (packetFactory == 'F04') return 3;
          if (packetFactory == 'F05') return 4;
          return 0; // Default F01
        })();

        if (packet.state == 'DRIVE_INGEST') {
          _showGoogleDriveIngestNotification(packet);
          // Push a new distillery snapshot tagged by factory code
          distillerySnapshotStore.pushSnapshot(
            packetFactory,
            DistilleryExcelSnapshot.fromTelemetry(
                feedRate: packet.feedRate > 0 ? packet.feedRate : 59.2,
                analyserTemp: packet.analyserTemp > 0 ? packet.analyserTemp : 78.7,
                productAlcohol: packet.productAlcoholFinal > 0 ? packet.productAlcoholFinal : 97.6,
                washAlcohol: packet.washAlcoholFeed > 0 ? packet.washAlcoholFeed : 9.5,
                recovery: (95.0 + (packet.productAlcoholFinal - 95.0) * 0.5).clamp(92.0, 99.8),
                loss: packet.alcoholLossSpentwash > 0 ? packet.alcoholLossSpentwash : 0.05,
                bottomBrix: packet.bottomSpentwashBrix > 0 ? packet.bottomSpentwashBrix : 4.6,
                pressure: 0.63 + (packet.fermenterPowerKw - 28.0) * 0.001,
                vacuum: -0.62 + (packet.coolingWaterFlowLpm - 400.0) * -0.0001,
                dp: 0.22 + (packet.steamConsumptionKgph - 92.0) * 0.0003,
                spentWashKl: packet.spentwashRecycle > 0 ? packet.spentwashRecycle : 6.0,
                reboilerTemp: (packet.analyserTemp > 0 ? packet.analyserTemp : 78.7) - 0.1,
              ),
            );
        }
        setState(() {
          _syncedFactories.add(packet.factoryCode); // Mark that real synced data has been received
          if (packet.state == 'DRIVE_INGEST') {
            _lastSyncTime = packet.serverTimestamp;
            if (_excelSyncState == 'loaded') {
              _excelSyncState = 'synced';
              Future.delayed(const Duration(milliseconds: 1500), () {
                if (mounted) {
                  setState(() {
                    _excelSyncState = 'loaded';
                  });
                }
              });
            }
          }
          _latestTelemetry = packet;
          final int vesselIdx = (packet.fermenter - 1).clamp(0, 3);
          final String label = packet.predictionLabel.toLowerCase();
          final double yeastVal = packet.agitatorHealthScore * 3.0;
          final double vaVal = packet.batchQualityScore > 75 ? 1100.0 : 2100.0;
          
          for (int f = 0; f < 5; f++) {
            if (widget.role.startsWith('operator')) {
              final int opIndex = (int.tryParse(widget.role.substring(8)) ?? 1) - 1;
              if (f != opIndex) continue;
            }
            
            // Only update the vessel data for the factory that sent this telemetry packet
            if (f != packetFactoryIdx) continue;
            
            if (packet.fermentersList.isNotEmpty) {
              for (int i = 0; i < packet.fermentersList.length; i++) {
                final fItem = packet.fermentersList[i];
                if (fItem.status == 'AWAITING_SYNC') {
                  _factoriesVessels[f][i] = {
                    'title': 'Fermentation ${i + 1}',
                    'levelFactor': 0.0,
                    'stateText': 'STANDBY',
                    'temperature': 0.0,
                    'ph': 0.0,
                    'brix': 0.0,
                    'qualityFlag': 'AWAITING SYNC',
                    'confidence': 0.0,
                    'isRecoverable': true,
                    'volatileAcidityPpm': 0.0,
                    'yeastCount': 0.0,
                    'alcohol': 0.0,
                    'fermentationEfficiency': 0.0,
                    'isEmpty': true,
                    'qcActions': const <QCEntry>[],
                    'brixHistory': <double>[],
                    'alcoholHistory': <double>[],
                    'tempHistory': <double>[],
                  };
                } else {
                  final List<double> bHist = List<double>.from(_factoriesVessels[f][i]['brixHistory'] ?? []);
                  final List<double> aHist = List<double>.from(_factoriesVessels[f][i]['alcoholHistory'] ?? []);
                  final List<double> tHist = List<double>.from(_factoriesVessels[f][i]['tempHistory'] ?? []);

                  bHist.add(fItem.brix);
                  aHist.add(packet.alcohol);
                  tHist.add(fItem.temp);

                  if (bHist.length > 24) bHist.removeAt(0);
                  if (aHist.length > 24) aHist.removeAt(0);
                  if (tHist.length > 24) tHist.removeAt(0);

                  final String fLabel = fItem.status.toLowerCase();
                  final double fConfidence = packet.predictionConfidence / 100.0;
                  final double fYeast = double.tryParse(fItem.yeast.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 320.0;
                  final double fVa = double.tryParse(fItem.va.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 80.0;

                  _factoriesVessels[f][i] = {
                    'title': 'Fermentation ${fItem.id}',
                    'levelFactor': (fItem.vol / 100.0).clamp(0.0, 1.0),
                    'stateText': fItem.subStatus.isEmpty ? 'FERMENTING' : fItem.subStatus.toUpperCase(),
                    'temperature': fItem.temp,
                    'ph': fItem.ph,
                    'brix': fItem.brix,
                    'qualityFlag': fItem.status == 'GOLDEN' ? 'GOLDEN BATCH' : fItem.status.toUpperCase(),
                    'confidence': fConfidence,
                    'isRecoverable': fItem.status.toLowerCase() != 'infection',
                    'volatileAcidityPpm': fVa * 20.0,
                    'yeastCount': fYeast,
                    'alcohol': packet.alcohol,
                    'fermentationEfficiency': packet.fermentationEfficiency,
                    'isEmpty': false,
                    'qcActions': getQcActions(fItem.ph, fItem.brix, fItem.temp, fLabel),
                    'brixHistory': bHist,
                    'alcoholHistory': aHist,
                    'tempHistory': tHist,
                  };
                }
              }
            } else {
              final double tempOffset = (f - 2) * 0.4;
              final double phOffset = (f - 2) * 0.05;
              final double brixOffset = (f - 2) * 0.2;
              
              final List<double> bHist = List<double>.from(_factoriesVessels[f][vesselIdx]['brixHistory'] ?? []);
              final List<double> aHist = List<double>.from(_factoriesVessels[f][vesselIdx]['alcoholHistory'] ?? []);
              final List<double> tHist = List<double>.from(_factoriesVessels[f][vesselIdx]['tempHistory'] ?? []);
              
              final double currentBrix = (packet.brix + brixOffset).clamp(1.0, 15.0);
              final double currentTemp = (packet.temperature + tempOffset).clamp(30.0, 36.0);
              final double currentPh = (packet.ph + phOffset).clamp(4.2, 5.2);
              
              bHist.add(currentBrix);
              aHist.add(packet.alcohol);
              tHist.add(currentTemp);
              
              if (bHist.length > 24) bHist.removeAt(0);
              if (aHist.length > 24) aHist.removeAt(0);
              if (tHist.length > 24) tHist.removeAt(0);

              _factoriesVessels[f][vesselIdx] = {
                'title': 'Fermentation ${vesselIdx + 1}',
                'levelFactor': (packet.fermentationEfficiency / 100.0).clamp(0.0, 1.0),
                'stateText': packet.state == 'DRIVE_INGEST' ? 'FERMENTING' : packet.state,
                'temperature': currentTemp,
                'ph': currentPh,
                'brix': currentBrix,
                'qualityFlag': label == 'golden' ? 'GOLDEN BATCH' : label.toUpperCase(),
                'confidence': packet.predictionConfidence / 100.0,
                'isRecoverable': label != 'low_alcohol',
                'volatileAcidityPpm': vaVal,
                'yeastCount': yeastVal,
                'alcohol': packet.alcohol,
                'fermentationEfficiency': packet.fermentationEfficiency,
                'isEmpty': packet.state == 'IDLE' || packet.state == 'STANDBY',
                'qcActions': getQcActions(currentPh, currentBrix, currentTemp, label),
                'brixHistory': bHist,
                'alcoholHistory': aHist,
                'tempHistory': tHist,
              };
            }
          }
        });
      }
  }


  Widget _buildAwaitingSyncOverlay(String factoryCode) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 8),
      child: GlassCard(
        padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppColors.cyan.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.cloud_sync_rounded,
                  color: AppColors.cyan,
                  size: 40,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Awaiting Data Sync ($factoryCode)',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 8),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: const Text(
                  'Dashboard shows live fermenter and distillation data after the first Excel sync from Google Drive. Please upload an Excel sheet to begin.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }




  void _showGoogleDriveIngestNotification(TelemetryDataModel packet) {
    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (context) {
        return Positioned(
          top: 24,
          right: 24,
          child: Material(
            color: Colors.transparent,
            child: TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 300),
              tween: Tween(begin: 0.0, end: 1.0),
              builder: (context, value, child) {
                return Opacity(
                  opacity: value,
                  child: Transform.translate(
                    offset: Offset(0, (1 - value) * -20),
                    child: child,
                  ),
                );
              },
              child: Container(
                width: 340,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surfaceDeep.withValues(alpha: 0.85),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.cyan.withValues(alpha: 0.4),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.cyan.withValues(alpha: 0.15),
                      blurRadius: 16,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.cyan.withOpacity(0.12),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.cloud_download_rounded,
                        color: AppColors.cyan,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'NEW EXCEL INGESTION',
                            style: TextStyle(
                              color: AppColors.cyan,
                              fontWeight: FontWeight.bold,
                              fontSize: 10,
                              letterSpacing: 1.0,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Google Drive Excel sheet processed successfully for Fermenter ${packet.fermenter}!',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: packet.predictionLabel.toUpperCase() == 'GOLDEN BATCH'
                                      ? AppColors.amber.withOpacity(0.12)
                                      : AppColors.blue.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(
                                    color: packet.predictionLabel.toUpperCase() == 'GOLDEN BATCH'
                                        ? AppColors.amber.withOpacity(0.3)
                                        : AppColors.blue.withOpacity(0.3),
                                  ),
                                ),
                                child: Text(
                                  packet.predictionLabel.toUpperCase(),
                                  style: TextStyle(
                                    color: packet.predictionLabel.toUpperCase() == 'GOLDEN BATCH'
                                        ? AppColors.amber
                                        : AppColors.blue,
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Confidence: ${packet.predictionConfidence.toStringAsFixed(1)}%',
                                style: const TextStyle(
                                  color: AppColors.textMuted,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () => entry.remove(),
                      child: const Icon(
                        Icons.close_rounded,
                        color: AppColors.textMuted,
                        size: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );

    Overlay.of(context).insert(entry);

    // Auto remove after 5 seconds
    Future.delayed(const Duration(seconds: 5), () {
      if (entry.mounted) {
        entry.remove();
      }
    });
  }

  Future<void> _handleManualRefresh() async {
    if (_isRefreshing) return;
    setState(() {
      _isRefreshing = true;
    });

    final String factoryCode = const ['F01', 'F02', 'F03', 'F04', 'F05'][_selectedFactoryIndex];
    final packets = await _telemetryService.fetchSnapshots(factoryCode);

    if (mounted) {
      setState(() {
        _isRefreshing = false;
        if (packets.isNotEmpty) {
          final packet = packets.first;
          _syncedFactories.add(packet.factoryCode); // Dismiss awaiting sync overlay
          _lastSyncTime = packet.serverTimestamp;
          _latestTelemetry = packet;

          final int vesselIdx = (packet.fermenter - 1).clamp(0, 3);
          final int packetFactoryIdx = _selectedFactoryIndex;

          final double tempOffset = (packetFactoryIdx - 2) * 0.4;
          final double phOffset = (packetFactoryIdx - 2) * 0.05;
          final double brixOffset = (packetFactoryIdx - 2) * 0.2;

          final double currentBrix = (packet.brix + brixOffset).clamp(1.0, 15.0);
          final double currentTemp = (packet.temperature + tempOffset).clamp(30.0, 36.0);
          final double currentPh = (packet.ph + phOffset).clamp(4.2, 5.2);

          final List<double> bHist = List<double>.from(_factoriesVessels[packetFactoryIdx][vesselIdx]['brixHistory'] ?? []);
          final List<double> aHist = List<double>.from(_factoriesVessels[packetFactoryIdx][vesselIdx]['alcoholHistory'] ?? []);
          final List<double> tHist = List<double>.from(_factoriesVessels[packetFactoryIdx][vesselIdx]['tempHistory'] ?? []);

          if (bHist.length >= 20) bHist.removeAt(0);
          if (aHist.length >= 20) aHist.removeAt(0);
          if (tHist.length >= 20) tHist.removeAt(0);

          bHist.add(currentBrix);
          aHist.add(packet.alcohol);
          tHist.add(currentTemp);

          _factoriesVessels[packetFactoryIdx][vesselIdx] = {
            'title': 'Fermentation ${vesselIdx + 1}',
            'levelFactor': (packet.fermentationEfficiency / 100.0).clamp(0.0, 1.0),
            'stateText': 'FERMENTING',
            'temperature': currentTemp,
            'ph': currentPh,
            'brix': currentBrix,
            'qualityFlag': packet.predictionLabel.toLowerCase() == 'golden' ? 'GOLDEN BATCH' : packet.predictionLabel.toUpperCase(),
            'confidence': packet.predictionConfidence / 100.0,
            'isRecoverable': packet.predictionLabel.toLowerCase() != 'low_alcohol',
            'volatileAcidityPpm': packet.batchQualityScore > 75 ? 1100.0 : 2100.0,
            'yeastCount': packet.agitatorHealthScore * 3.0,
            'alcohol': packet.alcohol,
            'fermentationEfficiency': packet.fermentationEfficiency,
            'isEmpty': false,
            'qcActions': getQcActions(currentPh, currentBrix, currentTemp, packet.predictionLabel.toLowerCase()),
            'brixHistory': bHist,
            'alcoholHistory': aHist,
            'tempHistory': tHist,
          };

          // Update secondary active vessel for manual refresh too
          final int vesselIdx2 = (vesselIdx + 2) % 4;
          final double currentBrix2 = (currentBrix - 1.2).clamp(1.0, 15.0);
          final double currentTemp2 = (currentTemp + 0.6).clamp(30.0, 36.0);
          final double currentPh2 = (currentPh - 0.15).clamp(4.2, 5.2);
          final double yeastVal2 = ((packet.agitatorHealthScore * 3.0) - 2.5).clamp(10.0, 300.0);
          final double vaVal2 = (packet.batchQualityScore > 75 ? 1100.0 : 2100.0) == 1100.0 ? 1500.0 : 1100.0;
          final String label2 = packet.predictionLabel.toLowerCase() == 'golden' ? 'normal' : 'golden';

          final List<double> bHist2 = List<double>.from(_factoriesVessels[packetFactoryIdx][vesselIdx2]['brixHistory'] ?? []);
          final List<double> aHist2 = List<double>.from(_factoriesVessels[packetFactoryIdx][vesselIdx2]['alcoholHistory'] ?? []);
          final List<double> tHist2 = List<double>.from(_factoriesVessels[packetFactoryIdx][vesselIdx2]['tempHistory'] ?? []);

          bHist2.add(currentBrix2);
          aHist2.add(packet.alcohol - 0.8);
          tHist2.add(currentTemp2);

          if (bHist2.length >= 20) bHist2.removeAt(0);
          if (aHist2.length >= 20) aHist2.removeAt(0);
          if (tHist2.length >= 20) tHist2.removeAt(0);

          _factoriesVessels[packetFactoryIdx][vesselIdx2] = {
            'title': 'Fermentation ${vesselIdx2 + 1}',
            'levelFactor': ((packet.fermentationEfficiency - 12.0) / 100.0).clamp(0.0, 1.0),
            'stateText': 'FERMENTING',
            'temperature': currentTemp2,
            'ph': currentPh2,
            'brix': currentBrix2,
            'qualityFlag': label2 == 'golden' ? 'GOLDEN BATCH' : label2.toUpperCase(),
            'confidence': (packet.predictionConfidence - 10.0) / 100.0,
            'isRecoverable': label2 != 'low_alcohol',
            'volatileAcidityPpm': vaVal2,
            'yeastCount': yeastVal2,
            'alcohol': packet.alcohol - 0.8,
            'fermentationEfficiency': packet.fermentationEfficiency - 12.0,
            'isEmpty': false,
            'qcActions': getQcActions(currentPh2, currentBrix2, currentTemp2, label2),
            'brixHistory': bHist2,
            'alcoholHistory': aHist2,
            'tempHistory': tHist2,
          };

          if (packets.length >= 2) {
            distillerySnapshotStore.pushSnapshot(
              factoryCode,
              DistilleryExcelSnapshot.fromTelemetry(
                  feedRate: packets[1].feedRate > 0 ? packets[1].feedRate : 59.2,
                  analyserTemp: packets[1].analyserTemp > 0 ? packets[1].analyserTemp : 78.7,
                  productAlcohol: packets[1].productAlcoholFinal > 0 ? packets[1].productAlcoholFinal : 97.6,
                  washAlcohol: packets[1].washAlcoholFeed > 0 ? packets[1].washAlcoholFeed : 9.5,
                  recovery: (95.0 + (packets[1].productAlcoholFinal - 95.0) * 0.5).clamp(92.0, 99.8),
                  loss: packets[1].alcoholLossSpentwash > 0 ? packets[1].alcoholLossSpentwash : 0.05,
                  bottomBrix: packets[1].bottomSpentwashBrix > 0 ? packets[1].bottomSpentwashBrix : 4.6,
                  pressure: 0.63 + (packets[1].fermenterPowerKw - 28.0) * 0.001,
                  vacuum: -0.62 + (packets[1].coolingWaterFlowLpm - 400.0) * -0.0001,
                  dp: 0.22 + (packets[1].steamConsumptionKgph - 92.0) * 0.0003,
                  spentWashKl: packets[1].spentwashRecycle > 0 ? packets[1].spentwashRecycle : 6.0,
                  reboilerTemp: (packets[1].analyserTemp > 0 ? packets[1].analyserTemp : 78.7) - 0.1,
                ),
              );
          }
          
          distillerySnapshotStore.pushSnapshot(
            factoryCode,
            DistilleryExcelSnapshot.fromTelemetry(
                feedRate: packet.feedRate > 0 ? packet.feedRate : 59.2,
                analyserTemp: packet.analyserTemp > 0 ? packet.analyserTemp : 78.7,
                productAlcohol: packet.productAlcoholFinal > 0 ? packet.productAlcoholFinal : 97.6,
                washAlcohol: packet.washAlcoholFeed > 0 ? packet.washAlcoholFeed : 9.5,
                recovery: (95.0 + (packet.productAlcoholFinal - 95.0) * 0.5).clamp(92.0, 99.8),
                loss: packet.alcoholLossSpentwash > 0 ? packet.alcoholLossSpentwash : 0.05,
                bottomBrix: packet.bottomSpentwashBrix > 0 ? packet.bottomSpentwashBrix : 4.6,
                pressure: 0.63 + (packet.fermenterPowerKw - 28.0) * 0.001,
                vacuum: -0.62 + (packet.coolingWaterFlowLpm - 400.0) * -0.0001,
                dp: 0.22 + (packet.steamConsumptionKgph - 92.0) * 0.0003,
                spentWashKl: packet.spentwashRecycle > 0 ? packet.spentwashRecycle : 6.0,
                reboilerTemp: (packet.analyserTemp > 0 ? packet.analyserTemp : 78.7) - 0.1,
              ),
            );

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Dashboard successfully synced with latest database logs!'),
              backgroundColor: AppColors.cyan,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No database snapshots found for this factory.'),
              backgroundColor: Colors.amber,
            ),
          );
        }
      });
    }
  }

  @override
  void initState() {
    super.initState();
    
    _selectedFactoryIndex = (() {
      final code = widget.factoryCode;
      if (code == 'F02') return 1;
      if (code == 'F03') return 2;
      if (code == 'F04') return 3;
      if (code == 'F05') return 4;
      return 0;
    })();

    _factoriesVessels = List.generate(5, (fIdx) {
      // Start every vessel as blank â€” real values populate on first sync
      return List.generate(4, (vIdx) => _awaitingSyncEntry(vIdx));
    });

    _telemetryService = SseTelemetryService();
    _telemetryService.connect();

    _telemetrySubscription = _telemetryService.telemetryStream.listen((packet) {
      _handleTelemetryPacket(packet);
    });

    _localTelemetrySubscription = localPipelineService.telemetryStream.listen((packet) {
      _handleTelemetryPacket(packet);
    });
    
    // Process any packets already cached in the service with a simulated 1.5s scanning delay to show "Awaiting Data Sync" overlay first
    WidgetsBinding.instance.addPostFrameCallback((_) {
      print('DASHBOARD: Scheduling delayed cache load. Count = ${localPipelineService.lastEmittedPackets.length}');
      Future.delayed(const Duration(milliseconds: 1500), () {
        if (!mounted) return;
        
        print('DASHBOARD: Loading cached packets after scan delay...');
        // Disable simulation block to allow processing of telemetry packets
        _isSimulatedScanning = false;
        
        for (final packet in localPipelineService.lastEmittedPackets.values) {
          _handleTelemetryPacket(packet);
        }

        final String currentFactory = const ['F01', 'F02', 'F03', 'F04', 'F05'][_selectedFactoryIndex];
        final activePacket = localPipelineService.lastEmittedPackets[currentFactory];
        
        setState(() {
          if (activePacket != null) {
            _pipelineStatus = PipelineStatus(
              type: PipelineStatusType.fileLoaded,
              message: 'Loaded: ${activePacket.fileName} | Alcohol: ${activePacket.alcohol.toStringAsFixed(1)}% | ${activePacket.predictionLabel.toUpperCase()}',
              fileName: activePacket.fileName,
            );
            _excelSyncState = 'synced';
            _triggerBannerFadeOutTimer();
          } else {
            _pipelineStatus = const PipelineStatus(
              type: PipelineStatusType.scanning,
              message: 'Waiting for Excel files in Download folder...',
            );
            _excelSyncState = 'scanning';
          }
        });

        if (_excelSyncState == 'synced') {
          Future.delayed(const Duration(milliseconds: 1500), () {
            if (mounted) {
              setState(() {
                _excelSyncState = 'loaded';
              });
            }
          });
        }
      });
    });

    localPipelineService.startAutoScanning();

    _statusSubscription = localPipelineService.statusStream.listen((status) {
      if (mounted) {
        // Only override our display status if it is a new fileLoaded, an error, or if we are not currently displaying a fileLoaded status
        if (status.type == PipelineStatusType.fileLoaded ||
            status.type == PipelineStatusType.error ||
            status.type == PipelineStatusType.permissionDenied ||
            _pipelineStatus.type != PipelineStatusType.fileLoaded) {
          setState(() => _pipelineStatus = status);
          if (status.type == PipelineStatusType.fileLoaded) {
            _triggerBannerFadeOutTimer();
          }
        }
      }
    });

    // Live clock â€” updates every second
    _updateClock();
    _clockTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) _updateClock();
    });

    // Automatically load existing database snapshots for all factories on startup
    _loadInitialData();

    // Auto-refresh via fetchSnapshots is disabled — data arrives via LocalPipelineService
    // MQTT stream which has its own 10-second Excel scan cycle. No polling needed.
    // _autoRefreshTimer = Timer.periodic(const Duration(seconds: 5), (_) {
    //   _performAutoRefresh();
    // });
  }

  Future<void> _performAutoRefresh() async {
    if (_isRefreshing) return;
    final String factoryCode = const ['F01', 'F02', 'F03', 'F04', 'F05'][_selectedFactoryIndex];
    final packets = await _telemetryService.fetchSnapshots(factoryCode);

    if (mounted && packets.isNotEmpty) {
      setState(() {
        _syncedFactories.add(factoryCode);
        final packet = packets.first;
        _lastSyncTime = packet.serverTimestamp;
        _latestTelemetry = packet;

        final int vesselIdx = (packet.fermenter - 1).clamp(0, 3);
        final int packetFactoryIdx = _selectedFactoryIndex;

        final double tempOffset = (packetFactoryIdx - 2) * 0.4;
        final double phOffset = (packetFactoryIdx - 2) * 0.05;
        final double brixOffset = (packetFactoryIdx - 2) * 0.2;

        final double currentBrix = (packet.brix + brixOffset).clamp(1.0, 15.0);
        final double currentTemp = (packet.temperature + tempOffset).clamp(30.0, 36.0);
        final double currentPh = (packet.ph + phOffset).clamp(4.2, 5.2);

        final List<double> bHist = List<double>.from(_factoriesVessels[packetFactoryIdx][vesselIdx]['brixHistory'] ?? []);
        final List<double> aHist = List<double>.from(_factoriesVessels[packetFactoryIdx][vesselIdx]['alcoholHistory'] ?? []);
        final List<double> tHist = List<double>.from(_factoriesVessels[packetFactoryIdx][vesselIdx]['tempHistory'] ?? []);

        if (bHist.length >= 20) bHist.removeAt(0);
        if (aHist.length >= 20) aHist.removeAt(0);
        if (tHist.length >= 20) tHist.removeAt(0);

        bHist.add(currentBrix);
        aHist.add(packet.alcohol);
        tHist.add(currentTemp);

        _factoriesVessels[packetFactoryIdx][vesselIdx] = {
          'title': 'Fermentation ${vesselIdx + 1}',
          'levelFactor': (packet.fermentationEfficiency / 100.0).clamp(0.0, 1.0),
          'stateText': 'FERMENTING',
          'temperature': currentTemp,
          'ph': currentPh,
          'brix': currentBrix,
          'qualityFlag': packet.predictionLabel.toLowerCase() == 'golden' ? 'GOLDEN BATCH' : packet.predictionLabel.toUpperCase(),
          'confidence': packet.predictionConfidence / 100.0,
          'isRecoverable': packet.predictionLabel.toLowerCase() != 'low_alcohol',
          'volatileAcidityPpm': packet.batchQualityScore > 75 ? 1100.0 : 2100.0,
          'yeastCount': packet.agitatorHealthScore * 3.0,
          'alcohol': packet.alcohol,
          'fermentationEfficiency': packet.fermentationEfficiency,
          'isEmpty': false,
          'qcActions': getQcActions(currentPh, currentBrix, currentTemp, packet.predictionLabel.toLowerCase()),
          'brixHistory': bHist,
          'alcoholHistory': aHist,
          'tempHistory': tHist,
        };
      });
    }
  }

  Future<void> _loadInitialData() async {
    bool hasAnyData = false;
    for (int f = 0; f < 5; f++) {
      final String code = const ['F01', 'F02', 'F03', 'F04', 'F05'][f];
      final List<TelemetryDataModel> packets = await _telemetryService.fetchSnapshots(code);
      if (packets.isNotEmpty) {
        hasAnyData = true;
        // Populate the latest batch details for this factory
        final packet = packets.first;
        final int vesselIdx = (packet.fermenter - 1).clamp(0, 3);
        
        final double tempOffset = (f - 2) * 0.4;
        final double phOffset = (f - 2) * 0.05;
        final double brixOffset = (f - 2) * 0.2;

        final double currentBrix = (packet.brix + brixOffset).clamp(1.0, 15.0);
        final double currentTemp = (packet.temperature + tempOffset).clamp(30.0, 36.0);
        final double currentPh = (packet.ph + phOffset).clamp(4.2, 5.2);

        final List<double> bHist = [currentBrix];
        final List<double> aHist = [packet.alcohol];
        final List<double> tHist = [currentTemp];

        if (mounted) {
          setState(() {
            _factoriesVessels[f][vesselIdx] = {
              'title': 'Fermentation ${vesselIdx + 1}',
              'levelFactor': (packet.fermentationEfficiency / 100.0).clamp(0.0, 1.0),
              'stateText': 'FERMENTING',
              'temperature': currentTemp,
              'ph': currentPh,
              'brix': currentBrix,
              'qualityFlag': packet.predictionLabel.toLowerCase() == 'golden' ? 'GOLDEN BATCH' : packet.predictionLabel.toUpperCase(),
              'confidence': packet.predictionConfidence / 100.0,
              'isRecoverable': packet.predictionLabel.toLowerCase() != 'low_alcohol',
              'volatileAcidityPpm': packet.batchQualityScore > 75 ? 1100.0 : 2100.0,
              'yeastCount': packet.agitatorHealthScore * 3.0,
              'alcohol': packet.alcohol,
              'fermentationEfficiency': packet.fermentationEfficiency,
              'isEmpty': false,
              'qcActions': getQcActions(currentPh, currentBrix, currentTemp, packet.predictionLabel.toLowerCase()),
              'brixHistory': bHist,
              'alcoholHistory': aHist,
              'tempHistory': tHist,
            };

            _syncedFactories.add(code);
            // Set the active displayed telemetry for the initial factory view
            if (f == _selectedFactoryIndex && _latestTelemetry == null) {
              _latestTelemetry = packet;
              _lastSyncTime = packet.serverTimestamp;
            }
          });
        }
      }
    }

    // _syncedFactories populated inside loop above
  }

  void _updateClock() {
    final now = DateTime.now();
    final hour = now.hour > 12 ? now.hour - 12 : (now.hour == 0 ? 12 : now.hour);
    final ampm = now.hour >= 12 ? 'PM' : 'AM';
    final min = now.minute.toString().padLeft(2, '0');
    final sec = now.second.toString().padLeft(2, '0');
    setState(() {
      _currentTime = '$hour:$min:$sec $ampm';
      _currentDate = _formatDate(now);
    });
  }

  String _formatDate(DateTime d) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[d.month - 1]} ${d.day}, ${d.year}';
  }


  Timer? _bannerHideTimer;

  void _triggerBannerFadeOutTimer() {
    _bannerHideTimer?.cancel();
    setState(() {
      _showScanStatusBanner = true;
    });
    _bannerHideTimer = Timer(const Duration(seconds: 4), () {
      if (mounted) {
        setState(() {
          _showScanStatusBanner = false;
        });
      }
    });
  }

  /// Builds a status banner showing file scan / permission status
  Widget _buildScanStatusBanner() {
    final status = _pipelineStatus;
    
    // Only collapse success fileLoaded banners, keep errors / scanning permanently visible.
    final bool isVisible = status.type != PipelineStatusType.fileLoaded || _showScanStatusBanner;

    Color bgColor;
    Color borderColor;
    Color textColor;
    IconData icon;

    switch (status.type) {
      case PipelineStatusType.fileLoaded:
        bgColor = const Color(0xFF0D3320);
        borderColor = AppColors.green;
        textColor = AppColors.green;
        icon = Icons.check_circle_rounded;
        break;
      case PipelineStatusType.permissionDenied:
        bgColor = const Color(0xFF3D1A00);
        borderColor = AppColors.orange;
        textColor = AppColors.orange;
        icon = Icons.folder_off_rounded;
        break;
      case PipelineStatusType.error:
        bgColor = const Color(0xFF3D0D0D);
        borderColor = AppColors.red;
        textColor = AppColors.red;
        icon = Icons.error_rounded;
        break;
      case PipelineStatusType.scanning:
      case PipelineStatusType.idle:
      default:
        bgColor = const Color(0xFF0D1A3D);
        borderColor = AppColors.primaryBlue;
        textColor = AppColors.blue;
        icon = Icons.radar_rounded;
    }

    return AnimatedOpacity(
      opacity: isVisible ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
        height: isVisible ? 32.0 : 0.0,
        margin: EdgeInsets.only(bottom: isVisible ? 6.0 : 0.0),
        padding: isVisible 
            ? const EdgeInsets.symmetric(horizontal: 12, vertical: 7)
            : EdgeInsets.zero,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: borderColor.withValues(alpha: isVisible ? 0.5 : 0.0), width: isVisible ? 1 : 0),
        ),
        clipBehavior: Clip.hardEdge,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: textColor, size: 14),
            const SizedBox(width: 8),
            Text(
              status.message,
              style: TextStyle(
                color: textColor,
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.3,
              ),
            ),
            if (status.type == PipelineStatusType.permissionDenied) ...[
              const SizedBox(width: 6),
              Icon(Icons.open_in_new_rounded, color: textColor, size: 11),
            ],
          ],
        ),
      ),
    );
  }
  @override
  void dispose() {
    _bannerHideTimer?.cancel();
    _autoRefreshTimer?.cancel();
    _clockTimer.cancel();
    _telemetrySubscription?.cancel();
    _localTelemetrySubscription?.cancel();
    _statusSubscription?.cancel();
    localPipelineService.stopAutoScanning();
    _telemetryService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: StreamBuilder<SseConnectionStatus>(
        stream: _telemetryService.statusStream,
        initialData: SseConnectionStatus.connecting,
        builder: (context, statusSnapshot) {
          final connStatus = statusSnapshot.data ?? SseConnectionStatus.connecting;
          final String currentFactory = const ['F01', 'F02', 'F03', 'F04', 'F05'][_selectedFactoryIndex];
          final bool isAwaitingSync = !_syncedFactories.contains(currentFactory);

          return Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.background, // Deep navy-black
                  AppColors.surface, // Deep navy
                ],
              ),
            ),
            child: Stack(
              children: [
                    // Glowing Backdrop Orb 1 (Warm Orange at top-right)
                    Positioned(
                      top: -150,
                      right: -150,
                      child: Container(
                        width: 450,
                        
                        height: 450,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              AppColors.orange.withValues(alpha: 0.08),
                              AppColors.orange.withValues(alpha: 0.0),
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Glowing Backdrop Orb 2 (Cyan at bottom-left)
                    Positioned(
                      bottom: -150,
                      left: -150,
                      child: Container(
                        width: 450,
                        height: 450,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              AppColors.blue.withValues(alpha: 0.08),
                              AppColors.blue.withValues(alpha: 0.0),
                            ],
                          ),
                        ),
                      ),
                    ),
                  Row(
                    children: [
                      // Main Dashboard Canvas
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(12, 12, 24, 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Header Bar with live clock + connection status
                              _buildHeaderBar(connStatus),
                              const SizedBox(height: 6),
                              _buildScanStatusBanner(),
                              const SizedBox(height: 8),

                              if (_currentView == 'overview')
                                Expanded(
                                  child: isAwaitingSync
                                      ? _buildAwaitingSyncOverlay(currentFactory)
                                      : DistilleryOverviewScreen(
                                          vessels: _factoriesVessels[_selectedFactoryIndex],
                                          telemetry: _latestTelemetry,
                                          factoryCode: currentFactory,
                                        ),
                                )
                              else ...[
                                // Section 1: The "Fermenter Overview Grid" (Top of the Screen)
                                if (false)
                                  SizedBox(
                                    height: 248,
                                    child: Scrollbar(
                                      thumbVisibility: true,
                                      child: ListView.builder(
                                        itemCount: 5,
                                        padding: EdgeInsets.zero,
                                        itemBuilder: (context, fIdx) {
                                          return Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.symmetric(vertical: 4),
                                                child: Row(
                                                  children: [
                                                    const Icon(Icons.factory_rounded, color: AppColors.blue, size: 14),
                                                    const SizedBox(width: 8),
                                                    Text(
                                                      "${const ['Haliyal', 'Sankili', 'Nellikuppam', 'Sivagangai', 'Bagalkot'][fIdx].toUpperCase()} OPERATIONS",
                                                      style: const TextStyle(
                                                        color: Colors.white,
                                                        fontWeight: FontWeight.bold,
                                                        fontSize: 12,
                                                        letterSpacing: 1.0,
                                                      ),
                                                    ),
                                                    const Spacer(),
                                                    Text(
                                                       "${_factoriesVessels[fIdx].where((v) => !(v['isEmpty'] as bool)).length}/4 Fermenters Active",
                                                       style: const TextStyle(color: AppColors.textMuted, fontSize: 10),
                                                     ),
                                                  ],
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: List.generate(4, (vIdx) {
                                                  final data = _factoriesVessels[fIdx][vIdx];
                                                  final isSelected = _selectedFactoryIndex == fIdx && _selectedFermenterIndex == vIdx;
                                                  return Expanded(
                                                    child: Container(
                                                      margin: EdgeInsets.only(
                                                        right: vIdx == 3 ? 0 : 8,
                                                      ),
                                                      child: LiquidTankCard(
                                                        title: data['title'] as String,
                                                        levelFactor: data['levelFactor'] as double,
                                                        stateText: data['stateText'] as String,
                                                        temperature: data['temperature'] as double,
                                                        ph: data['ph'] as double,
                                                        brix: data['brix'] as double,
                                                        qualityFlag: data['qualityFlag'] as String,
                                                        isSelected: isSelected,
                                                        isEmpty: (data['isEmpty'] as bool?) ?? false,
                                                        onTap: () {
                                                          setState(() {
                                                            _selectedFactoryIndex = fIdx;
                                                            _selectedFermenterIndex = vIdx;
                                                          });
                                                        },
                                                      ),
                                                    ),
                                                  );
                                                }),
                                              ),
                                              const SizedBox(height: 12),
                                            ],
                                          );
                                        },
                                      ),
                                    ),
                                  )
                                else
                                  SizedBox(
                                    height: 248,
                                    child: LayoutBuilder(
                                      builder: (context, constraints) {
                                        final opIndex = (int.tryParse(widget.role.substring(8)) ?? 1) - 1;
                                        return Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: List.generate(4, (index) {
                                            final data = _factoriesVessels[opIndex][index];
                                            return Expanded(
                                              child: Container(
                                                margin: EdgeInsets.only(
                                                  right: index == 3 ? 0 : 8,
                                                ),
                                                child: LiquidTankCard(
                                                  title: data['title'] as String,
                                                  levelFactor: data['levelFactor'] as double,
                                                  stateText: data['stateText'] as String,
                                                  temperature: data['temperature'] as double,
                                                  ph: data['ph'] as double,
                                                  brix: data['brix'] as double,
                                                  qualityFlag: data['qualityFlag'] as String,
                                                  isSelected: _selectedFermenterIndex == index,
                                                  isEmpty: (data['isEmpty'] as bool?) ?? false,
                                                  onTap: () {
                                                    setState(() {
                                                      _selectedFactoryIndex = opIndex;
                                                      _selectedFermenterIndex = index;
                                                    });
                                                  },
                                                ),
                                              ),
                                            );
                                          }),
                                        );
                                      },
                                    ),
                                  ),
                              const SizedBox(height: 8),

                              // Section 2 & 3: Telemetry Details (Expanded)
                              Expanded(
                                child: LayoutBuilder(
                                  builder: (context, constraints) {
                                    final isWide = constraints.maxWidth > 920;
                                    final selectedData = _factoriesVessels[_selectedFactoryIndex][_selectedFermenterIndex];
                                    final bool isEmpty = selectedData['isEmpty'] as bool? ?? false;
                                    final String currentFactory = const ['F01', 'F02', 'F03', 'F04', 'F05'][_selectedFactoryIndex];
          final bool isAwaitingSync = !_syncedFactories.contains(currentFactory);
                                  
                                  // Show awaiting sync overlay until first real data arrives
                                  if (isAwaitingSync) {
                                    return _buildAwaitingSyncOverlay(currentFactory);
                                  }

                                  if (isEmpty) {
                                    return Container(
                                      width: double.infinity,
                                      margin: const EdgeInsets.only(top: 8),
                                      child: GlassCard(
                                        padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
                                        child: Center(
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Container(
                                                padding: const EdgeInsets.all(18),
                                                decoration: BoxDecoration(
                                                  color: AppColors.divider.withValues(alpha: 0.12),
                                                  shape: BoxShape.circle,
                                                ),
                                                child: const Icon(
                                                  Icons.hourglass_empty_rounded,
                                                  color: AppColors.textMuted,
                                                  size: 40,
                                                ),
                                              ),
                                              const SizedBox(height: 16),
                                              Text(
                                                '${selectedData['title']} - STANDBY',
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                  letterSpacing: 0.5,
                                                ),
                                              ),
                                              const SizedBox(height: 8),
                                              ConstrainedBox(
                                                constraints: const BoxConstraints(maxWidth: 480),
                                                child: const Text(
                                                  'This bioreactor fermenter is empty and ready for cleaning or a new batch cycle. Pitch a new batch by importing telemetry files, or click on an active fermenter card above.',
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                    color: AppColors.textMuted,
                                                    fontSize: 13,
                                                    height: 1.4,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  }

                                  if (isWide) {
                                    return Row(
                                      crossAxisAlignment: CrossAxisAlignment.stretch,
                                      children: [
                                        Expanded(
                                          flex: 3,
                                          child: const PlantKpisPanel(),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          flex: 3,
                                          child: GoldenBatchPossibility(
                                            confidence: selectedData['confidence'] as double,
                                            qcActions: (selectedData['qcActions'] as List?)?.cast<QCEntry>() ?? <QCEntry>[],
                                            ph: selectedData['ph'] as double,
                                            temperature: selectedData['temperature'] as double,
                                            yeastCount: selectedData['yeastCount'] as double,
                                            volatileAcidity: selectedData['volatileAcidityPpm'] as double,
                                            factoryCode: const ['F01', 'F02', 'F03', 'F04', 'F05'][_selectedFactoryIndex],
                                            telemetryService: _telemetryService,
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          flex: 4,
                                          child: AiOperatorAdvisor(
                                            isRecoverable: selectedData['isRecoverable'] as bool,
                                            volatileAcidityPpm: selectedData['volatileAcidityPpm'] as double,
                                            pitchAlcohol: (selectedData['alcohol'] as double? ?? 0.0),
                                            fermentationEfficiency: (selectedData['fermentationEfficiency'] as double? ?? 0.0),
                                            ph: (selectedData['ph'] as double? ?? 0.0),
                                          ),
                                        ),
                                      ],
                                    );
                                  } else {
                                    return Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        GoldenBatchPossibility(
                                          confidence: selectedData['confidence'] as double,
                                          qcActions: (selectedData['qcActions'] as List?)?.cast<QCEntry>() ?? <QCEntry>[],
                                          ph: selectedData['ph'] as double,
                                          temperature: selectedData['temperature'] as double,
                                          yeastCount: selectedData['yeastCount'] as double,
                                          volatileAcidity: selectedData['volatileAcidityPpm'] as double,
                                          factoryCode: const ['F01', 'F02', 'F03', 'F04', 'F05'][_selectedFactoryIndex],
                                          telemetryService: _telemetryService,
                                        ),
                                        const SizedBox(height: 16),

                                        AiOperatorAdvisor(
                                          isRecoverable: selectedData['isRecoverable'] as bool,
                                          volatileAcidityPpm: selectedData['volatileAcidityPpm'] as double,
                                          pitchAlcohol: (selectedData['alcohol'] as double? ?? 0.0),
                                          fermentationEfficiency: (selectedData['fermentationEfficiency'] as double? ?? 0.0),
                                          ph: (selectedData['ph'] as double? ?? 0.0),
                                        ),
                                        const SizedBox(height: 16),
                                        const PlantKpisPanel(),
                                      ],
                                    );
                                  }
                                },
                                ),
                              ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),


                ],
              ),
            );
        },
      ),
    );
  }

  Widget _buildHeaderBar(SseConnectionStatus status) {
    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      runSpacing: 10,
      children: [
        // Brand, Subtitle & Status Badge
        Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 14,
          runSpacing: 10,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.asset(
                  'assets/logo/parrys_logo.png',
                  height: 48,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 4),
                Text(
                  '${const ['Haliyal', 'Sankili', 'Nellikuppam', 'Sivagangai', 'Bagalkot'][_selectedFactoryIndex]} Control Console',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textMuted, // Steel Gray
                  ),
                ),
              ],
            ),

            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                // Button 1: Fermentor Dashboard
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _currentView = 'dashboard';
                    });
                  },
                  child: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GlassCard(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      borderRadius: 12,
                      backgroundColor: _currentView == 'dashboard'
                          ? AppColors.blue.withValues(alpha: 0.15)
                          : AppColors.glassOverlay,
                      borderColor: _currentView == 'dashboard'
                          ? AppColors.blue
                          : const Color(0x1FFFFFFF),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.dashboard_rounded,
                            size: 14,
                            color: _currentView == 'dashboard'
                                ? AppColors.blue
                                : AppColors.textMuted,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Fermentor Dashboard',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: _currentView == 'dashboard'
                                  ? Colors.white
                                  : AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),

                // Button 2: Distillery Overview
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _currentView = 'overview';
                    });
                  },
                  child: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GlassCard(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      borderRadius: 12,
                      backgroundColor: _currentView == 'overview'
                          ? AppColors.cyan.withValues(alpha: 0.15)
                          : AppColors.glassOverlay,
                      borderColor: _currentView == 'overview'
                          ? AppColors.cyan
                          : const Color(0x1FFFFFFF),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.factory_rounded,
                            size: 14,
                            color: _currentView == 'overview'
                                ? AppColors.cyan
                                : AppColors.textMuted,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Distillery Overview',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: _currentView == 'overview'
                                  ? Colors.white
                                  : AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),

        // Live Clock, Date & Actions
        Wrap(
          spacing: 10,
          runSpacing: 10,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            // Google Drive Ingest Last Sync Time Badge (Interactive Refresh)
            GestureDetector(
              onTap: () {
                _handleManualRefresh();
                final factoryCode = const ['F01', 'F02', 'F03', 'F04', 'F05'][_selectedFactoryIndex];
                final path = 'C:\\Users\\Admin B\\Downloads\\Distillery_EID\\Distillery_EID\\temp\\preprocessed_${factoryCode}.csv';
                if (Platform.isWindows) {
                  Process.run('explorer', [path]);
                }
              },
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GlassCard(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  borderRadius: 14,
                  backgroundColor: AppColors.cyan.withOpacity(0.12),
                  borderColor: AppColors.cyan.withOpacity(0.2),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _isRefreshing
                          ? const SizedBox(
                              width: 12,
                              height: 12,
                              child: CircularProgressIndicator(
                                strokeWidth: 1.5,
                                valueColor: AlwaysStoppedAnimation<Color>(AppColors.cyan),
                              ),
                            )
                          : const Icon(Icons.sync_rounded, size: 14, color: AppColors.cyan),
                      const SizedBox(width: 6),
                      Text(
                        'Current Excel: ${(() {
                          final currentFactory = const ['F01', 'F02', 'F03', 'F04', 'F05'][_selectedFactoryIndex];
                          final cached = localPipelineService.lastEmittedPackets[currentFactory];
                          return cached?.fileName ?? 'None (Waiting for upload)';
                        })()}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.cyan,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            GestureDetector(
              onTap: () {
                Navigator.of(context).pushReplacement(
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) =>
                        const LoginScreen(skipVideo: true),
                    transitionsBuilder: (context, animation, secondaryAnimation, child) {
                      return FadeTransition(opacity: animation, child: child);
                    },
                    transitionDuration: const Duration(milliseconds: 500),
                  ),
                );
              },
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GlassCard(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  borderRadius: 14,
                  backgroundColor: AppColors.red.withValues(alpha: 0.15),
                  borderColor: AppColors.red.withOpacity(0.2),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.logout_rounded, size: 14, color: AppColors.red),
                      const SizedBox(width: 6),
                      const Text(
                        'Logout',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.red,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}









