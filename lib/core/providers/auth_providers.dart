import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});

/// Id de l'utilisateur courant, toujours non-null.
///
/// Le module Authentification (module 5) n'est pas encore branché : en
/// attendant, on se connecte anonymement pour avoir un identifiant stable de
/// donneur. Firebase permet nativement de migrer un compte anonyme vers un
/// vrai compte plus tard, donc ceci n'est pas jetable — le module 5 pourra
/// construire par-dessus sans perdre les engagements déjà faits.
///
/// Nécessite que la méthode de connexion "Anonymous" soit activée dans
/// Firebase Console (Authentication > Sign-in method).
final currentUserIdProvider = FutureProvider<String>((ref) async {
  final auth = ref.watch(firebaseAuthProvider);
  final existing = auth.currentUser;
  if (existing != null) return existing.uid;
  final credential = await auth.signInAnonymously();
  final uid = credential.user?.uid;
  if (uid == null) {
    throw StateError('Connexion anonyme Firebase impossible.');
  }
  return uid;
});
