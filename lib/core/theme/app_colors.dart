import 'package:flutter/material.dart';

/// Palette basée sur les maquettes Figma VitalLink (rouge médical / urgence).
abstract final class AppColors {
  /// Rouge de marque exact, relevé dans les métadonnées du fichier Figma
  /// ("Brand logo. - Primary color: #dc2626").
  static const primary = Color(0xFFDC2626);
  static const primaryDark = Color(0xFFB71C1C);
  static const background = Color(0xFFF7F7FA);
  static const surface = Colors.white;
  static const textPrimary = Color(0xFF1A1A1A);
  static const textSecondary = Color(0xFF6B7280);
  static const border = Color(0xFFE5E7EB);
  static const success = Color(0xFF2E7D32);
  static const warning = Color(0xFFF59E0B);
  static const info = Color(0xFF2F80ED);

  /// Couleur des icônes/labels inactifs de la bottom nav (gris-brun neutre
  /// mesuré sur la capture du Figma, pas un gris bleuté classique).
  static const navInactive = Color(0xFF44403C);
}
