import 'package:cloud_firestore/cloud_firestore.dart';

class DonorProfile {
  const DonorProfile({
    required this.bloodGroup,
    required this.available,
    this.lastDonationAt,
  });

  final String bloodGroup;
  final bool available;
  final DateTime? lastDonationAt;

  String get eligibilityLabel {
    if (!available) return 'Indisponible';
    if (lastDonationAt == null) return 'Éligible maintenant';
    final diffDays = DateTime.now().difference(lastDonationAt!).inDays;
    if (diffDays >= 90) return 'Éligible maintenant';
    return 'Éligible dans ${90 - diffDays} jours';
  }

  String get lastDonationLabel {
    if (lastDonationAt == null) return 'Aucun don enregistré';
    return '${lastDonationAt!.day}/${lastDonationAt!.month}/${lastDonationAt!.year}';
  }

  factory DonorProfile.fromFirestore(Map<String, dynamic> data) {
    DateTime? lastDonation;
    final last = data['lastDonationAt'];
    if (last is Timestamp) {
      lastDonation = last.toDate();
    }
    return DonorProfile(
      bloodGroup: data['bloodGroup'] as String? ?? 'O+',
      available: data['available'] as bool? ?? true,
      lastDonationAt: lastDonation,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'bloodGroup': bloodGroup,
      'available': available,
      'lastDonationAt': lastDonationAt != null
          ? Timestamp.fromDate(lastDonationAt!)
          : null,
    };
  }
}
