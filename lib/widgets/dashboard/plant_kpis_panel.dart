import 'package:flutter/material.dart';
import '../common/glass_card.dart';
import '../../utils/app_colors.dart';

class PlantKpisPanel extends StatefulWidget {
  const PlantKpisPanel({
    super.key,
  });

  @override
  State<PlantKpisPanel> createState() => _PlantKpisPanelState();
}

class _PlantKpisPanelState extends State<PlantKpisPanel> {
  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      borderRadius: 24,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Header conformed to mockup layout
          const Row(
            children: [
              Icon(Icons.lock_rounded, color: AppColors.red, size: 14),
              SizedBox(width: 6),
              Text(
                'Plant-wide KPIs & Alarms',
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),

          // 2. Linear parameter stats rows matching mockup values
          _buildKpiRow('Yeast Count', '55/0', 0.55, AppColors.cyan),
          const SizedBox(height: 5),
          _buildKpiRow('Volatile Acids', '80.0', 0.80, AppColors.orange),
          const SizedBox(height: 5),
          _buildKpiRow('pH', '4.35', 0.43, AppColors.red),
          const SizedBox(height: 8),

          // 3. Flat space-efficient secondary alarms list
          const Text(
            'Plant-wide & Alarms',
            style: TextStyle(
              fontSize: 9.5,
              fontWeight: FontWeight.bold,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 5),
          _buildKpiRow('Volatile Acids', '51/0', 0.51, AppColors.cyan),
          const SizedBox(height: 5),
          _buildKpiRow('pH', '4.75', 0.68, AppColors.textMuted),
        ],
      ),
    );
  }

  Widget _buildKpiRow(String label, String value, double progress, Color barColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 9.5, color: AppColors.textSecondary, fontWeight: FontWeight.bold),
            ),
            Text(
              value,
              style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: barColor),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(2),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 4,
            backgroundColor: AppColors.glassOverlay,
            valueColor: AlwaysStoppedAnimation<Color>(barColor),
          ),
        ),
      ],
    );
  }
}
