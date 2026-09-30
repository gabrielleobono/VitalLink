import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/hospital_model.dart';
import '../../data/repositories/hospital_repository.dart';
import 'blood_request_providers.dart' show firestoreProvider;

final hospitalRepositoryProvider = Provider<HospitalRepository>((ref) {
  return HospitalRepository(ref.watch(firestoreProvider));
});

/// Infos d'un hôpital par id (référentiel statique, un simple fetch suffit).
final hospitalByIdProvider = FutureProvider.autoDispose
    .family<HospitalModel, String>((ref, id) {
      return ref.watch(hospitalRepositoryProvider).fetchById(id);
    });

/// Liste complète des hôpitaux, pour le sélecteur du formulaire de création.
final allHospitalsProvider = FutureProvider.autoDispose<List<HospitalModel>>((
  ref,
) {
  return ref.watch(hospitalRepositoryProvider).fetchAll();
});
