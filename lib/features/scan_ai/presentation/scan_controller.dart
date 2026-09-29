import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../data/rodium_prescription_scanner.dart';
import '../domain/prescription_scanner.dart';
import 'scan_state.dart';

/// Provider pour l'instance du scanner
final prescriptionScannerProvider = Provider<PrescriptionScanner>((ref) {
  return RodiumPrescriptionScanner();
});

/// Provider d'état pour le controller (Riverpod 3)
final scanControllerProvider = NotifierProvider<ScanController, ScanState>(
  ScanController.new,
);

class ScanController extends Notifier<ScanState> {
  late final PrescriptionScanner _scanner;
  late final ImagePicker _picker;

  @override
  ScanState build() {
    _scanner = ref.watch(prescriptionScannerProvider);
    _picker = ImagePicker();
    return const ScanState();
  }

  /// Sélectionne une image depuis la caméra ou la galerie et lance le scan
  Future<void> pickAndScan(ImageSource source) async {
    try {
      final pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (pickedFile == null) return;

      final file = File(pickedFile.path);

      state = state.copyWith(
        status: ScanStatus.loading,
        selectedImage: file,
        errorMessage: null,
      );

      final result = await _scanner.scan(file);

      state = state.copyWith(
        status: ScanStatus.success,
        scanResult: result,
        editedMedicineName: result.medicineName,
        errorMessage: null,
      );
    } catch (e) {
      state = state.copyWith(
        status: ScanStatus.error,
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  /// Permet à l'utilisateur de corriger le nom du médicament détecté
  void updateMedicineName(String newName) {
    state = state.copyWith(editedMedicineName: newName.trim());
  }

  /// Réinitialise la capture pour scanner une nouvelle ordonnance
  void reset() {
    state = const ScanState();
  }
}
