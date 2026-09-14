import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/data/app_providers.dart';
import '../../../core/domain/appointment.dart';
import '../../../core/presentation/widgets/eb_widgets.dart';
import '../../../core/theme/eb_theme.dart';
import '../../../core/utils/eb_formatters.dart';

/// Confirmed booking screen, shown after a successful booking.
class BookingSuccessScreen extends ConsumerWidget {
  const BookingSuccessScreen({super.key, this.appointmentId});

  final String? appointmentId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookings = ref.watch(bookingsProvider);
    Appointment? appt;
    for (final a in bookings) {
      if (a.id == appointmentId) {
        appt = a;
        break;
      }
    }

    return Scaffold(
      backgroundColor: EbColors.surface,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 96,
                  height: 96,
                  decoration: const BoxDecoration(
                    color: EbColors.sage,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check_rounded, size: 52, color: Colors.white),
                ),
                const SizedBox(height: 22),
                const Text('You’re booked! 🌸', style: EbTextStyles.h1),
                const SizedBox(height: 6),
                const Text(
                  'A confirmation has been sent to your email.\nWe can’t wait to see you.',
                  style: EbTextStyles.subtitle,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                if (appt != null) ...[
                  EbCard(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      children: [
                        _Row('Treatment', appt.treatmentName),
                        _Row('Clinic', appt.clinicName),
                        _Row('Practitioner', appt.practitionerName),
                        _Row(
                          'When',
                          '${EbFormatters.dateLong(appt.start)} · ${EbFormatters.time(appt.start)}',
                        ),
                        _Row('Total paid', EbFormatters.money(appt.price)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 22),
                ],
                FilledButton(
                  onPressed: () => context.go('/bookings'),
                  child: const Text('View my bookings'),
                ),
                const SizedBox(height: 10),
                OutlinedButton(
                  onPressed: () => context.go('/discover'),
                  child: const Text('Back to discovery'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 108,
            child: Text(label, style: EbTextStyles.label),
          ),
          Expanded(
            child: Text(value, style: EbTextStyles.bodyStrong),
          ),
        ],
      ),
    );
  }
}
