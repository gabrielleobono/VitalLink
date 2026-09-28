/// Enums du module Urgence Sang.
///
/// Chaque valeur porte sa forme stockée dans Firestore (`wire`, identique aux
/// enums de SPECIFICATIONS.md) et son libellé français affiché à l'écran.
library;

/// Niveau d'urgence d'une alerte (spec : `urgency_level`).
enum UrgencyLevel {
  critical('CRITICAL', 'Critique'),
  high('HIGH', 'Urgent'),
  moderate('MODERATE', 'Modéré');

  const UrgencyLevel(this.wire, this.label);

  final String wire;
  final String label;

  /// Valeur inconnue -> `high` (on préfère sur-signaler que sous-signaler).
  static UrgencyLevel fromWire(String? value) => UrgencyLevel.values.firstWhere(
        (e) => e.wire == value,
        orElse: () => UrgencyLevel.high,
      );
}

/// Statut d'une alerte (spec : `request_status`).
enum RequestStatus {
  open('OPEN', 'Ouverte'),
  fulfilled('FULFILLED', 'Besoin couvert'),
  closed('CLOSED', 'Clôturée');

  const RequestStatus(this.wire, this.label);

  final String wire;
  final String label;

  /// Valeur inconnue -> `closed` (une alerte illisible n'est jamais affichée
  /// comme ouverte).
  static RequestStatus fromWire(String? value) => RequestStatus.values.firstWhere(
        (e) => e.wire == value,
        orElse: () => RequestStatus.closed,
      );
}

/// Statut d'un engagement de donneur (spec : `pledge_status`).
enum PledgeStatus {
  committed('COMMITTED', 'Engagé'),
  arrived('ARRIVED', 'Arrivé'),
  completed('COMPLETED', 'Don effectué'),
  cancelled('CANCELLED', 'Annulé');

  const PledgeStatus(this.wire, this.label);

  final String wire;
  final String label;

  /// Valeur inconnue -> `cancelled` (n'est jamais compté comme un donneur).
  static PledgeStatus fromWire(String? value) => PledgeStatus.values.firstWhere(
        (e) => e.wire == value,
        orElse: () => PledgeStatus.cancelled,
      );
}

/// Délai d'arrivée estimé choisi dans le bottom sheet « Je viens donner ».
enum ArrivalEstimate {
  in30Minutes('IN_30_MIN', 'Dans 30 min'),
  in1Hour('IN_1H', 'Dans 1 h'),
  in2Hours('IN_2H', 'Dans 2 h');

  const ArrivalEstimate(this.wire, this.label);

  final String wire;
  final String label;

  static ArrivalEstimate fromWire(String? value) =>
      ArrivalEstimate.values.firstWhere(
        (e) => e.wire == value,
        orElse: () => ArrivalEstimate.in1Hour,
      );
}
