import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../blocs/jobs/jobs_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/job.dart';
import '../../../data/models/user.dart';
import '../../../data/repositories/job_repository.dart';
import '../../../widgets/user_avatar.dart';

/// Bottom sheet for an admin to assign or reassign a job to a mechanic.
class AssignSheet {
  AssignSheet._();

  static void show(BuildContext context, Job job, AppUser admin) {
    final repo = context.read<JobRepository>();
    final jobsBloc = context.read<JobsBloc>();
    final mechanics = repo.mechanics.where((m) => m.active).toList();

    // Count current open workload per mechanic for a helpful hint.
    final workload = <String, int>{};
    for (final j in jobsBloc.state.jobs) {
      if (j.assignedToId != null && j.status.isOpen) {
        workload[j.assignedToId!] = (workload[j.assignedToId!] ?? 0) + 1;
      }
    }

    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 10),
              child: Text(
                job.isAssigned ? 'Reassign ${job.code}' : 'Assign ${job.code}',
                style: const TextStyle(
                    fontWeight: FontWeight.w800, fontSize: 17),
              ),
            ),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                children: [
                  for (final m in mechanics)
                    ListTile(
                      leading: UserAvatar(user: m),
                      title: Text(m.name),
                      subtitle: Text(
                        '${workload[m.id] ?? 0} open job(s)',
                        style: const TextStyle(fontSize: 12.5),
                      ),
                      trailing: job.assignedToId == m.id
                          ? const Icon(Icons.check_circle,
                              color: AppColors.success)
                          : const Icon(Icons.chevron_right),
                      onTap: () {
                        Navigator.pop(ctx);
                        if (job.assignedToId != m.id) {
                          jobsBloc.add(
                            JobAssignRequested(
                              jobId: job.id,
                              mechanicId: m.id,
                              byUser: admin.name,
                            ),
                          );
                        }
                      },
                    ),
                ],
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
