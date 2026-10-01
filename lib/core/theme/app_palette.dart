import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Couleurs structurelles (fond, surface, texte, bordures) qui doivent
/// s'inverser en mode sombre. Les couleurs de marque et les badges pastel
/// (`AppColors.primary`, `tealPrimary`, `softBlue`, ...) restent identiques
/// dans les deux modes - ce ne sont pas des surfaces, elles ne sont donc pas
/// dans cette palette et continuent de se lire via `AppColors` directement.
@immutable
class AppPalette extends ThemeExtension<AppPalette> {
  const AppPalette({
    required this.background,
    required this.surface,
    required this.textPrimary,
    required this.textSecondary,
    required this.border,
    required this.navInactive,
  });

  final Color background;
  final Color surface;
  final Color textPrimary;
  final Color textSecondary;
  final Color border;
  final Color navInactive;

  static const AppPalette light = AppPalette(
    background: AppColors.background,
    surface: AppColors.surface,
    textPrimary: AppColors.textPrimary,
    textSecondary: AppColors.textSecondary,
    border: AppColors.border,
    navInactive: AppColors.navInactive,
  );

  static const AppPalette dark = AppPalette(
    background: Color(0xFF0F172A),
    surface: Color(0xFF1E293B),
    textPrimary: Color(0xFFF1F5F9),
    textSecondary: Color(0xFF94A3B8),
    border: Color(0xFF334155),
    navInactive: Color(0xFF64748B),
  );

  @override
  AppPalette copyWith({
    Color? background,
    Color? surface,
    Color? textPrimary,
    Color? textSecondary,
    Color? border,
    Color? navInactive,
  }) {
    return AppPalette(
      background: background ?? this.background,
      surface: surface ?? this.surface,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      border: border ?? this.border,
      navInactive: navInactive ?? this.navInactive,
    );
  }

  @override
  AppPalette lerp(ThemeExtension<AppPalette>? other, double t) {
    if (other is! AppPalette) return this;
    return AppPalette(
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      border: Color.lerp(border, other.border, t)!,
      navInactive: Color.lerp(navInactive, other.navInactive, t)!,
    );
  }
}

/// Accès pratique aux couleurs structurelles du thème actif :
/// `context.palette.surface`.
extension AppPaletteX on BuildContext {
  AppPalette get palette =>
      Theme.of(this).extension<AppPalette>() ?? AppPalette.light;
}
