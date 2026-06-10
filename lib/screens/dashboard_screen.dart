import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_theme.dart';
import '../controllers/auth_controller.dart';
import '../models/subject_model.dart';
import '../widgets/app_widgets.dart';
import 'login_screen.dart';
import 'detail_screen.dart';
import 'course_list_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<AuthController>();
    final user = ctrl.currentUser!;

    return GradientScaffold(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Top bar
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hello, ${user.firstName} 👋',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          user.email,
                          style: const TextStyle(
                              fontSize: 13, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  UserAvatar(initials: user.initials, size: 52),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ── Stats row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  _StatChip(
                      label: 'Subjects',
                      value: '${kSubjects.length}',
                      color: AppColors.purple),
                  const SizedBox(width: 10),
                  _StatChip(
                      label: 'Semester',
                      value: 'Fall 2025',
                      color: AppColors.teal),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ── API Courses banner button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CourseListScreen()),
                ),
                child: Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.accent, Color(0xFFFF8C69)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.api_rounded,
                            color: Colors.white, size: 22),
                      ),
                      const SizedBox(width: 14),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('API Courses',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 15)),
                            Text('Browse, add, edit & delete via JSONPlaceholder',
                                style: TextStyle(
                                    color: Colors.white70, fontSize: 11)),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios_rounded,
                          color: Colors.white70, size: 14),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // ── Section label
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Text('My Subjects',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary)),
            ),
            const SizedBox(height: 14),

            // ── Subject list
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
                itemCount: kSubjects.length,
                separatorBuilder: (_, __) => const SizedBox(height: 14),
                itemBuilder: (context, i) =>
                    _SubjectCard(subject: kSubjects[i]),
              ),
            ),

            // ── Logout
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: OutlinedButton.icon(
                onPressed: () async {
                  await ctrl.logout();
                  if (context.mounted) {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                      (_) => false,
                    );
                  }
                },
                icon: const Icon(Icons.logout_rounded,
                    color: AppColors.accent, size: 18),
                label: const Text('Logout',
                    style: TextStyle(
                        color: AppColors.accent, fontWeight: FontWeight.w700)),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  side: const BorderSide(color: AppColors.accent),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SubjectCard extends StatelessWidget {
  final Subject subject;
  const _SubjectCard({required this.subject});

  Color get _color =>
      Color(int.parse('FF${subject.colorHex}', radix: 16));

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      elevation: 1,
      shadowColor: Colors.black12,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => DetailScreen(subject: subject)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: _color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                alignment: Alignment.center,
                child: Text(subject.iconEmoji,
                    style: const TextStyle(fontSize: 26)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(subject.name,
                        style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                            color: AppColors.primary)),
                    const SizedBox(height: 4),
                    Text(subject.code,
                        style: TextStyle(
                            fontSize: 12,
                            color: _color,
                            fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    Text(subject.instructor,
                        style: const TextStyle(
                            fontSize: 12, color: AppColors.textSecondary)),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios_rounded,
                  size: 14, color: AppColors.textSecondary),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _StatChip(
      {required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
              width: 8,
              height: 8,
              decoration:
                  BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value,
                  style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.w800,
                      fontSize: 14)),
              Text(label,
                  style: const TextStyle(
                      color: AppColors.textSecondary, fontSize: 11)),
            ],
          ),
        ],
      ),
    );
  }
}