import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/screens/complete_profile_screen.dart';
import '../../features/auth/presentation/screens/sign_in_screen.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/blood_requests/presentation/screens/create_alert_screen.dart';
import '../../features/blood_requests/presentation/screens/emergency_detail_screen.dart';
import '../../features/blood_requests/presentation/screens/emergency_screen.dart';
import '../../features/donor_guide/presentation/screens/donor_guide_screen.dart';
import '../../features/home/presentation/screens/dashboard_screen.dart';
import '../../features/home/presentation/widgets/home_shell.dart';
import '../../features/pharmacy/presentation/screens/pharmacy_list_screen.dart';
import '../../features/profile/presentation/screens/my_alerts_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/scan_ai/presentation/scan_screen.dart';

/// Chemins de navigation de l'application.
abstract final class AppRoutes {
  static const splash = '/splash';
  static const login = '/login';
  static const completeProfile = '/complete-profile';
  static const home = '/home';
  static const emergencies = '/emergencies';
  static const pharmacies = '/pharmacies';
  static const profile = '/profile';
  static const scan = '/scan';
  static const donorGuide = '/donor-guide';
  static const myAlerts = '/profile/my-alerts';

  static const createEmergency = '/emergencies/new';
  static String emergencyDetail(String alertId) => '/emergencies/$alertId';
}

/// Mémorise, pour la session en cours, qu'un profil `users/{uid}` existe déjà
/// — évite de refaire un aller-retour Firestore à chaque navigation une fois
/// que [appRouter.redirect] l'a confirmé une première fois.
bool _profileConfirmed = false;

/// Mode Invité : accès libre à l'app sans compte ni profil, choisi
/// explicitement sur l'écran de connexion ("Continuer sans compte"). Tant que
/// c'est actif, le `redirect` n'impose plus ni connexion ni inscription.
bool _guestMode = false;

/// À appeler juste après la création réussie du profil (écran "Compléter mon
/// profil") pour que le prochain `redirect` n'essaie pas de rediriger à
/// nouveau.
void markProfileComplete() => _profileConfirmed = true;

/// À appeler quand l'utilisateur choisit "Continuer sans compte".
void enterGuestMode() => _guestMode = true;

/// À appeler lors de la déconnexion pour forcer le prochain `redirect` à
/// renvoyer vers l'écran de connexion.
void resetSession() {
  _profileConfirmed = false;
  _guestMode = false;
}

final appRouter = GoRouter(
  initialLocation: AppRoutes.splash,
  redirect: (context, state) async {
    final location = state.matchedLocation;
    if (_guestMode || location == AppRoutes.login) return null;
    if (location == AppRoutes.splash) return null;
    if (_profileConfirmed || location == AppRoutes.completeProfile) {
      return null;
    }
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return AppRoutes.login;
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      if (doc.exists) {
        _profileConfirmed = true;
        return null;
      }
      return AppRoutes.completeProfile;
    } catch (_) {
      // Auth/Firestore indisponible : ne bloque pas la navigation.
      return null;
    }
  },
  routes: [
    GoRoute(
      path: AppRoutes.splash,
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: AppRoutes.login,
      builder: (context, state) => const SignInScreen(),
    ),
    GoRoute(
      path: AppRoutes.completeProfile,
      builder: (context, state) => const CompleteProfileScreen(),
    ),
    GoRoute(
      path: AppRoutes.scan,
      builder: (context, state) => const ScanScreen(),
    ),
    GoRoute(
      path: AppRoutes.createEmergency,
      builder: (context, state) => const CreateAlertScreen(),
    ),
    GoRoute(
      path: AppRoutes.donorGuide,
      builder: (context, state) => const DonorGuideScreen(),
    ),
    GoRoute(
      path: AppRoutes.myAlerts,
      builder: (context, state) => const MyAlertsScreen(),
    ),
    GoRoute(
      path: '/emergencies/:alertId',
      builder: (context, state) =>
          EmergencyDetailScreen(alertId: state.pathParameters['alertId']!),
    ),
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) =>
          HomeShell(navigationShell: navigationShell),
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.home,
              builder: (context, state) => const DashboardScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.emergencies,
              builder: (context, state) => const EmergencyScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.pharmacies,
              builder: (context, state) => const PharmacyListScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.profile,
              builder: (context, state) => const ProfileScreen(),
            ),
          ],
        ),
      ],
    ),
  ],
);
