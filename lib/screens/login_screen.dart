import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_theme.dart';
import '../controllers/auth_controller.dart';
import '../enums/app_enums.dart';
import '../validators/app_validator.dart';
import '../widgets/app_widgets.dart';
import 'register_screen.dart';
import 'dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  bool _obscurePassword = true;
  bool _rememberMe = false;
  bool _formValid = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  void _checkValidity() {
    setState(() => _formValid = _formKey.currentState?.validate() ?? false);
  }

  Future<void> _submit() async {
    if (!_formValid) return;
    final ctrl = context.read<AuthController>();
    ctrl.clearError();

    final ok = await ctrl.login(
      email: _emailCtrl.text,
      password: _passwordCtrl.text,
      rememberMe: _rememberMe,
    );

    if (!mounted) return;
    if (ok) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const DashboardScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<AuthController>();

    return GradientScaffold(
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: Form(
            key: _formKey,
            onChanged: _checkValidity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Logo
                _buildLogo(),
                const SizedBox(height: 40),

                const ScreenHeader(
                  title: 'Welcome\nBack 👋',
                  subtitle: 'Sign in to continue your learning',
                ),
                const SizedBox(height: 36),

                // Error
                if (ctrl.state == AuthState.error) ...[
                  ErrorBanner(message: ctrl.errorMessage),
                  const SizedBox(height: 16),
                ],

                // Email
                TextFormField(
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email Address',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  validator: AppValidator.email,
                ),
                const SizedBox(height: 16),

                // Password
                TextFormField(
                  controller: _passwordCtrl,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        color: AppColors.textSecondary,
                      ),
                      onPressed: () => setState(
                          () => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                  validator: (v) => v == null || v.isEmpty
                      ? 'Password is required'
                      : null,
                ),
                const SizedBox(height: 12),

                // Remember me
                Row(
                  children: [
                    SizedBox(
                      width: 24,
                      height: 24,
                      child: Checkbox(
                        value: _rememberMe,
                        onChanged: (v) =>
                            setState(() => _rememberMe = v ?? false),
                        activeColor: AppColors.accent,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4)),
                      ),
                    ),
                    const SizedBox(width: 10),
                    GestureDetector(
                      onTap: () =>
                          setState(() => _rememberMe = !_rememberMe),
                      child: const Text(
                        'Remember me',
                        style: TextStyle(
                            color: AppColors.textSecondary, fontSize: 14),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Submit
                PrimaryButton(
                  label: 'Sign In',
                  onPressed: _formValid ? _submit : null,
                  isLoading: ctrl.isLoading,
                ),
                const SizedBox(height: 24),

                // Hint box for demo
                _buildDemoHint(),
                const SizedBox(height: 24),

                // Register link
                Center(
                  child: GestureDetector(
                    onTap: () => Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const RegisterScreen()),
                    ),
                    child: RichText(
                      text: const TextSpan(
                        text: "Don't have an account? ",
                        style: TextStyle(color: AppColors.textSecondary),
                        children: [
                          TextSpan(
                            text: 'Create one',
                            style: TextStyle(
                              color: AppColors.accent,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(14),
          ),
          alignment: Alignment.center,
          child: const Text(
            'E',
            style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w900),
          ),
        ),
        const SizedBox(width: 12),
        const Text(
          'EduApp',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: AppColors.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildDemoHint() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.accentAlt.withOpacity(0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.accentAlt.withOpacity(0.2)),
      ),
      child: const Row(
        children: [
          Icon(Icons.info_outline,
              size: 16, color: AppColors.accentAlt),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'Register first to create your credentials, then log in.',
              style: TextStyle(
                  fontSize: 12,
                  color: AppColors.accentAlt),
            ),
          ),
        ],
      ),
    );
  }
}