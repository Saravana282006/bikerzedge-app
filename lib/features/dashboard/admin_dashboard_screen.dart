import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/jobs/jobs_bloc.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/enums.dart';
import '../../data/models/job.dart';
import '../../data/repositories/job_repository.dart';
import '../../widgets/common.dart';
import '../../widgets/job_card.dart';
import '../../widgets/stat_card.dart';
import '../jobs/create_job_screen.dart';
import '../jobs/job_detail_screen.dart';
import '../shell/app_shell.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.read<AuthBloc>().state.user!;
    final repo = context.read<JobRepository>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [NotificationAction(user: user), const SizedBox(width: 4)],
      ),
      body: BlocBuilder<JobsBloc, JobsState>(
        builder: (context, state) {
          if (state.status == JobsStatus.loading ||
              state.status == JobsStatus.initial) {
            return const Center(child: CircularProgressIndicator());
          }
          final jobs = state.jobs;
          final counts = state.countsByStatus;
          final openCount = jobs.where((j) => j.status.isOpen).length;
          final unassigned =
              jobs.where((j) => !j.isAssigned && j.status.isOpen).length;
          final ready = counts[JobStatus.readyForDelivery] ?? 0;
          final waiting = counts[JobStatus.waitingForParts] ?? 0;
          final priority =
              jobs.where((j) => j.priority && j.status.isOpen).toList();
          final recent = jobs.take(4).toList();

          return RefreshIndicator(
            onRefresh: () async =>
                context.read<JobsBloc>().add(const JobsRefreshed()),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(
                  'Hello, ${user.name.split(' ').first} 👋',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  "Here's the workshop at a glance.",
                  style: TextStyle(fontSize: 14, color: AppColors.slate500),
                ),
                const SizedBox(height: 18),
                _StatGrid(
                  cards: [
                    StatCard(
                      label: 'Open jobs',
                      value: '$openCount',
                      icon: Icons.build_circle_outlined,
                      color: AppColors.brandOrange,
                    ),
                    StatCard(
                      label: 'Unassigned',
                      value: '$unassigned',
                      icon: Icons.person_off_outlined,
                      color: AppColors.danger,
                    ),
                    StatCard(
                      label: 'Waiting for parts',
                      value: '$waiting',
                      icon: Icons.pending_actions_outlined,
                      color: AppColors.warning,
                    ),
                    StatCard(
                      label: 'Ready for delivery',
                      value: '$ready',
                      icon: Icons.local_shipping_outlined,
                      color: AppColors.success,
                    ),
                  ],
                ),
                const SizedBox(height: 22),
                const SectionHeader('Jobs by status'),
                PanelCard(
                  child: Column(
                    children: [
                      for (final s in JobStatus.values)
                        _StatusBar(
                          status: s,
                          count: counts[s] ?? 0,
                          total: jobs.isEmpty ? 1 : jobs.length,
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 22),
                Row(
                  children: [
                    Expanded(
                      child: _QuickAction(
                        icon: Icons.add_circle_outline,
                        label: 'New Job',
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => const CreateJobScreen(),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _QuickAction(
                        icon: Icons.person_off_outlined,
                        label: 'Unassigned ($unassigned)',
                        onTap: () {
                          context
                              .read<JobsBloc>()
                              .add(const JobsFiltersCleared());
                        },
                      ),
                    ),
                  ],
                ),
                if (priority.isNotEmpty) ...[
                  const SizedBox(height: 22),
                  const SectionHeader('Priority jobs'),
                  for (final j in priority)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: JobCard(
                        job: j,
                        assigneeName: repo.userById(j.assignedToId)?.name,
                        onTap: () => _openJob(context, j),
                      ),
                    ),
                ],
                const SizedBox(height: 22),
                const SectionHeader('Recently created'),
                for (final j in recent)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: JobCard(
                      job: j,
                      assigneeName: repo.userById(j.assignedToId)?.name,
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

/// Lays out four stat cards responsively — a single row on wide screens,
/// two rows of two on phones — without a fixed aspect ratio (so nothing
/// can overflow when a label wraps).
class _StatGrid extends StatelessWidget {
  const _StatGrid({required this.cards});
  final List<Widget> cards;

  Widget _row(List<Widget> items) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < items.length; i++) ...[
            if (i > 0) const SizedBox(width: 12),
            Expanded(child: items[i]),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 600;
    if (wide) return _row(cards);
    return Column(
      children: [
        _row(cards.sublist(0, 2)),
        const SizedBox(height: 12),
        _row(cards.sublist(2)),
      ],
    );
  }
}

class _StatusBar extends StatelessWidget {
  const _StatusBar({
    required this.status,
    required this.count,
    required this.total,
  });

  final JobStatus status;
  final int count;
  final int total;

  @override
  Widget build(BuildContext context) {
    final fraction = total == 0 ? 0.0 : count / total;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(status.icon, size: 16, color: status.color),
          const SizedBox(width: 10),
          SizedBox(
            width: 130,
            child: Text(
              status.label,
              style: const TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: AppColors.slate700,
              ),
            ),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: fraction,
                minHeight: 8,
                backgroundColor: AppColors.slate100,
                valueColor: AlwaysStoppedAnimation(status.color),
              ),
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 24,
            child: Text(
              '$count',
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: AppColors.ink,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.slate100),
          ),
          child: Row(
            children: [
              Icon(icon, color: AppColors.brandOrangeDark, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.ink,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
