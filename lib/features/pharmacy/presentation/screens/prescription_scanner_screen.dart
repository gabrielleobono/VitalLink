import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_palette.dart';

class PrescriptionScannerScreen extends StatefulWidget {
  const PrescriptionScannerScreen({super.key});

  @override
  State<PrescriptionScannerScreen> createState() =>
      _PrescriptionScannerScreenState();
}

class _PrescriptionScannerScreenState extends State<PrescriptionScannerScreen> {
  final ImagePicker _picker = ImagePicker();
  XFile? _selectedImage;
  bool _isProcessing = false;
  bool _isScanned = false;

  final TextEditingController _medicineController = TextEditingController(
    text: 'Amoxicilline 500mg',
  );
  String _dosage = 'Gélule 500mg';
  String _packaging = 'Boîte de 12/21';
  double _confidence = 98.4;

  @override
  void dispose() {
    _medicineController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 85,
      );

      if (image == null) return;

      setState(() {
        _selectedImage = image;
        _isProcessing = true;
      });

      // Simulation de traitement OCR / IA de vision
      await Future.delayed(const Duration(milliseconds: 1400));

      if (mounted) {
        setState(() {
          _isProcessing = false;
          _isScanned = true;
          _medicineController.text = 'Amoxicilline 500mg';
          _dosage = 'Gélule 500mg';
          _packaging = 'Boîte de 12/21';
          _confidence = 98.4;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isProcessing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de la capture : $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Scaffold(
      backgroundColor: palette.background,
      appBar: AppBar(
        backgroundColor: palette.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: palette.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.tealLight,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.document_scanner_rounded,
                color: AppColors.tealPrimary,
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              "Scan d'ordonnance",
              style: TextStyle(
                color: palette.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: palette.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: palette.border),
              ),
              child: Column(
                children: [
                  Text(
                    'Prenez en photo votre ordonnance',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: palette.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'L\'IA détectera automatiquement les molécules prescrites pour vérifier la disponibilité en pharmacie de garde.',
                    style: TextStyle(
                      fontSize: 13,
                      color: palette.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  if (_selectedImage != null) ...[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        height: 200,
                        width: double.infinity,
                        decoration: BoxDecoration(color: palette.background),
                        child: kIsWeb
                            ? Image.network(
                                _selectedImage!.path,
                                fit: BoxFit.cover,
                              )
                            : Image.file(
                                File(_selectedImage!.path),
                                fit: BoxFit.cover,
                              ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  if (_isProcessing) ...[
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: Column(
                        children: [
                          CircularProgressIndicator(
                            color: AppColors.tealPrimary,
                          ),
                          SizedBox(height: 12),
                          Text(
                            'Analyse OCR et reconnaissance des médicaments...',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: AppColors.tealPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ] else ...[
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _pickImage(ImageSource.camera),
                            icon: const Icon(
                              Icons.camera_alt_rounded,
                              size: 18,
                            ),
                            label: const Text('Appareil Photo'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.tealPrimary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _pickImage(ImageSource.gallery),
                            icon: const Icon(
                              Icons.photo_library_rounded,
                              size: 18,
                            ),
                            label: const Text('Galerie'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: palette.textPrimary,
                              side: BorderSide(color: palette.border),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            if (_isScanned) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: palette.surface,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: AppColors.tealPrimary.withValues(alpha: 0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.check_circle_rounded,
                          color: AppColors.tealPrimary,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Médicament détecté',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: palette.textPrimary,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.tealLight,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '$_confidence% certitude',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppColors.tealPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _medicineController,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: palette.textPrimary,
                      ),
                      decoration: InputDecoration(
                        labelText: 'Nom du médicament',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Forme : $_dosage\nConditionnement : $_packaging',
                            style: TextStyle(
                              fontSize: 12,
                              color: palette.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(
                            context,
                            _medicineController.text.trim(),
                          );
                        },
                        icon: const Icon(Icons.search_rounded, size: 18),
                        label: const Text('Rechercher dans les pharmacies'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.tealPrimary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
