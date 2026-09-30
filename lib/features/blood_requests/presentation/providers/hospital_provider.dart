import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/hospital.dart';

/// Fiche d'un hôpital par son id (`hospitals/{id}`).
final hospitalProvider = FutureProvider.family<Hospital?, String>((
  ref,
  hospitalId,
) async {
  if (hospitalId.isEmpty) return null;
  final snapshot = await FirebaseFirestore.instance
      .collection('hospitals')
      .doc(hospitalId)
      .get();
  if (!snapshot.exists) return null;
  return Hospital.fromFirestore(snapshot.id, snapshot.data()!);
});
