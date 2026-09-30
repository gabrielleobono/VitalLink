import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/blood_request_enums.dart';
import '../../domain/pledge.dart';
import '../models/pledge_model.dart';

/// Accès Firestore aux engagements (« Je viens donner »).
class PledgeRepository {
  PledgeRepository(this._firestore);

  final FirebaseFirestore _firestore;

  DocumentReference<Map<String, dynamic>> _pledgeDoc(
    String requestId,
    String donorId,
  ) => _firestore
      .collection('pledges')
      .doc(Pledge.buildId(requestId: requestId, donorId: donorId));

  DocumentReference<Map<String, dynamic>> _requestDoc(String requestId) =>
      _firestore.collection('blood_requests').doc(requestId);

  /// Crée l'engagement et incrémente `units_pledged` sur l'alerte, dans une
  /// transaction : si deux donneurs s'engagent au même instant, aucun des
  /// deux compteurs n'est perdu.
  ///
  /// Idempotent : si ce donneur a déjà un engagement actif sur cette alerte,
  /// ne fait rien (l'id du document est déterministe, voir [Pledge.buildId]).
  Future<void> pledge({
    required String requestId,
    required String donorId,
    required ArrivalEstimate estimatedArrival,
  }) {
    return _firestore.runTransaction((transaction) async {
      final pledgeRef = _pledgeDoc(requestId, donorId);
      final existingPledge = await transaction.get(pledgeRef);
      if (existingPledge.exists) {
        return;
      }

      final pledge = PledgeModel(
        id: pledgeRef.id,
        requestId: requestId,
        donorId: donorId,
        estimatedArrival: estimatedArrival,
        status: PledgeStatus.committed,
        createdAt: null,
      );

      transaction.set(pledgeRef, pledge.toFirestore());
      transaction.update(_requestDoc(requestId), {
        'units_pledged': FieldValue.increment(1),
      });
    });
  }
}
