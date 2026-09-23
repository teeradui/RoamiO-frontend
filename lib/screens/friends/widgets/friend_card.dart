import 'package:flutter/material.dart';
import 'package:roamio_frontend/theme/colors.dart';
import 'package:roamio_frontend/viewmodels/my_friends_view_model.dart';

class FriendCard extends StatelessWidget {
  const FriendCard({
    super.key,
    required this.friend,
    this.trailing,
    this.subtitle,
    this.showReliabilityScore = true,
    this.onTap,
  });

  final FriendItem friend;
  final Widget? trailing;
  final Widget? subtitle;
  final bool showReliabilityScore;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.bgCard,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 25,
                backgroundImage: friend.profileImageUrl != null
                    ? NetworkImage(friend.profileImageUrl!)
                    : const AssetImage('assets/images/default_profile.png'),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      friend.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 1),

                    Row(
                      children: [
                        Text(
                          friend.username,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 15,
                          ),
                        ),

                        if (subtitle != null) ...[
                          const SizedBox(width: 2),
                          const Text(
                            '·',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(width: 2),
                          subtitle!,
                        ],

                        if (showReliabilityScore) ...[
                          const SizedBox(width: 4),
                          ShaderMask(
                            shaderCallback: (bounds) {
                              return const LinearGradient(
                                colors: AppColors.iconPersonalGraph,
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ).createShader(bounds);
                            },
                            child: const Icon(
                              Icons.workspace_premium_rounded,
                              size: 16,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 1),
                          Text(
                            '${friend.reliabilityScore}',
                            style: TextStyle(
                              color: friend.reliabilityScore >= 200
                                  ? AppColors.green
                                  : AppColors.red,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),

              if (trailing != null) trailing!,
            ],
          ),
        ),
      ),
    );
  }
}
