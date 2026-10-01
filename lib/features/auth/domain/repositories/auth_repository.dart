import '../entities/user_entity.dart';

/// Accès abstrait à l'authentification. [AuthRepositoryImpl] est la seule
/// classe de l'app qui importe `firebase_auth` — tout le reste (écrans,
/// providers) passe par cette interface.
abstract class AuthRepository {
  Stream<UserEntity?> authStateChanges();

  UserEntity? get currentUser;

  /// Envoie le code SMS. [onCodeSent] reçoit le `verificationId` à repasser
  /// à [confirmOtp]. [onAutoVerified] est appelé si Android valide le code
  /// automatiquement (sans saisie), auquel cas la connexion est déjà faite.
  Future<void> sendOtp({
    required String phoneNumber,
    required void Function(String verificationId) onCodeSent,
    required void Function(String message) onError,
    required void Function(UserEntity user) onAutoVerified,
  });

  Future<UserEntity> confirmOtp({
    required String verificationId,
    required String smsCode,
  });

  /// Identité de repli tant qu'aucun numéro n'est vérifié (navigation
  /// invité, actions nécessitant un `uid` stable).
  Future<UserEntity> signInAnonymously();

  Future<void> signOut();
}
