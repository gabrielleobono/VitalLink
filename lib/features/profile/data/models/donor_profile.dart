import 'package:cloud_firestore/cloud_firestore.dart';

/// Profil donneur (`donors/{uid}` — cf. CONTEXT.md), séparé de `users` pour
/// limiter l'accès aux données sensibles.
class DonorProfile {
  const DonorProfile({
    required this.bloodGroup,
    required this.available,
    required this.lastDonationAt,
  });

  final String bloodGroup;
  final bool available;
  final DateTime? lastDonationAt;

  factory DonorProfile.fromFirestore(Map<String, dynamic> data) {
    return DonorProfile(
      bloodGroup: data['bloodGroup'] as String? ?? '',
      available: data['available'] as bool? ?? false,
      lastDonationAt: (data['lastDonationAt'] as Timestamp?)?.toDate(),
    );
  }

  /// Un don n'est recommandé qu'après un délai de sécurité de 90 jours.
  bool get isEligible {
    final lastDonation = lastDonationAt;
    if (lastDonation == null) return true;
    return DateTime.now().difference(lastDonation).inDays >= 90;
  }

  String get eligibilityLabel {
    if (isEligible) return 'Éligible au don';
    final daysLeft = 90 - DateTime.now().difference(lastDonationAt!).inDays;
    return 'Éligible dans $daysLeft j';
  }

  String get lastDonationLabel {
    final lastDonation = lastDonationAt;
    if (lastDonation == null) return 'Aucun don enregistré';
    final days = DateTime.now().difference(lastDonation).inDays;
    if (days < 30) return 'Dernier don : il y a $days j';
    return 'Dernier don : il y a ${(days / 30).round()} mois';
  }
}
