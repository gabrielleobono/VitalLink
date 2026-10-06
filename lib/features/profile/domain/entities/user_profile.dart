/// Profil citoyen (entité métier).
///
/// VitalLink n'a qu'un seul type de compte — aucune notion de rôle ici,
/// contrairement au document Firestore brut (`UserProfileModel`) qui garde
/// `role: "citizen"` car les règles de sécurité en dépendent encore.
class UserProfile {
  const UserProfile({
    required this.uid,
    required this.displayName,
    required this.email,
    required this.phone,
    required this.country,
    required this.city,
    required this.region,
    required this.verified,
    required this.isDonor,
  });

  final String uid;
  final String displayName;
  final String email;
  final String phone;
  final String country;
  final String city;
  final String region;
  final bool verified;
  final bool isDonor;
}
