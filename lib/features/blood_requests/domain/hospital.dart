/// Établissement de santé référencé par une alerte (spec : table `hospitals`).
///
/// [emergencyPhone] est le numéro **institutionnel** du standard, jamais un
/// numéro personnel : c'est ce que le donneur appelle après engagement.
class Hospital {
  const Hospital({
    required this.id,
    required this.name,
    required this.city,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.emergencyPhone,
  });

  final String id;
  final String name;
  final String city;
  final String address;
  final double latitude;
  final double longitude;
  final String emergencyPhone;
}
