import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import '../../data/models/pharmacy.dart';
import '../../data/repositories/pharmacy_repository.dart';

enum PharmacyFilter { all, onDutyOnly }

final pharmacyRepositoryProvider = Provider<PharmacyRepository>((ref) {
  return PharmacyRepository();
});

final userPositionProvider = FutureProvider<Position?>((ref) async {
  bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) return null;

  LocationPermission permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) return null;
  }
  if (permission == LocationPermission.deniedForever) return null;

  try {
    return await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.medium,
        timeLimit: Duration(seconds: 4),
      ),
    );
  } catch (_) {
    return null;
  }
});

class PharmacySearchQueryNotifier extends Notifier<String> {
  @override
  String build() => '';

  void setQuery(String q) => state = q;
}

final pharmacySearchQueryProvider =
    NotifierProvider<PharmacySearchQueryNotifier, String>(
      PharmacySearchQueryNotifier.new,
    );

class PharmacyFilterNotifier extends Notifier<PharmacyFilter> {
  @override
  PharmacyFilter build() => PharmacyFilter.all;

  void setFilter(PharmacyFilter f) => state = f;
}

final pharmacyFilterProvider =
    NotifierProvider<PharmacyFilterNotifier, PharmacyFilter>(
      PharmacyFilterNotifier.new,
    );

final rawPharmaciesStreamProvider = StreamProvider.autoDispose<List<Pharmacy>>((
  ref,
) {
  final repo = ref.watch(pharmacyRepositoryProvider);
  return repo.watchPharmacies();
});

final filteredPharmaciesProvider = Provider<List<Pharmacy>>((ref) {
  final pharmaciesAsync = ref.watch(rawPharmaciesStreamProvider);
  final query = ref.watch(pharmacySearchQueryProvider).trim().toLowerCase();
  final filter = ref.watch(pharmacyFilterProvider);
  final userPos = ref.watch(userPositionProvider).asData?.value;

  final pharmacies =
      pharmaciesAsync.asData?.value ?? PharmacyRepository.fallbackPharmacies;

  var list = pharmacies.map((pharmacy) {
    if (userPos != null &&
        pharmacy.latitude != 0.0 &&
        pharmacy.longitude != 0.0) {
      final distance = Geolocator.distanceBetween(
        userPos.latitude,
        userPos.longitude,
        pharmacy.latitude,
        pharmacy.longitude,
      );
      return pharmacy.copyWith(distanceInMeters: distance);
    }
    return pharmacy;
  }).toList();

  // Filtrage : Officines de garde confirmée uniquement
  if (filter == PharmacyFilter.onDutyOnly) {
    list = list.where((p) => p.isOnDuty).toList();
  }

  // Filtrage par texte de recherche
  if (query.isNotEmpty) {
    list = list.where((p) {
      final matchName = p.name.toLowerCase().contains(query);
      final matchAddr = p.address.toLowerCase().contains(query);
      final matchNeigh = p.neighborhood.toLowerCase().contains(query);
      final matchMed = p.availableMedicines.any(
        (m) => m.toLowerCase().contains(query),
      );
      return matchName || matchAddr || matchNeigh || matchMed;
    }).toList();
  }

  // Tri par proximité puis statut de garde
  list.sort((a, b) {
    if (a.distanceInMeters != null && b.distanceInMeters != null) {
      return a.distanceInMeters!.compareTo(b.distanceInMeters!);
    }
    if (a.isOnDuty && !b.isOnDuty) return -1;
    if (!a.isOnDuty && b.isOnDuty) return 1;
    return a.name.compareTo(b.name);
  });

  return list;
});
