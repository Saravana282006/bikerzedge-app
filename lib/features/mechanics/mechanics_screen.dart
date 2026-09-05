import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/jobs/jobs_bloc.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/user.dart';
import '../../data/repositories/job_repository.dart';
import '../../widgets/common.dart';
import '../../widgets/user_avatar.dart';
import '../shell/app_shell.dart';

/// Admin view of the workshop's mechanics and their current workload.
class MechanicsScreen extends StatelessWidget {
  const MechanicsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.read<AuthBloc>().state.user!;
    final repo = context.read<JobRepository>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mechanics'),
        actions: [NotificationAction(user: user), const SizedBox(width: 4)],
      ),
      body: BlocBuilder<JobsBloc, JobsState>(
        builder: (context, state) {
          final mechanics = repo.mechanics;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const SectionHeader('Team'),
              for (final m in mechanics) ...[
                _MechanicCard(
                  mechanic: m,
                  open: state.jobs
                      .where((j) =>
                          j.assignedToId == m.id && j.status.isOpen)
                      .length,
                  active: state.jobs
                      .where((j) =>
                          j.assignedToId == m.id && j.status.isActive)
                      .length,
                ),
                const SizedBox(height: 10),
              ],
              const SizedBox(height: 8),
              const Text(
                'Mechanic accounts are created and managed by an admin '
                '(PRD §5). Self sign-up is intentionally not available.',
                style: TextStyle(
                  fontSize: 12.5,
                  color: AppColors.slate500,
                  height: 1.5,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _MechanicCard extends StatelessWidget {
  const _MechanicCard({
    required this.mechanic,
    required this.open,
    required this.active,
  });

  final AppUser mechanic;
  final int open;
  final int active;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            UserAvatar(user: mechanic, size: 46),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(mechanic.name,
                          style: const TextStyle(
                              fontWeight: FontWeight.w700, fontSize: 15)),
                      const SizedBox(width: 8),
                      if (!mechanic.active)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.slate100,
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: const Text('Inactive',
                              style: TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.slate500)),
                        ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(mechanic.email,
                      style: const TextStyle(
                          color: AppColors.slate500, fontSize: 12.5)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _pill('$open open', AppColors.brandOrange),
                      const SizedBox(width: 8),
                      _pill('$active active', AppColors.info),
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              tooltip: 'View jobs',
              onPressed: () {
                context.read<JobsBloc>()
                  ..add(const JobsFiltersCleared())
                  ..add(JobsMechanicFilterChanged(mechanic.id));
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Filtered Jobs by ${mechanic.name}.'),
                  ),
                );
              },
              icon: const Icon(Icons.filter_list),
            ),
          ],
        ),
      ),
    );
  }

  Widget _pill(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(7),
      ),
      child: Text(text,
          style: TextStyle(
              color: color, fontWeight: FontWeight.w700, fontSize: 11.5)),
    );
  }
}
