import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/firestore_providers.dart';
import '../../data/models/blood_alert.dart';
import '../../data/repositories/blood_alert_repository.dart';

final bloodAlertRepositoryProvider = Provider<BloodAlertRepository>((ref) {
  return BloodAlertRepository(ref.watch(firestoreProvider));
});

/// Flux temps réel des alertes de sang ouvertes, les plus récentes d'abord.
final bloodAlertsProvider = StreamProvider<List<BloodAlert>>((ref) {
  return ref.watch(bloodAlertRepositoryProvider).watchOpenAlerts();
});

/// Une alerte précise par id, pour l'écran de détail.
final bloodAlertByIdProvider = StreamProvider.family<BloodAlert?, String>((
  ref,
  alertId,
) {
  return ref.watch(bloodAlertRepositoryProvider).watchAlertById(alertId);
});
