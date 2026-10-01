import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../../home/presentation/providers/blood_alert_provider.dart';
import '../../../home/presentation/widgets/blood_alert_card.dart';

/// Écran "Urgences" : liste des alertes de sang ouvertes et accès à la
/// publication d'une nouvelle alerte.
class EmergencyScreen extends ConsumerWidget {
  const EmergencyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final alertsAsync = ref.watch(bloodAlertsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Urgences')),
      body: alertsAsync.when(
        data: (alerts) {
          if (alerts.isEmpty) {
            return const Center(
              child: Text('Aucune alerte ouverte pour le moment.'),
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
        error: (error, stackTrace) =>
            const Center(child: Text('Impossible de charger les alertes.')),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(AppRoutes.createEmergency),
        icon: const Icon(Icons.add_alert_rounded),
        label: const Text('Nouvelle alerte'),
      ),
    );
  }
}
