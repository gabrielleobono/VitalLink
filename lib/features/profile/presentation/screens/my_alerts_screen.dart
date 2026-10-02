import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
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
        title: Text(
          'Mes alertes',
          style: TextStyle(
            color: palette.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: alertsAsync.when(
        data: (alerts) {
          if (alerts.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  "Tu n'as publié aucune alerte pour l'instant.",
                  style: TextStyle(color: palette.textSecondary),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: alerts.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final alert = alerts[index];
              return BloodAlertCard(
                alert: alert,
                onTap: () => context.push(AppRoutes.emergencyDetail(alert.id)),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) =>
            Center(
              child: Text(
                'Impossible de charger tes alertes.',
                style: TextStyle(color: palette.textSecondary),
              ),
            ),
      ),
    );
  }
}
