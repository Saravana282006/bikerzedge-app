import '../models/app_notification.dart';
import '../models/enums.dart';
import '../models/inspection_item.dart';
import '../models/job.dart';
import '../models/motorcycle.dart';
import '../models/photo.dart';
import '../models/spare_part.dart';
import '../models/timeline_event.dart';
import '../models/user.dart';

/// Static seed data for the standalone prototype. In production these come from
/// Firebase Auth (users) and Cloud Firestore (jobs, notifications).
class MockData {
  MockData._();

  static final DateTime _now = DateTime.now();

  static DateTime _ago({int days = 0, int hours = 0, int minutes = 0}) =>
      _now.subtract(Duration(days: days, hours: hours, minutes: minutes));

  // ---------------------------------------------------------------- Users ---
  static const AppUser admin = AppUser(
    id: 'u_admin',
    name: 'Suresh Nair',
    role: UserRole.admin,
    email: 'admin@bikerzedge.com',
    phone: '+91 98400 11223',
  );

  static const AppUser mechRavi = AppUser(
    id: 'u_ravi',
    name: 'Ravi Kumar',
    role: UserRole.mechanic,
    email: 'ravi@bikerzedge.com',
    phone: '+91 90031 44556',
  );

  static const AppUser mechImran = AppUser(
    id: 'u_imran',
    name: 'Imran Shaikh',
    role: UserRole.mechanic,
    email: 'imran@bikerzedge.com',
    phone: '+91 99622 77889',
  );

  static const AppUser mechDivya = AppUser(
    id: 'u_divya',
    name: 'Divya Menon',
    role: UserRole.mechanic,
    email: 'divya@bikerzedge.com',
    phone: '+91 87540 33221',
  );

  static const AppUser mechArjun = AppUser(
    id: 'u_arjun',
    name: 'Arjun Reddy',
    role: UserRole.mechanic,
    email: 'arjun@bikerzedge.com',
    active: false,
    phone: '+91 80560 99001',
  );

  static List<AppUser> users() => const [
        admin,
        mechRavi,
        mechImran,
        mechDivya,
        mechArjun,
      ];

  static List<AppUser> mechanics() =>
      users().where((u) => u.role == UserRole.mechanic).toList();

  static List<InspectionItem> _checklist({List<int> checked = const []}) {
    return [
      for (var i = 0; i < kDefaultInspectionLabels.length; i++)
        InspectionItem(
          id: 'insp_$i',
          label: kDefaultInspectionLabels[i],
          checked: checked.contains(i),
        ),
    ];
  }

  // ----------------------------------------------------------------- Jobs ---
  static List<Job> jobs() => [
        Job(
          id: 'j1',
          code: 'MT-1042',
          ownerName: 'Karthik Raman',
          contact: '+91 98765 43210',
          motorcycle: const Motorcycle(
            make: 'Royal Enfield',
            model: 'Classic 350',
            registration: 'TN 09 BK 4521',
            odometer: 24310,
            year: 2021,
            color: 'Stealth Black',
          ),
          serviceRequest:
              'Engine oil leak near the head; unusual tapping noise at idle.',
          status: JobStatus.repairStarted,
          createdAt: _ago(days: 2, hours: 3),
          assignedToId: mechRavi.id,
          priority: true,
          diagnosis:
              'Head gasket seep confirmed. Tappet clearance out of spec. '
              'Recommend gasket replacement + tappet adjustment.',
          inspection: _checklist(checked: [0, 1, 3, 4, 5, 8, 9]),
          parts: const [
            SparePart(
                id: 'p1', name: 'Head gasket', quantity: 1, unitCost: 480),
            SparePart(
                id: 'p2', name: 'Engine oil 20W-50 (1L)', quantity: 3, unitCost: 620),
          ],
          photos: [
            JobPhoto(
              id: 'ph1',
              caption: 'Oil seep near cylinder head',
              uploadedBy: mechRavi.name,
              uploadedAt: _ago(days: 1, hours: 20),
              stage: PhotoStage.diagnosis,
              seedColor: 0xFF7C2D12,
            ),
            JobPhoto(
              id: 'ph2',
              caption: 'Odometer reading at intake',
              uploadedBy: mechRavi.name,
              uploadedAt: _ago(days: 2, hours: 3),
              stage: PhotoStage.inspection,
              seedColor: 0xFF334155,
            ),
          ],
          timeline: [
            TimelineEvent(
              id: 't1',
              type: TimelineEventType.created,
              byUser: admin.name,
              at: _ago(days: 2, hours: 3),
            ),
            TimelineEvent(
              id: 't2',
              type: TimelineEventType.statusChange,
              byUser: admin.name,
              at: _ago(days: 2, hours: 2, minutes: 40),
              fromStatus: JobStatus.received,
              toStatus: JobStatus.inspection,
            ),
            TimelineEvent(
              id: 't3',
              type: TimelineEventType.assignment,
              byUser: admin.name,
              at: _ago(days: 2, hours: 1),
              note: 'Assigned to Ravi Kumar',
            ),
            TimelineEvent(
              id: 't4',
              type: TimelineEventType.statusChange,
              byUser: mechRavi.name,
              at: _ago(days: 1, hours: 22),
              fromStatus: JobStatus.assigned,
              toStatus: JobStatus.diagnosis,
            ),
            TimelineEvent(
              id: 't5',
              type: TimelineEventType.note,
              byUser: mechRavi.name,
              at: _ago(days: 1, hours: 20),
              note: 'Confirmed head gasket seep after cleaning the area.',
            ),
            TimelineEvent(
              id: 't6',
              type: TimelineEventType.statusChange,
              byUser: mechRavi.name,
              at: _ago(hours: 6),
              fromStatus: JobStatus.diagnosis,
              toStatus: JobStatus.repairStarted,
            ),
          ],
          notes: const [
            'Customer requested a call before ordering any part above ₹1000.',
          ],
        ),
        Job(
          id: 'j2',
          code: 'MT-1043',
          ownerName: 'Meera Iyer',
          contact: '+91 91234 56780',
          motorcycle: const Motorcycle(
            make: 'Honda',
            model: 'Activa 6G',
            registration: 'TN 07 CE 8890',
            odometer: 18760,
            year: 2022,
            color: 'Pearl White',
          ),
          serviceRequest: 'General service + front brake feels spongy.',
          status: JobStatus.waitingForParts,
          createdAt: _ago(days: 1, hours: 6),
          assignedToId: mechImran.id,
          diagnosis:
              'Brake shoes worn beyond limit. Awaiting genuine brake shoe set.',
          inspection: _checklist(checked: [0, 3, 4, 5, 6, 9]),
          parts: const [
            SparePart(id: 'p3', name: 'Brake shoe set', quantity: 1, unitCost: 340),
            SparePart(id: 'p4', name: 'Air filter', quantity: 1, unitCost: 210),
          ],
          photos: [
            JobPhoto(
              id: 'ph3',
              caption: 'Worn brake shoe',
              uploadedBy: mechImran.name,
              uploadedAt: _ago(hours: 20),
              stage: PhotoStage.diagnosis,
              seedColor: 0xFF1E3A8A,
              pendingUpload: true,
            ),
          ],
          timeline: [
            TimelineEvent(
              id: 't7',
              type: TimelineEventType.created,
              byUser: admin.name,
              at: _ago(days: 1, hours: 6),
            ),
            TimelineEvent(
              id: 't8',
              type: TimelineEventType.assignment,
              byUser: admin.name,
              at: _ago(days: 1, hours: 5),
              note: 'Assigned to Imran Shaikh',
            ),
            TimelineEvent(
              id: 't9',
              type: TimelineEventType.statusChange,
              byUser: mechImran.name,
              at: _ago(hours: 22),
              fromStatus: JobStatus.diagnosis,
              toStatus: JobStatus.waitingForParts,
            ),
          ],
        ),
        Job(
          id: 'j3',
          code: 'MT-1044',
          ownerName: 'Vikram Singh',
          contact: '+91 99887 66554',
          motorcycle: const Motorcycle(
            make: 'Bajaj',
            model: 'Pulsar NS200',
            registration: 'TN 22 AA 1200',
            odometer: 31240,
            year: 2020,
            color: 'Racing Red',
          ),
          serviceRequest: 'Chain noise and gear shifting hard.',
          status: JobStatus.received,
          createdAt: _ago(hours: 4),
          inspection: _checklist(),
          timeline: [
            TimelineEvent(
              id: 't10',
              type: TimelineEventType.created,
              byUser: admin.name,
              at: _ago(hours: 4),
            ),
          ],
        ),
        Job(
          id: 'j4',
          code: 'MT-1039',
          ownerName: 'Anitha Rao',
          contact: '+91 90000 12345',
          motorcycle: const Motorcycle(
            make: 'TVS',
            model: 'Apache RTR 160',
            registration: 'TN 10 BZ 7788',
            odometer: 42890,
            year: 2019,
            color: 'Gloss Black',
          ),
          serviceRequest: 'Full service, clutch replacement.',
          status: JobStatus.readyForDelivery,
          createdAt: _ago(days: 4, hours: 2),
          assignedToId: mechDivya.id,
          diagnosis: 'Clutch plates replaced, cable adjusted, road tested OK.',
          inspection: _checklist(checked: [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10]),
          parts: const [
            SparePart(
                id: 'p5', name: 'Clutch plate set', quantity: 1, unitCost: 890),
            SparePart(
                id: 'p6', name: 'Clutch cable', quantity: 1, unitCost: 160),
            SparePart(
                id: 'p7', name: 'Engine oil 10W-30 (1L)', quantity: 2, unitCost: 540),
          ],
          photos: [
            JobPhoto(
              id: 'ph4',
              caption: 'Old clutch plates',
              uploadedBy: mechDivya.name,
              uploadedAt: _ago(days: 3, hours: 5),
              stage: PhotoStage.repair,
              seedColor: 0xFF166534,
            ),
            JobPhoto(
              id: 'ph5',
              caption: 'Post road-test check',
              uploadedBy: mechDivya.name,
              uploadedAt: _ago(days: 1),
              stage: PhotoStage.delivery,
              seedColor: 0xFF115E59,
            ),
          ],
          timeline: [
            TimelineEvent(
              id: 't11',
              type: TimelineEventType.created,
              byUser: admin.name,
              at: _ago(days: 4, hours: 2),
            ),
            TimelineEvent(
              id: 't12',
              type: TimelineEventType.statusChange,
              byUser: mechDivya.name,
              at: _ago(days: 1),
              fromStatus: JobStatus.testing,
              toStatus: JobStatus.readyForDelivery,
            ),
          ],
        ),
        Job(
          id: 'j5',
          code: 'MT-1030',
          ownerName: 'Prakash Babu',
          contact: '+91 93333 44556',
          motorcycle: const Motorcycle(
            make: 'Yamaha',
            model: 'FZ-S',
            registration: 'TN 01 CX 5643',
            odometer: 27650,
            year: 2021,
            color: 'Matte Blue',
          ),
          serviceRequest: 'Periodic service + headlight not working.',
          status: JobStatus.closed,
          createdAt: _ago(days: 8),
          closedAt: _ago(days: 6, hours: 4),
          assignedToId: mechRavi.id,
          diagnosis: 'Headlight bulb + relay replaced. Service completed.',
          inspection: _checklist(checked: [0, 1, 3, 4, 5, 6, 8, 9, 10]),
          parts: const [
            SparePart(id: 'p8', name: 'Headlight bulb H4', quantity: 1, unitCost: 240),
            SparePart(id: 'p9', name: 'Relay', quantity: 1, unitCost: 180),
          ],
          photos: [
            JobPhoto(
              id: 'ph6',
              caption: 'Delivery-ready',
              uploadedBy: mechRavi.name,
              uploadedAt: _ago(days: 6, hours: 5),
              stage: PhotoStage.delivery,
              seedColor: 0xFF3F3F46,
            ),
          ],
          timeline: [
            TimelineEvent(
              id: 't13',
              type: TimelineEventType.created,
              byUser: admin.name,
              at: _ago(days: 8),
            ),
            TimelineEvent(
              id: 't14',
              type: TimelineEventType.statusChange,
              byUser: admin.name,
              at: _ago(days: 6, hours: 4),
              fromStatus: JobStatus.readyForDelivery,
              toStatus: JobStatus.closed,
            ),
          ],
        ),
        Job(
          id: 'j6',
          code: 'MT-1045',
          ownerName: 'Fatima Bi',
          contact: '+91 96500 88221',
          motorcycle: const Motorcycle(
            make: 'Suzuki',
            model: 'Access 125',
            registration: 'TN 04 DD 3322',
            odometer: 9820,
            year: 2023,
            color: 'Metallic Grey',
          ),
          serviceRequest: 'First free service.',
          status: JobStatus.assigned,
          createdAt: _ago(hours: 2),
          assignedToId: mechImran.id,
          inspection: _checklist(checked: [0]),
          timeline: [
            TimelineEvent(
              id: 't15',
              type: TimelineEventType.created,
              byUser: admin.name,
              at: _ago(hours: 2),
            ),
            TimelineEvent(
              id: 't16',
              type: TimelineEventType.assignment,
              byUser: admin.name,
              at: _ago(hours: 1),
              note: 'Assigned to Imran Shaikh',
            ),
          ],
        ),
      ];

  // -------------------------------------------------------- Notifications ---
  static List<AppNotification> notifications() => [
        AppNotification(
          id: 'n1',
          toUserId: mechRavi.id,
          message: 'Job MT-1042 (Royal Enfield Classic 350) assigned to you.',
          jobId: 'j1',
          createdAt: _ago(days: 2, hours: 1),
          read: true,
        ),
        AppNotification(
          id: 'n2',
          toUserId: mechImran.id,
          message: 'Job MT-1045 (Suzuki Access 125) assigned to you.',
          jobId: 'j6',
          createdAt: _ago(hours: 1),
        ),
        AppNotification(
          id: 'n3',
          toUserId: admin.id,
          message: 'MT-1039 moved to Ready for Delivery by Divya Menon.',
          jobId: 'j4',
          createdAt: _ago(days: 1),
        ),
        AppNotification(
          id: 'n4',
          toUserId: admin.id,
          message: 'MT-1043 is Waiting for Parts (brake shoe set).',
          jobId: 'j2',
          createdAt: _ago(hours: 22),
          read: true,
        ),
      ];
}
