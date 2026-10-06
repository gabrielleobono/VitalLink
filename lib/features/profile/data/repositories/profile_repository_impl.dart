import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/profile_repository.dart';
import '../models/donor_profile.dart';
import '../models/user_profile_model.dart';

/// Accès Firestore aux collections `users` et `donors` du profil courant.
/// Séparées (cf. CONTEXT.md) pour limiter l'accès aux données sensibles du
/// donneur côté règles de sécurité.
class ProfileRepositoryImpl implements ProfileRepository {
  ProfileRepositoryImpl(this._firestore);

  final FirebaseFirestore _firestore;

  @override
  Stream<UserProfile?> watchUser(String uid) {
    return _firestore
        .collection('users')
        .doc(uid)
        .snapshots()
        .map(
          (doc) => doc.exists
              ? UserProfileModel.fromFirestore(uid, doc.data()!)
              : null,
        );
  }

  @override
  Stream<DonorProfile?> watchDonor(String uid) {
    return _firestore
        .collection('donors')
        .doc(uid)
        .snapshots()
        .map(
          (doc) => doc.exists ? DonorProfile.fromFirestore(doc.data()!) : null,
        );
  }

  @override
  Stream<int> watchMyAlertsCount(String uid) {
    return _firestore
        .collection('bloodAlerts')
        .where('createdBy', isEqualTo: uid)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  @override
  Future<void> setDonorAvailability(String uid, bool available) async {
    await _firestore.collection('donors').doc(uid).set({
      'available': available,
    }, SetOptions(merge: true));
    await _firestore.collection('users').doc(uid).set({
      'isDonor': available,
    }, SetOptions(merge: true));
  }

  @override
  Future<void> createProfile({
    required String uid,
    required String displayName,
    required String country,
    required String city,
    required String region,
    required bool isDonor,
    String? bloodGroup,
  }) async {
    await _firestore.collection('users').doc(uid).set({
      'role': 'citizen',
      'displayName': displayName,
      'email': '',
      'phone': '',
      'country': country,
      'city': city,
      'region': region,
      'verified': false,
      'isDonor': isDonor,
      'fcmTokens': <String>[],
      'createdAt': FieldValue.serverTimestamp(),
    });
    if (bloodGroup != null) {
      await _firestore.collection('donors').doc(uid).set({
        'bloodGroup': bloodGroup,
        'available': isDonor,
        'lastDonationAt': null,
      });
    }
  }

  @override
  Future<void> updateLocation({
    required String uid,
    required String country,
    required String city,
    required String region,
  }) async {
    await _firestore.collection('users').doc(uid).set({
      'country': country,
      'city': city,
      'region': region,
    }, SetOptions(merge: true));
  }
}
