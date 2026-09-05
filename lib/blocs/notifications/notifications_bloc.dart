import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/app_notification.dart';
import '../../data/repositories/job_repository.dart';

part 'notifications_event.dart';
part 'notifications_state.dart';

class NotificationsBloc
    extends Bloc<NotificationsEvent, NotificationsState> {
  NotificationsBloc(this._repository) : super(const NotificationsState()) {
    on<NotificationsLoaded>(_onLoaded);
    on<NotificationRead>(_onRead);
    on<NotificationsAllRead>(_onAllRead);
  }

  final JobRepository _repository;

  Future<void> _onLoaded(
    NotificationsLoaded event,
    Emitter<NotificationsState> emit,
  ) async {
    emit(state.copyWith(userId: event.userId, loading: true));
    final items = await _repository.fetchNotifications(event.userId);
    emit(state.copyWith(items: items, loading: false));
  }

  Future<void> _onRead(
    NotificationRead event,
    Emitter<NotificationsState> emit,
  ) async {
    await _repository.markNotificationRead(event.notificationId);
    if (state.userId != null) {
      final items = await _repository.fetchNotifications(state.userId!);
      emit(state.copyWith(items: items));
    }
  }

  Future<void> _onAllRead(
    NotificationsAllRead event,
    Emitter<NotificationsState> emit,
  ) async {
    if (state.userId == null) return;
    await _repository.markAllNotificationsRead(state.userId!);
    final items = await _repository.fetchNotifications(state.userId!);
    emit(state.copyWith(items: items));
  }
}
