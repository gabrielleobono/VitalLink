import '../../domain/entities/user_profile.dart';

/// Sérialisation Firestore de [UserProfile] (`users/{uid}` — cf.
/// CONTEXT.md). Le document garde `role`/`verified` pour satisfaire les
/// règles de sécurité héritées du schéma initial, mais `role` n'est pas
/// exposé par l'entité métier : un seul type de compte dans l'app.
class UserProfileModel extends UserProfile {
  const UserProfileModel({
    required super.uid,
    required super.displayName,
    required super.email,
    required super.phone,
    required super.country,
    required super.city,
    required super.verified,
    required super.isDonor,
  });

  factory UserProfileModel.fromFirestore(
    String uid,
    Map<String, dynamic> data,
  ) {
    return UserProfileModel(
      uid: uid,
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
