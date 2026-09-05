part of 'jobs_bloc.dart';

enum JobsStatus { initial, loading, loaded, failure }

class JobsState extends Equatable {
  const JobsState({
    this.status = JobsStatus.initial,
    this.jobs = const [],
    this.query = '',
    this.statusFilters = const {},
    this.mechanicFilter,
    this.processing = false,
    this.notice,
    this.noticeId = 0,
    this.error,
  });

  final JobsStatus status;
  final List<Job> jobs;
  final String query;
  final Set<JobStatus> statusFilters;
  final String? mechanicFilter;

  /// True while a mutation is in flight (drives inline spinners).
  final bool processing;

  /// A transient message for a SnackBar; [noticeId] increments so identical
  /// messages still trigger a BlocListener.
  final String? notice;
  final int noticeId;
  final String? error;

  bool get hasActiveFilters =>
      query.isNotEmpty || statusFilters.isNotEmpty || mechanicFilter != null;

  /// Look up a job by id from the current list.
  Job? jobById(String id) {
    for (final j in jobs) {
      if (j.id == id) return j;
    }
    return null;
  }

  /// Jobs matching the current search + status + mechanic filters.
  List<Job> get filteredJobs {
    final q = query.trim().toLowerCase();
    return jobs.where((job) {
      if (statusFilters.isNotEmpty && !statusFilters.contains(job.status)) {
        return false;
      }
      if (mechanicFilter != null && job.assignedToId != mechanicFilter) {
        return false;
      }
      if (q.isEmpty) return true;
      final haystack = [
        job.code,
        job.ownerName,
        job.motorcycle.registration,
        job.motorcycle.displayName,
        job.status.label,
        job.serviceRequest,
      ].join(' ').toLowerCase();
      return haystack.contains(q);
    }).toList();
  }

  /// Count of jobs per status across the whole (unfiltered) list.
  Map<JobStatus, int> get countsByStatus {
    final map = <JobStatus, int>{};
    for (final j in jobs) {
      map[j.status] = (map[j.status] ?? 0) + 1;
    }
    return map;
  }

  JobsState copyWith({
    JobsStatus? status,
    List<Job>? jobs,
    String? query,
    Set<JobStatus>? statusFilters,
    String? mechanicFilter,
    bool clearMechanicFilter = false,
    bool? processing,
    String? notice,
    int? noticeId,
    String? error,
    bool clearError = false,
  }) {
    return JobsState(
      status: status ?? this.status,
      jobs: jobs ?? this.jobs,
      query: query ?? this.query,
      statusFilters: statusFilters ?? this.statusFilters,
      mechanicFilter:
          clearMechanicFilter ? null : (mechanicFilter ?? this.mechanicFilter),
      processing: processing ?? this.processing,
      notice: notice ?? this.notice,
      noticeId: noticeId ?? this.noticeId,
      error: clearError ? null : (error ?? this.error),
    );
  }

  @override
  List<Object?> get props => [
        status,
        jobs,
        query,
        statusFilters,
        mechanicFilter,
        processing,
        notice,
        noticeId,
        error,
      ];
}
