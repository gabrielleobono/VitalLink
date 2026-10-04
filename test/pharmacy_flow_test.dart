import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vitallink/features/pharmacy/presentation/screens/pharmacy_list_screen.dart';

void main() {
  group('Pharmacy Flow & Screen Interaction Tests', () {
    testWidgets('Affichage initial et presence des elements cles de l ecran', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: PharmacyListScreen())),
      );

      await tester.pumpAndSettle();

      // Verifie les filtres rapides
      expect(find.textContaining('Toutes'), findsOneWidget);
      expect(find.textContaining('De garde uniquement'), findsOneWidget);

      // Verifie la presence du banner IA en bas
      expect(find.textContaining('Scanner une ordonnance'), findsOneWidget);

      // Verifie la presence du champ de recherche
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('Filtrage interactif par le bouton de garde', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: PharmacyListScreen())),
      );

      await tester.pumpAndSettle();

      // Clique sur le bouton de filtre de garde
      final dutyFilterButton = find.textContaining('De garde uniquement');
      expect(dutyFilterButton, findsOneWidget);
      await tester.tap(dutyFilterButton);
      await tester.pumpAndSettle();

      // Verifie que le filtre est bien applique sans crash
      expect(find.byType(PharmacyListScreen), findsOneWidget);
    });

    testWidgets(
      'Recherche interactive par saisie textuelle dans le TextField',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          const ProviderScope(child: MaterialApp(home: PharmacyListScreen())),
        );

        await tester.pumpAndSettle();

        // Saisie d un texte de recherche
        final searchField = find.byType(TextField);
        await tester.enterText(searchField, 'Camp Guezo');
        await tester.pumpAndSettle();

        // Verifie que le texte est bien dans le champ
        expect(find.text('Camp Guezo'), findsOneWidget);
      },
    );
  });
}
