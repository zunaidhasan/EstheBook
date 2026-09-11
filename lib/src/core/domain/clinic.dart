import 'package:flutter/foundation.dart';

@immutable
class Clinic {
  const Clinic({
    required this.id,
    required this.name,
    required this.tagline,
    required this.description,
    required this.specialties,
    required this.amenities,
    required this.city,
    required this.district,
    required this.rating,
    required this.reviewCount,
    required this.priceLevel,
    required this.openHour,
    required this.closeHour,
    required this.gradSeed,
    required this.practitioners,
    required this.treatmentIds,
  });

  final String id;
  final String name;
  final String tagline;
  final String description;
  final List<String> specialties;
  final List<String> amenities;
  final String city;
  final String district;
  final double rating;
  final int reviewCount;
  final int priceLevel; // 1..3 ($, $$, $$$)
  final int openHour;
  final int closeHour;
  final int gradSeed;
  final List<Practitioner> practitioners;
  final List<String> treatmentIds;

  bool get isOpenNow => DateTime.now().hour >= openHour && DateTime.now().hour < closeHour;

  String get priceLabel => '\$' * priceLevel.clamp(1, 3);

  factory Clinic.fromJson(Map<String, dynamic> json) {
    return Clinic(
      id: json['id'] as String,
      name: json['name'] as String,
      tagline: json['tagline'] as String,
      description: json['description'] as String,
      specialties: (json['specialties'] as List<dynamic>).cast<String>(),
      amenities: (json['amenities'] as List<dynamic>).cast<String>(),
      city: json['city'] as String,
      district: json['district'] as String,
      rating: (json['rating'] as num).toDouble(),
      reviewCount: json['reviewCount'] as int,
      priceLevel: json['priceLevel'] as int,
      openHour: json['openHour'] as int,
      closeHour: json['closeHour'] as int,
      gradSeed: json['gradSeed'] as int,
      practitioners: (json['practitioners'] as List<dynamic>)
          .map((e) => Practitioner.fromJson(e as Map<String, dynamic>))
          .toList(),
      treatmentIds: (json['treatmentIds'] as List<dynamic>).cast<String>(),
    );
  }
}

@immutable
class Practitioner {
  const Practitioner({
    required this.name,
    required this.title,
    required this.yearsExperience,
    required this.specialty,
  });

  final String name;
  final String title;
  final int yearsExperience;
  final String specialty;

  factory Practitioner.fromJson(Map<String, dynamic> json) {
    return Practitioner(
      name: json['name'] as String,
      title: json['title'] as String,
      yearsExperience: json['yearsExperience'] as int,
      specialty: json['specialty'] as String,
    );
  }
}
