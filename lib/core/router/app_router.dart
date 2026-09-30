import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/blood_requests/presentation/screens/create_alert_screen.dart';
import '../../features/blood_requests/presentation/screens/emergency_detail_screen.dart';
import '../../features/blood_requests/presentation/screens/emergency_screen.dart';
import '../../features/home/presentation/screens/dashboard_screen.dart';
import '../../features/home/presentation/widgets/home_shell.dart';
import '../../features/pharmacies/presentation/screens/pharmacies_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/scan_ai/presentation/scan_screen.dart';

/// Chemins de navigation de l'application.
abstract final class AppRoutes {
  static const login = '/login';
  static const home = '/home';
  static const emergencies = '/emergencies';
  static const pharmacies = '/pharmacies';
  static const profile = '/profile';
  static const scan = '/scan';

  /// Formulaire de publication d'une nouvelle alerte.
  static const createEmergency = '$emergencies/new';

  /// Détail d'une alerte précise (hors bottom nav, avec bouton retour).
  static String emergencyDetail(String requestId) => '$emergencies/$requestId';
}

final appRouter = GoRouter(
  initialLocation: AppRoutes.home,
  routes: [
    GoRoute(
      path: AppRoutes.login,
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: AppRoutes.scan,
      builder: (context, state) => const ScanScreen(),
    ),
    // Route statique déclarée AVANT la route dynamique ':requestId' pour que
    // "/emergencies/new" ne soit jamais capturé comme un id d'alerte.
    GoRoute(
      path: AppRoutes.createEmergency,
      builder: (context, state) => const CreateAlertScreen(),
    ),
    GoRoute(
      path: AppRoutes.emergencyDetail(':requestId'),
      builder: (context, state) =>
          EmergencyDetailScreen(requestId: state.pathParameters['requestId']!),
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
              builder: (context, state) => const PharmaciesScreen(),
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
