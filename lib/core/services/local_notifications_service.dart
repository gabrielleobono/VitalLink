import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Notifications locales (bannière native Android/iOS) déclenchées côté
/// client quand le flux Firestore détecte une alerte sang compatible.
///
/// Ce n'est pas un vrai push FCM : ça ne fonctionne que tant que
/// l'application est encore en mémoire (ouverte ou minimisée), pas si elle a
/// été totalement fermée. Suffisant pour une démo, pas pour la production.
abstract final class LocalNotificationsService {
  static final _plugin = FlutterLocalNotificationsPlugin();

  static const _channel = AndroidNotificationChannel(
    'blood_alerts',
    'Alertes sang compatibles',
    description:
        "Notifie quand une alerte sang correspond à votre groupe et que vous êtes disponible.",
    importance: Importance.high,
  );

  static Future<void> initialize() async {
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings();
    await _plugin.initialize(
      const InitializationSettings(android: androidInit, iOS: iosInit),
    );

    final androidPlugin = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    await androidPlugin?.createNotificationChannel(_channel);
    await androidPlugin?.requestNotificationsPermission();

    await _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >()
        ?.requestPermissions(alert: true, badge: true, sound: true);
  }

  static Future<void> showBloodAlert({
    required String title,
    required String body,
  }) {
    return _plugin.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _channel.id,
          _channel.name,
          channelDescription: _channel.description,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: const DarwinNotificationDetails(),
      ),
    );
  }
}
