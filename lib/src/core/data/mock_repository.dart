import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/clinic.dart';
import '../domain/treatment.dart';

/// Loads and indexes the mock JSON datasets bundled with the app.
class MockRepository {
  MockRepository._(this._clinics, this._treatments);

  final List<Clinic> _clinics;
  final List<Treatment> _treatments;

  final Map<String, Clinic> _clinicsById = {};
  final Map<String, Treatment> _treatmentsById = {};

  static const String _clinicsAsset = 'assets/data/clinics.json';
  static const String _treatmentsAsset = 'assets/data/treatments.json';

  static Future<MockRepository> load() async {
    final clinicsJson = jsonDecode(await rootBundle.loadString(_clinicsAsset)) as List<dynamic>;
    final treatmentsJson = jsonDecode(await rootBundle.loadString(_treatmentsAsset)) as List<dynamic>;

    final repo = MockRepository._(
      clinicsJson.map((e) => Clinic.fromJson(e as Map<String, dynamic>)).toList(),
      treatmentsJson.map((e) => Treatment.fromJson(e as Map<String, dynamic>)).toList(),
    );

    for (final c in repo._clinics) {
      repo._clinicsById[c.id] = c;
    }
    for (final t in repo._treatments) {
      repo._treatmentsById[t.id] = t;
    }
    return repo;
  }

  List<Clinic> get clinics => List.unmodifiable(_clinics);

  List<Treatment> get treatments => List.unmodifiable(_treatments);

  Clinic? clinicById(String id) => _clinicsById[id];

  Treatment? treatmentById(String id) => _treatmentsById[id];

  List<Treatment> treatmentsForClinic(String clinicId) =>
      _treatments.where((t) => t.clinicId == clinicId).toList(growable: false);

  /// Slots the clinic can accept bookings for on the given day. A slot is
  /// offered every 30 minutes between opening and one hour before closing.
  List<DateTime> slotsForDay(Clinic clinic, DateTime day) {
    final slots = <DateTime>[];
    final start = DateTime(day.year, day.month, day.day, clinic.openHour);
    final lastStart = DateTime(day.year, day.month, day.day, clinic.closeHour - 1);
    for (var t = start;
        t.isBefore(lastStart) || t == lastStart;
        t = t.add(const Duration(minutes: 30))) {
      slots.add(t);
    }
    return slots;
  }

  /// Deterministic pseudo-availability so the mock feels alive: some slots
  /// are "taken" depending on clinic, day and time.
  bool isSlotTaken(Clinic clinic, DateTime slot) {
    final seed = clinic.id.hashCode ^ (slot.day * 31 + slot.hour * 7 + (slot.minute ~/ 30));
    return seed % 100 < 35; // ~35% of slots are taken.
  }
}
