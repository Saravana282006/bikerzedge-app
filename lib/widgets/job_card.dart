import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/utils/formatters.dart';
import '../data/models/job.dart';
import 'status_chip.dart';

/// A tappable summary card for a job, used in every job list.
class JobCard extends StatelessWidget {
  const JobCard({
    super.key,
    required this.job,
    required this.onTap,
    this.assigneeName,
  });

  final Job job;
  final VoidCallback onTap;
  final String? assigneeName;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if (job.priority) ...[
                    const Icon(Icons.flag_rounded,
                        size: 16, color: AppColors.danger),
                    const SizedBox(width: 4),
                  ],
                  Text(
                    job.code,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                      color: AppColors.brandOrangeDark,
                      letterSpacing: 0.2,
                    ),
                  ),
                  const Spacer(),
                  StatusChip(status: job.status, compact: true),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                job.motorcycle.displayName,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  color: AppColors.ink,
                ),
              ),
              const SizedBox(height: 2),
              Row(
                children: [
                  const Icon(Icons.confirmation_number_outlined,
                      size: 14, color: AppColors.slate500),
                  const SizedBox(width: 4),
                  Text(
                    job.motorcycle.registration,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.slate700,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Icon(Icons.person_outline,
                      size: 14, color: AppColors.slate500),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      job.ownerName,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.slate700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              const Divider(height: 1),
              const SizedBox(height: 10),
              Row(
                children: [
                  Icon(Icons.engineering_outlined,
                      size: 15,
                      color: assigneeName == null
                          ? AppColors.danger
                          : AppColors.slate500),
                  const SizedBox(width: 4),
                  Text(
                    assigneeName ?? 'Unassigned',
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: assigneeName == null
                          ? AppColors.danger
                          : AppColors.slate700,
                    ),
                  ),
                  const Spacer(),
                  if (job.pendingPhotoUploads > 0) ...[
                    const Icon(Icons.sync_problem_outlined,
                        size: 15, color: AppColors.warning),
                    const SizedBox(width: 4),
                  ],
                  const Icon(Icons.schedule,
                      size: 14, color: AppColors.slate500),
                  const SizedBox(width: 4),
                  Text(
                    Formatters.relative(job.createdAt),
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.slate500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
