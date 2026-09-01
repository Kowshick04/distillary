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
    if (isEmpty) {
      return GlassCard(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        borderRadius: 24,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.sensors_off_rounded, color: AppColors.textMuted, size: 14),
                const SizedBox(width: 6),
                Text(
                  'Plant-wide KPIs & Alarms — $vesselTitle',
                  style: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Center(
              child: Text(
                'Fermenter is in STANDBY.\nNo active telemetry or threshold alarms.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 10.5,
                  color: AppColors.textMuted,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      );
    }

    final double yeastNorm = (yeastCount / 450.0).clamp(0.0, 1.0);
    final double vaNorm = (volatileAcidityPpm / 150.0).clamp(0.0, 1.0);
    final double phNorm = ph > 0 ? ((ph - 3.5) / 2.0).clamp(0.0, 1.0) : 0.5;
    final double feNorm = (fermentationEfficiency / 100.0).clamp(0.0, 1.0);

    final isGolden = status.toUpperCase().contains('GOLDEN');
    final isRisk = status.toUpperCase().contains('INFECTION') || volatileAcidityPpm > 120.0;
    final isLowPh = ph < 4.40;

    final Color statusColor = isGolden
        ? AppColors.cyan
        : (isRisk ? AppColors.red : AppColors.orange);

    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      borderRadius: 24,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(
                isGolden ? Icons.sensors_rounded : Icons.warning_amber_rounded,
                color: statusColor,
                size: 14,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Plant-wide KPIs & Alarms — $vesselTitle',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),

          // Parameter rows
          _buildKpiRow(
            'Yeast Viability',
            '${yeastCount.toStringAsFixed(0)} M/mL',
            yeastNorm,
            isGolden ? AppColors.cyan : (yeastCount >= 250 ? AppColors.orange : AppColors.red),
          ),
          const SizedBox(height: 5),
          _buildKpiRow(
            'Volatile Acidity',
            '${volatileAcidityPpm.toStringAsFixed(1)} ppm',
            vaNorm,
            volatileAcidityPpm <= 65 ? AppColors.cyan : (volatileAcidityPpm <= 120 ? AppColors.orange : AppColors.red),
          ),
          const SizedBox(height: 5),
          _buildKpiRow(
            'Fermenter pH',
            ph.toStringAsFixed(2),
            phNorm,
            (ph >= 4.40 && ph <= 4.80) ? AppColors.cyan : AppColors.orange,
          ),
          const SizedBox(height: 5),
          _buildKpiRow(
            'FE Efficiency',
            '${fermentationEfficiency.toStringAsFixed(1)} %',
            feNorm,
            fermentationEfficiency >= 88.0 ? AppColors.cyan : AppColors.orange,
          ),
          const SizedBox(height: 8),

          // Threshold Alarms Status Badge
          const Text(
            'Active Alarms & Threshold Status',
            style: TextStyle(
              fontSize: 9.5,
              fontWeight: FontWeight.bold,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          if (isGolden)
            _buildAlarmBadge(
              icon: Icons.check_circle_outline_rounded,
              text: '✓ All parameters within optimal Golden tolerance',
              color: AppColors.cyan,
              bg: AppColors.cyan.withValues(alpha: 0.1),
            )
          else if (isLowPh)
            _buildAlarmBadge(
              icon: Icons.warning_amber_rounded,
              text: '⚠️ Low pH Stress (${ph.toStringAsFixed(2)}) — Acidification risk',
              color: AppColors.orange,
              bg: AppColors.orange.withValues(alpha: 0.12),
            )
          else if (volatileAcidityPpm > 65)
            _buildAlarmBadge(
              icon: Icons.warning_amber_rounded,
              text: '⚠️ Elevated Volatile Acidity (${volatileAcidityPpm.toStringAsFixed(1)} ppm)',
              color: AppColors.orange,
              bg: AppColors.orange.withValues(alpha: 0.12),
            )
          else
            _buildAlarmBadge(
              icon: Icons.info_outline_rounded,
              text: 'Standard normal batch operating envelope',
              color: AppColors.textSecondary,
              bg: AppColors.glassOverlay,
            ),
        ],
      ),
    );
  }

  Widget _buildAlarmBadge({
    required IconData icon,
    required String text,
    required Color color,
    required Color bg,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 12),
          const SizedBox(width: 5),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 8.5,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
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
              style: const TextStyle(
                fontSize: 9.5,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: 9.5,
                fontWeight: FontWeight.bold,
                color: barColor,
              ),
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
