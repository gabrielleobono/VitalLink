import 'dart:io';

import '../domain/prescription_scan.dart';

enum ScanStatus { initial, loading, success, error }

class ScanState {
  final ScanStatus status;
  final File? selectedImage;
  final PrescriptionScan? scanResult;
  final String? errorMessage;
  final String editedMedicineName;

  const ScanState({
    this.status = ScanStatus.initial,
    this.selectedImage,
    this.scanResult,
    this.errorMessage,
    this.editedMedicineName = '',
  });

  bool get isLoading => status == ScanStatus.loading;
  bool get isSuccess => status == ScanStatus.success;
  bool get hasError => status == ScanStatus.error;

  ScanState copyWith({
    ScanStatus? status,
    File? selectedImage,
    PrescriptionScan? scanResult,
    String? errorMessage,
    String? editedMedicineName,
  }) {
    return ScanState(
      status: status ?? this.status,
      selectedImage: selectedImage ?? this.selectedImage,
      scanResult: scanResult ?? this.scanResult,
      errorMessage: errorMessage,
      editedMedicineName: editedMedicineName ?? this.editedMedicineName,
    );
  }
}
