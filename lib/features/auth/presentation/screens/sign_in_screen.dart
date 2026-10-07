import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/auth_providers.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_palette.dart';
import '../../data/datasources/africa_locations.dart';

enum _SignInStep { phone, otp }

/// Écran "Sign In" (Figma) : connexion par téléphone + code SMS (Firebase
/// Phone Auth), ou accès immédiat sans compte ("Mode Invité").
///
/// Tant que le plan Blaze n'est pas activé, seuls les numéros de test
/// configurés dans Firebase Console (Authentication > Sign-in method >
/// Phone > Numéros de test) reçoivent un code — aucun vrai SMS n'est envoyé.
class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({super.key});

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen> {
  final _phoneController = TextEditingController();
  final _codeController = TextEditingController();

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
      await ref
          .read(phoneAuthControllerProvider)
          .sendCode(
            phoneNumber: '$_dialCode$rawNumber',
            onAutoVerified: () {
              if (mounted) context.go(AppRoutes.home);
            },
            onError: (message) {
              if (!mounted) return;
              setState(() {
                _isSubmitting = false;
                _errorMessage = message;
              });
            },
            onCodeSent: (verificationId) {
              if (!mounted) return;
              setState(() {
                _isSubmitting = false;
                _verificationId = verificationId;
                _step = _SignInStep.otp;
              });
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
      await ref
          .read(phoneAuthControllerProvider)
          .confirmCode(verificationId: verificationId, smsCode: smsCode);
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
                InkWell(
                  onTap: context.canPop() ? () => context.pop() : null,
                  borderRadius: BorderRadius.circular(20),
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: Icon(Icons.arrow_back, color: palette.textPrimary),
                  ),
                ),
                const SizedBox(width: 6),
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
            // Bloc informatif (un seul type de compte dans l'app).
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.softBlue,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          'Don de sang',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          "Réseau d'urgence",
                          style: TextStyle(
                            fontSize: 11,
                            color: palette.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 32,
                    child: VerticalDivider(color: palette.border, width: 1),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          'Pharmacies',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.tealPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Gardes en direct',
                          style: TextStyle(
                            fontSize: 11,
                            color: palette.textSecondary,
                          ),
                        ),
                      ],
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
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: AppColors.tealLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Numéro de test (évaluateurs) : +237 6 00 00 00 00',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.tealPrimary,
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
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: AppColors.tealLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Code de test (évaluateurs) : 000000',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.tealPrimary,
                  ),
                ),
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
              child: ElevatedButton(
                onPressed: _continueAsGuest,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.softBlue,
                  foregroundColor: AppColors.info,
                  elevation: 0,
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
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: TextStyle(fontSize: 11, color: palette.textSecondary),
                children: [
                  const TextSpan(text: 'En continuant, vous acceptez nos '),
                  TextSpan(
                    text: "Conditions d'utilisation",
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const TextSpan(text: ' et notre '),
                  TextSpan(
                    text: 'Politique de confidentialité',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const TextSpan(text: '.'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
