import 'dart:ui';
import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';

class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final Color backgroundColor;
  final Color borderColor;
  final double blurAmount;

  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.borderRadius = 20,
    this.backgroundColor = AppColors.surfaceGlass, // 12% Deep Navy
    this.borderColor = const Color(0x42223B57),    // Dark Blue-Gray conformed
    this.blurAmount = 24.0,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blurAmount, sigmaY: blurAmount),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(color: borderColor, width: 1.5),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0C0E1F35),
                blurRadius: 16,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}
