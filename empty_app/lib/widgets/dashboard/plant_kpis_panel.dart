import 'package:flutter/material.dart';
import '../common/glass_card.dart';
import '../../utils/app_colors.dart';

class PlantKpisPanel extends StatelessWidget {
  final double yeastCount;
  final double volatileAcidityPpm;
  final double ph;
  final double brix;
  final double temperature;
  final double fermentationEfficiency;
  final String vesselTitle;
  final String status;
  final bool isEmpty;

  const PlantKpisPanel({
    super.key,
    this.yeastCount = 320.0,
    this.volatileAcidityPpm = 55.0,
    this.ph = 4.5,
    this.brix = 4.0,
    this.temperature = 32.0,
    this.fermentationEfficiency = 88.0,
    this.vesselTitle = 'Fermentation 1',
    this.status = 'GOLDEN BATCH',
    this.isEmpty = false,
  });

  @override
  Widget build(BuildContext context) {
    final double yeastNorm = (yeastCount / 500.0).clamp(0.05, 1.0);
    final double vaNorm = (volatileAcidityPpm / 150.0).clamp(0.05, 1.0);
    final double phNorm = ph > 0 ? ((ph - 3.5) / 2.0).clamp(0.05, 1.0) : 0.43;

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

          // 2. Linear parameter stats rows matching mockup values with dynamic data
          _buildKpiRow('Yeast Count', '${yeastCount.toStringAsFixed(0)}/0', yeastNorm, AppColors.cyan),
          const SizedBox(height: 5),
          _buildKpiRow('Volatile Acids', volatileAcidityPpm.toStringAsFixed(1), vaNorm, AppColors.orange),
          const SizedBox(height: 5),
          _buildKpiRow('pH', ph.toStringAsFixed(2), phNorm, AppColors.red),
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
          _buildKpiRow('Volatile Acids', '${volatileAcidityPpm.toStringAsFixed(0)}/0', (vaNorm * 0.8).clamp(0.05, 1.0), AppColors.cyan),
          const SizedBox(height: 5),
          _buildKpiRow('pH', (ph + 0.1).toStringAsFixed(2), (phNorm * 1.1).clamp(0.05, 1.0), AppColors.textMuted),
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
