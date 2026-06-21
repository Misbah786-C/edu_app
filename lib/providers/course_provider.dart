import 'package:flutter/foundation.dart';
import '../models/course_model.dart';
import '../services/course_service.dart';
import '../repositories/course_repository.dart';

enum CourseStatus { idle, loading, success, error }

/// Holds all UI state for courses and delegates data work to [CourseRepository].
///
/// Responsibilities:
///  • expose loading / success / error / empty states,
///  • drive optimistic create / update / delete with rollback,
///  • keep an offline flag + last-sync time for the UI banner,
///  • own the search query and expose a filtered view.
///
/// It contains NO HTTP and NO storage logic — that lives behind the repository.
class CourseProvider with ChangeNotifier {
  final CourseRepository _repo;
  CourseProvider({CourseRepository? repository})
      : _repo = repository ?? CourseRepository();

  // ── State ─────────────────────────────────────────────────────────────────
  List<Course> _courses = [];
  CourseStatus _status = CourseStatus.idle;
  String _errorMessage = '';
  bool _fromCache = false;
  DateTime? _lastSync;
  String _query = '';

  // ── Getters ─────────────────────────────────────────────────────────────
  /// Courses after applying the current search query.
  List<Course> get courses {
    if (_query.trim().isEmpty) return List.unmodifiable(_courses);
    final q = _query.toLowerCase();
    return List.unmodifiable(
      _courses.where((c) =>
          c.title.toLowerCase().contains(q) ||
          c.body.toLowerCase().contains(q)),
    );
  }

  /// The full unfiltered list (used to tell "no data" from "no search results").
  List<Course> get allCourses => List.unmodifiable(_courses);

  CourseStatus get status => _status;
  String get errorMessage => _errorMessage;
  bool get isLoading => _status == CourseStatus.loading;

  /// True when the data on screen came from the offline cache.
  bool get isFromCache => _fromCache;
  DateTime? get lastSync => _lastSync;

  String get query => _query;
  bool get isSearching => _query.trim().isNotEmpty;
  bool get hasData => _courses.isNotEmpty;

  // ── Search ────────────────────────────────────────────────────────────────
  void setQuery(String value) {
    _query = value;
    notifyListeners();
  }

  void clearQuery() {
    if (_query.isEmpty) return;
    _query = '';
    notifyListeners();
  }

  // ── Status helpers ──────────────────────────────────────────────────────
  void _setLoading() {
    _status = CourseStatus.loading;
    _errorMessage = '';
    notifyListeners();
  }

  void _setSuccess() {
    _status = CourseStatus.success;
    notifyListeners();
  }

  void _setError(String msg) {
    _status = CourseStatus.error;
    _errorMessage = msg;
    notifyListeners();
  }

  // ── READ ──────────────────────────────────────────────────────────────────
  Future<void> loadCourses() async {
    _setLoading();
    try {
      final result = await _repo.getCourses();
      _courses = result.data;
      _fromCache = result.fromCache;
      _lastSync = result.lastSync;
      _setSuccess();
    } on ApiException catch (e) {
      _setError(e.message);
    } catch (e) {
      _setError('Unexpected error: $e');
    }
  }

  // ── CREATE ──────────────────────────────────────────────────────────────
  /// Optimistic: the new course appears immediately and is removed again if
  /// the API call fails.
  Future<bool> addCourse({required String title, required String body}) async {
    // Temporary local id so the optimistic card has a stable key.
    final tempId = DateTime.now().millisecondsSinceEpoch;
    final optimistic =
        Course(id: tempId, title: title, body: body, userId: 1);
    _courses.insert(0, optimistic);
    notifyListeners();

    try {
      final created = await _repo.createCourse(title: title, body: body);
      // Swap the placeholder for the server's version.
      final idx = _courses.indexWhere((c) => c.id == tempId);
      if (idx != -1) _courses[idx] = created;
      await _syncCacheSafe();
      _setSuccess();
      return true;
    } catch (e) {
      _courses.removeWhere((c) => c.id == tempId); // rollback
      _errorMessage = _messageFor(e);
      notifyListeners();
      return false;
    }
  }

  // ── UPDATE ──────────────────────────────────────────────────────────────
  /// Optimistic: the edit is shown right away and reverted on failure.
  Future<bool> editCourse(Course updated) async {
    final idx = _courses.indexWhere((c) => c.id == updated.id);
    if (idx == -1) return false;

    final previous = _courses[idx];
    _courses[idx] = updated; // optimistic
    notifyListeners();

    try {
      final result = await _repo.updateCourse(updated);
      final newIdx = _courses.indexWhere((c) => c.id == updated.id);
      if (newIdx != -1) _courses[newIdx] = result;
      await _syncCacheSafe();
      _setSuccess();
      return true;
    } catch (e) {
      final revertIdx = _courses.indexWhere((c) => c.id == updated.id);
      if (revertIdx != -1) _courses[revertIdx] = previous; // rollback
      _errorMessage = _messageFor(e);
      notifyListeners();
      return false;
    }
  }

  // ── DELETE ──────────────────────────────────────────────────────────────
  /// Optimistic: the row disappears immediately and is restored if the API
  /// request fails.
  Future<bool> removeCourse(int id) async {
    final idx = _courses.indexWhere((c) => c.id == id);
    if (idx == -1) return false;

    final removed = _courses[idx];
    _courses.removeAt(idx); // optimistic
    notifyListeners();

    try {
      await _repo.deleteCourse(id);
      await _syncCacheSafe();
      return true;
    } catch (e) {
      _courses.insert(idx, removed); // rollback to original position
      _errorMessage = _messageFor(e);
      notifyListeners();
      return false;
    }
  }

  // ── Internals ─────────────────────────────────────────────────────────────
  Future<void> _syncCacheSafe() async {
    try {
      await _repo.syncCache(_courses);
    } catch (_) {
      // A cache write failure should never break the user flow.
    }
  }

  String _messageFor(Object e) =>
      e is ApiException ? e.message : 'Unexpected error: $e';
}
