import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../profile/presentation/providers/profile_providers.dart';
import '../providers/pharmacy_provider.dart';
import '../widgets/pharmacy_card.dart';
import '../widgets/sector_map_preview.dart';
import 'prescription_scanner_screen.dart';

class PharmacyListScreen extends ConsumerStatefulWidget {
  const PharmacyListScreen({super.key});

  @override
  ConsumerState<PharmacyListScreen> createState() => _PharmacyListScreenState();
}

class _PharmacyListScreenState extends ConsumerState<PharmacyListScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pharmacies = ref.watch(filteredPharmaciesProvider);
    final activeFilter = ref.watch(pharmacyFilterProvider);
    final onDutyCount = pharmacies.where((p) => p.isOnDuty).length;
    final palette = context.palette;
    final profile = ref.watch(userProfileProvider).asData?.value;
    final cityLabel = profile != null && profile.city.isNotEmpty
        ? profile.city
        : 'votre secteur';

    return Scaffold(
      backgroundColor: palette.background,
      appBar: AppBar(
        backgroundColor: palette.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: AppColors.tealLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.local_pharmacy_rounded,
                color: AppColors.tealPrimary,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pharmacies de Garde',
                  style: TextStyle(
                    color: palette.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.location_on,
                      size: 12,
                      color: AppColors.tealPrimary,
                    ),
                    const SizedBox(width: 3),
                    Text(
                      cityLabel,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.tealPrimary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.only(top: 8, bottom: 32),
        children: [
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: _searchController,
              style: TextStyle(color: palette.textPrimary, fontSize: 14),
              onChanged: (val) {
                ref.read(pharmacySearchQueryProvider.notifier).setQuery(val);
              },
              decoration: InputDecoration(
                filled: true,
                fillColor: palette.surface,
                hintText: 'Rechercher une pharmacie ou un quarti...',
                hintStyle: TextStyle(
                  color: palette.textSecondary,
                  fontSize: 14,
                ),
                prefixIcon: Icon(
                  Icons.search_rounded,
                  color: palette.textSecondary,
                  size: 22,
                ),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(
                          Icons.close_rounded,
                          color: palette.textSecondary,
                          size: 18,
                        ),
                        onPressed: () {
                          _searchController.clear();
                          ref
                              .read(pharmacySearchQueryProvider.notifier)
                              .setQuery('');
                        },
                      )
                    : null,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: palette.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: palette.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(
                    color: AppColors.tealPrimary,
                    width: 1.5,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      ref
                          .read(pharmacyFilterProvider.notifier)
                          .setFilter(PharmacyFilter.all);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 11),
                      decoration: BoxDecoration(
                        color: activeFilter == PharmacyFilter.all
                            ? AppColors.tealPrimary
                            : AppColors.softBlue,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'Ouverte maintenant',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: activeFilter == PharmacyFilter.all
                              ? Colors.white
                              : AppColors.tealPrimary,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      ref
                          .read(pharmacyFilterProvider.notifier)
                          .setFilter(PharmacyFilter.onDutyOnly);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 11),
                      decoration: BoxDecoration(
                        color: activeFilter == PharmacyFilter.onDutyOnly
                            ? AppColors.tealPrimary
                            : AppColors.softBlue,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'Officine de garde confirmée',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: activeFilter == PharmacyFilter.onDutyOnly
                              ? Colors.white
                              : AppColors.tealPrimary,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: GestureDetector(
              onTap: () async {
                final scannedMed = await Navigator.push<String?>(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PrescriptionScannerScreen(),
                  ),
                );
                if (scannedMed != null && scannedMed.isNotEmpty) {
                  _searchController.text = scannedMed;
                  ref
                      .read(pharmacySearchQueryProvider.notifier)
                      .setQuery(scannedMed);
                }
              },
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.tealPrimary.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: AppColors.tealPrimary.withValues(alpha: 0.35),
                        ),
                      ),
                      child: const Icon(
                        Icons.document_scanner_rounded,
                        color: AppColors.tealPrimary,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Scanner une ordonnance avec l\'IA',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Recherche automatique des stocks',
                            style: TextStyle(
                              color: Color(0xFF94A3B8),
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.arrow_forward_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          if (pharmacies.isEmpty)
            Padding(
              padding: const EdgeInsets.all(40),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.search_off_rounded,
                      size: 48,
                      color: palette.textSecondary.withValues(alpha: 0.5),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Aucune pharmacie trouvée pour cette recherche.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: palette.textSecondary,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            ...pharmacies.map((p) => PharmacyCard(pharmacy: p)),
          const SizedBox(height: 8),
          SectorMapPreview(
            onDutyCount: onDutyCount,
            currentSector: cityLabel,
            pharmacies: pharmacies,
          ),
        ],
      ),
    );
  }
}
