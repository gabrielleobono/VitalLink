import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_palette.dart';
import '../../data/africa_locations.dart';

enum _SignInMode { bloodDonation, pharmacies }

enum _SignInStep { phone, otp }

/// Écran "Sign In" (Figma) : connexion par téléphone + code SMS (Firebase
/// Phone Auth), ou accès immédiat sans compte ("Mode Invité").
///
/// Tant que le plan Blaze n'est pas activé, seuls les numéros de test
/// configurés dans Firebase Console (Authentication > Sign-in method >
/// Phone > Numéros de test) reçoivent un code — aucun vrai SMS n'est envoyé.
class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _phoneController = TextEditingController();
  final _codeController = TextEditingController();

  _SignInMode _mode = _SignInMode.bloodDonation;
  _SignInStep _step = _SignInStep.phone;
  String _country = 'Cameroun';
  String? _verificationId;
  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void dispose() {
    _phoneController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  String get _dialCode => AfricaLocations.dialCodeByCountry[_country]!;

  Future<void> _sendCode() async {
    final rawNumber = _phoneController.text.trim();
    if (rawNumber.isEmpty) {
      setState(() => _errorMessage = 'Entrez votre numéro de téléphone.');
      return;
    }
    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });
    try {
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: '$_dialCode$rawNumber',
        verificationCompleted: (credential) async {
          await FirebaseAuth.instance.signInWithCredential(credential);
          if (mounted) context.go(AppRoutes.home);
        },
        verificationFailed: (e) {
          if (!mounted) return;
          setState(() {
            _isSubmitting = false;
            _errorMessage = e.message ?? "L'envoi du code a échoué. Réessayez.";
          });
        },
        codeSent: (verificationId, _) {
          if (!mounted) return;
          setState(() {
            _isSubmitting = false;
            _verificationId = verificationId;
            _step = _SignInStep.otp;
          });
        },
        codeAutoRetrievalTimeout: (verificationId) {
          _verificationId = verificationId;
        },
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
        _errorMessage = "L'envoi du code a échoué. Réessayez.";
      });
    }
  }

  Future<void> _confirmCode() async {
    final verificationId = _verificationId;
    final smsCode = _codeController.text.trim();
    if (verificationId == null || smsCode.isEmpty) return;
    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );
      await FirebaseAuth.instance.signInWithCredential(credential);
      if (!mounted) return;
      context.go(AppRoutes.home);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
        _errorMessage = 'Code invalide. Réessayez.';
      });
    }
  }

  void _continueAsGuest() {
    enterGuestMode();
    context.go(AppRoutes.home);
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Scaffold(
      backgroundColor: palette.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.water_drop,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'VitalLink',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: palette.textPrimary,
                        ),
                      ),
                      Text(
                        'Sign In',
                        style: TextStyle(
                          fontSize: 12,
                          color: palette.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: palette.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: palette.border),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _ModeTab(
                      icon: Icons.water_drop,
                      title: 'Don de sang',
                      subtitle: "Réseau d'urgence",
                      selected: _mode == _SignInMode.bloodDonation,
                      onTap: () =>
                          setState(() => _mode = _SignInMode.bloodDonation),
                    ),
                  ),
                  Expanded(
                    child: _ModeTab(
                      icon: Icons.local_pharmacy_rounded,
                      title: 'Pharmacies',
                      subtitle: 'Gardes en direct',
                      selected: _mode == _SignInMode.pharmacies,
                      onTap: () =>
                          setState(() => _mode = _SignInMode.pharmacies),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            if (_step == _SignInStep.phone) ...[
              Row(
                children: [
                  Text(
                    'Numéro de téléphone',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: palette.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.tealLight,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      'Vérification SMS',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: AppColors.tealPrimary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  InkWell(
                    onTap: () async {
                      final countries = AfricaLocations.dialCodeByCountry.keys
                          .toList();
                      final selected = await showModalBottomSheet<String>(
                        context: context,
                        builder: (context) => SafeArea(
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              maxHeight:
                                  MediaQuery.of(context).size.height * 0.6,
                            ),
                            child: ListView(
                              shrinkWrap: true,
                              children: [
                                for (final c in countries)
                                  ListTile(
                                    leading: Text(
                                      AfricaLocations.flagByCountry[c]!,
                                    ),
                                    title: Text(c),
                                    trailing: Text(
                                      AfricaLocations.dialCodeByCountry[c]!,
                                    ),
                                    onTap: () => Navigator.of(context).pop(c),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      );
                      if (selected != null) {
                        setState(() => _country = selected);
                      }
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        color: palette.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: palette.border),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _dialCode,
                            style: TextStyle(color: palette.textPrimary),
                          ),
                          Icon(
                            Icons.arrow_drop_down,
                            color: palette.textSecondary,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      style: TextStyle(color: palette.textPrimary),
                      decoration: InputDecoration(
                        hintText: '6XX XX XX XX',
                        filled: true,
                        fillColor: palette.surface,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: palette.border),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Nous vous enverrons un code de confirmation sécurisé par SMS.',
                style: TextStyle(fontSize: 12, color: palette.textSecondary),
              ),
              if (_errorMessage != null) ...[
                const SizedBox(height: 10),
                Text(
                  _errorMessage!,
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 13,
                  ),
                ),
              ],
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _sendCode,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Recevoir le code de vérification',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                ),
              ),
            ] else ...[
              Text(
                'Code de vérification',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: palette.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Entrez le code reçu par SMS au $_dialCode${_phoneController.text.trim()}.',
                style: TextStyle(fontSize: 12, color: palette.textSecondary),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _codeController,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: palette.textPrimary,
                  fontSize: 20,
                  letterSpacing: 8,
                  fontWeight: FontWeight.w700,
                ),
                decoration: InputDecoration(
                  hintText: '••••••',
                  filled: true,
                  fillColor: palette.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: palette.border),
                  ),
                ),
              ),
              if (_errorMessage != null) ...[
                const SizedBox(height: 10),
                Text(
                  _errorMessage!,
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 13,
                  ),
                ),
              ],
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _confirmCode,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Confirmer le code',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: _isSubmitting
                    ? null
                    : () => setState(() {
                        _step = _SignInStep.phone;
                        _errorMessage = null;
                      }),
                child: const Text('Changer de numéro'),
              ),
            ],
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(child: Divider(color: palette.border)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Text(
                    'ou',
                    style: TextStyle(color: palette.textSecondary),
                  ),
                ),
                Expanded(child: Divider(color: palette.border)),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: _continueAsGuest,
                style: OutlinedButton.styleFrom(
                  foregroundColor: palette.textPrimary,
                  side: BorderSide(color: palette.border),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'Continuer sans compte (Mode Invité)',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Accès immédiat aux pharmacies de garde et alertes critiques.',
              style: TextStyle(fontSize: 12, color: palette.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Text(
              "En continuant, vous acceptez nos Conditions d'utilisation et notre Politique de confidentialité.",
              style: TextStyle(fontSize: 11, color: palette.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _ModeTab extends StatelessWidget {
  const _ModeTab({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 18,
              color: selected ? Colors.white : palette.textSecondary,
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: selected ? Colors.white : palette.textPrimary,
              ),
            ),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 10,
                color: selected
                    ? Colors.white.withValues(alpha: 0.85)
                    : palette.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
