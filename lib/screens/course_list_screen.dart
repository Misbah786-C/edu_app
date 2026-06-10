import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_theme.dart';
import '../models/course_model.dart';
import '../providers/course_provider.dart';
import '../widgets/app_widgets.dart';
import 'course_form_screen.dart';
import 'course_detail_screen.dart';

class CourseListScreen extends StatefulWidget {
  const CourseListScreen({super.key});

  @override
  State<CourseListScreen> createState() => _CourseListScreenState();
}

class _CourseListScreenState extends State<CourseListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CourseProvider>().loadCourses();
    });
  }

  Future<void> _confirmDelete(Course course) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete Course',
            style: TextStyle(fontWeight: FontWeight.w800)),
        content: Text(
            'Are you sure you want to delete\n"${course.title}"?\n\nThis cannot be undone.'),
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

    if (ok == true && mounted) {
      final success =
          await context.read<CourseProvider>().removeCourse(course.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
              success ? 'Course deleted successfully' : 'Failed to delete'),
          backgroundColor: success ? AppColors.success : AppColors.error,
          behavior: SnackBarBehavior.floating,
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: const Text('Courses'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        titleTextStyle: const TextStyle(
            color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: () => context.read<CourseProvider>().loadCourses(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.accent,
        foregroundColor: Colors.white,
        onPressed: () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => const CourseFormScreen())),
        icon: const Icon(Icons.add),
        label: const Text('Add Course',
            style: TextStyle(fontWeight: FontWeight.w700)),
      ),
      body: Consumer<CourseProvider>(
        builder: (context, provider, _) {
          // ── Loading ──────────────────────────────────────────
          if (provider.isLoading) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: AppColors.accent),
                  SizedBox(height: 16),
                  Text('Fetching courses...',
                      style: TextStyle(color: AppColors.textSecondary)),
                ],
              ),
            );
          }

          // ── Error ─────────────────────────────────────────────
          if (provider.status == CourseStatus.error) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.wifi_off_rounded,
                        size: 64, color: AppColors.error),
                    const SizedBox(height: 16),
                    const Text('Something went wrong',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary)),
                    const SizedBox(height: 8),
                    Text(provider.errorMessage,
                        textAlign: TextAlign.center,
                        style:
                            const TextStyle(color: AppColors.textSecondary)),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () => provider.loadCourses(),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }

          // ── Empty ─────────────────────────────────────────────
          if (provider.courses.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.school_outlined,
                      size: 72, color: AppColors.textSecondary),
                  const SizedBox(height: 16),
                  const Text('No courses yet',
                      style: TextStyle(
                          fontSize: 18, color: AppColors.textSecondary)),
                  const SizedBox(height: 8),
                  const Text('Tap + to add your first course',
                      style: TextStyle(color: AppColors.textSecondary)),
                ],
              ),
            );
          }

          // ── List ──────────────────────────────────────────────
          return RefreshIndicator(
            color: AppColors.accent,
            onRefresh: () => provider.loadCourses(),
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
              itemCount: provider.courses.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, i) {
                final course = provider.courses[i];
                return _CourseCard(
                  course: course,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => CourseDetailScreen(course: course)),
                  ),
                  onEdit: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => CourseFormScreen(course: course)),
                  ),
                  onDelete: () => _confirmDelete(course),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

// ── Course card ───────────────────────────────────────────────────────────────
class _CourseCard extends StatelessWidget {
  final Course course;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _CourseCard({
    required this.course,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

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

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      elevation: 1,
      shadowColor: Colors.black12,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // ID badge
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: _accent.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                alignment: Alignment.center,
                child: Text(
                  '#${course.id}',
                  style: TextStyle(
                      color: _accent,
                      fontWeight: FontWeight.w800,
                      fontSize: 12),
                ),
              ),
              const SizedBox(width: 14),
              // Title + body
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      course.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          color: AppColors.primary),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      course.body,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Actions
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _ActionIcon(
                      icon: Icons.edit_outlined,
                      color: AppColors.purple,
                      onTap: onEdit),
                  const SizedBox(height: 4),
                  _ActionIcon(
                      icon: Icons.delete_outline,
                      color: AppColors.error,
                      onTap: onDelete),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionIcon extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _ActionIcon(
      {required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 16, color: color),
      ),
    );
  }
}