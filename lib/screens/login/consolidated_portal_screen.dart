import 'dart:async';
import 'package:flutter/material.dart';
import '../../models/telemetry_data_model.dart';
import '../../services/mqtt_telemetry_service.dart';
import '../../widgets/common/glass_card.dart';
import '../dashboard/dashboard_screen.dart';
import 'login_screen.dart';
import '../../utils/app_colors.dart';

class ConsolidatedPortalScreen extends StatefulWidget {
  const ConsolidatedPortalScreen({super.key});

  @override
  State<ConsolidatedPortalScreen> createState() => _ConsolidatedPortalScreenState();
}

class _ConsolidatedPortalScreenState extends State<ConsolidatedPortalScreen> {
  StreamSubscription<TelemetryDataModel>? _telemetrySubscription;
  final Map<String, TelemetryDataModel> _latestPackets = {};

  final List<Map<String, dynamic>> _facilities = [
    {
      'id': 'operator1',
      'factoryCode': 'F01',
      'title': 'Haliyal Operations',
      'vessels': '0 / 4 Fermenters Active',
      'efficiency': 0.0,
      'flag': 'AWAITING SYNC',
      'color': AppColors.divider,
      'icon': Icons.factory_rounded,
    },
    {
      'id': 'operator2',
      'factoryCode': 'F02',
      'title': 'Sankili Operations',
      'vessels': '0 / 4 Fermenters Active',
      'efficiency': 0.0,
      'flag': 'AWAITING SYNC',
      'color': AppColors.divider,
      'icon': Icons.factory_rounded,
    },
    {
      'id': 'operator3',
      'factoryCode': 'F03',
      'title': 'Nellikuppam Operations',
      'vessels': '0 / 4 Fermenters Active',
      'efficiency': 0.0,
      'flag': 'AWAITING SYNC',
      'color': AppColors.divider,
      'icon': Icons.factory_rounded,
    },
    {
      'id': 'operator4',
      'factoryCode': 'F04',
      'title': 'Sivagangai Operations',
      'vessels': '0 / 4 Fermenters Active',
      'efficiency': 0.0,
      'flag': 'AWAITING SYNC',
      'color': AppColors.divider,
      'icon': Icons.factory_rounded,
    },
    {
      'id': 'operator5',
      'factoryCode': 'F05',
      'title': 'Bagalkot Operations',
      'vessels': '0 / 4 Fermenters Active',
      'efficiency': 0.0,
      'flag': 'AWAITING SYNC',
      'color': AppColors.divider,
      'icon': Icons.factory_rounded,
    },
  ];

  @override
  void initState() {
    super.initState();
    
    // Load pre-existing packets already caught by background service
    mqttTelemetryService.lastEmittedPackets.forEach((code, packet) {
      _updatePacketData(packet);
    });

    _telemetrySubscription = mqttTelemetryService.telemetryStream.listen((packet) {
      if (!mounted) return;
      setState(() {
        _updatePacketData(packet);
      });
    });
  }

  void _updatePacketData(TelemetryDataModel packet) {
    _latestPackets[packet.factoryCode] = packet;
    
    int idx = -1;
    if (packet.factoryCode == 'F01') idx = 0;
    else if (packet.factoryCode == 'F02') idx = 1;
    else if (packet.factoryCode == 'F03') idx = 2;
    else if (packet.factoryCode == 'F04') idx = 3;
    else if (packet.factoryCode == 'F05') idx = 4;

    if (idx != -1) {
      final int activeCount = packet.fermentersList.where((f) => f.status != 'AWAITING_SYNC' && f.status != 'STANDBY').length;
      _facilities[idx]['vessels'] = '$activeCount / 4 Fermenters Active';
      _facilities[idx]['efficiency'] = packet.feEfficiency / 100.0;
      _facilities[idx]['flag'] = packet.predictionLabel.toUpperCase();
      
      Color c = AppColors.divider;
      final String flag = packet.predictionLabel.toUpperCase();
      if (flag.contains('GOLDEN')) {
        c = AppColors.amber;
      } else if (flag.contains('RISK') || flag.contains('INFECTION') || flag.contains('LOW_ALCOHOL')) {
        c = AppColors.red;
      } else if (flag.contains('NORMAL')) {
        c = AppColors.teal;
      } else if (flag.contains('OPTIMAL')) {
        c = AppColors.green;
      }
      _facilities[idx]['color'] = c;
    }
  }

  @override
  void dispose() {
    _telemetrySubscription?.cancel();
    super.dispose();
  }

  void _openDashboard(String role, String factoryCode) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => DashboardScreen(role: role, factoryCode: factoryCode),
      ),
    );
  }

  Widget _buildGridItem(BuildContext context, int index, {bool isMobile = false}) {
    if (index == _facilities.length) {
      // CEO Portal Tile
      return SizedBox(
        height: isMobile ? 110 : null,
        child: GlassCard(
          padding: EdgeInsets.all(isMobile ? 10 : 16),
          borderRadius: 16,
          child: InkWell(
            onTap: () => _openDashboard('ceo', 'F01'),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.admin_panel_settings_rounded, color: AppColors.amber, size: isMobile ? 20 : 24),
                    const SizedBox(width: 8),
                    Text(
                      'PARRYS HQ (CEO)',
                      style: TextStyle(fontSize: isMobile ? 12 : 14, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ],
                ),
                if (!isMobile)
                  const Text(
                    'Corporate Executive Overview Portal with multi-facility analysis.',
                    style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                  ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('CEO Access', style: TextStyle(fontSize: isMobile ? 10 : 11, fontWeight: FontWeight.bold, color: AppColors.amber)),
                    Icon(Icons.arrow_forward_rounded, color: AppColors.amber, size: isMobile ? 16 : 18),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    }

    final f = _facilities[index];
    final color = f['color'] as Color;

    return SizedBox(
      height: isMobile ? 110 : null,
      child: GlassCard(
        padding: EdgeInsets.all(isMobile ? 10 : 16),
        borderRadius: 16,
        child: InkWell(
          onTap: () => _openDashboard(f['id'], f['factoryCode']),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(f['icon'] as IconData, color: color, size: isMobile ? 18 : 22),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      f['title'] as String,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: isMobile ? 11.5 : 13, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                ],
              ),
              Text(
                f['vessels'] as String,
                style: TextStyle(fontSize: isMobile ? 10 : 11, color: AppColors.textMuted),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: isMobile ? 6 : 8, vertical: isMobile ? 2 : 4),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: color.withValues(alpha: 0.4)),
                    ),
                    child: Text(
                      f['flag'] as String,
                      style: TextStyle(fontSize: isMobile ? 8.5 : 9, fontWeight: FontWeight.bold, color: color),
                    ),
                  ),
                  Text(
                    f['efficiency'] > 0
                        ? '${((f['efficiency'] as double) * 100).toStringAsFixed(1)}%'
                        : 'OFFLINE',
                    style: TextStyle(fontSize: isMobile ? 12 : 13, fontWeight: FontWeight.bold, color: color),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Recompute total plant KPI summary statistics from live packets
    int totalActive = 0;
    double totalYield = 0.0;
    double totalEffSum = 0.0;
    int activeAlarms = 0;

    for (final p in _latestPackets.values) {
      totalActive += p.fermentersList.where((f) => f.status != 'AWAITING_SYNC' && f.status != 'STANDBY').length;
      totalYield += p.actualProduction;
      totalEffSum += p.feEfficiency;
      final String flag = p.predictionLabel.toUpperCase();
      if (flag.contains('RISK') || flag.contains('INFECTION') || flag.contains('LOW_ALCOHOL')) {
        activeAlarms++;
      }
    }
    
    final double avgEff = _latestPackets.isNotEmpty ? (totalEffSum / _latestPackets.length) : 0.0;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final bool isMobile = constraints.maxWidth < 600;

            Widget mainContent = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Row
                isMobile
                    ? SizedBox(
                        width: double.infinity,
                        height: 70,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: const [
                                Icon(Icons.precision_manufacturing_rounded, color: AppColors.primaryBlue, size: 24),
                                SizedBox(height: 4),
                                Text(
                                  'PARRYS | AURA',
                                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1.5),
                                ),
                                Text(
                                  'Enterprise Corporate Control Center',
                                  style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                                ),
                              ],
                            ),
                            Positioned(
                              right: 0,
                              top: 10,
                              child: IconButton(
                                icon: const Icon(Icons.logout_rounded, color: AppColors.red),
                                tooltip: 'Logout to Main Login',
                                onPressed: () {
                                  Navigator.of(context).pushReplacement(
                                    MaterialPageRoute(builder: (context) => const LoginScreen(skipVideo: true)),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      )
                    : Row(
                        children: [
                          const Icon(Icons.precision_manufacturing_rounded, color: AppColors.primaryBlue, size: 28),
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                'PARRYS | AURA',
                                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1.5),
                              ),
                              Text(
                                'Enterprise Corporate Control Center',
                                style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                              ),
                            ],
                          ),
                          const Spacer(),
                          IconButton(
                            icon: const Icon(Icons.logout_rounded, color: AppColors.red),
                            tooltip: 'Logout to Main Login',
                            onPressed: () {
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(builder: (context) => const LoginScreen(skipVideo: true)),
                              );
                            },
                          ),
                        ],
                      ),
                const SizedBox(height: 20),

                // Top 4 Corporate KPI Summary Cards
                isMobile
                    ? GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: 2,
                        childAspectRatio: 2.8,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                        children: [
                          _buildKpiSummaryCard('$totalActive / 20 Active Fermenters', 'Plant Status', Icons.grid_view_rounded, AppColors.primaryBlue),
                          _buildKpiSummaryCard('${totalYield.toStringAsFixed(1)} KL Daily Yield', 'Total Output', Icons.water_drop_rounded, AppColors.teal),
                          _buildKpiSummaryCard('${avgEff.toStringAsFixed(1)}% Avg Efficiency', 'System Health', Icons.speed_rounded, AppColors.cyan),
                          _buildKpiSummaryCard('$activeAlarms RISK ALERTS', 'Active Alarms', Icons.warning_amber_rounded, AppColors.red),
                        ],
                      )
                    : Row(
                        children: [
                          _buildKpiSummaryCard('$totalActive / 20 Active Fermenters', 'Plant Status', Icons.grid_view_rounded, AppColors.primaryBlue),
                          const SizedBox(width: 12),
                          _buildKpiSummaryCard('${totalYield.toStringAsFixed(1)} KL Daily Yield', 'Total Output', Icons.water_drop_rounded, AppColors.teal),
                          const SizedBox(width: 12),
                          _buildKpiSummaryCard('${avgEff.toStringAsFixed(1)}% Avg Efficiency', 'System Health', Icons.speed_rounded, AppColors.cyan),
                          const SizedBox(width: 12),
                          _buildKpiSummaryCard('$activeAlarms RISK ALERTS', 'Active Alarms', Icons.warning_amber_rounded, AppColors.red),
                        ],
                      ),
                const SizedBox(height: 20),

                const Text(
                  'SELECT DISTILLERY FACILITY FOR OPERATIONAL DASHBOARD',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1),
                ),
                const SizedBox(height: 14),

                // 5 Facility Cards Grid (2x2x1 layout on mobile, no CEO portal)
                isMobile
                    ? Column(
                        children: [
                          Row(
                            children: [
                              Expanded(child: _buildGridItem(context, 0, isMobile: true)),
                              const SizedBox(width: 8),
                              Expanded(child: _buildGridItem(context, 1, isMobile: true)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(child: _buildGridItem(context, 2, isMobile: true)),
                              const SizedBox(width: 8),
                              Expanded(child: _buildGridItem(context, 3, isMobile: true)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Spacer(),
                              Expanded(
                                flex: 2,
                                child: _buildGridItem(context, 4, isMobile: true),
                              ),
                              const Spacer(),
                            ],
                          ),
                        ],
                      )
                    : Expanded(
                        child: GridView.builder(
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            childAspectRatio: 1.6,
                            crossAxisSpacing: 14,
                            mainAxisSpacing: 14,
                          ),
                          itemCount: _facilities.length + 1,
                          itemBuilder: (context, index) => _buildGridItem(context, index),
                        ),
                      ),
              ],
            );

            if (isMobile) {
              return SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: mainContent,
                ),
              );
            }

            return Padding(
              padding: const EdgeInsets.all(20),
              child: mainContent,
            );
          },
        ),
      ),
    );
  }

  Widget _buildKpiSummaryCard(String title, String subtitle, IconData icon, Color color) {
    return GlassCard(
      padding: const EdgeInsets.all(10),
      borderRadius: 14,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: Colors.white),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 8.5, color: AppColors.textMuted),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
