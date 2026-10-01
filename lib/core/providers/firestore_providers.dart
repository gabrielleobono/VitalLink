import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Instance Firestore partagée, injectée dans les repositories — même
/// convention que [firebaseAuthProvider] dans `auth_providers.dart`.
final firestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});
