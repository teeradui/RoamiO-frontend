import 'package:flutter/material.dart';
import 'package:ming_cute_icons/ming_cute_icons.dart';
import 'package:provider/provider.dart';
import 'package:roamio_frontend/screens/friends/friend_profile_screen.dart';
import 'package:roamio_frontend/screens/friends/widgets/friend_card.dart';
import 'package:roamio_frontend/theme/colors.dart';
import 'package:roamio_frontend/viewmodels/friend_recommend_view_model.dart';
import 'package:roamio_frontend/viewmodels/my_friends_view_model.dart';

class FriendRecommendTab extends StatelessWidget {
  const FriendRecommendTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => FriendRecommendViewModel()..loadRecommendations(),
      child: const _FriendRecommendContent(),
    );
  }
}

class _FriendRecommendContent extends StatelessWidget {
  const _FriendRecommendContent();

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

  Widget _buildFriendRequestAction(
    BuildContext context,
    FriendRecommendViewModel viewModel,
    FriendItem friend,
  ) {
    final status = viewModel.getRequestStatus(friend.userId);

    if (status == FriendRequestStatus.friends) {
      return const Text(
        'Friends',
        style: TextStyle(
          color: AppColors.textSecondary,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      );
    }

    if (status == FriendRequestStatus.pending) {
      return const Text(
        'Pending',
        style: TextStyle(
          color: AppColors.textSecondary,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      );
    }

    return IconButton(
      onPressed: () async {
        await viewModel.sendFriendRequest(friend.userId);

        final error = viewModel.getRequestError(friend.userId);

        if (context.mounted && error != null) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(error)));
        }
      },
      icon: const Icon(
        MingCuteIcons.mgc_user_add_2_line,
        color: AppColors.btnPrimary,
        size: 24,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<FriendRecommendViewModel>(
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

        if (viewModel.recommendations.isEmpty) {
          return _buildEmptyState(
            icon: MingCuteIcons.mgc_user_search_line,
            title: 'No recommendations',
            message:
                'We’ll show you people you may know or want to connect with.',
          );
        }

        return ListView.separated(
          padding: EdgeInsets.zero,
          itemCount: viewModel.recommendations.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final friend = viewModel.recommendations[index];

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
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildFriendRequestAction(context, viewModel, friend),
                  const Icon(
                    Icons.chevron_right_rounded,
                    size: 24,
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
