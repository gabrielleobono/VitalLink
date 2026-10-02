import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/blood_alert.dart';

/// Accès Firestore à la collection `bloodAlerts` pour le fil "Urgences à
/// proximité" de l'Accueil et "Mes alertes".
class BloodAlertRepository {
  BloodAlertRepository(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection('bloodAlerts');

  Stream<List<BloodAlert>> watchOpenAlerts() {
    return _collection
        .where('status', isEqualTo: 'open')
        .snapshots()
        .map((snapshot) {
          final list = snapshot.docs
              .map((doc) => BloodAlert.fromFirestore(doc.id, doc.data()))
              .toList();
          list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return list;
        });
  }

  /// Alertes publiées par [uid], quel que soit leur statut (pour l'écran
  /// "Mes alertes" du Profil). Tri en mémoire pour éviter le besoin d'index composite.
  Stream<List<BloodAlert>> watchMyAlerts(String uid) {
    return _collection
        .where('createdBy', isEqualTo: uid)
        .snapshots()
        .map((snapshot) {
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
}
