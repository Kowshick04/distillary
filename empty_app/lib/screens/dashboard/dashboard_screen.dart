import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../services/mqtt_telemetry_service.dart';
import '../../models/telemetry_data_model.dart';
import '../../models/distillery_snapshot_model.dart';
import '../../services/distillery_snapshot_store.dart';
import '../../widgets/common/glass_card.dart';
import '../../widgets/dashboard/liquid_tank_card.dart';
import '../../widgets/dashboard/ai_operator_advisor.dart';
import '../../widgets/dashboard/plant_kpis_panel.dart';
import '../../widgets/dashboard/golden_batch_possibility.dart';
import '../../widgets/assistant/ayam_bot_assist.dart';
import 'distillery_overview_screen.dart';
import '../login/login_screen.dart';
import '../../utils/app_colors.dart';

class DashboardScreen extends StatefulWidget {
  final String role;
  final String factoryCode;

  const DashboardScreen({
    super.key,
    required this.role,
    this.factoryCode = 'F01',
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  StreamSubscription<TelemetryDataModel>? _telemetrySubscription;
  
  // View states
  String _currentView = 'dashboard'; // 'dashboard' or 'overview'
  int _selectedFermenterIndex = 0; // Default to Fermentation 1
  int _selectedFactoryIndex = 0; // Will be locked for operators
  
  TelemetryDataModel? _latestTelemetry;
  
  // Real-time clock properties
  String _currentTime = '';
  String _currentDate = '';
  Timer? _clockTimer;
  
  // Synced factories list
  final Set<String> _syncedFactories = {'F01', 'F02', 'F03', 'F04', 'F05'};
  
  // Multi-factory vessels data structure matching primary app
  late List<List<Map<String, dynamic>>> _factoriesVessels;

  static Map<String, dynamic> _standbyEntry(int idx) => {
    'title': 'Fermentation ${idx + 1}',
    'levelFactor': 0.0,
    'stateText': 'STANDBY',
    'temperature': 0.0,
    'ph': 0.0,
    'brix': 0.0,
    'qualityFlag': 'STANDBY',
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

  @override
  void initState() {
    super.initState();
    
    // Resolve factory index based on widget.factoryCode
    _selectedFactoryIndex = (() {
      final code = widget.factoryCode;
      if (code == 'F02') return 1; // Sankili
      if (code == 'F03') return 2; // Nellikuppam
      if (code == 'F04') return 3; // Sivagangai
      if (code == 'F05') return 4; // Bagalkot
      return 0; // Default F01 (Haliyal)
    })();

    _selectedFermenterIndex = (() {
      if (_selectedFactoryIndex == 3) return 1; // Sivagangai starts on F2
      return 0;
    })();

    // Initialize vessels with factory-specific Golden and Normal baselines
    _factoriesVessels = [
      // 0: Haliyal (F01) - F1 (Golden 95%), F4 (Golden 91%), F2/F3 Standby
      [
        {
          'title': 'Fermentation 1',
          'levelFactor': 0.85,
          'stateText': 'FERMENTING',
          'temperature': 32.5,
          'ph': 4.70,
          'brix': 2.6,
          'qualityFlag': 'GOLDEN BATCH',
          'confidence': 0.95,
          'isRecoverable': true,
          'volatileAcidityPpm': 48.0,
          'yeastCount': 350.0,
          'alcohol': 14.2,
          'fermentationEfficiency': 94.0,
          'isEmpty': false,
          'qcActions': const <QCEntry>[],
          'brixHistory': <double>[2.6],
          'alcoholHistory': <double>[14.2],
          'tempHistory': <double>[32.5],
        },
        _standbyEntry(1),
        _standbyEntry(2),
        {
          'title': 'Fermentation 4',
          'levelFactor': 0.82,
          'stateText': 'FERMENTING',
          'temperature': 32.8,
          'ph': 4.62,
          'brix': 2.9,
          'qualityFlag': 'GOLDEN BATCH',
          'confidence': 0.91,
          'isRecoverable': true,
          'volatileAcidityPpm': 52.0,
          'yeastCount': 338.0,
          'alcohol': 13.5,
          'fermentationEfficiency': 91.0,
          'isEmpty': false,
          'qcActions': const <QCEntry>[],
          'brixHistory': <double>[2.9],
          'alcoholHistory': <double>[13.5],
          'tempHistory': <double>[32.8],
        },
      ],
      // 1: Sankili (F02) - F1 (Normal 72%), F4 (Golden 93%), F2/F3 Standby
      [
        {
          'title': 'Fermentation 1',
          'levelFactor': 0.80,
          'stateText': 'FERMENTING',
          'temperature': 31.8,
          'ph': 4.30,
          'brix': 5.0,
          'qualityFlag': 'NORMAL',
          'confidence': 0.72,
          'isRecoverable': true,
          'volatileAcidityPpm': 92.0,
          'yeastCount': 210.0,
          'alcohol': 8.8,
          'fermentationEfficiency': 84.0,
          'isEmpty': false,
          'qcActions': const <QCEntry>[
            QCEntry(action: 'Add Ammonium Hydroxide buffer', description: 'Adjust pH up to target 4.8.')
          ],
          'brixHistory': <double>[5.0],
          'alcoholHistory': <double>[8.8],
          'tempHistory': <double>[31.8],
        },
        _standbyEntry(1),
        _standbyEntry(2),
        {
          'title': 'Fermentation 4',
          'levelFactor': 0.86,
          'stateText': 'FERMENTING',
          'temperature': 32.6,
          'ph': 4.68,
          'brix': 2.7,
          'qualityFlag': 'GOLDEN BATCH',
          'confidence': 0.93,
          'isRecoverable': true,
          'volatileAcidityPpm': 54.0,
          'yeastCount': 340.0,
          'alcohol': 13.9,
          'fermentationEfficiency': 92.0,
          'isEmpty': false,
          'qcActions': const <QCEntry>[],
          'brixHistory': <double>[2.7],
          'alcoholHistory': <double>[13.9],
          'tempHistory': <double>[32.6],
        },
      ],
      // 2: Nellikuppam (F03) - F1 (Golden 92%), F2 (Normal 70%), F3/F4 Standby
      [
        {
          'title': 'Fermentation 1',
          'levelFactor': 0.85,
          'stateText': 'FERMENTING',
          'temperature': 33.4,
          'ph': 4.65,
          'brix': 2.8,
          'qualityFlag': 'GOLDEN BATCH',
          'confidence': 0.92,
          'isRecoverable': true,
          'volatileAcidityPpm': 51.0,
          'yeastCount': 344.0,
          'alcohol': 13.8,
          'fermentationEfficiency': 92.0,
          'isEmpty': false,
          'qcActions': const <QCEntry>[],
          'brixHistory': <double>[2.8],
          'alcoholHistory': <double>[13.8],
          'tempHistory': <double>[33.4],
        },
        {
          'title': 'Fermentation 2',
          'levelFactor': 0.80,
          'stateText': 'FERMENTING',
          'temperature': 31.3,
          'ph': 4.25,
          'brix': 5.2,
          'qualityFlag': 'NORMAL',
          'confidence': 0.70,
          'isRecoverable': true,
          'volatileAcidityPpm': 98.0,
          'yeastCount': 195.0,
          'alcohol': 8.5,
          'fermentationEfficiency': 82.0,
          'isEmpty': false,
          'qcActions': const <QCEntry>[
            QCEntry(action: 'Add Ammonium Hydroxide buffer', description: 'Adjust pH up to target 4.8.')
          ],
          'brixHistory': <double>[5.2],
          'alcoholHistory': <double>[8.5],
          'tempHistory': <double>[31.3],
        },
        _standbyEntry(2),
        _standbyEntry(3),
      ],
      // 3: Sivagangai (F04) - F2 (Golden 89%), F3 (Normal 75%), F1/F4 Standby
      [
        _standbyEntry(0),
        {
          'title': 'Fermentation 2',
          'levelFactor': 0.84,
          'stateText': 'FERMENTING',
          'temperature': 32.2,
          'ph': 4.58,
          'brix': 3.0,
          'qualityFlag': 'GOLDEN BATCH',
          'confidence': 0.89,
          'isRecoverable': true,
          'volatileAcidityPpm': 58.0,
          'yeastCount': 325.0,
          'alcohol': 13.1,
          'fermentationEfficiency': 89.0,
          'isEmpty': false,
          'qcActions': const <QCEntry>[],
          'brixHistory': <double>[3.0],
          'alcoholHistory': <double>[13.1],
          'tempHistory': <double>[32.2],
        },
        {
          'title': 'Fermentation 3',
          'levelFactor': 0.80,
          'stateText': 'FERMENTING',
          'temperature': 31.5,
          'ph': 4.35,
          'brix': 4.8,
          'qualityFlag': 'NORMAL',
          'confidence': 0.75,
          'isRecoverable': true,
          'volatileAcidityPpm': 88.0,
          'yeastCount': 220.0,
          'alcohol': 9.2,
          'fermentationEfficiency': 85.0,
          'isEmpty': false,
          'qcActions': const <QCEntry>[
            QCEntry(action: 'Add Ammonium Hydroxide buffer', description: 'Adjust pH up to target 4.8.')
          ],
          'brixHistory': <double>[4.8],
          'alcoholHistory': <double>[9.2],
          'tempHistory': <double>[31.5],
        },
        _standbyEntry(3),
      ],
      // 4: Bagalkot (F05) - F1 (Golden 96%), F2 (Golden 94%), F3/F4 Standby
      [
        {
          'title': 'Fermentation 1',
          'levelFactor': 0.88,
          'stateText': 'FERMENTING',
          'temperature': 32.4,
          'ph': 4.72,
          'brix': 2.4,
          'qualityFlag': 'GOLDEN BATCH',
          'confidence': 0.96,
          'isRecoverable': true,
          'volatileAcidityPpm': 45.0,
          'yeastCount': 360.0,
          'alcohol': 14.5,
          'fermentationEfficiency': 95.0,
          'isEmpty': false,
          'qcActions': const <QCEntry>[],
          'brixHistory': <double>[2.4],
          'alcoholHistory': <double>[14.5],
          'tempHistory': <double>[32.4],
        },
        {
          'title': 'Fermentation 2',
          'levelFactor': 0.86,
          'stateText': 'FERMENTING',
          'temperature': 32.7,
          'ph': 4.67,
          'brix': 2.6,
          'qualityFlag': 'GOLDEN BATCH',
          'confidence': 0.94,
          'isRecoverable': true,
          'volatileAcidityPpm': 49.0,
          'yeastCount': 348.0,
          'alcohol': 14.1,
          'fermentationEfficiency': 93.0,
          'isEmpty': false,
          'qcActions': const <QCEntry>[],
          'brixHistory': <double>[2.6],
          'alcoholHistory': <double>[14.1],
          'tempHistory': <double>[32.7],
        },
        _standbyEntry(2),
        _standbyEntry(3),
      ],
    ];

    // Check for cached MQTT packet on startup
    final cached = mqttTelemetryService.lastEmittedPackets[widget.factoryCode];
    if (cached != null) {
      _processTelemetryPacket(cached);
    }

    // Subscribe to live MQTT stream
    _telemetrySubscription = mqttTelemetryService.telemetryStream.listen((packet) {
      _processTelemetryPacket(packet);
    });

    // Setup live clock
    _updateClock();
    _clockTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) _updateClock();
    });
  }

  void _processTelemetryPacket(TelemetryDataModel packet) {
    if (!mounted) return;

    final String packetFactory = packet.factoryCode;
    final int packetFactoryIdx = (() {
      if (packetFactory == 'F02') return 1;
      if (packetFactory == 'F03') return 2;
      if (packetFactory == 'F04') return 3;
      if (packetFactory == 'F05') return 4;
      return 0; // Default F01
    })();

    setState(() {
      _syncedFactories.add(packetFactory);
      
      // Update active telemetry details if packet is for current selected factory
      if (packetFactoryIdx == _selectedFactoryIndex) {
        _latestTelemetry = packet;
      }

      // Automatically push a snapshot to DistillerySnapshotStore to update the DistilleryOverview screen!
      distillerySnapshotStore.pushSnapshot(
        packetFactory,
        DistilleryExcelSnapshot.fromTelemetry(
          feedRate: packet.feedRate > 0 ? packet.feedRate : 59.2,
          analyserTemp: packet.analyserTemp > 0 ? packet.analyserTemp : 78.7,
          productAlcohol: packet.productAlcoholFinal > 0 ? packet.productAlcoholFinal : 97.6,
          washAlcohol: packet.washAlcohol > 0 ? packet.washAlcohol : 12.9,
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

      if (packet.fermentersList.isNotEmpty) {
        for (int i = 0; i < packet.fermentersList.length; i++) {
          final fItem = packet.fermentersList[i];
          final String fStatusUpper = fItem.status.toUpperCase();
          if (fStatusUpper == 'AWAITING_SYNC' || fStatusUpper == 'STANDBY' || fItem.vol == 0) {
            _factoriesVessels[packetFactoryIdx][i] = _standbyEntry(i);
          } else {
            final List<double> bHist = List<double>.from(_factoriesVessels[packetFactoryIdx][i]['brixHistory'] ?? []);
            final List<double> aHist = List<double>.from(_factoriesVessels[packetFactoryIdx][i]['alcoholHistory'] ?? []);
            final List<double> tHist = List<double>.from(_factoriesVessels[packetFactoryIdx][i]['tempHistory'] ?? []);

            bHist.add(fItem.brix);
            aHist.add(packet.ethanolPct);
            tHist.add(fItem.temp);

            if (bHist.length > 24) bHist.removeAt(0);
            if (aHist.length > 24) aHist.removeAt(0);
            if (tHist.length > 24) tHist.removeAt(0);

            final String fLabel = fItem.status.toLowerCase();
            final double fConfidence = fItem.confidence > 0 ? (fItem.confidence / 100.0) : (fLabel.contains('golden') ? 0.92 : 0.70);
            final double fYeast = fItem.yeast.isNotEmpty ? (double.tryParse(fItem.yeast.replaceAll(RegExp(r'[^0-9.]'), '')) ?? (fLabel.contains('golden') ? 344.0 : 195.0)) : (fLabel.contains('golden') ? 344.0 : 195.0);
            final double fVa = fItem.va.isNotEmpty ? (double.tryParse(fItem.va.replaceAll(RegExp(r'[^0-9.]'), '')) ?? (fLabel.contains('golden') ? 51.0 : 98.0)) : (fLabel.contains('golden') ? 51.0 : 98.0);
            final double fAlcohol = fItem.alcohol > 0 ? fItem.alcohol : (fLabel.contains('golden') ? 13.8 : 8.5);
            final double fEff = fLabel.contains('golden') ? 92.0 : 82.0;

            _factoriesVessels[packetFactoryIdx][i] = {
              'title': 'Fermentation ${fItem.id}',
              'levelFactor': (fItem.vol / 100.0).clamp(0.0, 1.0),
              'stateText': fItem.subStatus.isEmpty ? 'FERMENTING' : fItem.subStatus.toUpperCase(),
              'temperature': fItem.temp,
              'ph': fItem.ph,
              'brix': fItem.brix,
              'qualityFlag': fItem.status.toUpperCase() == 'GOLDEN'
                  ? 'GOLDEN BATCH'
                  : (fItem.status.toUpperCase() == 'RISK (INFECTION)'
                      ? 'RISK (INFECTION)'
                      : fItem.status.toUpperCase()),
              'confidence': fConfidence,
              'isRecoverable': fItem.status.toLowerCase() != 'infection',
              'volatileAcidityPpm': fVa,
              'yeastCount': fYeast,
              'alcohol': fAlcohol,
              'fermentationEfficiency': fEff,
              'isEmpty': false,
              'qcActions': getQcActions(fItem.ph, fItem.brix, fItem.temp, fLabel),
              'brixHistory': bHist,
              'alcoholHistory': aHist,
              'tempHistory': tHist,
            };
          }
        }
      } else {
        final int vesselIdx = (packet.fermenter - 1).clamp(0, 3);
        final String label = packet.predictionLabel.toLowerCase();
        final double yeastVal = packet.agitatorHealthScore * 3.0;
        final double vaVal = packet.batchQualityScore > 75 ? 1100.0 : 2100.0;
        
        final double tempOffset = (packetFactoryIdx - 2) * 0.4;
        final double phOffset = (packetFactoryIdx - 2) * 0.05;
        final double brixOffset = (packetFactoryIdx - 2) * 0.2;
        
        final double currentBrix = (packet.brix + brixOffset).clamp(1.0, 15.0);
        final double currentTemp = (packet.temperature + tempOffset).clamp(30.0, 36.0);
        final double currentPh = (packet.ph + phOffset).clamp(4.2, 5.2);
        // Normalize efficiency to percent (guard against fraction 0-1 from some sources)
        final double normalizedEfficiency = packet.fermentationEfficiency > 1.0
            ? packet.fermentationEfficiency
            : packet.fermentationEfficiency * 100.0;

        // 1. Update the primary active vessel
        final List<double> bHist = List<double>.from(_factoriesVessels[packetFactoryIdx][vesselIdx]['brixHistory'] ?? []);
        final List<double> aHist = List<double>.from(_factoriesVessels[packetFactoryIdx][vesselIdx]['alcoholHistory'] ?? []);
        final List<double> tHist = List<double>.from(_factoriesVessels[packetFactoryIdx][vesselIdx]['tempHistory'] ?? []);
        
        bHist.add(currentBrix);
        aHist.add(packet.alcohol);
        tHist.add(currentTemp);
        
        if (bHist.length > 24) bHist.removeAt(0);
        if (aHist.length > 24) aHist.removeAt(0);
        if (tHist.length > 24) tHist.removeAt(0);

        _factoriesVessels[packetFactoryIdx][vesselIdx] = {
          'title': 'Fermentation ${vesselIdx + 1}',
          'levelFactor': (normalizedEfficiency / 100.0).clamp(0.0, 1.0),
          'stateText': 'FERMENTING',
          'temperature': currentTemp,
          'ph': currentPh,
          'brix': currentBrix,
          'qualityFlag': packet.predictionLabel.toUpperCase().contains('GOLDEN')
              ? 'GOLDEN BATCH'
              : (packet.predictionLabel.toUpperCase().contains('RISK')
                  ? 'RISK (INFECTION)'
                  : 'NORMAL'),
          'confidence': packet.predictionConfidence > 1.0
              ? packet.predictionConfidence / 100.0
              : packet.predictionConfidence,
          'isRecoverable': !packet.predictionLabel.toLowerCase().contains('low'),
          'volatileAcidityPpm': vaVal,
          'yeastCount': yeastVal,
          // alcohol on fermenter card = fermented wash alcohol (~11-13%)
          'alcohol': packet.washAlcoholFeed > 0 ? packet.washAlcoholFeed : packet.alcohol,
          'fermentationEfficiency': normalizedEfficiency,
          'isEmpty': false,
          'qcActions': getQcActions(currentPh, currentBrix, currentTemp, label),
          'brixHistory': bHist,
          'alcoholHistory': aHist,
          'tempHistory': tHist,
        };

        // Do not simulate secondary vessel, keep other fermenters standby.
      }
    });
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

  @override
  void dispose() {
    _telemetrySubscription?.cancel();
    _clockTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final String currentFactory = const ['F01', 'F02', 'F03', 'F04', 'F05'][_selectedFactoryIndex];
    final bool isAwaitingSync = !_syncedFactories.contains(currentFactory);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Container(
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
            
            LayoutBuilder(
              builder: (context, screenConstraints) {
                final bool isTall = screenConstraints.maxHeight > 620;
                final double contentPadding = screenConstraints.maxWidth < 800 ? 8.0 : 16.0;
                final bool isScrollable = !isTall || screenConstraints.maxWidth < 600;
                final bool useExpanded = isTall && !isScrollable;

                Widget mainContent = Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Bar
                    _buildHeaderBar(screenConstraints.maxWidth),
                    const SizedBox(height: 8),

                    // View switcher — Stack+AnimatedOpacity avoids AnimatedSwitcher element-tree crash
                    useExpanded
                        ? Expanded(
                            child: Stack(
                              children: [
                                Positioned.fill(
                                  child: AnimatedOpacity(
                                    opacity: _currentView == 'overview' ? 1.0 : 0.0,
                                    duration: const Duration(milliseconds: 300),
                                    child: IgnorePointer(
                                      ignoring: _currentView != 'overview',
                                      child: _buildDistilleryOverviewContent(isTall, currentFactory, isAwaitingSync),
                                    ),
                                  ),
                                ),
                                Positioned.fill(
                                  child: AnimatedOpacity(
                                    opacity: _currentView != 'overview' ? 1.0 : 0.0,
                                    duration: const Duration(milliseconds: 300),
                                    child: IgnorePointer(
                                      ignoring: _currentView == 'overview',
                                      child: _buildFermenterDashboardContent(screenConstraints, isTall, currentFactory),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                        : AnimatedCrossFade(
                            firstChild: _buildDistilleryOverviewContent(isTall, currentFactory, isAwaitingSync),
                            secondChild: _buildFermenterDashboardContent(screenConstraints, isTall, currentFactory),
                            crossFadeState: _currentView == 'overview' 
                                ? CrossFadeState.showFirst 
                                : CrossFadeState.showSecond,
                            duration: const Duration(milliseconds: 300),
                          )
                  ],
                );

                if (isScrollable) {
                  mainContent = SingleChildScrollView(
                    child: mainContent,
                  );
                }

                return Row(
                  children: [
                    // Left Factory sidebar (CEO only)
                    if (!widget.role.startsWith('operator'))
                      _buildLeftFactorySidebar(),
                    
                    // Main Dashboard Canvas
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(12, 12, contentPadding + 8, 16),
                        child: mainContent,
                      ),
                    ),
                  ],
                );
              },
            ),


          ],
        ),
      ),
    );
  }

  Widget _buildBottomPanels(String currentFactory, double maxWidth, bool expandHeight) {
    final selectedData = _factoriesVessels[_selectedFactoryIndex][_selectedFermenterIndex];
    final bool isEmpty = selectedData['isEmpty'] as bool? ?? true;
    final bool isAwaitingSync = !_syncedFactories.contains(currentFactory);

    if (isAwaitingSync) {
      return _buildAwaitingSyncOverlay(currentFactory);
    }

    if (isEmpty) {
      return Container(
        width: double.infinity,
        margin: const EdgeInsets.only(top: 8),
        child: GlassCard(
          padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 24),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.divider.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.hourglass_empty_rounded,
                    color: AppColors.textMuted,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  '${selectedData['title']} - STANDBY',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 6),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 480),
                  child: const Text(
                    'This bioreactor fermenter is empty and ready for cleaning or a new batch cycle. Pitch a new batch by importing telemetry files, or click on an active fermenter card above.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 12,
                      height: 1.3,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final double volatileAcidity = selectedData['volatileAcidityPpm'] as double? ?? 0.0;
    final double yeastVal = selectedData['yeastCount'] as double? ?? 0.0;

    // Use side-by-side layout for screen widths > 600 pixels (standard landscape phone size and above)
    final bool isWideLayout = maxWidth > 600;

    if (isWideLayout) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            flex: 3,
            child: PlantKpisPanel(
              yeastCount: yeastVal,
              volatileAcidityPpm: volatileAcidity,
              ph: selectedData['ph'] as double? ?? 0.0,
              brix: selectedData['brix'] as double? ?? 0.0,
              temperature: selectedData['temperature'] as double? ?? 0.0,
              fermentationEfficiency: selectedData['fermentationEfficiency'] as double? ?? 0.0,
              vesselTitle: selectedData['title'] as String? ?? 'Fermentation',
              status: selectedData['stateText'] as String? ?? 'STANDBY',
              isEmpty: selectedData['isEmpty'] as bool? ?? false,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 3,
            child: GoldenBatchPossibility(
              confidence: selectedData['confidence'] as double? ?? 0.0,
              qcActions: (selectedData['qcActions'] as List?)?.cast<QCEntry>() ?? <QCEntry>[],
              ph: selectedData['ph'] as double? ?? 0.0,
              temperature: selectedData['temperature'] as double? ?? 0.0,
              yeastCount: yeastVal,
              volatileAcidity: volatileAcidity,
              factoryCode: currentFactory,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 4,
            child: AiOperatorAdvisor(
              isRecoverable: selectedData['isRecoverable'] as bool? ?? true,
              volatileAcidityPpm: volatileAcidity,
              pitchAlcohol: (selectedData['alcohol'] as double? ?? selectedData['brix'] as double? ?? 0.0),
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
            confidence: selectedData['confidence'] as double? ?? 0.0,
            qcActions: (selectedData['qcActions'] as List?)?.cast<QCEntry>() ?? <QCEntry>[],
            ph: selectedData['ph'] as double? ?? 0.0,
            temperature: selectedData['temperature'] as double? ?? 0.0,
            yeastCount: yeastVal,
            volatileAcidity: volatileAcidity,
            factoryCode: currentFactory,
          ),
          const SizedBox(height: 8),
          AiOperatorAdvisor(
            isRecoverable: selectedData['isRecoverable'] as bool? ?? true,
            volatileAcidityPpm: volatileAcidity,
            pitchAlcohol: (selectedData['alcohol'] as double? ?? selectedData['brix'] as double? ?? 0.0),
            fermentationEfficiency: (selectedData['fermentationEfficiency'] as double? ?? 0.0),
            ph: (selectedData['ph'] as double? ?? 0.0),
          ),
          const SizedBox(height: 8),
          PlantKpisPanel(
            yeastCount: yeastVal,
            volatileAcidityPpm: volatileAcidity,
            ph: selectedData['ph'] as double? ?? 0.0,
            brix: selectedData['brix'] as double? ?? 0.0,
            temperature: selectedData['temperature'] as double? ?? 0.0,
            fermentationEfficiency: selectedData['fermentationEfficiency'] as double? ?? 0.0,
            vesselTitle: selectedData['title'] as String? ?? 'Fermentation',
            status: selectedData['stateText'] as String? ?? 'STANDBY',
            isEmpty: selectedData['isEmpty'] as bool? ?? false,
          ),
        ],
      );
    }
  }

  Widget _buildLeftFactorySidebar() {
    return Container(
      width: 200,
      decoration: const BoxDecoration(
        color: Color(0xFF090D1C),
        border: Border(right: BorderSide(color: Color(0x1BFFFFFF))),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 24, 16, 12),
            child: Row(
              children: [
                Icon(Icons.dashboard_customize_rounded, color: AppColors.blue, size: 16),
                SizedBox(width: 8),
                Text(
                  'ENTERPRISE MAP',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textMuted,
                    letterSpacing: 1.0,
                  ),
                ),
              ],
            ),
          ),
          const Divider(color: Color(0x11FFFFFF), height: 1),
          Expanded(
            child: ListView.builder(
              itemCount: 5,
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemBuilder: (context, index) {
                final String code = const ['F01', 'F02', 'F03', 'F04', 'F05'][index];
                final String name = const ['Haliyal', 'Sankili', 'Nellikuppam', 'Sivagangai', 'Bagalkot'][index];
                final isSelected = _selectedFactoryIndex == index;
                final isSynced = _syncedFactories.contains(code);

                return InkWell(
                  onTap: () {
                    setState(() {
                      _selectedFactoryIndex = index;
                      _selectedFermenterIndex = 0; // Reset fermenter selection
                      final cached = mqttTelemetryService.lastEmittedPackets[code];
                      if (cached != null) {
                        _latestTelemetry = cached;
                      } else {
                        _latestTelemetry = null;
                      }
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.blue.withValues(alpha: 0.1)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isSelected ? AppColors.blue.withValues(alpha: 0.25) : Colors.transparent,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.factory_rounded,
                          size: 14,
                          color: isSelected ? AppColors.blue : AppColors.divider,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                name,
                                style: TextStyle(
                                  color: isSelected ? Colors.white : AppColors.textSecondary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                isSynced ? 'Active Stream' : 'Offline / Standby',
                                style: TextStyle(
                                  color: isSynced ? AppColors.teal : AppColors.divider,
                                  fontSize: 9.0,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (isSynced)
                          Container(
                            width: 5,
                            height: 5,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.teal,
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDistilleryOverviewContent(
      bool isTall, String currentFactory, bool isAwaitingSync) {
    final child = isAwaitingSync
        ? _buildAwaitingSyncOverlay(currentFactory)
        : DistilleryOverviewScreen(
            vessels: _factoriesVessels[_selectedFactoryIndex],
            telemetry: _latestTelemetry,
            factoryCode: currentFactory,
          );

    if (isTall) {
      return KeyedSubtree(
        child: child,
      );
    } else {
      return SizedBox(
        height: 400,
        child: child,
      );
    }
  }

  Widget _buildFermenterDashboardContent(
      BoxConstraints screenConstraints, bool isTall, String currentFactory) {
    final bool isMobile = screenConstraints.maxWidth < 600;

    Widget buildTankCard(int index) {
      final data = _factoriesVessels[_selectedFactoryIndex][index];
      final bool isEmpty = data['isEmpty'] as bool? ?? true;
      return Expanded(
        child: Container(
          margin: EdgeInsets.only(
            right: isMobile
                ? (index % 2 == 1 ? 0 : 6.0)
                : (index == 3 ? 0 : (screenConstraints.maxWidth < 800 ? 4.0 : 8.0)),
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
            isEmpty: isEmpty,
            yeastCount: data['yeastCount'] as double? ?? 0.0,
            volatileAcidity: data['volatileAcidityPpm'] as double? ?? 0.0,
            qcAction: data['qcActions'] != null && (data['qcActions'] as List).isNotEmpty
                ? (data['qcActions'] as List).first.action
                : '',
            onTap: () {
              setState(() {
                _selectedFermenterIndex = index;
              });
            },
          ),
        ),
      );
    }

    final List<Widget> children = [
      // Section 1: The "Fermenter Overview Grid"
      SizedBox(
        height: isMobile ? 380.0 : (screenConstraints.maxWidth < 800 ? 200.0 : 248.0),
        child: isMobile
            ? Column(
                children: [
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        buildTankCard(0),
                        buildTankCard(1),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        buildTankCard(2),
                        buildTankCard(3),
                      ],
                    ),
                  ),
                ],
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(4, (index) => buildTankCard(index)),
              ),
      ),
      const SizedBox(height: 8),

      // Section 2 & 3: Telemetry Details (Bottom panels)
      (isTall && !isMobile)
          ? Expanded(
              child: _buildBottomPanels(currentFactory, screenConstraints.maxWidth, true),
            )
          : Container(
              margin: const EdgeInsets.only(top: 8),
              child: _buildBottomPanels(currentFactory, screenConstraints.maxWidth, false),
            ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: (isTall && !isMobile) ? MainAxisSize.max : MainAxisSize.min,
      children: children,
    );
  }

  Widget _buildHeaderBar(double screenWidth) {
    final String currentFactory = const ['F01', 'F02', 'F03', 'F04', 'F05'][_selectedFactoryIndex];
    final bool isSynced = _syncedFactories.contains(currentFactory);
    final bool isCompact = screenWidth < 840;

    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      runSpacing: 8,
      children: [
        // Brand & Subtitle
        Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 12,
          runSpacing: 8,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.asset(
                  'assets/logo/parrys_logo.png',
                  height: screenWidth < 600 ? 36 : 44,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 4),
                Text(
                  '${const ['Haliyal', 'Sankili', 'Nellikuppam', 'Sivagangai', 'Bagalkot'][_selectedFactoryIndex]} Control Console',
                  style: TextStyle(
                    fontSize: screenWidth < 600 ? 10 : 11.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),

            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                // Button 1: Fermenter Dashboard
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _currentView = 'dashboard';
                    });
                  },
                  child: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GlassCard(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      borderRadius: 10,
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
                            size: 12,
                            color: _currentView == 'dashboard'
                                ? AppColors.blue
                                : AppColors.textMuted,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Fermenter Dashboard',
                            style: TextStyle(
                              fontSize: 10,
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
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      borderRadius: 10,
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
                            Icons.analytics_rounded,
                            size: 12,
                            color: _currentView == 'overview'
                                ? AppColors.cyan
                                : AppColors.textMuted,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Distillery Overview',
                            style: TextStyle(
                              fontSize: 10,
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

        // Badges and Logout
        Wrap(
          spacing: 8,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            // Live clock (hide seconds on small screens to save space)
            Text(
              isCompact ? _currentTime.replaceAll(RegExp(r':\d{2}\s'), ' ') : '$_currentDate | $_currentTime',
              style: const TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.bold,
                color: AppColors.textSecondary,
              ),
            ),

            // Sync status badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
              decoration: BoxDecoration(
                color: isSynced
                    ? AppColors.teal.withValues(alpha: 0.15)
                    : AppColors.amber.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSynced
                      ? AppColors.teal.withValues(alpha: 0.4)
                      : AppColors.amber.withValues(alpha: 0.4),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isSynced ? Icons.sync_rounded : Icons.sync_problem_rounded,
                    color: isSynced ? AppColors.teal : AppColors.amber,
                    size: 12,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    isSynced
                        ? 'Excel: ${_latestTelemetry?.excelTimestamp ?? "N/A"}'
                        : 'Awaiting Sync...',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: isSynced ? AppColors.teal : AppColors.amber,
                    ),
                  ),
                ],
              ),
            ),



            // Logout button
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => const LoginScreen(skipVideo: true)),
                );
              },
              icon: const Icon(Icons.logout_rounded, size: 12),
              label: const Text('Logout'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.glassOverlay,
                foregroundColor: AppColors.red,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: BorderSide(color: AppColors.red.withValues(alpha: 0.13)),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAwaitingSyncOverlay(String factoryCode) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 8),
      child: GlassCard(
        padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 24),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.cyan.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.cloud_sync_rounded,
                  color: AppColors.cyan,
                  size: 32,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Awaiting Data Sync ($factoryCode)',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 6),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: const Text(
                  'Please start the MQTT telemetry simulator to sync live factory feed data. The dashboards will load automatically once a telemetry packet is received.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 12,
                    height: 1.3,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
