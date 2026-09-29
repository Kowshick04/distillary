import 'package:flutter/material.dart';
import '../common/glass_card.dart';
import '../../utils/app_colors.dart';
import '../../utils/responsive_layout.dart';

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
    final bool is12Inch = ResponsiveLayout.is12InchTablet(context);
    final double yeastNorm = (yeastCount / 500.0).clamp(0.05, 1.0);
    final double vaNorm = (volatileAcidityPpm / 150.0).clamp(0.05, 1.0);
    final double phNorm = ph > 0 ? ((ph - 3.5) / 2.0).clamp(0.05, 1.0) : 0.43;

    return GlassCard(
      padding: EdgeInsets.symmetric(
        horizontal: is12Inch ? 16 : 14,
        vertical: is12Inch ? 14 : 10,
      ),
      borderRadius: 24,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final bool hasBoundedHeight = is12Inch && constraints.maxHeight.isFinite && constraints.maxHeight > 220;

          return Column(
            mainAxisSize: hasBoundedHeight ? MainAxisSize.max : MainAxisSize.min,
            mainAxisAlignment: hasBoundedHeight ? MainAxisAlignment.spaceBetween : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Header conformed to mockup layout
              Row(
                children: [
                  Icon(Icons.lock_rounded, color: AppColors.red, size: is12Inch ? 16 : 14),
                  SizedBox(width: is12Inch ? 8 : 6),
                  Text(
                    'Plant-wide KPIs & Alarms',
                    style: TextStyle(
                      fontSize: is12Inch ? 12.5 : 11.5,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              if (!hasBoundedHeight) const SizedBox(height: 6),

              // 2. Linear parameter stats rows matching mockup values with dynamic data
              _buildKpiRow('Yeast Count', '${yeastCount.toStringAsFixed(0)}/0', yeastNorm, AppColors.cyan, isLarge: hasBoundedHeight),
              if (!hasBoundedHeight) const SizedBox(height: 5),
              _buildKpiRow('Volatile Acids', volatileAcidityPpm.toStringAsFixed(1), vaNorm, AppColors.orange, isLarge: hasBoundedHeight),
              if (!hasBoundedHeight) const SizedBox(height: 5),
              _buildKpiRow('pH', ph.toStringAsFixed(2), phNorm, AppColors.red, isLarge: hasBoundedHeight),
              if (!hasBoundedHeight) const SizedBox(height: 8),

              // 3. Flat space-efficient secondary alarms list
              Text(
                'Plant-wide & Alarms',
                style: TextStyle(
                  fontSize: is12Inch ? 10.5 : 9.5,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textSecondary,
                  letterSpacing: is12Inch ? 0.5 : 0.0,
                ),
              ),
              if (!hasBoundedHeight) const SizedBox(height: 5),
              _buildKpiRow('Volatile Acids Threshold', '${volatileAcidityPpm.toStringAsFixed(0)}/0', (vaNorm * 0.8).clamp(0.05, 1.0), AppColors.cyan, isLarge: hasBoundedHeight),
              if (!hasBoundedHeight) const SizedBox(height: 5),
              _buildKpiRow('Buffer Adjustment Factor', (ph + 0.1).toStringAsFixed(2), (phNorm * 1.1).clamp(0.05, 1.0), AppColors.textMuted, isLarge: hasBoundedHeight),

              if (hasBoundedHeight)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                  decoration: BoxDecoration(
                    color: const Color(0x0AFFFFFF),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0x14FFFFFF)),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Fermentation Health Status',
                        style: TextStyle(fontSize: 10, color: AppColors.textMuted, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'OPTIMAL STABILITY',
                        style: TextStyle(fontSize: 10, color: AppColors.cyan, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildKpiRow(String label, String value, double progress, Color barColor, {bool isLarge = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(fontSize: isLarge ? 10.5 : 9.5, color: AppColors.textSecondary, fontWeight: FontWeight.bold),
            ),
            Text(
              value,
              style: TextStyle(fontSize: isLarge ? 10.5 : 9.5, fontWeight: FontWeight.bold, color: barColor),
            ),
          ],
        ),
        SizedBox(height: isLarge ? 5 : 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(isLarge ? 3 : 2),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: isLarge ? 6.0 : 4.0,
            backgroundColor: AppColors.glassOverlay,
            valueColor: AlwaysStoppedAnimation<Color>(barColor),
          ),
        ),
      ],
    );
  }
}
