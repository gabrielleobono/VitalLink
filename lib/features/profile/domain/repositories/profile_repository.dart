import '../../data/models/donor_profile.dart';
import '../entities/user_profile.dart';

/// Accès abstrait au profil citoyen. [ProfileRepositoryImpl] est la seule
/// classe qui importe Firestore pour `users`/`donors`.
abstract class ProfileRepository {
  Stream<UserProfile?> watchUser(String uid);

  Stream<DonorProfile?> watchDonor(String uid);

  /// Alertes publiées par cet utilisateur (carte statistiques du Profil).
  Stream<int> watchMyAlertsCount(String uid);

  /// Bascule "Prêt à donner" — crée `donors/{uid}` au premier passage à
  /// `true` et répercute l'état sur `users/{uid}.isDonor`.
  Future<void> setDonorAvailability(String uid, bool available);

  /// Complète le profil d'un nouveau numéro après connexion OTP.
  Future<void> createProfile({
    required String uid,
    required String displayName,
    required String country,
    required String city,
    required String region,
    required bool isDonor,
    String? bloodGroup,
  });

  /// Met à jour uniquement la localisation (écran "Modifier ma
  /// localisation" du Profil) — ex: un donneur qui déménage, ou un profil
  /// créé avant l'ajout du champ région.
  Future<void> updateLocation({
    required String uid,
    required String country,
    required String city,
    required String region,
  });
}
