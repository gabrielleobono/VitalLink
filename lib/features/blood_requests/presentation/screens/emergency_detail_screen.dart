import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/launcher_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/blood_compatibility.dart';
import '../../data/models/blood_request_model.dart';
import '../../data/models/hospital_model.dart';
import '../providers/blood_request_providers.dart';
import '../providers/hospital_providers.dart';
import '../widgets/badges.dart';
import '../widgets/engagement_bottom_sheet.dart';

/// Écran Détail d'une alerte : groupe, poches restantes, hôpital, appel et
/// itinéraire Maps.
///
/// N'affiche et n'appelle jamais le numéro de la famille : seul le numéro
/// institutionnel de l'hôpital ([Hospital.emergencyPhone]) est exposé ici.
class EmergencyDetailScreen extends ConsumerWidget {
  const EmergencyDetailScreen({super.key, required this.requestId});

  final String requestId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final requestAsync = ref.watch(bloodRequestByIdProvider(requestId));

    return Scaffold(
      appBar: AppBar(title: const Text("Détail de l'alerte")),
      body: requestAsync.when(
        data: (request) => _DetailBody(request: request),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => const _CenteredMessage(
          message: "Cette alerte est introuvable ou a été retirée.",
        ),
      ),
    );
  }
}

class _DetailBody extends ConsumerWidget {
  const _DetailBody({required this.request});

  final BloodRequestModel request;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hospitalAsync = ref.watch(hospitalByIdProvider(request.hospitalId));
    final progress = request.unitsNeeded > 0
        ? request.unitsPledged / request.unitsNeeded
        : 0.0;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            _BloodGroupBadge(label: request.bloodGroupNeeded.label),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    request.city,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      UrgencyChip(urgency: request.urgency),
                      VerificationBadge(
                        isVerified: request.isMedicallyVerified,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Poches de sang',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    Text(
                      '${request.unitsPledged}/${request.unitsNeeded}',
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: progress.clamp(0, 1),
                    minHeight: 8,
                    backgroundColor: AppColors.border,
                    valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                  ),
                ),
                if (request.unitsRemaining > 0) ...[
                  const SizedBox(height: 8),
                  Text(
                    '${request.unitsRemaining} poche(s) encore recherchée(s)',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ],
                if (request.isOpen && !request.isFullyPledged) ...[
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        final confirmed = await showEngagementBottomSheet(
                          context,
                          requestId: request.id,
                        );
                        if (confirmed == true && context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Engagement enregistré, merci !'),
                            ),
                          );
                        }
                      },
                      icon: const Icon(
                        Icons.volunteer_activism_rounded,
                        size: 18,
                      ),
                      label: const Text('Je viens donner'),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        if (request.notes case final notes? when notes.isNotEmpty) ...[
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Notes',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    notes,
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
          ),
        ],
        const SizedBox(height: 16),
        hospitalAsync.when(
          data: (hospital) => _HospitalCard(
            hospital: hospital,
            department: request.hospitalDepartment,
          ),
          loading: () => const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            ),
          ),
          error: (error, stackTrace) => const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                "Informations de l'hôpital indisponibles pour le moment.",
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _HospitalCard extends StatelessWidget {
  const _HospitalCard({required this.hospital, required this.department});

  final HospitalModel hospital;
  final String? department;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.local_hospital_rounded,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    department != null
                        ? '${hospital.name} · $department'
                        : hospital.name,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              '${hospital.address}, ${hospital.city}',
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () =>
                        LauncherService.callPhone(hospital.emergencyPhone),
                    icon: const Icon(Icons.call_rounded, size: 18),
                    label: const Text('Appeler'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => LauncherService.openMapsDirections(
                      latitude: hospital.latitude,
                      longitude: hospital.longitude,
                    ),
                    icon: const Icon(Icons.directions_rounded, size: 18),
                    label: const Text('Itinéraire'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _BloodGroupBadge extends StatelessWidget {
  const _BloodGroupBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56,
      height: 56,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: AppColors.primary,
          fontWeight: FontWeight.w700,
          fontSize: 18,
        ),
      ),
    );
  }
}

class _CenteredMessage extends StatelessWidget {
  const _CenteredMessage({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(color: AppColors.textSecondary),
        ),
      ),
    );
  }
}
