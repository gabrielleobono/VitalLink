import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';

final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(ref.watch(firebaseAuthProvider));
});

/// Flux de l'utilisateur connecté (`null` si déconnecté) — utilisé par le
/// routeur pour décider entre Sign In, Compléter le profil et Accueil.
final authStateProvider = StreamProvider<UserEntity?>((ref) {
  return ref.watch(authRepositoryProvider).authStateChanges();
});

/// Id de l'utilisateur courant, toujours non-null.
///
/// Tant qu'aucun numéro n'est vérifié, on se connecte anonymement pour avoir
/// un identifiant stable (navigation invité, engagement donneur). Firebase
/// permet nativement de migrer un compte anonyme vers un vrai compte plus
/// tard, donc ceci n'est pas jetable.
///
/// Dépend de [authStateProvider] (pas d'un simple accès à
/// `repository.currentUser`) pour se recalculer à chaque connexion/
/// déconnexion, plutôt que de rester figé sur l'ancien uid.
final currentUserIdProvider = FutureProvider<String>((ref) async {
  final authUser = await ref.watch(authStateProvider.future);
  if (authUser != null) return authUser.uid;
  final repository = ref.watch(authRepositoryProvider);
  final user = await repository.signInAnonymously();
  return user.uid;
});

/// Connexion par téléphone (OTP) et déconnexion — seul point d'entrée vers
/// l'authentification pour les écrans : ils n'appellent jamais
/// `FirebaseAuth.instance` eux-mêmes, uniquement ce contrôleur.
class PhoneAuthController {
  PhoneAuthController(this._ref);

  final Ref _ref;

  Future<void> sendCode({
    required String phoneNumber,
    required void Function(String verificationId) onCodeSent,
    required void Function(String message) onError,
    required void Function() onAutoVerified,
  }) {
    return _ref
        .read(authRepositoryProvider)
        .sendOtp(
          phoneNumber: phoneNumber,
          onCodeSent: onCodeSent,
          onError: onError,
          onAutoVerified: (_) => onAutoVerified(),
        );
  }

  Future<void> confirmCode({
    required String verificationId,
    required String smsCode,
  }) {
    return _ref
        .read(authRepositoryProvider)
        .confirmOtp(verificationId: verificationId, smsCode: smsCode);
  }

  Future<void> signOut() => _ref.read(authRepositoryProvider).signOut();
}

final phoneAuthControllerProvider = Provider<PhoneAuthController>((ref) {
  return PhoneAuthController(ref);
});
