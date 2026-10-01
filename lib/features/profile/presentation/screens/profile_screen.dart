import 'package:flutter/material.dart';

/// Écran "Profil" (placeholder minimal).
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profil')),
      body: const Center(child: Text('Profil')),
    );
  }
}
