import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/blood_alert.dart';

/// Flux temps réel des alertes de sang ouvertes, les plus récentes d'abord.
final bloodAlertsProvider = StreamProvider<List<BloodAlert>>((ref) {
  return FirebaseFirestore.instance
      .collection('bloodAlerts')
      .where('status', isEqualTo: 'open')
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map(
        (snapshot) => snapshot.docs
            .map((doc) => BloodAlert.fromFirestore(doc.id, doc.data()))
            .toList(),
      );
});

/// Une alerte précise par id, pour l'écran de détail.
final bloodAlertByIdProvider = StreamProvider.family<BloodAlert?, String>((
  ref,
  alertId,
) {
  return FirebaseFirestore.instance
      .collection('bloodAlerts')
      .doc(alertId)
      .snapshots()
      .map(
        (doc) =>
            doc.exists ? BloodAlert.fromFirestore(doc.id, doc.data()!) : null,
      );
});
