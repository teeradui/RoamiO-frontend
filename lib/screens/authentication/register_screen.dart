import 'dart:io';

import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ming_cute_icons/ming_cute_icons.dart';
import 'package:path/path.dart' as path;
import 'package:provider/provider.dart';
import 'package:roamio_frontend/theme/colors.dart';
import 'package:roamio_frontend/viewmodels/register_view_model.dart';
import 'package:flutter/services.dart';

class RegisterScreen extends StatelessWidget {
  final VoidCallback? onRegistered;

  const RegisterScreen({super.key, this.onRegistered});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => RegisterViewModel(),
      child: _RegisterForm(onRegistered: onRegistered),
    );
  }
}

class _RegisterForm extends StatefulWidget {
  final VoidCallback? onRegistered;

  const _RegisterForm({this.onRegistered});

  @override
  State<_RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<_RegisterForm> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final ImagePicker _imagePicker = ImagePicker();

  File? _profileImage;

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _pickProfileImage() async {
    final XFile? image = await _imagePicker.pickImage(
      source: ImageSource.gallery,
    );

    if (image == null) return;

    final extension = path.extension(image.path).toLowerCase();

    const allowedExtensions = ['.jpg', '.jpeg', '.png'];

    if (!allowedExtensions.contains(extension)) {
      _showImageError('Please upload a JPG, JPEG, or PNG image.');
      return;
    }

    final file = File(image.path);
    final fileSize = await file.length();

    const maxSize = 5 * 1024 * 1024;

    if (fileSize > maxSize) {
      _showImageError('Profile picture must be no larger than 5 MB.');
      return;
    }

    setState(() {
      _profileImage = file;
    });
  }

  Future<void> _showImageError(String message) async {
    if (!mounted) return;

    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Container(
            padding: const EdgeInsets.fromLTRB(24, 26, 24, 20),
            decoration: BoxDecoration(
              color: AppColors.bgCard,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.10),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.close_rounded,
                    color: Colors.red,
                    size: 30,
                  ),
                ),

                const SizedBox(height: 18),

                Text(
                  'Unable to Upload',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                    height: 1.45,
                  ),
                ),

                const SizedBox(height: 22),

                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.btnPrimary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      'Got it',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<bool> _showUsernameConfirmation(String username) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          insetPadding: const EdgeInsets.symmetric(horizontal: 24),
          child: Container(
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
            decoration: BoxDecoration(
              color: AppColors.bgCard,
              borderRadius: BorderRadius.circular(26),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Title
                Text(
                  'Confirm your username',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 21,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  'This is how other travelers will find you.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),

                const SizedBox(height: 20),

                // Username card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 15,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.bgCard,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.btnPrimary.withValues(alpha: 0.20),
                      width: 1.2,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '@',
                        style: TextStyle(
                          color: AppColors.btnPrimary,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Flexible(
                        child: Text(
                          username,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Warning
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      color: AppColors.textMuted,
                      size: 17,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Your username cannot be changed later.',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Buttons
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 48,
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.of(context).pop(false);
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.textSecondary,
                            side: BorderSide(
                              color: AppColors.textMuted.withValues(
                                alpha: 0.25,
                              ),
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: const Text(
                            'Cancel',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 10),

                    Expanded(
                      child: SizedBox(
                        height: 48,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop(true);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.btnPrimary,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: const Text(
                            'Confirm',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );

    return result ?? false;
  }

  Future<void> _register() async {
    final formValid = _formKey.currentState!.validate();

    final viewModel = context.read<RegisterViewModel>();

    if (!formValid ||
        viewModel.usernameError != null ||
        viewModel.emailError != null ||
        viewModel.confirmPasswordError != null) {
      return;
    }

    final username = _usernameController.text.trim();

    final confirmed = await _showUsernameConfirmation(username);

    if (!confirmed || !mounted) return;

    final success = await viewModel.register(
      name: _nameController.text.trim(),
      username: username,
      email: _emailController.text.trim(),
      password: _passwordController.text,
      passwordConfirmation: _confirmPasswordController.text,
      profilePicturePath: _profileImage?.path,
    );

    if (!mounted) return;

    if (success) {
      await _showRegisterSuccess();
    }
  }

  Future<void> _showRegisterSuccess() async {
    if (!mounted) return;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Container(
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
            decoration: BoxDecoration(
              color: AppColors.bgCard,
              borderRadius: BorderRadius.circular(26),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.10),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    color: Colors.green,
                    size: 34,
                  ),
                ),

                const SizedBox(height: 18),

                Text(
                  'Welcome to RoamiO!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 21,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  'Your account has been created successfully.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                    height: 1.45,
                  ),
                ),

                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.btnPrimary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      'Get Started',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (!mounted) return;
    widget.onRegistered?.call();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<RegisterViewModel>(
      builder: (context, viewModel, child) {
        return Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildProfilePicture(),

              const SizedBox(height: 16),

              _buildTextField(
                controller: _nameController,
                label: 'Name',
                hint: 'Enter your name',
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your name.';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 12),

              _buildTextField(
                controller: _usernameController,
                label: 'Username',
                hint: 'username',
                prefixText: '@',
                inputFormatters: [FilteringTextInputFormatter.deny('@')],
                errorText: viewModel.usernameError,
                onChanged: (value) {
                  context.read<RegisterViewModel>().checkUsername(value);
                },
              ),

              const SizedBox(height: 12),

              _buildTextField(
                controller: _emailController,
                label: 'Email',
                hint: 'Enter your email',
                keyboardType: TextInputType.emailAddress,
                errorText: viewModel.emailError,
                onChanged: (value) {
                  context.read<RegisterViewModel>().checkEmail(value);
                },
              ),

              const SizedBox(height: 12),

              _buildTextField(
                controller: _passwordController,
                label: 'Password',
                hint: 'Enter your password',
                obscureText: _obscurePassword,
                onChanged: (value) {
                  context.read<RegisterViewModel>().checkPasswordMatch(
                    password: _passwordController.text,
                    confirmPassword: value,
                  );
                },
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

              const SizedBox(height: 12),

              _buildTextField(
                controller: _confirmPasswordController,
                label: 'Confirm Password',
                hint: 'Confirm your password',
                obscureText: _obscureConfirmPassword,
                errorText: viewModel.confirmPasswordError,
                onChanged: (value) {
                  context.read<RegisterViewModel>().checkPasswordMatch(
                    password: _passwordController.text,
                    confirmPassword: value,
                  );
                },
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureConfirmPassword
                        ? FluentIcons.eye_off_24_regular
                        : FluentIcons.eye_24_regular,
                    color: AppColors.textMuted,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureConfirmPassword = !_obscureConfirmPassword;
                    });
                  },
                ),
              ),

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: viewModel.isLoading ? null : _register,
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
                          'Create Account',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),

              if (viewModel.errorMessage != null) ...[
                const SizedBox(height: 16),
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

  Widget _buildProfilePicture() {
    return Center(
      child: GestureDetector(
        onTap: _pickProfileImage,
        child: Stack(
          children: [
            Container(
              width: 104,
              height: 104,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: CircleAvatar(
                radius: 52,
                backgroundColor: AppColors.bgCard,
                backgroundImage: _profileImage != null
                    ? FileImage(_profileImage!)
                    : null,
                child: _profileImage == null
                    ? Icon(
                        MingCuteIcons.mgc_user_1_line,
                        size: 48,
                        color: AppColors.textMuted,
                      )
                    : null,
              ),
            ),
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.btnPrimary,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.12),
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.camera_alt_outlined,
                  size: 17,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    String? Function(String?)? validator,
    String? errorText,
    ValueChanged<String>? onChanged,
    TextInputType? keyboardType,
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
            keyboardType: keyboardType,
            obscureText: obscureText,
            validator: validator,
            onChanged: onChanged,
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

              errorText: errorText,

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
