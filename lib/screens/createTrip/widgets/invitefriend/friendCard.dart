import 'package:flutter/material.dart';
import 'package:roamio_frontend/models/friendModel.dart';
import 'package:roamio_frontend/theme/colors.dart';

class FriendCard extends StatelessWidget {
  const FriendCard({
    super.key,
    required this.friend,
    required this.isSelected,
    required this.onTap,
  });

  final FriendModel friend;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 26,
              backgroundColor: AppColors.bgAccent,
              backgroundImage: friend.profileImageUrl == null
                  ? null
                  : NetworkImage(friend.profileImageUrl!),
              child: friend.profileImageUrl == null
                  ? const Icon(
                      Icons.person,
                      color: AppColors.textSecondary,
                    )
                  : null,
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    friend.username,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Reliability ${friend.reliabilityScore.toStringAsFixed(0)}%",
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),

            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected
                    ? AppColors.btnPrimary
                    : Colors.transparent,
                border: Border.all(
                  color: isSelected
                      ? AppColors.btnPrimary
                      : AppColors.tabInactive,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? const Icon(
                      Icons.check,
                      color: AppColors.bgPrimary,
                      size: 18,
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}