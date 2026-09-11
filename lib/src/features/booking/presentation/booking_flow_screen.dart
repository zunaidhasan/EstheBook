import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/data/app_providers.dart';
import '../../../core/domain/clinic.dart';
import '../../../core/domain/treatment.dart';
import '../../../core/presentation/widgets/eb_widgets.dart';
import '../../../core/theme/eb_theme.dart';
import '../../../core/utils/eb_formatters.dart';

/// Seamless booking: treatment → slot → confirm, in 3 taps.
class BookingFlowScreen extends ConsumerStatefulWidget {
  const BookingFlowScreen({
    super.key,
    required this.clinicId,
    this.preselectedTreatmentId,
  });

  final String clinicId;
  final String? preselectedTreatmentId;

  @override
  ConsumerState<BookingFlowScreen> createState() => _BookingFlowScreenState();
}

class _BookingFlowScreenState extends ConsumerState<BookingFlowScreen> {
  int _step = 0;
  Treatment? _treatment;
  DateTime? _slot;
  String? _practitioner;
  final _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Resolve the preselected treatment after the first frame (data is sync
    // once repository is loaded).
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || widget.preselectedTreatmentId == null) return;
      final repo = ref.read(mockRepositoryProvider).valueOrNull;
      final t = repo?.treatmentById(widget.preselectedTreatmentId!);
      if (t != null) {
        setState(() {
          _treatment = t;
          _step = 1;
        });
      }
    });
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  void _goStep(int step) {
    setState(() {
      if (step == 0) _slot = null; // re-choosing treatment invalidates the slot
      _step = step.clamp(0, 2);
    });
  }

  Future<void> _confirmBooking() async {
    final repo = ref.read(mockRepositoryProvider).valueOrNull;
    final clinic = repo?.clinicById(widget.clinicId);
    if (repo == null || clinic == null || _treatment == null || _slot == null) return;

    final router = GoRouter.of(context);

    final id = ref.read(bookingsProvider.notifier).add(
          clinicId: clinic.id,
          clinicName: clinic.name,
          treatmentId: _treatment!.id,
          treatmentName: _treatment!.name,
          practitionerName: _practitioner ?? 'Next available',
          start: _slot!,
          durationMinutes: _treatment!.durationMinutes,
          price: _treatment!.price,
        );

    router.go('/booking/success', extra: {'appointmentId': id});
  }

  @override
  Widget build(BuildContext context) {
    final repoAsync = ref.watch(mockRepositoryProvider);
    return repoAsync.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(
        appBar: AppBar(),
        body: EbEmptyState(
          icon: Icons.cloud_off_outlined,
          title: 'Couldn’t load booking',
          message: 'Please try again.',
          actionLabel: 'Retry',
          onAction: () => ref.invalidate(mockRepositoryProvider),
        ),
      ),
      data: (repo) {
        final clinic = repo.clinicById(widget.clinicId);
        if (clinic == null) {
          return Scaffold(
            appBar: AppBar(),
            body: const EbEmptyState(
              icon: Icons.storefront,
              title: 'Clinic not found',
              message: 'We can’t find this clinic.',
            ),
          );
        }
        return _BookingFlowBody(
          clinic: clinic,
          treatments: repo.treatmentsForClinic(clinic.id),
          step: _step,
          treatment: _treatment,
          slot: _slot,
          practitioner: _practitioner,
          onTreatmentSelected: (t) {
            setState(() {
              _treatment = t;
              _step = 1;
            });
          },
          onSlotSelected: (slot) {
            setState(() {
              _slot = slot;
              _step = 2;
            });
          },
          onPractitionerSelected: (p) => setState(() => _practitioner = p),
          notesController: _notesController,
          onStepChanged: _goStep,
          onConfirm: _confirmBooking,
        );
      },
    );
  }
}

class _BookingFlowBody extends StatelessWidget {
  const _BookingFlowBody({
    required this.clinic,
    required this.treatments,
    required this.step,
    required this.treatment,
    required this.slot,
    required this.practitioner,
    required this.onTreatmentSelected,
    required this.onSlotSelected,
    required this.onPractitionerSelected,
    required this.notesController,
    required this.onStepChanged,
    required this.onConfirm,
  });

  final Clinic clinic;
  final List<Treatment> treatments;
  final int step;
  final Treatment? treatment;
  final DateTime? slot;
  final String? practitioner;
  final ValueChanged<Treatment> onTreatmentSelected;
  final ValueChanged<DateTime> onSlotSelected;
  final ValueChanged<String?> onPractitionerSelected;
  final TextEditingController notesController;
  final ValueChanged<int> onStepChanged;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    final titles = ['Choose treatment', 'Pick date & time', 'Confirm'];
    return Scaffold(
      backgroundColor: EbColors.surface,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (step > 0) {
              onStepChanged(step - 1);
            } else {
              Navigator.of(context).maybePop();
            }
          },
        ),
        title: Text('Book · ${clinic.name}', maxLines: 1, overflow: TextOverflow.ellipsis),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Stepper header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 4),
              child: Row(
                children: [
                  for (var i = 0; i < 3; i++) ...[
                    _StepDot(index: i, active: i <= step),
                    if (i < 2) Expanded(child: _StepConnector(active: i < step)),
                  ],
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 6, 20, 0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Step ${step + 1} of 3 · ${titles[step]}',
                  style: EbTextStyles.subtitle,
                ),
              ),
            ),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 260),
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeInCubic,
                transitionBuilder: (child, anim) => FadeTransition(
                  opacity: anim,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0.03, 0),
                      end: Offset.zero,
                    ).animate(anim),
                    child: child,
                  ),
                ),
                child: switch (step) {
                  0 => _StepTreatment(
                      key: const ValueKey(0),
                      treatments: treatments,
                      selected: treatment,
                      onSelect: onTreatmentSelected,
                    ),
                  1 => _StepSlot(
                      key: const ValueKey(1),
                      clinic: clinic,
                      selectedSlot: slot,
                      onSelect: onSlotSelected,
                    ),
                  _ => _StepConfirm(
                      key: const ValueKey(2),
                      clinic: clinic,
                      treatment: treatment,
                      slot: slot,
                      practitioner: practitioner,
                      onPractitionerSelected: onPractitionerSelected,
                      notesController: notesController,
                      onConfirm: onConfirm,
                    ),
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StepDot extends StatelessWidget {
  const _StepDot({required this.index, required this.active});

  final int index;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 26,
      height: 26,
      decoration: BoxDecoration(
        color: active ? EbColors.sageDeep : EbColors.blush,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        '${index + 1}',
        style: EbTextStyles.label.copyWith(
          color: active ? Colors.white : EbColors.onBlush,
        ),
      ),
    );
  }
}

class _StepConnector extends StatelessWidget {
  const _StepConnector({required this.active});

  final bool active;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 2,
      margin: const EdgeInsets.symmetric(horizontal: 6),
      decoration: BoxDecoration(
        color: active ? EbColors.sageDeep : EbColors.blush,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}

// ----------------------------- Step 1 ---------------------------------------

class _StepTreatment extends StatelessWidget {
  const _StepTreatment({
    super.key,
    required this.treatments,
    required this.selected,
    required this.onSelect,
  });

  final List<Treatment> treatments;
  final Treatment? selected;
  final ValueChanged<Treatment> onSelect;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      itemCount: treatments.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, i) {
        final t = treatments[i];
        final isSel = selected?.id == t.id;
        return EbCard(
          onTap: () => onSelect(t),
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSel ? EbColors.sageDeep : Colors.white,
                  border: Border.all(
                    color: isSel ? EbColors.sageDeep : const Color(0xFFD9CCC6),
                    width: 2,
                  ),
                ),
                child: isSel
                    ? const Icon(Icons.check, size: 14, color: Colors.white)
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(t.name, style: EbTextStyles.bodyStrong),
                    const SizedBox(height: 4),
                    Text(
                      '${t.durationMinutes} min · ${t.downtimeLabel}',
                      style: EbTextStyles.label,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              EbPrice(amount: t.price),
            ],
          ),
        );
      },
    );
  }
}

// ----------------------------- Step 2 ---------------------------------------

class _StepSlot extends ConsumerStatefulWidget {
  const _StepSlot({
    super.key,
    required this.clinic,
    required this.selectedSlot,
    required this.onSelect,
  });

  final Clinic clinic;
  final DateTime? selectedSlot;
  final ValueChanged<DateTime> onSelect;

  @override
  ConsumerState<_StepSlot> createState() => _StepSlotState();
}

class _StepSlotState extends ConsumerState<_StepSlot> {
  DateTime _day = DateTime.now();

  bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  @override
  Widget build(BuildContext context) {
    final repo = ref.watch(mockRepositoryProvider).valueOrNull;
    if (repo == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final slots = repo.slotsForDay(widget.clinic, _day)
        .where((s) => s.isAfter(DateTime.now()))
        .toList();

    return Column(
      children: [
        // Day picker strip
        SizedBox(
          height: 92,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: 21,
            itemBuilder: (context, i) {
              final day = DateTime.now().add(Duration(days: i));
              final isSel = _sameDay(day, _day);
              final closed = day.weekday == DateTime.sunday;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Opacity(
                  opacity: closed ? 0.45 : 1,
                  child: ChoiceChip(
                    label: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          EbFormatters.relativeDay(day, DateTime.now()),
                          style: EbTextStyles.label.copyWith(
                            color: isSel ? Colors.white : EbColors.ink,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          EbFormatters.dateShort(day).split(',')[1].trim(),
                          style: EbTextStyles.label.copyWith(
                            fontSize: 10,
                            color: isSel ? Colors.white70 : EbColors.inkSoft,
                          ),
                        ),
                      ],
                    ),
                    selected: isSel,
                    showCheckmark: false,
                    onSelected: closed ? null : (_) => setState(() => _day = day),
                    selectedColor: EbColors.sageDeep,
                    backgroundColor: Colors.white,
                    side: BorderSide(color: isSel ? EbColors.sageDeep : EbColors.divider),
                  ),
                ),
              );
            },
          ),
        ),
        Expanded(
          child: slots.isEmpty
              ? EbEmptyState(
                  icon: Icons.event_busy,
                  title: 'No slots left',
                  message: 'Fully booked for this day — please pick another date.',
                )
              : GridView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 110,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    childAspectRatio: 2.4,
                  ),
                  itemCount: slots.length,
                  itemBuilder: (context, i) {
                    final s = slots[i];
                    final taken = repo.isSlotTaken(widget.clinic, s);
                    final isSel = widget.selectedSlot == s;
                    return _SlotChip(
                      slot: s,
                      taken: taken,
                      selected: isSel,
                      onTap: taken ? null : () => widget.onSelect(s),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class _SlotChip extends StatelessWidget {
  const _SlotChip({
    required this.slot,
    required this.taken,
    required this.selected,
    required this.onTap,
  });

  final DateTime slot;
  final bool taken;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final bg = taken
        ? EbColors.shimmerBase
        : selected
            ? EbColors.sageDeep
            : Colors.white;
    final fg = taken
        ? const Color(0xFFB9A9A9)
        : selected
            ? Colors.white
            : EbColors.ink;

    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Center(
          child: Text(
            taken
                ? '${EbFormatters.time(slot)}  ✕'
                : EbFormatters.time(slot),
            style: EbTextStyles.bodyStrong.copyWith(color: fg, fontSize: 12.5),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}

// ----------------------------- Step 3 ---------------------------------------

class _StepConfirm extends StatelessWidget {
  const _StepConfirm({
    super.key,
    required this.clinic,
    required this.treatment,
    required this.slot,
    required this.practitioner,
    required this.onPractitionerSelected,
    required this.notesController,
    required this.onConfirm,
  });

  final VoidCallback onConfirm;

  final Clinic clinic;
  final Treatment? treatment;
  final DateTime? slot;
  final String? practitioner;
  final ValueChanged<String?> onPractitionerSelected;
  final TextEditingController notesController;

  @override
  Widget build(BuildContext context) {
    if (treatment == null || slot == null) {
      return const EbEmptyState(
        icon: Icons.error_outline,
        title: 'Almost there',
        message: 'Please complete the previous steps first.',
      );
    }

    final practitioners = [
      'Next available',
      for (final p in clinic.practitioners) p.name,
    ];

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      children: [
        EbCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Booking summary', style: EbTextStyles.h3),
              const SizedBox(height: 12),
              _SummaryRow(icon: Icons.spa_outlined, label: 'Treatment', value: treatment!.name),
              _SummaryRow(icon: Icons.storefront_outlined, label: 'Clinic', value: clinic.name),
              _SummaryRow(
                icon: Icons.event_outlined,
                label: 'When',
                value:
                    '${EbFormatters.dateLong(slot!)}, ${EbFormatters.time(slot!)} · ${treatment!.durationMinutes} min',
              ),
              _SummaryRow(
                icon: Icons.payments_outlined,
                label: 'Total',
                value: EbFormatters.money(treatment!.price),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        EbCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Practitioner', style: EbTextStyles.h3),
              const SizedBox(height: 4),
              Text(
                'Optional — choose who you’d like to see.',
                style: EbTextStyles.label,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final name in practitioners)
                    ChoiceChip(
                      label: Text(name),
                      selected: (practitioner ?? 'Next available') == name,
                      showCheckmark: false,
                      onSelected: (_) => onPractitionerSelected(name),
                      labelStyle: EbTextStyles.label.copyWith(
                        color: (practitioner ?? 'Next available') == name
                            ? Colors.white
                            : EbColors.ink,
                      ),
                      selectedColor: EbColors.sageDeep,
                    ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        EbCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Notes for the clinic', style: EbTextStyles.h3),
              const SizedBox(height: 8),
              TextField(
                controller: notesController,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: 'Allergies, preferences, questions…',
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        FilledButton(
          onPressed: () {
            showDialog<void>(
              context: context,
              builder: (dialogContext) => AlertDialog(
                title: const Text('Confirm booking?'),
                content: Text(
                  '${treatment!.name}\n${EbFormatters.dateLong(slot!)} at ${EbFormatters.time(slot!)}\nat ${clinic.name}',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(dialogContext).pop(),
                    child: const Text('Not yet'),
                  ),
                  FilledButton(
                    onPressed: () {
                      Navigator.of(dialogContext).pop();
                      onConfirm();
                    },
                    child: const Text('Confirm'),
                  ),
                ],
              ),
            );
          },
          child: const Text('Confirm booking'),
        ),
      ],
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.icon, required this.label, required this.value});

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: EbColors.inkSoft),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: EbTextStyles.label),
                const SizedBox(height: 1),
                Text(value, style: EbTextStyles.bodyStrong),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
