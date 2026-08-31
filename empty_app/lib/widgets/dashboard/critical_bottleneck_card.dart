import 'package:flutter/material.dart';
import '../common/glass_card.dart';
import '../../models/telemetry_data_model.dart';
import '../../utils/app_colors.dart';

class CriticalBottleneckCard extends StatelessWidget {
  final TelemetryDataModel? telemetry;

  const CriticalBottleneckCard({super.key, this.telemetry});

  @override
  Widget build(BuildContext context) {
    final t = telemetry;

    // Live values — use real telemetry if temperature is elevated
    final temp = t?.temperature ?? 35.8;
    final fermenterNum = t?.fermenter ?? 103;
    final isHighTemp = temp > 34.0;
    final riskLevel = temp > 36.0 ? 'Critical' : (temp > 34.0 ? 'High' : 'Normal');
    final riskColor = temp > 34.0
        ? AppColors.orange // Warm Orange (Warning/Critical)
        : AppColors.cyan; // Teal (Normal)
    final riskBgColor = temp > 34.0
        ? AppColors.orange.withValues(alpha: 0.12)
        : AppColors.cyan.withValues(alpha: 0.12);
    final statusLabel = isHighTemp ? 'High Temperature' : 'Temperature Normal';
    final impactLabel = isHighTemp ? 'Delayed Fermentation' : 'On Schedule';
    final progressValue = ((temp - 30.0) / 10.0).clamp(0.0, 1.0);
    final estLoss = isHighTemp ? '${((temp - 34.0) * 0.3).toStringAsFixed(1)} KL' : '0.0 KL';
    final estDelay = isHighTemp
        ? '${((temp - 34.0) * 1.5).toStringAsFixed(0)} Hours'
        : 'None';

    return GlassCard(
      padding: const EdgeInsets.all(18),
      borderRadius: 20,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    color: riskColor,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Critical Fermenter Alert',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary, // Off-white
                    ),
                  ),
                ],
              ),
              const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted, size: 20),
            ],
          ),
          const SizedBox(height: 14),

          Row(
            children: [
              // Large Circular Indicator
              SizedBox(
                width: 72,
                height: 72,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CircularProgressIndicator(
                      value: progressValue,
                      strokeWidth: 8,
                      backgroundColor: const Color(0x14FFFFFF), // Frosted background ring
                      valueColor: AlwaysStoppedAnimation<Color>(riskColor),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'F-$fermenterNum',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary, // Off-white
                          ),
                        ),
                        Text(
                          '${temp.toStringAsFixed(1)}\u00B0C',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: riskColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),

              // Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          statusLabel,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: riskColor,
                          ),
                        ),
                        Container(
                          padding:
                              const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: riskBgColor,
                            borderRadius:
                                const BorderRadius.all(Radius.circular(6)),
                          ),
                          child: Text(
                            'Risk: $riskLevel',
                            style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: riskColor),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Impact: $impactLabel',
                      style:
                          const TextStyle(fontSize: 11, color: AppColors.textSecondary), // Light Gray
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0x08FFFFFF), // Translucent card background
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Est. Loss',
                                    style: TextStyle(
                                        fontSize: 9, color: AppColors.textMuted)),
                                Text(estLoss,
                                    style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.textPrimary)),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0x08FFFFFF), // Translucent card background
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Est. Delay',
                                    style: TextStyle(
                                        fontSize: 9, color: AppColors.textMuted)),
                                Text(estDelay,
                                    style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.textPrimary)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
