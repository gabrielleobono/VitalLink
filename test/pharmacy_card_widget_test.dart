import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vitallink/features/pharmacy/data/models/pharmacy.dart';
import 'package:vitallink/features/pharmacy/presentation/widgets/pharmacy_card.dart';

void main() {
  group('PharmacyCard Widget Tests', () {
    testWidgets(
      'Affiche le nom, l adresse et le badge DE GARDE CE SOIR quand isOnDuty est true',
      (WidgetTester tester) async {
        const pharmacy = Pharmacy(
          id: 'test_1',
          name: 'Pharmacie Centrale',
          address: 'Rue des Palmiers, Cotonou',
          neighborhood: 'Cadjehoun',
          phoneNumber: '+229 97 00 00 00',
          latitude: 6.36,
          longitude: 2.42,
          isOnDuty: true,
          dutySchedule: '24h/24',
          isVerified: true,
          distanceInMeters: 400,
        );

        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(body: PharmacyCard(pharmacy: pharmacy)),
          ),
        );

        // Verifie que le nom de la pharmacie est bien affiche
        expect(find.text('Pharmacie Centrale'), findsOneWidget);

        // Verifie que l adresse et la distance sont presentes
        expect(find.text('400 m • Rue des Palmiers, Cotonou'), findsOneWidget);

        // Verifie le badge de garde
        expect(find.text('DE GARDE CE SOIR'), findsOneWidget);

        // Verifie les boutons d action
        expect(find.text('Appeler direct'), findsOneWidget);
        expect(find.textContaining('Maps'), findsOneWidget);
      },
    );

    testWidgets('Affiche les services / specialites proposes', (
      WidgetTester tester,
    ) async {
      const pharmacy = Pharmacy(
        id: 'test_2',
        name: 'Pharmacie Du Boulevard',
        address: 'Avenue Jean Paul II',
        neighborhood: 'Haie Vive',
        phoneNumber: '+229 96 00 00 00',
        latitude: 6.37,
        longitude: 2.41,
        isOnDuty: false,
        dutySchedule: '08h00 - 20h00',
        services: ['Vaccination', 'Livraison 24h'],
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: PharmacyCard(pharmacy: pharmacy)),
        ),
      );

      expect(find.text('Vaccination'), findsOneWidget);
      expect(find.text('Livraison 24h'), findsOneWidget);
      expect(find.text('08h00 - 20h00'), findsOneWidget);
    });
  });
}
