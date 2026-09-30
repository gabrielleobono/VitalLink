import 'package:flutter/material.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Conditions d’utilisation')),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Conditions d’utilisation',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Text(
              'En utilisant VitalLink, vous acceptez les conditions '
              'd’utilisation de l’application.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            Text(
              'VitalLink permet aux citoyens de créer un profil et '
              'd’indiquer leur disponibilité pour le don de sang.',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
