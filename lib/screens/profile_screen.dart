
import 'package:flutter/material.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  final String name;
  final String phone;
  final String country;
  final String bloodGroup;

  const ProfileScreen({
    super.key,
    required this.name,
    required this.phone,
    required this.country,
    required this.bloodGroup,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool isReadyToDonate = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mon profil'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 45,
              child: Icon(
                Icons.person,
                size: 50,
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              'Profil citoyen',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 30),

            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Nom'),
              subtitle: Text(widget.name),
            ),

            ListTile(
              leading: const Icon(Icons.public),
              title: const Text('Pays'),
              subtitle: Text(widget.country),
            ),

            ListTile(
              leading: const Icon(Icons.bloodtype),
              title: const Text('Groupe sanguin'),
              subtitle: Text(widget.bloodGroup),
            ),

            ListTile(
              leading: const Icon(Icons.phone),
              title: const Text('Téléphone'),
              subtitle: Text(widget.phone),
            ),

            const Divider(),

            SwitchListTile(
              title: const Text(
                'Prêt à donner',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(
                isReadyToDonate
                    ? 'Vous êtes disponible pour donner du sang'
                    : 'Vous n’êtes pas disponible actuellement',
              ),
              value: isReadyToDonate,
              secondary: Icon(
                isReadyToDonate
                    ? Icons.volunteer_activism
                    : Icons.bloodtype,
              ),
              onChanged: (value) {
                setState(() {
                  isReadyToDonate = value;
                });
              },
            ),

            const SizedBox(height: 20),

            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                  builder: (context) => EditProfileScreen(
  name: widget.name,
  phone: widget.phone,
  country: widget.country,
  bloodGroup: widget.bloodGroup,
),
                  ),
                );
              },
              icon: const Icon(Icons.edit),
              label: const Text('Modifier mon profil'),
            ),
          ],
        ),
      ),
    );
  }
}
