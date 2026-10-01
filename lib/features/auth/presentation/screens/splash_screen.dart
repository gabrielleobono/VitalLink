import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_palette.dart';

/// Écran de démarrage : logo + mission VitalLink, affiché brièvement au
/// lancement avant que [appRouter] ne redirige vers l'écran adapté à la
/// session (connexion, inscription ou accueil).
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 1400), () {
      if (mounted) context.go(AppRoutes.home);
    });
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Scaffold(
      backgroundColor: palette.background,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset('assets/icons/app_icon.png', width: 72, height: 72),
            const SizedBox(height: 14),
            RichText(
              text: TextSpan(
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: palette.textPrimary,
                ),
                children: const [
                  TextSpan(text: 'Vital'),
                  TextSpan(
                    text: 'Link',
                    style: TextStyle(color: AppColors.primary),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 48),
              child: Text(
                "Sang et médicaments d'urgence, partout en Afrique francophone.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: palette.textSecondary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
