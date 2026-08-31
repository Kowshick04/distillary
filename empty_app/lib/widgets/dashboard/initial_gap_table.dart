import 'package:flutter/material.dart';
import '../common/glass_card.dart';
import '../../utils/app_colors.dart';

class GapTableEntry {
  final String metric;
  final String activeVal;
  final String goldenVal;
  final String statusText;
  final Color statusColor;

  const GapTableEntry({
    required this.metric,
    required this.activeVal,
    required this.goldenVal,
    required this.statusText,
    required this.statusColor,
  });
}

class InitialGapTable extends StatelessWidget {
  final List<GapTableEntry> entries;

  const InitialGapTable({super.key, required this.entries});

  double _getProgressRatio(String metric, String activeVal) {
    try {
      final cleanVal = activeVal.replaceAll(RegExp(r'[^0-9.]'), '');
      final double numeric = double.tryParse(cleanVal) ?? 0.0;
      if (metric.toLowerCase().contains('yeast')) {
        return (numeric / 300.0).clamp(0.0, 1.0);
      } else if (metric.toLowerCase().contains('acid') || metric.toLowerCase().contains('volatile')) {
        return (numeric / 2000.0).clamp(0.0, 1.0); 
      } else if (metric.toLowerCase().contains('ph')) {
        return (numeric / 7.0).clamp(0.0, 1.0);
      }
    } catch (_) {}
    return 0.5;
  }

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(18),
      borderRadius: 24,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          // Header conformed to mockup layout: Title + Sort & Filter Dropdowns
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.analytics_rounded, color: AppColors.cyan, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Dynamic Parameter GAP Matrix',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              
              // Sort and filter buttons row
              Row(
                children: [
                  _buildHeaderButton('Sort by', Icons.keyboard_arrow_down_rounded),
                  const SizedBox(width: 8),
                  _buildHeaderButton('Filter', Icons.filter_list_rounded),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Custom table implementation using Table widget conformed to mockup
          Table(
            columnWidths: const {
              0: FlexColumnWidth(3),
              1: FlexColumnWidth(4.5),
              2: FlexColumnWidth(3),
              3: FlexColumnWidth(2.5),
            },
            border: TableBorder(
              horizontalInside: BorderSide(
                color: const Color(0xFF223B57).withValues(alpha: 0.3),
                width: 1.0,
              ),
            ),
            children: [
              // Header Row
              TableRow(
                children: [
                  _buildHeaderCell('Metric'),
                  _buildHeaderCell('Progress'),
                  _buildHeaderCell('Target (Background)'),
                  _buildHeaderCell('Status Indicator'),
                ],
              ),

              // Data Rows conformed to mockup layout
              ...entries.map((entry) {
                final ratio = _getProgressRatio(entry.metric, entry.activeVal);
                return TableRow(
                  children: [
                    _buildMetricCell(entry.metric),
                    _buildProgressCell(ratio, entry.statusColor),
                    _buildTargetCell(entry.goldenVal),
                    _buildStatusIndicatorCell(entry.statusText, entry.statusColor),
                  ],
                );
              }),
            ],
          ),
        ],
      ),
    ),
  );
}

  Widget _buildHeaderButton(String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF223B57).withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF223B57).withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 10, color: AppColors.textSecondary, fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 4),
          Icon(icon, size: 12, color: AppColors.textSecondary),
        ],
      ),
    );
  }

  Widget _buildHeaderCell(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.8,
          color: AppColors.textMuted,
        ),
      ),
    );
  }

  Widget _buildMetricCell(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }

  Widget _buildProgressCell(double ratio, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      child: Center(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(3),
          child: LinearProgressIndicator(
            value: ratio,
            minHeight: 6.0,
            backgroundColor: const Color(0x0DFFFFFF),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ),
    );
  }

  Widget _buildTargetCell(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  Widget _buildStatusIndicatorCell(String text, Color color) {
    // Standardize status texts to match mockup ("Sub-optimal", "Optional", "Clear")
    String statusLabel = text;
    if (text.toLowerCase().contains('optimal') && !text.toLowerCase().contains('sub')) {
      statusLabel = 'Optional';
    } else if (text.toLowerCase().contains('sub')) {
      statusLabel = 'Sub-optimal';
    } else {
      statusLabel = 'Clear';
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.6),
                  blurRadius: 4,
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          Text(
            statusLabel,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
