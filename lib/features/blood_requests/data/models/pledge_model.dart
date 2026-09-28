import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/blood_request_enums.dart';
import '../../domain/pledge.dart';

/// Sérialisation Firestore de [Pledge].
/// Collection : `pledges/{requestId_donorId}` — champs en snake_case.
class PledgeModel extends Pledge {
  const PledgeModel({
    required super.id,
    required super.requestId,
    required super.donorId,
    required super.estimatedArrival,
    required super.status,
    required super.createdAt,
  });

  factory PledgeModel.fromEntity(Pledge p) => PledgeModel(
        id: p.id,
        requestId: p.requestId,
        donorId: p.donorId,
        estimatedArrival: p.estimatedArrival,
        status: p.status,
        createdAt: p.createdAt,
      );

  factory PledgeModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    if (data == null) {
      throw StateError('Engagement ${doc.id} introuvable ou vide.');
    }
    return PledgeModel.fromMap(doc.id, data);
  }

  factory PledgeModel.fromMap(String id, Map<String, dynamic> data) =>
      PledgeModel(
        id: id,
        requestId: data['request_id'] as String,
        donorId: data['donor_id'] as String,
        estimatedArrival:
            ArrivalEstimate.fromWire(data['estimated_arrival'] as String?),
        status: PledgeStatus.fromWire(data['status'] as String?),
        createdAt: (data['created_at'] as Timestamp?)?.toDate().toUtc(),
      );

  Map<String, dynamic> toFirestore() {
    final created = createdAt;
    return {
      'request_id': requestId,
      'donor_id': donorId,
      'status': status.wire,
      'estimated_arrival': estimatedArrival.wire,
      'created_at': created != null
          ? Timestamp.fromDate(created)
          : FieldValue.serverTimestamp(),
    };
  }
}
