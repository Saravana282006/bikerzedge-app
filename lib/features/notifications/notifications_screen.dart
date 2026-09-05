import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/notifications/notifications_bloc.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../data/models/user.dart';
import '../../widgets/common.dart';
import '../jobs/job_detail_screen.dart';

/// In-app internal notifications (PRD §6). Push (FCM) is a future phase.
class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key, required this.user});

  final AppUser user;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          BlocBuilder<NotificationsBloc, NotificationsState>(
            builder: (context, state) {
              if (state.unreadCount == 0) return const SizedBox.shrink();
              return TextButton(
                onPressed: () => context
                    .read<NotificationsBloc>()
                    .add(const NotificationsAllRead()),
                child: const Text('Mark all read'),
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<NotificationsBloc, NotificationsState>(
        builder: (context, state) {
          if (state.loading && state.items.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.items.isEmpty) {
            return const EmptyState(
              icon: Icons.notifications_none,
              title: 'No notifications',
              message: 'Assignments and status changes show up here.',
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: state.items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, i) {
              final n = state.items[i];
              return Card(
                child: ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: n.read
                          ? AppColors.slate100
                          : AppColors.brandOrange.withValues(alpha: 0.14),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.notifications_outlined,
                      size: 20,
                      color:
                          n.read ? AppColors.slate500 : AppColors.brandOrangeDark,
                    ),
                  ),
                  title: Text(
                    n.message,
                    style: TextStyle(
                      fontSize: 13.5,
                      height: 1.4,
                      fontWeight: n.read ? FontWeight.w500 : FontWeight.w700,
                      color: AppColors.ink,
                    ),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(Formatters.relative(n.createdAt),
                        style: const TextStyle(
                            fontSize: 12, color: AppColors.slate500)),
                  ),
                  trailing: n.read
                      ? null
                      : const Icon(Icons.circle,
                          size: 10, color: AppColors.brandOrange),
                  onTap: () {
                    context
                        .read<NotificationsBloc>()
                        .add(NotificationRead(n.id));
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => JobDetailScreen(jobId: n.jobId),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
