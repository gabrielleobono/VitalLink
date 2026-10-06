// ignore_for_file: avoid_print
// Script ponctuel en lecture seule : affiche le contenu complet de
// `hospitals` pour vérifier les champs country/region.

import 'package:flutter/widgets.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vitallink/firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final snapshot = await FirebaseFirestore.instance
      .collection('hospitals')
      .get();
  print('${snapshot.docs.length} hôpital(aux) :');
  for (final doc in snapshot.docs) {
    final d = doc.data();
    print(
      '- ${d['name']} | city=${d['city']} | country=${d['country']} | region=${d['region']}',
    );
  }
}
