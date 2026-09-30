import 'package:flutter/material.dart';

/// Écran "Urgences" (placeholder minimal).
class EmergencyScreen extends StatelessWidget {
  const EmergencyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Urgences')),
      body: const Center(child: Text('Urgences')),
    );
  }
}
