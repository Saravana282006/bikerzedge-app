part of 'jobs_bloc.dart';

sealed class JobsEvent extends Equatable {
  const JobsEvent();
  @override
  List<Object?> get props => [];
}

class JobsLoaded extends JobsEvent {
  const JobsLoaded();
}

class JobsRefreshed extends JobsEvent {
  const JobsRefreshed();
}

// --- Filters (admin Jobs screen) ---
class JobsSearchChanged extends JobsEvent {
  const JobsSearchChanged(this.query);
  final String query;
  @override
  List<Object?> get props => [query];
}

class JobsStatusFilterToggled extends JobsEvent {
  const JobsStatusFilterToggled(this.status);
  final JobStatus status;
  @override
  List<Object?> get props => [status];
}

class JobsMechanicFilterChanged extends JobsEvent {
  const JobsMechanicFilterChanged(this.mechanicId);
  final String? mechanicId;
  @override
  List<Object?> get props => [mechanicId];
}

class JobsFiltersCleared extends JobsEvent {
  const JobsFiltersCleared();
}

// --- Mutations ---
class JobCreateRequested extends JobsEvent {
  const JobCreateRequested({
    required this.ownerName,
    required this.contact,
    required this.motorcycle,
    required this.serviceRequest,
    required this.priority,
    required this.byUser,
  });
  final String ownerName;
  final String contact;
  final Motorcycle motorcycle;
  final String serviceRequest;
  final bool priority;
  final String byUser;
  @override
  List<Object?> get props =>
      [ownerName, contact, motorcycle, serviceRequest, priority, byUser];
}

class JobAssignRequested extends JobsEvent {
  const JobAssignRequested({
    required this.jobId,
    required this.mechanicId,
    required this.byUser,
  });
  final String jobId;
  final String mechanicId;
  final String byUser;
  @override
  List<Object?> get props => [jobId, mechanicId, byUser];
}

class JobStatusChangeRequested extends JobsEvent {
  const JobStatusChangeRequested({
    required this.jobId,
    required this.newStatus,
    required this.byUser,
    this.note,
  });
  final String jobId;
  final JobStatus newStatus;
  final String byUser;
  final String? note;
  @override
  List<Object?> get props => [jobId, newStatus, byUser, note];
}

class JobNoteAdded extends JobsEvent {
  const JobNoteAdded({
    required this.jobId,
    required this.note,
    required this.byUser,
  });
  final String jobId;
  final String note;
  final String byUser;
  @override
  List<Object?> get props => [jobId, note, byUser];
}

class JobDiagnosisSet extends JobsEvent {
  const JobDiagnosisSet({
    required this.jobId,
    required this.diagnosis,
    required this.byUser,
  });
  final String jobId;
  final String diagnosis;
  final String byUser;
  @override
  List<Object?> get props => [jobId, diagnosis, byUser];
}

class JobPartAdded extends JobsEvent {
  const JobPartAdded({
    required this.jobId,
    required this.name,
    required this.quantity,
    this.unitCost,
    required this.byUser,
  });
  final String jobId;
  final String name;
  final int quantity;
  final double? unitCost;
  final String byUser;
  @override
  List<Object?> get props => [jobId, name, quantity, unitCost, byUser];
}

class JobPartRemoved extends JobsEvent {
  const JobPartRemoved({required this.jobId, required this.partId});
  final String jobId;
  final String partId;
  @override
  List<Object?> get props => [jobId, partId];
}

class JobPhotoAdded extends JobsEvent {
  const JobPhotoAdded({
    required this.jobId,
    required this.caption,
    required this.stage,
    required this.byUser,
    this.pendingUpload = false,
  });
  final String jobId;
  final String caption;
  final PhotoStage stage;
  final String byUser;
  final bool pendingUpload;
  @override
  List<Object?> get props => [jobId, caption, stage, byUser, pendingUpload];
}

class JobInspectionToggled extends JobsEvent {
  const JobInspectionToggled({required this.jobId, required this.itemId});
  final String jobId;
  final String itemId;
  @override
  List<Object?> get props => [jobId, itemId];
}
