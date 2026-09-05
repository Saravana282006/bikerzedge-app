# MotoTrack — Workshop Job Tracker (BIKERZEDGE)

An interactive **Flutter** prototype of MotoTrack, the internal Android app for a
motorcycle workshop to receive, assign, track and close service jobs. Built from
`MotoTrack_Mobile_App_PRD_v1.2` for client review.

This build is a **standalone, click-through prototype**: it runs entirely on
**in-memory mock data** — no Firebase or backend setup required. The data layer
is behind clean repository interfaces so a real Firebase (Auth + Firestore +
Storage) implementation can be dropped in later without touching the UI or state
logic.

State management is **Bloc** (`flutter_bloc`), as agreed.

---

## Run it

```bash
# 1. Add platform scaffolding (android/ios/web) to this source tree — one time.
flutter create .

# 2. Fetch packages and launch on an emulator, device or Chrome.
flutter pub get
flutter run           # or: flutter run -d chrome
```

Verify the code at any time:

```bash
flutter analyze       # 0 issues
flutter test          # widget smoke tests for the core flows
```

### Demo logins
The login screen has one-tap buttons. Or sign in with any of these emails and any
non-empty password:

| Role     | Email                   |
|----------|-------------------------|
| Admin    | `admin@bikerzedge.com`  |
| Mechanic | `ravi@bikerzedge.com`   |
| Mechanic | `imran@bikerzedge.com`  |
| Mechanic | `divya@bikerzedge.com`  |

---

## What the prototype demonstrates (PRD core features)

- **Role-based login** routing to the correct dashboard (Admin vs Mechanic).
- **Admin dashboard** — workshop-wide counts by status, priority & recent jobs.
- **Mechanic dashboard** — only the jobs assigned to that mechanic.
- **Create job** — owner, motorcycle & service details (fast intake flow).
- **Assign / reassign** a job to a mechanic (with an in-app notification).
- **Job status workflow** — the full 10-stage lifecycle, with role rules
  (mechanics advance their jobs; only Admin closes).
- **Inspection checklist** with per-item check + progress.
- **Mechanic workspace** — diagnosis, notes, photos and spare parts in one place.
- **Spare parts** — per-job logging and a workshop-wide parts view with totals.
- **Job timeline** — chronological, timestamped history of every action.
- **Search & filters** — by registration, owner, code, status and mechanic.
- **Reports** — jobs by status, mechanic workload, throughput.
- **In-app notifications** — assignment and status-change alerts with unread badge.
- **Offline cue** — photos can be "captured offline" and show a queued-to-sync state.
- **Responsive layout** — bottom navigation on phones, a side rail on tablets/wide.

---

## Architecture

Feature-first structure with a clear data → bloc → UI separation.

```
lib/
  main.dart                 App entry
  app.dart                  Repositories + Blocs wiring, auth-gated root
  core/
    theme/                  BIKERZEDGE brand palette + Material 3 theme
    utils/                  Formatters, id generator
  data/
    models/                 Job, Motorcycle, User, SparePart, Photo, Timeline… (+ enums)
    repositories/           AuthRepository, JobRepository (in-memory), MockData seed
  blocs/
    auth/                   AuthBloc — sign in / demo login / sign out
    jobs/                   JobsBloc — list, filters, and all job mutations
    notifications/          NotificationsBloc — in-app alerts + unread count
  widgets/                  Shared UI: StatusChip, JobCard, StatCard, avatars…
  features/
    auth/                   Login
    shell/                  Responsive role-based navigation shell
    dashboard/              Admin & Mechanic dashboards
    jobs/                   List, create, detail (workspace/timeline), inspection
    mechanics/ reports/ spare_parts/ notifications/ profile/
test/
  smoke_test.dart           Widget tests covering the core user flows
```

### Swapping in Firebase later
Replace the bodies of `AuthRepository` and `JobRepository` with Firebase calls
(Auth + Firestore + Storage). The method signatures the Blocs depend on stay the
same, so the state and UI layers are unaffected. Firestore's built-in offline
persistence maps directly onto the offline requirement; photos move to Cloud
Storage with queued upload; roles are enforced with custom claims + security
rules, matching PRD §5 and §12.

---

## Notes & scope

- **Photos** are represented as labelled placeholder tiles (no device camera in a
  headless prototype); the capture/attach flow, stages and offline-queue state are
  all wired up. Real capture uses `image_picker` + `flutter_image_compress`.
- Out of scope per the PRD: customer-facing screens, payments/invoicing, full
  inventory, multi-branch, iOS, and app-store publishing.

_Prototype v1.0 · Flutter + Bloc · mock data._
