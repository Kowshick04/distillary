import 'package:flutter/material.dart';
import '../common/glass_card.dart';
import '../../models/telemetry_data_model.dart';
import '../../utils/app_colors.dart';

class KpiData {
  final String title;
  final String value;
  final String unit;
  final String change;
  final bool isPositive;
  final IconData icon;
  final Color iconBgColor;
  final Color iconColor;

  const KpiData({
    required this.title,
    required this.value,
    this.unit = '',
    required this.change,
    required this.isPositive,
    required this.icon,
    required this.iconBgColor,
    required this.iconColor,
  });
}

class TopKpiBar extends StatelessWidget {
  final TelemetryDataModel? telemetry;

  const TopKpiBar({super.key, this.telemetry});

  List<KpiData> get _kpiItems {
    final t = telemetry;
    return [
      KpiData(
        title: 'Active Fermenters',
        value: t != null ? t.activeFermentersText : '12 / 16 Running',
        change: '+2 since last shift',
        isPositive: true,
        icon: Icons.science_rounded,
        iconBgColor: const Color(0xFFEBF3FF),
        iconColor: AppColors.primaryBlue,
      ),
      KpiData(
        title: 'Predicted Ethanol Production',
        value: t != null ? t.predictedEthanolText : '48.2 KL',
        change: '+3.5% vs Yesterday',
        isPositive: true,
        icon: Icons.local_gas_station_rounded,
        iconBgColor: const Color(0xFFF3E8FF),
        iconColor: AppColors.purple,
      ),
      KpiData(
        title: 'Average Alcohol Content',
        value: t != null ? t.avgAlcoholText : '8.2 %',
        change: '+0.4%',
        isPositive: true,
        icon: Icons.water_drop_rounded,
        iconBgColor: const Color(0xFFDCFCE7),
        iconColor: AppColors.cyan, // conformed Teal
      ),
      KpiData(
        title: 'Completed Batches Today',
        value: t != null ? t.completedBatchesText : '5',
        change: '+1 vs Yesterday',
        isPositive: true,
        icon: Icons.check_circle_rounded,
        iconBgColor: const Color(0xFFDCFCE7),
        iconColor: AppColors.cyan, // conformed Teal
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: _kpiItems.map((item) {
            final cardWidth = (constraints.maxWidth - (12 * 3)) / 4;
            return SizedBox(
              width: cardWidth < 180 ? (constraints.maxWidth - 12) / 2 : cardWidth,
              child: GlassCard(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                borderRadius: 16,
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: item.iconColor.withValues(alpha: 0.12), // Frosted dynamic circle
                        shape: BoxShape.circle,
                      ),
                      child: Icon(item.icon, color: item.iconColor, size: 20),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            item.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.textMuted, // Steel Gray
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 2),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.baseline,
                              textBaseline: TextBaseline.alphabetic,
                              children: [
                                Text(
                                  item.value,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary, // Off-white
                                  ),
                                ),
                                if (item.unit.isNotEmpty) ...[
                                  const SizedBox(width: 4),
                                  Text(
                                    item.unit,
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textSecondary, // Light Gray
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          // Removed subtitle change text for minimal visual layout
                        ],
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
