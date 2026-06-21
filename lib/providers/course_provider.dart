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
      _setErro