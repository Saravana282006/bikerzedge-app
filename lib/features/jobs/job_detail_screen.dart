import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/jobs/jobs_bloc.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../data/models/enums.dart';
import '../../data/models/job.dart';
import '../../data/models/photo.dart';
import '../../data/models/user.dart';
import '../../data/repositories/job_repository.dart';
import '../../widgets/common.dart';
import '../../widgets/status_chip.dart';
import '../../widgets/user_avatar.dart';
import 'inspection_screen.dart';
import 'job_timeline_view.dart';
import 'widgets/assign_sheet.dart';
import 'widgets/job_dialogs.dart';

class JobDetailScreen extends StatelessWidget {
  const JobDetailScreen({super.key, required this.jobId});

  final String jobId;

  @override
  Widget build(BuildContext context) {
    final user = context.read<AuthBloc>().state.user!;
    final repo = context.read<JobRepository>();

    return BlocConsumer<JobsBloc, JobsState>(
      listenWhen: (a, b) => a.noticeId != b.noticeId,
      listener: (context, state) {
        if (state.notice != null) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(content: Text(state.notice!)));
        }
      },
      builder: (context, state) {
        final job = state.jobById(jobId);
        if (job == null) {
          return Scaffold(
            appBar: AppBar(),
            body: const EmptyState(
              icon: Icons.error_outline,
              title: 'Job not found',
            ),
          );
        }

        final assignee = repo.userById(job.assignedToId);
        final canEdit =
            user.isAdmin || (job.assignedToId == user.id && !job.isClosed);

        return DefaultTabController(
          length: 3,
          child: Scaffold(
            appBar: AppBar(
              title: Text(job.code),
              bottom: const TabBar(
                labelColor: AppColors.brandOrangeDark,
                unselectedLabelColor: AppColors.slate500,
                indicatorColor: AppColors.brandOrange,
                tabs: [
                  Tab(text: 'Overview'),
                  Tab(text: 'Workspace'),
                  Tab(text: 'Timeline'),
                ],
              ),
            ),
            body: TabBarView(
              children: [
                _OverviewTab(job: job, assignee: assignee, user: user),
                _WorkspaceTab(job: job, user: user, canEdit: canEdit),
                JobTimelineView(job: job),
              ],
            ),
            bottomNavigationBar: _ActionBar(
              job: job,
              user: user,
              canEdit: canEdit,
              assignee: assignee,
            ),
          ),
        );
      },
    );
  }
}

// ------------------------------------------------------------- Overview ---
class _OverviewTab extends StatelessWidget {
  const _OverviewTab({
    required this.job,
    required this.assignee,
    required this.user,
  });

  final Job job;
  final AppUser? assignee;
  final AppUser user;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            StatusChip(status: job.status),
            const Spacer(),
            if (job.priority)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.danger.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.flag_rounded,
                        size: 14, color: AppColors.danger),
                    SizedBox(width: 4),
                    Text('Priority',
                        style: TextStyle(
                          color: AppColors.danger,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        )),
                  ],
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),
        _WorkflowProgress(status: job.status),
        const SizedBox(height: 20),
        const SectionHeader('Motorcycle'),
        PanelCard(
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.brandOrange.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.two_wheeler,
                        color: AppColors.brandOrangeDark, size: 26),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          job.motorcycle.displayName,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: AppColors.ink,
                          ),
                        ),
                        Text(
                          job.motorcycle.registration,
                          style: const TextStyle(
                            fontSize: 13.5,
                            color: AppColors.slate500,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Divider(height: 24),
              InfoRow(
                label: 'Odometer',
                value: '${job.motorcycle.odometer} km',
                icon: Icons.speed,
              ),
              if (job.motorcycle.year != null)
                InfoRow(
                  label: 'Year',
                  value: '${job.motorcycle.year}',
                  icon: Icons.event_outlined,
                ),
              if (job.motorcycle.color != null)
                InfoRow(
                  label: 'Colour',
                  value: job.motorcycle.color!,
                  icon: Icons.palette_outlined,
                ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        const SectionHeader('Customer'),
        PanelCard(
          child: Column(
            children: [
              InfoRow(
                  label: 'Owner',
                  value: job.ownerName,
                  icon: Icons.person_outline),
              InfoRow(
                  label: 'Contact',
                  value: job.contact,
                  icon: Icons.phone_outlined),
              InfoRow(
                label: 'Received',
                value: Formatters.dateTime(job.createdAt),
                icon: Icons.login,
              ),
              if (job.closedAt != null)
                InfoRow(
                  label: 'Closed',
                  value: Formatters.dateTime(job.closedAt!),
                  icon: Icons.check_circle_outline,
                ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        const SectionHeader('Service request'),
        PanelCard(
          child: Text(
            job.serviceRequest,
            style: const TextStyle(fontSize: 14, height: 1.5),
          ),
        ),
        const SizedBox(height: 16),
        const SectionHeader('Assigned mechanic'),
        PanelCard(
          child: assignee == null
              ? const Row(
                  children: [
                    Icon(Icons.person_off_outlined, color: AppColors.danger),
                    SizedBox(width: 12),
                    Text('Not yet assigned',
                        style: TextStyle(
                          color: AppColors.danger,
                          fontWeight: FontWeight.w600,
                        )),
                  ],
                )
              : Row(
                  children: [
                    UserAvatar(user: assignee!),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(assignee!.name,
                            style: const TextStyle(
                                fontWeight: FontWeight.w700, fontSize: 15)),
                        Text(assignee!.email,
                            style: const TextStyle(
                                color: AppColors.slate500, fontSize: 12.5)),
                      ],
                    ),
                  ],
                ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}

/// A compact horizontal representation of the 10-stage workflow.
class _WorkflowProgress extends StatelessWidget {
  const _WorkflowProgress({required this.status});
  final JobStatus status;

  @override
  Widget build(BuildContext context) {
    final total = JobStatus.values.length;
    final current = status.step + 1;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Stage $current of $total',
              style: const TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: AppColors.slate700,
              ),
            ),
            const Spacer(),
            Text(
              status.label,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: status.color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            for (var i = 0; i < total; i++)
              Expanded(
                child: Container(
                  height: 6,
                  margin: EdgeInsets.only(right: i == total - 1 ? 0 : 3),
                  decoration: BoxDecoration(
                    color: i <= status.step
                        ? status.color
                        : AppColors.slate100,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

// ------------------------------------------------------------ Workspace ---
class _WorkspaceTab extends StatelessWidget {
  const _WorkspaceTab({
    required this.job,
    required this.user,
    required this.canEdit,
  });

  final Job job;
  final AppUser user;
  final bool canEdit;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (!canEdit)
          Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.slate100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.lock_outline,
                    size: 18, color: AppColors.slate500),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    job.isClosed
                        ? 'This job is closed and read-only.'
                        : 'Read-only — this job is not assigned to you.',
                    style: const TextStyle(
                        fontSize: 12.5, color: AppColors.slate700),
                  ),
                ),
              ],
            ),
          ),
        // Inspection
        _InspectionCard(job: job, canEdit: canEdit),
        const SizedBox(height: 16),
        // Diagnosis
        const SectionHeader('Diagnosis'),
        PanelCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                job.diagnosis?.isNotEmpty == true
                    ? job.diagnosis!
                    : 'No diagnosis recorded yet.',
                style: TextStyle(
                  fontSize: 14,
                  height: 1.5,
                  color: job.diagnosis?.isNotEmpty == true
                      ? AppColors.ink
                      : AppColors.slate500,
                  fontStyle: job.diagnosis?.isNotEmpty == true
                      ? FontStyle.normal
                      : FontStyle.italic,
                ),
              ),
              if (canEdit) ...[
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () => JobDialogs.editDiagnosis(context, job, user),
                  icon: const Icon(Icons.edit_note, size: 18),
                  label: Text(
                      job.diagnosis?.isNotEmpty == true ? 'Edit' : 'Add diagnosis'),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 16),
        // Spare parts
        SectionHeader(
          'Spare parts (${job.partsCount})',
          trailing: job.parts.isEmpty
              ? null
              : Text(
                  Formatters.money(job.partsTotal),
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    color: AppColors.ink,
                    fontSize: 13,
                  ),
                ),
        ),
        PanelCard(
          child: Column(
            children: [
              if (job.parts.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Text('No parts logged.',
                      style: TextStyle(
                          color: AppColors.slate500,
                          fontStyle: FontStyle.italic)),
                )
              else
                for (final p in job.parts)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      children: [
                        const Icon(Icons.settings_outlined,
                            size: 18, color: AppColors.slate500),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            p.name,
                            style: const TextStyle(
                                fontWeight: FontWeight.w600, fontSize: 14),
                          ),
                        ),
                        Text('×${p.quantity}',
                            style: const TextStyle(
                                color: AppColors.slate500, fontSize: 13)),
                        if (p.unitCost != null) ...[
                          const SizedBox(width: 12),
                          Text(Formatters.money(p.lineTotal),
                              style: const TextStyle(
                                  fontWeight: FontWeight.w700, fontSize: 13)),
                        ],
                        if (canEdit)
                          IconButton(
                            visualDensity: VisualDensity.compact,
                            icon: const Icon(Icons.close,
                                size: 18, color: AppColors.slate500),
                            onPressed: () => context.read<JobsBloc>().add(
                                  JobPartRemoved(jobId: job.id, partId: p.id),
                                ),
                          ),
                      ],
                    ),
                  ),
              if (canEdit) ...[
                const SizedBox(height: 10),
                OutlinedButton.icon(
                  onPressed: () => JobDialogs.addPart(context, job, user),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Log a part'),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 16),
        // Photos
        SectionHeader('Photos (${job.photos.length})'),
        _PhotosGrid(job: job, canEdit: canEdit, user: user),
        const SizedBox(height: 16),
        // Notes
        const SectionHeader('Notes'),
        PanelCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (job.notes.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Text('No notes yet.',
                      style: TextStyle(
                          color: AppColors.slate500,
                          fontStyle: FontStyle.italic)),
                )
              else
                for (final n in job.notes)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(top: 2),
                          child: Icon(Icons.sticky_note_2_outlined,
                              size: 16, color: AppColors.slate500),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(n,
                              style: const TextStyle(
                                  fontSize: 14, height: 1.4)),
                        ),
                      ],
                    ),
                  ),
              if (canEdit) ...[
                const SizedBox(height: 10),
                OutlinedButton.icon(
                  onPressed: () => JobDialogs.addNote(context, job, user),
                  icon: const Icon(Icons.add_comment_outlined, size: 18),
                  label: const Text('Add note'),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}

class _InspectionCard extends StatelessWidget {
  const _InspectionCard({required this.job, required this.canEdit});
  final Job job;
  final bool canEdit;

  @override
  Widget build(BuildContext context) {
    final done = job.inspectionDone;
    final total = job.inspection.length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader('Inspection checklist ($done/$total)'),
        PanelCard(
          child: Column(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: total == 0 ? 0 : done / total,
                  minHeight: 8,
                  backgroundColor: AppColors.slate100,
                  valueColor:
                      const AlwaysStoppedAnimation(AppColors.brandOrange),
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      total == 0
                          ? 'No checklist'
                          : done == total
                              ? 'Inspection complete ✓'
                              : '${total - done} item(s) remaining',
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.slate700,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  OutlinedButton.icon(
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) =>
                            InspectionScreen(jobId: job.id, canEdit: canEdit),
                      ),
                    ),
                    icon: const Icon(Icons.checklist, size: 18),
                    label: Text(canEdit ? 'Open' : 'View'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PhotosGrid extends StatelessWidget {
  const _PhotosGrid({
    required this.job,
    required this.canEdit,
    required this.user,
  });
  final Job job;
  final bool canEdit;
  final AppUser user;

  @override
  Widget build(BuildContext context) {
    return PanelCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (job.photos.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text('No photos attached.',
                  style: TextStyle(
                      color: AppColors.slate500,
                      fontStyle: FontStyle.italic)),
            )
          else
            GridView.count(
              crossAxisCount: 3,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 0.82,
              children: [for (final p in job.photos) _PhotoTile(photo: p)],
            ),
          if (canEdit) ...[
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () => JobDialogs.addPhoto(context, job, user),
              icon: const Icon(Icons.add_a_photo_outlined, size: 18),
              label: const Text('Add photo'),
            ),
          ],
        ],
      ),
    );
  }
}

class _PhotoTile extends StatelessWidget {
  const _PhotoTile({required this.photo});
  final JobPhoto photo;

  @override
  Widget build(BuildContext context) {
    final color = Color(photo.seedColor);
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color, color.withValues(alpha: 0.7)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: const Center(
              child: Icon(Icons.image_outlined, color: Colors.white70),
            ),
          ),
          Positioned(
            top: 4,
            left: 4,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(5),
              ),
              child: Text(
                photo.stage.label,
                style: const TextStyle(color: Colors.white, fontSize: 9.5),
              ),
            ),
          ),
          if (photo.pendingUpload)
            const Positioned(
              top: 4,
              right: 4,
              child: Icon(Icons.sync_problem,
                  size: 15, color: Colors.amberAccent),
            ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(5),
              color: Colors.black54,
              child: Text(
                photo.caption,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.white, fontSize: 10),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ------------------------------------------------------------ Action bar ---
class _ActionBar extends StatelessWidget {
  const _ActionBar({
    required this.job,
    required this.user,
    required this.canEdit,
    required this.assignee,
  });

  final Job job;
  final AppUser user;
  final bool canEdit;
  final AppUser? assignee;

  @override
  Widget build(BuildContext context) {
    final processing = context.select((JobsBloc b) => b.state.processing);
    final children = <Widget>[];

    // Admin: assign / reassign
    if (user.isAdmin && !job.isClosed) {
      children.add(
        Expanded(
          child: OutlinedButton.icon(
            onPressed: processing
                ? null
                : () => AssignSheet.show(context, job, user),
            icon: const Icon(Icons.person_add_alt_1, size: 18),
            label: Text(job.isAssigned ? 'Reassign' : 'Assign'),
          ),
        ),
      );
    }

    // Advance-status actions
    final nextOptions = canEdit ? job.status.nextOptions : <JobStatus>[];
    if (nextOptions.isNotEmpty) {
      if (children.isNotEmpty) children.add(const SizedBox(width: 10));
      children.add(
        Expanded(
          flex: 2,
          child: FilledButton.icon(
            onPressed: processing
                ? null
                : () => _advance(context, nextOptions),
            icon: const Icon(Icons.arrow_forward, size: 18),
            label: Text('Move to ${nextOptions.first.label}'),
          ),
        ),
      );
    }

    // Admin close action (only from Ready for Delivery)
    if (user.isAdmin && job.status == JobStatus.readyForDelivery) {
      if (children.isNotEmpty) children.add(const SizedBox(width: 10));
      children.add(
        Expanded(
          child: FilledButton.icon(
            style: FilledButton.styleFrom(backgroundColor: AppColors.success),
            onPressed: processing ? null : () => _close(context),
            icon: const Icon(Icons.check_circle_outline, size: 18),
            label: const Text('Close'),
          ),
        ),
      );
    }

    if (children.isEmpty) {
      // Nothing actionable — show a status hint.
      children.add(
        Expanded(
          child: Center(
            child: Text(
              job.isClosed
                  ? 'Job closed'
                  : (user.isMechanic && job.assignedToId != user.id
                      ? 'Assigned to ${assignee?.name ?? 'another mechanic'}'
                      : job.status == JobStatus.readyForDelivery
                          ? 'Awaiting admin to close'
                          : 'No actions available'),
              style: const TextStyle(
                color: AppColors.slate500,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
        ),
      );
    }

    return SafeArea(
      minimum: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: Row(children: children),
    );
  }

  void _advance(BuildContext context, List<JobStatus> options) {
    if (options.length == 1) {
      _confirmStatus(context, options.first);
      return;
    }
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 4, 20, 8),
              child: Text('Advance job to…',
                  style: TextStyle(
                      fontWeight: FontWeight.w800, fontSize: 16)),
            ),
            for (final s in options)
              ListTile(
                leading: Icon(s.icon, color: s.color),
                title: Text(s.label),
                onTap: () {
                  Navigator.pop(ctx);
                  _confirmStatus(context, s);
                },
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _confirmStatus(BuildContext context, JobStatus s) {
    context.read<JobsBloc>().add(
          JobStatusChangeRequested(
            jobId: job.id,
            newStatus: s,
            byUser: user.name,
          ),
        );
  }

  void _close(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Close this job?'),
        content: Text(
          '${job.code} will be marked Closed and become read-only for '
          'mechanics. Only an admin can reopen it.',
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.success),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Close job'),
          ),
        ],
      ),
    );
    if (confirm == true && context.mounted) {
      context.read<JobsBloc>().add(
            JobStatusChangeRequested(
              jobId: job.id,
              newStatus: JobStatus.closed,
              byUser: user.name,
            ),
          );
    }
  }
}
