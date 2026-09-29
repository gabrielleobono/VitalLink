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

  late String country;
  late String bloodGroup;

  @override
  void initState() {
    super.initState();

    nameController = TextEditingController(text: widget.name);
    phoneController = TextEditingController(text: widget.phone);

    country = widget.country;
    bloodGroup = widget.bloodGroup;
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    super.dispose();
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

            DropdownButtonFormField<String>(
              initialValue: country,
              decoration: const InputDecoration(
                labelText: 'Pays de résidence',
                prefixIcon: Icon(Icons.public),
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(
                  value: 'Burundi',
                  child: Text('Burundi'),
                ),
                DropdownMenuItem(
                  value: 'Rwanda',
                  child: Text('Rwanda'),
                ),
                DropdownMenuItem(
                  value: 'RDC',
                  child: Text('RDC'),
                ),
                DropdownMenuItem(
                  value: 'Tanzanie',
                  child: Text('Tanzanie'),
                ),
                DropdownMenuItem(
                  value: 'Kenya',
                  child: Text('Kenya'),
                ),
              ],
              onChanged: (value) {
                setState(() {
                  country = value!;
                });
              },
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
                setState(() {
                  bloodGroup = value!;
                });
              },
            ),

            const SizedBox(height: 30),

            ElevatedButton.icon(
          onPressed: () {
  Navigator.pop(context, {
    'name': nameController.text,
    'phone': phoneController.text,
    'country': country,
    'bloodGroup': bloodGroup,
  });
},
              icon: const Icon(Icons.save),
              label: const Text('Enregistrer'),
            ),
          ],
        ),
      ),
    );
  }
}