import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';

class ThreeDPrismColumn extends StatefulWidget {
  final String label;
  final double heightFactor; // 0.0 to 1.0
  final Color baseColor;
  final bool isActive;
  final bool isCompleted;
  final VoidCallback onTap;

  const ThreeDPrismColumn({
    super.key,
    required this.label,
    required this.heightFactor,
    required this.baseColor,
    this.isActive = false,
    this.isCompleted = false,
    required this.onTap,
  });

  @override
  State<ThreeDPrismColumn> createState() => _ThreeDPrismColumnState();
}

class _ThreeDPrismColumnState extends State<ThreeDPrismColumn>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    if (widget.isActive) {
      _animationController.repeat();
    }
  }

  @override
  void didUpdateWidget(ThreeDPrismColumn oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive != oldWidget.isActive) {
      if (widget.isActive) {
        _animationController.repeat();
      } else {
        _animationController.stop();
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return CustomPaint(
            size: const Size(120, 160),
            painter: _PrismPainter(
              heightFactor: widget.heightFactor,
              baseColor: widget.baseColor,
              isActive: widget.isActive,
              isCompleted: widget.isCompleted,
              stripeOffset: _animationController.value,
              label: widget.label,
            ),
          );
        },
      ),
    );
  }
}

class _PrismPainter extends CustomPainter {
  final double heightFactor;
  final Color baseColor;
  final bool isActive;
  final bool isCompleted;
  final double stripeOffset;
  final String label;

  _PrismPainter({
    required this.heightFactor,
    required this.baseColor,
    required this.isActive,
    required this.isCompleted,
    required this.stripeOffset,
    required this.label,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Width and height details
    final double blockWidth = size.width * 0.55;
    final double maxBlockHeight = size.height * 0.70;
    final double activeHeight = maxBlockHeight * heightFactor.clamp(0.1, 1.0);
    
    // Extrusion offsets
    const double extrusionX = 14.0;
    const double extrusionY = -10.0;

    // Center coordinates
    final double left = (size.width - blockWidth - extrusionX) / 2;
    final double right = left + blockWidth;
    final double bottom = size.height - 30; // Leave space for labels
    final double top = bottom - activeHeight;

    // Colors mapping conformed to Neon Glassmorphism
    final Color frontColor = baseColor.withValues(alpha: isCompleted ? 0.35 : (isActive ? 0.45 : 0.18));
    final Color rightColor = baseColor.withValues(alpha: isCompleted ? 0.22 : (isActive ? 0.30 : 0.10));
    final Color topColor = baseColor.withValues(alpha: isCompleted ? 0.50 : (isActive ? 0.60 : 0.28));

    // Paint Front Face
    final Path frontPath = Path()
      ..moveTo(left, top)
      ..lineTo(right, top)
      ..lineTo(right, bottom)
      ..lineTo(left, bottom)
      ..close();

    final Paint frontPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          frontColor,
          frontColor.withValues(alpha: 0.08),
        ],
      ).createShader(Rect.fromLTRB(left, top, right, bottom));
    canvas.drawPath(frontPath, frontPaint);

    // Paint Right Face (Extrusion)
    final Path rightPath = Path()
      ..moveTo(right, top)
      ..lineTo(right + extrusionX, top + extrusionY)
      ..lineTo(right + extrusionX, bottom + extrusionY)
      ..lineTo(right, bottom)
      ..close();

    final Paint rightPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          rightColor,
          rightColor.withValues(alpha: 0.05),
        ],
      ).createShader(Rect.fromLTRB(right, top + extrusionY, right + extrusionX, bottom));
    canvas.drawPath(rightPath, rightPaint);

    // Paint Top Face (Cap Highlight)
    final Path topPath = Path()
      ..moveTo(left, top)
      ..lineTo(left + extrusionX, top + extrusionY)
      ..lineTo(right + extrusionX, top + extrusionY)
      ..lineTo(right, top)
      ..close();

    final Paint topPaint = Paint()
      ..color = topColor
      ..style = PaintingStyle.fill;
    canvas.drawPath(topPath, topPaint);

    // Draw Neon Border Lines (sharp specular edges)
    final Paint borderPaint = Paint()
      ..color = baseColor.withValues(alpha: isActive ? 0.8 : 0.4)
      ..strokeWidth = isActive ? 2.0 : 1.2
      ..style = PaintingStyle.stroke;
    
    // Draw front outline
    canvas.drawPath(frontPath, borderPaint);
    // Draw extrusion lines
    canvas.drawLine(Offset(right, top), Offset(right + extrusionX, top + extrusionY), borderPaint);
    canvas.drawLine(Offset(right, bottom), Offset(right + extrusionX, bottom + extrusionY), borderPaint);
    canvas.drawLine(Offset(right + extrusionX, top + extrusionY), Offset(right + extrusionX, bottom + extrusionY), borderPaint);
    canvas.drawLine(Offset(left, top), Offset(left + extrusionX, top + extrusionY), borderPaint);
    canvas.drawLine(Offset(left + extrusionX, top + extrusionY), Offset(right + extrusionX, top + extrusionY), borderPaint);

    // Draw Diagonal Stripes Pattern on Front Face
    _drawDiagonalStripes(canvas, left, right, top, bottom);

    // Draw Drop Shadow Glow when Active
    if (isActive) {
      final Paint glowPaint = Paint()
        ..color = baseColor.withValues(alpha: 0.35)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);
      canvas.drawPath(frontPath, glowPaint);
    }

    // Draw Labels text below
    final TextPainter textPainter = TextPainter(
      text: TextSpan(
        text: label,
        style: TextStyle(
          fontSize: 9.5,
          fontWeight: isActive ? FontWeight.bold : FontWeight.w600,
          color: isActive ? Colors.white : AppColors.textSecondary, // Light Gray
        ),
      ),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    )..layout(maxWidth: size.width);
    
    textPainter.paint(
      canvas,
      Offset((size.width - textPainter.width) / 2, size.height - 22),
    );
  }

  void _drawDiagonalStripes(Canvas canvas, double left, double right, double top, double bottom) {
    // Clip drawing area to front face of prism
    canvas.save();
    canvas.clipPath(Path()
      ..moveTo(left, top)
      ..lineTo(right, top)
      ..lineTo(right, bottom)
      ..lineTo(left, bottom)
      ..close());

    final Paint stripePaint = Paint()
      ..color = baseColor.withValues(alpha: isCompleted ? 0.30 : (isActive ? 0.40 : 0.15))
      ..strokeWidth = 3.5
      ..style = PaintingStyle.stroke;

    final double width = right - left;
    final double height = bottom - top;
    const double diagonalStep = 18.0;

    // To animate, we apply a sliding shift using stripeOffset (which moves from 0 to 1)
    final double shift = isActive ? (stripeOffset * diagonalStep) : 0.0;

    // Draw diagonal lines from top-left to bottom-right (dy/dx = 1)
    for (double x = -height; x < width + height; x += diagonalStep) {
      final double startX = left + x + shift;
      final double startY = top;
      final double endX = startX - height;
      final double endY = bottom;
      canvas.drawLine(Offset(startX, startY), Offset(endX, endY), stripePaint);
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _PrismPainter oldDelegate) {
    return oldDelegate.heightFactor != heightFactor ||
        oldDelegate.baseColor != baseColor ||
        oldDelegate.isActive != isActive ||
        oldDelegate.isCompleted != isCompleted ||
        oldDelegate.stripeOffset != stripeOffset ||
        oldDelegate.label != label;
  }
}
