// ignore_for_file: avoid_print

import 'package:flutter/widgets.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vitallink/firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final firestore = FirebaseFirestore.instance;
  final now = DateTime.now();

  print('⏳ Démarrage du peuplement Firestore (Module 6)...');
  final batch = firestore.batch();

  // 1. HÔPITAUX DE RÉFÉRENCE (Collection hospitals/{id} - champs snake_case)
  final hospitals = [
    {
      'id': 'hosp_hgd_douala',
      'name': 'Hôpital Général de Douala',
      'city': 'Douala',
      'address': 'Logbessou',
      'latitude': 4.0612,
      'longitude': 9.7523,
      'emergency_phone': '+237233320202',
    },
    {
      'id': 'hosp_laquintinie',
      'name': 'Hôpital Laquintinie',
      'city': 'Douala',
      'address': 'Akwa',
      'latitude': 4.0536,
      'longitude': 9.7078,
      'emergency_phone': '+237233421540',
    },
    {
      'id': 'hosp_hg_yaounde',
      'name': 'Hôpital Général de Yaoundé',
      'city': 'Yaoundé',
      'address': 'Ngousso',
      'latitude': 3.8967,
      'longitude': 11.5432,
      'emergency_phone': '+237222212018',
    },
    {
      'id': 'hosp_chu_yaounde',
      'name': 'Centre Hospitalier Universitaire (CHU)',
      'city': 'Yaoundé',
      'address': 'Melen',
      'latitude': 3.8643,
      'longitude': 11.4987,
      'emergency_phone': '+237222231260',
    },
  ];

  final hospitalsCol = firestore.collection('hospitals');
  for (final hosp in hospitals) {
    final id = hosp['id'] as String;
    final data = Map<String, dynamic>.from(hosp)..remove('id');
    batch.set(hospitalsCol.doc(id), data);
  }
  print('✅ 4 hôpitaux enregistrés');

  // 2. PHARMACIES DE GARDE (Collection pharmacies/{id} - camelCase)
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

  final pharmaciesCol = firestore.collection('pharmacies');
  for (final ph in pharmacies) {
    batch.set(pharmaciesCol.doc(), ph);
  }
  print('✅ 5 pharmacies enregistrées');

  // 3. ALERTES SANG POUR L'ACCUEIL (Collection bloodAlerts/{id})
  final bloodAlertsCol = firestore.collection('bloodAlerts');

  batch.set(bloodAlertsCol.doc('demo_alert_o_negative'), {
    'recipientBloodGroup': 'O-',
    'compatibleGroups': ['O-'],
    'units': 2,
    'criticality': 'urgent',
    'hospitalId': 'hosp_hgd_douala',
    'hospitalName': 'Hôpital Général de Douala',
    'serviceInfo': 'Maternité / Réanimation',
    'district': 'Logbessou, Douala',
    'distanceKm': 2.4,
    'status': 'open',
    'createdAt': Timestamp.fromDate(now.subtract(const Duration(minutes: 25))),
    'expiresAt': Timestamp.fromDate(now.add(const Duration(hours: 12))),
    'alertBadgeLabel': 'Citoyen vérifié',
    'alertBadgeVariant': 'citizen',
    'bloodGroupTagLabel': 'Urgent O-',
    'ctaSubtitleText': '2 poches requises avant 20h',
  });

  batch.set(bloodAlertsCol.doc('demo_alert_a_positive'), {
    'recipientBloodGroup': 'A+',
    'compatibleGroups': ['A+', 'A-', 'O+', 'O-'],
    'units': 3,
    'criticality': 'high',
    'hospitalId': 'hosp_laquintinie',
    'hospitalName': 'Hôpital Laquintinie',
    'serviceInfo': 'Chirurgie pédiatrique',
    'district': 'Akwa, Douala',
    'distanceKm': 4.1,
    'status': 'open',
    'createdAt': Timestamp.fromDate(now.subtract(const Duration(hours: 2))),
    'expiresAt': Timestamp.fromDate(now.add(const Duration(hours: 24))),
    'alertBadgeLabel': 'Citoyen',
    'alertBadgeVariant': 'citizen',
    'bloodGroupTagLabel': 'Besoin A+',
    'ctaSubtitleText': 'Intervention programmée demain matin',
  });
  print('✅ 2 alertes sang enregistrées');

  await batch.commit();
  print(
    '🎉 Module 6 terminé : base Firestore prête pour les tests et la démo !',
  );
}
