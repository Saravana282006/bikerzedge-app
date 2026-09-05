import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/jobs/jobs_bloc.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../data/models/job.dart';
import '../../widgets/common.dart';
import '../../widgets/stat_card.dart';
import '../jobs/job_detail_screen.dart';
import '../shell/app_shell.dart';

/// Workshop-wide log of spare parts used across all jobs (PRD §6, §9).
/// Note: full inventory (stock, suppliers) is intentionally out of scope.
class SparePartsScreen extends StatelessWidget {
  const SparePartsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.read<AuthBloc>().state.user!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Spare Parts'),
        actions: [NotificationAction(user: user), const SizedBox(width: 4)],
      ),
      body: BlocBuilder<JobsBloc, JobsState>(
        builder: (context, state) {
          final jobs = state.jobs;
          final entries = <_PartEntry>[];
          for (final j in jobs) {
            for (final p in j.parts) {
              entries.add(_PartEntry(job: j, name: p.name, qty: p.quantity,
                  cost: p.lineTotal, hasCost: p.unitCost != null));
            }
          }
          entries.sort((a, b) => b.job.createdAt.compareTo(a.job.createdAt));

          final totalUnits = entries.fold<int>(0, (s, e) => s + e.qty);
          final totalValue = entries.fold<double>(0, (s, e) => s + e.cost);

          // Top parts by units used.
          final byName = <String, int>{};
          for (final e in entries) {
            byName[e.name] = (byName[e.name] ?? 0) + e.qty;
          }
          final topParts = byName.entries.toList()
            ..sort((a, b) => b.value.compareTo(a.value));

          if (entries.isEmpty) {
            return const EmptyState(
              icon: Icons.inventory_2_outlined,
              title: 'No parts logged yet',
              message: 'Parts logged on jobs will appear here.',
            );
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Row(
                children: [
                  Expanded(
                    child: StatCard(
                      label: 'Parts used',
                      value: '$totalUnits',
                      icon: Icons.inventory_2_outlined,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: StatCard(
                      label: 'Total value',
                      value: Formatters.money(totalValue),
                      icon: Icons.payments_outlined,
                      color: AppColors.success,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 22),
              const SectionHeader('Most used'),
              PanelCard(
                child: Column(
                  children: [
                    for (final e in topParts.take(5))
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(e.key,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13.5)),
                            ),
                            Text('${e.value} used',
                                style: const TextStyle(
                                    color: AppColors.slate500, fontSize: 12.5)),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              const SectionHeader('All logged parts'),
              for (final e in entries)
                Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: const Icon(Icons.settings_outlined,
                        color: AppColors.slate500),
                    title: Text(e.name,
                        style: const TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 14)),
                    subtitle: Text(
                        '${e.job.code} · ${e.job.motorcycle.displayName}',
                        style: const TextStyle(fontSize: 12.5)),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('×${e.qty}',
                            style: const TextStyle(
                                fontWeight: FontWeight.w700, fontSize: 13)),
                        if (e.hasCost)
                          Text(Formatters.money(e.cost),
                              style: const TextStyle(
                                  color: AppColors.slate500, fontSize: 12)),
                      ],
                    ),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => JobDetailScreen(jobId: e.job.id),
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 16),
            ],
          );
        },
      ),
    );
  }
}

class _PartEntry {
  _PartEntry({
    required this.job,
    required this.name,
    required this.qty,
    required this.cost,
    required this.hasCost,
  });
  final Job job;
  final String name;
  final int qty;
  final double cost;
  final bool hasCost;
}
