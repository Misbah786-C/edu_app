import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/course_model.dart';

/// Local (offline) data source for courses, backed by Hive.
///
/// Courses are serialised to a single JSON string and stored under one key,
/// so no Hive `TypeAdapter` / code-generation is required. A separate key
/// keeps the timestamp of the last successful sync with the API.
///
/// This class knows NOTHING about HTTP — it only reads/writes the local box.
class CourseLocalStorage {
  static const String _boxName = 'course_cache';
  static const String _coursesKey = 'courses';
  static const String _syncKey = 'last_sync';

  /// Must be called once before [runApp] (see `main.dart`).
  static Future<void> init() async {
    await Hive.initFlutter();
    if (!Hive.isBoxOpen(_boxName)) {
      await Hive.openBox(_boxName);
    }
  }

  Box get _box => Hive.box(_boxName);

  /// Persist the full course list and stamp the sync time.
  Future<void> saveCourses(List<Course> courses) async {
    final encoded = json.encode(courses.map((c) => c.toJson()).toList());
    await _box.put(_coursesKey, encoded);
    await _box.put(_syncKey, DateTime.now().toIso8601String());
  }

  /// Read the cached course list (empty if nothing has been cached yet).
  Future<List<Course>> loadCourses() async {
    final raw = _box.get(_coursesKey) as String?;
    if (raw == null || raw.isEmpty) return <Course>[];
    try {
      final decoded = json.decode(raw) as List<dynamic>;
      return decoded
          .map((e) => Course.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      // Corrupted cache — treat as empty rather than crashing the app.
      return <Course>[];
    }
  }

  /// Timestamp of the last successful API sync, or null if never synced.
  DateTime? lastSync() {
    final raw = _box.get(_syncKey) as String?;
    return raw == null ? null : DateTime.tryParse(raw);
  }

  /// True once at least one successful API response has been cached.
  bool get hasCache {
    final raw = _box.get(_coursesKey) as String?;
    return raw != null && raw.isNotEmpty;
  }

  Future<void> clear() => _box.clear();
}
