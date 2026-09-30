import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/hospital.dart';

/// Sérialisation Firestore de [Hospital].
/// Collection : `hospitals/{id}` — champs en snake_case (SPECIFICATIONS.md).
class HospitalModel extends Hospital {
  const HospitalModel({
    required super.id,
    required super.name,
    required super.city,
    required super.address,
    required super.latitude,
    required super.longitude,
    required super.emergencyPhone,
  });

  factory HospitalModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data();
    if (data == null) {
      throw StateError('Hôpital ${doc.id} introuvable ou vide.');
    }
    return HospitalModel.fromMap(doc.id, data);
  }

  /// Séparé de [fromFirestore] pour pouvoir être testé sans Firebase.
  factory HospitalModel.fromMap(String id, Map<String, dynamic> data) {
    return HospitalModel(
      id: id,
      name: data['name'] as String,
      city: data['city'] as String,
      address: data['address'] as String,
      // Firestore peut renvoyer un int (ex. latitude 0) : toDouble() couvre
      // les deux cas.
      latitude: (data['latitude'] as num).toDouble(),
      longitude: (data['longitude'] as num).toDouble(),
      emergencyPhone: data['emergency_phone'] as String,
    );
  }
}
