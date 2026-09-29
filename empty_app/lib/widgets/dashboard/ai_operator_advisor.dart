import 'package:flutter/material.dart';
import '../common/glass_card.dart';
import '../../utils/app_colors.dart';
import '../../utils/responsive_layout.dart';

class QCEntry {
  final String action;
  final String description;

  const QCEntry({required this.action, required this.description});
}

class AiOperatorAdvisor extends StatefulWidget {
  final bool isRecoverable;
  final double volatileAcidityPpm;
  final double pitchAlcohol;
  final double fermentationEfficiency;
  final double ph;

  const AiOperatorAdvisor({
    super.key,
    required this.isRecoverable,
    required this.volatileAcidityPpm,
    this.pitchAlcohol = 0.0,
    this.fermentationEfficiency = 0.0,
    this.ph = 0.0,
  });

  @override
  State<AiOperatorAdvisor> createState() => _AiOperatorAdvisorState();
}

class _AiOperatorAdvisorState extends State<AiOperatorAdvisor>
    with SingleTickerProviderStateMixin {
  late AnimationController _flashController;
  late Animation<double> _flashAnimation;

  @override
  void initState() {
    super.initState();
    _flashController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
    _flashAnimation = Tween<double>(begin: 0.15, end: 0.85).animate(_flashController);
  }

  @override
  void dispose() {
    _flashController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool is12Inch = ResponsiveLayout.is12InchTablet(context);
    final hasInfection = widget.volatileAcidityPpm > 1500;
    final isOptimal = widget.pitchAlcohol >= 11.5 && widget.ph >= 4.40 && widget.volatileAcidityPpm <= 70.0;
    final Color feasibilityColor = isOptimal
        ? AppColors.cyan
        : (widget.isRecoverable ? AppColors.orange : AppColors.red);
    final Color feasibilityBg = isOptimal
        ? AppColors.cyan.withValues(alpha: 0.15)
        : (widget.isRecoverable ? AppColors.orange.withValues(alpha: 0.15) : AppColors.red.withValues(alpha: 0.15));
    final String feasibilityText = isOptimal
        ? 'OPTIMAL'
        : (widget.isRecoverable ? 'RECOVERABLE' : 'UNRECOVERABLE');

    return GlassCard(
      padding: EdgeInsets.symmetric(
        horizontal: 16,
        vertical: is12Inch ? 14 : 12,
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
              // 1. Header conformed to mockup
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.psychology_rounded, color: AppColors.cyan, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'AI Operator Advisor',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                    decoration: BoxDecoration(
                      color: feasibilityBg,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: feasibilityColor.withOpacity(0.3), width: 0.8),
                    ),
                    child: Text(
                      feasibilityText,
                      style: TextStyle(fontSize: 8.5, fontWeight: FontWeight.bold, color: feasibilityColor),
                    ),
                  ),
                ],
              ),
              if (!hasBoundedHeight) const SizedBox(height: 8),

              // Infection Warning Alert Banner
              if (hasInfection) ...[
                AnimatedBuilder(
                  animation: _flashAnimation,
                  builder: (context, child) {
                    return Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                      decoration: BoxDecoration(
                        color: AppColors.red.withValues(alpha: _flashAnimation.value),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.red, width: 1.2),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.gpp_bad_rounded, color: AppColors.textPrimary, size: 16),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'CRITICAL: Infection threshold breach. High volatile acidity.',
                              style: TextStyle(
                                fontSize: 9.5,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                if (!hasBoundedHeight) const SizedBox(height: 8),
              ],

              // 2. Feature Importance progress bars (dynamic from real telemetry)
              const Text(
                'FEATURE IMPORTANCE',
                style: TextStyle(
                  fontSize: 10,
                  letterSpacing: 0.8,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textMuted,
                ),
              ),
              if (!hasBoundedHeight) const SizedBox(height: 4),
              Builder(
                builder: (context) {
                  final double pitchAlcFactor = (widget.pitchAlcohol / 15.0).clamp(0.0, 1.0);
                  final double volatileFactor = (widget.volatileAcidityPpm / 2500.0).clamp(0.0, 1.0);
                  final double effFactor = (widget.fermentationEfficiency / 100.0).clamp(0.0, 1.0);
                  final double phFactor = widget.ph > 0 ? ((widget.ph - 3.5) / 2.5).clamp(0.0, 1.0) : 0.0;

                  return Column(
                    children: [
                      _buildFeatureBar('Pitch Alcohol', pitchAlcFactor, isOptimal ? AppColors.cyan : AppColors.cyan),
                      _buildFeatureBar('Volatile Acidity', volatileFactor, isOptimal ? AppColors.cyan : AppColors.cyan),
                      _buildFeatureBar('Ferment. Efficiency', effFactor, AppColors.blue),
                      _buildFeatureBar('pH Level', phFactor, AppColors.blue),
                    ],
                  );
                },
              ),

              // 3. Actionable Live Operational Recommendation Card (Fills lower empty space on 12.7" screen)
              if (hasBoundedHeight)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceDeep,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: hasInfection ? AppColors.red.withOpacity(0.5) : AppColors.cyan.withOpacity(0.25),
                      width: 1.0,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            hasInfection ? Icons.warning_amber_rounded : Icons.tips_and_updates_rounded,
                            color: hasInfection ? AppColors.red : AppColors.cyan,
                            size: 15,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            hasInfection ? 'PRIORITY INTERVENTION REQUIRED' : 'ACTIONABLE PROCESS ADVICE',
                            style: TextStyle(
                              fontSize: 9.5,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                              color: hasInfection ? AppColors.red : AppColors.cyan,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Text(
                        hasInfection
                            ? 'Volatile acidity is elevated (${widget.volatileAcidityPpm.toStringAsFixed(0)} ppm). Check fermenter for bacterial contamination and prepare acid addition.'
                            : (isOptimal
                                ? 'Batch is tracking optimal Golden profile (Alcohol ${widget.pitchAlcohol.toStringAsFixed(1)}%, pH ${widget.ph.toStringAsFixed(2)}). Maintain current cooling flow and yeast feeding rate.'
                                : 'Adjust cooling water flow to stabilize temperature and maintain alcohol conversion efficiency.'),
                        style: const TextStyle(
                          fontSize: 9.5,
                          color: AppColors.textPrimary,
                          height: 1.35,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            isOptimal ? 'SYSTEM: STABLE' : 'ADVISOR: ACTIVE',
                            style: const TextStyle(fontSize: 8.0, color: AppColors.textMuted, fontWeight: FontWeight.bold),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                            decoration: BoxDecoration(
                              color: (isOptimal ? AppColors.cyan : AppColors.orange).withOpacity(0.15),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: (isOptimal ? AppColors.cyan : AppColors.orange).withOpacity(0.4),
                                width: 0.8,
                              ),
                            ),
                            child: Text(
                              isOptimal ? 'BATCH VERIFIED' : 'GUIDANCE ACTIVE',
                              style: TextStyle(
                                fontSize: 8.0,
                                fontWeight: FontWeight.bold,
                                color: isOptimal ? AppColors.cyan : AppColors.orange,
                              ),
                            ),
                          ),
                        ],
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

  Widget _buildFeatureBar(String name, double factor, Color barColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                name,
                style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
              ),
              Text(
                '${(factor * 100).toStringAsFixed(0)}%',
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 2),
          ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value: factor,
              minHeight: 3.5,
              backgroundColor: AppColors.glassOverlay,
              valueColor: AlwaysStoppedAnimation<Color>(barColor),
            ),
          ),
        ],
      ),
    );
  }
}
