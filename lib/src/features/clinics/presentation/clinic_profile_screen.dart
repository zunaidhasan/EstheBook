import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/data/app_providers.dart';
import '../../../core/domain/clinic.dart';
import '../../../core/domain/treatment.dart';
import '../../../core/presentation/widgets/eb_widgets.dart';
import '../../../core/theme/eb_gradients.dart';
import '../../../core/theme/eb_theme.dart';
import '../../../core/utils/eb_formatters.dart';

/// Verified clinic profile: gallery, amenities, practitioners, treatment menu.
class ClinicProfileScreen extends ConsumerWidget {
  const ClinicProfileScreen({super.key, required this.clinicId});

  final String clinicId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repoAsync = ref.watch(mockRepositoryProvider);

    return repoAsync.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(
        appBar: AppBar(),
        body: EbEmptyState(
          icon: Icons.cloud_off_outlined,
          title: 'Couldn’t load this clinic',
          message: 'Please check your connection and try again.',
          actionLabel: 'Retry',
          onAction: () => ref.invalidate(mockRepositoryProvider),
        ),
      ),
      data: (repo) {
        final clinic = repo.clinicById(clinicId);
        if (clinic == null) {
          return Scaffold(
            appBar: AppBar(),
            body: const EbEmptyState(
              icon: Icons.storefront,
              title: 'Clinic not found',
              message: 'This clinic may have closed or the link is out of date.',
            ),
          );
        }
        final treatments = repo.treatmentsForClinic(clinic.id);
        return _ClinicProfileContent(clinic: clinic, treatments: treatments);
      },
    );
  }
}

class _ClinicProfileContent extends StatelessWidget {
  const _ClinicProfileContent({required this.clinic, required this.treatments});

  final Clinic clinic;
  final List<Treatment> treatments;

  @override
  Widget build(BuildContext context) {
    final cheapest = treatments.isEmpty
        ? 0
        : treatments.map((t) => t.price).reduce((a, b) => a < b ? a : b);

    final content = CustomScrollView(
      slivers: [
        SliverAppBar(
          pinned: true,
          expandedHeight: 210,
          toolbarHeight: 56,
          backgroundColor: EbColors.surface,
          surfaceTintColor: Colors.transparent,
          leading: _CircularIconButton(
            icon: Icons.arrow_back,
            onTap: () => Navigator.of(context).maybePop(),
          ),
          actions: [
            _CircularIconButton(
              icon: Icons.ios_share,
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Sharing is coming in V2 ✨')),
                );
              },
            ),
            const SizedBox(width: 8),
          ],
          flexibleSpace: FlexibleSpaceBar(
            background: EbGradientPlaceholder(seed: clinic.gradSeed, iconSize: 56),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name + rating
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(clinic.name, style: EbTextStyles.h1),
                          const SizedBox(height: 4),
                          Text(clinic.tagline, style: EbTextStyles.subtitle),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(EbRadius.chip),
                        boxShadow: EbShadows.soft,
                      ),
                      child: EbRatingBadge(rating: clinic.rating, reviewCount: clinic.reviewCount),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    EbPill(
                      label: clinic.isOpenNow ? 'Open now' : 'Closed',
                      icon: clinic.isOpenNow ? Icons.lock_open : Icons.lock_outline,
                      background: clinic.isOpenNow
                          ? EbColors.sage.withValues(alpha: 0.18)
                          : EbColors.blush,
                      color: clinic.isOpenNow ? EbColors.sageDeep : EbColors.onBlush,
                    ),
                    for (final s in clinic.specialties) EbPill(label: s),
                    EbPill(label: clinic.priceLabel, icon: Icons.payments_outlined),
                  ],
                ),
                const SizedBox(height: 18),

                // Quick facts row
                Row(
                  children: [
                    Expanded(
                      child: EbStatCard(
                        icon: Icons.location_on_outlined,
                        value: clinic.district,
                        label: '${clinic.city} · ${clinic.priceLabel}',
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: EbStatCard(
                        icon: Icons.schedule,
                        value: '${clinic.openHour}:00–${clinic.closeHour}:00',
                        label: 'Opening hours',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                EbStatCard(
                  icon: Icons.spa_outlined,
                  value: EbFormatters.moneyRange(cheapest, treatments.isEmpty ? 0 : treatments.map((t) => t.price).reduce((a, b) => a > b ? a : b)),
                  label: 'Treatment price range',
                ),

                // About
                const EbSectionHeader(title: 'About the clinic', subtitle: 'Overview'),
                Text(clinic.description, style: EbTextStyles.body),
                const SizedBox(height: 10),

                // Amenities
                const EbSectionHeader(title: 'Amenities', subtitle: 'Comfort'),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final a in clinic.amenities)
                      EbPill(label: a, icon: Icons.check_circle_outline, background: EbColors.blush),
                  ],
                ),

                // Practitioners
                const EbSectionHeader(title: 'Meet the practitioners', subtitle: 'Team'),
                for (final p in clinic.practitioners)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: EbCard(
                      padding: const EdgeInsets.all(14),
                      child: Row(
                        children: [
                          EbIconBadge(
                            icon: Icons.face_retouching_natural,
                            background: EbGradients.bySeed(p.name.hashCode).colors.first,
                            color: EbColors.ink,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(p.name, style: EbTextStyles.bodyStrong),
                                const SizedBox(height: 2),
                                Text(
                                  '${p.title} · ${p.specialty}',
                                  style: EbTextStyles.label,
                                ),
                              ],
                            ),
                          ),
                          Text(
                            '${p.yearsExperience} yrs',
                            style: EbTextStyles.overline,
                          ),
                        ],
                      ),
                    ),
                  ),

                // Treatment menu
                const EbSectionHeader(
                  title: 'Treatment menu',
                  subtitle: 'Treatments',
                  trailing: Text(
                    '${treatments.length} available',
                    style: EbTextStyles.label,
                  ),
                ),
                for (final t in treatments) _TreatmentTile(treatment: t),
              ],
            ),
          ),
        ),
      ],
    );

    return Scaffold(
      backgroundColor: EbColors.surface,
      body: Stack(
        children: [
          Positioned.fill(child: content),
          // Sticky Book CTA
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: EdgeInsets.fromLTRB(
                20, 12, 20,
                12 + MediaQuery.paddingOf(context).bottom,
              ),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0x00FDFBF7), Color(0xFFFDFBF7)],
                ),
              ),
              child: EbCard(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('From', style: EbTextStyles.label),
                          EbPrice(amount: cheapest),
                        ],
                      ),
                    ),
                    FilledButton(
                      onPressed: () => context.push('/discover/clinic/${clinic.id}/book'),
                      child: const Text('Book a treatment'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CircularIconButton extends StatelessWidget {
  const _CircularIconButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Material(
        color: Colors.white.withValues(alpha: 0.94),
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Icon(icon, size: 20, color: EbColors.ink),
          ),
        ),
      ),
    );
  }
}

class _TreatmentTile extends StatelessWidget {
  const _TreatmentTile({required this.treatment});

  final Treatment treatment;

  Color get _downtimeColor {
    switch (treatment.downtime) {
      case Downtime.none:
        return EbColors.success;
      case Downtime.low:
        return EbColors.info;
      case Downtime.medium:
        return EbColors.warning;
      case Downtime.high:
        return EbColors.error;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: EbCard(
        padding: const EdgeInsets.all(14),
        onTap: () => context.push('/discover/clinic/${treatment.clinicId}/book?treatment=${treatment.id}'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(treatment.name, style: EbTextStyles.bodyStrong),
              ),
              const SizedBox(width: 8),
              EbPrice(amount: treatment.price),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            treatment.summary,
            style: EbTextStyles.label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              EbPill(label: '${treatment.durationMinutes} min', icon: Icons.schedule),
              EbDowntimePill(label: treatment.downtimeLabel, color: _downtimeColor),
              if (treatment.popularity >= 0.85)
                EbPill(
                  label: 'Popular',
                  icon: Icons.local_fire_department_outlined,
                  background: const Color(0xFFFDF0E4),
                  color: const Color(0xFFB97A3D),
                ),
            ],
          ),
        ],
        ),
      ),
    );
  }
}
