import 'package:flutter/foundation.dart';

/// Status of a booked appointment in the user dashboard.
enum BookingStatus { upcoming, completed, cancelled }

BookingStatus bookingStatusFromString(String value) {
  switch (value) {
    case 'upcoming':
      return BookingStatus.upcoming;
    case 'completed':
      return BookingStatus.completed;
    case 'cancelled':
      return BookingStatus.cancelled;
    default:
      return BookingStatus.upcoming;
  }
}

@immutable
class Appointment {
  const Appointment({
    required this.id,
    required this.clinicId,
    required this.clinicName,
    required this.treatmentId,
    required this.treatmentName,
    required this.practitionerName,
    required this.start,
    required this.durationMinutes,
    required this.price,
    required this.status,
    required this.bookedAt,
    this.notes,
  });

  final String id;
  final String clinicId;
  final String clinicName;
  final String treatmentId;
  final String treatmentName;
  final String practitionerName;
  final DateTime start;
  final int durationMinutes;
  final int price;
  final BookingStatus status;
  final DateTime bookedAt;
  final String? notes;

  DateTime get end => start.add(Duration(minutes: durationMinutes));

  Appointment copyWith({
    String? id,
    String? clinicId,
    String? clinicName,
    String? treatmentId,
    String? treatmentName,
    String? practitionerName,
    DateTime? start,
    int? durationMinutes,
    int? price,
    BookingStatus? status,
    DateTime? bookedAt,
    String? notes,
  }) {
    return Appointment(
      id: id ?? this.id,
      clinicId: clinicId ?? this.clinicId,
      clinicName: clinicName ?? this.clinicName,
      treatmentId: treatmentId ?? this.treatmentId,
      treatmentName: treatmentName ?? this.treatmentName,
      practitionerName: practitionerName ?? this.practitionerName,
      start: start ?? this.start,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      price: price ?? this.price,
      status: status ?? this.status,
      bookedAt: bookedAt ?? this.bookedAt,
      notes: notes ?? this.notes,
    );
  }
}
