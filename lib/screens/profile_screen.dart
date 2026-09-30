import 'package:flutter/material.dart';
import 'edit_profile_screen.dart';
import 'login_screen.dart';

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
  late String name;
  late String phone;
  late String country;
  late String bloodGroup;

  bool isReadyToDonate = false;

  @override
  void initState() {
    super.initState();

    name = widget.name;
    phone = widget.phone;
    country = widget.country;
    bloodGroup = widget.bloodGroup;
  }

  Future<void> editProfile() async {
    final result = await Navigator.push<Map<String, String>>(
      context,
      MaterialPageRoute(
        builder: (context) => EditProfileScreen(
          name: name,
          phone: phone,
          country: country,
          bloodGroup: bloodGroup,
        ),
      ),
    );

    if (result != null) {
      setState(() {
        name = result['name'] ?? name;
        phone = result['phone'] ?? phone;
        country = result['country'] ?? country;
        bloodGroup = result['bloodGroup'] ?? bloodGroup;
      });
    }
  }

  void logout() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text('Mon profil'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const CircleAvatar(radius: 45, child: Icon(Icons.person, size: 50)),

            const SizedBox(height: 20),

            const Text(
              'Profil citoyen',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 30),

            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Nom'),
              subtitle: Text(name),
            ),

            ListTile(
              leading: const Icon(Icons.location_on),
              title: const Text('Ville ou pays'),
              subtitle: Text(country),
            ),

            ListTile(
              leading: const Icon(Icons.bloodtype),
              title: const Text('Groupe sanguin'),
              subtitle: Text(bloodGroup),
            ),

            ListTile(
              leading: const Icon(Icons.phone),
              title: const Text('Téléphone'),
              subtitle: Text(phone),
            ),

            const Divider(),

            SwitchListTile(
              title: const Text(
                'Prêt à donner',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                isReadyToDonate
                    ? 'Vous êtes disponible pour donner du sang'
                    : 'Vous n’êtes pas disponible actuellement',
              ),
              value: isReadyToDonate,
              secondary: Icon(
                isReadyToDonate ? Icons.volunteer_activism : Icons.bloodtype,
              ),
              onChanged: (value) {
                setState(() {
                  isReadyToDonate = value;
                });
              },
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: editProfile,
                icon: const Icon(Icons.edit),
                label: const Text('Modifier mon profil'),
              ),
            ),

            const SizedBox(height: 15),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: logout,
                icon: const Icon(Icons.logout),
                label: const Text('Se déconnecter'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
