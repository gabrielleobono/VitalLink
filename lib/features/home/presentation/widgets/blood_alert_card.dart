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

  /// Calcule la distance affichée (dynamique via GPS ou repli statique)
  String _buildDistanceLabel(double? calculatedKm) {
    final km = calculatedKm ?? (alert.distanceKm > 0 ? alert.distanceKm : null);
    if (km != null && km > 0) {
      return 'À ${km.toStringAsFixed(1)} km • ${alert.district}';
    }
    return alert.district.isNotEmpty ? alert.district : 'À proximité';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = context.palette;
    final badgeColor = _isVerified ? AppColors.tealPrimary : AppColors.info;
    final badgeBg = _isVerified ? AppColors.tealLight : AppColors.softBlue;

    // Calcul dynamique de la distance si l'hôpital et la position sont connus
    final userPosAsync = ref.watch(userPositionProvider);
    final hospitalAsync = ref.watch(hospitalProvider(alert.hospitalId));

    double? dynamicDistanceKm;
    final userPos = userPosAsync.asData?.value;
    final hospital = hospitalAsync.asData?.value;

    if (userPos != null && hospital != null) {
      dynamicDistanceKm = LocationService.distanceInKm(
        startLatitude: userPos.latitude,
        startLongitude: userPos.longitude,
        endLatitude: hospital.location.latitude,
        endLongitude: hospital.location.longitude,
      );
    }

    // Couleurs vives et contrastées adaptées au thème sombre
    final tagColor = switch (alert.criticality) {
      'critical' => AppColors.primaryRed,
      'high' => const Color(0xFFD97706), // Ambre vif
      _ => const Color(0xFFDC2626),
    };

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: palette.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: palette.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: badgeBg,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    alert.alertBadgeLabel,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: badgeColor,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  alert.relativeCreatedAt,
                  style: TextStyle(fontSize: 11, color: palette.textSecondary),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Badge du groupe sanguin
                Container(
                  width: 52,
                  height: 52,
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: tagColor,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: tagColor.withValues(alpha: 0.3),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
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
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          height: 1.1,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _bottomTagLabel,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.4,
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
                        style: TextStyle(
                          fontSize: 12,
                          color: palette.textSecondary,
                        ),
                      ),
                      Text(
                        _buildDistanceLabel(dynamicDistanceKm),
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
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Text(
                    alert.ctaSubtitleText,
                    style: TextStyle(
                      fontSize: 12,
                      color: palette.textSecondary,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: onTap,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    minimumSize: Size.zero,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    elevation: 0,
                    textStyle: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  child: const Text('Je viens donner'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
