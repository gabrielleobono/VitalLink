// ignore_for_file: avoid_print
// Script ponctuel : crée 5 alertes de test (une par région du Cameroun)
// pour vérifier le filtrage géographique de `bloodAlertsProvider`.
// Utilise le compte déjà connecté sur l'appareil (Firebase Auth persiste la
// session) — aucune règle Firestore à assouplir, le créateur écrit comme un
// citoyen normal (`source: 'citizen'`, `alertBadgeVariant: 'citizen'`).

import 'package:flutter/widgets.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vitallink/firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final user = await FirebaseAuth.instance
      .authStateChanges()
      .firstWhere((u) => u != null)
      .timeout(const Duration(seconds: 10));

  if (user == null) {
    print('Aucun utilisateur connecté sur cet appareil — abandon.');
    return;
  }
  print('Connecté comme ${user.uid}');

  final firestore = FirebaseFirestore.instance;

  final alerts = [
    {
      'region': 'Littoral',
      'district': 'Douala',
      'hospitalName': 'Hôpital Laquintinie (test)',
      'recipientBloodGroup': 'O+',
      'compatibleGroups': ['O-', 'O+'],
    },
    {
      'region': 'Centre',
      'district': 'Yaoundé',
      'hospitalName': 'Hôpital Central (test)',
      'recipientBloodGroup': 'A+',
      'compatibleGroups': ['O-', 'O+', 'A-', 'A+'],
    },
    {
      'region': 'Nord',
      'district': 'Garoua',
      'hospitalName': 'Hôpital Régional de Garoua (test)',
      'recipientBloodGroup': 'B-',
      'compatibleGroups': ['O-', 'B-'],
    },
    {
      'region': 'Ouest',
      'district': 'Bafoussam',
      'hospitalName': 'Hôpital Régional de Bafoussam (test)',
      'recipientBloodGroup': 'AB+',
      'compatibleGroups': ['O-', 'O+', 'A-', 'A+', 'B-', 'B+', 'AB-', 'AB+'],
    },
    {
      'region': 'Sud-Ouest',
      'district': 'Buea',
      'hospitalName': 'Buea Regional Hospital (test)',
      'recipientBloodGroup': 'AB-',
      'compatibleGroups': ['O-', 'A-', 'B-', 'AB-'],
    },
  ];

  final col = firestore.collection('bloodAlerts');
  for (final a in alerts) {
    final doc = await col.add({
      'recipientBloodGroup': a['recipientBloodGroup'],
      'compatibleGroups': a['compatibleGroups'],
      'units': 2,
      'criticality': 'high',
      'hospitalId': 'test-hospital-${a['region']}',
      'location': const GeoPoint(0, 0),
      'createdBy': user.uid,
      'country': 'Cameroun',
      'region': a['region'],
      'status': 'open',
      'createdAt': FieldValue.serverTimestamp(),
      'expiresAt': Timestamp.fromDate(
        DateTime.now().add(const Duration(hours: 24)),
      ),
      'hospitalName': a['hospitalName'],
      'serviceInfo': 'Urgences (test)',
      'contactPhone': '+237600000000',
      'district': a['district'],
      'distanceKm': 0,
      'alertBadgeLabel': 'Alerte citoyenne',
      'alertBadgeVariant': 'citizen',
      'source': 'citizen',
      'bloodGroupTagLabel': a['recipientBloodGroup'],
      'ctaSubtitleText': '2 poche(s) · ${a['hospitalName']}',
    });
    print('Créée : ${a['region']} — ${a['recipientBloodGroup']} (${doc.id})');
  }
  print('Terminé : ${alerts.length} alertes de test créées.');
}
