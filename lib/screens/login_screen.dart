import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'register_screen.dart';
import 'profile_screen.dart';
import 'terms_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();

  bool obscurePassword = true;

  void login() {
    if (phoneController.text.isEmpty ||
        passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez remplir tous les champs'),
        ),
      );
      return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => ProfileScreen(
          name: 'Citoyen VitalLink',
          phone: phoneController.text,
          country: 'Burundi',
          bloodGroup: 'Non renseigné',
        ),
      ),
    );
  }

  void loginAsGuest() {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => const ProfileScreen(
        name: 'Invité',
        phone: 'Non renseigné',
        country: 'Non renseigné',
        bloodGroup: 'Non renseigné',
      ),
    ),
  );
}

  void requestOtp() {
    if (phoneController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Veuillez entrer votre numéro de téléphone',
          ),
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Code OTP envoyé à votre numéro'),
      ),
    );
  }

  @override
  void dispose() {
    phoneController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FC),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
          child: Column(
            children: [
              // En-tête
              Row(
                children: [
                  IconButton(
                    onPressed: () {
                      Navigator.maybePop(context);
                    },
                    icon: const Icon(Icons.arrow_back),
                  ),

                  const SizedBox(width: 8),

                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE92929),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.bloodtype,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),

                  const SizedBox(width: 12),

                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'VitalLink',
                        style: TextStyle(
                          fontSize: 21,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF172033),
                        ),
                      ),
                      Text(
                        'Sign In',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF777D8A),
                        ),
                      ),
                    ],
                  ),

                  const Spacer(),

                  Container(
                    width: 46,
                    height: 46,
                    decoration: const BoxDecoration(
                      color: Color(0xFFE92929),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.person_outline,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Message d'accueil
              const Text(
                'Connectez-vous pour sauver des vies ou trouver\n'
                'une aide urgente en quelques secondes.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 17,
                  height: 1.4,
                  color: Color(0xFF4F5563),
                ),
              ),

              const SizedBox(height: 22),

              // Carte Don de sang / Pharmacies
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFFEAF9FA),
                      Color(0xFFF0F2FF),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          _buildSmallIcon(
                            Icons.bloodtype_outlined,
                            const Color(0xFFE92929),
                          ),
                          const SizedBox(width: 10),
                          const Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Don de sang',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFD92323),
                                ),
                              ),
                              Text(
                                'Réseau urgent',
                                style: TextStyle(
                                  color: Color(0xFF777D8A),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    Container(
                      width: 1,
                      height: 45,
                      color: Colors.white,
                    ),

                    Expanded(
                      child: Row(
                        children: [
                          _buildSmallIcon(
                            Icons.local_pharmacy_outlined,
                            const Color(0xFF1DAA9A),
                          ),
                          const SizedBox(width: 10),
                          const Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Pharmacies',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF168C80),
                                ),
                              ),
                              Text(
                                'Gardes en direct',
                                style: TextStyle(
                                  color: Color(0xFF777D8A),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 22),

              // Carte connexion
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.phone_android,
                          color: Color(0xFFE92929),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Numéro de téléphone',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF172033),
                          ),
                        ),
                        const Spacer(),
                        const Icon(
                          Icons.bolt,
                          size: 18,
                          color: Color(0xFF168C80),
                        ),
                        const Text(
                          ' Vérification SMS',
                          style: TextStyle(
                            color: Color(0xFF168C80),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    TextField(
                      controller: phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        hintText: 'Ex: +257 79 XX XX XX',
                        prefixIcon: const Icon(Icons.phone),
                        filled: true,
                        fillColor: const Color(0xFFF1F3FC),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    TextField(
                      controller: passwordController,
                      obscureText: obscurePassword,
                      decoration: InputDecoration(
                        labelText: 'Mot de passe',
                        prefixIcon:
                            const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(
                            obscurePassword
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                          onPressed: () {
                            setState(() {
                              obscurePassword =
                                  !obscurePassword;
                            });
                          },
                        ),
                        filled: true,
                        fillColor: const Color(0xFFF1F3FC),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    const Row(
                      children: [
                        Icon(
                          Icons.verified_user_outlined,
                          size: 18,
                          color: Color(0xFF168C80),
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Vos informations restent confidentielles.',
                            style: TextStyle(
                              color: Color(0xFF777D8A),
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 18),

                    // Connexion
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton.icon(
                        onPressed: login,
                        icon: const Icon(Icons.login),
                        label: const Text(
                          'Se connecter',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color(0xFFE92929),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // OTP
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: OutlinedButton.icon(
                        onPressed: requestOtp,
                        icon: const Icon(Icons.sms_outlined),
                        label: const Text(
                          'Recevoir le code de vérification',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor:
                              const Color(0xFFE92929),
                          side: const BorderSide(
                            color: Color(0xFFE92929),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    Row(
                      children: [
                        const Expanded(child: Divider()),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                          ),
                          child: Text(
                            'OU',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const Expanded(child: Divider()),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Mode invité
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: TextButton.icon(
                        onPressed: loginAsGuest,
                        icon: const Icon(
                          Icons.person_outline,
                          color: Color(0xFF172033),
                        ),
                        label: const Text(
                          'Continuer sans compte (Mode Invité)',
                          style: TextStyle(
                            color: Color(0xFF172033),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: TextButton.styleFrom(
                          backgroundColor:
                              const Color(0xFFF1F3FC),
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Créer un compte
                    Center(
                      child: TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const RegisterScreen(),
                            ),
                          );
                        },
                        child: const Text(
                          'Créer un compte',
                          style: TextStyle(
                            color: Color(0xFFE92929),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Informations sécurité
              Row(
                children: [
                  Expanded(
                    child: _buildInfoCard(
                      Icons.lock_outline,
                      'Confidentialité',
                      'Données protégées',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildInfoCard(
                      Icons.flash_on_outlined,
                      'Urgence',
                      'Alerte rapide',
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 18),

              // Conditions d'utilisation
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF777D8A),
                    height: 1.4,
                  ),
                  children: [
                    const TextSpan(
                      text: 'En continuant, vous acceptez nos ',
                    ),

                    TextSpan(
                      text: 'Conditions d’utilisation',
                      style: const TextStyle(
                        color: Color(0xFFE92929),
                        decoration: TextDecoration.underline,
                        fontWeight: FontWeight.w600,
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const TermsScreen(),
                            ),
                          );
                        },
                    ),

                    const TextSpan(
                      text: ' et notre ',
                    ),

                    TextSpan(
                      text: 'Politique de confidentialité',
                      style: const TextStyle(
                        color: Color(0xFFE92929),
                        decoration: TextDecoration.underline,
                        fontWeight: FontWeight.w600,
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          ScaffoldMessenger.of(context)
                              .showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Politique de confidentialité',
                              ),
                            ),
                          );
                        },
                    ),

                    const TextSpan(
                      text: '.',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSmallIcon(
    IconData icon,
    Color color,
  ) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        shape: BoxShape.circle,
      ),
      child: Icon(
        icon,
        color: color,
        size: 22,
      ),
    );
  }

  Widget _buildInfoCard(
    IconData icon,
    String title,
    String subtitle,
  ) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: const Color(0xFFE92929),
            size: 24,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF172033),
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF777D8A),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}