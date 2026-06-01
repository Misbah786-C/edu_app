import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_theme.dart';
import '../controllers/auth_controller.dart';
import '../enums/app_enums.dart';
import '../validators/app_validator.dart';
import '../widgets/app_widgets.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  Gender? _selectedGender;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _formValid = false;

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  void _checkValidity() {
    final valid = _formKey.currentState?.validate() ?? false;
    setState(() => _formValid = valid && _selectedGender != null);
  }

  Future<void> _submit() async {
    if (!_formValid) return;
    final ctrl = context.read<AuthController>();
    ctrl.clearError();

    final ok = await ctrl.register(
      firstName: _firstNameCtrl.text,
      lastName: _lastNameCtrl.text,
      email: _emailCtrl.text,
      gender: _selectedGender!,
      password: _passwordCtrl.text,
    );

    if (!mounted) return;

    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Account created! Please sign in.'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<AuthController>();

    return GradientScaffold(
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Form(
            key: _formKey,
            onChanged: _checkValidity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Logo area
                _buildLogo(),
                const SizedBox(height: 32),

                const ScreenHeader(
                  title: 'Create\nAccount',
                  subtitle: 'Fill in your details to get started',
                ),
                const SizedBox(height: 32),

                // Error banner
                if (ctrl.state == AuthState.error) ...[
                  ErrorBanner(message: ctrl.errorMessage),
                  const SizedBox(height: 16),
                ],

                // Name row
                Row(
                  children: [
                    Expanded(child: _buildField(
                      controller: _firstNameCtrl,
                      label: 'First Name',
                      icon: Icons.person_outline,
                      validator: (v) => AppValidator.name(v, fieldName: 'First name'),
                    )),
                    const SizedBox(width: 12),
                    Expanded(child: _buildField(
                      controller: _lastNameCtrl,
                      label: 'Last Name',
                      icon: Icons.person_outline,
                      validator: (v) => AppValidator.name(v, fieldName: 'Last name'),
                    )),
                  ],
                ),
                const SizedBox(height: 16),

                // Email
                _buildField(
                  controller: _emailCtrl,
                  label: 'Email Address',
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: AppValidator.email,
                ),
                const SizedBox(height: 16),

                // Gender
                _buildGenderDropdown(),
                const SizedBox(height: 16),

                // Password
                TextFormField(
                  controller: _passwordCtrl,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(_obscurePassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined),
                      onPressed: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                  validator: AppValidator.password,
                  onChanged: (_) => _checkValidity(),
                ),
                PasswordStrengthBar(password: _passwordCtrl.text),
                const SizedBox(height: 16),

                // Confirm password
                TextFormField(
                  controller: _confirmCtrl,
                  obscureText: _obscureConfirm,
                  decoration: InputDecoration(
                    labelText: 'Confirm Password',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(_obscureConfirm
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined),
                      onPressed: () =>
                          setState(() => _obscureConfirm = !_obscureConfirm),
                    ),
                  ),
                  validator: (v) =>
                      AppValidator.confirmPassword(v, _passwordCtrl.text),
                ),
                const SizedBox(height: 32),

                // Submit
                PrimaryButton(
                  label: 'Create Account',
                  onPressed: _formValid ? _submit : null,
                  isLoading: ctrl.isLoading,
                ),
                const SizedBox(height: 20),

                // Login link
                Center(
                  child: GestureDetector(
                    onTap: () => Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                    ),
                    child: RichText(
                      text: const TextSpan(
                        text: 'Already have an account? ',
                        style: TextStyle(color: AppColors.textSecondary),
                        children: [
                          TextSpan(
                            text: 'Sign In',
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
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(16),
      ),
      alignment: Alignment.center,
      child: const Text('E', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w900)),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
      ),
      validator: validator,
    );
  }

  Widget _buildGenderDropdown() {
    return DropdownButtonFormField<Gender>(
      value: _selectedGender,
      decoration: const InputDecoration(
        labelText: 'Gender',
        prefixIcon: Icon(Icons.wc_outlined),
      ),
      items: Gender.values
          .map((g) => DropdownMenuItem(value: g, child: Text(g.label)))
          .toList(),
      onChanged: (val) {
        setState(() => _selectedGender = val);
        _checkValidity();
      },
      validator: (v) => v == null ? 'Please select a gender' : null,
    );
  }
}