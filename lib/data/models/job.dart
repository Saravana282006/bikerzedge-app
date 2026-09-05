import 'package:equatable/equatable.dart';

import 'enums.dart';
import 'inspection_item.dart';
import 'motorcycle.dart';
import 'photo.dart';
import 'spare_part.dart';
import 'timeline_event.dart';

/// A service job — the central entity in MotoTrack (PRD §10).
class Job extends Equatable {
  const Job({
    required this.id,
    required this.code,
    required this.ownerName,
    required this.contact,
    required this.motorcycle,
    required this.serviceRequest,
    required this.status,
    required this.createdAt,
    this.assignedToId,
    this.closedAt,
    this.priority = false,
    this.diagnosis,
    this.inspection = const [],
    this.parts = const [],
    this.photos = const [],
    this.timeline = const [],
    this.notes = const [],
  });

  final String id;

  /// Short human-friendly code, e.g. "MT-1042", shown on cards.
  final String code;
  final String ownerName;
  final String contact;
  final Motorcycle motorcycle;
  final String serviceRequest;
  final JobStatus status;
  final DateTime createdAt;
  final String? assignedToId;
  final DateTime? closedAt;
  final bool priority;
  final String? diagnosis;
  final List<InspectionItem> inspection;
  final List<SparePart> parts;
  final List<JobPhoto> photos;
  final List<TimelineEvent> timeline;
  final List<String> notes;

  bool get isAssigned => assignedToId != null;
  bool get isClosed => status == JobStatus.closed;

  /// Total logged parts cost (0 when costs weren't recorded).
  double get partsTotal =>
      parts.fold(0, (sum, p) => sum + p.lineTotal);

  int get partsCount => parts.fold(0, (sum, p) => sum + p.quantity);

  int get inspectionDone => inspection.where((i) => i.checked).length;

  int get pendingPhotoUploads =>
      photos.where((p) => p.pendingUpload).length;

  Job copyWith({
    String? id,
    String? code,
    String? ownerName,
    String? contact,
    Motorcycle? motorcycle,
    String? serviceRequest,
    JobStatus? status,
    DateTime? createdAt,
    String? assignedToId,
    bool clearAssignee = false,
    DateTime? closedAt,
    bool clearClosedAt = false,
    bool? priority,
    String? diagnosis,
    List<InspectionItem>? inspection,
    List<SparePart>? parts,
    List<JobPhoto>? photos,
    List<TimelineEvent>? timeline,
    List<String>? notes,
  }) {
    return Job(
      id: id ?? this.id,
      code: code ?? this.code,
      ownerName: ownerName ?? this.ownerName,
      contact: contact ?? this.contact,
      motorcycle: motorcycle ?? this.motorcycle,
      serviceRequest: serviceRequest ?? this.serviceRequest,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      assignedToId:
          clearAssignee ? null : (assignedToId ?? this.assignedToId),
      closedAt: clearClosedAt ? null : (closedAt ?? this.closedAt),
      priority: priority ?? this.priority,
      diagnosis: diagnosis ?? this.diagnosis,
      inspection: inspection ?? this.inspection,
      parts: parts ?? this.parts,
      photos: photos ?? this.photos,
      timeline: timeline ?? this.timeline,
      notes: notes ?? this.notes,
    );
  }

  @override
  List<Object?> get props => [
        id,
        code,
        ownerName,
        contact,
        motorcycle,
        serviceRequest,
        status,
        createdAt,
        assignedToId,
        closedAt,
        priority,
        diagnosis,
        inspection,
        parts,
        photos,
        timeline,
        notes,
      ];
}
