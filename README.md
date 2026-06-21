# EduApp — Flutter Multi-Screen Authentication + CRUD API App

A complete Flutter mobile application featuring user authentication, form validation, navigation, and full CRUD operations using the JSONPlaceholder REST API.

> **Extension update — Offline Support & State Management Upgrade**
> This branch (`feature/offline-cache-and-state-manangement`) adds an offline-first
> architecture: courses are cached locally with **Hive**, served from cache when the
> device is offline, fetched from the API when online, and all create/update/delete
> actions use **optimistic UI updates with rollback**. The data flow now follows a clean
> **Repository pattern**: `UI → Provider (state) → Repository → API service / Local storage`.

**Branch:** `feature/offline-cache-and-state-manangement`

---

## API Used

**JSONPlaceholder** — Free fake REST API for testing and development
- Base URL: `https://jsonplaceholder.typicode.com`
- Endpoint: `/posts` (used as courses)

### Documentation Followed
> https://jsonplaceholder.typicode.com/guide

### API Endpoints Implemented

| Method | Endpoint | Action |
|--------|----------|--------|
| GET | `/posts` | Fetch all courses |
| POST | `/posts` | Create a new course |
| PUT | `/posts/:id` | Update an existing course |
| DELETE | `/posts/:id` | Delete a course |

---

## Prerequisites

- Flutter SDK >= 3.0.0
- Dart SDK >= 3.0.0
- VS Code with Flutter plugin
- Android emulator or physical device
- Active internet connection (for API calls)

---

## Installation

1. Clone the repository
   ```bash
   git clone <your-repo-url>
   ```

2. Switch to the feature branch
   ```bash
   git checkout feature/offline-cache-and-state-manangement
   ```

3. Install dependencies
   ```bash
   flutter pub get
   ```

4. Run the app
   ```bash
   flutter run
   ```

5. Run tests
   ```bash
   flutter test
   ```

---

## Dependencies

| Package | Version | Purpose |
|---------|---------|---------|
| `provider` | ^6.1.2 | State management (UI state control) |
| `http` | ^1.2.0 | REST API calls |
| `hive` | ^2.2.3 | Local NoSQL database for offline course cache |
| `hive_flutter` | ^1.1.0 | Flutter bindings + `Hive.initFlutter()` |
| `connectivity_plus` | ^6.1.0 | Detect online/offline state |
| `shared_preferences` | ^2.2.3 | Session persistence for Remember Me |

---

## Screens

| Screen | Description |
|--------|-------------|
| Splash | Animated launch screen, restores saved session |
| Register | Full registration form with real-time validation |
| Login | Email/password login with show/hide toggle and Remember Me |
| Dashboard | Displays user info, subjects, and API courses entry |
| Subject Detail | Shows subject description, schedule, and room |
| Course List | Fetches and displays courses from JSONPlaceholder API |
| Course Form | Shared form screen for creating and editing courses |
| Course Detail | Full course view with edit and delete options |

---

## Validation Rules

| Field | Rules |
|-------|-------|
| First Name | Required, min 2 characters |
| Last Name | Required, min 2 characters |
| Email | Required, valid email format |
| Gender | Required selection |
| Password | Required, min 6 chars, 1 uppercase, 1 special character |
| Confirm Password | Required, must match password |
| Login Email | Required, valid email format |
| Login Password | Required, non-empty |
| Course Title | Required, min 3 characters |
| Course Description | Required, min 10 characters |

---

## Architecture

```
lib/
├── main.dart                         # MultiProvider entry point
├── app_theme.dart                    # Colors, theme, design tokens
├── enums/
│   └── app_enums.dart                # Gender, AuthState, SubjectId
├── models/
│   ├── user_model.dart               # User data model
│   ├── subject_model.dart            # Subject catalogue
│   └── course_model.dart             # Course model (fromJson/toJson)
├── services/
│   ├── course_service.dart           # All HTTP calls only, no UI/storage code
│   ├── course_local_storage.dart     # Hive offline cache (save/load courses)
│   └── connectivity_service.dart     # Online/offline detection
├── repositories/
│   └── course_repository.dart        # Decides API vs local cache; sync logic
├── providers/
│   └── course_provider.dart          # UI state + optimistic updates + search
├── controllers/
│   └── auth_controller.dart          # Authentication business logic
├── validators/
│   └── app_validator.dart            # Reusable validator class
├── widgets/
│   └── app_widgets.dart              # Shared reusable UI components
└── screens/
    ├── splash_screen.dart
    ├── register_screen.dart
    ├── login_screen.dart
    ├── dashboard_screen.dart
    ├── detail_screen.dart
    ├── course_list_screen.dart
    ├── course_form_screen.dart
    └── course_detail_screen.dart
```

---

## Architecture Layers (Repository Pattern)

The app follows a strict separation of concerns:

```
UI (screens/widgets)
        │   reads state, dispatches actions
        ▼
State Management  →  CourseProvider (ChangeNotifier)
        │   no HTTP, no storage — only UI state
        ▼
Repository        →  CourseRepository
        │   decides: API when online, cache when offline; keeps cache in sync
        ├─────────────► API Service     (CourseService)        — HTTP only
        └─────────────► Local Database   (CourseLocalStorage)   — Hive only
                          ▲
                          └── ConnectivityService — "are we online?"
```

| Layer | File | Responsibility |
|-------|------|----------------|
| API service | `services/course_service.dart` | Only performs HTTP requests; throws `ApiException` |
| Local storage | `services/course_local_storage.dart` | Only reads/writes the Hive cache + last-sync time |
| Connectivity | `services/connectivity_service.dart` | Reports online/offline |
| Repository | `repositories/course_repository.dart` | Chooses API vs cache, refreshes the cache |
| State | `providers/course_provider.dart` | Loading/success/error/empty + optimistic updates + search |

---

## State Management

State is managed with **Provider** (`CourseProvider`, a `ChangeNotifier`). `setState`
is not used for course data — the UI only listens to the provider. All four states are
handled explicitly via the `CourseStatus` enum:

| State | Description |
|-------|-------------|
| `loading` | Spinner shown only on the *first* load (cached data is shown instantly on later loads) |
| `success` | Renders the list (or the offline banner over the list) |
| `error` | Full-screen error + Retry, shown only when there is no cached data to fall back on |
| empty | Distinguishes "no courses yet" from "no search results" |

The provider also exposes `isFromCache`, `lastSync`, and the search `query`, keeping all
UI logic out of the widgets.

---

## Offline Support

Course data is cached locally with **Hive** after every successful API response. The list
is serialised to a single JSON string (no `TypeAdapter`/code-gen needed) and stored with a
`last_sync` timestamp.

On load, `CourseRepository.getCourses()`:

1. Checks connectivity via `ConnectivityService`.
2. **Online** → fetches from the API and refreshes the Hive cache.
3. **Offline** (or a failed request) → returns the cached copy and flags it `fromCache`.

When serving cached data, the Course List shows an **offline banner** with the last sync
time. Once connectivity returns, a refresh re-fetches from the API and the cache is
re-synchronised. Every create/update/delete also writes the updated list back to the cache,
so the offline copy always stays correct.

---

## Optimistic UI Updates

Create, update, and delete update the UI **immediately**, before the network responds:

- **Delete** — the row disappears at once; if the API call fails it is **restored to its
  original position** and an error snackbar is shown.
- **Update** — the edited values render instantly; on failure the previous values are
  **rolled back**.
- **Create** — a placeholder card appears immediately and is swapped for the server's
  response (or **removed** if the request fails).

This keeps the UI responsive and is implemented entirely in `CourseProvider` so the widgets
stay simple.

---

## UX Improvements

- **Pull-to-refresh** on the course list (`RefreshIndicator`).
- **Search/filter** courses by title or description in real time.
- **Offline banner** showing cached state + last sync time.
- Proper **empty states** ("no courses yet" vs "no search results").
- Loading spinner only blocks the screen on first load, not on background refreshes.

---

## Screenshots

> Add screenshots/GIFs here after running the app (`flutter run`):

| Course List (online) | Offline banner (cached) | Search / filter |
|----------------------|-------------------------|-----------------|
| _screenshot_ | _screenshot_ | _screenshot_ |

| Add / Edit course | Optimistic delete | Empty state |
|-------------------|-------------------|-------------|
| _screenshot_ | _screenshot_ | _screenshot_ |

Place image files under `assets/images/` (or `docs/`) and reference them like:
`![Course List](docs/course_list.png)`

---

## CRUD Flow

1. **Read** — App opens Course List → GET /posts → displays 20 courses
2. **Create** — Tap Add Course → fill form → POST /posts → inserted at top of list
3. **Update** — Tap edit icon → pre-filled form → PUT /posts/:id → list updated
4. **Delete** — Tap delete icon → confirmation dialog → DELETE /posts/:id → removed from list

---

## Notes

- JSONPlaceholder is a fake API — data is not actually persisted on the server but all responses (201, 200) are returned correctly and the UI reflects all changes locally.
- The app uses an in-memory user store — registered users exist only for the lifetime of the app session.
- Passwords are never stored to disk. Only name, email, and gender are saved via SharedPreferences when Remember Me is checked.
