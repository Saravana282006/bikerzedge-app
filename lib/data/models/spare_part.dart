import 'package:equatable/equatable.dart';

/// A spare part logged against a job (PRD §6, §10).
class SparePart extends Equatable {
  const SparePart({
    required this.id,
    required this.name,
    required this.quantity,
    this.unitCost,
  });

  final String id;
  final String name;
  final int quantity;
  final double? unitCost;

  double get lineTotal => (unitCost ?? 0) * quantity;

  SparePart copyWith({
    String? id,
    String? name,
    int? quantity,
    double? unitCost,
  }) {
    return SparePart(
      id: id ?? this.id,
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      unitCost: unitCost ?? this.unitCost,
    );
  }

  @override
  List<Object?> get props => [id, name, quantity, unitCost];
}
