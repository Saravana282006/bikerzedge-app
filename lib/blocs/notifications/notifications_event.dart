part of 'notifications_bloc.dart';

sealed class NotificationsEvent extends Equatable {
  const NotificationsEvent();
  @override
  List<Object?> get props => [];
}

class NotificationsLoaded extends NotificationsEvent {
  const NotificationsLoaded(this.userId);
  final String userId;
  @override
  List<Object?> get props => [userId];
}

class NotificationRead extends NotificationsEvent {
  const NotificationRead(this.notificationId);
  final String notificationId;
  @override
  List<Object?> get props => [notificationId];
}

class NotificationsAllRead extends NotificationsEvent {
  const NotificationsAllRead();
}
