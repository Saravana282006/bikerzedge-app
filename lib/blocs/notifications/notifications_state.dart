part of 'notifications_bloc.dart';

class NotificationsState extends Equatable {
  const NotificationsState({
    this.items = const [],
    this.userId,
    this.loading = false,
  });

  final List<AppNotification> items;
  final String? userId;
  final bool loading;

  int get unreadCount => items.where((n) => !n.read).length;

  NotificationsState copyWith({
    List<AppNotification>? items,
    String? userId,
    bool? loading,
  }) {
    return NotificationsState(
      items: items ?? this.items,
      userId: userId ?? this.userId,
      loading: loading ?? this.loading,
    );
  }

  @override
  List<Object?> get props => [items, userId, loading];
}
