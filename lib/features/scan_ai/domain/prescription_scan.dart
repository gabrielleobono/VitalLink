class PrescriptionScan {
  final String medicineName;
  final String? dosage;
  final String? packaging;
  final double confidence;

  const PrescriptionScan({
    required this.medicineName,
    this.dosage,
    this.packaging,
    required this.confidence,
  });

  PrescriptionScan copyWith({
    String? medicineName,
    String? dosage,
    String? packaging,
    double? confidence,
  }) {
    return PrescriptionScan(
      medicineName: medicineName ?? this.medicineName,
      dosage: dosage ?? this.dosage,
      packaging: packaging ?? this.packaging,
      confidence: confidence ?? this.confidence,
    );
  }
}
