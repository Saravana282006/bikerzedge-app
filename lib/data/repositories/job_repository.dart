import '../../core/utils/id_generator.dart';
import '../models/app_notification.dart';
import '../models/enums.dart';
import '../models/inspection_item.dart';
import '../models/job.dart';
import '../models/motorcycle.dart';
import '../models/photo.dart';
import '../models/spare_part.dart';
import '../models/timeline_event.dart';
import '../models/user.dart';
import 'mock_data.dart';

/// In-memory data store for jobs, staff and notifications.
///
/// Every method returns after a short simulated delay so the UI exercises its
/// loading states. Swap this class for Firestore-backed queries later — the
/// method signatures are what the Blocs depend on.
class JobRepository {
  final List<Job> _jobs = MockData.jobs();
  final List<AppUser> _users = MockData.users();
  final List<AppNotification> _notifications = MockData.notifications();

  int _codeSeq = 1046;

  Future<void> _tick() =>
      Future<void>.delayed(const Duration(milliseconds: 350));

  // ------------------------------------------------------------- Queries ---
  Future<List<Job>> fetchJobs() async {
    await _tick();
    return List.unmodifiable(_sorted(_jobs));
  }

  List<Job> _sorted(List<Job> jobs) {
    final copy = [...jobs];
    copy.sort((a, b) {
      if (a.priority != b.priority) return a.priority ? -1 : 1;
      return b.createdAt.compareTo(a.createdAt);
    });
    return copy;
  }

  List<AppUser> get users => List.unmodifiable(_users);

  List<AppUser> get mechanics =>
      _users.where((u) => u.role == UserRole.mechanic).toList();

  AppUser? userById(String? id) {
    if (id == null) return null;
    for (final u in _users) {
      if (u.id == id) return u;
    }
    return null;
  }

  Job _byId(String id) => _jobs.firstWhere((j) => j.id == id);

  int _indexOf(String id) => _jobs.indexWhere((j) => j.id == id);

  // ------------------------------------------------------------ Mutations ---
  Future<Job> createJob({
    required String ownerName,
    required String contact,
    required Motorcycle motorcycle,
    required String serviceRequest,
    bool priority = false,
    required String byUser,
  }) async {
    await _tick();
    final now = DateTime.now();
    final id = IdGenerator.next('j');
    final code = 'MT-${_codeSeq++}';
    final job = Job(
      id: id,
      code: code,
      ownerName: ownerName,
      contact: contact,
      motorcycle: motorcycle,
      serviceRequest: serviceRequest,
      status: JobStatus.received,
      createdAt: now,
      priority: priority,
      inspection: [
        for (var i = 0; i < kDefaultInspectionLabels.length; i++)
          InspectionItem(id: 'insp_${id}_$i', label: kDefaultInspectionLabels[i]),
      ],
      timeline: [
        TimelineEvent(
          id: IdGenerator.next('t'),
          type: TimelineEventType.created,
          byUser: byUser,
          at: now,
        ),
      ],
    );
    _jobs.add(job);
    return job;
  }

  Future<Job> assignJob({
    required String jobId,
    required String mechanicId,
    required String byUser,
  }) async {
    await _tick();
    final job = _byId(jobId);
    final mech = userById(mechanicId);
    final now = DateTime.now();
    final events = [
      ...job.timeline,
      TimelineEvent(
        id: IdGenerator.next('t'),
        type: TimelineEventType.assignment,
        byUser: byUser,
        at: now,
        note: 'Assigned to ${mech?.name ?? 'mechanic'}',
      ),
    ];
    // Assigning also advances a fresh/inspection job to 'assigned'.
    final newStatus = job.status.index < JobStatus.assigned.index
        ? JobStatus.assigned
        : job.status;
    if (newStatus != job.status) {
      events.add(TimelineEvent(
        id: IdGenerator.next('t'),
        type: TimelineEventType.statusChange,
        byUser: byUser,
        at: now,
        fromStatus: job.status,
        toStatus: newStatus,
      ));
    }
    final updated = job.copyWith(
      assignedToId: mechanicId,
      status: newStatus,
      timeline: events,
    );
    _jobs[_indexOf(jobId)] = updated;

    _notify(
      toUserId: mechanicId,
      jobId: jobId,
      message: '${job.code} (${job.motorcycle.displayName}) assigned to you.',
    );
    return updated;
  }

  Future<Job> changeStatus({
    required String jobId,
    required JobStatus newStatus,
    required String byUser,
    String? note,
  }) async {
    await _tick();
    final job = _byId(jobId);
    final now = DateTime.now();
    final updated = job.copyWith(
      status: newStatus,
      closedAt: newStatus == JobStatus.closed ? now : null,
      clearClosedAt: newStatus != JobStatus.closed && job.closedAt != null,
      timeline: [
        ...job.timeline,
        TimelineEvent(
          id: IdGenerator.next('t'),
          type: TimelineEventType.statusChange,
          byUser: byUser,
          at: now,
          fromStatus: job.status,
          toStatus: newStatus,
          note: note,
        ),
      ],
    );
    _jobs[_indexOf(jobId)] = updated;

    // Notify admins of noteworthy transitions.
    if (newStatus == JobStatus.readyForDelivery ||
        newStatus == JobStatus.waitingForParts) {
      for (final admin in _users.where((u) => u.role == UserRole.admin)) {
        _notify(
          toUserId: admin.id,
          jobId: jobId,
          message: '${job.code} moved to ${newStatus.label} by $byUser.',
        );
      }
    }
    return updated;
  }

  Future<Job> addNote({
    required String jobId,
    required String note,
    required String byUser,
  }) async {
    await _tick();
    final job = _byId(jobId);
    final updated = job.copyWith(
      notes: [...job.notes, note],
      timeline: [
        ...job.timeline,
        TimelineEvent(
          id: IdGenerator.next('t'),
          type: TimelineEventType.note,
          byUser: byUser,
          at: DateTime.now(),
          note: note,
        ),
      ],
    );
    _jobs[_indexOf(jobId)] = updated;
    return updated;
  }

  Future<Job> setDiagnosis({
    required String jobId,
    required String diagnosis,
    required String byUser,
  }) async {
    await _tick();
    final job = _byId(jobId);
    final updated = job.copyWith(
      diagnosis: diagnosis,
      timeline: [
        ...job.timeline,
        TimelineEvent(
          id: IdGenerator.next('t'),
          type: TimelineEventType.note,
          byUser: byUser,
          at: DateTime.now(),
          note: 'Diagnosis updated',
        ),
      ],
    );
    _jobs[_indexOf(jobId)] = updated;
    return updated;
  }

  Future<Job> addPart({
    required String jobId,
    required String name,
    required int quantity,
    double? unitCost,
    required String byUser,
  }) async {
    await _tick();
    final job = _byId(jobId);
    final part = SparePart(
      id: IdGenerator.next('p'),
      name: name,
      quantity: quantity,
      unitCost: unitCost,
    );
    final updated = job.copyWith(
      parts: [...job.parts, part],
      timeline: [
        ...job.timeline,
        TimelineEvent(
          id: IdGenerator.next('t'),
          type: TimelineEventType.part,
          byUser: byUser,
          at: DateTime.now(),
          note: 'Logged part: $name ×$quantity',
        ),
      ],
    );
    _jobs[_indexOf(jobId)] = updated;
    return updated;
  }

  Future<Job> removePart({
    required String jobId,
    required String partId,
  }) async {
    await _tick();
    final job = _byId(jobId);
    final updated = job.copyWith(
      parts: job.parts.where((p) => p.id != partId).toList(),
    );
    _jobs[_indexOf(jobId)] = updated;
    return updated;
  }

  Future<Job> addPhoto({
    required String jobId,
    required String caption,
    required PhotoStage stage,
    required String byUser,
    int seedColor = 0xFF334155,
    bool pendingUpload = false,
  }) async {
    await _tick();
    final job = _byId(jobId);
    final photo = JobPhoto(
      id: IdGenerator.next('ph'),
      caption: caption,
      uploadedBy: byUser,
      uploadedAt: DateTime.now(),
      stage: stage,
      seedColor: seedColor,
      pendingUpload: pendingUpload,
    );
    final updated = job.copyWith(
      photos: [...job.photos, photo],
      timeline: [
        ...job.timeline,
        TimelineEvent(
          id: IdGenerator.next('t'),
          type: TimelineEventType.photo,
          byUser: byUser,
          at: DateTime.now(),
          note: '${stage.label} photo: $caption',
        ),
      ],
    );
    _jobs[_indexOf(jobId)] = updated;
    return updated;
  }

  Future<Job> toggleInspectionItem({
    required String jobId,
    required String itemId,
  }) async {
    await _tick();
    final job = _byId(jobId);
    final updated = job.copyWith(
      inspection: [
        for (final item in job.inspection)
          if (item.id == itemId) item.copyWith(checked: !item.checked) else item,
      ],
    );
    _jobs[_indexOf(jobId)] = updated;
    return updated;
  }

  Future<Job> setInspectionRemark({
    required String jobId,
    required String itemId,
    required String remark,
  }) async {
    await _tick();
    final job = _byId(jobId);
    final updated = job.copyWith(
      inspection: [
        for (final item in job.inspection)
          if (item.id == itemId) item.copyWith(remark: remark) else item,
      ],
    );
    _jobs[_indexOf(jobId)] = updated;
    return updated;
  }

  // ----------------------------------------------------- Notifications ---
  void _notify({
    required String toUserId,
    required String jobId,
    required String message,
  }) {
    _notifications.insert(
      0,
      AppNotification(
        id: IdGenerator.next('n'),
        toUserId: toUserId,
        message: message,
        jobId: jobId,
        createdAt: DateTime.now(),
      ),
    );
  }

  Future<List<AppNotification>> fetchNotifications(String userId) async {
    await _tick();
    final list = _notifications.where((n) => n.toUserId == userId).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return List.unmodifiable(list);
  }

  Future<void> markNotificationRead(String notificationId) async {
    final idx = _notifications.indexWhere((n) => n.id == notificationId);
    if (idx != -1) {
      _notifications[idx] = _notifications[idx].copyWith(read: true);
    }
  }

  Future<void> markAllNotificationsRead(String userId) async {
    for (var i = 0; i < _notifications.length; i++) {
      if (_notifications[i].toUserId == userId && !_notifications[i].read) {
        _notifications[i] = _notifications[i].copyWith(read: true);
      }
    }
  }
}
