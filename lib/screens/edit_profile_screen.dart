import 'package:flutter/material.dart';

class EditProfileScreen extends StatefulWidget {
  final String name;
  final String phone;
  final String country;
  final String bloodGroup;

  const EditProfileScreen({
    super.key,
    required this.name,
    required this.phone,
    required this.country,
    required this.bloodGroup,
  });

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController nameController;
  late TextEditingController phoneController;
  late TextEditingController countryController;

  late String bloodGroup;

  @override
  void initState() {
    super.initState();

    nameController = TextEditingController(text: widget.name);
    phoneController = TextEditingController(text: widget.phone);
    countryController = TextEditingController(text: widget.country);

    // Si aucune valeur valide n'est fournie, on utilise "Non renseigné".
    const bloodGroups = [
      'Non renseigné',
      'A+',
      'A-',
      'B+',
      'B-',
      'AB+',
      'AB-',
      'O+',
      'O-',
    ];

    bloodGroup = bloodGroups.contains(widget.bloodGroup)
        ? widget.bloodGroup
        : 'Non renseigné';
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    countryController.dispose();
    super.dispose();
  }

  void saveProfile() {
    Navigator.pop(context, {
      'name': nameController.text.trim(),
      'phone': phoneController.text.trim(),
      'country': countryController.text.trim(),
      'bloodGroup': bloodGroup,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Modifier mon profil'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Nom',
                prefixIcon: Icon(Icons.person),
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Téléphone',
                prefixIcon: Icon(Icons.phone),
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            TextField(
              controller: countryController,
              decoration: const InputDecoration(
                labelText: 'Ville ou pays',
                prefixIcon: Icon(Icons.location_on),
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

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
                DropdownMenuItem(
                  value: 'A+',
                  child: Text('A+'),
                ),
                DropdownMenuItem(
                  value: 'A-',
                  child: Text('A-'),
                ),
                DropdownMenuItem(
                  value: 'B+',
                  child: Text('B+'),
                ),
                DropdownMenuItem(
                  value: 'B-',
                  child: Text('B-'),
                ),
                DropdownMenuItem(
                  value: 'AB+',
                  child: Text('AB+'),
                ),
                DropdownMenuItem(
                  value: 'AB-',
                  child: Text('AB-'),
                ),
                DropdownMenuItem(
                  value: 'O+',
                  child: Text('O+'),
                ),
                DropdownMenuItem(
                  value: 'O-',
                  child: Text('O-'),
                ),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    bloodGroup = value;
                  });
                }
              },
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: saveProfile,
                icon: const Icon(Icons.save),
                label: const Text('Enregistrer'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}