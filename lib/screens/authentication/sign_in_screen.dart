import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:roamio_frontend/screens/authentication/forgot_password_screen.dart';
import 'package:roamio_frontend/theme/colors.dart';
import 'package:roamio_frontend/viewmodels/sign_in_view_model.dart';
import 'package:flutter/services.dart';

class SignInScreen extends StatelessWidget {
  const SignInScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SignInViewModel(),
      child: const _SignInForm(),
    );
  }
}

class _SignInForm extends StatefulWidget {
  const _SignInForm();

  @override
  State<_SignInForm> createState() => _SignInFormState();
}

class _SignInFormState extends State<_SignInForm> {
  final _formKey = GlobalKey<FormState>();

  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) return;

    final viewModel = context.read<SignInViewModel>();

    final success = await viewModel.signIn(
      username: _usernameController.text.trim(),
      password: _passwordController.text,
    );

    if (!mounted) return;

    if (success) {
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  void _forgotPassword() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Forgot Password will be available soon.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SignInViewModel>(
      builder: (context, viewModel, child) {
        return Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTextField(
                controller: _usernameController,
                label: 'Username',
                hint: 'username',
                prefixText: '@',
                inputFormatters: [FilteringTextInputFormatter.deny('@')],
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your username.';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 12),

              _buildTextField(
                controller: _passwordController,
                label: 'Password',
                hint: 'Enter your password',
                obscureText: _obscurePassword,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword
                        ? FluentIcons.eye_off_24_regular
                        : FluentIcons.eye_24_regular,
                    color: AppColors.textMuted,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password.';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 8),

              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ForgotPasswordScreen(),
                      ),
                    );
                  },
                  child: Text(
                    'Forgot Password?',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 90),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: viewModel.isLoading ? null : _signIn,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.btnPrimary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: viewModel.isLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Sign In',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),

              if (viewModel.errorMessage != null) ...[
                const SizedBox(height: 12),
                Text(
                  viewModel.errorMessage!,
                  style: const TextStyle(color: Colors.red, fontSize: 14),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    String? Function(String?)? validator,
    bool obscureText = false,
    Widget? suffixIcon,
    String? prefixText,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),

        const SizedBox(height: 6),

        Container(
          decoration: BoxDecoration(
            color: AppColors.bgCard,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: TextFormField(
            controller: controller,
            obscureText: obscureText,
            validator: validator,
            inputFormatters: inputFormatters,
            style: TextStyle(color: AppColors.textPrimary, fontSize: 15),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: AppColors.textMuted),
              prefixText: prefixText,
              prefixStyle: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
              suffixIcon: suffixIcon,

              filled: true,
              fillColor: Colors.transparent,

              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),

              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),

              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),

              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(
                  color: const Color.fromARGB(255, 243, 209, 177),
                  width: 1,
                ),
              ),

              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: Colors.red),
              ),

              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: Colors.red),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
