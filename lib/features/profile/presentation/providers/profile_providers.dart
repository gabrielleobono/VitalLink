import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/auth_providers.dart';
import '../../data/models/donor_profile.dart';
import '../../data/models/user_profile.dart';

/// Flux du profil `users/{uid}` — le document est créé par l'écran
/// d'inscription (`RegisterScreen`) avant même que l'app n'atteigne l'Accueil
/// ou le Profil (cf. le `redirect` de `appRouter`), donc il existe toujours
/// ici en usage normal.
final userProfileProvider = StreamProvider<UserProfile?>((ref) async* {
  final uid = await ref.watch(currentUserIdProvider.future);
  yield* FirebaseFirestore.instance
      .collection('users')
      .doc(uid)
      .snapshots()
      .map(
        (doc) =>
            doc.exists ? UserProfile.fromFirestore(uid, doc.data()!) : null,
      );
});

final donorProfileProvider = StreamProvider<DonorProfile?>((ref) async* {
  final uid = await ref.watch(currentUserIdProvider.future);
  yield* FirebaseFirestore.instance
      .collection('donors')
      .doc(uid)
      .snapshots()
      .map(
        (doc) => doc.exists ? DonorProfile.fromFirestore(doc.data()!) : null,
      );
});

/// Alertes publiées par l'utilisateur courant (pour la carte statistiques).
final myAlertsCountProvider = StreamProvider<int>((ref) async* {
  final uid = await ref.watch(currentUserIdProvider.future);
  yield* FirebaseFirestore.instance
      .collection('bloodAlerts')
      .where('createdBy', isEqualTo: uid)
      .snapshots()
      .map((snapshot) => snapshot.docs.length);
});

/// Bascule "Prêt à donner" de la carte "Engagement Donneur" — crée
/// `donors/{uid}` au premier passage à `true`.
class DonorAvailabilityController {
  DonorAvailabilityController(this._ref);

  final Ref _ref;

  Future<void> setAvailable(bool available) async {
    final uid = await _ref.read(currentUserIdProvider.future);
    await FirebaseFirestore.instance.collection('donors').doc(uid).set({
      'available': available,
    }, SetOptions(merge: true));
    await FirebaseFirestore.instance.collection('users').doc(uid).set({
      'isDonor': available,
    }, SetOptions(merge: true));
  }
}

final donorAvailabilityControllerProvider =
    Provider<DonorAvailabilityController>(
      (ref) => DonorAvailabilityController(ref),
    );
