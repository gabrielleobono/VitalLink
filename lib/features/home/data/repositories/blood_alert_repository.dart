import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/blood_alert.dart';

/// Accès Firestore à la collection `bloodAlerts` pour le fil "Urgences à
/// proximité" de l'Accueil et "Mes alertes".
class BloodAlertRepository {
  BloodAlertRepository(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection('bloodAlerts');

  /// Alertes ouvertes, limitées au [country] et à la [region] de
  /// l'utilisateur courant — on ne montre jamais une urgence d'un autre
  /// pays ou d'une autre région/province, même si elle est "proche" à vol
  /// d'oiseau (cf. décision produit : pas d'alerte hors de sa zone).
  Stream<List<BloodAlert>> watchOpenAlerts({
    required String country,
    required String region,
  }) {
    return _collection
        .where('status', isEqualTo: 'open')
        .where('country', isEqualTo: country)
        .where('region', isEqualTo: region)
        .snapshots()
        .map((snapshot) {
          final list = snapshot.docs
              .map((doc) => BloodAlert.fromFirestore(doc.id, doc.data()))
              .toList();
          list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return list;
        })
        // Si Firestore réclame un index composite (status+country+region)
        // qui n'existe pas encore, on dégrade sans faire planter l'écran.
        .handleError((_) => <BloodAlert>[]);
  }

  /// Alertes publiées par [uid], quel que soit leur statut (pour l'écran
  /// "Mes alertes" du Profil). Tri en mémoire pour éviter le besoin d'index composite.
  Stream<List<BloodAlert>> watchMyAlerts(String uid) {
    return _collection.where('createdBy', isEqualTo: uid).snapshots().map((
      snapshot,
    ) {
      final list = snapshot.docs
          .map((doc) => BloodAlert.fromFirestore(doc.id, doc.data()))
          .toList();
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    });
  }

  Stream<BloodAlert?> watchAlertById(String id) {
    return _collection
        .doc(id)
        .snapshots()
        .map(
          (doc) =>
              doc.exists ? BloodAlert.fromFirestore(doc.id, doc.data()!) : null,
        );
  }

  /// Clôture une alerte (le besoin est couvert) — réservé à son créateur,
  /// voir `firestore.rules` > `bloodAlerts/{id}` > `allow update`.
  Future<void> closeAlert(String id) {
    return _collection.doc(id).update({'status': 'closed'});
  }
}
