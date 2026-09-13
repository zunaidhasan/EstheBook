import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/appointment.dart';
import '../domain/clinic.dart';
import 'mock_repository.dart';

/// Provider for the singleton [MockRepository], loaded from assets.
final mockRepositoryProvider = FutureProvider<MockRepository>((ref) async {
  return MockRepository.load();
});

/// Simple in-memory auth state for V1 (no real authentication).
class SessionState {
  const SessionState({this.userName = 'Zunaid', this.hasOnboarded = false});

  final String userName;
  final bool hasOnboarded;

  SessionState copyWith({String? userName, bool? hasOnboarded}) {
    return SessionState(
      userName: userName ?? this.userName,
      hasOnboarded: hasOnboarded ?? this.hasOnboarded,
    );
  }
}

final sessionProvider = StateNotifierProvider<SessionController, SessionState>((ref) {
  return SessionController();
});

class SessionController extends StateNotifier<SessionState> {
  SessionController() : super(const SessionState());

  void completeOnboarding(String name) {
    state = state.copyWith(userName: name, hasOnboarded: true);
  }
}

// ---------------------------------------------------------------------------
// Discovery search & filter state
// ---------------------------------------------------------------------------

class DiscoveryFilters {
  const DiscoveryFilters({
    this.query = '',
    this.specialty,
    this.district,
    this.minRating = 0,
    this.sort = DiscoverySort.recommended,
  });

  final String query;
  final String? specialty;
  final String? district;
  final double minRating;
  final DiscoverySort sort;

  bool get hasActiveFilters =>
      query.isNotEmpty || specialty != null || district != null || minRating > 0;

  DiscoveryFilters copyWith({
    String? query,
    String? specialty,
    bool clearSpecialty = false,
    String? district,
    bool clearDistrict = false,
    double? minRating,
    DiscoverySort? sort,
  }) {
    return DiscoveryFilters(
      query: query ?? this.query,
      specialty: clearSpecialty ? null : (specialty ?? this.specialty),
      district: clearDistrict ? null : (district ?? this.district),
      minRating: minRating ?? this.minRating,
      sort: sort ?? this.sort,
    );
  }
}

enum DiscoverySort { recommended, ratingDesc, priceAsc, priceDesc }

/// A clinic joined with its cheapest treatment price, for result cards.
class ClinicWithPrice {
  const ClinicWithPrice({required this.clinic, required this.priceFrom});

  final Clinic clinic;
  final int priceFrom;
}

final discoveryFiltersProvider =
    StateNotifierProvider<DiscoveryFiltersController, DiscoveryFilters>((ref) {
  return DiscoveryFiltersController();
});

class DiscoveryFiltersController extends StateNotifier<DiscoveryFilters> {
  DiscoveryFiltersController() : super(const DiscoveryFilters());

  void setQuery(String q) => state = state.copyWith(query: q);

  void setSpecialty(String? s) =>
      state = state.copyWith(specialty: s, clearSpecialty: s == null);

  void setDistrict(String? d) =>
      state = state.copyWith(district: d, clearDistrict: d == null);

  void setMinRating(double r) => state = state.copyWith(minRating: r);

  void setSort(DiscoverySort s) => state = state.copyWith(sort: s);

  void reset() => state = const DiscoveryFilters();
}

final filteredClinicsProvider = FutureProvider.autoDispose<List<ClinicWithPrice>>((ref) async {
  final repo = await ref.watch(mockRepositoryProvider.future);
  final filters = ref.watch(discoveryFiltersProvider);
  // Keep the provider alive across re-sorting; avoid flicker by watching
  // filters but not disposing between keystrokes.
  ref.keepAlive();

  await Future<void>.delayed(const Duration(milliseconds: 220)); // mock latency

  final q = filters.query.trim().toLowerCase();
  final list = repo.clinics.where((c) {
    if (q.isNotEmpty &&
        !c.name.toLowerCase().contains(q) &&
        !c.tagline.toLowerCase().contains(q) &&
        !c.specialties.any((s) => s.toLowerCase().contains(q)) &&
        !c.district.toLowerCase().contains(q)) {
      return false;
    }
    if (filters.specialty != null && !c.specialties.contains(filters.specialty)) {
      return false;
    }
    if (filters.district != null && c.district != filters.district) {
      return false;
    }
    if (c.rating < filters.minRating) return false;
    return true;
  }).toList();

  List<ClinicWithPrice> withPrices(List<Clinic> clinics) => clinics
      .map((c) {
        final ts = repo.treatmentsForClinic(c.id);
        final min = ts.isEmpty ? 0 : ts.map((t) => t.price).reduce((a, b) => a < b ? a : b);
        return ClinicWithPrice(clinic: c, priceFrom: min);
      })
      .toList(growable: false);

  switch (filters.sort) {
    case DiscoverySort.ratingDesc:
      list.sort((a, b) => b.rating.compareTo(a.rating));
      break;
    case DiscoverySort.priceAsc:
      list.sort((a, b) {
        final pa = repo.treatmentsForClinic(a.id).map((t) => t.price).fold(1 << 30, (x, y) => x < y ? x : y);
        final pb = repo.treatmentsForClinic(b.id).map((t) => t.price).fold(1 << 30, (x, y) => x < y ? x : y);
        return pa.compareTo(pb);
      });
      break;
    case DiscoverySort.priceDesc:
      list.sort((a, b) {
        final pa = repo.treatmentsForClinic(a.id).map((t) => t.price).fold(0, (x, y) => x > y ? x : y);
        final pb = repo.treatmentsForClinic(b.id).map((t) => t.price).fold(0, (x, y) => x > y ? x : y);
        return pb.compareTo(pa);
      });
      break;
    case DiscoverySort.recommended:
      list.sort((a, b) {
        final scoreA = a.rating * 100 + a.reviewCount / 20;
        final scoreB = b.rating * 100 + b.reviewCount / 20;
        return scoreB.compareTo(scoreA);
      });
      break;
  }

  return withPrices(list);
});

/// Distinct filter facet values, derived once from the repository.
final specialtiesProvider = FutureProvider.autoDispose<List<String>>((ref) async {
  final repo = await ref.watch(mockRepositoryProvider.future);
  final set = <String>{};
  for (final c in repo.clinics) {
    set.addAll(c.specialties);
  }
  final l = set.toList()..sort();
  return l;
});

final districtsProvider = FutureProvider.autoDispose<List<String>>((ref) async {
  final repo = await ref.watch(mockRepositoryProvider.future);
  final set = <String>{};
  for (final c in repo.clinics) {
    set.add(c.district);
  }
  final l = set.toList()..sort();
  return l;
});

// ---------------------------------------------------------------------------
// Bookings
// ---------------------------------------------------------------------------

/// Manages the user's mock appointments in memory.
class BookingsNotifier extends StateNotifier<List<Appointment>> {
  BookingsNotifier() : super(_seedBookings());

  static List<Appointment> _seedBookings() {
    final now = DateTime.now();
    return [
      Appointment(
        id: 'seed-1',
        clinicId: 'c1',
        clinicName: 'Lumière Aesthetics',
        treatmentId: 'c1-t3',
        treatmentName: 'Lumière Signature Facial',
        practitionerName: 'Nadia Rahman',
        start: now.add(const Duration(days: 3)),
        durationMinutes: 60,
        price: 220,
        status: BookingStatus.upcoming,
        bookedAt: now.subtract(const Duration(days: 2)),
      ),
      Appointment(
        id: 'seed-2',
        clinicId: 'c3',
        clinicName: 'Maison Glow',
        treatmentId: 'c3-t2',
        treatmentName: 'Marina Radiance Laser Toning',
        practitionerName: 'Dr. Ren Kobayashi',
        start: now.add(const Duration(days: 10, hours: 2)),
        durationMinutes: 30,
        price: 280,
        status: BookingStatus.upcoming,
        bookedAt: now.subtract(const Duration(days: 1)),
      ),
      Appointment(
        id: 'seed-3',
        clinicId: 'c2',
        clinicName: 'Sage & Skin Clinic',
        treatmentId: 'c2-t3',
        treatmentName: 'Calming Acne Facial',
        practitionerName: 'Dr. Aisyah Karim',
        start: now.subtract(const Duration(days: 21)),
        durationMinutes: 50,
        price: 160,
        status: BookingStatus.completed,
        bookedAt: now.subtract(const Duration(days: 35)),
      ),
      Appointment(
        id: 'seed-4',
        clinicId: 'c4',
        clinicName: 'The Blush Room',
        treatmentId: 'c4-t1',
        treatmentName: 'Baby Botox® Micro-Toxin',
        practitionerName: 'Dr. Sarah Oh',
        start: now.subtract(const Duration(days: 60)),
        durationMinutes: 20,
        price: 320,
        status: BookingStatus.completed,
        bookedAt: now.subtract(const Duration(days: 70)),
      ),
    ];
  }

  /// Adds a new appointment and returns its id.
  String add({
    required String clinicId,
    required String clinicName,
    required String treatmentId,
    required String treatmentName,
    required String practitionerName,
    required DateTime start,
    required int durationMinutes,
    required int price,
  }) {
    final id = 'bk-${DateTime.now().microsecondsSinceEpoch}';
    final appt = Appointment(
      id: id,
      clinicId: clinicId,
      clinicName: clinicName,
      treatmentId: treatmentId,
      treatmentName: treatmentName,
      practitionerName: practitionerName,
      start: start,
      durationMinutes: durationMinutes,
      price: price,
      status: BookingStatus.upcoming,
      bookedAt: DateTime.now(),
    );
    state = [...state, appt];
    return id;
  }

  void cancel(String id) {
    state = [
      for (final a in state)
        if (a.id == id)
          a.copyWith(status: BookingStatus.cancelled)
        else
          a,
    ];
  }
}

final bookingsProvider =
    StateNotifierProvider<BookingsNotifier, List<Appointment>>((ref) {
  return BookingsNotifier();
});

/// Upcoming (not cancelled, in the future) appointments, soonest first.
final upcomingBookingsProvider = Provider<List<Appointment>>((ref) {
  final now = DateTime.now();
  final list = ref
      .watch(bookingsProvider)
      .where((a) => a.status == BookingStatus.upcoming && a.start.isAfter(now))
      .toList()
    ..sort((a, b) => a.start.compareTo(b.start));
  return list;
});

/// Past appointments (completed or cancelled), most recent first.
final pastBookingsProvider = Provider<List<Appointment>>((ref) {
  final now = DateTime.now();
  final list = ref
      .watch(bookingsProvider)
      .where((a) =>
          a.status == BookingStatus.completed ||
          a.status == BookingStatus.cancelled ||
          (a.status == BookingStatus.upcoming && !a.start.isAfter(now)))
      .toList()
    ..sort((a, b) => b.start.compareTo(a.start));
  return list;
});
