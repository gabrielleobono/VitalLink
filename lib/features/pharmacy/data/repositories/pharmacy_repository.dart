import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/pharmacy.dart';

class PharmacyRepository {
  final FirebaseFirestore _firestore;

  PharmacyRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  static const List<Pharmacy> fallbackPharmacies = [
    Pharmacy(
      id: 'ph_centre',
      name: 'Pharmacie du Centre',
      address: 'Rue Joss, Bonanjo',
      neighborhood: 'Bonanjo',
      phoneNumber: '+237699001122',
      latitude: 4.0483,
      longitude: 9.7043,
      isOnDuty: true,
      dutySchedule: "Permanence ouverte jusqu'à 08h00 demain matin",
      isVerified: true,
      services: ['Vaccinations', 'Paiement Mobile', 'Urgences 24h'],
      availableMedicines: [
        'Amoxicilline 500mg',
        'Paracétamol',
        'Ibuprofène',
        'Arteméther',
      ],
    ),
    Pharmacy(
      id: 'ph_palmiers',
      name: 'Pharmacie des Palmiers',
      address: 'Bd de la Liberté, Akwa',
      neighborhood: 'Akwa',
      phoneNumber: '+237677889900',
      latitude: 4.0510,
      longitude: 9.7080,
      isOnDuty: false,
      dutySchedule: 'Ouverte (ferme à 20h00)',
      isVerified: true,
      services: ['Vaccinations', 'Paiement Mobile', 'Livraison Express'],
      availableMedicines: ['Paracétamol', 'Vitamine C', 'Ciprofloxacine'],
    ),
    Pharmacy(
      id: 'ph_akwa',
      name: 'Pharmacie de la Liberté',
      address: 'Avenue des Cocotiers, Akwa',
      neighborhood: 'Akwa',
      phoneNumber: '+237690123456',
      latitude: 4.0535,
      longitude: 9.7065,
      isOnDuty: true,
      dutySchedule: 'Permanence de garde active',
      isVerified: true,
      services: ['Paiement Mobile', 'Conseil Médical'],
      availableMedicines: [
        'Amoxicilline 500mg',
        'Paracétamol 1g',
        'Azithromycine',
      ],
    ),
    Pharmacy(
      id: 'ph_deido',
      name: 'Pharmacie Principale',
      address: 'Rue Manga Bell, Douala',
      neighborhood: 'Deido',
      phoneNumber: '+237670987654',
      latitude: 4.0620,
      longitude: 9.7120,
      isOnDuty: false,
      dutySchedule: 'Ferme à 21h30',
      isVerified: true,
      services: ['Livraison Express'],
      availableMedicines: ['Ibuprofène', 'Oméprazole'],
    ),
  ];

  Stream<List<Pharmacy>> watchPharmacies() {
    try {
      return _firestore
          .collection('pharmacies')
          .snapshots(includeMetadataChanges: true)
          .map((snapshot) {
            if (snapshot.docs.isEmpty) {
              return fallbackPharmacies;
            }
            return snapshot.docs
                .map((doc) => Pharmacy.fromMap(doc.data(), doc.id))
                .toList();
          })
          .handleError((_) => fallbackPharmacies);
    } catch (_) {
      return Stream.value(fallbackPharmacies);
    }
  }

  Future<List<Pharmacy>> getPharmacies() async {
    try {
      final snapshot = await _firestore
          .collection('pharmacies')
          .get(const GetOptions(source: Source.serverAndCache));

      if (snapshot.docs.isEmpty) {
        return fallbackPharmacies;
      }

      return snapshot.docs
          .map((doc) => Pharmacy.fromMap(doc.data(), doc.id))
          .toList();
    } catch (_) {
      return fallbackPharmacies;
    }
  }
}
