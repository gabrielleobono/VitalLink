import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../home/presentation/providers/blood_alert_provider.dart';
import '../../../home/presentation/widgets/blood_alert_card.dart';

/// Écran "Mes alertes" : alertes de sang publiées par l'utilisateur courant,
/// accessible depuis le Profil.
class MyAlertsScreen extends ConsumerWidget {
  const MyAlertsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = context.palette;
    final alertsAsync = ref.watch(myAlertsProvider);

    return Scaffold(
      backgroundColor: palette.background,
      appBar: AppBar(
        backgroundColor: palette.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Mes alertes',
              style: TextStyle(
                color: palette.textPrimary,
                fontWeight: FontWeight.w800,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 2),
            alertsAsync.when(
              data: (alerts) => Text(
                '${alerts.length} alerte${alerts.length > 1 ? 's' : ''} créée${alerts.length > 1 ? 's' : ''}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: palette.textSecondary,
                ),
              ),
              loading: () => Text(
                'Chargement...',
                style: TextStyle(fontSize: 12, color: palette.textSecondary),
              ),
              error: (err, stack) => const SizedBox.shrink(),
            ),
          ],
        ),
      ),
      body: alertsAsync.when(
        data: (alerts) {
          if (alerts.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: AppColors.primaryRed.withValues(alpha: 0.08),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.campaign_outlined,
                        size: 36,
                        color: AppColors.primaryRed,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Aucune alerte publiée',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: palette.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Tu n\'as publié aucune alerte de sang pour l\'instant.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        color: palette.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.only(top: 8, bottom: 24),
            itemCount: alerts.length,
            itemBuilder: (context, index) {
              final alert = alerts[index];
              return BloodAlertCard(
                alert: alert,
                onTap: () => context.push(AppRoutes.emergencyDetail(alert.id)),
              );
            },
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primaryRed),
        ),
        error: (error, _) => Center(
          child: Text(
            'Impossible de charger tes alertes.',
            style: TextStyle(color: palette.textSecondary),
          ),
        ),
      ),
    );
  }
}
