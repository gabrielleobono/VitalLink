import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Mode de thème actif de l'app (clair/sombre/système), modifiable à chaud
/// via l'icône de bascule sur l'écran d'accueil.
///
/// Ne persiste pas entre les lancements de l'app (pas de package de
/// stockage local dans le projet pour l'instant) — revient à
/// [ThemeMode.system] à chaque redémarrage.
class AppThemeModeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() => ThemeMode.system;

  void setMode(ThemeMode mode) => state = mode;
}

final themeModeProvider = NotifierProvider<AppThemeModeNotifier, ThemeMode>(
  AppThemeModeNotifier.new,
);
