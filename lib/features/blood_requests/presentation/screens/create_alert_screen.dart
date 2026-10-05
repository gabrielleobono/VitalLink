import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/utils/blood_compatibility.dart';
import '../../../profile/presentation/providers/profile_providers.dart';
import '../../data/models/hospital.dart';

/// Hôpitaux limités au pays et à la région de l'utilisateur courant — même
/// règle de zone que les alertes et les pharmacies.
final _hospitalsListProvider = FutureProvider<List<Hospital>>((ref) async {
  final profile = await ref.watch(userProfileProvider.future);
  if (profile == null || profile.country.isEmpty || profile.region.isEmpty) {
    return const [];
  }
  final snapshot = await FirebaseFirestore.instance
      .collection('hospitals')
      .where('country', isEqualTo: profile.country)
      .where('region', isEqualTo: profile.region)
      .get();
  return snapshot.docs
      .map((doc) => Hospital.fromFirestore(doc.id, doc.data()))
      .toList();
});

class CreateAlertScreen extends ConsumerStatefulWidget {
  const CreateAlertScreen({super.key});

  @override
  ConsumerState<CreateAlertScreen> createState() => _CreateAlertScreenState();
}

class _CreateAlertScreenState extends ConsumerState<CreateAlertScreen> {
  BloodGroup? _bloodGroup;
  Hospital? _hospital;
  int _unitsNeeded = 1;

  final _departmentController = TextEditingController();
  final _phoneController = TextEditingController();
  final _caregiverCodeController = TextEditingController();

  bool _isCaregiver = false;
  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void dispose() {
    _departmentController.dispose();
    _phoneController.dispose();
    _caregiverCodeController.dispose();
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
      final profile = ref.read(userProfileProvider).asData?.value;
      final compatible = BloodCompatibility.compatibleDonorsFor(
        bloodGroup,
      ).map((g) => g.label).toList();

      final isVerifiedCaregiver =
          _isCaregiver && _caregiverCodeController.text.trim().isNotEmpty;

      final contactPhone = _phoneController.text.trim().isNotEmpty
          ? _phoneController.text.trim()
          : hospital.phone;

      final doc = await FirebaseFirestore.instance
          .collection('bloodAlerts')
          .add({
            'recipientBloodGroup': bloodGroup.label,
            'compatibleGroups': compatible,
            'units': _unitsNeeded,
            'criticality': 'high',
            'hospitalId': hospital.id,
            'location': hospital.location,
            'createdBy': user.uid,
            'country': profile?.country ?? '',
            'region': profile?.region ?? '',
            'status': 'open',
            'createdAt': FieldValue.serverTimestamp(),
            'expiresAt': Timestamp.fromDate(
              DateTime.now().add(const Duration(hours: 24)),
            ),
            'hospitalName': hospital.name,
            'serviceInfo': _departmentController.text.trim().isNotEmpty
                ? _departmentController.text.trim()
                : 'Urgences',
            'contactPhone': contactPhone,
            'district': hospital.city,
            'distanceKm': 0,
            'alertBadgeLabel': isVerifiedCaregiver
                ? 'Alerte médicale vérifiée'
                : 'Alerte citoyenne',
            'alertBadgeVariant': isVerifiedCaregiver ? 'verified' : 'citizen',
            'source': isVerifiedCaregiver ? 'medical_staff' : 'citizen',
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
            ? 'Publication refusée : droits insuffisants. Réessayez plus tard.'
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
    final palette = context.palette;
    final hospitalsAsync = ref.watch(_hospitalsListProvider);

    return Scaffold(
      backgroundColor: palette.background,
      appBar: AppBar(
        backgroundColor: palette.background,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: palette.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Lancer Une Urgence Sang',
          style: TextStyle(
            color: palette.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        decoration: BoxDecoration(
          color: palette.surface,
          border: Border(top: BorderSide(color: palette.border)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _canSubmit ? _submit : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  disabledBackgroundColor: AppColors.primary.withValues(
                    alpha: 0.35,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.play_arrow, color: Colors.white, size: 20),
                          SizedBox(width: 8),
                          Text(
                            "DIFFUSER L'ALERTE D'URGENCE",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Notification prioritaire envoyée aux donneurs compatibles à proximité.',
              textAlign: TextAlign.center,
              style: TextStyle(color: palette.textSecondary, fontSize: 11),
            ),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        children: [
          Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.water_drop,
                  color: Colors.white,
                  size: 14,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Groupe sanguin requis',
                style: TextStyle(
                  color: palette.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Sélectionnez le groupe ciblé',
            style: TextStyle(color: palette.textSecondary, fontSize: 13),
          ),
          const SizedBox(height: 14),

          _buildBloodGroupGrid(palette),

          const SizedBox(height: 24),

          Text(
            'Nombre de poches',
            style: TextStyle(
              color: palette.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _buildStepButton(
                palette: palette,
                icon: Icons.remove,
                onTap: _isSubmitting || _unitsNeeded <= 1
                    ? null
                    : () => setState(() => _unitsNeeded--),
              ),
              Container(
                width: 60,
                alignment: Alignment.center,
                child: Text(
                  '$_unitsNeeded',
                  style: TextStyle(
                    color: palette.textPrimary,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              _buildStepButton(
                palette: palette,
                icon: Icons.add,
                onTap: _isSubmitting
                    ? null
                    : () => setState(() => _unitsNeeded++),
              ),
              const SizedBox(width: 16),
              Text(
                'Poches calibrées de 450ml',
                style: TextStyle(color: palette.textSecondary, fontSize: 13),
              ),
            ],
          ),

          const SizedBox(height: 28),

          Row(
            children: [
              const Icon(
                Icons.local_hospital,
                color: AppColors.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Destination hospitalière',
                style: TextStyle(
                  color: palette.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Point de réception et transmission',
            style: TextStyle(color: palette.textSecondary, fontSize: 13),
          ),
          const SizedBox(height: 14),

          Text(
            'Hôpital / Clinique',
            style: TextStyle(color: palette.textSecondary, fontSize: 13),
          ),
          const SizedBox(height: 6),
          hospitalsAsync.when(
            data: (hospitals) {
              if (hospitals.isEmpty) {
                return Text(
                  "Aucun hôpital enregistré.",
                  style: TextStyle(color: palette.textSecondary),
                );
              }
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: palette.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: palette.border),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<Hospital>(
                    value: _hospital,
                    isExpanded: true,
                    dropdownColor: palette.surface,
                    hint: Text(
                      'Sélectionner un établissement',
                      style: TextStyle(
                        color: palette.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                    items: [
                      for (final hospital in hospitals)
                        DropdownMenuItem(
                          value: hospital,
                          child: Text(
                            '${hospital.name} (${hospital.city})',
                            style: TextStyle(
                              color: palette.textPrimary,
                              fontSize: 14,
                            ),
                          ),
                        ),
                    ],
                    onChanged: _isSubmitting
                        ? null
                        : (value) {
                            setState(() {
                              _hospital = value;
                              if (value != null &&
                                  _phoneController.text.trim().isEmpty) {
                                _phoneController.text = value.phone;
                              }
                            });
                          },
                  ),
                ),
              );
            },
            loading: () => const LinearProgressIndicator(),
            error: (_, _) => Text(
              'Erreur de chargement des hôpitaux.',
              style: TextStyle(color: palette.textSecondary),
            ),
          ),

          const SizedBox(height: 14),

          Text(
            'Service & Bâtiment',
            style: TextStyle(color: palette.textSecondary, fontSize: 13),
          ),
          const SizedBox(height: 6),
          _buildTextField(
            palette: palette,
            controller: _departmentController,
            hintText: 'Ex. Service Réanimation Pédiatrique - Bâtiment B',
            icon: Icons.meeting_room_outlined,
          ),

          const SizedBox(height: 14),

          Text(
            'Numéro direct de la permanence ou du médecin',
            style: TextStyle(color: palette.textSecondary, fontSize: 13),
          ),
          const SizedBox(height: 6),
          _buildTextField(
            palette: palette,
            controller: _phoneController,
            hintText: '+237 233 42 12 34',
            keyboardType: TextInputType.phone,
            icon: Icons.phone_outlined,
          ),

          const SizedBox(height: 24),

          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: palette.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: palette.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.shield_outlined,
                      color: AppColors.info,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Alerte Citoyenne Immédiate',
                        style: TextStyle(
                          color: palette.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Diffusion directe aux donneurs compatibles',
                  style: TextStyle(color: palette.textSecondary, fontSize: 12),
                ),
                Divider(color: palette.border, height: 20),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Vous êtes soignant ? Ajouter un code de validation',
                        style: TextStyle(
                          color: palette.textPrimary,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    Switch(
                      value: _isCaregiver,
                      activeThumbColor: AppColors.primary,
                      onChanged: (val) => setState(() => _isCaregiver = val),
                    ),
                  ],
                ),
                if (_isCaregiver) ...[
                  const SizedBox(height: 8),
                  _buildTextField(
                    palette: palette,
                    controller: _caregiverCodeController,
                    hintText: 'Code professionnel de santé',
                    icon: Icons.verified_user_outlined,
                  ),
                ],
              ],
            ),
          ),

          if (_errorMessage != null) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.3),
                ),
              ),
              child: Text(
                _errorMessage!,
                style: TextStyle(color: palette.textPrimary, fontSize: 13),
              ),
            ),
          ],

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildBloodGroupGrid(AppPalette palette) {
    final groups = BloodGroup.values;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: groups.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 1.5,
      ),
      itemBuilder: (context, index) {
        final group = groups[index];
        final isSelected = _bloodGroup == group;

        return InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: _isSubmitting
              ? null
              : () => setState(() => _bloodGroup = isSelected ? null : group),
          child: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary : palette.surface,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isSelected ? AppColors.primary : palette.border,
                width: isSelected ? 1.5 : 1,
              ),
            ),
            child: Text(
              group.label,
              style: TextStyle(
                color: isSelected ? Colors.white : palette.textPrimary,
                fontSize: 16,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStepButton({
    required AppPalette palette,
    required IconData icon,
    required VoidCallback? onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: palette.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: palette.border),
        ),
        child: Icon(
          icon,
          color: onTap != null
              ? palette.textPrimary
              : palette.textSecondary.withValues(alpha: 0.4),
          size: 20,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required AppPalette palette,
    required TextEditingController controller,
    required String hintText,
    IconData? icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      enabled: !_isSubmitting,
      keyboardType: keyboardType,
      style: TextStyle(color: palette.textPrimary, fontSize: 14),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: palette.textSecondary, fontSize: 13),
        prefixIcon: icon != null
            ? Icon(icon, color: palette.textSecondary, size: 20)
            : null,
        filled: true,
        fillColor: palette.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: palette.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: palette.border),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide(color: AppColors.primary, width: 1.5),
        ),
      ),
    );
  }
}
