import 'package:firebase_auth/firebase_auth.dart';

import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._firebaseAuth);

  final FirebaseAuth _firebaseAuth;

  UserEntity _toEntity(User user) =>
      UserEntity(uid: user.uid, phoneNumber: user.phoneNumber);

  @override
  Stream<UserEntity?> authStateChanges() {
    return _firebaseAuth.authStateChanges().map(
      (user) => user == null ? null : _toEntity(user),
    );
  }

  @override
  UserEntity? get currentUser {
    final user = _firebaseAuth.currentUser;
    return user == null ? null : _toEntity(user);
  }

  @override
  Future<void> sendOtp({
    required String phoneNumber,
    required void Function(String verificationId) onCodeSent,
    required void Function(String message) onError,
    required void Function(UserEntity user) onAutoVerified,
  }) {
    return _firebaseAuth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (credential) async {
        final result = await _firebaseAuth.signInWithCredential(credential);
        final user = result.user;
        if (user != null) onAutoVerified(_toEntity(user));
      },
      verificationFailed: (e) =>
          onError(e.message ?? "L'envoi du code a échoué."),
      codeSent: (verificationId, _) => onCodeSent(verificationId),
      codeAutoRetrievalTimeout: (_) {},
    );
  }

  @override
  Future<UserEntity> confirmOtp({
    required String verificationId,
    required String smsCode,
  }) async {
    final credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: smsCode,
    );
    final result = await _firebaseAuth.signInWithCredential(credential);
    final user = result.user;
    if (user == null) {
      throw StateError('Connexion par OTP impossible.');
    }
    return _toEntity(user);
  }

  @override
  Future<UserEntity> signInAnonymously() async {
    final result = await _firebaseAuth.signInAnonymously();
    final user = result.user;
    if (user == null) {
      throw StateError('Connexion anonyme Firebase impossible.');
    }
    return _toEntity(user);
  }

  @override
  Future<void> signOut() => _firebaseAuth.signOut();
}
