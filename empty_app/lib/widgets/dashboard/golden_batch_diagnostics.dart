import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';

class GoldenBatchDiagnostics extends StatefulWidget {
  final String title;
  final double levelFactor;
  final double temperature;
  final double ph;
  final double brix;
  final String qualityFlag;
  final double confidence;
  final bool isRecoverable;
  final double volatileAcidityPpm;
  final List<String> suggestions;
  final List<String> rootCauses;
  final double yeastCount;

  const GoldenBatchDiagnostics({
    super.key,
    required this.title,
    required this.levelFactor,
    required this.temperature,
    required this.ph,
    required this.brix,
    required this.qualityFlag,
    required this.confidence,
    required this.isRecoverable,
    required this.volatileAcidityPpm,
    required this.suggestions,
    required this.rootCauses,
    required this.yeastCount,
  });

  @override
  State<GoldenBatchDiagnostics> createState() => _GoldenBatchDiagnosticsState();
}

class _GoldenBatchDiagnosticsState extends State<GoldenBatchDiagnostics>
    with SingleTickerProviderStateMixin {
  late AnimationController _radialController;

  @override
  void initState() {
    super.initState();
    _radialController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..forward();
  }

  @override
  void didUpdateWidget(covariant GoldenBatchDiagnostics oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.confidence != widget.confidence || oldWidget.qualityFlag != widget.qualityFlag) {
      _radialController.reset();
      _radialController.forward();
    }
  }

  @override
  void dispose() {
    _radialController.dispose();
    super.dispose();
  }

  Color _getStatusColor() {
    switch (widget.qualityFlag.toUpperCase()) {
      case 'GOLDEN BATCH':
      case 'GOLDEN':
        return AppColors.cyan; // Teal
      case 'RISK':
        return AppColors.red; // Red
      case 'NORMAL':
      default:
        return AppColors.amber; // Amber
    }
  }

  double _getAlignmentPercentage() {
    final flag = widget.qualityFlag.toUpperCase();
    if (flag.contains('GOLDEN')) {
      return 0.90 + (widget.confidence * 0.08); // 90% - 98%
    } else if (flag.contains('RISK')) {
      return 0.35 + (widget.confidence * 0.20); // 35% - 55%
    } else {
      return 0.65 + (widget.confidence * 0.20); // 65% - 85%
    }
  }

  String _getMetabolicNarrative() {
    final flag = widget.qualityFlag.toUpperCase();
    final vaStr = widget.volatileAcidityPpm.toStringAsFixed(0);
    final phStr = widget.ph.toStringAsFixed(2);

    if (flag.contains('GOLDEN')) {
      return 'The current batch is aligned with the Golden Batch profile. Initial yeast cell density is optimal and bacterial volatile acidity remains negligible.';
    } else if (flag.contains('RISK')) {
      return 'This batch is NOT a Golden Batch. Critical bacterial contamination is detected via elevated volatile acidity ($vaStr ppm), suppressing yeast metabolic activity.';
    } else {
      return 'This batch deviates slightly from the Golden Batch profile. The average pH level ($phStr) is sub-optimal, causing minor osmotic stress and slightly delaying sugar consumption.';
    }
  }

  String _getStatusChipText() {
    final flag = widget.qualityFlag.toUpperCase();
    if (flag.contains('GOLDEN')) {
      return 'GOLDEN PROFILE MATCHED';
    } else if (flag.contains('RISK')) {
      return 'CRITICAL PROFILE MISMATCH';
    } else {
      return 'MINOR PROFILE DEVIATIONS';
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor();
    final alignmentPercent = _getAlignmentPercentage();
    final narrative = _getMetabolicNarrative();
    final statusChipText = _getStatusChipText();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceDeep, // Slate Dark
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: statusColor.withValues(alpha: 0.25),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: statusColor.withValues(alpha: 0.04),
            blurRadius: 12,
            spreadRadius: 2,
          )
        ],
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          // Header Row
          Row(
            children: [
              Icon(
                Icons.psychology_outlined,
                color: statusColor,
                size: 22,
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Golden Batch Diagnostics & Root Cause Analysis',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: statusColor.withValues(alpha: 0.3), width: 0.8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: statusColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      statusChipText,
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Main Layout split: Radial Alignment Dial on Left, Diagnostic text + details on Right
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Radial Dial (Alignment Meter)
              Column(
                children: [
                  const SizedBox(height: 6),
                  AnimatedBuilder(
                    animation: _radialController,
                    builder: (context, child) {
                      final val = _radialController.value * alignmentPercent;
                      return SizedBox(
                        width: 120,
                        height: 120,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Circular track
                            const SizedBox(
                              width: 105,
                              height: 105,
                              child: CircularProgressIndicator(
                                value: 1.0,
                                strokeWidth: 8,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Color(0xFF1E2638), // Deep Track
                                ),
                              ),
                            ),
                            // Progress bar
                            SizedBox(
                              width: 105,
                              height: 105,
                              child: CircularProgressIndicator(
                                value: val,
                                strokeWidth: 8,
                                strokeCap: StrokeCap.round,
                                valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                              ),
                            ),
                            // Text percentage display
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  '${(val * 100).toStringAsFixed(0)}%',
                                  style: const TextStyle(
                                    color: AppColors.textPrimary,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 22,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                                const Text(
                                  'ALIGNMENT',
                                  style: TextStyle(
                                    color: AppColors.textMuted,
                                    fontSize: 8,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.0,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Profile Match Fit',
                    style: TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 24),

              // Narrative and Diagnostic details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'DIAGNOSTIC SUMMARY & CHEMICAL PATHWAY',
                      style: TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      narrative,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 13,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Quick parameter highlights comparison grid
                    Row(
                      children: [
                        _buildQuickMetricCard(
                          title: 'Yeast Count',
                          value: '${widget.yeastCount.toStringAsFixed(0)}M',
                          target: '300M+',
                          isOk: widget.yeastCount >= 300,
                          statusColor: statusColor,
                        ),
                        const SizedBox(width: 12),
                        _buildQuickMetricCard(
                          title: 'Volatile Acidity',
                          value: '${widget.volatileAcidityPpm.toStringAsFixed(0)} ppm',
                          target: '<1500 ppm',
                          isOk: widget.volatileAcidityPpm < 1500,
                          statusColor: statusColor,
                        ),
                        const SizedBox(width: 12),
                        _buildQuickMetricCard(
                          title: 'pH Level',
                          value: widget.ph.toStringAsFixed(2),
                          target: '4.5 - 5.0',
                          isOk: (widget.ph >= 4.5 && widget.ph <= 5.0),
                          statusColor: statusColor,
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
    ),
  );
}

  Widget _buildQuickMetricCard({
    required String title,
    required String value,
    required String target,
    required bool isOk,
    required Color statusColor,
  }) {
    final cardColor = isOk ? AppColors.cyan : (title.contains('Acidity') && !isOk ? AppColors.red : AppColors.amber);
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1F2C),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: cardColor.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  isOk ? Icons.check_circle_rounded : (title.contains('Acidity') && !isOk ? Icons.error_rounded : Icons.warning_rounded),
                  color: cardColor,
                  size: 11,
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 1),
            Text(
              'Target: $target',
              style: const TextStyle(
                color: AppColors.textMuted,
                fontSize: 8.5,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
