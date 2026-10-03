import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/utils/blood_compatibility.dart';
import '../../../profile/presentation/providers/profile_providers.dart';
import '../widgets/eligibility_quiz.dart';

/// Guide du donneur : tableau de compatibilité + quiz d'éligibilité
/// (module 5 de CONTEXT.md). Fonctionne entièrement hors-ligne — aucune
/// donnée Firestore n'est lue au-delà du groupe sanguin déjà en cache pour
/// mettre en avant la ligne de l'utilisateur dans le tableau.
class DonorGuideScreen extends ConsumerStatefulWidget {
  const DonorGuideScreen({super.key});

  @override
  ConsumerState<DonorGuideScreen> createState() => _DonorGuideScreenState();
}

class _DonorGuideScreenState extends ConsumerState<DonorGuideScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final donorAsync = ref.watch(donorProfileProvider);
    final myGroup = BloodCompatibility.fromLabel(
      donorAsync.value?.bloodGroup ?? '',
    );

    return Scaffold(
      backgroundColor: palette.background,
      appBar: AppBar(
        backgroundColor: palette.surface,
        elevation: 0,
        title: Text(
          'Guide du donneur',
          style: TextStyle(
            color: palette.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: palette.textSecondary,
          indicatorColor: AppColors.primary,
          tabs: const [
            Tab(text: 'Compatibilité'),
            Tab(text: 'Quiz'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _CompatibilityTab(highlightedGroup: myGroup),
          const EligibilityQuiz(),
        ],
      ),
    );
  }
}

class _CompatibilityTab extends StatelessWidget {
  const _CompatibilityTab({required this.highlightedGroup});

  final BloodGroup? highlightedGroup;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (highlightedGroup != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(
              'Ta ligne (${highlightedGroup!.label}) est mise en avant '
              'ci-dessous.',
              style: TextStyle(fontSize: 12, color: palette.textSecondary),
            ),
          ),
        CompatibilityTable(highlightedGroup: highlightedGroup),
      ],
    );
  }
}
