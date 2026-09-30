import 'package:flutter/material.dart';

/// Palette de couleurs VitalLink unifiée (Figma & modules métier).
abstract final class AppColors {
  // --- Couleurs de base & Figma (Module 1) ---
  static const Color primary = Color(0xFFDC2626);
  static const Color primaryDark = Color(0xFFB71C1C);
  static const Color primaryRed = Color(0xFFDC2626);
  static const Color darkSlate = Color(0xFF1E293B);

  static const Color background = Color(0xFFF7F7FA);
  static const Color surface = Colors.white;
  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color border = Color(0xFFE5E7EB);

  static const Color success = Color(0xFF2E7D32);
  static const Color warning = Color(0xFFF59E0B);
  static const Color info = Color(0xFF2F80ED);
  static const Color navInactive = Color(0xFF44403C);

  // --- Teintes spécifiques pharmacies & badges (Module 3) ---
  static const Color tealPrimary = Color(0xFF0F766E);
  static const Color tealLight = Color(0xFFCCFBF1);
  static const Color tealBadge = Color(0xFF5EEAD4);

  static const Color softBlue = Color(0xFFE0F2FE);
  static const Color purpleLight = Color(0xFFF3E8FF);
  static const Color purpleText = Color(0xFF6B21A8);
}
