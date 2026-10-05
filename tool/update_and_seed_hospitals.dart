// ignore_for_file: avoid_print
// Script ponctuel : (1) tague les hôpitaux existants (country/region déduits
// de leur ville) et (2) ajoute des hôpitaux de test dans d'autres régions
// du Cameroun, pour tester le filtrage géographique du picker d'hôpital
// dans "Lancer une urgence". Nécessite une règle `allow write` Firestore
// temporairement assouplie sur `hospitals` (normalement `if false`) — à
// lancer puis resécuriser aussitôt.

import 'package:flutter/widgets.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vitallink/firebase_options.dart';

String? _regionFor(String city) {
  final text = city.toLowerCase();
  if (text.contains('yaoundé') || text.contains('yaounde')) return 'Centre';
  if (text.contains('douala')) return 'Littoral';
  if (text.contains('garoua')) return 'Nord';
  if (text.contains('bafoussam')) return 'Ouest';
  if (text.contains('buea')) return 'Sud-Ouest';
  return null;
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final firestore = FirebaseFirestore.instance;
  final col = firestore.collection('hospitals');

  // 1) Migration des hôpitaux existants.
  final snapshot = await col.get();
  print('${snapshot.docs.length} hôpital(aux) existant(s) trouvé(s).');
  for (final doc in snapshot.docs) {
    final data = doc.data();
    final name = data['name'] as String? ?? '(sans nom)';
    final existingCountry = data['country'] as String?;
    if (existingCountry != null && existingCountry.isNotEmpty) {
      print('Ignoré (déjà taggé) : $name');
      continue;
    }
    final region = _regionFor(data['city'] as String? ?? '');
    if (region == null) {
      print('Région inconnue, ignoré : $name (ville="${data['city']}")');
      continue;
    }
    await doc.reference.update({'country': 'Cameroun', 'region': region});
    print('Mis à jour : $name -> Cameroun / $region');
  }

  // 2) Hôpitaux de test dans d'autres régions (pour tester le picker en
  // changeant sa propre région via "Modifier ma localisation").
  final testHospitals = [
    {
      'name': 'Hôpital Régional de Garoua (test)',
      'address': 'Avenue du Renouveau, Garoua',
      'phone': '+237600000001',
      'city': 'Garoua',
      'region': 'Nord',
    },
    {
      'name': 'Hôpital Régional de Bafoussam (test)',
      'address': 'Route de Bamenda, Bafoussam',
      'phone': '+237600000002',
      'city': 'Bafoussam',
      'region': 'Ouest',
    },
    {
      'name': 'Buea Regional Hospital (test)',
      'address': 'Molyko, Buea',
      'phone': '+237600000003',
      'city': 'Buea',
      'region': 'Sud-Ouest',
    },
  ];

  for (final h in testHospitals) {
    final doc = await col.add({
      'name': h['name'],
      'address': h['address'],
      'phone': h['phone'],
      'city': h['city'],
      'location': const GeoPoint(0, 0),
      'country': 'Cameroun',
      'region': h['region'],
    });
    print('Créé : ${h['name']} (${doc.id})');
  }

  print('Terminé.');
}
