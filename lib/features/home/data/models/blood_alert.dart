import 'package:cloud_firestore/cloud_firestore.dart';

/// Alerte de don de sang affichée sur le dashboard ("Urgences à proximité").
///
/// Reprend le schéma `bloodAlerts/{id}` de CONTEXT.md (recipientBloodGroup,
/// compatibleGroups, units, criticality, hospitalId, location, geohash,
/// createdBy, status, createdAt, expiresAt) et ajoute des champs
/// dénormalisés d'affichage (hospitalName, serviceInfo, district,
/// distanceKm, alertBadgeLabel, ...) pour éviter une jointure par carte
/// dans la liste.
class BloodAlert {
  const BloodAlert({
    required this.id,
    required this.recipientBloodGroup,
    required this.compatibleGroups,
    required this.units,
    required this.criticality,
    required this.hospitalId,
    required this.createdBy,
    required this.country,
    required this.region,
    required this.status,
    required this.createdAt,
    required this.expiresAt,
    required this.hospitalName,
    required this.serviceInfo,
    required this.district,
    required this.distanceKm,
    required this.alertBadgeLabel,
    required this.alertBadgeVariant,
    required this.bloodGroupTagLabel,
    required this.ctaSubtitleText,
  });

  final String id;
  final String recipientBloodGroup;
  final List<String> compatibleGroups;
  final int units;
  final String criticality;
  final String hospitalId;
  final String createdBy;
  final String country;
  final String region;
  final String status;
  final DateTime createdAt;
  final DateTime expiresAt;
  final String hospitalName;
  final String serviceInfo;
  final String district;
  final double distanceKm;
  final String alertBadgeLabel;
  final String alertBadgeVariant;
  final String bloodGroupTagLabel;
  final String ctaSubtitleText;

  factory BloodAlert.fromFirestore(String id, Map<String, dynamic> data) {
    return BloodAlert(
      id: id,
      recipientBloodGroup: data['recipientBloodGroup'] as String? ?? '',
      compatibleGroups:
          (data['compatibleGroups'] as List?)?.cast<String>() ?? const [],
      units: (data['units'] as num?)?.toInt() ?? 0,
      criticality: data['criticality'] as String? ?? 'medium',
      hospitalId: data['hospitalId'] as String? ?? '',
      createdBy: data['createdBy'] as String? ?? '',
      country: data['country'] as String? ?? '',
      region: data['region'] as String? ?? '',
      status: data['status'] as String? ?? 'open',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      expiresAt: (data['expiresAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      hospitalName: data['hospitalName'] as String? ?? '',
      serviceInfo: data['serviceInfo'] as String? ?? '',
      district: data['district'] as String? ?? '',
      distanceKm: (data['distanceKm'] as num?)?.toDouble() ?? 0,
      alertBadgeLabel: data['alertBadgeLabel'] as String? ?? '',
      alertBadgeVariant: data['alertBadgeVariant'] as String? ?? 'verified',
      bloodGroupTagLabel: data['bloodGroupTagLabel'] as String? ?? '',
      ctaSubtitleText: data['ctaSubtitleText'] as String? ?? '',
    );
  }

  /// Texte relatif court ("Il y a 12 min", "Il y a 1h").
  String get relativeCreatedAt {
    final diff = DateTime.now().difference(createdAt);
    if (diff.inHours >= 1) return 'Il y a ${diff.inHours}h';
    if (diff.inMinutes >= 1) return 'Il y a ${diff.inMinutes} min';
    return "À l'instant";
  }
}
