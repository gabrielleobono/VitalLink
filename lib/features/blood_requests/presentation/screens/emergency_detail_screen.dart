import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/launcher_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../home/data/models/blood_alert.dart';
import '../../../home/presentation/providers/blood_alert_provider.dart';
import '../providers/hospital_provider.dart';
import '../widgets/confirm_donation_sheet.dart';

/// Écran "Détails de l'urgence" — ouvert depuis une carte d'alerte du Home.
class EmergencyDetailScreen extends ConsumerWidget {
  const EmergencyDetailScreen({super.key, required this.alertId});

  final String alertId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = context.palette;
    final alertAsync = ref.watch(bloodAlertByIdProvider(alertId));

    return Scaffold(
      backgroundColor: palette.background,
      appBar: AppBar(
        backgroundColor: palette.surface,
        elevation: 0,
        title: Text(
          "Détails de l'urgence",
          style: TextStyle(
            color: palette.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.share_outlined, color: palette.textPrimary),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Partage bientôt disponible.')),
              );
            },
          ),
        ],
      ),
      body: alertAsync.when(
        data: (alert) {
          if (alert == null) {
            return Center(
              child: Text(
                'Cette alerte n\'existe plus.',
                style: TextStyle(color: palette.textSecondary),
              ),
            );
          }
          return _EmergencyDetailBody(alert: alert);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Text(
            'Erreur de chargement : $error',
            style: TextStyle(color: palette.textSecondary),
          ),
        ),
      ),
    );
  }
}

class _EmergencyDetailBody extends ConsumerWidget {
  const _EmergencyDetailBody({required this.alert});

  final BloodAlert alert;

  static const _requirements = [
    'Âge 18-65 ans',
    'Poids ≥ 50 kg',
    'Dernier don ≥ 90 jours',
    "Carte nationale d'identité",
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = context.palette;
    final hospitalAsync = ref.watch(hospitalProvider(alert.hospitalId));
    final isVerified = alert.alertBadgeVariant == 'verified';
    final headline = alert.criticality == 'critical'
        ? '${alert.units} poche${alert.units > 1 ? 's' : ''} requise${alert.units > 1 ? 's' : ''} en urgence absolue'
        : alert.ctaSubtitleText;
    final shortCode =
        '#VL-${alert.id.length >= 4 ? alert.id.substring(alert.id.length - 4).toUpperCase() : alert.id.toUpperCase()}';

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: palette.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: palette.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.primaryRed,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'GROUPE',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 8,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          alert.recipientBloodGroup,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: isVerified
                                ? AppColors.tealLight
                                : AppColors.softBlue,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            alert.alertBadgeLabel,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: isVerified
                                  ? AppColors.tealPrimary
                                  : AppColors.info,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          headline,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: palette.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${alert.district} • ${alert.distanceKm.toStringAsFixed(1)} km de votre position',
                          style: TextStyle(
                            fontSize: 12,
                            color: palette.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Divider(height: 20),
              Text(
                'Posté ${alert.relativeCreatedAt.toLowerCase()}',
                style: TextStyle(fontSize: 12, color: palette.textSecondary),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        hospitalAsync.when(
          data: (hospital) => Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: palette.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: palette.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  alert.hospitalName,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: palette.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  alert.serviceInfo,
                  style: TextStyle(fontSize: 13, color: palette.textSecondary),
                ),
                if (hospital != null)
                  Text(
                    '${hospital.address} • ${hospital.city}',
                    style: TextStyle(
                      fontSize: 12,
                      color: palette.textSecondary,
                    ),
                  ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: hospital == null
                            ? null
                            : () => LauncherService.callPhone(hospital.phone),
                        icon: const Icon(Icons.call, size: 16),
                        label: const Text("Appeler l'hôpital"),
                        style: OutlinedButton.styleFrom(
                          backgroundColor: AppColors.darkSlate,
                          foregroundColor: Colors.white,
                          side: BorderSide.none,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: hospital == null
                            ? null
                            : () => LauncherService.openMapsDirections(
                                latitude: hospital.location.latitude,
                                longitude: hospital.location.longitude,
                              ),
                        icon: const Icon(Icons.directions, size: 16),
                        label: const Text('Itinéraire Maps'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: palette.textPrimary,
                          side: BorderSide(color: palette.border),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          loading: () => const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (_, _) => const SizedBox.shrink(),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: palette.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: palette.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${alert.units} poche${alert.units > 1 ? 's' : ''} nécessaire${alert.units > 1 ? 's' : ''}',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: palette.textPrimary,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.softBlue.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text.rich(
                  TextSpan(
                    style: TextStyle(fontSize: 12, color: palette.textPrimary),
                    children: [
                      const TextSpan(text: 'Présentez-vous directement à la '),
                      TextSpan(
                        text: alert.hospitalName,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      const TextSpan(text: ' en mentionnant l\'alerte '),
                      TextSpan(
                        text: shortCode,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      const TextSpan(text: ' pour un accueil prioritaire.'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'CONDITIONS REQUISES',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: palette.textSecondary,
                  letterSpacing: 0.4,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _requirements
                    .map(
                      (req) => Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: palette.background,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: palette.border),
                        ),
                        child: Text(
                          req,
                          style: TextStyle(
                            fontSize: 11,
                            color: palette.textSecondary,
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: () {
            final hospital = hospitalAsync.value;
            showConfirmDonationSheet(
              context: context,
              alert: alert,
              hospital: hospital,
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            minimumSize: const Size.fromHeight(52),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            elevation: 0,
          ),
          child: const Text(
            "Je viens donner (M'engager)",
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "Votre engagement informe immédiatement l'équipe médicale de garde.",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 11, color: palette.textSecondary),
        ),
      ],
    );
  }
}
