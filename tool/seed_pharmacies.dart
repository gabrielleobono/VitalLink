// ignore_for_file: avoid_print
// Script ponctuel : peuple la collection `pharmacies` (vide en prod).
// Necessite une regle `allow create` temporairement assouplie sur
// `pharmacies` (voir firestore.rules) - a lancer puis resecuriser aussitot.

import 'package:flutter/widgets.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vitallink/firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final firestore = FirebaseFirestore.instance;

  final pharmacies = [
    {
      'name': 'Pharmacie du Centre',
      'address': 'Boulevard de la Liberté, Akwa',
      'neighborhood': 'Akwa, Douala',
      'phoneNumber': '+237699001122',
      'latitude': 4.0505,
      'longitude': 9.7042,
      'isOnDuty': true,
      'dutySchedule': 'Garde 24h/24 cette semaine',
      'isVerified': true,
      'services': ['Garde de nuit', 'Urgences', 'Conseil'],
      'availableMedicines': <String>[],
    },
    {
      'name': 'Pharmacie des Palmiers',
      'address': 'Rue Joss, Bonanjo',
      'neighborhood': 'Bonanjo, Douala',
      'phoneNumber': '+237677334455',
      'latitude': 4.0431,
      'longitude': 9.6912,
      'isOnDuty': true,
      'dutySchedule': 'De garde jusqu\'à lundi 08h',
      'isVerified': true,
      'services': ['Garde', 'Oxygène', 'Premiers soins'],
      'availableMedicines': <String>[],
    },
    {
      'name': 'Pharmacie de Deïdo',
      'address': 'Rond-point Deïdo',
      'neighborhood': 'Deïdo, Douala',
      'phoneNumber': '+237699556677',
      'latitude': 4.0620,
      'longitude': 9.7150,
      'isOnDuty': false,
      'dutySchedule': 'Fermée (reprise demain 08h)',
      'isVerified': true,
      'services': ['Standard'],
      'availableMedicines': <String>[],
    },
    {
      'name': 'Pharmacie de Bonamoussadi',
      'address': 'Carrefour Denver',
      'neighborhood': 'Bonamoussadi, Douala',
      'phoneNumber': '+237670112233',
      'latitude': 4.0845,
      'longitude': 9.7380,
      'isOnDuty': true,
      'dutySchedule': 'Garde continue ce week-end',
      'isVerified': true,
      'services': ['Garde 24h', 'Dépannage ordonnance'],
      'availableMedicines': <String>[],
    },
    {
      'name': 'Pharmacie Bastos',
      'address': 'Avenue Winston Churchill',
      'neighborhood': 'Bastos, Yaoundé',
      'phoneNumber': '+237691223344',
      'latitude': 3.8821,
      'longitude': 11.5135,
      'isOnDuty': true,
      'dutySchedule': 'Garde de nuit permanente',
      'isVerified': true,
      'services': ['Urgences 24h/24', 'Vaccination'],
      'availableMedicines': <String>[],
    },
  ];

  final col = firestore.collection('pharmacies');
  for (final ph in pharmacies) {
    final doc = await col.add(ph);
    print('Ajoutée : ${ph['name']} (${doc.id})');
  }
  print('Terminé : ${pharmacies.length} pharmacies ajoutées.');
}
