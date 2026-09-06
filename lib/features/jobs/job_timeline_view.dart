import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../data/models/job.dart';
import '../../data/models/timeline_event.dart';
import '../../widgets/common.dart';

/// Chronological, timestamped history of a job (PRD §6). Newest first.
class JobTimelineView extends StatelessWidget {
  const JobTimelineView({super.key, required this.job});

  final Job job;

  @override
  Widget build(BuildContext context) {
    final events = [...job.timeline]..sort((a, b) => b.at.compareTo(a.at));
    if (events.isEmpty) {
      return const EmptyState(
        icon: Icons.history,
        title: 'No history yet',
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: events.length,
      itemBuilder: (context, i) {
        final e = events[i];
        final isLast = i == events.length - 1;
        return Padding(
          padding: EdgeInsets.only(bottom: isLast ? 0 : 4),
          child: Stack(
            children: [
              if (!isLast)
                const Positioned(
                  left: 16,
                  top: 34,
                  bottom: 0,
                  child: ColoredBox(color: AppColors.slate100, child: SizedBox(width: 2)),
                ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: _color(e).withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                      border: Border.all(color: _color(e).withValues(alpha: 0.4)),
                    ),
                    child: Icon(_icon(e), size: 17, color: _color(e)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(bottom: isLast ? 0 : 18),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _title(e),
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                              color: AppColors.ink,
                            ),
                          ),
                          if (e.note != null && e.note!.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text(
                              e.note!,
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.slate700,
                                height: 1.4,
                              ),
                            ),
                          ],
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.person_outline,
                                  size: 13, color: AppColors.slate500),
                              const SizedBox(width: 4),
                              Text(
                                e.byUser,
                                style: const TextStyle(
                                    fontSize: 12, color: AppColors.slate500),
                              ),
                              const SizedBox(width: 10),
                              const Icon(Icons.schedule,
                                  size: 12, color: AppColors.slate500),
                              const SizedBox(width: 4),
                              Text(
                                Formatters.dateTime(e.at),
                                style: const TextStyle(
                                    fontSize: 12, color: AppColors.slate500),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  String _title(TimelineEvent e) {
    if (e.type == TimelineEventType.statusChange &&
        e.fromStatus != null &&
        e.toStatus != null) {
      return '${e.fromStatus!.label} → ${e.toStatus!.label}';
    }
    return e.type.label;
  }

  IconData _icon(TimelineEvent e) {
    if (e.type == TimelineEventType.statusChange && e.toStatus != null) {
      return e.toStatus!.icon;
    }
    return switch (e.type) {
      TimelineEventType.created => Icons.add_circle_outline,
      TimelineEventType.note => Icons.sticky_note_2_outlined,
      TimelineEventType.photo => Icons.photo_camera_outlined,
      TimelineEventType.part => Icons.settings_outlined,
      TimelineEventType.assignment => Icons.person_add_alt_1_outlined,
      TimelineEventType.statusChange => Icons.sync_alt,
    };
  }

  Color _color(TimelineEvent e) {
    if (e.type == TimelineEventType.statusChange && e.toStatus != null) {
      return e.toStatus!.color;
    }
    return AppColors.brandOrangeDark;
  }
}
