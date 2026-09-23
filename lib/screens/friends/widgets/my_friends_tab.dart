import 'package:flutter/material.dart';
import 'package:roamio_frontend/theme/colors.dart';
import 'package:hugeicons/hugeicons.dart';

class MyFriendsTab extends StatelessWidget {
  const MyFriendsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        _buildFriendCard(
          name: 'Mina',
          username: '@mina',
        ),
        const SizedBox(height: 10),
        _buildFriendCard(
          name: 'Jane',
          username: '@jane',
        ),
        const SizedBox(height: 10),
        _buildFriendCard(
          name: 'Mark',
          username: '@mark',
        ),
      ],
    );
  }

  Widget _buildFriendCard({
    required String name,
    required String username,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 25,
            backgroundImage: AssetImage(
              'assets/images/default_profile.png',
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  username,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const HugeIcon(
            icon: HugeIcons.strokeRoundedUserCheck01,
            color: AppColors.tabActive,
            size: 22,
          ),
        ],
      ),
    );
  }
}