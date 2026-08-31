import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';

class HillData {
  final String label;
  final double value;
  final Color color;
  final double peakXPercent;
  final double widthPercent;
  final double heightPercent;
  final String suffix;

  const HillData({
    required this.label,
    required this.value,
    required this.color,
    required this.peakXPercent,
    required this.widthPercent,
    required this.heightPercent,
    this.suffix = '',
  });

  HillData copyWith({
    double? value,
    double? heightPercent,
  }) {
    return HillData(
      label: label,
      value: value ?? this.value,
      color: color,
      peakXPercent: peakXPercent,
      widthPercent: widthPercent,
      heightPercent: heightPercent ?? this.heightPercent,
      suffix: suffix,
    );
  }
}

class OverlappingHillsChart extends StatefulWidget {
  final double totalEmissions;
  final String unit;
  final List<HillData> hills;
  final String summaryTitle;
  final String summaryDescription;

  const OverlappingHillsChart({
    super.key,
    required this.totalEmissions,
    this.unit = 'kg CO₂ eq',
    required this.hills,
    this.summaryTitle = 'Summary',
    this.summaryDescription = 'Total Carbon Footprint',
  });

  @override
  State<OverlappingHillsChart> createState() => _OverlappingHillsChartState();
}

class _OverlappingHillsChartState extends State<OverlappingHillsChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  List<double> _oldValues = [];
  List<double> _targetValues = [];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _targetValues = widget.hills.map((h) => h.value).toList();
    _oldValues = List.from(_targetValues);
    _controller.forward(from: 1.0);
  }

  @override
  void didUpdateWidget(OverlappingHillsChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    bool changed = false;
    if (widget.hills.length != oldWidget.hills.length) {
      changed = true;
    } else {
      for (int i = 0; i < widget.hills.length; i++) {
        if (widget.hills[i].value != oldWidget.hills[i].value) {
          changed = true;
          break;
        }
      }
    }

    if (changed) {
      _oldValues = _targetValues;
      _targetValues = widget.hills.map((h) => h.value).toList();
      
      if (_oldValues.length != _targetValues.length) {
        _oldValues = List.from(_targetValues);
      }
      
      _controller.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 250,
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.background.withOpacity(0.08), // Dark glassmorphic backdrop
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0x2BFFFFFF), width: 1.2),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              final double t = CurvedAnimation(
                parent: _controller,
                curve: Curves.easeOutCubic,
              ).value;

              final List<HillData> animatedHills = [];
              for (int i = 0; i < widget.hills.length; i++) {
                final double startVal = _oldValues.length > i ? _oldValues[i] : widget.hills[i].value;
                final double targetVal = _targetValues[i];
                final double currentVal = startVal + (targetVal - startVal) * t;
                
                final double baseHeightPercent = widget.hills[i].heightPercent;
                final double currentHeightPercent = baseHeightPercent * (targetVal > 0 ? (currentVal / targetVal).clamp(0.2, 1.5) : 1.0);

                animatedHills.add(
                  widget.hills[i].copyWith(
                    value: currentVal,
                    heightPercent: currentHeightPercent.clamp(0.05, 0.95),
                  ),
                );
              }

              final double totalStart = oldTotalEmissions(widget.totalEmissions);
              final double currentTotal = totalStart + (widget.totalEmissions - totalStart) * t;

              return CustomPaint(
                size: Size(constraints.maxWidth, constraints.maxHeight),
                painter: _HillsPainter(
                  hills: animatedHills,
                  totalEmissions: currentTotal,
                  unit: widget.unit,
                  summaryTitle: widget.summaryTitle,
                  summaryDescription: widget.summaryDescription,
                ),
              );
            },
          );
        },
      ),
    );
  }

  double oldTotalEmissions(double target) {
    double sumOld = 0;
    for (var val in _oldValues) {
      sumOld += val;
    }
    return sumOld > 0 ? sumOld : target;
  }
}

class _HillsPainter extends CustomPainter {
  final List<HillData> hills;
  final double totalEmissions;
  final String unit;
  final String summaryTitle;
  final String summaryDescription;

  _HillsPainter({
    required this.hills,
    required this.totalEmissions,
    required this.unit,
    required this.summaryTitle,
    required this.summaryDescription,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final bottom = size.height - 75; // Leave more space at bottom for labels below the plate
    final w = size.width;

    // Draw horizontal faint grid lines in the background
    final gridPaint = Paint()
      ..color = AppColors.textSecondary.withValues(alpha: 0.06)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    for (int i = 0; i < 4; i++) {
      final y = bottom - (i * (size.height - 110) / 3);
      canvas.drawLine(Offset(0, y), Offset(w, y), gridPaint);
    }

    // 1. Draw Left Sweeping Contour Fan Lines (Steel Gray)
    _drawContourLines(canvas, size, bottom);

    // 2. Draw 3D Chrome Reflective Base Plate
    final double plateLeft = w * 0.22;
    final double plateRight = w * 0.95;
    final double plateTopY = bottom - 3;
    final double plateBottomY = bottom + 8;

    final Path platePath = Path()
      ..moveTo(plateLeft, plateBottomY)
      ..lineTo(plateLeft + 24, plateTopY)
      ..lineTo(plateRight - 24, plateTopY)
      ..lineTo(plateRight, plateBottomY)
      ..close();

    final plateGradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        AppColors.textMuted.withValues(alpha: 0.8), // Metallic silver highlight
        const Color(0xFF223B57).withValues(alpha: 0.9), // Steel reflection
        AppColors.background.withValues(alpha: 0.95), // Deep base
      ],
    );
    canvas.drawPath(platePath, Paint()..shader = plateGradient.createShader(Rect.fromLTRB(plateLeft, plateTopY, plateRight, plateBottomY))..style = PaintingStyle.fill);

    // Draw metallic highlight line along top edge
    final Path plateTopLine = Path()
      ..moveTo(plateLeft + 24, plateTopY)
      ..lineTo(plateRight - 24, plateTopY);
    canvas.drawPath(plateTopLine, Paint()..color = AppColors.textSecondary.withValues(alpha: 0.5)..strokeWidth = 1.5..style = PaintingStyle.stroke);

    // 3. Draw each hill curve shape (Layered Left to Right)
    for (int i = 0; i < hills.length; i++) {
      final hill = hills[i];
      final peakX = w * hill.peakXPercent;
      final hillWidth = w * hill.widthPercent;
      final startX = peakX - (hillWidth / 2);
      final endX = peakX + (hillWidth / 2);
      final height = (size.height - 110) * hill.heightPercent;
      final peakY = bottom - height;

      // Draw the hill translucent glass curve shape
      final path = Path()..moveTo(startX, bottom);
      path.cubicTo(
        startX + (peakX - startX) * 0.45, bottom,
        peakX - (peakX - startX) * 0.35, peakY,
        peakX, peakY,
      );
      path.cubicTo(
        peakX + (endX - peakX) * 0.35, peakY,
        endX - (endX - peakX) * 0.45, bottom,
        endX, bottom,
      );
      path.lineTo(startX, bottom);
      path.close();

      // Translucent Glass Gradient Fill
      final hillGradient = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          hill.color.withValues(alpha: 0.35),
          hill.color.withValues(alpha: 0.01),
        ],
      );

      canvas.drawPath(path, Paint()..shader = hillGradient.createShader(Rect.fromLTRB(startX, peakY, endX, bottom))..style = PaintingStyle.fill);

      // Draw solid neon glowing outline along the top edge curve
      final Path outlinePath = Path()..moveTo(startX, bottom);
      outlinePath.cubicTo(
        startX + (peakX - startX) * 0.45, bottom,
        peakX - (peakX - startX) * 0.35, peakY,
        peakX, peakY,
      );
      outlinePath.cubicTo(
        peakX + (endX - peakX) * 0.35, peakY,
        endX - (endX - peakX) * 0.45, bottom,
        endX, bottom,
      );

      canvas.drawPath(
        outlinePath,
        Paint()
          ..color = hill.color.withValues(alpha: 0.85)
          ..strokeWidth = 2.0
          ..style = PaintingStyle.stroke,
      );

      // Draw vertical alignment line from peak down to base plate
      canvas.drawLine(
        Offset(peakX, peakY),
        Offset(peakX, bottom),
        Paint()
          ..color = AppColors.textSecondary.withValues(alpha: 0.12)
          ..strokeWidth = 1.0,
      );
    }

    // 4. Draw Summit Connection Path (Cyan/Muted line across peaks)
    final Path connectionPath = Path();
    for (int i = 0; i < hills.length; i++) {
      final hill = hills[i];
      final peakX = w * hill.peakXPercent;
      final peakY = bottom - (size.height - 110) * hill.heightPercent;

      if (i == 0) {
        connectionPath.moveTo(peakX, peakY);
      } else {
        final prevHill = hills[i - 1];
        final prevX = w * prevHill.peakXPercent;
        final prevY = bottom - (size.height - 110) * prevHill.heightPercent;
        connectionPath.cubicTo(
          prevX + (peakX - prevX) * 0.5, prevY,
          prevX + (peakX - prevX) * 0.5, peakY,
          peakX, peakY,
        );
      }
    }
    canvas.drawPath(
      connectionPath,
      Paint()
        ..color = AppColors.textSecondary.withValues(alpha: 0.3)
        ..strokeWidth = 1.2
        ..style = PaintingStyle.stroke,
    );

    // 5. Draw Glowing summit nodes & Labels below the base plate
    for (int i = 0; i < hills.length; i++) {
      final hill = hills[i];
      final peakX = w * hill.peakXPercent;
      final peakY = bottom - (size.height - 110) * hill.heightPercent;

      // Draw Glowing Peak Summit Circle Nodes
      canvas.drawCircle(Offset(peakX, peakY), 5.5, Paint()..color = hill.color.withValues(alpha: 0.4));
      canvas.drawCircle(Offset(peakX, peakY), 3.0, Paint()..color = Colors.white);

      // Draw indicator pointer line pointing down below the plate
      final double pointerTop = bottom + 8;
      final double pointerBottom = pointerTop + 14;
      canvas.drawLine(
        Offset(peakX, pointerTop),
        Offset(peakX, pointerBottom),
        Paint()
          ..color = AppColors.textSecondary.withValues(alpha: 0.2)
          ..strokeWidth = 1.0,
      );

      // Draw Label: Title (e.g. "Plant Power") in clean light gray
      _drawText(
        canvas: canvas,
        text: hill.label,
        offset: Offset(peakX, pointerBottom + 4),
        fontSize: 9,
        fontWeight: FontWeight.w600,
        color: AppColors.textMuted, // Steel Gray
        center: true,
      );

      // Draw Label: Numeric Value (e.g. "89.2 kW") in colored bold neon text matching the curve
      _drawText(
        canvas: canvas,
        text: '${hill.value.toStringAsFixed(1)}${hill.suffix}',
        offset: Offset(peakX, pointerBottom + 16),
        fontSize: 12,
        fontWeight: FontWeight.bold,
        color: hill.color,
        center: true,
      );
    }

    // 6. Draw Summary Block on the left side
    _drawSummaryBlock(canvas, size, bottom);
  }

  void _drawContourLines(Canvas canvas, Size size, double bottom) {
    final w = size.width;
    final firstHill = hills.isNotEmpty
        ? hills.first
        : const HillData(
            label: '',
            value: 0,
            color: Colors.transparent,
            peakXPercent: 0.42,
            widthPercent: 0.40,
            heightPercent: 0.75);
            
    final targetX = w * firstHill.peakXPercent;
    final targetY = bottom - ((size.height - 110) * firstHill.heightPercent);

    final linePaint = Paint()
      ..color = AppColors.textMuted.withValues(alpha: 0.12) // Steel Gray
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    const int numLines = 14;
    for (int i = 0; i < numLines; i++) {
      final t = i / (numLines - 1);
      final startX = w * 0.05 + (t * w * 0.16);
      
      final path = Path()..moveTo(startX, bottom);
      path.cubicTo(
        startX + (targetX - startX) * 0.4, bottom - 10,
        targetX - (targetX - startX) * 0.5, targetY + (1.0 - t) * 60,
        targetX, targetY,
      );
      
      canvas.drawPath(path, linePaint);
    }
  }

  void _drawSummaryBlock(Canvas canvas, Size size, double bottom) {
    final startX = size.width * 0.07;
    final blockY = size.height * 0.28;

    // Draw vertical scale line
    final linePaint = Paint()
      ..color = AppColors.textSecondary.withValues(alpha: 0.4) // Steel Gray
      ..strokeWidth = 1.2;
    canvas.drawLine(Offset(startX, blockY - 10), Offset(startX, bottom), linePaint);
    canvas.drawLine(Offset(startX - 3, blockY - 10), Offset(startX + 3, blockY - 10), linePaint);

    // Title
    _drawText(
      canvas: canvas,
      text: summaryTitle,
      offset: Offset(startX + 12, blockY),
      fontSize: 11,
      fontWeight: FontWeight.w600,
      color: AppColors.textMuted, // Steel Gray
    );

    // Giant value
    _drawText(
      canvas: canvas,
      text: totalEmissions.toStringAsFixed(0),
      offset: Offset(startX + 12, blockY + 12),
      fontSize: 48,
      fontWeight: FontWeight.w900,
      color: AppColors.textPrimary, // Off-white
      fontFamily: 'serif',
    );

    // Unit
    _drawText(
      canvas: canvas,
      text: unit,
      offset: Offset(startX + 12, blockY + 62),
      fontSize: 11,
      fontWeight: FontWeight.bold,
      color: AppColors.blue, // Cyan
    );

    // Description text
    _drawText(
      canvas: canvas,
      text: summaryDescription,
      offset: Offset(startX + 12, blockY + 76),
      fontSize: 9,
      fontWeight: FontWeight.w500,
      color: AppColors.textMuted, // Steel Gray
    );
  }

  void _drawText({
    required Canvas canvas,
    required String text,
    required Offset offset,
    required double fontSize,
    required FontWeight fontWeight,
    required Color color,
    String? fontFamily,
    bool center = false,
  }) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: color,
          fontSize: fontSize,
          fontWeight: fontWeight,
          fontFamily: fontFamily,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    
    final finalOffset = center 
        ? Offset(offset.dx - textPainter.width / 2, offset.dy) 
        : offset;
        
    textPainter.paint(canvas, finalOffset);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
