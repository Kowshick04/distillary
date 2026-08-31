import 'package:flutter/material.dart';
import '../common/glass_card.dart';
import '../../utils/app_colors.dart';

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
    final hasInfection = widget.volatileAcidityPpm > 1500;
    final Color feasibilityColor = widget.isRecoverable ? AppColors.cyan : AppColors.red;
    final Color feasibilityBg = widget.isRecoverable ? AppColors.cyan.withValues(alpha: 0.12) : AppColors.red.withValues(alpha: 0.12);
    final String feasibilityText = widget.isRecoverable ? 'RECOVERABLE' : 'UNRECOVERABLE';

    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      borderRadius: 24,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          // 1. Header conformed to mockup
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
          const SizedBox(height: 8),

          // Infection Warning Alert Banner
          if (hasInfection) ...[
            AnimatedBuilder(
              animation: _flashAnimation,
              builder: (context, child) {
                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.red.withValues(alpha: _flashAnimation.value),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.red, width: 1.5),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.gpp_bad_rounded, color: AppColors.textPrimary, size: 18),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '🚨 Bacterial contamination detected. Fermentation is suppressed.',
                          style: TextStyle(
                            fontSize: 11,
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
            const SizedBox(height: 12),
          ],

          // 2. Model descriptor pills
          Row(
            children: [
              const Text(
                'STATUS: ',
                style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: AppColors.textMuted),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                decoration: BoxDecoration(
                  color: feasibilityBg,
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Text(
                  feasibilityText,
                  style: TextStyle(fontSize: 7, fontWeight: FontWeight.bold, color: feasibilityColor),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // 3. Feature Importance progress bars (dynamic from real telemetry)
          const Text(
            'FEATURE IMPORTANCE',
            style: TextStyle(
              fontSize: 10,
              letterSpacing: 0.8,
              fontWeight: FontWeight.bold,
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 4),
          Builder(
            builder: (context) {
              final double pitchAlcFactor = (widget.pitchAlcohol / 15.0).clamp(0.0, 1.0);
              final double volatileFactor = (widget.volatileAcidityPpm / 3000.0).clamp(0.0, 1.0);
              final double effFactor = (widget.fermentationEfficiency / 100.0).clamp(0.0, 1.0);
              final double phFactor = widget.ph > 0 ? ((widget.ph - 3.5) / 2.5).clamp(0.0, 1.0) : 0.0;

              return ListView(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildFeatureBar('Pitch Alcohol', pitchAlcFactor, AppColors.cyan),
                  _buildFeatureBar('Volatile Acidity', volatileFactor, AppColors.cyan),
                  _buildFeatureBar('Ferment. Efficiency', effFactor, AppColors.blue),
                  _buildFeatureBar('pH Level', phFactor, AppColors.blue),
                ],
              );
            },
          ),
          ],
        ),
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
                style: const TextStyle(fontSize: 10.5, color: AppColors.textSecondary),
              ),
              Text(
                '${(factor * 100).toStringAsFixed(0)}%',
                style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: barColor),
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
