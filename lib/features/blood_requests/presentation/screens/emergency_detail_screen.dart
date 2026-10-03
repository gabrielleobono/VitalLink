import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/services/launcher_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../home/data/models/blood_alert.dart';
import '../../../home/presentation/providers/blood_alert_provider.dart';
import '../providers/hospital_provider.dart';
import '../widgets/confirm_donation_sheet.dart';

/// Écran "Détails de l'urgence" ouvert depuis une carte d'alerte.
class EmergencyDetailScreen extends ConsumerWidget {
  const EmergencyDetailScreen({super.key, required this.alertId});

  final String alertId;

  void _shareAlert(BuildContext context, BloodAlert alert) {
    final shortCode = alert.id.length > 6
        ? alert.id.substring(0, 6).toUpperCase()
        : alert.id.toUpperCase();

    final text =
        '🚨 URGENCE SANG - VitalLink 🚨\n\n'
        'Besoin urgent de ${alert.units} poche(s) de sang groupe [${alert.recipientBloodGroup}] !\n'
        '🏥 Établissement : ${alert.hospitalName}\n'
        '📍 Quartier / Ville : ${alert.district}\n'
        '🏢 Service : ${alert.serviceInfo}\n'
        '🏷️ Code Alerte : #$shortCode\n\n'
        'Si vous êtes du groupe ${alert.recipientBloodGroup} ou compatible, votre don peut sauver une vie dès maintenant !\n'
        '📲 Ouvrez l\'application VitalLink pour vous engager ou rendez-vous directement à l\'accueil des urgences.';

    // ignore: deprecated_member_use
    Share.share(
      text,
      subject:
          'Urgence Sang ${alert.recipientBloodGroup} - ${alert.hospitalName}',
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = context.palette;
    final alertAsync = ref.watch(bloodAlertByIdProvider(alertId));

    return Scaffold(
      backgroundColor: palette.background,
      appBar: AppBar(
        backgroundColor: palette.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          "Détails de l'urgence",
          style: TextStyle(
            color: palette.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          alertAsync.when(
            data: (alert) => alert != null
                ? IconButton(
                    icon: const Icon(Icons.share_rounded),
                    color: palette.textPrimary,
                    tooltip: 'Partager l\'alerte',
                    onPressed: () => _shareAlert(context, alert),
                  )
                : const SizedBox.shrink(),
            loading: () => const SizedBox.shrink(),
            error: (err, stack) => const SizedBox.shrink(),
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
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primaryRed),
        ),
        error: (error, stack) => Center(
          child: Text(
            'Impossible de charger l\'alerte.',
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
    'Âge : 18 - 60 ans',
    'Poids : minimum 50 kg',
    'Être en bonne santé',
    'Ne pas être à jeun',
    'Bien s\'hydrater',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = context.palette;
    final hospitalAsync = ref.watch(hospitalProvider(alert.hospitalId));
    final shortCode = alert.id.length > 6
        ? alert.id.substring(0, 6).toUpperCase()
        : alert.id.toUpperCase();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: palette.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: palette.border),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFDC2626), Color(0xFF991B1B)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryRed.withValues(alpha: 0.35),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: Text(
                  alert.recipientBloodGroup,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Groupe sanguin requis : ${alert.recipientBloodGroup}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: palette.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Alerte #$shortCode',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: palette.textSecondary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
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
                        icon: const Icon(Icons.call_rounded, size: 16),
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
                        icon: const Icon(Icons.directions_rounded, size: 16),
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
          error: (err, stack) => const SizedBox.shrink(),
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
                  fontSize: 14,
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
                        text: '#$shortCode',
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
        ElevatedButton.icon(
          onPressed: () {
            final hospital = hospitalAsync.value;
            showConfirmDonationSheet(
              context: context,
              alert: alert,
              hospital: hospital,
            );
          },
          icon: const Icon(Icons.volunteer_activism_rounded, size: 18),
          label: const Text(
            "Je viens donner (M'engager)",
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryRed,
            foregroundColor: Colors.white,
            minimumSize: const Size.fromHeight(52),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            elevation: 0,
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
