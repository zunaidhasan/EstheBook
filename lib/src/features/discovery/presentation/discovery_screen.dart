import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/data/app_providers.dart';
import '../../../core/presentation/widgets/eb_widgets.dart';
import '../../../core/theme/eb_gradients.dart';
import '../../../core/theme/eb_theme.dart';

/// Smart discovery — browse clinics by specialty, district, and rating.
class DiscoveryScreen extends ConsumerStatefulWidget {
  const DiscoveryScreen({super.key});

  @override
  ConsumerState<DiscoveryScreen> createState() => _DiscoveryScreenState();
}

class _DiscoveryScreenState extends ConsumerState<DiscoveryScreen> {
  final _searchController = TextEditingController();
  final _searchFocus = FocusNode();

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  void _openFilterSheet() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => const _DiscoveryFilterSheet(),
    );
  }

  void _openSortSheet() {
    showModalBottomSheet<void>(
      context: context,
      builder: (_) => const _DiscoverySortSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filters = ref.watch(discoveryFiltersProvider);
    final results = ref.watch(filteredClinicsProvider);
    final session = ref.watch(sessionProvider);

    return SafeArea(
      bottom: false,
      child: Column(
        children: [
          // ---------------- Header ----------------
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Good ${_dayPart()}',
                            style: EbTextStyles.overline,
                          ),
                          const SizedBox(height: 2),
                          Text('Hi, ${session.userName} 👋', style: EbTextStyles.h1),
                        ],
                      ),
                    ),
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: EbColors.blush,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: const Center(
                        child: Text('🌸', style: TextStyle(fontSize: 22)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: _searchController,
                  focusNode: _searchFocus,
                  onChanged: (v) =>
                      ref.read(discoveryFiltersProvider.notifier).setQuery(v),
                  decoration: InputDecoration(
                    hintText: 'Search clinics, treatments, areas…',
                    prefixIcon: const Icon(Icons.search, color: EbColors.inkSoft),
                    suffixIcon: filters.query.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.close, size: 18),
                            onPressed: () {
                              _searchController.clear();
                              _searchFocus.unfocus();
                              ref.read(discoveryFiltersProvider.notifier).setQuery('');
                            },
                          )
                        : null,
                  ),
                  textInputAction: TextInputAction.search,
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 40,
                  child: Row(
                    children: [
                      _FilterButton(
                        active: filters.hasActiveFilters,
                        onTap: _openFilterSheet,
                      ),
                      const Spacer(),
                      _SortButton(onTap: _openSortSheet),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // ---------------- Results ----------------
          Expanded(
            child: results.when(
              loading: () => const _DiscoveryLoading(),
              error: (e, _) => EbEmptyState(
                icon: Icons.cloud_off_outlined,
                title: 'Something went wrong',
                message: 'We couldn’t load clinics. Please try again.',
                actionLabel: 'Retry',
                onAction: () => ref.invalidate(filteredClinicsProvider),
              ),
              data: (clinics) {
                if (clinics.isEmpty) {
                  return EbEmptyState(
                    icon: Icons.search_off,
                    title: 'No clinics found',
                    message: 'Try a different search term or clear your filters.',
                    actionLabel: 'Clear filters',
                    onAction: () {
                      _searchController.clear();
                      ref.read(discoveryFiltersProvider.notifier).reset();
                    },
                  );
                }
                return RefreshIndicator(
                  color: EbColors.sageDeep,
                  onRefresh: () async {
                    ref.invalidate(filteredClinicsProvider);
                    await ref.read(filteredClinicsProvider.future);
                  },
                  child: ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                    itemCount: clinics.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 14),
                    itemBuilder: (context, i) => _ClinicCard(data: clinics[i]),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String _dayPart() {
    final h = DateTime.now().hour;
    if (h < 12) return 'morning';
    if (h < 18) return 'afternoon';
    return 'evening';
  }
}

class _FilterButton extends StatelessWidget {
  const _FilterButton({required this.active, required this.onTap});

  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: active ? EbColors.sageDeep : Colors.white,
      shape: StadiumBorder(
        side: BorderSide(color: active ? EbColors.sageDeep : EbColors.divider),
      ),
      child: InkWell(
        onTap: onTap,
        customBorder: const StadiumBorder(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.tune_rounded,
                  size: 18,
                  color: active ? Colors.white : EbColors.ink,
                ),
                const SizedBox(width: 6),
                Text(
                  'Filters',
                  style: TextStyle(
                    color: active ? Colors.white : EbColors.ink,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                if (active) ...[
                  const SizedBox(width: 5),
                  const Icon(Icons.close, size: 14, color: Colors.white),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SortButton extends StatelessWidget {
  const _SortButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: EbColors.ink,
      borderRadius: BorderRadius.circular(EbRadius.chip),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(EbRadius.chip),
        child: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 14),
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.sort_rounded, size: 18, color: Colors.white),
                SizedBox(width: 6),
                Text('Sort', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DiscoveryLoading extends StatelessWidget {
  const _DiscoveryLoading();

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      itemCount: 4,
      separatorBuilder: (_, __) => const SizedBox(height: 14),
      itemBuilder: (_, __) => const _SkeletonCard(),
    );
  }
}

class _SkeletonCard extends StatefulWidget {
  const _SkeletonCard();

  @override
  State<_SkeletonCard> createState() => _SkeletonCardState();
}

class _SkeletonCardState extends State<_SkeletonCard> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: Tween(begin: 0.45, end: 1.0).animate(_c),
      child: Container(
        height: 150,
        decoration: BoxDecoration(
          color: EbColors.shimmerBase,
          borderRadius: BorderRadius.circular(EbRadius.card),
        ),
      ),
    );
  }
}

class _ClinicCard extends ConsumerWidget {
  const _ClinicCard({required this.data});

  final ClinicWithPrice data;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final clinic = data.clinic;
    return EbCard(
      onTap: () => context.push('/discover/clinic/${clinic.id}'),
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hero banner (gradient placeholder standing in for imagery).
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(EbRadius.card)),
            child: SizedBox(
              height: 110,
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  EbGradientPlaceholder(seed: clinic.gradSeed, iconSize: 44),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.92),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: EbRatingBadge(rating: clinic.rating, reviewCount: clinic.reviewCount, compact: true),
                    ),
                  ),
                  if (!clinic.isOpenNow)
                    Positioned(
                      left: 10,
                      bottom: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.45),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          'Closed · opens ${clinic.openHour}:00',
                          style: EbTextStyles.label.copyWith(color: Colors.white, fontSize: 11),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(clinic.name, style: EbTextStyles.h3, maxLines: 1, overflow: TextOverflow.ellipsis),
                    ),
                    Text(clinic.priceLabel, style: EbTextStyles.price),
                  ],
                ),
                const SizedBox(height: 3),
                Text(clinic.tagline, style: EbTextStyles.subtitle, maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined, size: 15, color: EbColors.inkSoft),
                    const SizedBox(width: 3),
                    Expanded(
                      child: Text(
                        '${clinic.district}, ${clinic.city}',
                        style: EbTextStyles.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text('From ', style: EbTextStyles.label),
                    EbPrice(amount: data.priceFrom, small: true),
                  ],
                ),
                if (clinic.specialties.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      for (final s in clinic.specialties.take(3)) EbPill(label: s),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DiscoveryFilterSheet extends ConsumerStatefulWidget {
  const _DiscoveryFilterSheet();

  @override
  ConsumerState<_DiscoveryFilterSheet> createState() => _DiscoveryFilterSheetState();
}

class _DiscoveryFilterSheetState extends ConsumerState<_DiscoveryFilterSheet> {
  @override
  Widget build(BuildContext context) {
    final filters = ref.watch(discoveryFiltersProvider);
    final specialties = ref.watch(specialtiesProvider).valueOrNull ?? const <String>[];
    final districts = ref.watch(districtsProvider).valueOrNull ?? const <String>[];

    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
            child: Row(
              children: [
                const Expanded(child: Text('Filter clinics', style: EbTextStyles.h3)),
                TextButton(
                  onPressed: () => ref.read(discoveryFiltersProvider.notifier).reset(),
                  child: const Text('Reset'),
                ),
              ],
            ),
          ),
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Specialty', style: EbTextStyles.bodyStrong),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final s in specialties)
                        ChoiceChip(
                          label: Text(s),
                          selected: filters.specialty == s,
                          showCheckmark: false,
                          onSelected: (v) =>
                              ref.read(discoveryFiltersProvider.notifier).setSpecialty(v ? s : null),
                          labelStyle: EbTextStyles.label.copyWith(
                            color: filters.specialty == s ? Colors.white : EbColors.ink,
                          ),
                          selectedColor: EbColors.sageDeep,
                        ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  const Text('District', style: EbTextStyles.bodyStrong),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final d in districts)
                        ChoiceChip(
                          label: Text(d),
                          selected: filters.district == d,
                          showCheckmark: false,
                          onSelected: (v) =>
                              ref.read(discoveryFiltersProvider.notifier).setDistrict(v ? d : null),
                          labelStyle: EbTextStyles.label.copyWith(
                            color: filters.district == d ? Colors.white : EbColors.ink,
                          ),
                          selectedColor: EbColors.sageDeep,
                        ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  const Text('Minimum rating', style: EbTextStyles.bodyStrong),
                  Slider(
                    value: filters.minRating,
                    min: 0,
                    max: 5,
                    divisions: 10,
                    label: filters.minRating == 0 ? 'Any' : filters.minRating.toStringAsFixed(1),
                    activeColor: EbColors.sageDeep,
                    onChanged: (v) => ref.read(discoveryFiltersProvider.notifier).setMinRating(v),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Show results'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DiscoverySortSheet extends ConsumerWidget {
  const _DiscoverySortSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sort = ref.watch(discoveryFiltersProvider).sort;
    final options = <(DiscoverySort, String, String)>[
      (DiscoverySort.recommended, 'Recommended', 'Our balanced pick of top-rated clinics'),
      (DiscoverySort.ratingDesc, 'Highest rated', 'Best reviews first'),
      (DiscoverySort.priceAsc, 'Price: low to high', 'Gentlest on the wallet'),
      (DiscoverySort.priceDesc, 'Price: high to low', 'Premium programmes first'),
    ];

    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 4, 20, 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text('Sort by', style: EbTextStyles.h3),
            ),
          ),
          for (final (value, title, sub) in options)
            RadioListTile<DiscoverySort>(
              value: value,
              groupValue: sort,
              onChanged: (v) {
                ref.read(discoveryFiltersProvider.notifier).setSort(v!);
                Navigator.of(context).pop();
              },
              title: Text(title, style: EbTextStyles.bodyStrong),
              subtitle: Text(sub, style: EbTextStyles.label),
              activeColor: EbColors.sageDeep,
            ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
