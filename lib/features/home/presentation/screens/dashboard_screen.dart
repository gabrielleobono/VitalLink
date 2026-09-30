import 'package:flutter/material.dart';

/// Écran "Accueil" (placeholder minimal).
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Accueil')),
      body: const Center(child: Text('Accueil')),
    );
  }
}
