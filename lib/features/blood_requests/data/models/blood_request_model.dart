import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/utils/blood_compatibility.dart';
import '../../domain/blood_group_codec.dart';
import '../../domain/blood_request.dart';
import '../../domain/blood_request_enums.dart';

/// Sérialisation Firestore de [BloodRequest].
/// Collection : `blood_requests/{id}` — champs en snake_case (SPECIFICATIONS.md).
class BloodRequestModel extends BloodRequest {
  const BloodRequestModel({
    required super.id,
    required super.requesterId,
    required super.city,
    required super.bloodGroupNeeded,
    required super.compatibleGroups,
    required super.hospitalId,
    required super.hospitalDepartment,
    required super.isMedicallyVerified,
    required super.urgency,
    required super.unitsNeeded,
    required super.unitsPledged,
    required super.status,
    required super.notes,
    required super.createdAt,
  });

  factory BloodRequestModel.fromEntity(BloodRequest r) => BloodRequestModel(
    id: r.id,
    requesterId: r.requesterId,
    city: r.city,
    bloodGroupNeeded: r.bloodGroupNeeded,
    compatibleGroups: r.compatibleGroups,
    hospitalId: r.hospitalId,
    hospitalDepartment: r.hospitalDepartment,
    isMedicallyVerified: r.isMedicallyVerified,
    urgency: r.urgency,
    unitsNeeded: r.unitsNeeded,
    unitsPledged: r.unitsPledged,
    status: r.status,
    notes: r.notes,
    createdAt: r.createdAt,
  );

  factory BloodRequestModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data();
    if (data == null) {
      throw StateError('Alerte ${doc.id} introuvable ou vide.');
    }
    return BloodRequestModel.fromMap(doc.id, data);
  }

  /// Séparé de [fromFirestore] pour pouvoir être testé sans Firebase.
  factory BloodRequestModel.fromMap(String id, Map<String, dynamic> data) {
    final groups = (data['compatible_groups'] as List<dynamic>? ?? const [])
        .map((e) => bloodGroupFromLabel(e as String))
        .toList(growable: false);

    return BloodRequestModel(
      id: id,
      requesterId: data['requester_id'] as String,
      city: data['city'] as String,
      bloodGroupNeeded: bloodGroupFromLabel(
        data['blood_group_needed'] as String,
      ),
      compatibleGroups: groups,
      hospitalId: data['hospital_id'] as String,
      hospitalDepartment: data['hospital_department'] as String?,
      isMedicallyVerified: data['is_medically_verified'] as bool? ?? false,
      urgency: UrgencyLevel.fromWire(data['urgency'] as String?),
      unitsNeeded: (data['units_needed'] as num?)?.toInt() ?? 1,
      unitsPledged: (data['units_pledged'] as num?)?.toInt() ?? 0,
      status: RequestStatus.fromWire(data['status'] as String?),
      notes: data['notes'] as String?,
      // `null` juste après une écriture locale (horodatage serveur en attente).
      createdAt: (data['created_at'] as Timestamp?)?.toDate().toUtc(),
    );
  }

  Map<String, dynamic> toFirestore() {
    final created = createdAt;
    return {
      'requester_id': requesterId,
      'city': city,
      'blood_group_needed': bloodGroupNeeded.label,
      'compatible_groups': compatibleGroups.map((g) => g.label).toList(),
      'hospital_id': hospitalId,
      'hospital_department': hospitalDepartment,
      'is_medically_verified': isMedicallyVerified,
      'urgency': urgency.wire,
      'units_needed': unitsNeeded,
      'units_pledged': unitsPledged,
      'status': status.wire,
      'notes': notes,
      'created_at': created != null
          ? Timestamp.fromDate(created)
          : FieldValue.serverTimestamp(),
    };
  }
}

/// Sérialisation de [BloodRequestContact].
/// Document : `blood_requests/{id}/private/contact`.
class BloodRequestContactModel extends BloodRequestContact {
  const BloodRequestContactModel({required super.contactPhone});

  factory BloodRequestContactModel.fromMap(Map<String, dynamic> data) =>
      BloodRequestContactModel(contactPhone: data['contact_phone'] as String);

  Map<String, dynamic> toFirestore() => {'contact_phone': contactPhone};
}
