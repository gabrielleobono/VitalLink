import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/firestore_providers.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../data/models/blood_alert.dart';
import '../../data/repositories/blood_alert_repository.dart';

final bloodAlertRepositoryProvider = Provider<BloodAlertRepository>((ref) {
  return BloodAlertRepository(ref.watch(firestoreProvider));
});

/// Flux temps réel des alertes de sang ouvertes, les plus récentes d'abord.
final bloodAlertsProvider = StreamProvider<List<BloodAlert>>((ref) {
  return ref.watch(bloodAlertRepositoryProvider).watchOpenAlerts();
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
