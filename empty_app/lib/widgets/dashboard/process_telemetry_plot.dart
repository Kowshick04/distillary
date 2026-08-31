import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../common/glass_card.dart';
import '../../utils/app_colors.dart';

class ProcessTelemetryPlot extends StatelessWidget {
  final List<double> brixHistory;
  final List<double> alcoholHistory;
  final List<double> tempHistory;

  const ProcessTelemetryPlot({
    super.key,
    required this.brixHistory,
    required this.alcoholHistory,
    required this.tempHistory,
  });

  List<FlSpot> _toSpots(List<double> values) {
    return values.asMap().entries
        .map((e) => FlSpot(e.key.toDouble(), e.value))
        .toList();
  }

  // Golden Shadow baseline reference curve (sigmoidal profile of a perfect batch)
  List<FlSpot> _getGoldenShadowSpots() {
    final List<FlSpot> spots = [];
    const int count = 24;
    for (int i = 0; i < count; i++) {
      final double progress = i / (count - 1);
      final double targetBrix = 7.5 - progress * 6.3;
      spots.add(FlSpot(i.toDouble(), targetBrix));
    }
    return spots;
  }

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(18),
      borderRadius: 24,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header + Legend Indicator Icons row conformed to mockup
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.stacked_line_chart_rounded, color: AppColors.blue, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Process Telemetry Plot',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              // Header dropdown style tag on far right matching mockup
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF223B57).withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFF223B57).withValues(alpha: 0.5)),
                ),
                child: const Row(
                  children: [
                    Text(
                      'Golden Shadow Range',
                      style: TextStyle(fontSize: 10, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
                    ),
                    SizedBox(width: 4),
                    Icon(Icons.keyboard_arrow_down_rounded, size: 12, color: AppColors.textSecondary),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Legend alignment
          Wrap(
            spacing: 12,
            runSpacing: 6,
            children: [
              _buildLegendItem('Brix Consumption', AppColors.purple), 
              _buildLegendItem('Alcohol Yield', AppColors.cyan), 
              _buildLegendItem('Temperature', AppColors.orange, isDashed: true), 
              _buildLegendItem('Golden Shadow', AppColors.textMuted, isFaded: true), 
            ],
          ),
          const SizedBox(height: 20),

          // Trend Chart Canvas overlaid with vertical line and tooltip
          LayoutBuilder(
            builder: (context, constraints) {
              final double chartWidth = constraints.maxWidth;
              // Hour 2 Baseline is at index 2 out of 23.
              final double markerLeft = chartWidth * (2.0 / 23.0);

              return SizedBox(
                height: 250,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // 1. Grid & Lines Chart
                    LineChart(
                      LineChartData(
                        gridData: FlGridData(
                          show: true,
                          drawVerticalLine: false,
                          getDrawingHorizontalLine: (value) => const FlLine(
                            color: Color(0x08FFFFFF),
                            strokeWidth: 1,
                          ),
                        ),
                        titlesData: const FlTitlesData(show: false),
                        borderData: FlBorderData(show: false),
                        lineBarsData: [
                          // Golden Shadow Reference
                          LineChartBarData(
                            spots: _getGoldenShadowSpots(),
                            isCurved: true,
                            color: AppColors.textMuted.withValues(alpha: 0.18),
                            barWidth: 3.5,
                            dotData: const FlDotData(show: false),
                            belowBarData: BarAreaData(show: false),
                          ),
                          // Brix
                          LineChartBarData(
                            spots: _toSpots(brixHistory),
                            isCurved: true,
                            color: AppColors.purple,
                            barWidth: 2.5,
                            dotData: const FlDotData(show: false),
                            belowBarData: BarAreaData(
                              show: true,
                              color: AppColors.purple.withValues(alpha: 0.04),
                            ),
                          ),
                          // Alcohol
                          LineChartBarData(
                            spots: _toSpots(alcoholHistory),
                            isCurved: true,
                            color: AppColors.cyan,
                            barWidth: 2.5,
                            dotData: const FlDotData(show: false),
                            belowBarData: BarAreaData(
                              show: true,
                              color: AppColors.cyan.withValues(alpha: 0.04),
                            ),
                          ),
                          // Temp
                          LineChartBarData(
                            spots: _toSpots(tempHistory),
                            isCurved: true,
                            color: AppColors.orange,
                            barWidth: 2.0,
                            dashArray: [6, 4],
                            dotData: const FlDotData(show: false),
                            belowBarData: BarAreaData(show: false),
                          ),
                        ],
                      ),
                    ),

                    // 2. Interactive Vertical Marker Line conformed to mockup
                    Positioned(
                      left: markerLeft,
                      top: 0,
                      bottom: 0,
                      child: Container(
                        width: 1.5,
                        color: AppColors.blue.withValues(alpha: 0.65),
                      ),
                    ),

                    // 3. Dot coordinate markers at Hour 2
                    Positioned(
                      left: markerLeft - 4,
                      top: 130, // Approximate intercept
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AppColors.cyan, // Cyan marker
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),

                    // 4. Floating popover card listing parameter values at Hour 2
                    Positioned(
                      left: markerLeft + 12,
                      top: 20,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.surface.withValues(alpha: 0.9), // Deep Navy matching Outline
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.blue.withValues(alpha: 0.4), width: 1.0),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.4),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              'Hour 2 Baseline',
                              style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                            const SizedBox(height: 4),
                            _buildTooltipValueRow(AppColors.purple, 'Brix', '14.09%'),
                            _buildTooltipValueRow(AppColors.cyan, 'Alcohol', '5.9%'),
                            _buildTooltipValueRow(AppColors.orange, 'Temp', '31.2\u00B0C'),
                            _buildTooltipValueRow(AppColors.purple, 'pH', '4.83'),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          
          const Text(
            'Note: If the active brix curve falls below the Golden Shadow profile, the fermentation batch is stalling.',
            style: TextStyle(
              fontSize: 9.5,
              fontStyle: FontStyle.italic,
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTooltipValueRow(Color dotColor, String metric, String val) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: dotColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            '$metric: ',
            style: const TextStyle(fontSize: 9, color: AppColors.textSecondary),
          ),
          Text(
            val,
            style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String title, Color color, {bool isDashed = false, bool isFaded = false}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 3,
          decoration: BoxDecoration(
            color: isFaded ? color.withValues(alpha: 0.25) : color,
            borderRadius: BorderRadius.circular(1),
          ),
        ),
        const SizedBox(width: 5),
        Text(
          title,
          style: TextStyle(
            fontSize: 9.5,
            fontWeight: FontWeight.bold,
            color: isFaded ? AppColors.textMuted : AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
