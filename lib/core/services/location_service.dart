import 'package:geolocator/geolocator.dart';

/// Accès à la position GPS de l'appareil : permissions, coordonnées
/// actuelles, et calcul de distance entre deux points (en kilomètres).
abstract final class LocationService {
  static const LocationSettings _settings = LocationSettings(
    accuracy: LocationAccuracy.high,
  );

  /// S'assure que le service de localisation est activé et que la permission
  /// est accordée (la demande si nécessaire).
  ///
  /// Renvoie `true` si on peut lire la position, `false` si le service de
  /// localisation est désactivé ou si la permission est refusée — dans ce
  /// dernier cas, à l'appelant de proposer d'ouvrir les réglages via
  /// [Geolocator.openAppSettings] si la permission est refusée définitivement.
  static Future<bool> ensurePermission() async {
    if (!await Geolocator.isLocationServiceEnabled()) return false;

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    return permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always;
  }

  /// Position GPS actuelle, ou `null` si la permission n'est pas accordée
  /// ou le service de localisation est désactivé.
  static Future<Position?> getCurrentPosition() async {
    if (!await ensurePermission()) return null;
    return Geolocator.getCurrentPosition(locationSettings: _settings);
  }

  /// Distance en kilomètres entre deux coordonnées GPS.
  static double distanceInKm({
    required double startLatitude,
    required double startLongitude,
    required double endLatitude,
    required double endLongitude,
  }) {
    final meters = Geolocator.distanceBetween(
      startLatitude,
      startLongitude,
      endLatitude,
      endLongitude,
    );
    return meters / 1000;
  }
}
