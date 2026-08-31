import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../common/glass_card.dart';
import 'overlapping_hills_chart.dart';
import 'three_d_prism_column.dart';
import '../../models/telemetry_data_model.dart';
import '../../utils/app_colors.dart';

class FermentationStageInfo {
  final String id;
  final String stageNumber;
  final String name;
  final String status;
  final IconData icon;
  final Color color;
  final bool isCompleted;
  final bool isRunning;

  const FermentationStageInfo({
    required this.id,
    required this.stageNumber,
    required this.name,
    required this.status,
    required this.icon,
    required this.color,
    this.isCompleted = false,
    this.isRunning = false,
  });
}

class WorkflowProcessCard extends StatefulWidget {
  final TelemetryDataModel? telemetry;
  final Function(String stageId)? onStageTap;
  final String selectedBatch;
  final List<String> batches;
  final ValueChanged<String>? onBatchChanged;

  const WorkflowProcessCard({
    super.key,
    this.telemetry,
    this.onStageTap,
    required this.selectedBatch,
    required this.batches,
    this.onBatchChanged,
  });

  @override
  State<WorkflowProcessCard> createState() => _WorkflowProcessCardState();
}

class _WorkflowProcessCardState extends State<WorkflowProcessCard> {
  bool _isScadaView = true; // Added view switcher state flag

  // Rolling 24-point history for the live chart
  final List<double> _tempHistory = [];
  final List<double> _alcoholHistory = [];
  final List<double> _phHistory = [];

  static const int _maxHistoryPoints = 24;

  static const List<FermentationStageInfo> _stages = [
    FermentationStageInfo(
      id: "01",
      stageNumber: "Stage 1",
      name: "Molasses Preparation",
      status: "Completed",
      icon: Icons.blender_rounded,
      color: AppColors.cyan, // Conformed to Teal
      isCompleted: true,
    ),
    FermentationStageInfo(
      id: "02",
      stageNumber: "Stage 2",
      name: "Yeast Charging",
      status: "Completed",
      icon: Icons.bubble_chart_rounded,
      color: AppColors.cyan, // Conformed to Teal
      isCompleted: true,
    ),
    FermentationStageInfo(
      id: "03",
      stageNumber: "Stage 3",
      name: "Active Fermentation",
      status: "Running",
      icon: Icons.local_fire_department_rounded,
      color: AppColors.orange, // Conformed to Warm Orange
      isRunning: true,
    ),
    FermentationStageInfo(
      id: "04",
      stageNumber: "Stage 4",
      name: "Cooling",
      status: "Upcoming",
      icon: Icons.ac_unit_rounded,
      color: AppColors.textMuted, // Conformed to Steel Gray
    ),
    FermentationStageInfo(
      id: "05",
      stageNumber: "Stage 5",
      name: "Batch Complete",
      status: "Pending",
      icon: Icons.check_circle_outline_rounded,
      color: AppColors.textMuted, // Conformed to Steel Gray
    ),
  ];

  @override
  void initState() {
    super.initState();
    // Seed history with realistic baseline values
    _seedHistory();
  }

  void _seedHistory() {
    for (int i = 0; i < _maxHistoryPoints; i++) {
      _tempHistory.add(31.0 + (i / _maxHistoryPoints) * 1.5);
      _alcoholHistory.add(1.2 + (i / _maxHistoryPoints) * 7.0);
      _phHistory.add(5.4 - (i / _maxHistoryPoints) * 0.8);
    }
  }

  @override
  void didUpdateWidget(WorkflowProcessCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    final t = widget.telemetry;
    if (t != null && t != oldWidget.telemetry) {
      // Push new live values into rolling history
      if (_tempHistory.length >= _maxHistoryPoints) _tempHistory.removeAt(0);
      if (_alcoholHistory.length >= _maxHistoryPoints) _alcoholHistory.removeAt(0);
      if (_phHistory.length >= _maxHistoryPoints) _phHistory.removeAt(0);

      _tempHistory.add(t.temperature);
      _alcoholHistory.add(t.alcohol);
      _phHistory.add(t.ph);
    }
  }

  List<FlSpot> _toSpots(List<double> values) {
    return values.asMap().entries
        .map((e) => FlSpot(e.key.toDouble(), e.value))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.telemetry;

    final batchId = t != null ? 'F-${t.batchId}' : 'F-1025';
    final batchProgress = t != null
        ? '${(t.fermentationEfficiency * 0.74).clamp(10.0, 99.0).toStringAsFixed(0)}%'
        : '68%';
    final alcoholCurrent = t != null ? '${t.alcohol.toStringAsFixed(1)}%' : '7.9%';
    final alcoholExpected = t != null
        ? '${(t.alcohol + 0.5).toStringAsFixed(1)}%'
        : '8.4%';
    final yeastHealth = t != null
        ? (t.agitatorHealthScore > 88 ? 'Healthy' : 'Caution')
        : 'Healthy';
    final yeastColor = yeastHealth == 'Healthy'
        ? AppColors.green
        : AppColors.amber;
    final fermentEff = t != null
        ? '${t.fermentationEfficiency.toStringAsFixed(1)}%'
        : '91.8%';

    return GlassCard(
      padding: const EdgeInsets.all(22),
      borderRadius: 24,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header, Switcher & Legend
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            runSpacing: 12,
            spacing: 16,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.science_rounded, color: AppColors.blue, size: 22), // Cyan conformed
                      SizedBox(width: 8),
                      Text(
                        'Fermentation Real-time SCADA Metrics',
                        style: TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary, // Off-white
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 2),
                ],
              ),
              
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Batch / Fermenter Selector capsule
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.glassOverlay, // Very faint frosted capsule
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0x14FFFFFF)),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: widget.selectedBatch,
                        dropdownColor: AppColors.surface,
                        icon: const Icon(Icons.arrow_drop_down, color: AppColors.blue),
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                        onChanged: (val) {
                          if (val != null) {
                            widget.onBatchChanged?.call(val);
                          }
                        },
                        items: widget.batches.map((batch) {
                          return DropdownMenuItem<String>(
                            value: batch,
                            child: Text(batch),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  
                  // View Switcher Container (SCADA View vs Trend View)
                  Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: AppColors.glassOverlay, // Very faint frosted capsule
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0x14FFFFFF)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        GestureDetector(
                          onTap: () => setState(() => _isScadaView = true),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: _isScadaView ? AppColors.blue.withValues(alpha: 0.12) : Colors.transparent, // Frosted Cyan active
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: _isScadaView ? AppColors.blue.withValues(alpha: 0.2) : Colors.transparent,
                                width: 1,
                              ),
                            ),
                            child: Text(
                              'SCADA View',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: _isScadaView ? AppColors.textPrimary : AppColors.textMuted,
                              ),
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () => setState(() => _isScadaView = false),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: !_isScadaView ? AppColors.blue.withValues(alpha: 0.12) : Colors.transparent, // Frosted Cyan active
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: !_isScadaView ? AppColors.blue.withValues(alpha: 0.2) : Colors.transparent,
                                width: 1,
                              ),
                            ),
                            child: Text(
                              'Trend View',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: !_isScadaView ? AppColors.textPrimary : AppColors.textMuted,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Custom Indicators Legend Wrap (replaces overflow Row)
          Wrap(
            spacing: 14,
            runSpacing: 8,
            children: [
              _buildLegendItem('Fermentation Eff.', AppColors.orange), // Orange
              _buildLegendItem('Agitator Health', AppColors.teal), // Emerald Green
              _buildLegendItem('Plant Power', AppColors.primaryBlue), // Neon Blue
              _buildLegendItem('Cooling Flow', AppColors.cyan), // Cyan
              _buildLegendItem('Batch Quality', AppColors.purple), // Purple/Magenta
              _buildLegendItem('Golden Batch Target (Dashed)', AppColors.amber), // Golden Reference
            ],
          ),
          const SizedBox(height: 24),

          // 5-Stage Fermentation Process Timeline - 3D Glass Prism Columns Layout
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: _stages.map((stage) {
                // Map heights and states dynamically conformed to brand layout
                double hFactor = 0.5;
                bool isCompleted = false;
                bool isActive = false;
                Color baseCol = AppColors.textMuted; // Steel Gray

                if (stage.id == "01") {
                  hFactor = 0.80;
                  isCompleted = true;
                  baseCol = AppColors.cyan; // Teal
                } else if (stage.id == "02") {
                  hFactor = 0.65;
                  isCompleted = true;
                  baseCol = AppColors.cyan; // Teal
                } else if (stage.id == "03") {
                  hFactor = t != null ? (t.fermentationEfficiency / 100.0) : 0.90;
                  isActive = true;
                  baseCol = AppColors.orange; // Orange
                } else if (stage.id == "04") {
                  hFactor = 0.45;
                  baseCol = AppColors.textMuted; // Steel Gray
                } else if (stage.id == "05") {
                  hFactor = 0.20;
                  baseCol = AppColors.textMuted; // Steel Gray
                }

                return Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    ThreeDPrismColumn(
                      label: stage.name,
                      heightFactor: hFactor,
                      baseColor: baseCol,
                      isActive: isActive,
                      isCompleted: isCompleted,
                      onTap: () {
                        widget.onStageTap?.call(stage.id);
                      },
                    ),
                    if (stage.id != "05")
                      Container(
                        margin: const EdgeInsets.only(bottom: 70),
                        child: Icon(
                          Icons.water_drop_rounded,
                          color: baseCol.withValues(alpha: isActive ? 0.8 : 0.3),
                          size: 14,
                        ),
                      ),
                  ],
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 24),

          // Standalone AI Prediction Badge showing actual classification conformed to style
          _buildAiPredictionBadge(t),
          const SizedBox(height: 16),

          // Live Multi-line Analytics Chart + Floating Badges
          // Live Toggleable Chart (SCADA View vs Trend View)
          _isScadaView
              ? SizedBox(
                  height: 220,
                  child: OverlappingHillsChart(
                    totalEmissions: t != null
                        ? (t.fermentationEfficiency * 0.74).clamp(10.0, 99.0)
                        : 68.0,
                    unit: '%',
                    summaryTitle: 'Progress',
                    summaryDescription: 'Current Batch Progress',
                    hills: _getHills(t),
                  ),
                )
              : SizedBox(
                  height: 200,
                  child: Stack(
                    children: [
                      // Live Trend chart
                      LineChart(
                        LineChartData(
                          gridData: FlGridData(
                            show: true,
                            drawVerticalLine: false,
                            getDrawingHorizontalLine: (value) => const FlLine(
                              color: AppColors.glassOverlay, // Conformed dark grid lines
                              strokeWidth: 1,
                            ),
                          ),
                          titlesData: const FlTitlesData(show: false),
                          borderData: FlBorderData(show: false),
                          lineBarsData: [
                            // Orange = Temperature
                            LineChartBarData(
                              spots: _toSpots(_tempHistory),
                              isCurved: true,
                              color: AppColors.orange, // Warm Orange
                              barWidth: 2.5,
                              dotData: const FlDotData(show: false),
                              belowBarData: BarAreaData(
                                show: true,
                                color: AppColors.orange.withValues(alpha: 0.07),
                              ),
                            ),
                            // Teal = Alcohol %
                            LineChartBarData(
                              spots: _toSpots(_alcoholHistory),
                              isCurved: true,
                              color: AppColors.teal, // Emerald Green conformed
                              barWidth: 2.5,
                              dotData: const FlDotData(show: false),
                              belowBarData: BarAreaData(
                                show: true,
                                color: AppColors.teal.withValues(alpha: 0.07),
                              ),
                            ),
                            // Cyan = pH
                            LineChartBarData(
                              spots: _toSpots(_phHistory),
                              isCurved: true,
                              color: AppColors.primaryBlue, // Neon Blue conformed
                              barWidth: 2.5,
                              dotData: const FlDotData(show: false),
                              belowBarData: BarAreaData(
                                show: true,
                                color: AppColors.primaryBlue.withValues(alpha: 0.07),
                              ),
                            ),
                            // Golden = Ideal Golden Batch Target Reference
                            LineChartBarData(
                              spots: _getGoldenTargetSpots(),
                              isCurved: true,
                              color: AppColors.amber, // Golden Reference
                              barWidth: 2.0,
                              dashArray: [6, 4],
                              dotData: const FlDotData(show: false),
                              belowBarData: BarAreaData(show: false),
                            ),
                          ],
                        ),
                      ),

                      // Floating live data glass badges
                      Positioned(
                        left: 10,
                        top: 10,
                        child: _buildFloatingCard(
                          title: 'Current Batch',
                          value: batchId,
                          sub2: 'Progress: $batchProgress',
                          icon: Icons.inventory_2_outlined,
                          iconColor: AppColors.primaryBlue,
                        ),
                      ),
                      Positioned(
                        left: 190,
                        top: 10,
                        child: _buildFloatingCard(
                          title: 'Alcohol Prediction',
                          value: alcoholCurrent,
                          sub2: 'Expected: $alcoholExpected',
                          icon: Icons.auto_graph_rounded,
                          iconColor: AppColors.teal,
                        ),
                      ),
                      Positioned(
                        right: 190,
                        bottom: 12,
                        child: _buildFloatingCard(
                          title: 'Yeast Health',
                          value: yeastHealth,
                          sub2: 'Confidence: 98%',
                          icon: Icons.health_and_safety_outlined,
                          iconColor: yeastColor,
                        ),
                      ),
                      Positioned(
                        right: 10,
                        bottom: 12,
                        child: _buildFloatingCard(
                          title: 'Fermentation Eff.',
                          value: fermentEff,
                          sub2: 'Current Batch',
                          icon: Icons.bolt_rounded,
                          iconColor: AppColors.orange,
                        ),
                      ),
                    ],
                  ),
                ),
        ],
      ),
    );
  }

  Widget _buildAiPredictionBadge(TelemetryDataModel? t) {
    final String label = t != null ? t.predictionLabel : 'normal';
    final double confidence = t != null ? t.predictionConfidence : 78.0;

    final String displayLabel;
    if (label == 'golden') {
      displayLabel = 'Golden Batch Target';
    } else if (label == 'normal') {
      displayLabel = 'Normal Batch';
    } else {
      displayLabel = 'Low Alcohol Batch';
    }

    final Color statusColor;
    final String reliability;
    if (confidence >= 85.0) {
      statusColor = AppColors.teal; // Emerald Green
      reliability = 'Reliable';
    } else if (confidence >= 70.0) {
      statusColor = AppColors.amber; // Amber Warning
      reliability = 'Borderline';
    } else {
      statusColor = AppColors.red; // Red Alarm
      reliability = 'Low Reliability';
    }

    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      borderRadius: 16,
      borderColor: statusColor.withValues(alpha: 0.3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.auto_awesome,
                  color: statusColor,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'AI BATCH PREDICTION CLASSIFIER',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                      color: AppColors.textMuted,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Predicted: $displayLabel',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.glassOverlay,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0x14FFFFFF)),
            ),
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: statusColor,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: statusColor.withValues(alpha: 0.5),
                        blurRadius: 6,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${confidence.toStringAsFixed(1)}% Confidence ($reliability)',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<FlSpot> _getGoldenTargetSpots() {
    final List<FlSpot> spots = [];
    for (int i = 0; i < _maxHistoryPoints; i++) {
      final double progress = i / (_maxHistoryPoints - 1);
      final double targetVal = 30.8 + progress * 1.6;
      spots.add(FlSpot(i.toDouble(), targetVal));
    }
    return spots;
  }

  List<HillData> _getHills(TelemetryDataModel? t) {
    return [
      HillData(
        label: 'Fermentation Eff.',
        value: t?.fermentationEfficiency ?? 91.4,
        color: AppColors.orange, // Orange
        peakXPercent: 0.35,
        widthPercent: 0.35,
        heightPercent: 0.55,
        suffix: '%',
      ),
      HillData(
        label: 'Agitator Health',
        value: t?.agitatorHealthScore ?? 93.9,
        color: AppColors.teal, // Emerald Green conformed
        peakXPercent: 0.46,
        widthPercent: 0.32,
        heightPercent: 0.48,
        suffix: '%',
      ),
      HillData(
        label: 'Plant Power',
        value: t?.plantPowerKw ?? 88.4,
        color: AppColors.primaryBlue, // Neon Blue conformed
        peakXPercent: 0.56,
        widthPercent: 0.28,
        heightPercent: 0.38,
        suffix: ' kW',
      ),
      HillData(
        label: 'Cooling Flow',
        value: t?.coolingWaterFlowLpm ?? 421.7,
        color: AppColors.cyan, // Cyan conformed
        peakXPercent: 0.65,
        widthPercent: 0.24,
        heightPercent: 0.28,
        suffix: ' LPM',
      ),
      HillData(
        label: 'Batch Quality',
        value: t?.batchQualityScore ?? 71.6,
        color: AppColors.purple, // Purple/Magenta conformed
        peakXPercent: 0.74,
        widthPercent: 0.20,
        heightPercent: 0.20,
        suffix: '%',
      ),
    ];
  }

  Widget _buildLegendItem(String title, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          title,
          style: const TextStyle(
              fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary), // Light Gray conformed
        ),
      ],
    );
  }

  Widget _buildFloatingCard({
    required String title,
    required String value,
    required String sub2,
    required IconData icon,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.12), // 12% Deep Navy glass
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0x22FFFFFF), width: 1.5), // Specular light highlight
        boxShadow: const [
          BoxShadow(color: Color(0x0C0E1F35), blurRadius: 10, offset: Offset(0, 4))
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: iconColor),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(title,
                  style: const TextStyle(
                      fontSize: 9,
                      color: AppColors.textMuted, // Steel Gray
                      fontWeight: FontWeight.bold)),
              Text(value,
                  style: TextStyle(
                      fontSize: 13, fontWeight: FontWeight.bold, color: iconColor)),
              Text(sub2,
                  style: const TextStyle(fontSize: 9, color: AppColors.textSecondary)), // Light Gray
            ],
          ),
        ],
      ),
    );
  }
}
