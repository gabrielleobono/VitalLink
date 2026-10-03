import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/vital_link_logo.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../home/presentation/providers/blood_alert_provider.dart';
import '../../../home/presentation/widgets/blood_alert_card.dart';

/// Écran "Urgences" : liste des alertes de sang ouvertes avec le logo officiel VitalLink
class EmergencyScreen extends ConsumerWidget {
  const EmergencyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final alertsAsync = ref.watch(bloodAlertsProvider);
    final palette = context.palette;

    return Scaffold(
      backgroundColor: palette.background,
      appBar: AppBar(
        backgroundColor: palette.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            const VitalLinkLogo(size: 38),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Urgences Sang',
                  style: TextStyle(
                    color: palette.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                alertsAsync.when(
                  data: (alerts) => Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 7,
                        height: 7,
                        decoration: const BoxDecoration(
                          color: AppColors.primaryRed,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        '${alerts.length} alerte${alerts.length > 1 ? 's' : ''} active${alerts.length > 1 ? 's' : ''}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: palette.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  loading: () => Text(
                    'Chargement des alertes...',
                    style: TextStyle(
                      fontSize: 12,
                      color: palette.textSecondary,
                    ),
                  ),
                  error: (err, stack) => Text(
                    'Mode hors-ligne',
                    style: TextStyle(
                      fontSize: 12,
                      color: palette.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),

      body: alertsAsync.when(
        data: (alerts) {
          if (alerts.isEmpty) {
            return Center(
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
                      Icons.volunteer_activism_rounded,
                      size: 36,
                      color: AppColors.primaryRed,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Aucune urgence en cours',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: palette.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Toutes les demandes de poches de sang sont pourvues.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      color: palette.textSecondary,
                    ),
                  ),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.only(top: 8, bottom: 100),
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
        error: (error, stackTrace) => Center(
          child: Text(
            'Impossible de charger les alertes.',
            style: TextStyle(color: palette.textSecondary),
          ),
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: FloatingActionButton.extended(
          onPressed: () => context.push(AppRoutes.createEmergency),
          backgroundColor: AppColors.primaryRed,
          foregroundColor: Colors.white,
          elevation: 4,
          icon: const Icon(Icons.add_alert_rounded, size: 20),
          label: const Text(
            'Nouvelle alerte',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
          ),
        ),
      ),
    );
  }
}
