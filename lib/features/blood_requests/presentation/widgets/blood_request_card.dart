import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/blood_compatibility.dart';
import '../../data/models/blood_request_model.dart';
import 'badges.dart';

/// Carte d'alerte dans le fil : uniquement des champs publics (groupe, ville,
/// hôpital, urgence, badge). Jamais de nom de patient ni de contact.
class BloodRequestCard extends StatelessWidget {
  const BloodRequestCard({super.key, required this.request, this.onTap});

  final BloodRequestModel request;
  final VoidCallback? onTap;

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
                        UrgencyChip(urgency: request.urgency),
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
                    VerificationBadge(isVerified: request.isMedicallyVerified),
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
