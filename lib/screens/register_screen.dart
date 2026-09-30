import 'package:flutter/material.dart';
import 'profile_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final countryController = TextEditingController();
  final passwordController = TextEditingController();

  String bloodGroup = 'Non renseigné';

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    countryController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void register() {
    if (nameController.text.trim().isEmpty ||
        phoneController.text.trim().isEmpty ||
        countryController.text.trim().isEmpty ||
        passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez remplir tous les champs')),
      );
      return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => ProfileScreen(
          name: nameController.text.trim(),
          phone: phoneController.text.trim(),
          country: countryController.text.trim(),
          bloodGroup: bloodGroup,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Créer un compte')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Icon(Icons.person_add, size: 70),

            const SizedBox(height: 20),

            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Nom complet',
                prefixIcon: Icon(Icons.person),
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 15),

            TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Téléphone',
                prefixIcon: Icon(Icons.phone),
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 15),

            TextField(
              controller: countryController,
              decoration: const InputDecoration(
                labelText: 'Ville ou pays',
                hintText: 'Ex : Bujumbura',
                prefixIcon: Icon(Icons.location_on),
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 15),

            DropdownButtonFormField<String>(
              initialValue: bloodGroup,
              decoration: const InputDecoration(
                labelText: 'Groupe sanguin',
                prefixIcon: Icon(Icons.bloodtype),
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(
                  value: 'Non renseigné',
                  child: Text('Non renseigné'),
                ),
                DropdownMenuItem(value: 'A+', child: Text('A+')),
                DropdownMenuItem(value: 'A-', child: Text('A-')),
                DropdownMenuItem(value: 'B+', child: Text('B+')),
                DropdownMenuItem(value: 'B-', child: Text('B-')),
                DropdownMenuItem(value: 'AB+', child: Text('AB+')),
                DropdownMenuItem(value: 'AB-', child: Text('AB-')),
                DropdownMenuItem(value: 'O+', child: Text('O+')),
                DropdownMenuItem(value: 'O-', child: Text('O-')),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    bloodGroup = value;
                  });
                }
              },
            ),

            const SizedBox(height: 15),

            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Mot de passe',
                prefixIcon: Icon(Icons.lock),
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 25),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: register,
                child: const Text('Créer mon compte'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
