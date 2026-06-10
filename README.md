# EduApp — Flutter Multi-Screen Authentication + CRUD API App

A complete Flutter mobile application featuring user authentication, form validation, navigation, and full CRUD operations using the JSONPlaceholder REST API.

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
   git checkout feature/course-api-integration
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
| `provider` | ^6.1.2 | State management |
| `shared_preferences` | ^2.2.3 | Session persistence for Remember Me |
| `http` | ^1.2.0 | REST API calls |

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
│   └── course_service.dart           # All HTTP calls, no UI code
├── providers/
│   └── course_provider.dart          # loading / success / error states
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

## State Management

`CourseProvider` handles three states using the `CourseStatus` enum:

| State | Description |
|-------|-------------|
| `loading` | Shows CircularProgressIndicator |
| `success` | Renders data or navigates back |
| `error` | Shows error message with Retry button |

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