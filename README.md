# EduApp — Flutter Multi-Screen Authentication App

## Project Overview

A complete multi-screen Flutter application featuring user authentication, form validation, navigation, and clean architecture. Built for the Mobile App Development assignment.

## Features

### Screens
| Screen | Description |
|--------|-------------|
| **Splash** | Branded loading screen; auto-restores saved session |
| **Register** | Full registration form with real-time validation |
| **Login** | Email/password login with show/hide toggle & Remember Me |
| **Dashboard** | Displays user info, avatar, and subject list |
| **Detail** | Full subject details — description, schedule, room |

### Key Requirements Met
- ✅ Real-time form validation (all fields)
- ✅ Password strength indicator
- ✅ Confirm password match check
- ✅ Submit button disabled until form is valid
- ✅ Show/hide password toggle (eye icon)
- ✅ Remember Me — persists session via `SharedPreferences`
- ✅ Gender dropdown using `Gender` enum
- ✅ `AuthState` enum for state management
- ✅ Reusable `AppValidator` class (fully decoupled from UI)
- ✅ `AuthController` separates all business logic from UI
- ✅ Navigation with data passing between screens
- ✅ Logout clears session and returns to Login

---

## Architecture

```
lib/
├── main.dart                        # Entry point
├── app_theme.dart                   # Colors, theme, design tokens
├── enums/
│   └── app_enums.dart               # Gender, AuthState, SubjectId enums
├── models/
│   ├── user_model.dart              # UserModel with toMap/fromMap
│   └── subject_model.dart          # Subject model + static catalogue
├── validators/
│   └── app_validator.dart          # ✅ Reusable validator class (no UI)
├── controllers/
│   └── auth_controller.dart        # ✅ All auth logic (no UI code)
├── widgets/
│   └── app_widgets.dart            # Shared reusable widgets
└── screens/
    ├── splash_screen.dart
    ├── register_screen.dart
    ├── login_screen.dart
    ├── dashboard_screen.dart
    └── detail_screen.dart
```

---

## Getting Started

### Prerequisites

| Tool | Version |
|------|---------|
| Flutter SDK | ≥ 3.0.0 |
| Dart SDK | ≥ 3.0.0 |
| Android Studio / VS Code | Latest |
| Android Emulator or physical device | Any |

### Installation & Run

```bash
# 1. Clone the repo
git clone <your-repo-url>
cd edu_app

# 2. Install dependencies
flutter pub get

# 3. Run on connected device or emulator
flutter run

# 4. Run unit tests
flutter test
```

---

## Dependencies

```yaml
provider: ^6.1.2          # State management
shared_preferences: ^2.2.3 # Session persistence
http: ^1.2.0              # (Ready for API integration)
```

---

## How to Use the App

1. **Launch** → Splash screen appears, checks for saved session
2. **Register** → Fill in all fields → tap **Create Account**
3. **Login** → Enter the same email/password → tap **Sign In**
4. **Dashboard** → See your name, avatar, and 3 subjects
5. **Tap a subject** → View description, schedule, and room
6. **Logout** → Returns to Login screen and clears session

---

## Screenshots

> *(Add screenshots to a `screenshots/` folder and reference them here after running the app)*

| Register | Login | Dashboard | Detail |
|----------|-------|-----------|--------|
| ![Register](screenshots/register.png) | ![Login](screenshots/login.png) | ![Dashboard](screenshots/dashboard.png) | ![Detail](screenshots/detail.png) |

---

## Notes

- The app uses an **in-memory user store** — registered users persist only for the lifetime of the app process. For production, replace with a backend API.
- `SharedPreferences` persists the session (name, email, gender) across restarts when **Remember Me** is checked. The password is never stored.
