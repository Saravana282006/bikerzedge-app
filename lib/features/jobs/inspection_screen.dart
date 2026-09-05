import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/jobs/jobs_bloc.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/common.dart';

/// Intake inspection checklist with per-item check + remark (PRD §6).
class InspectionScreen extends StatelessWidget {
  const InspectionScreen({
    super.key,
    required this.jobId,
    required this.canEdit,
  });

  final String jobId;
  final bool canEdit;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Inspection checklist')),
      body: BlocBuilder<JobsBloc, JobsState>(
        builder: (context, state) {
          final job = state.jobById(jobId);
          if (job == null) {
            return const EmptyState(
                icon: Icons.error_outline, title: 'Job not found');
          }
          final done = job.inspectionDone;
          final total = job.inspection.length;

          return Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                color: AppColors.white,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text('$done of $total checked',
                            style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                color: AppColors.ink)),
                        const Spacer(),
                        if (done == total && total > 0)
                          const Row(
                            children: [
                              Icon(Icons.verified,
                                  size: 16, color: AppColors.success),
                              SizedBox(width: 4),
                              Text('Complete',
                                  style: TextStyle(
                                      color: AppColors.success,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 13)),
                            ],
                          ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: total == 0 ? 0 : done / total,
                        minHeight: 8,
                        backgroundColor: AppColors.slate100,
                        valueColor: const AlwaysStoppedAnimation(
                            AppColors.brandOrange),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: ListView.separated(
                  itemCount: job.inspection.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, i) {
                    final item = job.inspection[i];
                    return CheckboxListTile(
                      value: item.checked,
                      controlAffinity: ListTileControlAffinity.leading,
                      activeColor: AppColors.brandOrange,
                      onChanged: canEdit
                          ? (_) => context.read<JobsBloc>().add(
                                JobInspectionToggled(
                                    jobId: job.id, itemId: item.id),
                              )
                          : null,
                      title: Text(
                        item.label,
                        style: TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w600,
                          color: item.checked
                              ? AppColors.slate500
                              : AppColors.ink,
                          decoration: item.checked
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                      ),
                      subtitle: item.remark != null
                          ? Text(item.remark!,
                              style: const TextStyle(fontSize: 12.5))
                          : null,
                    );
                  },
                ),
              ),
              if (!canEdit)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  color: AppColors.slate100,
                  child: const Text(
                    'Read-only view',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: AppColors.slate500,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
