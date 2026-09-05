import 'package:equatable/equatable.dart';

/// An in-app internal notification (PRD §6). Push (FCM) is a future enhancement.
class AppNotification extends Equatable {
  const AppNotification({
    required this.id,
    required this.toUserId,
    required this.message,
    required this.jobId,
    required this.createdAt,
    this.read = false,
  });

  final String id;
  final String toUserId;
  final String message;
  final String jobId;
  final DateTime createdAt;
  final bool read;

  AppNotification copyWith({
    String? id,
    String? toUserId,
    String? message,
    String? jobId,
    DateTime? createdAt,
    bool? read,
  }) {
    return AppNotification(
      id: id ?? this.id,
      toUserId: toUserId ?? this.toUserId,
      message: message ?? this.message,
      jobId: jobId ?? this.jobId,
      createdAt: createdAt ?? this.createdAt,
      read: read ?? this.read,
    );
  }

  @override
  List<Object?> get props =>
      [id, toUserId, message, jobId, createdAt, read];
}
