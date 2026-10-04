import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/widgets/vital_link_logo.dart';
import '../../../pharmacy/data/models/pharmacy.dart';
import '../../../pharmacy/presentation/providers/pharmacy_provider.dart';
import '../../../profile/presentation/providers/profile_providers.dart';
import '../providers/blood_alert_provider.dart';
import '../widgets/blood_alert_card.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  final PageController _carouselController = PageController();
  int _currentCarouselIndex = 0;

  @override
  void dispose() {
    _carouselController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final alertsAsync = ref.watch(bloodAlertsProvider);
    final userProfileAsync = ref.watch(userProfileProvider);
    final profile = userProfileAsync.asData?.value;

    final allPharmacies = ref.watch(filteredPharmaciesProvider);
    final onDutyPharmacies = allPharmacies
        .where((p) => p.isOnDuty)
        .take(2)
        .toList();

    final locationLabel = profile != null && profile.city.isNotEmpty
        ? '${profile.city}, ${profile.country == "Cameroun" ? "CM" : profile.country}'
        : 'Douala, CM';

    return Scaffold(
      backgroundColor: palette.background,
      body: SafeArea(
        child: Column(
          children: [
            // 1. En-tête : Vrai logo VitalLink + Titre/Ville + Cloche notifications
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Row(
                children: [
                  const VitalLinkLogo(size: 42),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'VitalLink',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: palette.textPrimary,
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on,
                              size: 13,
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              locationLabel,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: palette.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.notifications_none_rounded,
                      color: palette.textPrimary,
                      size: 26,
                    ),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Aucune nouvelle notification'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            // 2. Contenu scrollable
            Expanded(
              child: ListView(
                padding: const EdgeInsets.only(bottom: 24),
                children: [
                  // Carrousel dynamique
                  SizedBox(
                    height: 140,
                    child: PageView(
                      controller: _carouselController,
                      onPageChanged: (index) {
                        setState(() => _currentCarouselIndex = index);
                      },
                      children: [
                        _buildCarouselCard(
                          title: 'Sauvez des vies aujourd’hui',
                          subtitle:
                              'Des banques de sang ont un besoin urgent de donneurs compatibles.',
                          badgeText: 'Urgence Vitale',
                          badgeColor: AppColors.primary,
                          gradientColors: const [
                            Color(0xFFB71C1C),
                            Color(0xFFDC2626),
                          ],
                          icon: Icons.water_drop,
                          onTap: () => context.go(AppRoutes.emergencies),
                        ),
                        _buildCarouselCard(
                          title: 'Pharmacies de garde ouvertes',
                          subtitle:
                              'Consultez les officines ouvertes cette nuit dans votre secteur.',
                          badgeText: 'Service 24/7',
                          badgeColor: AppColors.tealPrimary,
                          gradientColors: const [
                            Color(0xFF0F766E),
                            Color(0xFF14B8A6),
                          ],
                          icon: Icons.local_pharmacy_rounded,
                          onTap: () => context.go(AppRoutes.pharmacies),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Indicateurs à points du carrousel
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(2, (index) {
                      final isActive = _currentCarouselIndex == index;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        width: isActive ? 18 : 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: isActive ? AppColors.primary : palette.border,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 14),

                  // 3. Les 4 actions rapides compactes (hauteur et espacement réduits)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        Expanded(
                          child: _QuickActionButton(
                            icon: Icons.water_drop,
                            label: 'Urgences',
                            color: AppColors.primary,
                            onTap: () => context.go(AppRoutes.emergencies),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _QuickActionButton(
                            icon: Icons.local_pharmacy_rounded,
                            label: 'Pharmacies',
                            color: AppColors.tealPrimary,
                            onTap: () => context.go(AppRoutes.pharmacies),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _QuickActionButton(
                            icon: Icons.document_scanner_rounded,
                            label: 'Scanner IA',
                            color: AppColors.darkSlate,
                            onTap: () => context.push(AppRoutes.scan),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _QuickActionButton(
                            icon: Icons.add_alert_rounded,
                            label: 'Alerter',
                            color: AppColors.primaryDark,
                            onTap: () =>
                                context.push(AppRoutes.createEmergency),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),

                  // 4. Section Urgences (max 2)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.circle,
                          size: 8,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Urgences à proximité',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: palette.textPrimary,
                          ),
                        ),
                        const Spacer(),
                        alertsAsync.when(
                          data: (alerts) => GestureDetector(
                            onTap: () => context.go(AppRoutes.emergencies),
                            child: Text(
                              'Voir tout (${alerts.length})',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                          loading: () => const SizedBox.shrink(),
                          error: (_, _) => const SizedBox.shrink(),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),

                  alertsAsync.when(
                    data: (alerts) {
                      if (alerts.isEmpty) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 16,
                            horizontal: 32,
                          ),
                          child: Center(
                            child: Text(
                              'Aucune urgence à proximité pour le moment.',
                              style: TextStyle(color: palette.textSecondary),
                            ),
                          ),
                        );
                      }
                      final displayedAlerts = alerts.take(2).toList();
                      return Column(
                        children: [
                          for (final alert in displayedAlerts)
                            BloodAlertCard(
                              alert: alert,
                              onTap: () => context.push(
                                AppRoutes.emergencyDetail(alert.id),
                              ),
                            ),
                        ],
                      );
                    },
                    loading: () => const Padding(
                      padding: EdgeInsets.all(24),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                    error: (error, _) => Padding(
                      padding: const EdgeInsets.all(24),
                      child: Center(
                        child: Text(
                          'Erreur de chargement des alertes : $error',
                          style: TextStyle(color: palette.textSecondary),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 18),

                  // 5. Section Pharmacies de garde (max 2)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.circle,
                          size: 8,
                          color: AppColors.tealPrimary,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Pharmacies de garde',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: palette.textPrimary,
                          ),
                        ),
                        const Spacer(),
                        GestureDetector(
                          onTap: () => context.go(AppRoutes.pharmacies),
                          child: Text(
                            'Voir tout (${allPharmacies.where((p) => p.isOnDuty).length})',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.tealPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),

                  if (onDutyPharmacies.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 16,
                        horizontal: 32,
                      ),
                      child: Center(
                        child: Text(
                          'Aucune officine de garde détectée.',
                          style: TextStyle(color: palette.textSecondary),
                        ),
                      ),
                    )
                  else
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        children: [
                          for (final pharmacy in onDutyPharmacies)
                            _buildDashboardPharmacyTile(
                              pharmacy: pharmacy,
                              palette: palette,
                              onTap: () => context.go(AppRoutes.pharmacies),
                            ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardPharmacyTile({
    required Pharmacy pharmacy,
    required AppPalette palette,
    required VoidCallback onTap,
  }) {
    final distanceText = pharmacy.distanceInMeters != null
        ? '${(pharmacy.distanceInMeters! / 1000).toStringAsFixed(1)} km'
        : null;

    final locationText = pharmacy.neighborhood.isNotEmpty
        ? pharmacy.neighborhood
        : pharmacy.address;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: palette.border),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
        onTap: onTap,
        leading: CircleAvatar(
          radius: 18,
          backgroundColor: AppColors.tealLight,
          child: const Icon(
            Icons.local_pharmacy_rounded,
            color: AppColors.tealPrimary,
            size: 18,
          ),
        ),
        title: Text(
          pharmacy.name,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: palette.textPrimary,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          locationText,
          style: TextStyle(fontSize: 12, color: palette.textSecondary),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.tealLight,
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text(
                'De garde',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: AppColors.tealPrimary,
                ),
              ),
            ),
            if (distanceText != null) ...[
              const SizedBox(height: 2),
              Text(
                distanceText,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: palette.textSecondary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCarouselCard({
    required String title,
    required String subtitle,
    required String badgeText,
    required Color badgeColor,
    required List<Color> gradientColors,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: gradientColors.first.withValues(alpha: 0.25),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      badgeText,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: const TextStyle(color: Colors.white70, fontSize: 11),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.18),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Colors.white, size: 26),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: Colors.white, size: 16),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: color,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
