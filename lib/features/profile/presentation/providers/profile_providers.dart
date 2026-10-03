import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/firestore_providers.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../data/models/donor_profile.dart';
import '../../data/repositories/profile_repository_impl.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/profile_repository.dart';

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepositoryImpl(ref.watch(firestoreProvider));
});

final userProfileProvider = StreamProvider<UserProfile?>((ref) async* {
  final uid = await ref.watch(currentUserIdProvider.future);
  yield* ref.watch(profileRepositoryProvider).watchUser(uid);
});

final donorProfileProvider = StreamProvider<DonorProfile?>((ref) async* {
  final uid = await ref.watch(currentUserIdProvider.future);
  yield* ref.watch(profileRepositoryProvider).watchDonor(uid);
});

/// Alertes publiées par l'utilisateur courant (pour la carte statistiques).
final myAlertsCountProvider = StreamProvider<int>((ref) async* {
  final uid = await ref.watch(currentUserIdProvider.future);
  yield* ref.watch(profileRepositoryProvider).watchMyAlertsCount(uid);
});

/// Bascule "Prêt à donner" de la carte "Engagement Donneur".
class DonorAvailabilityController {
  DonorAvailabilityController(this._ref);

  final Ref _ref;

  Future<void> setAvailable(bool available) async {
    final uid = await _ref.read(currentUserIdProvider.future);
    await _ref
        .read(profileRepositoryProvider)
        .setDonorAvailability(uid, available);
  }
}

final donorAvailabilityControllerProvider =
    Provider<DonorAvailabilityController>(
      (ref) => DonorAvailabilityController(ref),
    );

/// Création du profil (écran "Compléter mon profil", nouveau numéro).
class ProfileCreationController {
  ProfileCreationController(this._ref);

  final Ref _ref;

  Future<void> createProfile({
    required String displayName,
    required String country,
    required String city,
    required bool isDonor,
    String? bloodGroup,
  }) async {
    final uid = await _ref.read(currentUserIdProvider.future);
    await _ref
        .read(profileRepositoryProvider)
        .createProfile(
          uid: uid,
          displayName: displayName,
          country: country,
          city: city,
          isDonor: isDonor,
          bloodGroup: bloodGroup,
        );
  }
}

final profileCreationControllerProvider = Provider<ProfileCreationController>(
  (ref) => ProfileCreationController(ref),
);
