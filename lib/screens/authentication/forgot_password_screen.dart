import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ming_cute_icons/ming_cute_icons.dart';
import 'package:roamio_frontend/theme/colors.dart';
import 'package:roamio_frontend/viewmodels/forgot_password_view_model.dart';

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ForgotPasswordViewModel(),
      child: const _ForgotPasswordView(),
    );
  }
}

class _ForgotPasswordView extends StatefulWidget {
  const _ForgotPasswordView();

  @override
  State<_ForgotPasswordView> createState() => _ForgotPasswordViewState();
}

class _ForgotPasswordViewState extends State<_ForgotPasswordView> {
  final _emailController = TextEditingController();
  final _otpController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _otpController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: SafeArea(
        child: Consumer<ForgotPasswordViewModel>(
          builder: (context, viewModel, child) {
            switch (viewModel.currentStep) {
              case ForgotPasswordStep.enterEmail:
                return _buildEmailStep(context, viewModel);

              case ForgotPasswordStep.enterOtp:
                return _buildOtpStep(context, viewModel);

              case ForgotPasswordStep.resetPassword:
                return _buildResetPasswordStep(context, viewModel);

              case ForgotPasswordStep.completed:
                return _buildCompletedStep(context);
            }
          },
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // Email
  // ─────────────────────────────────────────────

  Widget _buildEmailStep(
    BuildContext context,
    ForgotPasswordViewModel viewModel,
  ) {
    return _buildPage(
      icon: MingCuteIcons.mgc_mail_send_fill,
      title: 'Forgot password?',
      subtitle:
          'Enter your registered email and we’ll send you an OTP to reset your password.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildTextField(
            controller: _emailController,
            hintText: 'Email',
            icon: MingCuteIcons.mgc_mail_line,
            keyboardType: TextInputType.emailAddress,
          ),

          if (viewModel.errorMessage != null) ...[
            const SizedBox(height: 8),
            _buildErrorText(viewModel.errorMessage!),
          ],

          const SizedBox(height: 20),

          _buildPrimaryButton(
            text: 'Send OTP',
            isLoading: viewModel.isLoading,
            onPressed: () async {
              await viewModel.requestPasswordReset(
                _emailController.text,
              );
            },
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  // OTP
  // ─────────────────────────────────────────────

  Widget _buildOtpStep(
    BuildContext context,
    ForgotPasswordViewModel viewModel,
  ) {
    return _buildPage(
      icon: MingCuteIcons.mgc_shield_fill,
      title: 'Enter OTP',
      subtitle:
          'Enter the OTP sent to ${viewModel.registeredEmail}.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildTextField(
            controller: _otpController,
            hintText: 'Enter OTP',
            icon: MingCuteIcons.mgc_key_2_line,
            keyboardType: TextInputType.number,
            maxLength: 6,
          ),

          if (viewModel.errorMessage != null) ...[
            const SizedBox(height: 8),
            _buildErrorText(viewModel.errorMessage!),
          ],

          const SizedBox(height: 20),

          _buildPrimaryButton(
            text: 'Verify OTP',
            isLoading: viewModel.isLoading,
            onPressed: () async {
              await viewModel.verifyOtp(
                _otpController.text,
              );
            },
          ),

          const SizedBox(height: 12),

          TextButton(
            onPressed: viewModel.isLoading
                ? null
                : () async {
                    await viewModel.resendOtp();
                    _otpController.clear();
                  },
            child: const Text(
              'Resend OTP',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          TextButton(
            onPressed: viewModel.isLoading
                ? null
                : () {
                    _otpController.clear();
                    viewModel.backToEmail();
                  },
            child: const Text(
              'Change email',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  // Reset Password
  // ─────────────────────────────────────────────

  Widget _buildResetPasswordStep(
    BuildContext context,
    ForgotPasswordViewModel viewModel,
  ) {
    return _buildPage(
      icon: MingCuteIcons.mgc_lock_fill,
      title: 'Create new password',
      subtitle: 'Enter and confirm your new password.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildTextField(
            controller: _newPasswordController,
            hintText: 'New password',
            icon: MingCuteIcons.mgc_lock_line,
            obscureText: true,
          ),

          const SizedBox(height: 12),

          _buildTextField(
            controller: _confirmPasswordController,
            hintText: 'Confirm new password',
            icon: MingCuteIcons.mgc_lock_line,
            obscureText: true,
          ),

          if (viewModel.errorMessage != null) ...[
            const SizedBox(height: 8),
            _buildErrorText(viewModel.errorMessage!),
          ],

          const SizedBox(height: 20),

          _buildPrimaryButton(
            text: 'Reset password',
            isLoading: viewModel.isLoading,
            onPressed: () async {
              await viewModel.resetPassword(
                newPassword: _newPasswordController.text,
                passwordConfirmation:
                    _confirmPasswordController.text,
              );
            },
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  // Completed
  // ─────────────────────────────────────────────

  Widget _buildCompletedStep(BuildContext context) {
    return _buildPage(
      icon: MingCuteIcons.mgc_check_circle_fill,
      title: 'Password reset successful',
      subtitle:
          'Your password has been updated successfully.',
      child: _buildPrimaryButton(
        text: 'Back to Sign In',
        onPressed: () {
          Navigator.pop(context);
        },
      ),
    );
  }

  // ─────────────────────────────────────────────
  // Page
  // ─────────────────────────────────────────────

  Widget _buildPage({
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget child,
  }) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          IconButton(
            alignment: Alignment.centerLeft,
            padding: EdgeInsets.zero,
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(
              MingCuteIcons.mgc_left_line,
              color: AppColors.textPrimary,
              size: 24,
            ),
          ),

          const SizedBox(height: 28),

          // Header icon
          Center(
            child: Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.btnPrimary.withValues(alpha: 0.10),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: AppColors.btnPrimary,
                size: 30,
              ),
            ),
          ),

          const SizedBox(height: 20),

          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 26,
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
              height: 1.5,
            ),
          ),

          const SizedBox(height: 28),

          child,
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  // Text Field
  // ─────────────────────────────────────────────

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    TextInputType? keyboardType,
    bool obscureText = false,
    int? maxLength,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      maxLength: maxLength,
      style: const TextStyle(
        color: AppColors.textPrimary,
        fontSize: 14,
      ),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 14,
        ),
        prefixIcon: Icon(
          icon,
          color: AppColors.textSecondary,
          size: 20,
        ),
        filled: true,
        fillColor: AppColors.bgCard,
        counterText: '',
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 15,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: AppColors.textMuted.withValues(alpha: 0.12),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: AppColors.btnPrimary.withValues(alpha: 0.5),
            width: 1.2,
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // Primary Button
  // ─────────────────────────────────────────────

  Widget _buildPrimaryButton({
    required String text,
    required VoidCallback? onPressed,
    bool isLoading = false,
  }) {
    return SizedBox(
      height: 52,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.btnPrimary,
          foregroundColor: Colors.white,
          disabledBackgroundColor:
              AppColors.btnPrimary.withValues(alpha: 0.5),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                width: 21,
                height: 21,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Text(
                text,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // Error
  // ─────────────────────────────────────────────

  Widget _buildErrorText(String message) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(
          MingCuteIcons.mgc_warning_fill,
          color: AppColors.anotherred,
          size: 16,
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            message,
            style: const TextStyle(
              color: AppColors.anotherred,
              fontSize: 12,
              fontWeight: FontWeight.w500,
              height: 1.3,
            ),
          ),
        ),
      ],
    );
  }
}