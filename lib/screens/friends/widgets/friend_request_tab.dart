import 'package:flutter/material.dart';
import 'package:ming_cute_icons/ming_cute_icons.dart';
import 'package:provider/provider.dart';
import 'package:roamio_frontend/screens/friends/friend_profile_screen.dart';
import 'package:roamio_frontend/screens/friends/widgets/friend_card.dart';
import 'package:roamio_frontend/theme/colors.dart';
import 'package:roamio_frontend/viewmodels/friend_request_view_model.dart';

class FriendRequestTab extends StatelessWidget {
  const FriendRequestTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const _FriendRequestContent();
  }
}

class _FriendRequestContent extends StatelessWidget {
  const _FriendRequestContent();

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

  String _formatRequestTime(DateTime? time) {
    if (time == null) return '';

    final difference = DateTime.now().difference(time);

    if (difference.inMinutes < 1) {
      return 'now';
    }

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} min ago';
    }

    if (difference.inHours < 24) {
      return '${difference.inHours} hr ago';
    }

    if (difference.inDays < 7) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    }

    return '${difference.inDays ~/ 7} week${difference.inDays ~/ 7 == 1 ? '' : 's'} ago';
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<FriendRequestViewModel>(
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

        if (viewModel.requests.isEmpty) {
          return _buildEmptyState(
            icon: MingCuteIcons.mgc_user_add_2_line,
            title: 'No friend requests',
            message: 'You’re all caught up! New requests will appear here.',
          );
        }

        return ListView.separated(
          padding: EdgeInsets.zero,
          itemCount: viewModel.requests.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final request = viewModel.requests[index];

            return FriendCard(
              friend: request,
              subtitle: Text(
                _formatRequestTime(request.requestTime),
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
              ),
              showReliabilityScore: false,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => FriendProfileScreen(userId: request.userId),
                  ),
                );
              },
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppColors.bgGreen,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      onPressed: () async {
                        await viewModel.acceptRequest(request.userId);

                        final error = viewModel.responseErrorMessage;

                        if (context.mounted && error != null) {
                          ScaffoldMessenger.of(
                            context,
                          ).showSnackBar(SnackBar(content: Text(error)));
                        }
                      },
                      icon: const Icon(
                        Icons.check,
                        color: AppColors.green,
                        size: 18,
                      ),
                    ),
                  ),

                  const SizedBox(width: 6),

                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppColors.bgRed,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      onPressed: () async {
                        await viewModel.declineRequest(request.userId);

                        final error = viewModel.responseErrorMessage;

                        if (context.mounted && error != null) {
                          ScaffoldMessenger.of(
                            context,
                          ).showSnackBar(SnackBar(content: Text(error)));
                        }
                      },
                      icon: const Icon(
                        Icons.close,
                        color: AppColors.red,
                        size: 18,
                      ),
                    ),
                  ),

                  const SizedBox(width: 4),

                  const Icon(
                    Icons.chevron_right_rounded,
                    size: 26,
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
