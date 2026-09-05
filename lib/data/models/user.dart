import 'package:equatable/equatable.dart';

import 'enums.dart';

/// A workshop staff member — either an Admin (shop owner) or a Mechanic.
class AppUser extends Equatable {
  const AppUser({
    required this.id,
    required this.name,
    required this.role,
    required this.email,
    this.active = true,
    this.phone,
  });

  final String id;
  final String name;
  final UserRole role;
  final String email;
  final bool active;
  final String? phone;

  bool get isAdmin => role == UserRole.admin;
  bool get isMechanic => role == UserRole.mechanic;

  /// Initials for avatars, e.g. "Ravi Kumar" -> "RK".
  String get initials {
    final parts =
        name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1))
        .toUpperCase();
  }

  AppUser copyWith({
    String? id,
    String? name,
    UserRole? role,
    String? email,
    bool? active,
    String? phone,
  }) {
    return AppUser(
      id: id ?? this.id,
      name: name ?? this.name,
      role: role ?? this.role,
      email: email ?? this.email,
      active: active ?? this.active,
      phone: phone ?? this.phone,
    );
  }

  @override
  List<Object?> get props => [id, name, role, email, active, phone];
}
