import 'package:flutter/material.dart';

/// Écran "Pharmacies de garde" (placeholder minimal).
class PharmaciesScreen extends StatelessWidget {
  const PharmaciesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pharmacies de garde')),
      body: const Center(child: Text('Pharmacies de garde')),
    );
  }
}
