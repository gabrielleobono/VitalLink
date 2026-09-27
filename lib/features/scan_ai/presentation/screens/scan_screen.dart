import 'package:flutter/material.dart';

/// Écran "Scan d'ordonnance" (placeholder minimal).
class ScanScreen extends StatelessWidget {
  const ScanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Scan d'ordonnance")),
      body: const Center(child: Text("Scan d'ordonnance")),
    );
  }
}
