import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/blood_request_enums.dart';

/// Couleur associée à un niveau d'urgence, utilisée par [UrgencyChip] et
/// ailleurs (ex. l'écran Détail) pour rester visuellement cohérent.
Color urgencyColorFor(UrgencyLevel urgency) => switch (urgency) {
  UrgencyLevel.critical => AppColors.primary,
  UrgencyLevel.high => AppColors.warning,
  UrgencyLevel.moderate => AppColors.info,
};

/// Pastille colorée du niveau d'urgence ("Critique", "Urgent", "Modéré").
class UrgencyChip extends StatelessWidget {
  const UrgencyChip({super.key, required this.urgency});

  final UrgencyLevel urgency;

  @override
  Widget build(BuildContext context) {
    final color = urgencyColorFor(urgency);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        urgency.label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

/// Badge « Alerte Médicale Vérifiée » (vert) / « Alerte Citoyenne » (orange),
/// décidé en équipe le 24/09 pour ne jamais laisser croire qu'une alerte
/// citoyenne est validée par un hôpital.
class VerificationBadge extends StatelessWidget {
  const VerificationBadge({super.key, required this.isVerified});

  final bool isVerified;

  @override
  Widget build(BuildContext context) {
    final color = isVerified ? AppColors.success : AppColors.warning;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          isVerified ? Icons.verified_rounded : Icons.info_outline_rounded,
          size: 14,
          color: color,
        ),
        const SizedBox(width: 4),
        Text(
          isVerified ? 'Alerte médicale vérifiée' : 'Alerte citoyenne',
          style: TextStyle(
            color: color,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
