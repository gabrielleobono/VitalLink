import 'package:cloud_firestore/cloud_firestore.dart';

/// `hospitals/{id}` — voir CONTEXT.md > "Modèle de données".
class Hospital {
  const Hospital({
    required this.id,
    required this.name,
    required this.address,
    required this.phone,
    required this.city,
    required this.location,
  });

  final String id;
  final String name;
  final String address;
  final String phone;
  final String city;
  final GeoPoint location;

  factory Hospital.fromFirestore(String id, Map<String, dynamic> data) {
    return Hospital(
      id: id,
      name: data['name'] as String? ?? '',
      address: data['address'] as String? ?? '',
      phone: data['phone'] as String? ?? '',
      city: data['city'] as String? ?? '',
      location: data['location'] as GeoPoint? ?? const GeoPoint(0, 0),
    );
  }
}
