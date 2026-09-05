import 'package:equatable/equatable.dart';

/// A motorcycle belonging to a service [Job].
class Motorcycle extends Equatable {
  const Motorcycle({
    required this.make,
    required this.model,
    required this.registration,
    required this.odometer,
    this.year,
    this.color,
  });

  final String make;
  final String model;
  final String registration;
  final int odometer;
  final int? year;
  final String? color;

  String get displayName => '$make $model';

  Motorcycle copyWith({
    String? make,
    String? model,
    String? registration,
    int? odometer,
    int? year,
    String? color,
  }) {
    return Motorcycle(
      make: make ?? this.make,
      model: model ?? this.model,
      registration: registration ?? this.registration,
      odometer: odometer ?? this.odometer,
      year: year ?? this.year,
      color: color ?? this.color,
    );
  }

  @override
  List<Object?> get props => [make, model, registration, odometer, year, color];
}
