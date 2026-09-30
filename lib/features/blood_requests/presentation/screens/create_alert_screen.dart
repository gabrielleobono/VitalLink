import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/blood_compatibility.dart';
import '../../data/models/hospital.dart';

final _hospitalsListProvider = FutureProvider<List<Hospital>>((ref) async {
  final snapshot = await FirebaseFirestore.instance
      .collection('hospitals')
      .get();
  return snapshot.docs
      .map((doc) => Hospital.fromFirestore(doc.id, doc.data()))
      .toList();
});

const _criticalities = [
  ('critical', 'Critique'),
  ('high', 'Élevée'),
  ('medium', 'Moyenne'),
];

/// Formulaire de publication d'une alerte de sang (`bloodAlerts/{id}`).
/// Réservé aux soignants vérifiés (voir firestore.rules). Aucune donnée
/// nominative du patient n'est saisie ni stockée.
class CreateAlertScreen extends ConsumerStatefulWidget {
  const CreateAlertScreen({super.key});

  @override
  ConsumerState<CreateAlertScreen> createState() => _CreateAlertScreenState();
}

class _CreateAlertScreenState extends ConsumerState<CreateAlertScreen> {
  BloodGroup? _bloodGroup;
  Hospital? _hospital;
  String _criticality = 'high';
  int _unitsNeeded = 1;
  final _departmentController = TextEditingController();

  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void dispose() {
    _departmentController.dispose();
    super.dispose();
  }

  bool get _canSubmit =>
      _bloodGroup != null && _hospital != null && !_isSubmitting;

  Future<void> _submit() async {
    final bloodGroup = _bloodGroup;
    final hospital = _hospital;
    if (bloodGroup == null || hospital == null) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() => _errorMessage = 'Connectez-vous pour publier une alerte.');
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      final compatible = BloodCompatibility.compatibleDonorsFor(
        bloodGroup,
      ).map((g) => g.label).toList();

      final doc = await FirebaseFirestore.instance
          .collection('bloodAlerts')
          .add({
            'recipientBloodGroup': bloodGroup.label,
            'compatibleGroups': compatible,
            'units': _unitsNeeded,
            'criticality': _criticality,
            'hospitalId': hospital.id,
            'location': hospital.location,
            'createdBy': user.uid,
            'status': 'open',
            'createdAt': FieldValue.serverTimestamp(),
            'expiresAt': Timestamp.fromDate(
              DateTime.now().add(const Duration(hours: 24)),
            ),
            'hospitalName': hospital.name,
            'serviceInfo': _departmentController.text.trim(),
            'district': hospital.city,
            'distanceKm': 0,
            'alertBadgeLabel': 'Alerte vérifiée',
            'alertBadgeVariant': 'verified',
            'bloodGroupTagLabel': bloodGroup.label,
            'ctaSubtitleText': '$_unitsNeeded poche(s) · ${hospital.name}',
          });

      if (!mounted) return;
      Navigator.of(context).pop(doc.id);
    } on FirebaseException catch (error) {
      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
        _errorMessage = error.code == 'permission-denied'
            ? 'Seuls les soignants vérifiés peuvent publier une alerte.'
            : 'La publication a échoué. Vérifiez votre connexion et réessayez.';
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
        _errorMessage =
            'La publication a échoué. Vérifiez votre connexion et réessayez.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final hospitalsAsync = ref.watch(_hospitalsListProvider);

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
              return DropdownButtonFormField<Hospital>(
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
              'Impossible de charger la liste des hôpitaux.',
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
              for (final (value, label) in _criticalities)
                ChoiceChip(
                  label: Text(label),
                  selected: _criticality == value,
                  onSelected: _isSubmitting
                      ? null
                      : (selected) {
                          if (selected) setState(() => _criticality = value);
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
                  : const Text('Publier l’alerte'),
            ),
          ),
        ],
      ),
    );
  }
}
