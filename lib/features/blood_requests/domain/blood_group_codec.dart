import '../../../core/utils/blood_compatibility.dart';

/// Convertit le libellé stocké ("A+", "O-", ...) en [BloodGroup].
///
/// Lève une [FormatException] si le libellé est inconnu : un groupe sanguin
/// ne doit jamais être deviné.
BloodGroup bloodGroupFromLabel(String label) {
  for (final group in BloodGroup.values) {
    if (group.label == label) return group;
  }
  throw FormatException('Groupe sanguin inconnu : "$label"');
}
