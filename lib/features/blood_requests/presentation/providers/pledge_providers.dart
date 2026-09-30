import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/pledge_repository.dart';
import 'blood_request_providers.dart' show firestoreProvider;

final pledgeRepositoryProvider = Provider<PledgeRepository>((ref) {
  return PledgeRepository(ref.watch(firestoreProvider));
});
