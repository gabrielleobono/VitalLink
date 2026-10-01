import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vitallink/core/router/app_router.dart';
import 'package:vitallink/core/theme/app_theme.dart';
import 'package:vitallink/features/home/presentation/screens/dashboard_screen.dart';
import 'package:vitallink/features/home/presentation/widgets/home_shell.dart';
import 'package:vitallink/features/pharmacy/presentation/screens/pharmacy_list_screen.dart';

void main() {
  group('VitalLink Full Application Integration Tests (End-to-End)', () {
    testWidgets(
        'Cycle complet : Lancement app -> Tableau de bord -> Navigation vers Pharmacies -> Filtrage',
        (WidgetTester tester) async {
      // 1. Lancement global de l application avec theme et router
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp.router(
            title: 'VitalLink',
            theme: AppTheme.light(),
            routerConfig: appRouter,
            debugShowCheckedModeBanner: false,
          ),
        ),
      );

      await tester.pumpAndSettle();

      // 2. Verifier qu on est bien sur l ecran d accueil (Dashboard)
      expect(find.byType(HomeShell), findsOneWidget);
      expect(find.byType(DashboardScreen), findsOneWidget);
      expect(find.text('VitalLink'), findsOneWidget);

      // Verifier la presence de la barre inferieure de navigation
      expect(find.byType(BottomNavigationBar), findsOneWidget);

      // 3. Navigation vers l onglet Urgences dans la BottomNavigationBar
      final emergenciesTab = find.descendant(
        of: find.byType(BottomNavigationBar),
        matching: find.text('Urgences'),
      );
      await tester.tap(emergenciesTab);
      await tester.pumpAndSettle();

      // 4. Navigation vers l onglet Pharmacies dans la BottomNavigationBar
      final pharmaciesTab = find.descendant(
        of: find.byType(BottomNavigationBar),
        matching: find.text('Pharmacies'),
      );
      await tester.tap(pharmaciesTab);
      await tester.pumpAndSettle();

      // Verifier qu on est arrive sur l ecran de gestion des pharmacies
      expect(find.byType(PharmacyListScreen), findsOneWidget);
      expect(find.text('Ouverte maintenant'), findsOneWidget);
      expect(find.textContaining('Officine de garde'), findsOneWidget);

      // 5. Interagir avec le filtre des officines de garde
      final dutyFilter = find.textContaining('Officine de garde');
      await tester.tap(dutyFilter);
      await tester.pumpAndSettle();

      // 6. Navigation vers l onglet Profil
      final profileTab = find.descendant(
        of: find.byType(BottomNavigationBar),
        matching: find.text('Profil'),
      );
      await tester.tap(profileTab);
      await tester.pumpAndSettle();

      // 7. Retour sur l Accueil (Dashboard)
      final homeTab = find.descendant(
        of: find.byType(BottomNavigationBar),
        matching: find.text('Accueil'),
      );
      await tester.tap(homeTab);
      await tester.pumpAndSettle();

      expect(find.byType(DashboardScreen), findsOneWidget);
    });

    testWidgets('Raccourci rapide du Dashboard vers le module Pharmacies',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp.router(
            title: 'VitalLink',
            theme: AppTheme.light(),
            routerConfig: appRouter,
            debugShowCheckedModeBanner: false,
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Clic sur le bouton d action rapide "Pharmacies" sur le Dashboard
      final pharmacyCardAction = find.text('Pharmacies');
      expect(pharmacyCardAction, findsWidgets);

      await tester.tap(pharmacyCardAction.first);
      await tester.pumpAndSettle();

      // Verifie qu on atterrit bien sur le module pharmacies
      expect(find.byType(PharmacyListScreen), findsOneWidget);
    });
  });
}
