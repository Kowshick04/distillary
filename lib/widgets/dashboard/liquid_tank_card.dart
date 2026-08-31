import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';

class LiquidTankCard extends StatefulWidget {
  final String title;
  final double levelFactor; // Value between 0.0 and 1.0
  final String stateText;
  final double temperature;
  final double ph;
  final double brix;
  final String qualityFlag;
  final bool isSelected;
  final bool isEmpty;
  final VoidCallback onTap;
  final double yeastCount;
  final double volatileAcidity;
  final String qcAction;

  const LiquidTankCard({
    super.key,
    required this.title,
    required this.levelFactor,
    required this.stateText,
    required this.temperature,
    required this.ph,
    required this.brix,
    required this.qualityFlag,
    required this.isSelected,
    this.isEmpty = false,
    required this.onTap,
    this.yeastCount = 0.0,
    this.volatileAcidity = 0.0,
    this.qcAction = '',
  });

  @override
  State<LiquidTankCard> createState() => _LiquidTankCardState();
}

class _LiquidTankCardState extends State<LiquidTankCard> {
  Color _getThemeColor() {
    if (widget.isEmpty) {
      return AppColors.divider; // Dull steel gray for Standby
    }
    switch (widget.qualityFlag.toUpperCase()) {
      case 'GOLDEN BATCH':
      case 'GOLDEN':
        return AppColors.amber; // Premium Gold
      case 'RISK':
      case 'LOW ALCOHOL':
        return AppColors.orange; // Orange / Warm Accent
      case 'NORMAL':
        return AppColors.normalFermenting; // Rich Steel Blue
      default:
        return AppColors.textSecondary; // Steel Gray / Offline
    }
  }

  Color _getBadgeTextColor() {
    if (widget.isEmpty) return AppColors.textSecondary;
    final flag = widget.qualityFlag.toUpperCase();
    if (flag == 'GOLDEN BATCH' || flag == 'GOLDEN') {
      return AppColors.amber; // Gold
    } else if (flag == 'RISK' || flag == 'LOW ALCOHOL') {
      return AppColors.orange; // Orange
    } else if (flag == 'NORMAL') {
      return AppColors.normalFermenting; // Rich Steel Blue
    }
    return AppColors.textSecondary;
  }

  Color _getBadgeBgColor() {
    return _getBadgeTextColor().withValues(alpha: 0.15);
  }

  Color _getBadgeBorderColor() {
    return _getBadgeTextColor().withValues(alpha: 0.35);
  }

  String _getBadgeLabel() {
    final flag = widget.qualityFlag.toUpperCase();
    if (flag == 'GOLDEN BATCH' || flag == 'GOLDEN') return 'GOLDEN';
    return flag;
  }

  @override
  Widget build(BuildContext context) {
    final themeColor = _getThemeColor();
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.surfaceDeep, // Slate Dark conformed
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: widget.isSelected ? themeColor : themeColor.withValues(alpha: 0.2),
            width: widget.isSelected ? 1.5 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: widget.isSelected
                  ? themeColor.withValues(alpha: 0.25)
                  : themeColor.withValues(alpha: 0.04),
              blurRadius: widget.isSelected ? 12 : 6,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header: Title and Status Badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: themeColor,
                          boxShadow: [
                            BoxShadow(
                              color: themeColor.withValues(alpha: 0.8),
                              blurRadius: 6,
                              spreadRadius: 1.5,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          widget.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.textPrimary, // Off-white
                            fontWeight: FontWeight.bold,
                            fontSize: 13.5,
                          ),
                        ),
                      ),
                      if (!widget.isEmpty && widget.qualityFlag.isNotEmpty) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1.5),
                          decoration: BoxDecoration(
                            color: _getBadgeBgColor(),
                            borderRadius: BorderRadius.circular(5),
                            border: Border.all(color: _getBadgeBorderColor(), width: 0.8),
                          ),
                          child: Text(
                            _getBadgeLabel(),
                            style: TextStyle(
                              color: _getBadgeTextColor(),
                              fontSize: 8.5,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                  decoration: BoxDecoration(
                    color: themeColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    widget.stateText.toUpperCase(),
                    style: TextStyle(
                      color: themeColor,
                      fontSize: 9.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Tank Visual and Metrics Side Panel
            LayoutBuilder(
              builder: (context, cardConstraints) {
                final double vesselWidth = (cardConstraints.maxWidth * 0.45).clamp(40.0, 85.0);
                final double vesselHeight = vesselWidth * (130 / 90);
                return Row(
                  children: [
                    // Glowing Fermenter Vessel Visual conformed to exact custom widget
                    GlowingFermenterVessel(
                      fillPercent: widget.isEmpty ? 0.0 : widget.levelFactor,
                      themeColor: themeColor,
                      width: vesselWidth,
                      height: vesselHeight,
                      stateText: widget.stateText,
                      temperature: widget.temperature,
                      brix: widget.brix,
                    ),
                    SizedBox(width: cardConstraints.maxWidth > 150 ? 8 : 4),

                    // Metrics List conformed to design layout (Two columns)
                    Expanded(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _buildMetricRow('Temp.', widget.isEmpty ? '-\u00B0C' : '${widget.temperature.toStringAsFixed(1)}\u00B0C'),
                                const SizedBox(height: 3),
                                _buildMetricRow('pH', widget.isEmpty ? '-' : widget.ph.toStringAsFixed(2)),
                                const SizedBox(height: 3),
                                _buildMetricRow('Brix', widget.isEmpty ? '0.0%' : '${widget.brix.toStringAsFixed(1)}%'),
                              ],
                            ),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _buildMetricRow('Yeast', widget.isEmpty ? '-' : '${widget.yeastCount.toStringAsFixed(0)}M'),
                                const SizedBox(height: 3),
                                _buildMetricRow('VA', widget.isEmpty ? '-' : '${widget.volatileAcidity.toStringAsFixed(0)}p'),
                                const SizedBox(height: 3),
                                _buildMetricRow(
                                  'AI Predict',
                                  widget.isEmpty ? '-' : (widget.qualityFlag.toUpperCase() == 'GOLDEN BATCH' ? 'GOLDEN' : widget.qualityFlag.toUpperCase()),
                                  valueColor: themeColor,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
            if (!widget.isEmpty) ...[
              const SizedBox(height: 6),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(
                  color: widget.qcAction.isNotEmpty && widget.qcAction != 'Maintain current parameters'
                      ? AppColors.amber.withOpacity(0.12)
                      : AppColors.cyan.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: widget.qcAction.isNotEmpty && widget.qcAction != 'Maintain current parameters'
                        ? AppColors.amber.withOpacity(0.3)
                        : AppColors.cyan.withOpacity(0.3),
                    width: 0.8,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      widget.qcAction.isNotEmpty && widget.qcAction != 'Maintain current parameters'
                          ? Icons.warning_amber_rounded
                          : Icons.check_circle_outline_rounded,
                      size: 10,
                      color: widget.qcAction.isNotEmpty && widget.qcAction != 'Maintain current parameters'
                          ? AppColors.amber
                          : AppColors.cyan,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        widget.qcAction.isNotEmpty ? widget.qcAction : 'Profile Optimal',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 9.0,
                          fontWeight: FontWeight.bold,
                          color: widget.qcAction.isNotEmpty && widget.qcAction != 'Maintain current parameters'
                              ? AppColors.amber
                              : AppColors.cyan,
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
    );
  }

  Widget _buildMetricRow(String label, String value, {Color? valueColor}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: AppColors.textMuted, // Steel Gray
            fontSize: 10.0,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: valueColor ?? AppColors.textPrimary, // Off-White
            fontWeight: FontWeight.bold,
            fontSize: 12.5,
          ),
        ),
      ],
    );
  }
}

/// The glowing fermenter vessel widget displaying the high-tech cutaway vector design
class GlowingFermenterVessel extends StatefulWidget {
  final double fillPercent; // Value between 0.0 and 1.0
  final Color themeColor; // Glow color (e.g., Emerald, Cyan, Gold, Silver)
  final double width;
  final double height;
  final String stateText;
  final double temperature;
  final double brix;

  const GlowingFermenterVessel({
    super.key,
    this.fillPercent = 0.70,
    this.themeColor = AppColors.green,
    this.width = 110,
    this.height = 160,
    this.stateText = 'IDLE',
    this.temperature = 32.0,
    this.brix = 12.0,
  });

  @override
  State<GlowingFermenterVessel> createState() => _GlowingFermenterVesselState();
}

class _GlowingFermenterVesselState extends State<GlowingFermenterVessel>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(); // Continuous wave, bubble rising, and impeller rotation
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // CustomPaint rendering the entire steel bioreactor vessel structure + animations
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return CustomPaint(
                  painter: BioreactorVesselPainter(
                    progress: _controller.value,
                    fillPercent: widget.fillPercent,
                    glowColor: widget.themeColor,
                    stateText: widget.stateText,
                    temperature: widget.temperature,
                    brix: widget.brix,
                  ),
                );
              },
            ),
          ),
          // Digital volume tag
          Positioned(
            bottom: 12,
            right: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1.5),
              decoration: BoxDecoration(
                color: AppColors.surfaceDeep.withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: widget.themeColor.withValues(alpha: 0.3), width: 0.8),
              ),
              child: Text(
                "${(widget.fillPercent * 100).toStringAsFixed(0)}% VOL",
                style: TextStyle(
                  color: widget.themeColor,
                  fontSize: 7,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Custom painter rendering the stainless steel casing, pressure gauge, pipe lines, and rotating impeller
class BioreactorVesselPainter extends CustomPainter {
  final double progress;
  final double fillPercent;
  final Color glowColor;
  final String stateText;
  final double temperature;
  final double brix;

  BioreactorVesselPainter({
    required this.progress,
    required this.fillPercent,
    required this.glowColor,
    required this.stateText,
    required this.temperature,
    required this.brix,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;

    // Impeller speed and wave progress linked to states
    double speedMultiplier = 1.0;
    final state = stateText.toUpperCase();
    if (state == 'STANDBY' || state == 'IDLE') {
      speedMultiplier = 0.0;
    } else if (state.contains('COOLING') || state.contains('HOLDING')) {
      speedMultiplier = 0.3;
    } else if (state.contains('FERMENTING') || state.contains('ACTIVE')) {
      speedMultiplier = 2.0;
    }

    final double waveProgress = progress * (speedMultiplier > 0 ? speedMultiplier : 0.1);
    final double impellerAngle = progress * 2 * math.pi * speedMultiplier;

    // --- 1. DRAW PIPING & LEGS UNDERNEATH ---
    final Paint metalStemPaint = Paint()
      ..color = const Color(0xFF78909C)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    // Top Inlet Pipe Stem
    canvas.drawLine(Offset(w / 2, 0), Offset(w / 2, h * 0.16), metalStemPaint);

    // Bottom Outlet Pipe Stem
    canvas.drawLine(Offset(w / 2, h * 0.80), Offset(w / 2, h), metalStemPaint);

    // Structural Legs (Left & Right legs with footings)
    final Paint legPaint = Paint()
      ..color = const Color(0xFF455A64)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0
      ..strokeCap = StrokeCap.square;

    // Left leg
    canvas.drawLine(Offset(w * 0.24, h * 0.74), Offset(w * 0.16, h * 0.88), legPaint);
    canvas.drawLine(Offset(w * 0.12, h * 0.88), Offset(w * 0.20, h * 0.88), legPaint..strokeWidth = 2.0);

    // Right leg
    canvas.drawLine(Offset(w * 0.76, h * 0.74), Offset(w * 0.84, h * 0.88), legPaint..strokeWidth = 4.0);
    canvas.drawLine(Offset(w * 0.80, h * 0.88), Offset(w * 0.88, h * 0.88), legPaint..strokeWidth = 2.0);

    // --- 2. TANK OUTER STEEL CASING ---
    final Path casingPath = Path();
    casingPath.moveTo(w / 2, h * 0.80);
    casingPath.lineTo(w * 0.14, h * 0.72);
    casingPath.lineTo(w * 0.14, h * 0.22);
    casingPath.cubicTo(
      w * 0.14, h * 0.08,
      w * 0.86, h * 0.08,
      w * 0.86, h * 0.22,
    );
    casingPath.lineTo(w * 0.86, h * 0.72);
    casingPath.close();

    // Fill Casing with Steel Metallic Gradient
    final Paint casingFillPaint = Paint()
      ..shader = const LinearGradient(
        colors: [
          Color(0xFF2C3E50),
          Color(0xFF202C39),
          Color(0xFF151D26),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromLTWH(0, 0, w, h));
    canvas.drawPath(casingPath, casingFillPaint);

    // Stroke Casing with Metallic Silver Outline
    final Paint casingOutlinePaint = Paint()
      ..color = const Color(0xFF90A4AE)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6;
    canvas.drawPath(casingPath, casingOutlinePaint);

    // Cladding ring bands
    canvas.drawLine(Offset(w * 0.14, h * 0.32), Offset(w * 0.86, h * 0.32), casingOutlinePaint..strokeWidth = 1.0);
    canvas.drawLine(Offset(w * 0.14, h * 0.62), Offset(w * 0.86, h * 0.62), casingOutlinePaint);

    // Gas Release Valves on dome cap
    final Paint valvePaint = Paint()
      ..color = const Color(0xFF5A6F7C)
      ..style = PaintingStyle.fill;
    canvas.drawRect(Rect.fromLTWH(w / 2 - 4, h * 0.07, 8, 8), valvePaint);
    canvas.drawRect(Rect.fromLTWH(w / 2 - 6, h * 0.05, 12, 2.5), valvePaint..color = const Color(0xFF37474F));

    // --- 3. ANALOG PRESSURE GAUGE ---
    final Offset gaugeCenter = Offset(w * 0.76, h * 0.18);
    canvas.drawCircle(gaugeCenter, 5.0, Paint()..color = Colors.white..style = PaintingStyle.fill);
    canvas.drawCircle(gaugeCenter, 5.0, Paint()..color = const Color(0xFF37474F)..style = PaintingStyle.stroke..strokeWidth = 1.0);

    // Pressure fluctuates dynamically with temp and brix
    final double pressureRatio = ((temperature - 30.0) / 6.0 + (brix / 15.0) * 0.2).clamp(0.1, 0.9);
    final double gaugeAngle = -math.pi / 4 + pressureRatio * math.pi / 2 + 0.04 * math.sin(progress * 2 * math.pi);
    final Offset needleEnd = Offset(
      gaugeCenter.dx + 3.5 * math.cos(gaugeAngle),
      gaugeCenter.dy + 3.5 * math.sin(gaugeAngle),
    );
    canvas.drawLine(gaugeCenter, needleEnd, Paint()..color = AppColors.red..strokeWidth = 1.0);

    // --- 4. GLASS SIGHT WINDOW (CUTAWAY VIEW) ---
    final Rect sightRect = Rect.fromLTRB(w * 0.20, h * 0.17, w * 0.80, h * 0.71);
    final RRect sightRRect = RRect.fromRectAndRadius(sightRect, const Radius.circular(6));

    // Draw Sight Window backing
    canvas.drawRRect(sightRRect, Paint()..color = AppColors.surfaceDeep);

    // Draw cooling coils behind the glass
    final Paint coilPaint = Paint()
      ..color = AppColors.blue.withValues(alpha: 0.12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    for (double cy = sightRect.top + 8; cy < sightRect.bottom; cy += 12) {
      canvas.drawLine(Offset(sightRect.left - 2, cy), Offset(sightRect.right + 2, cy + 4), coilPaint);
    }

    canvas.save();
    canvas.clipRRect(sightRRect);

    // --- 5. DUAL LAYER FLUID WAVE ---
    if (fillPercent > 0) {
      final double liquidTop = sightRect.bottom - (sightRect.height * fillPercent);

      // Wave Layer 1 (Background Wave)
      final Path liquidPath1 = Path();
      liquidPath1.moveTo(sightRect.left - 5, liquidTop);
      for (double x = sightRect.left - 5; x <= sightRect.right + 5; x++) {
        double y = liquidTop +
            math.sin(((x - sightRect.left) / sightRect.width * 2 * math.pi) +
                    (waveProgress * 2 * math.pi) +
                    math.pi / 2) *
                2.5;
        liquidPath1.lineTo(x, y);
      }
      liquidPath1.lineTo(sightRect.right + 5, sightRect.bottom + 10);
      liquidPath1.lineTo(sightRect.left - 5, sightRect.bottom + 10);
      liquidPath1.close();
      canvas.drawPath(
        liquidPath1,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              glowColor.withValues(alpha: glowColor == AppColors.amber ? 0.45 : 0.22),
              glowColor.withValues(alpha: glowColor == AppColors.amber ? 0.30 : 0.12),
              glowColor.withValues(alpha: glowColor == AppColors.amber ? 0.12 : 0.04),
            ],
          ).createShader(sightRect),
      );

      // Wave Layer 2 (Foreground Wave)
      final Path liquidPath2 = Path();
      liquidPath2.moveTo(sightRect.left - 5, liquidTop);
      for (double x = sightRect.left - 5; x <= sightRect.right + 5; x++) {
        double y = liquidTop +
            math.sin(((x - sightRect.left) / sightRect.width * 2 * math.pi) +
                    (waveProgress * 2 * math.pi)) *
                2.0;
        liquidPath2.lineTo(x, y);
      }
      liquidPath2.lineTo(sightRect.right + 5, sightRect.bottom + 10);
      liquidPath2.lineTo(sightRect.left - 5, sightRect.bottom + 10);
      liquidPath2.close();
      canvas.drawPath(
        liquidPath2,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              glowColor.withValues(alpha: glowColor == AppColors.amber ? 0.75 : 0.40),
              glowColor.withValues(alpha: glowColor == AppColors.amber ? 0.45 : 0.20),
              glowColor.withValues(alpha: glowColor == AppColors.amber ? 0.18 : 0.06),
            ],
          ).createShader(sightRect),
      );

      // Carbonation Bubbles rising
      final Paint bubblePaint = Paint()..color = Colors.white;
      final math.Random random = math.Random(101);
      final int bubbleCount = state.contains('FERMENTING') ? 16 : 8;

      for (int i = 0; i < bubbleCount; i++) {
        double startX = sightRect.left + (sightRect.width * random.nextDouble());
        double offset = random.nextDouble();
        double bubbleProgress = (progress + offset) % 1.0;
        double yVal = sightRect.bottom - (sightRect.height * fillPercent * bubbleProgress);

        if (yVal > liquidTop + 2.0 && yVal < sightRect.bottom) {
          double radius = 0.5 + 1.2 * random.nextDouble();
          bubblePaint.color = Colors.white.withValues(
            alpha: (0.15 + 0.35 * math.sin(bubbleProgress * math.pi)),
          );
          canvas.drawCircle(Offset(startX, yVal), radius, bubblePaint);
        }
      }
    }

    // --- 6. ROTATING IMPELLER MIXER ---
    final Paint shaftPaint = Paint()
      ..color = const Color(0xFF90A4AE)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    canvas.drawLine(Offset(w / 2, sightRect.top), Offset(w / 2, sightRect.bottom - 6), shaftPaint);

    final double bladeWidth = 11.0 * math.sin(impellerAngle);
    final Offset impellerCenter = Offset(w / 2, sightRect.bottom - 6);

    final Paint bladePaint = Paint()
      ..shader = LinearGradient(
        colors: [
          AppColors.textSecondary,
          glowColor.withValues(alpha: 0.5),
          const Color(0xFF78909C),
        ],
      ).createShader(Rect.fromCenter(center: impellerCenter, width: bladeWidth.abs() * 2, height: 3.0));

    canvas.drawOval(
      Rect.fromCenter(center: impellerCenter, width: bladeWidth.abs() * 2, height: 3.0),
      bladePaint,
    );

    canvas.restore(); // Unclip

    // Pulsing Outer Glow Ring
    final double pulseValue = 0.5 + 0.5 * math.sin(progress * 2 * math.pi);
    final bool isGold = glowColor == AppColors.amber;
    final Paint glowOuter = Paint()
      ..color = glowColor.withValues(alpha: isGold ? (0.22 + pulseValue * 0.25) : (0.10 + pulseValue * 0.12))
      ..style = PaintingStyle.stroke
      ..strokeWidth = isGold ? 5.5 : 3.5
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, isGold ? 4 : 3);
    final Paint glowInner = Paint()
      ..color = glowColor.withValues(alpha: isGold ? (0.65 + pulseValue * 0.25) : (0.40 + pulseValue * 0.15))
      ..style = PaintingStyle.stroke
      ..strokeWidth = isGold ? 2.2 : 1.2;
    canvas.drawRRect(sightRRect, glowOuter);
    canvas.drawRRect(sightRRect, glowInner);

    // Glass glint reflection
    final Paint reflectionPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawLine(
      Offset(sightRect.left + 2, sightRect.top + 3),
      Offset(sightRect.left + 2, sightRect.bottom - 3),
      reflectionPaint,
    );
  }

  @override
  bool shouldRepaint(covariant BioreactorVesselPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.fillPercent != fillPercent ||
        oldDelegate.glowColor != glowColor ||
        oldDelegate.stateText != stateText ||
        oldDelegate.temperature != temperature ||
        oldDelegate.brix != brix;
  }
}
