import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/jobs/jobs_bloc.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/enums.dart';
import '../../data/models/job.dart';
import '../../widgets/common.dart';
import '../../widgets/job_card.dart';
import '../../widgets/stat_card.dart';
import '../jobs/job_detail_screen.dart';
import '../shell/app_shell.dart';

class MechanicDashboardScreen extends StatelessWidget {
  const MechanicDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.read<AuthBloc>().state.user!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Workspace'),
        actions: [NotificationAction(user: user), const SizedBox(width: 4)],
      ),
      body: BlocBuilder<JobsBloc, JobsState>(
        builder: (context, state) {
          if (state.status == JobsStatus.loading ||
              state.status == JobsStatus.initial) {
            return const Center(child: CircularProgressIndicator());
          }
          final mine =
              state.jobs.where((j) => j.assignedToId == user.id).toList();
          final active = mine.where((j) => j.status.isActive).toList();
          final open = mine.where((j) => j.status.isOpen).length;
          final waiting =
              mine.where((j) => j.status == JobStatus.waitingForParts).length;
          final ready = mine
              .where((j) => j.status == JobStatus.readyForDelivery)
              .length;

          return RefreshIndicator(
            onRefresh: () async =>
                context.read<JobsBloc>().add(const JobsRefreshed()),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(
                  'Hi, ${user.name.split(' ').first} 🔧',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'You have $open open ${open == 1 ? 'job' : 'jobs'} assigned.',
                  style:
                      const TextStyle(fontSize: 14, color: AppColors.slate500),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: StatCard(
                        label: 'Open jobs',
                        value: '$open',
                        icon: Icons.build_circle_outlined,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: StatCard(
                        label: 'Waiting parts',
                        value: '$waiting',
                        icon: Icons.pending_actions_outlined,
                        color: AppColors.warning,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: StatCard(
                        label: 'Ready',
                        value: '$ready',
                        icon: Icons.local_shipping_outlined,
                        color: AppColors.success,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 22),
                const SectionHeader('Active jobs'),
                if (active.isEmpty)
                  const PanelCard(
                    child: EmptyState(
                      icon: Icons.check_circle_outline,
                      title: 'Nothing in progress',
                      message: 'Jobs you start working on show up here.',
                    ),
                  )
                else
                  for (final j in active)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: JobCard(
                        job: j,
                        assigneeName: user.name,
                        onTap: () => _openJob(context, j),
                      ),
                    ),
                const SizedBox(height: 22),
                const SectionHeader('All my jobs'),
                if (mine.isEmpty)
                  const PanelCard(
                    child: EmptyState(
                      icon: Icons.inbox_outlined,
                      title: 'No jobs assigned yet',
                      message: 'An admin will assign jobs to you.',
                    ),
                  )
                else
                  for (final j in mine)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: JobCard(
                        job: j,
                        assigneeName: user.name,
                        onTap: () => _openJob(context, j),
                      ),
                    ),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }

  void _openJob(BuildContext context, Job job) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => JobDetailScreen(jobId: job.id),
      ),
    );
  }
}
