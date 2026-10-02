import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart' as latlong;

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_palette.dart';
import '../../data/models/pharmacy.dart';
import '../providers/pharmacy_provider.dart';

/// Centre de repli (Douala) si la position de l'utilisateur est indisponible
/// et qu'aucune pharmacie n'a de coordonnées exploitables.
const _fallbackCenter = latlong.LatLng(4.0511, 9.7679);

class SectorMapPreview extends ConsumerWidget {
  final int onDutyCount;
  final String currentSector;
  final List<Pharmacy> pharmacies;

  const SectorMapPreview({
    super.key,
    required this.onDutyCount,
    required this.pharmacies,
    this.currentSector = 'votre secteur',
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = context.palette;
    final userPosition = ref.watch(userPositionProvider).asData?.value;
    final userLatLng = userPosition != null
        ? latlong.LatLng(userPosition.latitude, userPosition.longitude)
        : null;
    final center =
        userLatLng ??
        (pharmacies.isNotEmpty
            ? latlong.LatLng(
                pharmacies.first.latitude,
                pharmacies.first.longitude,
              )
            : _fallbackCenter);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: palette.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Carte du secteur $currentSector',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: palette.textPrimary,
                ),
              ),
              Text(
                '$onDutyCount de garde actives',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.tealPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: SizedBox(
              height: 180,
              width: double.infinity,
              child: FlutterMap(
                options: MapOptions(
                  initialCenter: center,
                  initialZoom: 13,
                  interactionOptions: const InteractionOptions(
                    flags: InteractiveFlag.pinchZoom | InteractiveFlag.drag,
                  ),
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.vitallink.vitallink',
                  ),
                  MarkerLayer(
                    markers: [
                      for (final pharmacy in pharmacies)
                        if (pharmacy.latitude != 0.0 ||
                            pharmacy.longitude != 0.0)
                          Marker(
                            point: latlong.LatLng(
                              pharmacy.latitude,
                              pharmacy.longitude,
                            ),
                            width: 32,
                            height: 32,
                            child: Icon(
                              Icons.local_pharmacy,
                              color: pharmacy.isOnDuty
                                  ? AppColors.primaryRed
                                  : AppColors.tealPrimary,
                              size: 28,
                            ),
                          ),
                      if (userLatLng != null)
                        Marker(
                          point: userLatLng,
                          width: 22,
                          height: 22,
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppColors.info,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 3),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.2),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                  RichAttributionWidget(
                    attributions: [
                      TextSourceAttribution('© OpenStreetMap contributors'),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
