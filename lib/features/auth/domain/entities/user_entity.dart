/// Identité d'authentification (Firebase Auth), indépendante de Firestore.
class UserEntity {
  const UserEntity({required this.uid, this.phoneNumber});

  final String uid;
  final String? phoneNumber;
}
