/// Profil public d'un utilisateur (`users/{uid}` — cf. CONTEXT.md).
class UserProfile {
  const UserProfile({
    required this.uid,
    required this.role,
    required this.displayName,
    required this.email,
    required this.phone,
    required this.country,
    required this.city,
    required this.verified,
    required this.isDonor,
  });

  final String uid;
  final String role;
  final String displayName;
  final String email;
  final String phone;
  final String country;
  final String city;
  final bool verified;
  final bool isDonor;

  factory UserProfile.fromFirestore(String uid, Map<String, dynamic> data) {
    return UserProfile(
      uid: uid,
      role: data['role'] as String? ?? 'citizen',
      displayName: data['displayName'] as String? ?? 'Utilisateur VitalLink',
      email: data['email'] as String? ?? '',
      phone: data['phone'] as String? ?? '',
      country: data['country'] as String? ?? '',
      city: data['city'] as String? ?? '',
      verified: data['verified'] as bool? ?? false,
      isDonor: data['isDonor'] as bool? ?? false,
    );
  }
}
