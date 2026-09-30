import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../../core/services/launcher_service.dart';
import '../../../../core/services/location_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/utils/blood_compatibility.dart';
import '../../data/models/hospital.dart';
import '../../../home/data/models/blood_alert.dart';

/// Bottom sheet "Confirmer votre don" ouverte depuis l'écran de détail
/// d'une urgence, une fois l'utilisateur prêt à s'engager.
Future<void> showConfirmDonationSheet({
  required BuildContext context,
  required BloodAlert alert,
  required Hospital? hospital,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) =>
        ConfirmDonationSheet(alert: alert, hospital: hospital),
  );
}

class ConfirmDonationSheet extends StatefulWidget {
  const ConfirmDonationSheet({super.key, required this.alert, this.hospital});

  final BloodAlert alert;
  final Hospital? hospital;

  @override
  State<ConfirmDonationSheet> createState() => _ConfirmDonationSheetState();
}

class _ConfirmDonationSheetState extends State<ConfirmDonationSheet> {
  final _phoneController = TextEditingController();
  double? _distanceKm;
  bool _submitting = false;
  BloodGroup? _selectedGroup;

  @override
  void initState() {
    super.initState();
    _distanceKm = widget.alert.distanceKm;
    _selectedGroup = _compatibleGroups.isNotEmpty
        ? _compatibleGroups.first
        : null;
    _refreshDistance();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  List<BloodGroup> get _compatibleGroups {
    return widget.alert.compatibleGroups
        .map(_parseBloodGroup)
        .whereType<BloodGroup>()
        .toList();
  }

  BloodGroup? _parseBloodGroup(String label) {
    for (final group in BloodGroup.values) {
      if (group.label == label) return group;
    }
    return null;
  }

  Future<void> _refreshDistance() async {
    final hospital = widget.hospital;
    if (hospital == null) return;
    final position = await LocationService.getCurrentPosition();
    if (position == null || !mounted) return;
    setState(() {
      _distanceKm = LocationService.distanceInKm(
        startLatitude: position.latitude,
        startLongitude: position.longitude,
        endLatitude: hospital.location.latitude,
        endLongitude: hospital.location.longitude,
      );
    });
  }

  Future<void> _confirm() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Connecte-toi pour confirmer ta venue (l'authentification n'est pas encore branchée).",
          ),
        ),
      );
      return;
    }

    setState(() => _submitting = true);
    try {
      await FirebaseFirestore.instance
          .collection('bloodAlerts')
          .doc(widget.alert.id)
          .collection('responses')
          .doc(user.uid)
          .set({
            'status': 'coming',
            'eta': Timestamp.now(),
            'respondedAt': Timestamp.now(),
          });

      final hospital = widget.hospital;
      if (hospital != null) {
        await LauncherService.openMapsDirections(
          latitude: hospital.location.latitude,
          longitude: hospital.location.longitude,
        );
      }
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Impossible de confirmer : $e")));
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final alert = widget.alert;
    final hospital = widget.hospital;
    final etaMinutes = _distanceKm == null
        ? null
        : (_distanceKm! / 15 * 60).round().clamp(4, 90);
    final requiredLabel = alert.compatibleGroups.length == 1
        ? 'Compatible ${alert.compatibleGroups.first} requis'
        : 'Compatible: ${alert.compatibleGroups.join(', ')}';

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.9,
        ),
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          decoration: BoxDecoration(
            color: palette.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: palette.border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Text(
                  'Confirmer votre don',
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                    color: palette.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${alert.hospitalName} • Urgences',
                  style: TextStyle(fontSize: 13, color: palette.textSecondary),
                ),
                const SizedBox(height: 14),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: palette.background,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    etaMinutes == null
                        ? 'Trajet estimé : ${_distanceKm?.toStringAsFixed(1) ?? alert.distanceKm.toStringAsFixed(1)} km'
                        : 'Trajet estimé : ${_distanceKm!.toStringAsFixed(1)} km (env. $etaMinutes min en route via Maps)',
                    style: TextStyle(
                      fontSize: 12,
                      color: palette.textSecondary,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Mon groupe sanguin',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: palette.textPrimary,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.softBlue,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        requiredLabel,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: BloodGroup.values.map((group) {
                    final isCompatible = _compatibleGroups.contains(group);
                    final isSelected = _selectedGroup == group;
                    return GestureDetector(
                      onTap: isCompatible
                          ? () => setState(() => _selectedGroup = group)
                          : null,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primary
                              : palette.background,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.primary
                                : palette.border,
                          ),
                        ),
                        child: Text(
                          group.label,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: isSelected
                                ? Colors.white
                                : isCompatible
                                ? palette.textPrimary
                                : palette.textSecondary,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                Text(
                  "Numéro pour l'équipe médicale",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: palette.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  decoration: BoxDecoration(
                    color: palette.background,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: palette.border),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: Row(
                    children: [
                      Text(
                        '+237',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: palette.textPrimary,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          style: TextStyle(
                            fontSize: 15,
                            color: palette.textPrimary,
                          ),
                          decoration: InputDecoration(
                            hintText: '699 00 12 34',
                            hintStyle: TextStyle(color: palette.textSecondary),
                            border: InputBorder.none,
                            filled: false,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _submitting ? null : _confirm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 0,
                    ),
                    child: _submitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'Je confirme ma venue & Itinéraire',
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: hospital == null
                        ? null
                        : () => LauncherService.callPhone(hospital.phone),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: palette.textPrimary,
                      side: BorderSide(color: palette.border),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(
                      hospital == null
                          ? "Appeler l'hôpital"
                          : "Appeler l'hôpital (${hospital.phone})",
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
