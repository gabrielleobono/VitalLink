import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/blood_requests/presentation/screens/emergency_screen.dart';
import '../../features/home/presentation/screens/dashboard_screen.dart';
import '../../features/home/presentation/widgets/home_shell.dart';
import '../../features/pharmacies/presentation/screens/pharmacies_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/scan_ai/presentation/screens/scan_screen.dart';

/// Chemins de navigation de l'application.
abstract final class AppRoutes {
  static const login = '/login';
  static const home = '/home';
  static const emergencies = '/emergencies';
  static const pharmacies = '/pharmacies';
  static const profile = '/profile';
  static const scan = '/scan';
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
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) => HomeShell(navigationShell: navigationShell),
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(path: AppRoutes.home, builder: (context, state) => const DashboardScreen()),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(path: AppRoutes.emergencies, builder: (context, state) => const EmergencyScreen()),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(path: AppRoutes.pharmacies, builder: (context, state) => const PharmaciesScreen()),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(path: AppRoutes.profile, builder: (context, state) => const ProfileScreen()),
          ],
        ),
      ],
    ),
  ],
);
