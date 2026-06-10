import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_theme.dart';
import '../models/course_model.dart';
import '../providers/course_provider.dart';
import 'course_form_screen.dart';

class CourseDetailScreen extends StatelessWidget {
  final Course course;
  const CourseDetailScreen({super.key, required this.course});

  Color get _accent {
    const palette = [
      Color(0xFF6C63FF),
      Color(0xFF43AA8B),
      Color(0xFFFF6B6B),
      Color(0xFFFFBE0B),
      Color(0xFF0F3460),
    ];
    return palette[course.id % palette.length];
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete Course',
            style: TextStyle(fontWeight: FontWeight.w800)),
        content: const Text(
            'Are you sure you want to delete this course?\nThis cannot be undone.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (ok == true && context.mounted) {
      final success =
          await context.read<CourseProvider>().removeCourse(course.id);
      if (context.mounted) {
        if (success) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Course deleted'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
          ));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content:
                Text(context.read<CourseProvider>().errorMessage),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: Text('Course #${course.id}'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        titleTextStyle: const TextStyle(
            color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Edit',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => CourseFormScreen(course: course)),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Delete',
            onPressed: () => _confirmDelete(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Banner ───────────────────────────────────────────
            _Banner(course: course, color: _accent),
            const SizedBox(height: 24),

            // ── Title ────────────────────────────────────────────
            Text(
              course.title,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: AppColors.primary,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 8),

            // ── Meta chips ───────────────────────────────────────
            Row(
              children: [
                _Chip(label: 'ID: ${course.id}', color: _accent),
                const SizedBox(width: 8),
                _Chip(label: 'User: ${course.userId}', color: AppColors.teal),
              ],
            ),
            const SizedBox(height: 24),

            // ── Description ──────────────────────────────────────
            _Section(
              icon: Icons.description_outlined,
              title: 'Description',
              color: _accent,
              child: Text(
                course.body,
                style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                    height: 1.7),
              ),
            ),
            const SizedBox(height: 28),

            // ── Action buttons ───────────────────────────────────
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => CourseFormScreen(course: course)),
                    ),
                    icon: Icon(Icons.edit_outlined, color: _accent),
                    label: Text('Edit',
                        style: TextStyle(color: _accent, fontWeight: FontWeight.w700)),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: BorderSide(color: _accent),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () => _confirmDelete(context),
                    icon: const Icon(Icons.delete_outline),
                    label: const Text('Delete',
                        style: TextStyle(fontWeight: FontWeight.w700)),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.error,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Banner extends StatelessWidget {
  final Course course;
  final Color color;
  const _Banner({required this.course, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 160,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          colors: [color, color.withOpacity(0.55)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -24,
            top: -24,
            child: Container(
              width: 130,
              height: 130,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.08),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Align(
              alignment: Alignment.bottomLeft,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('📚', style: TextStyle(fontSize: 36)),
                  const SizedBox(height: 8),
                  Text(
                    'JSONPlaceholder API',
                    style: TextStyle(
                        color: Colors.white.withOpacity(0.85),
                        fontSize: 13,
                        fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final Color color;
  const _Chip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(label,
          style: TextStyle(
              color: color, fontSize: 12, fontWeight: FontWeight.w700)),
    );
  }
}

class _Section extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final Widget child;
  const _Section(
      {required this.icon,
      required this.title,
      required this.color,
      required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              const SizedBox(width: 10),
              Text(title,
                  style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      color: AppColors.primary)),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(height: 1, color: AppColors.divider),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}