import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../data/models/blood_request_model.dart';
import '../../../../core/utils/blood_compatibility.dart';
import '../../domain/blood_request_enums.dart';

/// Carte d'alerte dans le fil : uniquement des champs publics (groupe, ville,
/// hôpital, urgence, badge). Jamais de nom de patient ni de contact.
class BloodRequestCard extends StatelessWidget {
  const BloodRequestCard({
    super.key,
    required this.request,
    this.onTap,
  });

  final BloodRequestModel request;
  final VoidCallback? onTap;

  Color get _urgencyColor => switch (request.urgency) {
        UrgencyLevel.critical => AppColors.primary,
        UrgencyLevel.high => AppColors.warning,
        UrgencyLevel.moderate => AppColors.info,
      };

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _BloodGroupBadge(label: request.bloodGroupNeeded.label),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            request.hospitalDepartment != null
                                ? '${request.city} · ${request.hospitalDepartment}'
                                : request.city,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        _UrgencyChip(
                          label: request.urgency.label,
                          color: _urgencyColor,
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${request.unitsRemaining} poche(s) encore recherchée(s)',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _VerificationBadge(isVerified: request.isMedicallyVerified),
                  ],
                ),
              ),
            ],
          ),
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
      width: 52,
      height: 52,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: AppColors.primary,
          fontWeight: FontWeight.w700,
          fontSize: 16,
        ),
      ),
    );
  }
}

class _UrgencyChip extends StatelessWidget {
  const _UrgencyChip({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
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
class _VerificationBadge extends StatelessWidget {
  const _VerificationBadge({required this.isVerified});

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
          style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
