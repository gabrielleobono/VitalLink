import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/blood_request_enums.dart';
import '../providers/pledge_providers.dart';

/// Ouvre le bottom sheet d'engagement pour l'alerte [requestId].
/// Retourne `true` si l'engagement a bien ÃƒÂ©tÃƒÂ© enregistrÃƒÂ©.
Future<bool?> showEngagementBottomSheet(
  BuildContext context, {
  required String requestId,
}) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) => _EngagementSheet(requestId: requestId),
  );
}

class _EngagementSheet extends ConsumerStatefulWidget {
  const _EngagementSheet({required this.requestId});

  final String requestId;

  @override
  ConsumerState<_EngagementSheet> createState() => _EngagementSheetState();
}

class _EngagementSheetState extends ConsumerState<_EngagementSheet> {
  ArrivalEstimate? _selected;
  bool _isSubmitting = false;
  String? _errorMessage;

  Future<void> _confirm() async {
    final selected = _selected;
    if (selected == null) return;

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      final donorId = await ref.read(currentUserIdProvider.future);
      await ref
          .read(pledgeRepositoryProvider)
          .pledge(
            requestId: widget.requestId,
            donorId: donorId,
            estimatedArrival: selected,
          );
      if (mounted) Navigator.of(context).pop(true);
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
        _errorMessage =
            "L'engagement n'a pas pu ÃƒÂªtre enregistrÃƒÂ©. VÃƒÂ©rifiez votre connexion et rÃƒÂ©essayez.";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: 20 + MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Je viens donner',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
            ),
            const SizedBox(height: 6),
            const Text(
              "Dans combien de temps pouvez-vous arriver ?",
              style: TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),
            RadioGroup<ArrivalEstimate>(
              groupValue: _selected,
              onChanged: (value) {
                if (_isSubmitting) return;
                setState(() => _selected = value);
              },
              child: Column(
                children: [
                  for (final estimate in ArrivalEstimate.values)
                    RadioListTile<ArrivalEstimate>(
                      contentPadding: EdgeInsets.zero,
                      value: estimate,
                      title: Text(estimate.label),
                    ),
                ],
              ),
            ),
            if (_errorMessage != null) ...[
              const SizedBox(height: 8),
              Text(
                _errorMessage!,
                style: const TextStyle(color: AppColors.primary, fontSize: 13),
              ),
            ],
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _selected == null || _isSubmitting ? null : _confirm,
                child: _isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Confirmer mon engagement'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
