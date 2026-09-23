import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:roamio_frontend/theme/colors.dart';
import 'package:roamio_frontend/viewmodels/friend_profile_view_model.dart';

import 'package:roamio_frontend/screens/profile/widgets/profile_reliability_card.dart';
import 'package:roamio_frontend/screens/profile/widgets/profile_awards_section.dart';
import 'package:roamio_frontend/screens/profile/widgets/score_history_section.dart';

class FriendProfileScreen extends StatelessWidget {
  const FriendProfileScreen({super.key, required this.userId});

  final String userId;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => FriendProfileViewModel(userId: userId),
      child: const _FriendProfileView(),
    );
  }
}

class _FriendProfileView extends StatelessWidget {
  const _FriendProfileView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
          child: Column(
            children: [
              _buildHeader(context),

              const SizedBox(height: 20),

              Expanded(
                child: SingleChildScrollView(
                  child: Consumer<FriendProfileViewModel>(
                    builder: (context, viewModel, child) {
                      return Column(
                        children: [
                          ProfileReliabilityCard(
                            profileImage: AssetImage(
                              viewModel.profileImagePath,
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

                          ScoreHistorySection(userId: viewModel.userId),

                          const SizedBox(height: 15),
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

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          padding: EdgeInsets.zero,
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.textPrimary,
            size: 20,
          ),
        ),

        const SizedBox(width: 8),

        const Text(
          'Friend profile',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 24,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
