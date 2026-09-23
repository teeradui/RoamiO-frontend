import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ming_cute_icons/ming_cute_icons.dart';
import 'package:roamio_frontend/theme/colors.dart';
import 'package:roamio_frontend/viewmodels/settings_view_model.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SettingsViewModel(),
      child: const _SettingsView(),
    );
  }
}

class _SettingsView extends StatelessWidget {
  const _SettingsView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      appBar: AppBar(
        backgroundColor: AppColors.bgPrimary,
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            MingCuteIcons.mgc_left_line,
            color: AppColors.black,
            size: 24,
          ),
        ),
        title: const Text(
          'Settings',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: Consumer<SettingsViewModel>(
        builder: (context, viewModel, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
            child: Column(
              children: [
                _buildProfilePicture(context, viewModel),

                const SizedBox(height: 28),

                _buildSettingItem(
                  context,
                  icon: FluentIcons.share_screen_person_overlay_inside_16_regular,
                  title: 'Change name',
                  onTap: () => _showChangeNameDialog(
                    context,
                    viewModel,
                  ),
                ),

                const SizedBox(height: 10),

                _buildSettingItem(
                  context,
                  icon: FluentIcons.password_16_regular,
                  title: 'Change password',
                  onTap: () => _showChangePasswordDialog(
                    context,
                    viewModel,
                  ),
                ),

                const SizedBox(height: 10),

                _buildSettingItem(
                  context,
                  icon: MingCuteIcons.mgc_delete_2_fill,
                  title: 'Delete account',
                  isDestructive: true,
                  onTap: () => _showDeleteAccountDialog(
                    context,
                    viewModel,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfilePicture(
    BuildContext context,
    SettingsViewModel viewModel,
  ) {
    return Column(
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 112,
              height: 112,
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.btnPrimary.withValues(alpha: 0.25),
                  width: 2,
                ),
              ),
              child: CircleAvatar(
                radius: 53,
                backgroundImage: AssetImage(
                  viewModel.profileImagePath,
                ),
              ),
            ),
            Positioned(
              right: -2,
              bottom: -2,
              child: GestureDetector(
                onTap: () {
                  // TODO: open image picker
                },
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.bgCard,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.bgPrimary,
                      width: 3,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.10),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    MingCuteIcons.mgc_camera_2_fill,
                    color: AppColors.textPrimary,
                    size: 18,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        const Text(
          'Change profile picture',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildSettingItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    final itemColor = isDestructive
        ? AppColors.anotherred
        : AppColors.textPrimary;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 18,
              vertical: 15,
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: itemColor,
                  size: 22,
                ),

                const SizedBox(width: 13),

                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: itemColor,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

                const Icon(
                  MingCuteIcons.mgc_right_line,
                  color: AppColors.textSecondary,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // Change Name
  // ─────────────────────────────────────────────

  void _showChangeNameDialog(
    BuildContext context,
    SettingsViewModel viewModel,
  ) {
    final controller = TextEditingController(
      text: viewModel.name,
    );

    showDialog(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.fromLTRB(22, 22, 22, 18),
            decoration: BoxDecoration(
              color: AppColors.bgCard,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDialogIcon(
                  FluentIcons.share_screen_person_overlay_inside_16_regular,
                  AppColors.btnPrimary,
                ),

                const SizedBox(height: 16),

                const Text(
                  'Change name',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 8),

                const Text(
                  'Enter your new name below.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),

                const SizedBox(height: 20),

                _buildTextField(
                  controller: controller,
                  hintText: 'Enter your name',
                  icon: FluentIcons.share_screen_person_overlay_inside_16_regular,
                ),

                const SizedBox(height: 20),

                _buildDialogButtons(
                  dialogContext: dialogContext,
                  cancelText: 'Cancel',
                  confirmText: 'Save',
                  onConfirm: () {
                    final name = controller.text.trim();

                    if (name.isNotEmpty) {
                      viewModel.changeName(name);
                    }

                    Navigator.pop(dialogContext);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ─────────────────────────────────────────────
  // Change Password
  // ─────────────────────────────────────────────

  void _showChangePasswordDialog(
    BuildContext context,
    SettingsViewModel viewModel,
  ) {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.fromLTRB(22, 22, 22, 18),
            decoration: BoxDecoration(
              color: AppColors.bgCard,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDialogIcon(
                  FluentIcons.password_16_regular,
                  AppColors.btnPrimary,
                ),

                const SizedBox(height: 16),

                const Text(
                  'Change password',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 8),

                const Text(
                  'Enter your current and new password.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),

                const SizedBox(height: 20),

                _buildTextField(
                  controller: currentPasswordController,
                  hintText: 'Current password',
                  icon: FluentIcons.password_16_regular,
                  obscureText: true,
                ),

                const SizedBox(height: 10),

                _buildTextField(
                  controller: newPasswordController,
                  hintText: 'New password',
                  icon: FluentIcons.password_16_regular,
                  obscureText: true,
                ),

                const SizedBox(height: 10),

                _buildTextField(
                  controller: confirmPasswordController,
                  hintText: 'Confirm new password',
                  icon: FluentIcons.password_16_regular,
                  obscureText: true,
                ),

                const SizedBox(height: 20),

                _buildDialogButtons(
                  dialogContext: dialogContext,
                  cancelText: 'Cancel',
                  confirmText: 'Save',
                  onConfirm: () async {
                    final success = await viewModel.changePassword(
                      currentPassword: currentPasswordController.text,
                      newPassword: newPasswordController.text,
                      confirmPassword: confirmPasswordController.text,
                    );

                    if (!dialogContext.mounted) return;

                    Navigator.pop(dialogContext);

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          success
                              ? 'Password changed successfully.'
                              : 'Unable to change password.',
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ─────────────────────────────────────────────
  // Delete Account
  // ─────────────────────────────────────────────

  void _showDeleteAccountDialog(
    BuildContext context,
    SettingsViewModel viewModel,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.fromLTRB(22, 22, 22, 18),
            decoration: BoxDecoration(
              color: AppColors.bgCard,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDialogIcon(
                  MingCuteIcons.mgc_delete_2_fill,
                  AppColors.anotherred,
                ),

                const SizedBox(height: 16),

                const Text(
                  'Delete account',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 8),

                const Text(
                  'Are you sure you want to delete your account? '
                  'This action cannot be undone.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),

                const SizedBox(height: 22),

                _buildDialogButtons(
                  dialogContext: dialogContext,
                  cancelText: 'Cancel',
                  confirmText: 'Delete',
                  confirmColor: AppColors.anotherred,
                  onConfirm: () async {
                    Navigator.pop(dialogContext);

                    final success = await viewModel.deleteAccount();

                    if (!context.mounted) return;

                    if (success) {
                      // TODO: navigate to Sign In later
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ─────────────────────────────────────────────
  // Dialog Components
  // ─────────────────────────────────────────────

  Widget _buildDialogIcon(
    IconData icon,
    Color color,
  ) {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        shape: BoxShape.circle,
      ),
      child: Icon(
        icon,
        color: color,
        size: 25,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    bool obscureText = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
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
          size: 19,
        ),
        filled: true,
        fillColor: AppColors.bgPrimary,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 13,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: AppColors.textMuted.withValues(alpha: 0.15),
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

  Widget _buildDialogButtons({
    required BuildContext dialogContext,
    required String cancelText,
    required String confirmText,
    required VoidCallback onConfirm,
    Color confirmColor = AppColors.btnPrimary,
  }) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.textSecondary,
              side: BorderSide(
                color: AppColors.textMuted.withValues(alpha: 0.25),
              ),
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: Text(
              cancelText,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),

        const SizedBox(width: 10),

        Expanded(
          child: ElevatedButton(
            onPressed: onConfirm,
            style: ElevatedButton.styleFrom(
              backgroundColor: confirmColor,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: Text(
              confirmText,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ],
    );
  }
}