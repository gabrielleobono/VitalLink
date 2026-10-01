import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/firestore_providers.dart';
import '../../data/models/hospital.dart';
import '../../data/repositories/hospital_lookup_repository.dart';

final hospitalLookupRepositoryProvider = Provider<HospitalLookupRepository>((
  ref,
) {
  return HospitalLookupRepository(ref.watch(firestoreProvider));
});

/// Fiche d'un hôpital par son id (`hospitals/{id}`).
final hospitalProvider = FutureProvider.family<Hospital?, String>((
  ref,
  hospitalId,
) {
  return ref.watch(hospitalLookupRepositoryProvider).fetchById(hospitalId);
});
