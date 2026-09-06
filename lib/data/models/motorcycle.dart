import 'package:equatable/equatable.dart';

/// Engine cooling / transmission types offered at job intake.
const List<String> kEngineTypes = ['Oil Cooled', 'Liquid Cooled', 'CVT'];

/// A motorcycle belonging to a service [Job].
class Motorcycle extends Equatable {
  const Motorcycle({
    required this.make,
    required this.model,
    required this.registration,
    required this.odometer,
    this.year,
    this.color,
    this.engineType,
  });

  final String make;
  final String model;
  final String registration;
  final int odometer;
  final int? year;
  final String? color;

  /// Cooling / transmission type — one of [kEngineTypes] (Oil Cooled,
  /// Liquid Cooled, CVT). Optional.
  final String? engineType;

  String get displayName => '$make $model';

  Motorcycle copyWith({
    String? make,
    String? model,
    String? registration,
    int? odometer,
    int? year,
    String? color,
    String? engineType,
  }) {
    return Motorcycle(
      make: make ?? this.make,
      model: model ?? this.model,
      registration: registration ?? this.registration,
      odometer: odometer ?? this.odometer,
      year: year ?? this.year,
      color: color ?? this.color,
      engineType: engineType ?? this.engineType,
    );
  }

  @override
  List<Object?> get props =>
      [make, model, registration, odometer, year, color, engineType];
}
