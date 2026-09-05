import 'package:equatable/equatable.dart';

import 'enums.dart';

enum TimelineEventType {
  created,
  statusChange,
  note,
  photo,
  part,
  assignment;

  String get label => switch (this) {
        TimelineEventType.created => 'Job created',
        TimelineEventType.statusChange => 'Status changed',
        TimelineEventType.note => 'Note added',
        TimelineEventType.photo => 'Photo added',
        TimelineEventType.part => 'Part logged',
        TimelineEventType.assignment => 'Assignment',
      };
}

/// A chronological, timestamped entry in a job's history (PRD §6, §10).
class TimelineEvent extends Equatable {
  const TimelineEvent({
    required this.id,
    required this.type,
    required this.byUser,
    required this.at,
    this.note,
    this.fromStatus,
    this.toStatus,
  });

  final String id;
  final TimelineEventType type;
  final String byUser;
  final DateTime at;
  final String? note;
  final JobStatus? fromStatus;
  final JobStatus? toStatus;

  @override
  List<Object?> get props => [id, type, byUser, at, note, fromStatus, toStatus];
}
