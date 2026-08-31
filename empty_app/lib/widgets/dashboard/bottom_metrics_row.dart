import 'package:flutter/material.dart';
import '../common/glass_card.dart';
import '../../models/telemetry_data_model.dart';
import '../../utils/app_colors.dart';

class BottomMetricsRow extends StatelessWidget {
  final TelemetryDataModel? telemetry;

  const BottomMetricsRow({super.key, this.telemetry});

  @override
  Widget build(BuildContext context) {
    final t = telemetry;

    final items = [
      _MetricCardData(
        label: 'Average Temperature',
        value: t != null ? t.avgTempText : '32.1\u00B0C',
        status: 'Optimal (30 - 33\u00B0C)',
        icon: Icons.thermostat_rounded,
        color: AppColors.blue, // Cyan
      ),
      _MetricCardData(
        label: 'Average pH',
        value: t != null ? t.avgPhText : '4.65',
        status: 'Healthy (4.5 - 4.8)',
        icon: Icons.biotech_rounded,
        color: const Color(0xFF496D89), // Muted Blue
      ),
      _MetricCardData(
        label: 'Average Alcohol',
        value: t != null ? t.avgAlcoholText : '7.8%',
        status: '+0.3% vs Target',
        icon: Icons.water_drop_rounded,
        color: AppColors.orange, // Warm Orange
      ),
      _MetricCardData(
        label: 'Batch Efficiency',
        value: t != null ? '${t.fermentationEfficiency.toStringAsFixed(1)}%' : '91.8%',
        status: 'Current Batch',
        icon: Icons.bolt_rounded,
        color: AppColors.cyan, // Teal
      ),
      const _MetricCardData(
        label: 'Cooling Efficiency',
        value: '95.2%',
        status: 'All Chillers Normal',
        icon: Icons.ac_unit_rounded,
        color: AppColors.blue, // Cyan
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidth = (constraints.maxWidth - (12 * 4)) / 5;
        final isMobile = cardWidth < 160;

        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: items.map((item) {
            return SizedBox(
              width: isMobile ? (constraints.maxWidth - 12) / 2 : cardWidth,
              child: GlassCard(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                borderRadius: 18,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(item.icon, color: item.color, size: 18),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            item.label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textMuted, // Steel Gray
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      item.value,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary, // Off-white
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.status,
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary, // Light Gray
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}

class _MetricCardData {
  final String label;
  final String value;
  final String status;
  final IconData icon;
  final Color color;

  const _MetricCardData({
    required this.label,
    required this.value,
    required this.status,
    required this.icon,
    required this.color,
  });
}
