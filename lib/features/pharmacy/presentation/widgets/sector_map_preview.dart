import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_palette.dart';

class SectorMapPreview extends StatelessWidget {
  final int onDutyCount;
  final String currentSector;

  const SectorMapPreview({
    super.key,
    required this.onDutyCount,
    this.currentSector = 'Akwa',
  });

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
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
          Container(
            height: 140,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: const Color(0xFFE2E8F0),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFFBAE6FD).withValues(alpha: 0.7),
                  const Color(0xFFBBF7D0).withValues(alpha: 0.7),
                ],
              ),
            ),
            child: Stack(
              children: [
                Positioned(
                  top: 20,
                  left: 40,
                  child: _buildPin(Icons.local_pharmacy, AppColors.primaryRed),
                ),
                Positioned(
                  top: 50,
                  right: 60,
                  child: _buildPin(Icons.local_pharmacy, AppColors.primaryRed),
                ),
                Positioned(
                  bottom: 45,
                  left: 120,
                  child: _buildPin(Icons.local_pharmacy, AppColors.tealPrimary),
                ),
                Positioned(
                  bottom: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.my_location,
                          size: 14,
                          color: AppColors.primaryRed,
                        ),
                        SizedBox(width: 6),
                        Text(
                          'Position actuelle: Rue Joss',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPin(IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.4),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Icon(icon, size: 14, color: Colors.white),
    );
  }
}
