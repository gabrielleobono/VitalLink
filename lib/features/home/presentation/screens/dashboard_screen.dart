import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/theme/theme_mode_provider.dart';
import '../../../profile/presentation/providers/profile_providers.dart';
import '../providers/blood_alert_provider.dart';
import '../widgets/blood_alert_card.dart';

/// Écran "Accueil" : actions rapides + alertes de sang à proximité,

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = context.palette;
    final alertsAsync = ref.watch(bloodAlertsProvider);
    final themeMode = ref.watch(themeModeProvider);
    final isDark =
        themeMode == ThemeMode.dark ||
        (themeMode == ThemeMode.system &&
            MediaQuery.platformBrightnessOf(context) == Brightness.dark);

    final userProfileAsync = ref.watch(userProfileProvider);
    final profile = userProfileAsync.asData?.value;
    final locationLabel = profile != null && profile.city.isNotEmpty
        ? '${profile.city}, ${profile.country == "Cameroun" ? "CM" : profile.country}'
        : 'Cameroun';

    return Scaffold(
      backgroundColor: palette.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.water_drop,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'VitalLink',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: palette.textPrimary,
                          ),
                        ),
                        Row(
                          children: [
                            const Icon(
                              Icons.circle,
                              size: 6,
                              color: AppColors.success,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              locationLabel,
                              style: TextStyle(
                                fontSize: 11,
                                color: palette.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: palette.background,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: palette.border),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.water_drop,
                          size: 12,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          profile?.isDonor == true
                              ? 'Donneur actif'
                              : 'Citoyen',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: palette.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 4),
                  IconButton(
                    tooltip: isDark
                        ? 'Passer en mode clair'
                        : 'Passer en mode sombre',
                    icon: Icon(
                      isDark
                          ? Icons.light_mode_outlined
                          : Icons.dark_mode_outlined,
                      color: palette.textSecondary,
                    ),
                    onPressed: () => ref
                        .read(themeModeProvider.notifier)
                        .setMode(isDark ? ThemeMode.light : ThemeMode.dark),
                  ),
                  InkWell(
                    onTap: () => context.go(AppRoutes.profile),
                    customBorder: const CircleBorder(),
                    child: CircleAvatar(
                      radius: 18,
                      backgroundColor: AppColors.primary.withValues(
                        alpha: 0.12,
                      ),
                      child: const Icon(
                        Icons.person,
                        color: AppColors.primary,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.only(bottom: 24),
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        Expanded(
                          child: _ActionCard(
                            icon: Icons.water_drop,
                            title: 'Urgence Sang',
                            subtitle: 'Lancer ou aider',
                            backgroundColor: AppColors.primary,
                            onTap: () => context.go(AppRoutes.emergencies),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _ActionCard(
                            icon: Icons.local_pharmacy_rounded,
                            title: 'Pharmacies',
                            subtitle: 'De garde ce soir',
                            backgroundColor: AppColors.darkSlate,
                            onTap: () => context.go(AppRoutes.pharmacies),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.circle,
                          size: 8,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Urgences à proximité',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: palette.textPrimary,
                          ),
                        ),
                        const Spacer(),
                        alertsAsync.when(
                          data: (alerts) => Text(
                            'Voir tout (${alerts.length})',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                          loading: () => const SizedBox.shrink(),
                          error: (_, _) => const SizedBox.shrink(),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  alertsAsync.when(
                    data: (alerts) {
                      if (alerts.isEmpty) {
                        return Padding(
                          padding: const EdgeInsets.all(32),
                          child: Center(
                            child: Text(
                              'Aucune urgence à proximité pour le moment.',
                              style: TextStyle(color: palette.textSecondary),
                            ),
                          ),
                        );
                      }
                      return Column(
                        children: [
                          for (final alert in alerts)
                            BloodAlertCard(
                              alert: alert,
                              onTap: () => context.push(
                                AppRoutes.emergencyDetail(alert.id),
                              ),
                            ),
                        ],
                      );
                    },
                    loading: () => const Padding(
                      padding: EdgeInsets.all(32),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                    error: (error, _) => Padding(
                      padding: const EdgeInsets.all(32),
                      child: Center(
                        child: Text(
                          'Erreur de chargement des alertes : $error',
                          style: TextStyle(color: palette.textSecondary),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.backgroundColor,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color backgroundColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: Colors.white, size: 18),
                ),
                const Spacer(),
                const Icon(
                  Icons.arrow_forward,
                  color: Colors.white70,
                  size: 16,
                ),
              ],
            ),
            const SizedBox(height: 18),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: const TextStyle(color: Colors.white70, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }
}
