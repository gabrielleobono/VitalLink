import 'package:url_launcher/url_launcher.dart';

/// Actions de contact "un tap" utilisées sur les fiches pharmacie/hôpital :
/// appel téléphonique natif et itinéraire Google Maps.
///
/// Chaque méthode renvoie `true` si l'application externe a pu être lancée,
/// `false` sinon (aucune app compatible, permission refusée...) — c'est à
/// l'appelant de décider comment le signaler à l'utilisateur (SnackBar, etc.).
abstract final class LauncherService {
  /// Lance l'appel téléphonique natif vers [phoneNumber].
  static Future<bool> callPhone(String phoneNumber) {
    final uri = Uri(scheme: 'tel', path: phoneNumber);
    return launchUrl(uri);
  }

  /// Ouvre l'itinéraire Google Maps vers les coordonnées [latitude]/[longitude].
  static Future<bool> openMapsDirections({
    required double latitude,
    required double longitude,
  }) {
    final uri = Uri.https('www.google.com', '/maps/search/', {
      'api': '1',
      'query': '$latitude,$longitude',
    });
    return launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}
