import 'package:flutter/material.dart';

/// Central responsive helper for Parrys Aura SCADA system.
/// Distinguishes between Mobile, Compact Tablet (11.0" Xiaomi Pad 6),
/// and Enterprise Large Tablet (12.7" Lenovo/Samsung/iPad Pro).
class ResponsiveLayout {
  /// Evaluates strictly true when the display is a 12.4" - 13.0" class tablet
  /// (Logical width >= 1250 dp AND logical height >= 780 dp in landscape).
  ///
  /// - Xiaomi Pad 6 (11.0", 1152 x 720 dp) -> FALSE (renders exact compact baseline)
  /// - 12.7" Class Tablet (1360 x 860 dp)   -> TRUE  (renders edge-to-edge scaled layout)
  static bool is12InchTablet(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return size.width >= 1250 && size.height >= 780;
  }

  /// Evaluates true when screen width is constrained or in portrait orientation.
  static bool isMobile(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return size.width < 900 || MediaQuery.of(context).orientation == Orientation.portrait;
  }

  /// Evaluates true specifically for 10" - 11.5" tablets (like Xiaomi Pad 6)
  static bool isCompactTablet(BuildContext context) {
    return !isMobile(context) && !is12InchTablet(context);
  }
}
