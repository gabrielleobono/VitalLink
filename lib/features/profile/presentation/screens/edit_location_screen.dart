import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../auth/data/datasources/africa_locations.dart';
import '../providers/profile_providers.dart';

/// "Modifier ma localisation" : permet de changer pays/ville/région à tout
/// moment depuis le Profil — notamment pour les profils créés avant l'ajout
/// du champ région, qui en ont besoin pour voir les urgences de leur zone
/// (cf. `bloodAlertsProvider`, filtré par pays + région).
class EditLocationScreen extends ConsumerStatefulWidget {
  const EditLocationScreen({super.key});

  @override
  ConsumerState<EditLocationScreen> createState() =>
      _EditLocationScreenState();
}

class _EditLocationScreenState extends ConsumerState<EditLocationScreen> {
  String? _country;
  String? _city;
  String? _region;
  bool _initialized = false;
  bool _isSubmitting = false;
  String? _errorMessage;

  void _initFrom(String country, String city, String region) {
    if (_initialized) return;
    final validCountry = AfricaLocations.citiesByCountry.containsKey(country)
        ? country
        : 'Cameroun';
    final cities = AfricaLocations.citiesByCountry[validCountry]!;
    final regions = AfricaLocations.regionOptionsFor(validCountry);
    _country = validCountry;
    _city = cities.contains(city) ? city : cities.first;
    _region = regions.contains(region) ? region : regions.first;
    _initialized = true;
  }

  Future<void> _pickCountry() async {
    final countries = AfricaLocations.citiesByCountry.keys.toList();
    final selected = await showModalBottomSheet<String>(
      context: context,
      builder: (context) => _PickerSheet(
        title: 'Pays',
        options: countries,
        optionLabel: (c) => '${AfricaLocations.flagByCountry[c]}  $c',
        selected: _country!,
      ),
    );
    if (selected == null || !mounted) return;
    setState(() {
      _country = selected;
      _city = AfricaLocations.citiesByCountry[selected]!.first;
      _region = AfricaLocations.regionOptionsFor(selected).first;
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
        selected: _city!,
      ),
    );
    if (selected == null || !mounted) return;
    setState(() => _city = selected);
  }

  Future<void> _pickRegion() async {
    final regions = AfricaLocations.regionOptionsFor(_country!);
    final selected = await showModalBottomSheet<String>(
      context: context,
      builder: (context) => _PickerSheet(
        title: AfricaLocations.regionLabelFor(_country!),
        options: regions,
        optionLabel: (r) => r,
        selected: _region!,
      ),
    );
    if (selected == null || !mounted) return;
    setState(() => _region = selected);
  }

  Future<void> _submit() async {
    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });
    try {
      await ref
          .read(profileLocationControllerProvider)
          .updateLocation(country: _country!, city: _city!, region: _region!)
          .timeout(const Duration(seconds: 6), onTimeout: () {});
      if (!mounted) return;
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
        _errorMessage =
            "Impossible d'enregistrer : vérifiez votre connexion et réessayez.";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final profileAsync = ref.watch(userProfileProvider);

    return Scaffold(
      backgroundColor: palette.background,
      appBar: AppBar(
        backgroundColor: palette.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          'Modifier ma localisation',
          style: TextStyle(color: palette.textPrimary, fontWeight: FontWeight.w700),
        ),
      ),
      body: profileAsync.when(
        data: (profile) {
          _initFrom(
            profile?.country ?? 'Cameroun',
            profile?.city ?? 'Douala',
            profile?.region ?? '',
          );
          return SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              children: [
                Text(
                  "Utilisé pour n'afficher que les urgences et pharmacies de votre pays et région.",
                  style: TextStyle(fontSize: 13, color: palette.textSecondary),
                ),
                const SizedBox(height: 20),
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
                        value: _city!,
                        onTap: _pickCity,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                _SelectField(
                  label: AfricaLocations.regionLabelFor(_country!).toUpperCase(),
                  value: _region!,
                  onTap: _pickRegion,
                ),
                if (_errorMessage != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    _errorMessage!,
                    style: const TextStyle(color: AppColors.primary, fontSize: 13),
                  ),
                ],
                const SizedBox(height: 24),
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
                            'Enregistrer',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
        error: (error, stack) => Center(
          child: Text(
            'Impossible de charger le profil.',
            style: TextStyle(color: palette.textSecondary),
          ),
        ),
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
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
            color: palette.textSecondary,
          ),
        ),
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
                Icon(Icons.chevron_right, size: 18, color: palette.textSecondary),
              ],
            ),
          ),
        ),
      ],
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
