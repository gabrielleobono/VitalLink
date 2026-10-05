// ignore_for_file: avoid_print
// Correctif ponctuel : les 3 hôpitaux originaux avaient déjà un `country`
// (ajouté manuellement avant ce travail) mais pas de `region`, donc le
// script de migration précédent les a ignorés à tort. On les corrige ici
// directement, sans condition.

import 'package:flutter/widgets.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vitallink/firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final col = FirebaseFirestore.instance.collection('hospitals');
  final snapshot = await col.get();

  for (final doc in snapshot.docs) {
    final data = doc.data();
    final region = data['region'] as String?;
    if (region != null && region.isNotEmpty) {
      print('OK déjà : ${data['name']} -> $region');
      continue;
    }
    final city = (data['city'] as String? ?? '').toLowerCase();
    if (!city.contains('douala')) {
      print('Ville inconnue, ignoré : ${data['name']} (city=${data['city']})');
      continue;
    }
    await doc.reference.update({'region': 'Littoral'});
    print('Corrigé : ${data['name']} -> Littoral');
  }
  print('Terminé.');
}
