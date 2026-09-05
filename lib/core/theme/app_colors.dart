import 'package:flutter/material.dart';

/// BIKERZEDGE brand palette. The wordmark is a bold industrial orange on white;
/// MotoTrack pairs that orange with slate/charcoal neutrals for a workshop feel.
class AppColors {
  AppColors._();

  /// Primary brand orange (from the BIKERZEDGE logo).
  static const Color brandOrange = Color(0xFFF5820C);
  static const Color brandOrangeDark = Color(0xFFD96D00);
  static const Color brandOrangeLight = Color(0xFFFFB259);

  // Neutrals (slate scale)
  static const Color ink = Color(0xFF0F172A);
  static const Color slate800 = Color(0xFF1E293B);
  static const Color slate700 = Color(0xFF334155);
  static const Color slate500 = Color(0xFF64748B);
  static const Color slate300 = Color(0xFFCBD5E1);
  static const Color slate100 = Color(0xFFF1F5F9);
  static const Color surface = Color(0xFFF8FAFC);
  static const Color white = Color(0xFFFFFFFF);

  // Semantic
  static const Color success = Color(0xFF16A34A);
  static const Color warning = Color(0xFFF59E0B);
  static const Color danger = Color(0xFFDC2626);
  static const Color info = Color(0xFF0EA5E9);
}
