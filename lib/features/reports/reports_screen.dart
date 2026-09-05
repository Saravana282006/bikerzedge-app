import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/jobs/jobs_bloc.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/enums.dart';
import '../../data/repositories/job_repository.dart';
import '../../widgets/common.dart';
import '../../widgets/stat_card.dart';
import '../shell/app_shell.dart';

/// Basic Phase-1 reports: jobs by status, mechanic workload, throughput
/// (PRD §6). Deeper aggregation is a later phase.
class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.read<AuthBloc>().state.user!;
    final repo = context.read<JobRepository>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports'),
        actions: [NotificationAction(user: user), const SizedBox(width: 4)],
      ),
      body: BlocBuilder<JobsBloc, JobsState>(
        builder: (context, state) {
          final jobs = state.jobs;
          final counts = state.countsByStatus;
          final open = jobs.where((j) => j.status.isOpen).length;
          final closed = jobs.where((j) => j.isClosed).length;
          final maxCount = counts.values.isEmpty
              ? 1
              : counts.values.reduce((a, b) => a > b ? a : b);

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Row(
                children: [
                  Expanded(
                    child: StatCard(
                      label: 'Total jobs',
                      value: '${jobs.length}',
                      icon: Icons.summarize_outlined,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: StatCard(
                      label: 'Open',
                      value: '$open',
                      icon: Icons.pending_outlined,
                      color: AppColors.info,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: StatCard(
                      label: 'Completed',
                      value: '$closed',
                      icon: Icons.check_circle_outline,
                      color: AppColors.success,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 22),
              const SectionHeader('Jobs by status'),
              PanelCard(
                child: Column(
                  children: [
                    for (final s in JobStatus.values)
                      _BarRow(
                        label: s.label,
                        value: counts[s] ?? 0,
                        max: maxCount,
                        color: s.color,
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              const SectionHeader('Mechanic workload'),
              PanelCard(
                child: Column(
                  children: [
                    for (final m in repo.mechanics)
                      Builder(builder: (context) {
                        final assigned = jobs
                            .where((j) => j.assignedToId == m.id)
                            .toList();
                        final mopen =
                            assigned.where((j) => j.status.isOpen).length;
                        final mclosed =
                            assigned.where((j) => j.isClosed).length;
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 120,
                                child: Text(m.name,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 13)),
                              ),
                              Expanded(
                                child: Row(
                                  children: [
                                    _wl('$mopen open', AppColors.brandOrange),
                                    const SizedBox(width: 8),
                                    _wl('$mclosed done', AppColors.success),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              const SectionHeader('Notes'),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.info.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                  border:
                      Border.all(color: AppColors.info.withValues(alpha: 0.25)),
                ),
                child: const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.info_outline, size: 18, color: AppColors.info),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Phase-1 reports are simple counts. Time-boxed '
                        'throughput and aggregation (e.g. via Cloud Functions) '
                        'can be added as reporting needs grow.',
                        style: TextStyle(
                            fontSize: 12.5,
                            color: AppColors.slate700,
                            height: 1.5),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
          );
        },
      ),
    );
  }

  Widget _wl(String text, Color color) {
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

class _BarRow extends StatelessWidget {
  const _BarRow({
    required this.label,
    required this.value,
    required this.max,
    required this.color,
  });

  final String label;
  final int value;
  final int max;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          SizedBox(
            width: 130,
            child: Text(label,
                style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.slate700)),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: max == 0 ? 0 : value / max,
                minHeight: 10,
                backgroundColor: AppColors.slate100,
                valueColor: AlwaysStoppedAnimation(color),
              ),
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 22,
            child: Text('$value',
                textAlign: TextAlign.right,
                style: const TextStyle(
                    fontWeight: FontWeight.w800, fontSize: 13)),
          ),
        ],
      ),
    );
  }
}
