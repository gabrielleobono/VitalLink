import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/blood_alert.dart';

/// Accès Firestore à la collection `bloodAlerts` pour le fil "Urgences à
/// proximité" de l'Accueil.
class BloodAlertRepository {
  BloodAlertRepository(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection('bloodAlerts');

  Stream<List<BloodAlert>> watchOpenAlerts() {
    return _collection
        .where('status', isEqualTo: 'open')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => BloodAlert.fromFirestore(doc.id, doc.data()))
              .toList(),
        );
  }

  /// Alertes publiées par [uid], quel que soit leur statut (pour l'écran
  /// "Mes alertes" du Profil).
  Stream<List<BloodAlert>> watchMyAlerts(String uid) {
    return _collection
        .where('createdBy', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => BloodAlert.fromFirestore(doc.id, doc.data()))
              .toList(),
        );
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
}
