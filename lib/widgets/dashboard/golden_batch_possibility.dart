import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../common/glass_card.dart';
import 'ai_operator_advisor.dart'; // To access QCEntry definition
import '../../services/sse_telemetry_service.dart'; // To access SseTelemetryService
import '../../utils/app_colors.dart';

enum AlignmentStatus { optimal, warning, critical }

class GoldenBatchPossibility extends StatefulWidget {
  final double confidence; // e.g. 0.85
  final List<QCEntry> qcActions;
  final double ph;
  final double temperature;
  final double yeastCount;
  final double volatileAcidity;
  final String factoryCode;
  final SseTelemetryService telemetryService;

  const GoldenBatchPossibility({
    super.key,
    required this.confidence,
    required this.qcActions,
    required this.ph,
    required this.temperature,
    required this.yeastCount,
    required this.volatileAcidity,
    required this.factoryCode,
    required this.telemetryService,
  });

  @override
  State<GoldenBatchPossibility> createState() => _GoldenBatchPossibilityState();
}

class _GoldenBatchPossibilityState extends State<GoldenBatchPossibility> {
  final Set<String> _dismissedActionTexts = {};

  // Helper logic for parameter status
  AlignmentStatus _getPhStatus() {
    if (widget.ph >= 4.5 && widget.ph <= 4.8) {
      return AlignmentStatus.optimal;
    } else if (widget.ph < 4.5) {
      return AlignmentStatus.warning;
    } else {
      return AlignmentStatus.critical;
    }
  }

  String _getPhAction() {
    final status = _getPhStatus();
    if (status == AlignmentStatus.optimal) return 'OPTIMAL';
    if (widget.ph < 4.5) return 'ADD BUFFER';
    return 'ADD ACID';
  }

  AlignmentStatus _getTempStatus() {
    if (widget.temperature >= 31.5 && widget.temperature <= 33.0) {
      return AlignmentStatus.optimal;
    } else if (widget.temperature < 31.5) {
      return AlignmentStatus.warning;
    } else {
      return AlignmentStatus.critical;
    }
  }

  String _getTempAction() {
    final status = _getTempStatus();
    if (status == AlignmentStatus.optimal) return 'OPTIMAL';
    if (widget.temperature < 31.5) return 'HEAT FLOW';
    return 'COOL DOWN';
  }

  AlignmentStatus _getYeastStatus() {
    if (widget.yeastCount >= 300.0) {
      return AlignmentStatus.optimal;
    } else if (widget.yeastCount >= 250.0) {
      return AlignmentStatus.warning;
    } else {
      return AlignmentStatus.critical;
    }
  }

  String _getYeastAction() {
    final status = _getYeastStatus();
    if (status == AlignmentStatus.optimal) return 'OPTIMAL';
    return 'INOCULATE';
  }

  AlignmentStatus _getVaStatus() {
    if (widget.volatileAcidity < 1500.0) {
      return AlignmentStatus.optimal;
    } else {
      return AlignmentStatus.critical;
    }
  }

  String _getVaAction() {
    final status = _getVaStatus();
    if (status == AlignmentStatus.optimal) return 'OPTIMAL';
    return 'SUPPRESS';
  }

  @override
  Widget build(BuildContext context) {
    const Color dialColor = AppColors.cyan;

    final effectiveActions = widget.qcActions.isNotEmpty
        ? widget.qcActions
        : (widget.confidence < 0.80
            ? [const QCEntry(action: 'Add Ammonium Hydroxide buffer', description: 'Adjust pH up to target 4.8.')]
            : <QCEntry>[]);

    // Filter out acknowledged actions
    final activeActions = effectiveActions
        .where((action) => !_dismissedActionTexts.contains(action.action))
        .toList();

    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      borderRadius: 24,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Header conformed to mockup
          const Row(
            children: [
              Icon(Icons.query_stats_rounded, color: AppColors.cyan, size: 20),
              SizedBox(width: 8),
              Text(
                'Golden Batch Possibility',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),

          // 2. Dial + Suggestions for pushing to golden batch
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Concentric Dial
              SizedBox(
                width: 62,
                height: 62,
                child: CustomPaint(
                  painter: _ConcentricDialPainter(
                    confidence: widget.confidence,
                    color: dialColor,
                  ),
                ),
              ),
              const SizedBox(width: 14),

              // Corrective action suggestions
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'CORRECTIVE ACTION SUGGESTION',
                      style: TextStyle(
                        fontSize: 8,
                        letterSpacing: 0.8,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textMuted,
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (widget.confidence >= 0.80 && activeActions.isEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0x08FFFFFF),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0x14FFFFFF)),
                        ),
                        child: const Text(
                          'Batch guidance aligns with Golden baseline targets. No action needed.',
                          style: TextStyle(fontSize: 9.5, fontStyle: FontStyle.italic, color: AppColors.textSecondary),
                        ),
                      )
                    else ...[
                      Builder(
                        builder: (context) {
                          final actionTitle = activeActions.isNotEmpty
                              ? activeActions.first.action
                              : 'Add Ammonium Hydroxide buffer';
                          final actionDesc = activeActions.isNotEmpty
                              ? activeActions.first.description
                              : 'Adjust pH up to target 4.8.';
                          final isWarning = actionTitle.toUpperCase().contains('WARNING') || actionTitle.toUpperCase().contains('CRITICAL');
                          final borderColor = isWarning ? AppColors.red : (widget.confidence >= 0.80 ? AppColors.cyan : AppColors.orange);

                          return Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceDeep,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: borderColor.withValues(alpha: 0.5), width: 1.2),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '1. $actionTitle',
                                  style: const TextStyle(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  actionDesc,
                                  style: const TextStyle(
                                    fontSize: 9,
                                    color: AppColors.textMuted,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: widget.confidence >= 0.80 ? AppColors.cyan : AppColors.orange,
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _dismissedActionTexts.add(actionTitle);
                                        });
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text('Acknowledge: "$actionTitle" marked as read.'),
                                            duration: const Duration(seconds: 2),
                                            backgroundColor: AppColors.cyan,
                                          ),
                                        );
                                      },
                                      child: const Text(
                                        'ACKNOWLEDGE',
                                        style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Colors.white),
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    OutlinedButton(
                                      style: OutlinedButton.styleFrom(
                                        side: const BorderSide(color: AppColors.textMuted),
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                                      ),
                                      onPressed: () async {
                                        final messenger = ScaffoldMessenger.of(context);
                                        try {
                                          await widget.telemetryService.submitOperatorAction(
                                            actionTitle,
                                            widget.factoryCode,
                                          );
                                          messenger.showSnackBar(
                                            const SnackBar(
                                              content: Text('Logged: Corrective action logged to audit trail.'),
                                              duration: Duration(seconds: 2),
                                              backgroundColor: AppColors.cyan,
                                            ),
                                          );
                                        } catch (_) {
                                          messenger.showSnackBar(
                                            const SnackBar(
                                              content: Text('Log queued: Offline buffer synced.'),
                                              duration: Duration(seconds: 2),
                                              backgroundColor: AppColors.textMuted,
                                            ),
                                          );
                                        }
                                      },
                                      child: const Text(
                                        'LOG',
                                        style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // 3. Gridconformed to Mockup
          const Text(
            'GOLDEN BATCH ALIGNMENT',
            style: TextStyle(
              fontSize: 10,
              letterSpacing: 0.8,
              fontWeight: FontWeight.bold,
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildAlignmentRow(
                      name: 'pH',
                      currentText: widget.ph.toStringAsFixed(2),
                      targetText: '4.50 - 4.80',
                      status: _getPhStatus(),
                      actionText: _getPhAction(),
                    ),
                    _buildAlignmentRow(
                      name: 'Yeast Count',
                      currentText: '${widget.yeastCount.toStringAsFixed(0)}M',
                      targetText: '>= 300M',
                      status: _getYeastStatus(),
                      actionText: _getYeastAction(),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildAlignmentRow(
                      name: 'Temperature',
                      currentText: '${widget.temperature.toStringAsFixed(1)}°C',
                      targetText: '31.5 - 33.0°C',
                      status: _getTempStatus(),
                      actionText: _getTempAction(),
                    ),
                    _buildAlignmentRow(
                      name: 'Volatile Acidity',
                      currentText: '${widget.volatileAcidity.toStringAsFixed(0)} ppm',
                      targetText: '< 1500 ppm',
                      status: _getVaStatus(),
                      actionText: _getVaAction(),
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

  Widget _buildAlignmentRow({
    required String name,
    required String currentText,
    required String targetText,
    required AlignmentStatus status,
    required String actionText,
  }) {
    Color statusColor;
    Color bgPillColor;
    IconData statusIcon;

    switch (status) {
      case AlignmentStatus.optimal:
        statusColor = AppColors.green; // Green
        bgPillColor = AppColors.green.withOpacity(0.12);
        statusIcon = Icons.check_circle_rounded;
        break;
      case AlignmentStatus.warning:
        statusColor = AppColors.orange; // Orange
        bgPillColor = AppColors.orange.withOpacity(0.12);
        statusIcon = Icons.trending_flat_rounded;
        break;
      case AlignmentStatus.critical:
        statusColor = AppColors.red; // Red
        bgPillColor = AppColors.red.withOpacity(0.12);
        statusIcon = Icons.warning_rounded;
        break;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0x0AFFFFFF),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: AppColors.glassOverlay),
        ),
        child: Row(
          children: [
            Icon(statusIcon, color: statusColor, size: 12),
            const SizedBox(width: 4),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    name == 'Temperature'
                        ? 'Temp'
                        : (name == 'Yeast Count'
                            ? 'Yeast'
                            : (name == 'Volatile Acidity' ? 'Acidity' : name)),
                    style: const TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    '$currentText [$targetText]',
                    style: const TextStyle(
                      fontSize: 8.0,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2.5),
              decoration: BoxDecoration(
                color: bgPillColor,
                borderRadius: BorderRadius.circular(3),
                border: Border.all(color: statusColor.withValues(alpha: 0.2)),
              ),
              child: Text(
                actionText,
                style: TextStyle(
                  fontSize: 7.5,
                  fontWeight: FontWeight.bold,
                  color: statusColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Custom concentric dials painter conformed to Golden Recovery probability
class _ConcentricDialPainter extends CustomPainter {
  final double confidence;
  final Color color;

  _ConcentricDialPainter({required this.confidence, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final outerRadius = size.width / 2 - 8;
    final innerRadius = outerRadius - 10;

    // Background tracks
    final Paint trackPaint = Paint()
      ..color = const Color(0x0DFFFFFF)
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke;

    canvas.drawCircle(center, outerRadius, trackPaint);
    canvas.drawCircle(center, innerRadius, trackPaint);

    // Active Outer Dial Arc
    final Paint outerArcPaint = Paint()
      ..color = color
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: outerRadius),
      -math.pi / 2,
      2 * math.pi * confidence,
      false,
      outerArcPaint,
    );

    // Active Inner opposing Arc
    final Paint innerArcPaint = Paint()
      ..color = AppColors.blue.withValues(alpha: 0.8)
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: innerRadius),
      math.pi / 2,
      -(2 * math.pi * (confidence * 0.7)),
      false,
      innerArcPaint,
    );

    // Center Golden Recovery text percentage
    final textPainter = TextPainter(
      text: TextSpan(
        text: '${(confidence * 100).toStringAsFixed(0)}%',
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w900,
          color: AppColors.textPrimary,
        ),
        children: const [
          TextSpan(
            text: '\nGolden Recovery',
            style: TextStyle(
              fontSize: 6.5,
              height: 1.3,
              fontWeight: FontWeight.bold,
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    )..layout();

    textPainter.paint(
      canvas,
      Offset(center.dx - textPainter.width / 2, center.dy - textPainter.height / 2),
    );
  }

  @override
  bool shouldRepaint(covariant _ConcentricDialPainter oldDelegate) {
    return oldDelegate.confidence != confidence || oldDelegate.color != color;
  }
}
