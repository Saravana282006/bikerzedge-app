import 'package:equatable/equatable.dart';

/// Stage a photo was captured at, used to label the gallery.
enum PhotoStage {
  inspection,
  diagnosis,
  repair,
  delivery;

  String get label => switch (this) {
        PhotoStage.inspection => 'Inspection',
        PhotoStage.diagnosis => 'Diagnosis',
        PhotoStage.repair => 'Repair',
        PhotoStage.delivery => 'Delivery',
      };
}

/// A photo attached to a job.
///
/// In this prototype there are no real image files — [seedColor] and [caption]
/// drive a placeholder tile. In production this maps to a Firebase Cloud
/// Storage URL with queued/offline upload (PRD §11 media handling).
class JobPhoto extends Equatable {
  const JobPhoto({
    required this.id,
    required this.caption,
    required this.uploadedBy,
    required this.uploadedAt,
    required this.stage,
    this.seedColor = 0xFF334155,
    this.pendingUpload = false,
  });

  final String id;
  final String caption;
  final String uploadedBy;
  final DateTime uploadedAt;
  final PhotoStage stage;
  final int seedColor;

  /// True when captured offline and still queued to sync (PRD US-04).
  final bool pendingUpload;

  JobPhoto copyWith({
    String? id,
    String? caption,
    String? uploadedBy,
    DateTime? uploadedAt,
    PhotoStage? stage,
    int? seedColor,
    bool? pendingUpload,
  }) {
    return JobPhoto(
      id: id ?? this.id,
      caption: caption ?? this.caption,
      uploadedBy: uploadedBy ?? this.uploadedBy,
      uploadedAt: uploadedAt ?? this.uploadedAt,
      stage: stage ?? this.stage,
      seedColor: seedColor ?? this.seedColor,
      pendingUpload: pendingUpload ?? this.pendingUpload,
    );
  }

  @override
  List<Object?> get props =>
      [id, caption, uploadedBy, uploadedAt, stage, seedColor, pendingUpload];
}
