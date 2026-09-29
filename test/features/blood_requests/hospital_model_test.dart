import 'package:flutter_test/flutter_test.dart';
import 'package:vitallink/features/blood_requests/data/models/hospital_model.dart';

void main() {
  group('HospitalModel', () {
    test('fromMap lit tous les champs, y compris des coordonnées entières', () {
      final hospital = HospitalModel.fromMap('h1', {
        'name': 'CHU de Brazzaville',
        'city': 'Brazzaville',
        'address': 'Avenue de la Paix',
        // Firestore peut stocker une coordonnée comme int si sa partie
        // décimale est nulle : le modèle doit accepter num, pas seulement double.
        'latitude': -4,
        'longitude': 15,
        'emergency_phone': '+242000000',
      });

      expect(hospital.name, 'CHU de Brazzaville');
      expect(hospital.latitude, -4.0);
      expect(hospital.longitude, 15.0);
      expect(hospital.emergencyPhone, '+242000000');
    });

    test('lève une erreur claire si le document est vide', () {
      expect(() => HospitalModel.fromMap('h1', {}), throwsA(isA<TypeError>()));
    });
  });
}
