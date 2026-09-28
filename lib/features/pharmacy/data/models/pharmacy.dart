class Pharmacy {
  final String id;
  final String name;
  final String address;
  final String neighborhood;
  final String phoneNumber;
  final double latitude;
  final double longitude;
  final bool isOnDuty;
  final String dutySchedule;
  final bool isVerified;
  final List<String> services;
  final List<String> availableMedicines;
  final double? distanceInMeters;

  const Pharmacy({
    required this.id,
    required this.name,
    required this.address,
    required this.neighborhood,
    required this.phoneNumber,
    required this.latitude,
    required this.longitude,
    required this.isOnDuty,
    required this.dutySchedule,
    this.isVerified = true,
    this.services = const [],
    this.availableMedicines = const [],
    this.distanceInMeters,
  });

  String get formattedDistance {
    if (distanceInMeters == null) return '';
    if (distanceInMeters! < 1000) {
      return '${distanceInMeters!.round()} m';
    }
    return '${(distanceInMeters! / 1000).toStringAsFixed(1)} km';
  }

  factory Pharmacy.fromMap(Map<String, dynamic> map, String docId) {
    return Pharmacy(
      id: docId,
      name: map['name'] as String? ?? 'Pharmacie',
      address: map['address'] as String? ?? '',
      neighborhood: map['neighborhood'] as String? ?? '',
      phoneNumber: map['phoneNumber'] as String? ?? '',
      latitude: (map['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (map['longitude'] as num?)?.toDouble() ?? 0.0,
      isOnDuty: map['isOnDuty'] as bool? ?? false,
      dutySchedule: map['dutySchedule'] as String? ?? '',
      isVerified: map['isVerified'] as bool? ?? true,
      services: (map['services'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      availableMedicines: (map['availableMedicines'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'address': address,
      'neighborhood': neighborhood,
      'phoneNumber': phoneNumber,
      'latitude': latitude,
      'longitude': longitude,
      'isOnDuty': isOnDuty,
      'dutySchedule': dutySchedule,
      'isVerified': isVerified,
      'services': services,
      'availableMedicines': availableMedicines,
    };
  }

  Pharmacy copyWith({
    double? distanceInMeters,
  }) {
    return Pharmacy(
      id: id,
      name: name,
      address: address,
      neighborhood: neighborhood,
      phoneNumber: phoneNumber,
      latitude: latitude,
      longitude: longitude,
      isOnDuty: isOnDuty,
      dutySchedule: dutySchedule,
      isVerified: isVerified,
      services: services,
      availableMedicines: availableMedicines,
      distanceInMeters: distanceInMeters ?? this.distanceInMeters,
    );
  }
}
