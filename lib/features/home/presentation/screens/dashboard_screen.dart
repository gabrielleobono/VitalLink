import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../blood_requests/presentation/providers/blood_request_providers.dart';
import '../../../blood_requests/presentation/widgets/blood_request_card.dart';

/// Ã‰cran "Accueil" (Hub) : accÃ¨s rapide Urgence/Pharmacies + fil des alertes
/// sang ouvertes (les 5 plus urgentes/rÃ©centes).
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  static const _feedPreviewCount = 5;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final requestsAsync = ref.watch(openBloodRequestsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('VitalLink')),
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(openBloodRequestsProvider.future),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Row(
              children: [
                Expanded(
                  child: _QuickActionButton(
                    icon: Icons.bloodtype_rounded,
                    label: 'Urgence Sang',
                    color: AppColors.primary,
                    onTap: () => context.go(AppRoutes.emergencies),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _QuickActionButton(
                    icon: Icons.local_pharmacy_rounded,
                    label: 'Pharmacies de garde',
                    color: AppColors.info,
                    onTap: () => context.go(AppRoutes.pharmacies),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Alertes en cours',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                ),
                TextButton(
                  onPressed: () => context.go(AppRoutes.emergencies),
                  child: const Text('Voir tout'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            requestsAsync.when(
              data: (requests) {
                if (requests.isEmpty) {
                  return const _EmptyFeed();
                }
                final preview = requests.take(_feedPreviewCount);
                return Column(
                  children: [
                    for (final request in preview)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: BloodRequestCard(
                          request: request,
                          onTap: () => context.push(AppRoutes.emergencyDetail(request.id)),
                        ),
                      ),
                  ],
                );
              },
              loading: () => const Padding(
                padding: EdgeInsets.symmetric(vertical: 32),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (error, stackTrace) => _FeedError(
                onRetry: () => ref.invalidate(openBloodRequestsProvider),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(height: 10),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyFeed extends StatelessWidget {
  const _EmptyFeed();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 32),
      child: Center(
        child: Text(
          "Aucune alerte en cours pour l'instant.",
          style: TextStyle(color: AppColors.textSecondary),
        ),
      ),
    );
  }
}

class _FeedError extends StatelessWidget {
  const _FeedError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        children: [
          const Text(
            "Impossible de charger les alertes.",
            style: TextStyle(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 8),
          OutlinedButton(onPressed: onRetry, child: const Text('RÃ©essayer')),
        ],
      ),
    );
  }
}
