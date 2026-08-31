import 'package:flutter/material.dart';
import '../common/glass_card.dart';
import '../../models/telemetry_data_model.dart';
import '../../services/golden_batch_service.dart';
import '../../utils/app_colors.dart';

class ComparisonItem {
  final int index;
  final String title;
  final String currentValueStr;
  final String targetValueStr;
  final String deltaStr;
  final bool isWarning;
  final bool isGood;
  final String suggestedAction;

  const ComparisonItem({
    required this.index,
    required this.title,
    required this.currentValueStr,
    required this.targetValueStr,
    required this.deltaStr,
    required this.isWarning,
    required this.isGood,
    required this.suggestedAction,
  });
}

class AiRecommendationsCard extends StatelessWidget {
  final TelemetryDataModel? telemetry;
  final VoidCallback? onViewAll;

  const AiRecommendationsCard({
    super.key,
    this.telemetry,
    this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    final t = telemetry;
    final int minutes = t?.timestampMinute ?? 0;
    
    // Fetch Golden Batch targets for the current elapsed minute
    final golden = GoldenBatchService.getTargetForMinute(minutes);

    // Compute live values and deltas
    final double curEff = t?.fermentationEfficiency ?? 91.8;
    final double curTemp = t?.temperature ?? 32.1;
    final double curPower = t?.plantPowerKw ?? 89.2;
    final double curCooling = t?.coolingWaterFlowLpm ?? 400.0;
    final double curQuality = t?.batchQualityScore ?? 70.0;

    final double deltaEff = curEff - golden.fermentationEfficiency;
    final double deltaTemp = curTemp - golden.temperature;
    final double deltaPower = curPower - golden.plantPowerKw;
    final double deltaCooling = curCooling - golden.coolingWaterFlowLpm;
    final double deltaQuality = curQuality - golden.batchQualityScore;

    // Construct the Comparison Items list with suggested actionable steps
    final List<ComparisonItem> items = [
      ComparisonItem(
        index: 1,
        title: 'Fermentation Efficiency',
        currentValueStr: '${curEff.toStringAsFixed(1)}%',
        targetValueStr: '${golden.fermentationEfficiency.toStringAsFixed(1)}%',
        deltaStr: '${deltaEff >= 0 ? '+' : ''}${deltaEff.toStringAsFixed(1)}%',
        isWarning: deltaEff < -1.5,
        isGood: deltaEff >= 0,
        suggestedAction: "verify yeast nutrient feed rate & agitator speed",
      ),
      ComparisonItem(
        index: 2,
        title: 'Temperature Deviation',
        currentValueStr: '${curTemp.toStringAsFixed(1)}\u00B0C',
        targetValueStr: '${golden.temperature.toStringAsFixed(1)}\u00B0C',
        deltaStr: '${deltaTemp >= 0 ? '+' : ''}${deltaTemp.toStringAsFixed(1)}\u00B0C',
        isWarning: deltaTemp.abs() > 0.8,
        isGood: deltaTemp.abs() <= 0.3,
        suggestedAction: "check cooling valve state & chiller load",
      ),
      ComparisonItem(
        index: 3,
        title: 'Plant Power Load',
        currentValueStr: '${curPower.toStringAsFixed(1)} kW',
        targetValueStr: '${golden.plantPowerKw.toStringAsFixed(1)} kW',
        deltaStr: '${deltaPower >= 0 ? '+' : ''}${deltaPower.toStringAsFixed(1)} kW',
        isWarning: deltaPower > 8.0,
        isGood: deltaPower.abs() <= 3.0,
        suggestedAction: "check agitator motor current draw & load balance",
      ),
      ComparisonItem(
        index: 4,
        title: 'Cooling Water Flow',
        currentValueStr: '${curCooling.toStringAsFixed(0)} LPM',
        targetValueStr: '${golden.coolingWaterFlowLpm.toStringAsFixed(0)} LPM',
        deltaStr: '${deltaCooling >= 0 ? '+' : ''}${deltaCooling.toStringAsFixed(0)} LPM',
        isWarning: deltaCooling < -15.0,
        isGood: deltaCooling.abs() <= 5.0,
        suggestedAction: "flush cooling jacket intake filter",
      ),
      ComparisonItem(
        index: 5,
        title: 'Batch Quality Score',
        currentValueStr: '${curQuality.toStringAsFixed(1)}%',
        targetValueStr: '${golden.batchQualityScore.toStringAsFixed(1)}%',
        deltaStr: '${deltaQuality >= 0 ? '+' : ''}${deltaQuality.toStringAsFixed(1)}%',
        isWarning: deltaQuality < -3.0,
        isGood: deltaQuality >= 0,
        suggestedAction: "adjust temperature profile and pH buffer",
      ),
    ];

    // Compute Overall Match Score
    final double matchScore = (100.0 - 
        (deltaEff.abs() * 2.0 + 
         deltaTemp.abs() * 5.0 + 
         (deltaPower.abs() / golden.plantPowerKw) * 100.0 + 
         (deltaCooling.abs() / golden.coolingWaterFlowLpm) * 100.0 + 
         deltaQuality.abs() * 0.5)
    ).clamp(50.0, 100.0);

    return GlassCard(
      padding: const EdgeInsets.all(18),
      borderRadius: 20,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.workspace_premium_rounded, color: AppColors.orange, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Golden Batch Analysis',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary, // Off-white
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: matchScore > 90.0 
                      ? AppColors.cyan.withOpacity(0.12) // Translucent Teal
                      : (matchScore > 75.0 ? AppColors.orange.withOpacity(0.12) : AppColors.orange.withOpacity(0.12)),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: matchScore > 90.0 
                        ? AppColors.cyan.withOpacity(0.2) 
                        : AppColors.orange.withOpacity(0.2),
                  ),
                ),
                child: Text(
                  'Match: ${matchScore.toStringAsFixed(1)}%',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: matchScore > 90.0 
                        ? AppColors.cyan 
                        : AppColors.orange,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Dynamic Comparison Items List
          Column(
            children: items.map((item) {
              final Color deltaColor = item.isWarning 
                  ? AppColors.orange // Warm Orange (Warning deviation)
                  : (item.isGood ? AppColors.cyan : AppColors.textMuted); // Teal (Good) or Steel Gray (Neutral)
              final Color deltaBg = item.isWarning 
                  ? AppColors.orange.withOpacity(0.12) 
                  : (item.isGood ? AppColors.cyan.withOpacity(0.12) : AppColors.glassOverlay);

              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.glassOverlay, // Very faint frosted highlight
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0x14FFFFFF)), // Specular line
                  boxShadow: const [
                    BoxShadow(color: Color(0x0C000000), blurRadius: 6, offset: Offset(0, 2)),
                  ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Status dot / Icon
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: deltaBg,
                      ),
                      child: Center(
                        child: Icon(
                          item.isWarning 
                              ? Icons.warning_amber_rounded 
                              : (item.isGood ? Icons.check_circle_outline_rounded : Icons.info_outline_rounded),
                          size: 14,
                          color: deltaColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),

                    // Metrics Details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  item.title,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary, // Off-white
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: deltaBg,
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: deltaBg.withValues(alpha: 0.4)),
                                ),
                                child: Text(
                                  item.deltaStr,
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                    color: deltaColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: (() {
                                double parseVal(String s) {
                                  final double? v = double.tryParse(s.replaceAll(RegExp(r'[^0-9.]'), ''));
                                  return v ?? 0.0;
                                }
                                final double curNum = parseVal(item.currentValueStr);
                                final double tarNum = parseVal(item.targetValueStr);
                                return tarNum > 0 ? (curNum / tarNum).clamp(0.0, 1.0) : 0.0;
                              })(),
                              minHeight: 5,
                              backgroundColor: AppColors.textSecondary.withOpacity(0.12), // Light Gray
                              valueColor: AlwaysStoppedAnimation<Color>(deltaColor),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Current: ${item.currentValueStr}',
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textMuted, // Steel Gray
                                ),
                              ),
                              Text(
                                'Target: ${item.targetValueStr}',
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textSecondary, // Light Gray
                                ),
                              ),
                            ],
                          ),
                          if (item.isWarning) ...[
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                              decoration: BoxDecoration(
                                color: AppColors.orange.withOpacity(0.12), // Faint Soft Orange background
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: AppColors.orange.withOpacity(0.2)),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.lightbulb_outline_rounded, size: 12, color: AppColors.orange),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      'Action: ${item.suggestedAction}',
                                      style: const TextStyle(
                                        fontSize: 9.5,
                                        fontStyle: FontStyle.italic,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.orange, // Soft Orange text conformed to brand
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
