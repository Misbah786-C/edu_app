import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/course_model.dart';

/// Thrown whenever the API returns an unexpected status code or the
/// network call itself fails.
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  ApiException({required this.message, this.statusCode});

  @override
  String toString() => 'ApiException($statusCode): $message';
}

/// All JSONPlaceholder HTTP calls live here — zero Flutter/UI imports.
class CourseService {
  static const _base = 'https://jsonplaceholder.typicode.com';

  final http.Client _client;
  CourseService({http.Client? client}) : _client = client ?? http.Client();

  // ── READ ─────────────────────────────────────────────────────────────────
  /// GET /posts  — returns first 20 posts mapped as courses.
  Future<List<Course>> fetchCourses() async {
    try {
      final res = await _client.get(
        Uri.parse('$_base/posts'),
        headers: {'Content-Type': 'application/json'},
      );
      if (res.statusCode == 200) {
        final list = json.decode(res.body) as List<dynamic>;
        return list.take(20).map((e) => Course.fromJson(e)).toList();
      }
      throw ApiException(
          message: 'Failed to fetch courses', statusCode: res.statusCode);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: 'Network error: $e');
    }
  }

  // ── CREATE ────────────────────────────────────────────────────────────────
  /// POST /posts
  Future<Course> createCourse({
    required String title,
    required String body,
    int userId = 1,
  }) async {
    try {
      final res = await _client.post(
        Uri.parse('$_base/posts'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'title': title, 'body': body, 'userId': userId}),
      );
      if (res.statusCode == 201) {
        return Course.fromJson(json.decode(res.body));
      }
      throw ApiException(
          message: 'Failed to create course', statusCode: res.statusCode);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: 'Network error: $e');
    }
  }

  // ── UPDATE ────────────────────────────────────────────────────────────────
  /// PUT /posts/:id
  Future<Course> updateCourse(Course course) async {
    try {
      final res = await _client.put(
        Uri.parse('$_base/posts/${course.id}'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(course.toJson()),
      );
      if (res.statusCode == 200) {
        return Course.fromJson(json.decode(res.body));
      }
      throw ApiException(
          message: 'Failed to update course', statusCode: res.statusCode);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: 'Network error: $e');
    }
  }

  // ── DELETE ────────────────────────────────────────────────────────────────
  /// DELETE /posts/:id
  Future<void> deleteCourse(int id) async {
    try {
      final res = await _client.delete(
        Uri.parse('$_base/posts/$id'),
        headers: {'Content-Type': 'application/json'},
      );
      // JSONPlaceholder returns 200 on successful delete
      if (res.statusCode != 200) {
        throw ApiException(
            message: 'Failed to delete course', statusCode: res.statusCode);
      }
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: 'Network error: $e');
    }
  }
}