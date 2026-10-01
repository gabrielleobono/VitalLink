import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/utils/blood_compatibility.dart';
import '../../../profile/presentation/providers/profile_providers.dart';
import '../../data/datasources/africa_locations.dart';

/// "Compléter mon profil" (Figma "Créer mon profil") : nom complet,
/// pays/ville, groupe sanguin (optionnel) et bascule "Prêt à donner".
///
/// Affiché après une connexion OTP réussie si le numéro est nouveau (aucun
/// document `users/{uid}`) — cf. le `redirect` de [appRouter]. Il n'y a pas
/// d'écran d'inscription séparé : avec Firebase Auth par SMS, inscription et
/// connexion se font au même endroit ([SignInScreen]).
class CompleteProfileScreen extends ConsumerStatefulWidget {
  const CompleteProfileScreen({super.key});

  @override
  ConsumerState<CompleteProfileScreen> createState() =>
      _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends ConsumerState<CompleteProfileScreen> {
  final _nameController = TextEditingController();
  String _country = 'Cameroun';
  String _city = 'Douala';
  BloodGroup? _bloodGroup;
  bool _readyToDonate = true;
  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickCountry() async {
    final countries = AfricaLocations.citiesByCountry.keys.toList();
    final selected = await showModalBottomSheet<String>(
      context: context,
      builder: (context) => _PickerSheet(
        title: 'Pays',
        options: countries,
        optionLabel: (c) => '${AfricaLocations.flagByCountry[c]}  $c',
        selected: _country,
      ),
    );
    if (selected == null || !mounted) return;
    setState(() {
      _country = selected;
      _city = AfricaLocations.citiesByCountry[selected]!.first;
    });
  }

  Future<void> _pickCity() async {
    final cities = AfricaLocations.citiesByCountry[_country]!;
    final selected = await showModalBottomSheet<String>(
      context: context,
      builder: (context) => _PickerSheet(
        title: 'Ville',
        options: cities,
        optionLabel: (c) => c,
        selected: _city,
      ),
    );
    if (selected == null || !mounted) return;
    setState(() => _city = selected);
  }

  Future<void> _submit() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      setState(() => _errorMessage = 'Entrez votre nom complet.');
      return;
    }
    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });
    try {
      await ref
          .read(profileCreationControllerProvider)
          .createProfile(
            displayName: name,
            country: _country,
            city: _city,
            isDonor: _readyToDonate,
            bloodGroup: _bloodGroup?.label,
          )
          // La persistance hors-ligne de Firestore écrit déjà dans le cache
          // local immédiatement ; ce Future n'attend que l'accusé du
          // serveur. Sur un réseau faible, on n'attend pas indéfiniment —
          // la synchronisation se termine en arrière-plan.
          .timeout(const Duration(seconds: 6), onTimeout: () {});
      markProfileComplete();
      if (!mounted) return;
      context.go(AppRoutes.home);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
        _errorMessage =
            "Impossible de créer le profil : vérifiez votre connexion et réessayez.";
      });
    }
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
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.circle, size: 8, color: AppColors.primary),
                const SizedBox(width: 6),
                Text(
                  'VITALLINK',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1,
                    color: palette.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              'Créer mon profil',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                color: palette.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Renseignez ces 3 informations essentielles pour commencer.',
              style: TextStyle(fontSize: 13, color: palette.textSecondary),
            ),
            const SizedBox(height: 24),
            _FieldLabel('NOM COMPLET'),
            const SizedBox(height: 6),
            TextField(
              controller: _nameController,
              textCapitalization: TextCapitalization.words,
              style: TextStyle(color: palette.textPrimary),
              decoration: InputDecoration(
                hintText: 'Jean-Paul Kamga',
                filled: true,
                fillColor: palette.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: palette.border),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: _SelectField(
                    label: 'PAYS',
                    value:
                        '${AfricaLocations.flagByCountry[_country]}  $_country',
                    onTap: _pickCountry,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _SelectField(
                    label: 'VILLE',
                    value: _city,
                    onTap: _pickCity,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                _FieldLabel('GROUPE SANGUIN'),
                const Spacer(),
                Text(
                  'Optionnel',
                  style: TextStyle(fontSize: 12, color: palette.textSecondary),
                ),
              ],
            ),
            const SizedBox(height: 8),
            GridView.count(
              crossAxisCount: 4,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 1.4,
              children: [
                for (final group in BloodGroup.values)
                  _BloodGroupButton(
                    group: group,
                    selected: _bloodGroup == group,
                    onTap: () => setState(
                      () => _bloodGroup = _bloodGroup == group ? null : group,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: () => setState(() => _bloodGroup = null),
              style: OutlinedButton.styleFrom(
                foregroundColor: palette.textSecondary,
                side: BorderSide(color: palette.border),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text('Je ne sais pas encore'),
            ),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: palette.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: palette.border),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Prêt à donner en cas d'urgence",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: palette.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          "Recevez une alerte lorsqu'une vie compatible a besoin de sang près de vous.",
                          style: TextStyle(
                            fontSize: 12,
                            color: palette.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: _readyToDonate,
                    activeThumbColor: AppColors.primary,
                    onChanged: (value) =>
                        setState(() => _readyToDonate = value),
                  ),
                ],
              ),
            ),
            if (_errorMessage != null) ...[
              const SizedBox(height: 12),
              Text(
                _errorMessage!,
                style: const TextStyle(color: AppColors.primary, fontSize: 13),
              ),
            ],
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submit,
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
                        'Commencer →',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.lock_outline,
                  size: 13,
                  color: palette.textSecondary,
                ),
                const SizedBox(width: 4),
                Text(
                  'Données médicales chiffrées et confidentielles',
                  style: TextStyle(fontSize: 11, color: palette.textSecondary),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.5,
        color: context.palette.textSecondary,
      ),
    );
  }
}

class _SelectField extends StatelessWidget {
  const _SelectField({
    required this.label,
    required this.value,
    required this.onTap,
  });

  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _FieldLabel(label),
        const SizedBox(height: 6),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            decoration: BoxDecoration(
              color: palette.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: palette.border),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    value,
                    style: TextStyle(color: palette.textPrimary, fontSize: 14),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(Icons.check, size: 16, color: AppColors.success),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _BloodGroupButton extends StatelessWidget {
  const _BloodGroupButton({
    required this.group,
    required this.selected,
    required this.onTap,
  });

  final BloodGroup group;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : palette.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? AppColors.primary : palette.border,
          ),
        ),
        child: Text(
          group.label,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: selected ? Colors.white : palette.textPrimary,
          ),
        ),
      ),
    );
  }
}

class _PickerSheet extends StatelessWidget {
  const _PickerSheet({
    required this.title,
    required this.options,
    required this.optionLabel,
    required this.selected,
  });

  final String title;
  final List<String> options;
  final String Function(String) optionLabel;
  final String selected;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.6,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: palette.textPrimary,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Flexible(
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    for (final option in options)
                      ListTile(
                        title: Text(optionLabel(option)),
                        trailing: option == selected
                            ? Icon(Icons.check, color: AppColors.success)
                            : null,
                        onTap: () => Navigator.of(context).pop(option),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
