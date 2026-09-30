import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/blood_request_model.dart';
import '../../data/repositories/blood_request_repository.dart';

final firestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

final bloodRequestRepositoryProvider = Provider<BloodRequestRepository>((ref) {
  return BloodRequestRepository(ref.watch(firestoreProvider));
});

/// Fil temps réel des alertes sang ouvertes, pour le Hub et l'écran Urgences.
final openBloodRequestsProvider =
    StreamProvider.autoDispose<List<BloodRequestModel>>((ref) {
      return ref.watch(bloodRequestRepositoryProvider).watchOpenRequests();
    });

/// Une alerte précise, écoutée en temps réel (écran Détail).
final bloodRequestByIdProvider = StreamProvider.autoDispose
    .family<BloodRequestModel, String>((ref, id) {
      return ref.watch(bloodRequestRepositoryProvider).watchRequestById(id);
    });
