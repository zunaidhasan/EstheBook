import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/data/app_providers.dart';
import '../../../core/domain/appointment.dart';
import '../../../core/presentation/widgets/eb_widgets.dart';
import '../../../core/theme/eb_theme.dart';
import '../../../core/utils/eb_formatters.dart';

/// User dashboard — track upcoming appointments and booking history.
class BookingsDashboardScreen extends ConsumerWidget {
  const BookingsDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final upcoming = ref.watch(upcomingBookingsProvider);
    final past = ref.watch(pastBookingsProvider);
    final session = ref.watch(sessionProvider);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: EbColors.surface,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('My Bookings', style: EbTextStyles.h2),
              Text(
                'Hi ${session.userName}, here’s your beauty diary',
                style: EbTextStyles.label,
              ),
            ],
          ),
          bottom: const TabBar(
            labelColor: EbColors.ink,
            unselectedLabelColor: EbColors.inkSoft,
            indicatorColor: EbColors.sageDeep,
            labelStyle: EbTextStyles.bodyStrong,
            tabs: [
              Tab(text: 'Upcoming'),
              Tab(text: 'History'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _UpcomingList(appointments: upcoming),
            _PastList(appointments: past),
          ],
        ),
      ),
    );
  }
}

class _UpcomingList extends ConsumerWidget {
  const _UpcomingList({required this.appointments});

  final List<Appointment> appointments;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (appointments.isEmpty) {
      return EbEmptyState(
        icon: Icons.event_available_outlined,
        title: 'Nothing booked yet',
        message: 'Your next self-care moment is a few taps away.',
        actionLabel: 'Explore clinics',
        onAction: () => context.go('/discover'),
      );
    }

    final next = appointments.first;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      children: [
        // Next appointment hero
        EbCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const EbIconBadge(icon: Icons.event, size: 40),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Next appointment', style: EbTextStyles.overline),
                        Text(
                          EbFormatters.relativeDay(next.start, DateTime.now()),
                          style: EbTextStyles.h2,
                        ),
                        Text(
                          '${EbFormatters.dateLong(next.start)} · ${EbFormatters.time(next.start)}',
                          style: EbTextStyles.label,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Divider(height: 24),
              _ApptTile(appt: next, highlight: true),
            ],
          ),
        ),
        if (appointments.length > 1) ...[
          const EbSectionHeader(title: 'Also coming up', subtitle: 'Upcoming'),
          for (final a in appointments.skip(1)) ...[
            _ApptTile(appt: a),
            const SizedBox(height: 10),
          ],
        ],
      ],
    );
  }
}

class _PastList extends ConsumerWidget {
  const _PastList({required this.appointments});

  final List<Appointment> appointments;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (appointments.isEmpty) {
      return const EbEmptyState(
        icon: Icons.history,
        title: 'No history yet',
        message: 'Completed and cancelled bookings will appear here.',
      );
    }

    final totalSpent = appointments
        .where((a) => a.status == BookingStatus.completed)
        .fold(0, (sum, a) => sum + a.price);

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      children: [
        Row(
          children: [
            Expanded(
              child: EbStatCard(
                icon: Icons.verified_outlined,
                value: '${appointments.length}',
                label: 'Total visits',
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: EbStatCard(
                icon: Icons.savings_outlined,
                value: EbFormatters.money(totalSpent),
                label: 'Invested in self-care',
              ),
            ),
          ],
        ),
        const EbSectionHeader(title: 'Past bookings', subtitle: 'History'),
        for (final a in appointments) ...[
          _ApptTile(appt: a),
          const SizedBox(height: 10),
        ],
      ],
    );
  }
}

class _ApptTile extends ConsumerWidget {
  const _ApptTile({required this.appt, this.highlight = false});

  final Appointment appt;
  final bool highlight;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPast = appt.status != BookingStatus.upcoming;

    return EbCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        children: [
          Row(
            children: [
              EbIconBadge(
                icon: appt.status == BookingStatus.cancelled
                    ? Icons.event_busy
                    : Icons.spa_outlined,
                background: appt.status == BookingStatus.cancelled
                    ? EbColors.shimmerBase
                    : EbColors.blush,
                color: appt.status == BookingStatus.cancelled
                    ? EbColors.inkSoft
                    : EbColors.onBlush,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(appt.treatmentName, style: EbTextStyles.bodyStrong),
                    const SizedBox(height: 2),
                    Text(
                      '${appt.clinicName} · ${appt.practitionerName}',
                      style: EbTextStyles.label,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${EbFormatters.relativeDay(appt.start, DateTime.now())} · ${EbFormatters.time(appt.start)} · ${EbFormatters.money(appt.price)}',
                      style: EbTextStyles.label.copyWith(color: EbColors.sageDeep),
                    ),
                  ],
                ),
              ),
              _StatusChip(status: appt.status),
            ],
          ),
          if (!isPast) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _showCancelDialog(context, ref),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(0, 44),
                      side: BorderSide(color: EbColors.error.withValues(alpha: 0.4)),
                      foregroundColor: EbColors.error,
                    ),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Rescheduling is coming in V2 ✨')),
                      );
                    },
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(0, 44),
                      backgroundColor: EbColors.sageDeep,
                    ),
                    child: const Text('Reschedule'),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  void _showCancelDialog(BuildContext context, WidgetRef ref) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Cancel this booking?'),
        content: Text(
          '${appt.treatmentName} at ${appt.clinicName} on ${EbFormatters.dateLong(appt.start)}.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Keep booking'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: EbColors.error),
            onPressed: () {
              ref.read(bookingsProvider.notifier).cancel(appt.id);
              Navigator.of(dialogContext).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Booking cancelled')),
              );
            },
            child: const Text('Cancel booking'),
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final BookingStatus status;

  @override
  Widget build(BuildContext context) {
    final (label, color, bg) = switch (status) {
      BookingStatus.upcoming => ('Upcoming', EbColors.sageDeep, EbColors.sage.withValues(alpha: 0.16)),
      BookingStatus.completed => ('Completed', EbColors.info, EbColors.info.withValues(alpha: 0.12)),
      BookingStatus.cancelled => ('Cancelled', EbColors.error, EbColors.error.withValues(alpha: 0.10)),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: EbTextStyles.label.copyWith(color: color, fontSize: 10.5),
      ),
    );
  }
}
