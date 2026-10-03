import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/local_notifications_service.dart';
import '../../../../core/utils/blood_compatibility.dart';
import '../../../profile/presentation/providers/profile_providers.dart';
import '../../data/models/blood_alert.dart';
import 'blood_alert_provider.dart';

/// Déclenche une notification locale quand une nouvelle alerte sang ouverte
/// est compatible avec le groupe du donneur courant et qu'il est disponible.
///
/// N'est pas un vrai push FCM (cf. [LocalNotificationsService]) : ne tourne
/// que tant que l'app reste en mémoire. Instancié une seule fois pour toute
/// la session via [bloodAlertNotificationWatcherProvider] (non-autoDispose).
class BloodAlertNotificationWatcher {
  BloodAlertNotificationWatcher(this._ref) {
    _ref.listen<AsyncValue<List<BloodAlert>>>(
      bloodAlertsProvider,
      _onAlerts,
      fireImmediately: true,
    );
  }

  final Ref _ref;
  final Set<String> _seenAlertIds = {};
  bool _isFirstLoad = true;

  void _onAlerts(
    AsyncValue<List<BloodAlert>>? previous,
    AsyncValue<List<BloodAlert>> next,
  ) {
    final alerts = next.asData?.value;
    if (alerts == null) return;

    // Premier chargement : on mémorise les alertes déjà en place sans
    // notifier, pour ne réagir qu'aux nouvelles arrivées ensuite.
    if (_isFirstLoad) {
      _seenAlertIds.addAll(alerts.map((a) => a.id));
      _isFirstLoad = false;
      return;
    }

    final donor = _ref.read(donorProfileProvider).asData?.value;
    final donorGroup = donor != null
        ? BloodCompatibility.fromLabel(donor.bloodGroup)
        : null;

    for (final alert in alerts) {
      if (_seenAlertIds.contains(alert.id)) continue;
      _seenAlertIds.add(alert.id);

      if (donor == null || !donor.available || donorGroup == null) continue;
      final recipientGroup = BloodCompatibility.fromLabel(
        alert.recipientBloodGroup,
      );
      if (recipientGroup == null) continue;
      if (!BloodCompatibility.canDonateTo(
        donor: donorGroup,
        receiver: recipientGroup,
      )) {
        continue;
      }

      LocalNotificationsService.showBloodAlert(
        title: 'Alerte sang compatible : ${alert.recipientBloodGroup}',
        body: alert.hospitalName.isNotEmpty
            ? '${alert.hospitalName} a besoin de vous. Touchez pour répondre.'
            : 'Une urgence proche a besoin de votre groupe sanguin.',
      );
    }
  }
}

final bloodAlertNotificationWatcherProvider =
    Provider<BloodAlertNotificationWatcher>((ref) {
      return BloodAlertNotificationWatcher(ref);
    });
