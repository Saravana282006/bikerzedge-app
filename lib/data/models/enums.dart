import 'package:flutter/material.dart';

/// User roles in MotoTrack. Access is enforced in the UI (and, in production,
/// on the backend via Firebase custom claims + security rules).
enum UserRole {
  admin,
  mechanic;

  String get label => switch (this) {
        UserRole.admin => 'Admin',
        UserRole.mechanic => 'Mechanic',
      };
}

/// Job status workflow (PRD §8).
///
/// Received → Inspection → Assigned → Diagnosis → Waiting for Parts →
/// Repair Started → Repair Completed → Testing → Ready for Delivery → Closed
///
/// Notes:
///  - 'Waiting for Parts' may loop back to 'Repair Started' once parts arrive.
///  - Only an Admin may move a job to 'Closed'.
enum JobStatus {
  received,
  inspection,
  assigned,
  diagnosis,
  waitingForParts,
  repairStarted,
  repairCompleted,
  testing,
  readyForDelivery,
  closed;

  String get label => switch (this) {
        JobStatus.received => 'Received',
        JobStatus.inspection => 'Inspection',
        JobStatus.assigned => 'Assigned',
        JobStatus.diagnosis => 'Diagnosis',
        JobStatus.waitingForParts => 'Waiting for Parts',
        JobStatus.repairStarted => 'Repair Started',
        JobStatus.repairCompleted => 'Repair Completed',
        JobStatus.testing => 'Testing',
        JobStatus.readyForDelivery => 'Ready for Delivery',
        JobStatus.closed => 'Closed',
      };

  /// Ordered position in the workflow, used for progress indicators.
  int get step => index;

  /// Whether this status counts as "open work" (not yet closed).
  bool get isOpen => this != JobStatus.closed;

  /// Whether this status counts as active repair work in progress.
  bool get isActive =>
      this == JobStatus.diagnosis ||
      this == JobStatus.waitingForParts ||
      this == JobStatus.repairStarted ||
      this == JobStatus.testing;

  /// A colour used consistently for chips and stats across the app.
  Color get color => switch (this) {
        JobStatus.received => const Color(0xFF64748B),
        JobStatus.inspection => const Color(0xFF0EA5E9),
        JobStatus.assigned => const Color(0xFF6366F1),
        JobStatus.diagnosis => const Color(0xFF8B5CF6),
        JobStatus.waitingForParts => const Color(0xFFF59E0B),
        JobStatus.repairStarted => const Color(0xFFF97316),
        JobStatus.repairCompleted => const Color(0xFF14B8A6),
        JobStatus.testing => const Color(0xFF06B6D4),
        JobStatus.readyForDelivery => const Color(0xFF22C55E),
        JobStatus.closed => const Color(0xFF16A34A),
      };

  IconData get icon => switch (this) {
        JobStatus.received => Icons.inbox_outlined,
        JobStatus.inspection => Icons.checklist_outlined,
        JobStatus.assigned => Icons.person_add_alt_1_outlined,
        JobStatus.diagnosis => Icons.medical_services_outlined,
        JobStatus.waitingForParts => Icons.pending_actions_outlined,
        JobStatus.repairStarted => Icons.build_outlined,
        JobStatus.repairCompleted => Icons.task_alt_outlined,
        JobStatus.testing => Icons.speed_outlined,
        JobStatus.readyForDelivery => Icons.local_shipping_outlined,
        JobStatus.closed => Icons.check_circle_outline,
      };

  /// Valid next statuses a user can advance to from here (excludes 'closed',
  /// which is admin-only and handled separately).
  List<JobStatus> get nextOptions {
    switch (this) {
      case JobStatus.received:
        return [JobStatus.inspection];
      case JobStatus.inspection:
        return [JobStatus.assigned];
      case JobStatus.assigned:
        return [JobStatus.diagnosis];
      case JobStatus.diagnosis:
        return [JobStatus.waitingForParts, JobStatus.repairStarted];
      case JobStatus.waitingForParts:
        return [JobStatus.repairStarted];
      case JobStatus.repairStarted:
        return [JobStatus.repairCompleted, JobStatus.waitingForParts];
      case JobStatus.repairCompleted:
        return [JobStatus.testing];
      case JobStatus.testing:
        return [JobStatus.readyForDelivery, JobStatus.repairStarted];
      case JobStatus.readyForDelivery:
        return []; // Only Admin closes — handled via a dedicated action.
      case JobStatus.closed:
        return [];
    }
  }
}
