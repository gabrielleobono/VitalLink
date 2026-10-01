import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/hospital.dart';

/// Accès Firestore à `hospitals/{id}` pour l'écran "Détails de l'urgence".
class HospitalLookupRepository {
  HospitalLookupRepository(this._firestore);

  final FirebaseFirestore _firestore;

  Future<Hospital?> fetchById(String id) async {
    if (id.isEmpty) return null;
    final snapshot = await _firestore.collection('hospitals').doc(id).get();
    if (!snapshot.exists) return null;
    return Hospital.fromFirestore(snapshot.id, snapshot.data()!);
  }
}
