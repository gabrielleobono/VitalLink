import 'dart:math' as math;

import '../../../core/utils/blood_compatibility.dart';
import 'blood_request_enums.dart';

/// Alerte de besoin en sang, partie **publique** (visible dans le fil).
///
/// Ne contient volontairement ni nom de patient ni numéro de la famille :
/// Firestore ne filtre pas les champs d'un document, donc tout ce qui est ici
/// est lisible par quiconque peut lire l'alerte. Le numéro de contact vit dans
/// [BloodRequestContact] (sous-document privé).
class BloodRequest {
  const BloodRequest({
    required this.id,
    required this.requesterId,
    required this.city,
    required this.bloodGroupNeeded,
    required this.compatibleGroups,
    required this.hospitalId,
    this.hospitalDepartment,
    this.isMedicallyVerified = false,
    this.urgency = UrgencyLevel.high,
    this.unitsNeeded = 1,
    this.unitsPledged = 0,
    this.status = RequestStatus.open,
    this.notes,
    this.createdAt,
  }) : assert(unitsNeeded >= 1, 'Une alerte demande au moins 1 poche');

  /// Nouvelle alerte : les groupes compatibles sont déduits en Dart (règle
  /// validée en équipe), jamais saisis à la main.
  factory BloodRequest.create({
    // Vide tant que Firestore n'a pas généré l'id définitif (voir
    // BloodRequestRepository.createRequest).
    String id = '',
    required String requesterId,
    required String city,
    required BloodGroup bloodGroupNeeded,
    required String hospitalId,
    String? hospitalDepartment,
    UrgencyLevel urgency = UrgencyLevel.high,
    int unitsNeeded = 1,
    String? notes,
  }) {
    return BloodRequest(
      id: id,
      requesterId: requesterId,
      city: city,
      bloodGroupNeeded: bloodGroupNeeded,
      compatibleGroups: BloodCompatibility.notificationPriorityFor(
        bloodGroupNeeded,
      ),
      hospitalId: hospitalId,
      hospitalDepartment: hospitalDepartment,
      urgency: urgency,
      unitsNeeded: unitsNeeded,
      notes: notes,
    );
  }

  final String id;
  final String requesterId;
  final String city;
  final BloodGroup bloodGroupNeeded;

  /// Groupes donneurs compatibles, du plus prioritaire au moins prioritaire.
  final List<BloodGroup> compatibleGroups;

  final String hospitalId;
  final String? hospitalDepartment;

  /// `true` = badge vert « Alerte Médicale Vérifiée », sinon badge orange
  /// « Alerte Citoyenne ». Doit être imposé côté Security Rules / serveur.
  final bool isMedicallyVerified;

  final UrgencyLevel urgency;
  final int unitsNeeded;
  final int unitsPledged;
  final RequestStatus status;
  final String? notes;

  /// `null` tant que l'alerte n'a pas été écrite (horodatage serveur).
  final DateTime? createdAt;

  bool get isOpen => status == RequestStatus.open;
  bool get isFullyPledged => unitsPledged >= unitsNeeded;
  int get unitsRemaining => math.max(0, unitsNeeded - unitsPledged);
}

/// Numéro de la famille pour une alerte : **privé**.
///
/// Stocké dans `blood_requests/{id}/private/contact`, lisible uniquement par le
/// demandeur (règle à écrire dans les Security Rules).
class BloodRequestContact {
  const BloodRequestContact({required this.contactPhone});

  final String contactPhone;
}
