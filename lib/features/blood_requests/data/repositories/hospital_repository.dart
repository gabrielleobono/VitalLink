import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/hospital_model.dart';

/// Accès Firestore à la collection `hospitals` (référentiel statique, alimenté
/// par le module 6 - Données de test & Demo).
class HospitalRepository {
  HospitalRepository(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection('hospitals');

  /// Un hôpital ne change pas souvent : un simple `get()` suffit, pas besoin
  /// d'écouter un flux temps réel comme pour les alertes.
  Future<HospitalModel> fetchById(String id) async {
    final doc = await _collection.doc(id).get();
    if (!doc.exists) {
      throw StateError('Hôpital "$id" introuvable dans Firestore.');
    }
    return HospitalModel.fromFirestore(doc);
  }

  /// Tous les hôpitaux du référentiel, pour le sélecteur du formulaire de
  /// création d'alerte. Petite liste statique : un simple `get()` suffit.
  Future<List<HospitalModel>> fetchAll() async {
    final snapshot = await _collection.orderBy('name').get();
    return snapshot.docs.map(HospitalModel.fromFirestore).toList();
  }
}
