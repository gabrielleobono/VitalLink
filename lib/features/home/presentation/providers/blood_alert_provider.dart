import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/firestore_providers.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../profile/presentation/providers/profile_providers.dart';
import '../../data/models/blood_alert.dart';
import '../../data/repositories/blood_alert_repository.dart';

final bloodAlertRepositoryProvider = Provider<BloodAlertRepository>((ref) {
  return BloodAlertRepository(ref.watch(firestoreProvider));
});

/// Flux temps réel des alertes de sang ouvertes de la zone de l'utilisateur
/// (même pays + même région/province), les plus récentes d'abord. Tant que
/// le profil n'a pas encore de pays/région connu, la liste reste vide plutôt
/// que de montrer des alertes potentiellement hors zone.
final bloodAlertsProvider = StreamProvider<List<BloodAlert>>((ref) async* {
  final profile = await ref.watch(userProfileProvider.future);
  if (profile == null || profile.country.isEmpty || profile.region.isEmpty) {
    yield const [];
    return;
  }
  yield* ref
      .watch(bloodAlertRepositoryProvider)
      .watchOpenAlerts(country: profile.country, region: profile.region);
});

/// Alertes publiées par l'utilisateur courant (écran "Mes alertes" du Profil).
final myAlertsProvider = StreamProvider<List<BloodAlert>>((ref) async* {
  final uid = await ref.watch(currentUserIdProvider.future);
  yield* ref.watch(bloodAlertRepositoryProvider).watchMyAlerts(uid);
});

/// Une alerte précise par id, pour l'écran de détail.
final bloodAlertByIdProvider = StreamProvider.family<BloodAlert?, String>((
  ref,
  alertId,
) {
  return ref.watch(bloodAlertRepositoryProvider).watchAlertById(alertId);
});
