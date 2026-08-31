import 'package:flutter/material.dart';

/// Centralized color palette for the Distillary / Auraliss app.
/// All UI colors should reference this class — never use raw hex literals.
class AppColors {
  AppColors._(); // prevent instantiation

  // ── Backgrounds (Midnight Navy Theme - Not Gray) ──────────────────
  static const Color background  = Color(0xFF000000);  // rich deep midnight navy
  static const Color surface     = Color(0xFF121622);  // card / panel fill
  static const Color surfaceDeep = Color(0xFF0A0D18);  // inner card bg
  static const Color surfaceGlass = Color(0x1F121622); // surface at 12% opacity

  // ── Brand Accents ────────────────────────────
  static const Color cyan        = Color(0xFF2AB1A0);  // live indicators / MQTT
  static const Color orange      = Color(0xFFF58A0A);  // warnings / secondary
  static const Color blue        = Color(0xFFC05A8F);  // vibrant plum/orchid accent  // fermenter status / charts
  static const Color amber       = Color(0xFFD2A44E);  // critical alerts / alarms
  static const Color red         = Color(0xFFFA8072);  // faults / errors
  static const Color green       = Color(0xFF72A47B);  // normal / healthy
  static const Color teal        = Color(0xFF2AB1A0);  // success states (alias cyan)
  static const Color purple      = Color(0xFF88779E);  // AI advisor / plots (violet)
  static const Color primaryBlue = Color(0xFFC05A8F);  // seed / button blue (alias blue)
  static const Color normalFermenting = Color(0xFF5B9BC2); // rich steel blue for normal fermentation

  // ── Text ─────────────────────────────────────
  static const Color textPrimary   = Color(0xFFF2F3F5); // main text (warm cream)
  static const Color textSecondary = Color(0xFFC8C9CD); // labels / subtitles
  static const Color textMuted     = Color(0xFF85868C); // hints / units

  // ── Structural ───────────────────────────────
  static const Color divider      = Color(0xFF2A3146);  // navy-indigo borders / separators
  static const Color glassOverlay = Color(0x0CFFFBFD);  // glass card tint
}
