import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Les 8 groupes sanguins (système ABO + Rhésus).
enum BloodGroup {
  oNegative,
  oPositive,
  aNegative,
  aPositive,
  bNegative,
  bPositive,
  abNegative,
  abPositive,
}

/// Libellé court affiché à l'écran ("O-", "AB+", ...).
extension BloodGroupLabel on BloodGroup {
  String get label => switch (this) {
        BloodGroup.oNegative => 'O-',
        BloodGroup.oPositive => 'O+',
        BloodGroup.aNegative => 'A-',
        BloodGroup.aPositive => 'A+',
        BloodGroup.bNegative => 'B-',
        BloodGroup.bPositive => 'B+',
        BloodGroup.abNegative => 'AB-',
        BloodGroup.abPositive => 'AB+',
      };
}

/// Table de compatibilité transfusionnelle (globules rouges) et règles de
/// priorité de notification associées.
///
/// Voir CONTEXT.md > "Règles métier > Compatibilité sanguine" : c'est la
/// référence médicale exacte, ne pas modifier ces valeurs sans revalider
/// avec cette source.
abstract final class BloodCompatibility {
  static const Map<BloodGroup, Set<BloodGroup>> _compatibleDonors = {
    BloodGroup.oNegative: {BloodGroup.oNegative},
    BloodGroup.oPositive: {BloodGroup.oNegative, BloodGroup.oPositive},
    BloodGroup.aNegative: {BloodGroup.oNegative, BloodGroup.aNegative},
    BloodGroup.aPositive: {
      BloodGroup.oNegative,
      BloodGroup.oPositive,
      BloodGroup.aNegative,
      BloodGroup.aPositive,
    },
    BloodGroup.bNegative: {BloodGroup.oNegative, BloodGroup.bNegative},
    BloodGroup.bPositive: {
      BloodGroup.oNegative,
      BloodGroup.oPositive,
      BloodGroup.bNegative,
      BloodGroup.bPositive,
    },
    BloodGroup.abNegative: {
      BloodGroup.oNegative,
      BloodGroup.aNegative,
      BloodGroup.bNegative,
      BloodGroup.abNegative,
    },
    // AB+ est receveur universel : compatible avec tous les groupes.
    BloodGroup.abPositive: {
      BloodGroup.oNegative,
      BloodGroup.oPositive,
      BloodGroup.aNegative,
      BloodGroup.aPositive,
      BloodGroup.bNegative,
      BloodGroup.bPositive,
      BloodGroup.abNegative,
      BloodGroup.abPositive,
    },
  };

  /// Groupes donneurs compatibles pour un [receiver] donné.
  static Set<BloodGroup> compatibleDonorsFor(BloodGroup receiver) =>
      _compatibleDonors[receiver]!;

  /// `true` si un donneur de groupe [donor] peut donner à un receveur de
  /// groupe [receiver].
  static bool canDonateTo({
    required BloodGroup donor,
    required BloodGroup receiver,
  }) =>
      _compatibleDonors[receiver]!.contains(donor);

  /// Ordre de priorité pour notifier les donneurs d'une alerte : le même
  /// groupe que le receveur d'abord, puis les autres groupes compatibles,
  /// et O- en tout dernier recours (donneur universel à préserver).
  ///
  /// Ne trie pas par distance : ce tri secondaire se fait dans la feature
  /// `donors` / les Cloud Functions, une fois qu'on a de vrais donneurs à
  /// classer.
  static List<BloodGroup> notificationPriorityFor(BloodGroup receiver) {
    final compatible = _compatibleDonors[receiver]!;
    return [
      if (compatible.contains(receiver)) receiver,
      for (final group in compatible)
        if (group != receiver && group != BloodGroup.oNegative) group,
      if (compatible.contains(BloodGroup.oNegative) &&
          receiver != BloodGroup.oNegative)
        BloodGroup.oNegative,
    ];
  }
}

/// Tableau visuel de compatibilité donneurs/receveurs, pour l'écran du guide
/// donneur (`donor_guide`).
class CompatibilityTable extends StatelessWidget {
  const CompatibilityTable({super.key});

  @override
  Widget build(BuildContext context) {
    return Table(
      border: TableBorder.all(color: AppColors.border),
      columnWidths: const {
        0: FixedColumnWidth(64),
        1: FlexColumnWidth(),
      },
      children: [
        _headerRow(),
        for (final receiver in BloodGroup.values) _row(receiver),
      ],
    );
  }

  TableRow _headerRow() {
    return TableRow(
      decoration: const BoxDecoration(color: AppColors.background),
      children: const [
        _Cell('Receveur', bold: true),
        _Cell('Peut recevoir de', bold: true),
      ],
    );
  }

  TableRow _row(BloodGroup receiver) {
    final donors = BloodCompatibility.compatibleDonorsFor(receiver)
        .map((g) => g.label)
        .join(', ');
    return TableRow(
      children: [
        _Cell(receiver.label, bold: true, color: AppColors.primary),
        _Cell(donors),
      ],
    );
  }
}

class _Cell extends StatelessWidget {
  const _Cell(this.text, {this.bold = false, this.color});

  final String text;
  final bool bold;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Text(
        text,
        style: TextStyle(
          fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
          color: color ?? AppColors.textPrimary,
        ),
      ),
    );
  }
}
