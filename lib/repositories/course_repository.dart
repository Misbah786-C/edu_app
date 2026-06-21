import '../models/course_model.dart';
import '../services/course_service.dart';
import '../services/course_local_storage.dart';
import '../services/connectivity_service.dart';

/// Wraps the data returned by the repository together with metadata the UI
/// cares about: whether it came from the offline cache, and when the cache
/// was last refreshed from the network.
class CoursesResult {
  final List<Course> data;
  final bool fromCache;
  final DateTime? lastSync;

  const CoursesResult(
    this.data, {
    this.fromCache = false,
    this.lastSync,
  });
}

/// The single source of truth for course data.
///
///   UI → Provider → **Repository** → API service / Local storage
///
/// The repository decides *where* data comes from:
///  • Online  → fetch from the API, then refresh the local cache.
///  • Offline → (or on a failed request) fall back to the cached copy.
///
/// The [CourseService] only performs HTTP; [CourseLocalStorage] only performs
/// local persistence. This class is the only place that knows about both.
class CourseRepository {
  final CourseService _api;
  final CourseLocalStorage _local;
  final ConnectivityService _connectivity;

  CourseRepository({
    CourseService? api,
    CourseLocalStorage? local,
    ConnectivityService? connectivity,
  })  : _api = api ?? CourseService(),
        _local = local ?? CourseLocalStorage(),
        _connectivity = connectivity ?? ConnectivityService();

  // ── READ ────────────────────────────────────────────────────────────────
  /// Returns courses, preferring fresh API data and falling back to the
  /// cached copy when offline or when the request fails.
  Future<CoursesResult> getCourses() async {
    final online = await _connectivity.isOnline();

    if (online) {
      try {
        final remote = await _api.fetchCourses();
        await _local.saveCourses(remote); // keep cache in sync
        return CoursesResult(
          remote,
          fromCache: false,
          lastSync: _local.lastSync(),
        );
      } on ApiException {
        // Network said "online" but the request still failed — use the cache
        // if we have one, otherwise surface the error.
        final cached = await _local.loadCourses();
        if (cached.isNotEmpty) {
          return CoursesResult(cached,
              fromCache: true, lastSync: _local.lastSync());
        }
        rethrow;
      }
    }

    // Offline → serve whatever we cached previously.
    final cached = await _local.loadCourses();
    return CoursesResult(cached, fromCache: true, lastSync: _local.lastSync());
  }

  // ── WRITE (API only — cache is refreshed via [syncCache]) ─────────────────
  Future<Course> createCourse({required String title, required String body}) {
    return _api.createCourse(title: title, body: body);
  }

  Future<Course> updateCourse(Course course) {
    return _api.updateCourse(course);
  }

  Future<void> deleteCourse(int id) {
    return _api.deleteCourse(id);
  }

  /// Persist the provider's authoritative in-memory list to the local cache.
  /// Called after a successful mutation so offline data stays correct.
  Future<void> syncCache(List<Course> courses) {
    return _local.saveCourses(courses);
  }

  /// Whether any data has ever been cached (used to decide offline messaging).
  bool get hasCache => _local.hasCache;
}
