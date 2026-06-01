// ── Gender ────────────────────────────────────────────────────────────────────
enum Gender {
  male,
  female,
  preferNotToSay;

  String get label {
    switch (this) {
      case Gender.male:
        return 'Male';
      case Gender.female:
        return 'Female';
      case Gender.preferNotToSay:
        return 'Prefer not to say';
    }
  }
}

// ── Auth state ────────────────────────────────────────────────────────────────
enum AuthState {
  unauthenticated,
  loading,
  authenticated,
  error,
}

// ── Subject IDs ───────────────────────────────────────────────────────────────
enum SubjectId {
  mobileAppDev,
  softwareReengineering,
  mis,
}