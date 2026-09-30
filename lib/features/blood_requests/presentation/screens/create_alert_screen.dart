import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/auth_providers.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/blood_compatibility.dart';
import '../../data/models/hospital_model.dart';
import '../../domain/blood_request.dart';
import '../../domain/blood_request_enums.dart';
import '../providers/blood_request_providers.dart';
import '../providers/hospital_providers.dart';

/// Formulaire de publication d'une alerte de sang.
///
/// Conçu pour aller vite en situation d'urgence : seuls le groupe sanguin et
/// l'hôpital sont obligatoires, tout le reste a une valeur par défaut
/// modifiable. La ville n'est pas saisie à la main : elle est déduite de
/// l'hôpital choisi, pour ne jamais désynchroniser les deux.
class CreateAlertScreen extends ConsumerStatefulWidget {
  const CreateAlertScreen({super.key});

  @override
  ConsumerState<CreateAlertScreen> createState() => _CreateAlertScreenState();
}

class _CreateAlertScreenState extends ConsumerState<CreateAlertScreen> {
  BloodGroup? _bloodGroup;
  HospitalModel? _hospital;
  UrgencyLevel _urgency = UrgencyLevel.high;
  int _unitsNeeded = 1;
  final _departmentController = TextEditingController();
  final _notesController = TextEditingController();
  final _contactPhoneController = TextEditingController();

  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void dispose() {
    _departmentController.dispose();
    _notesController.dispose();
    _contactPhoneController.dispose();
    super.dispose();
  }

  bool get _canSubmit =>
      _bloodGroup != null && _hospital != null && !_isSubmitting;

  Future<void> _submit() async {
    final bloodGroup = _bloodGroup;
    final hospital = _hospital;
    if (bloodGroup == null || hospital == null) return;

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      final requesterId = await ref.read(currentUserIdProvider.future);
      final request = BloodRequest.create(
        requesterId: requesterId,
        city: hospital.city,
        bloodGroupNeeded: bloodGroup,
        hospitalId: hospital.id,
        hospitalDepartment: _departmentController.text.trim().isEmpty
            ? null
            : _departmentController.text.trim(),
        urgency: _urgency,
        unitsNeeded: _unitsNeeded,
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
      );

      final newId = await ref
          .read(bloodRequestRepositoryProvider)
          .createRequest(request, contactPhone: _contactPhoneController.text);

      if (!mounted) return;
      Navigator.of(context).pop(newId);
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
        _errorMessage =
            "La publication a échoué. Vérifiez votre connexion et réessayez.";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final hospitalsAsync = ref.watch(allHospitalsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Nouvelle alerte')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Groupe sanguin recherché',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              for (final group in BloodGroup.values)
                ChoiceChip(
                  label: Text(group.label),
                  selected: _bloodGroup == group,
                  onSelected: _isSubmitting
                      ? null
                      : (selected) => setState(
                          () => _bloodGroup = selected ? group : null,
                        ),
                ),
            ],
          ),
          const SizedBox(height: 24),
          const Text('Hôpital', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 10),
          hospitalsAsync.when(
            data: (hospitals) {
              if (hospitals.isEmpty) {
                return const Text(
                  "Aucun hôpital enregistré pour l'instant.",
                  style: TextStyle(color: AppColors.textSecondary),
                );
              }
              return DropdownButtonFormField<HospitalModel>(
                initialValue: _hospital,
                isExpanded: true,
                decoration: const InputDecoration(border: OutlineInputBorder()),
                hint: const Text('Choisir un hôpital'),
                items: [
                  for (final hospital in hospitals)
                    DropdownMenuItem(
                      value: hospital,
                      child: Text('${hospital.name} · ${hospital.city}'),
                    ),
                ],
                onChanged: _isSubmitting
                    ? null
                    : (value) => setState(() => _hospital = value),
              );
            },
            loading: () => const LinearProgressIndicator(),
            error: (error, stackTrace) => const Text(
              "Impossible de charger la liste des hôpitaux.",
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _departmentController,
            enabled: !_isSubmitting,
            decoration: const InputDecoration(
              labelText: 'Service (optionnel)',
              hintText: 'Ex. Urgences, Maternité',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 24),
          const Text('Urgence', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            children: [
              for (final level in UrgencyLevel.values)
                ChoiceChip(
                  label: Text(level.label),
                  selected: _urgency == level,
                  onSelected: _isSubmitting
                      ? null
                      : (selected) {
                          if (selected) setState(() => _urgency = level);
                        },
                ),
            ],
          ),
          const SizedBox(height: 24),
          const Text(
            'Poches nécessaires',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              IconButton.outlined(
                onPressed: _isSubmitting || _unitsNeeded <= 1
                    ? null
                    : () => setState(() => _unitsNeeded--),
                icon: const Icon(Icons.remove),
              ),
              SizedBox(
                width: 48,
                child: Text(
                  '$_unitsNeeded',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
              ),
              IconButton.outlined(
                onPressed: _isSubmitting
                    ? null
                    : () => setState(() => _unitsNeeded++),
                icon: const Icon(Icons.add),
              ),
            ],
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _notesController,
            enabled: !_isSubmitting,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Notes (optionnel)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _contactPhoneController,
            enabled: !_isSubmitting,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(
              labelText: 'Votre numéro (optionnel, privé)',
              helperText: "Jamais affiché publiquement, ni aux donneurs.",
              border: OutlineInputBorder(),
            ),
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
              onPressed: _canSubmit ? _submit : null,
              child: _isSubmitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Publier l\u2019alerte'),
            ),
          ),
        ],
      ),
    );
  }
}
