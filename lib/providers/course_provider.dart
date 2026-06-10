import 'package:flutter/foundation.dart';
import '../models/course_model.dart';
import '../services/course_service.dart';

enum CourseStatus { idle, loading, success, error }

class CourseProvider with ChangeNotifier {
  final CourseService _service;
  CourseProvider({CourseService? service})
      : _service = service ?? CourseService();

  List<Course> _courses = [];
  CourseStatus _status = CourseStatus.idle;
  String _errorMessage = '';

  List<Course> get courses => List.unmodifiable(_courses);
  CourseStatus get status => _status;
  String get errorMessage => _errorMessage;
  bool get isLoading => _status == CourseStatus.loading;

  // ── helpers ───────────────────────────────────────────────────────────────
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
      _courses = await _service.fetchCourses();
      _setSuccess();
    } on ApiException catch (e) {
      _setError(e.message);
    } catch (e) {
      _setError('Unexpected error: $e');
    }
  }

  // ── CREATE ────────────────────────────────────────────────────────────────
  Future<bool> addCourse({required String title, required String body}) async {
    _setLoading();
    try {
      final created = await _service.createCourse(title: title, body: body);
      // JSONPlaceholder always returns id 101; insert at top so it's visible
      _courses.insert(0, created);
      _setSuccess();
      return true;
    } on ApiException catch (e) {
      _setError(e.message);
      return false;
    } catch (e) {
      _setError('Unexpected error: $e');
      return false;
    }
  }

  // ── UPDATE ────────────────────────────────────────────────────────────────
  Future<bool> editCourse(Course updated) async {
    _setLoading();
    try {
      final result = await _service.updateCourse(updated);
      final idx = _courses.indexWhere((c) => c.id == updated.id);
      if (idx != -1) _courses[idx] = result;
      _setSuccess();
      return true;
    } on ApiException catch (e) {
      _setError(e.message);
      return false;
    } catch (e) {
      _setError('Unexpected error: $e');
      return false;
    }
  }

  // ── DELETE ────────────────────────────────────────────────────────────────
  Future<bool> removeCourse(int id) async {
    _setLoading();
    try {
      await _service.deleteCourse(id);
      _courses.removeWhere((c) => c.id == id);
      _setSuccess();
      return true;
    } on ApiException catch (e) {
      _setError(e.message);
      return false;
    } catch (e) {
      _setError('Unexpected error: $e');
      return false;
    }
  }
}