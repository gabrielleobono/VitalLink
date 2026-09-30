import 'blood_request_enums.dart';

/// Engagement d'un donneur sur une alerte (« Je viens donner »).
class Pledge {
  const Pledge({
    required this.id,
    required this.requestId,
    required this.donorId,
    required this.estimatedArrival,
    this.status = PledgeStatus.committed,
    this.createdAt,
  });

  /// Identifiant déterministe : un donneur ne peut avoir qu'un engagement par
  /// alerte (Firestore n'a pas d'index unique, l'id le garantit).
  static String buildId({required String requestId, required String donorId}) =>
      '${requestId}_$donorId';

  final String id;
  final String requestId;
  final String donorId;
  final ArrivalEstimate estimatedArrival;
  final PledgeStatus status;
  final DateTime? createdAt;

  /// Un engagement annulé ne compte pas dans le nombre de donneurs mobilisés.
  bool get isActive => status != PledgeStatus.cancelled;
}
