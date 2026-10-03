import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/location_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../blood_requests/presentation/providers/hospital_provider.dart';
import '../../../pharmacy/presentation/providers/pharmacy_provider.dart';
import '../../data/models/blood_alert.dart';

class BloodAlertCard extends ConsumerWidget {
  const BloodAlertCard({super.key, required this.alert, required this.onTap});
  final BloodAlert alert;
  final VoidCallback onTap;

  bool get _isVerified => alert.alertBadgeVariant == 'verified';

  String get _bottomTagLabel {
    final raw = alert.bloodGroupTagLabel.trim();
    if (raw.isEmpty ||
        raw.toUpperCase() == alert.recipientBloodGroup.toUpperCase()) {
      return switch (alert.criticality) {
        'critical' => 'BLOC',
        'high' => 'URGENT',
        _ => 'FAMILLE',
      };
    }
    final cleaned = raw.replaceAll(alert.recipientBloodGroup, '').trim();
    return cleaned.isNotEmpty ? cleaned.toUpperCase() : 'URGENT';
  }

  String _buildDistanceLabel(double? calculatedKm, String? hospitalCity) {
    final km = calculatedKm ?? (alert.distanceKm > 0 ? alert.distanceKm : null);
    final district = alert.district.isNotEmpty
        ? alert.district
        : (hospitalCity ?? '');

    if (km != null && km > 0) {
      return district.isNotEmpty
          ? 'À ${km.toStringAsFixed(1)} km • $district'
          : 'À ${km.toStringAsFixed(1)} km';
    }
    return district.isNotEmpty ? 'À proximité • $district' : 'À proximité';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = context.palette;
    final badgeColor = _isVerified
        ? AppColors.tealPrimary
        : const Color(0xFF2563EB);
    final badgeBg = _isVerified ? AppColors.tealLight : const Color(0xFFEFF6FF);

    // Résolution GPS et Hôpital
    final userPosAsync = ref.watch(userPositionProvider);
    final hospitalAsync = ref.watch(hospitalProvider(alert.hospitalId));

    final userPos = userPosAsync.asData?.value;
    final hospital = hospitalAsync.asData?.value;

    double? dynamicDistanceKm;
    if (userPos != null && hospital != null) {
      dynamicDistanceKm = LocationService.distanceInKm(
        startLatitude: userPos.latitude,
        startLongitude: userPos.longitude,
        endLatitude: hospital.location.latitude,
        endLongitude: hospital.location.longitude,
      );
    }

    // Nom de l'hôpital : utilise le modèle chargé en priorité, puis le champ alert
    final displayHospitalName = (hospital != null && hospital.name.isNotEmpty)
        ? hospital.name
        : (alert.hospitalName.isNotEmpty ? alert.hospitalName : 'Hôpital');

    final gradientColors = switch (alert.criticality) {
      'critical' => [const Color(0xFFDC2626), const Color(0xFF991B1B)],
      'high' => [const Color(0xFFEA580C), const Color(0xFFC2410C)],
      _ => [const Color(0xFFE11D48), const Color(0xFFBE123C)],
    };

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: palette.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: palette.border, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: badgeBg,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _isVerified
                            ? Icons.verified_user_rounded
                            : Icons.campaign_rounded,
                        size: 13,
                        color: badgeColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        alert.alertBadgeLabel,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: badgeColor,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Row(
                  children: [
                    Icon(
                      Icons.schedule_rounded,
                      size: 13,
                      color: palette.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      alert.relativeCreatedAt,
                      style: TextStyle(
                        fontSize: 11,
                        color: palette.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Badge groupe sanguin
                Container(
                  width: 56,
                  height: 56,
                  padding: const EdgeInsets.symmetric(
                    vertical: 4,
                    horizontal: 2,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: gradientColors,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: gradientColors.first.withValues(alpha: 0.35),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        alert.recipientBloodGroup,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.w900,
                          height: 1.1,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 1,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.22),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          _bottomTagLabel,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 8,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        displayHospitalName,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: palette.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (alert.serviceInfo.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          alert.serviceInfo,
                          style: TextStyle(
                            fontSize: 12,
                            color: palette.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on_rounded,
                            size: 13,
                            color: AppColors.primaryRed,
                          ),
                          const SizedBox(width: 3),
                          Expanded(
                            child: Text(
                              _buildDistanceLabel(
                                dynamicDistanceKm,
                                hospital?.city,
                              ),
                              style: TextStyle(
                                fontSize: 12,
                                color: palette.textSecondary,
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Container(height: 1, color: palette.border.withValues(alpha: 0.6)),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: AppColors.primaryRed.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.water_drop_rounded,
                          size: 13,
                          color: AppColors.primaryRed,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          alert.ctaSubtitleText,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: palette.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: onTap,
                  icon: const Icon(Icons.volunteer_activism_rounded, size: 15),
                  label: const Text('Je viens donner'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryRed,
                    foregroundColor: Colors.white,
                    minimumSize: Size.zero,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 9,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                    textStyle: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
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
