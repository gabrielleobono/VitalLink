// ignore_for_file: avoid_print
// Script ponctuel : tague les pharmacies existantes (seedées avant l'ajout
// du filtrage géographique) avec country/region, déduits de leur ville
// (adresse/quartier). Nécessite une règle `allow update` temporairement
// assouplie sur `pharmacies` (voir firestore.rules) — à lancer puis
// resécuriser aussitôt, comme pour tool/seed_pharmacies.dart.

import 'package:flutter/widgets.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vitallink/firebase_options.dart';

String? _regionFor(String address, String neighborhood) {
  final text = '$address $neighborhood'.toLowerCase();
  if (text.contains('yaoundé') || text.contains('bastos')) return 'Centre';
  if (text.contains('douala') ||
      text.contains('akwa') ||
      text.contains('bonanjo') ||
      text.contains('deïdo') ||
      text.contains('deido') ||
      text.contains('bonamoussadi')) {
    return 'Littoral';
  }
  return null;
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final firestore = FirebaseFirestore.instance;
  final snapshot = await firestore.collection('pharmacies').get();
  print('${snapshot.docs.length} pharmacie(s) trouvée(s).');

  var updated = 0;
  for (final doc in snapshot.docs) {
    final data = doc.data();
    final name = data['name'] as String? ?? '(sans nom)';
    final existingCountry = data['country'] as String?;
    if (existingCountry != null && existingCountry.isNotEmpty) {
      print('Ignorée (déjà taguée) : $name');
      continue;
    }
    final region = _regionFor(
      data['address'] as String? ?? '',
      data['neighborhood'] as String? ?? '',
    );
    if (region == null) {
      print('Région inconnue, ignorée : $name');
      continue;
    }
    await doc.reference.update({'country': 'Cameroun', 'region': region});
    print('Mise à jour : $name -> Cameroun / $region');
    updated++;
  }
  print('Terminé : $updated pharmacie(s) mise(s) à jour.');
}
