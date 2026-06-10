import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_theme.dart';
import '../models/course_model.dart';
import '../providers/course_provider.dart';
import '../widgets/app_widgets.dart';

class CourseFormScreen extends StatefulWidget {
  /// null → Create mode   |   non-null → Edit mode
  final Course? course;
  const CourseFormScreen({super.key, this.course});

  @override
  State<CourseFormScreen> createState() => _CourseFormScreenState();
}

class _CourseFormScreenState extends State<CourseFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleCtrl;
  late final TextEditingController _bodyCtrl;
  bool _submitting = false;

  bool get _isEdit => widget.course != null;

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController(text: widget.course?.title ?? '');
    _bodyCtrl = TextEditingController(text: widget.course?.body ?? '');
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _bodyCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _submitting = true);

    final provider = context.read<CourseProvider>();
    bool success;

    if (_isEdit) {
      success = await provider.editCourse(
        widget.course!.copyWith(
          title: _titleCtrl.text.trim(),
          body: _bodyCtrl.text.trim(),
        ),
      );
    } else {
      success = await provider.addCourse(
        title: _titleCtrl.text.trim(),
        body: _bodyCtrl.text.trim(),
      );
    }

    if (!mounted) return;
    setState(() => _submitting = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(_isEdit
            ? 'Course updated successfully!'
            : 'Course added successfully!'),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
      ));
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(context.read<CourseProvider>().errorMessage),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: Text(_isEdit ? 'Edit Course' : 'Add Course'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        titleTextStyle: const TextStyle(
            color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header card ──────────────────────────────────
              Container(
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
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.accent.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        _isEdit ? Icons.edit_rounded : Icons.add_circle_outline,
                        color: AppColors.accent,
                        size: 26,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _isEdit ? 'Update Course' : 'New Course',
                            style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 16,
                                color: AppColors.primary),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _isEdit
                                ? 'Modify the details below'
                                : 'Fill in the details to create a course',
                            style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // ── Title ────────────────────────────────────────
              const _Label('Course Title'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _titleCtrl,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  hintText: 'e.g. Introduction to Flutter',
                  prefixIcon: Icon(Icons.title_rounded),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Title is required';
                  }
                  if (v.trim().length < 3) {
                    return 'Title must be at least 3 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // ── Description ──────────────────────────────────
              const _Label('Description'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _bodyCtrl,
                maxLines: 5,
                textInputAction: TextInputAction.done,
                decoration: const InputDecoration(
                  hintText: 'Describe the course content and objectives...',
                  prefixIcon: Padding(
                    padding: EdgeInsets.only(bottom: 64),
                    child: Icon(Icons.description_outlined),
                  ),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Description is required';
                  }
                  if (v.trim().length < 10) {
                    return 'Description must be at least 10 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 36),

              // ── Submit ───────────────────────────────────────
              PrimaryButton(
                label: _isEdit ? 'Save Changes' : 'Add Course',
                isLoading: _submitting,
                onPressed: _submitting ? null : _submit,
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton(
                  onPressed: _submitting ? null : () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.divider),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Text('Cancel',
                      style: TextStyle(color: AppColors.textSecondary)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 14,
            color: AppColors.primary),
      );
}