import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_palette.dart';
import '../../data/models/donor_profile.dart';
import '../../domain/entities/user_profile.dart';
import '../providers/profile_providers.dart';

/// Écran "Mon Profil" : identité, bascule "Prêt à donner" et raccourcis,
/// alimenté en temps réel par Firestore (`users/{uid}`, `donors/{uid}`).
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  void _showComingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('$feature bientôt disponible.')));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = context.palette;
    final userAsync = ref.watch(userProfileProvider);
    final donorAsync = ref.watch(donorProfileProvider);
    final alertsCountAsync = ref.watch(myAlertsCountProvider);

    return Scaffold(
      backgroundColor: palette.background,
      body: SafeArea(
        child: userAsync.when(
          data: (user) => user == null
              ? _NoProfilePrompt(
                  onCreateProfile: () {
                    // Un invité doit d'abord vérifier son numéro (OTP).
                    resetSession();
                    context.push(AppRoutes.login);
                  },
                )
              : _ProfileBody(
                  user: user,
                  donor: donorAsync.value,
                  alertsCount: alertsCountAsync.value ?? 0,
                  onComingSoon: (feature) => _showComingSoon(context, feature),
                ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Text(
                'Erreur de chargement du profil : $error',
                style: TextStyle(color: palette.textSecondary),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ProfileBody extends ConsumerWidget {
  const _ProfileBody({
    required this.user,
    required this.donor,
    required this.alertsCount,
    required this.onComingSoon,
  });

  final UserProfile? user;
  final DonorProfile? donor;
  final int alertsCount;
  final void Function(String feature) onComingSoon;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = context.palette;
    final isAvailable = donor?.available ?? false;
    final donationsCount = donor?.lastDonationAt != null ? 1 : 0;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      children: [
        Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.water_drop,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              'Mon Profil',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: palette.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _Card(
          child: Row(
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: palette.border,
                child: Icon(
                  Icons.person,
                  color: palette.textSecondary,
                  size: 28,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user?.displayName ?? 'Utilisateur VitalLink',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: palette.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        if (user?.phone.isNotEmpty ?? false)
                          Text(
                            user!.phone,
                            style: TextStyle(
                              fontSize: 12,
                              color: palette.textSecondary,
                            ),
                          ),
                        if (user?.verified ?? false) ...[
                          const SizedBox(width: 6),
                          _VerifiedBadge(),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 14,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          [
                            user?.city,
                            user?.country,
                          ].where((s) => s != null && s.isNotEmpty).join(', '),
                          style: TextStyle(
                            fontSize: 12,
                            color: palette.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Engagement Donneur',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: palette.textPrimary,
                      ),
                    ),
                  ),
                  Switch(
                    value: isAvailable,
                    activeThumbColor: AppColors.success,
                    onChanged: (value) => ref
                        .read(donorAvailabilityControllerProvider)
                        .setAvailable(value)
                        .catchError((_) {
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                "Impossible de mettre à jour : vérifiez votre connexion.",
                              ),
                            ),
                          );
                        }),
                  ),
                ],
              ),
              Text(
                isAvailable
                    ? "Disponible pour les urgences vitales à ${user?.city ?? 'proximité'}"
                    : 'Activez pour être notifié des urgences compatibles',
                style: TextStyle(fontSize: 12, color: palette.textSecondary),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.softBlue,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.water_drop,
                            size: 12,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            donor != null && donor!.bloodGroup.isNotEmpty
                                ? 'Groupe ${donor!.bloodGroup}'
                                : 'Groupe non renseigné',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            donor?.eligibilityLabel ?? 'Éligible au don',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppColors.success,
                            ),
                          ),
                          Text(
                            donor?.lastDonationLabel ?? 'Aucun don enregistré',
                            style: TextStyle(
                              fontSize: 11,
                              color: palette.textSecondary,
                            ),
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
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _StatCard(
                value: '$donationsCount',
                label: 'Dons effectués',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                value: '$alertsCount',
                label: 'Alertes publiées',
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _Card(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              _ProfileListTile(
                icon: Icons.menu_book_outlined,
                label: 'Guide du donneur',
                onTap: () => context.push(AppRoutes.donorGuide),
              ),
              Divider(height: 1, color: palette.border),
              _ProfileListTile(
                icon: Icons.calendar_today_outlined,
                label: 'Mes alertes et engagements',
                trailing: alertsCount > 0 ? '$alertsCount en cours' : null,
                onTap: () => context.push(AppRoutes.myAlerts),
              ),
              Divider(height: 1, color: palette.border),
              _ProfileListTile(
                icon: Icons.notifications_none,
                label: 'Notifications et urgences',
                onTap: () => context.go(AppRoutes.emergencies),
              ),
              Divider(height: 1, color: palette.border),
              _ProfileListTile(
                icon: Icons.info_outline,
                label: 'À propos & Conditions',
                onTap: () => onComingSoon('À propos & Conditions'),
              ),
              Divider(height: 1, color: palette.border),
              _ProfileListTile(
                icon: Icons.logout,
                label: 'Se déconnecter',
                labelColor: AppColors.primary,
                iconColor: AppColors.primary,
                onTap: () async {
                  await ref.read(phoneAuthControllerProvider).signOut();
                  resetSession();
                  if (context.mounted) context.go(AppRoutes.login);
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _NoProfilePrompt extends StatelessWidget {
  const _NoProfilePrompt({required this.onCreateProfile});

  final VoidCallback onCreateProfile;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.person_outline, size: 48, color: palette.textSecondary),
            const SizedBox(height: 12),
            Text(
              'Vous naviguez en mode invité',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: palette.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              "Créez votre profil pour gérer votre engagement donneur et suivre vos dons.",
              style: TextStyle(fontSize: 13, color: palette.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onCreateProfile,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
              ),
              child: const Text('Créer mon profil'),
            ),
          ],
        ),
      ),
    );
  }
}

class _VerifiedBadge extends StatelessWidget {
  const _VerifiedBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.tealLight,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check_circle, size: 11, color: AppColors.success),
          const SizedBox(width: 3),
          Text(
            'Vérifié',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: AppColors.success,
            ),
          ),
        ],
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.child, this.padding = const EdgeInsets.all(14)});

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: palette.border),
      ),
      // Material requis pour les ink splashes des ListTile internes.
      child: Material(color: Colors.transparent, child: child),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return _Card(
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: palette.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(fontSize: 12, color: palette.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _ProfileListTile extends StatelessWidget {
  const _ProfileListTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.trailing,
    this.labelColor,
    this.iconColor,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final String? trailing;
  final Color? labelColor;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return ListTile(
      onTap: onTap,
      leading: CircleAvatar(
        radius: 18,
        backgroundColor: AppColors.softBlue,
        child: Icon(icon, size: 18, color: iconColor ?? AppColors.info),
      ),
      title: Text(
        label,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: labelColor ?? palette.textPrimary,
        ),
      ),
      trailing: trailing != null
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.softBlue,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                trailing!,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.info,
                ),
              ),
            )
          : Icon(Icons.chevron_right, color: palette.textSecondary),
    );
  }
}
