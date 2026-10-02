/// Seuils indicatifs utilisés par le quiz d'éligibilité du Guide du donneur
/// (`donor_guide`). Valeurs standards de la transfusion sanguine — ne
/// remplacent jamais l'avis du personnel médical.
abstract final class DonorEligibilityConstants {
  static const int minAge = 18;
  static const int maxAge = 65;
  static const int minWeightKg = 50;
  static const int minDaysSinceLastDonation = 90;
  static const int minDaysSinceIllness = 14;
  static const int minDaysSinceTattoo = 120;
  static const int minMonthsSincePregnancy = 6;
}
