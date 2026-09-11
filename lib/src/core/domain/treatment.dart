import 'package:flutter/foundation.dart';

/// How far along a treatment plan the client is.
enum Downtime { none, low, medium, high }

Downtime downtimeFromString(String value) {
  switch (value) {
    case 'none':
      return Downtime.none;
    case 'low':
      return Downtime.low;
    case 'medium':
      return Downtime.medium;
    case 'high':
      return Downtime.high;
    default:
      return Downtime.none;
  }
}

@immutable
class Treatment {
  const Treatment({
    required this.id,
    required this.clinicId,
    required this.name,
    required this.category,
    required this.summary,
    required this.benefits,
    required this.durationMinutes,
    required this.price,
    required this.downtime,
    required this.popularity,
    required this.gradSeed,
  });

  final String id;
  final String clinicId;
  final String name;
  final String category;
  final String summary;
  final List<String> benefits;
  final int durationMinutes;
  final int price;
  final Downtime downtime;
  final double popularity; // 0..1 — used for "popular" badges and sorting.
  final int gradSeed;

  String get downtimeLabel {
    switch (downtime) {
      case Downtime.none:
        return 'No downtime';
      case Downtime.low:
        return 'Low downtime';
      case Downtime.medium:
        return 'Moderate downtime';
      case Downtime.high:
        return 'Extended downtime';
    }
  }

  factory Treatment.fromJson(Map<String, dynamic> json) {
    return Treatment(
      id: json['id'] as String,
      clinicId: json['clinicId'] as String,
      name: json['name'] as String,
      category: json['category'] as String,
      summary: json['summary'] as String,
      benefits: (json['benefits'] as List<dynamic>).cast<String>(),
      durationMinutes: json['durationMinutes'] as int,
      price: json['price'] as int,
      downtime: downtimeFromString(json['downtime'] as String),
      popularity: (json['popularity'] as num).toDouble(),
      gradSeed: json['gradSeed'] as int,
    );
  }
}
