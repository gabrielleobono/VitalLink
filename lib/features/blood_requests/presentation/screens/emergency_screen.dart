import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';

/// Écran "Urgences" : point d'entrée vers la publication d'une alerte.
class EmergencyScreen extends StatelessWidget {
  const EmergencyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Urgences')),
      body: const Center(child: Text('Urgences')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(AppRoutes.createEmergency),
        icon: const Icon(Icons.add_alert_rounded),
        label: const Text('Nouvelle alerte'),
      ),
    );
  }
}
