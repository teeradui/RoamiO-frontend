import 'package:flutter/material.dart';
import 'package:ming_cute_icons/ming_cute_icons.dart';
import 'package:provider/provider.dart';
import 'package:roamio_frontend/screens/friends/friend_profile_screen.dart';
import 'package:roamio_frontend/screens/friends/widgets/friend_card.dart';
import 'package:roamio_frontend/theme/colors.dart';
import 'package:roamio_frontend/viewmodels/my_friends_view_model.dart';

class MyFriendsTab extends StatelessWidget {
  const MyFriendsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => MyFriendsViewModel() /*..loadFriends()*/,
      child: const _MyFriendsContent(),
    );
  }
}

class _MyFriendsContent extends StatelessWidget {
  const _MyFriendsContent();

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String message,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 34, color: AppColors.textMuted),
          

          const SizedBox(height: 16),

          Text(
            title,
            style: const TextStyle(
              color: AppColors.textMuted,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 6),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textMuted,
                fontSize: 16,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MyFriendsViewModel>(
      builder: (context, viewModel, _) {
        if (viewModel.errorMessage != null) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                viewModel.errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          );
        }

        if (viewModel.friends.isEmpty) {
          return _buildEmptyState(
            icon: MingCuteIcons.mgc_user_2_line,
            title: 'No friends yet',
            message:
                'Start connecting with people and build your travel circle.',
          );
        }

        return ListView.separated(
          padding: EdgeInsets.zero,
          itemCount: viewModel.friends.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final friend = viewModel.friends[index];

            return FriendCard(
              friend: friend,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => FriendProfileScreen(userId: friend.userId),
                  ),
                );
              },
              showReliabilityScore: true,
              trailing: const Icon(
                Icons.chevron_right_rounded,
                size: 26,
                color: AppColors.textSecondary,
              ),
            );
          },
        );
      },
    );
  }
}
