import 'package:flutter_test/flutter_test.dart';
import 'package:vitallink/features/pharmacy/data/models/pharmacy.dart';

void main() {
  group('Pharmacy Model Tests', () {
    test('fromMap instancie correctement un modele complet', () {
      final data = {
        'name': 'Pharmacie du Port',
        'address': 'Boulevard Maritime',
        'neighborhood': 'Akpakpa',
        'phoneNumber': '+229 97 00 00 01',
        'latitude': 6.3654,
        'longitude': 2.4354,
        'isOnDuty': true,
        'dutySchedule': '24h/24',
        'isVerified': true,
        'services': ['Vaccination', 'Livraison'],
        'availableMedicines': ['Paracetamol', 'Amoxicilline'],
      };

      final pharmacy = Pharmacy.fromMap(data, 'pharma_1');

      expect(pharmacy.id, 'pharma_1');
      expect(pharmacy.name, 'Pharmacie du Port');
      expect(pharmacy.isOnDuty, isTrue);
      expect(pharmacy.services, contains('Vaccination'));
      expect(pharmacy.availableMedicines, contains('Amoxicilline'));
    });

    test(
      'fromMap gere les valeurs nulles ou manquantes avec des valeurs par defaut',
      () {
        final emptyData = <String, dynamic>{};

        final pharmacy = Pharmacy.fromMap(emptyData, 'pharma_default');

        expect(pharmacy.id, 'pharma_default');
        expect(pharmacy.name, 'Pharmacie');
        expect(pharmacy.address, '');
        expect(pharmacy.latitude, 0.0);
        expect(pharmacy.longitude, 0.0);
        expect(pharmacy.isOnDuty, isFalse);
        expect(pharmacy.isVerified, isTrue);
        expect(pharmacy.services, isEmpty);
        expect(pharmacy.availableMedicines, isEmpty);
      },
    );

    test(
      'toMap convertit correctement le modele en dictionnaire Firestore',
      () {
        const pharmacy = Pharmacy(
          id: 'pharma_2',
          name: 'Grande Pharmacie',
          address: 'Avenue de la Paix',
          neighborhood: 'Cadjehoun',
          phoneNumber: '+229 95 00 00 02',
          latitude: 6.3500,
          longitude: 2.4000,
          isOnDuty: false,
          dutySchedule: '8h - 20h',
        );

        final map = pharmacy.toMap();

        expect(map['name'], 'Grande Pharmacie');
        expect(map['address'], 'Avenue de la Paix');
        expect(map['isOnDuty'], isFalse);
        expect(map['latitude'], 6.3500);
      },
    );

    test(
      'formattedDistance affiche en metres si < 1000m et en km si >= 1000m',
      () {
        const pharmaNear = Pharmacy(
          id: '1',
          name: 'P1',
          address: '',
          neighborhood: '',
          phoneNumber: '',
          latitude: 0,
          longitude: 0,
          isOnDuty: false,
          dutySchedule: '',
          distanceInMeters: 450,
        );

        const pharmaFar = Pharmacy(
          id: '2',
          name: 'P2',
          address: '',
          neighborhood: '',
          phoneNumber: '',
          latitude: 0,
          longitude: 0,
          isOnDuty: false,
          dutySchedule: '',
          distanceInMeters: 2500,
        );

        const pharmaNoDist = Pharmacy(
          id: '3',
          name: 'P3',
          address: '',
          neighborhood: '',
          phoneNumber: '',
          latitude: 0,
          longitude: 0,
          isOnDuty: false,
          dutySchedule: '',
        );

        expect(pharmaNear.formattedDistance, '450 m');
        expect(pharmaFar.formattedDistance, '2.5 km');
        expect(pharmaNoDist.formattedDistance, '');
      },
    );

    test(
      'copyWith permet de mettre a jour la distance GPS sans muter l objet d origine',
      () {
        const original = Pharmacy(
          id: '1',
          name: 'Pharmacie Test',
          address: 'Rue 1',
          neighborhood: 'Zone 1',
          phoneNumber: '01020304',
          latitude: 6.0,
          longitude: 2.0,
          isOnDuty: true,
          dutySchedule: '24h/24',
        );

        final updated = original.copyWith(distanceInMeters: 800);

        expect(original.distanceInMeters, isNull);
        expect(updated.distanceInMeters, 800);
        expect(updated.name, original.name);
        expect(updated.isOnDuty, original.isOnDuty);
      },
    );
  });
}
