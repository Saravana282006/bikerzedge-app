import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/enums.dart';
import '../../data/models/job.dart';
import '../../data/models/motorcycle.dart';
import '../../data/models/photo.dart';
import '../../data/repositories/job_repository.dart';

part 'jobs_event.dart';
part 'jobs_state.dart';

class JobsBloc extends Bloc<JobsEvent, JobsState> {
  JobsBloc(this._repository) : super(const JobsState()) {
    on<JobsLoaded>(_onLoaded);
    on<JobsRefreshed>(_onLoaded);
    on<JobsSearchChanged>(_onSearchChanged);
    on<JobsStatusFilterToggled>(_onStatusFilterToggled);
    on<JobsMechanicFilterChanged>(_onMechanicFilterChanged);
    on<JobsFiltersCleared>(_onFiltersCleared);
    on<JobCreateRequested>(_onCreate);
    on<JobAssignRequested>(_onAssign);
    on<JobStatusChangeRequested>(_onStatusChange);
    on<JobNoteAdded>(_onNoteAdded);
    on<JobDiagnosisSet>(_onDiagnosisSet);
    on<JobPartAdded>(_onPartAdded);
    on<JobPartRemoved>(_onPartRemoved);
    on<JobPhotoAdded>(_onPhotoAdded);
    on<JobInspectionToggled>(_onInspectionToggled);
  }

  final JobRepository _repository;

  Future<void> _onLoaded(JobsEvent event, Emitter<JobsState> emit) async {
    if (state.status != JobsStatus.loaded) {
      emit(state.copyWith(status: JobsStatus.loading));
    }
    try {
      final jobs = await _repository.fetchJobs();
      emit(state.copyWith(status: JobsStatus.loaded, jobs: jobs));
    } catch (e) {
      emit(state.copyWith(
        status: JobsStatus.failure,
        error: 'Could not load jobs.',
      ));
    }
  }

  void _onSearchChanged(JobsSearchChanged event, Emitter<JobsState> emit) {
    emit(state.copyWith(query: event.query));
  }

  void _onStatusFilterToggled(
    JobsStatusFilterToggled event,
    Emitter<JobsState> emit,
  ) {
    final next = Set<JobStatus>.from(state.statusFilters);
    if (!next.add(event.status)) {
      next.remove(event.status);
    }
    emit(state.copyWith(statusFilters: next));
  }

  void _onMechanicFilterChanged(
    JobsMechanicFilterChanged event,
    Emitter<JobsState> emit,
  ) {
    if (event.mechanicId == null) {
      emit(state.copyWith(clearMechanicFilter: true));
    } else {
      emit(state.copyWith(mechanicFilter: event.mechanicId));
    }
  }

  void _onFiltersCleared(JobsFiltersCleared event, Emitter<JobsState> emit) {
    emit(state.copyWith(
      query: '',
      statusFilters: const {},
      clearMechanicFilter: true,
    ));
  }

  // -------------------------------------------------------- mutations ---
  Future<void> _runMutation(
    Emitter<JobsState> emit,
    Future<void> Function() action,
    String successNotice,
  ) async {
    emit(state.copyWith(processing: true, clearError: true));
    try {
      await action();
      final jobs = await _repository.fetchJobs();
      emit(state.copyWith(
        jobs: jobs,
        processing: false,
        notice: successNotice,
        noticeId: state.noticeId + 1,
      ));
    } catch (e) {
      emit(state.copyWith(
        processing: false,
        notice: 'Action failed. Please try again.',
        noticeId: state.noticeId + 1,
        error: e.toString(),
      ));
    }
  }

  Future<void> _onCreate(
    JobCreateRequested event,
    Emitter<JobsState> emit,
  ) async {
    await _runMutation(
      emit,
      () => _repository.createJob(
        ownerName: event.ownerName,
        contact: event.contact,
        motorcycle: event.motorcycle,
        serviceRequest: event.serviceRequest,
        priority: event.priority,
        byUser: event.byUser,
      ),
      'Job created and added to the board.',
    );
  }

  Future<void> _onAssign(
    JobAssignRequested event,
    Emitter<JobsState> emit,
  ) async {
    final mech = _repository.userById(event.mechanicId);
    await _runMutation(
      emit,
      () => _repository.assignJob(
        jobId: event.jobId,
        mechanicId: event.mechanicId,
        byUser: event.byUser,
      ),
      'Assigned to ${mech?.name ?? 'mechanic'}.',
    );
  }

  Future<void> _onStatusChange(
    JobStatusChangeRequested event,
    Emitter<JobsState> emit,
  ) async {
    await _runMutation(
      emit,
      () => _repository.changeStatus(
        jobId: event.jobId,
        newStatus: event.newStatus,
        byUser: event.byUser,
        note: event.note,
      ),
      'Status updated to ${event.newStatus.label}.',
    );
  }

  Future<void> _onNoteAdded(
    JobNoteAdded event,
    Emitter<JobsState> emit,
  ) async {
    await _runMutation(
      emit,
      () => _repository.addNote(
        jobId: event.jobId,
        note: event.note,
        byUser: event.byUser,
      ),
      'Note added.',
    );
  }

  Future<void> _onDiagnosisSet(
    JobDiagnosisSet event,
    Emitter<JobsState> emit,
  ) async {
    await _runMutation(
      emit,
      () => _repository.setDiagnosis(
        jobId: event.jobId,
        diagnosis: event.diagnosis,
        byUser: event.byUser,
      ),
      'Diagnosis saved.',
    );
  }

  Future<void> _onPartAdded(
    JobPartAdded event,
    Emitter<JobsState> emit,
  ) async {
    await _runMutation(
      emit,
      () => _repository.addPart(
        jobId: event.jobId,
        name: event.name,
        quantity: event.quantity,
        unitCost: event.unitCost,
        byUser: event.byUser,
      ),
      'Part logged.',
    );
  }

  Future<void> _onPartRemoved(
    JobPartRemoved event,
    Emitter<JobsState> emit,
  ) async {
    await _runMutation(
      emit,
      () => _repository.removePart(jobId: event.jobId, partId: event.partId),
      'Part removed.',
    );
  }

  Future<void> _onPhotoAdded(
    JobPhotoAdded event,
    Emitter<JobsState> emit,
  ) async {
    await _runMutation(
      emit,
      () => _repository.addPhoto(
        jobId: event.jobId,
        caption: event.caption,
        stage: event.stage,
        byUser: event.byUser,
        pendingUpload: event.pendingUpload,
      ),
      event.pendingUpload
          ? 'Photo captured — queued to sync when back online.'
          : 'Photo added.',
    );
  }

  Future<void> _onInspectionToggled(
    JobInspectionToggled event,
    Emitter<JobsState> emit,
  ) async {
    // No success notice — this is a high-frequency toggle.
    try {
      await _repository.toggleInspectionItem(
        jobId: event.jobId,
        itemId: event.itemId,
      );
      final jobs = await _repository.fetchJobs();
      emit(state.copyWith(jobs: jobs));
    } catch (_) {/* ignore transient toggle failure in prototype */}
  }
}
