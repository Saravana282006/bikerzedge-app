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
import '../shell/app_shell.dart';
import 'job_detail_screen.dart';

enum JobsScope { all, mine }

class JobsListScreen extends StatefulWidget {
  const JobsListScreen({super.key, required this.scope});

  final JobsScope scope;

  @override
  State<JobsListScreen> createState() => _JobsListScreenState();
}

class _JobsListScreenState extends State<JobsListScreen> {
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchCtrl.text = context.read<JobsBloc>().state.query;
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = context.read<AuthBloc>().state.user!;
    final repo = context.read<JobRepository>();
    final isMine = widget.scope == JobsScope.mine;

    return Scaffold(
      appBar: AppBar(
        title: Text(isMine ? 'My Jobs' : 'All Jobs'),
        actions: [NotificationAction(user: user), const SizedBox(width: 4)],
      ),
      body: BlocConsumer<JobsBloc, JobsState>(
        listenWhen: (a, b) => a.noticeId != b.noticeId,
        listener: (context, state) {
          if (state.notice != null) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(SnackBar(content: Text(state.notice!)));
          }
        },
        builder: (context, state) {
          if (state.status == JobsStatus.loading ||
              state.status == JobsStatus.initial) {
            return const Center(child: CircularProgressIndicator());
          }

          var jobs = state.filteredJobs;
          if (isMine) {
            jobs = jobs.where((j) => j.assignedToId == user.id).toList();
          }

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                child: TextField(
                  controller: _searchCtrl,
                  onChanged: (v) =>
                      context.read<JobsBloc>().add(JobsSearchChanged(v)),
                  decoration: InputDecoration(
                    hintText: 'Search reg. no, owner, code…',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: state.query.isEmpty
                        ? null
                        : IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () {
                              _searchCtrl.clear();
                              context
                                  .read<JobsBloc>()
                                  .add(const JobsSearchChanged(''));
                            },
                          ),
                  ),
                ),
              ),
              _FilterBar(scope: widget.scope),
              Expanded(
                child: jobs.isEmpty
                    ? EmptyState(
                        icon: Icons.search_off,
                        title: state.hasActiveFilters
                            ? 'No jobs match your filters'
                            : (isMine
                                ? 'No jobs assigned to you'
                                : 'No jobs yet'),
                        message: state.hasActiveFilters
                            ? 'Try clearing the search or filters.'
                            : null,
                      )
                    : RefreshIndicator(
                        onRefresh: () async => context
                            .read<JobsBloc>()
                            .add(const JobsRefreshed()),
                        child: ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: jobs.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 10),
                          itemBuilder: (context, i) {
                            final j = jobs[i];
                            return JobCard(
                              job: j,
                              assigneeName: repo.userById(j.assignedToId)?.name,
                              onTap: () => _openJob(context, j),
                            );
                          },
                        ),
                      ),
              ),
            ],
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

class _FilterBar extends StatelessWidget {
  const _FilterBar({required this.scope});
  final JobsScope scope;

  @override
  Widget build(BuildContext context) {
    final user = context.read<AuthBloc>().state.user!;
    final repo = context.read<JobRepository>();
    final showMechFilter = user.isAdmin && scope == JobsScope.all;

    return BlocBuilder<JobsBloc, JobsState>(
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 44,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  for (final s in JobStatus.values)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(s.label),
                        selected: state.statusFilters.contains(s),
                        showCheckmark: false,
                        avatar: Icon(s.icon,
                            size: 15,
                            color: state.statusFilters.contains(s)
                                ? s.color
                                : AppColors.slate500),
                        selectedColor: s.color.withValues(alpha: 0.14),
                        side: BorderSide(
                          color: state.statusFilters.contains(s)
                              ? s.color
                              : AppColors.slate300,
                        ),
                        onSelected: (_) => context
                            .read<JobsBloc>()
                            .add(JobsStatusFilterToggled(s)),
                      ),
                    ),
                ],
              ),
            ),
            if (showMechFilter)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
                child: Row(
                  children: [
                    const Icon(Icons.engineering_outlined,
                        size: 18, color: AppColors.slate500),
                    const SizedBox(width: 8),
                    Expanded(
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String?>(
                          isExpanded: true,
                          value: state.mechanicFilter,
                          hint: const Text('Filter by mechanic'),
                          items: [
                            const DropdownMenuItem<String?>(
                              value: null,
                              child: Text('All mechanics'),
                            ),
                            for (final m in repo.mechanics)
                              DropdownMenuItem<String?>(
                                value: m.id,
                                child: Text(m.name),
                              ),
                          ],
                          onChanged: (v) => context
                              .read<JobsBloc>()
                              .add(JobsMechanicFilterChanged(v)),
                        ),
                      ),
                    ),
                    if (state.hasActiveFilters)
                      TextButton.icon(
                        onPressed: () => context
                            .read<JobsBloc>()
                            .add(const JobsFiltersCleared()),
                        icon: const Icon(Icons.clear_all, size: 18),
                        label: const Text('Clear'),
                      ),
                  ],
                ),
              ),
            if (!showMechFilter && state.statusFilters.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: () => context
                        .read<JobsBloc>()
                        .add(const JobsFiltersCleared()),
                    icon: const Icon(Icons.clear_all, size: 18),
                    label: const Text('Clear filters'),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
