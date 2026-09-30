import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/blood_request.dart';
import '../../domain/blood_request_enums.dart';
import '../models/blood_request_model.dart';

/// Accès Firestore à la collection `blood_requests` (spec : "collection
/// racine, un document par alerte, champs publics uniquement").
class BloodRequestRepository {
  BloodRequestRepository(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection('blood_requests');

  /// Fil des alertes ouvertes : les plus critiques d'abord, puis les plus
  /// récentes. Le tri se termine côté Dart (Firestore ne sait pas ordonner
  /// par "gravité d'un enum").
  Stream<List<BloodRequestModel>> watchOpenRequests({int limit = 30}) {
    return _collection
        .where('status', isEqualTo: RequestStatus.open.wire)
        .orderBy('created_at', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) {
          final requests = snapshot.docs
              .map(BloodRequestModel.fromFirestore)
              .toList();
          requests.sort((a, b) {
            final byUrgency = a.urgency.index.compareTo(b.urgency.index);
            if (byUrgency != 0) return byUrgency;
            final aDate = a.createdAt;
            final bDate = b.createdAt;
            if (aDate == null || bDate == null) return 0;
            return bDate.compareTo(aDate);
          });
          return requests;
        });
  }

  /// Une alerte précise, mise à jour en temps réel (utilisé par l'écran
  /// Détail : le compteur de poches doit refléter les engagements en direct).
  Stream<BloodRequestModel> watchRequestById(String id) {
    return _collection.doc(id).snapshots().map(BloodRequestModel.fromFirestore);
  }

  /// Publie une nouvelle alerte, et le numéro de la famille dans un
  /// sous-document privé (jamais dans le document public de l'alerte).
  Future<String> createRequest(
    BloodRequest request, {
    String? contactPhone,
  }) async {
    final docRef = _collection.doc();
    final model = BloodRequestModel(
      id: docRef.id,
      requesterId: request.requesterId,
      city: request.city,
      bloodGroupNeeded: request.bloodGroupNeeded,
      compatibleGroups: request.compatibleGroups,
      hospitalId: request.hospitalId,
      hospitalDepartment: request.hospitalDepartment,
      isMedicallyVerified: request.isMedicallyVerified,
      urgency: request.urgency,
      unitsNeeded: request.unitsNeeded,
      unitsPledged: request.unitsPledged,
      status: request.status,
      notes: request.notes,
      createdAt: request.createdAt,
    );

    final batch = _firestore.batch();
    batch.set(docRef, model.toFirestore());
    if (contactPhone != null && contactPhone.trim().isNotEmpty) {
      batch.set(
        docRef.collection('private').doc('contact'),
        BloodRequestContactModel(
          contactPhone: contactPhone.trim(),
        ).toFirestore(),
      );
    }
    await batch.commit();
    return docRef.id;
  }
}
