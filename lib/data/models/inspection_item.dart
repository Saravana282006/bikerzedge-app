import 'package:equatable/equatable.dart';

/// A single line in the intake inspection checklist (PRD §6).
class InspectionItem extends Equatable {
  const InspectionItem({
    required this.id,
    required this.label,
    this.checked = false,
    this.remark,
  });

  final String id;
  final String label;
  final bool checked;
  final String? remark;

  InspectionItem copyWith({
    String? id,
    String? label,
    bool? checked,
    String? remark,
  }) {
    return InspectionItem(
      id: id ?? this.id,
      label: label ?? this.label,
      checked: checked ?? this.checked,
      remark: remark ?? this.remark,
    );
  }

  @override
  List<Object?> get props => [id, label, checked, remark];
}

/// The default checklist applied to a new job at intake.
const List<String> kDefaultInspectionLabels = [
  'Fuel level noted',
  'Body / fairing condition',
  'Scratches / dents recorded',
  'Tyre condition (front & rear)',
  'Brake pads & discs',
  'Lights & indicators working',
  'Horn working',
  'Chain & sprocket',
  'Battery condition',
  'Documents present',
  'Personal items removed',
];
