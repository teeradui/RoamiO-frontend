import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:roamio_frontend/screens/profile/settings_screen.dart';
import 'package:roamio_frontend/screens/profile/widgets/profile_awards_section.dart';
import 'package:roamio_frontend/screens/profile/widgets/score_history_section.dart';
import 'package:roamio_frontend/screens/profile/widgets/scoring_rule.dart';
import 'package:roamio_frontend/theme/colors.dart';
import 'package:roamio_frontend/viewmodels/profile_view_model.dart';
import 'package:roamio_frontend/screens/profile/widgets/profile_reliability_card.dart';
import 'package:hugeicons/hugeicons.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ProfileViewModel(),
      child: const _ProfileView(),
    );
  }
}

class _ProfileView extends StatelessWidget {
  const _ProfileView();

  void _showLogoutDialog(BuildContext context) {
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
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.12),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icon
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: AppColors.anotherred.withValues(alpha: 0.10),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.logout_rounded,
                    color: AppColors.anotherred,
                    size: 26,
                  ),
                ),

                const SizedBox(height: 16),

                // Title
                const Text(
                  'Log out',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 8),

                // Description
                const Text(
                  'Are you sure you want to log out?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    height: 1.4,
                  ),
                ),

                const SizedBox(height: 22),

                // Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.of(dialogContext).pop();
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.textSecondary,
                          side: BorderSide(
                            color: AppColors.textMuted.withValues(alpha: 0.3),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 10),

                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          Navigator.of(dialogContext).pop();
                          await context.read<ProfileViewModel>().logout();

                          // TODO: navigate to Sign In screen
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.anotherred,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text(
                          'Log out',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
          child: Column(
            children: [
              // =========================
              // Header
              // =========================
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Title
                  const Expanded(
                    child: Text(
                      'My profile',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),

                  // Settings
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.bgCard,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: IconButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const SettingsScreen(),
                          ),
                        );
                      },
                      padding: EdgeInsets.zero,
                      icon: HugeIcon(
                        icon: HugeIcons.strokeRoundedSettings01,
                        color: AppColors.black,
                        size: 25,
                      ),
                    ),
                  ),

                  const SizedBox(width: 10),

                  // Logout
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.bgCard,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: IconButton(
                      onPressed: () {
                        _showLogoutDialog(context);
                      },
                      padding: EdgeInsets.zero,
                      icon: HugeIcon(
                        icon: HugeIcons.strokeRoundedLogout01,
                        color: AppColors.anotherred,
                        size: 25,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              Expanded(
                child: SingleChildScrollView(
                  child: Consumer<ProfileViewModel>(
                    builder: (context, viewModel, child) {
                      return Column(
                        children: [
                          ProfileReliabilityCard(
                            profileImage: viewModel.profileImageUrl != null
                                ? NetworkImage(viewModel.profileImageUrl!)
                                : const AssetImage(
                                    'assets/images/default_profile.png',
                                  ),
                            name: viewModel.name,
                            username: viewModel.username,
                            tripsCompleted: viewModel.tripsCompleted,
                            score: viewModel.reliabilityScore,
                            reliabilityTitle: viewModel.reliabilityTitle,
                            joined: viewModel.joined,
                            attended: viewModel.attended,
                            attendanceRate: viewModel.attendanceRate,
                          ),

                          const SizedBox(height: 15),

                          ProfileAwardsSection(awards: viewModel.awards),

                          const SizedBox(height: 15),

                          const ScoreHistorySection(),

                          const SizedBox(height: 5),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
