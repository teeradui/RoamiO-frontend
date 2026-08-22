import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:roamio_frontend/theme/colors.dart';
import 'package:roamio_frontend/viewmodels/trip_card_view_model.dart';

class TripCard extends StatelessWidget {
  const TripCard({
    super.key,
    required this.viewModel,
    this.onTap,
  });

  final TripCardViewModel viewModel;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: .04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Container(
                width: 88,
                height: 88,
                color: AppColors.bgAccent,
                child: viewModel.imageUrl == null ||
                        viewModel.imageUrl!.isEmpty
                    ? const Icon(
                        Icons.image_outlined,
                        color: AppColors.textMuted,
                      )
                    : Image.network(
                        viewModel.imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) {
                          return const Icon(
                            Icons.broken_image_outlined,
                            color: AppColors.textMuted,
                          );
                        },
                      ),
              ),
            ),

            const SizedBox(width: 16),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          viewModel.tripName,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),

                      const SizedBox(width: 8),

                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: viewModel.statusBackgroundColor,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            HugeIcon(
                              icon: viewModel.statusIcon,
                              size: 14,
                              color: viewModel.statusColor,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              viewModel.statusText,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: viewModel.statusColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 5),

                  // Trip destination
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 16,
                        color: AppColors.textMuted,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          viewModel.tripDestination,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 6),

                  // Start date
                  Row(
                    children: [
                      const Icon(
                        Icons.calendar_today_outlined,
                        size: 16,
                        color: AppColors.textMuted,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        viewModel.formattedStartDate,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  Row(
                    children: [
                      const Icon(
                        Icons.photo_camera_outlined,
                        size: 16,
                        color: AppColors.textMuted,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        "${viewModel.photoCount} Photos",
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      const SizedBox(width: 12),

                      const Icon(
                        Icons.location_on_outlined,
                        size: 16,
                        color: AppColors.textMuted,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        "${viewModel.placeCount} Places",
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  _TripMemberAvatarStack(
                    members: viewModel.members,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TripMemberAvatarStack extends StatelessWidget {
  const _TripMemberAvatarStack({
    required this.members,
  });

  final List<TripCardMember> members;

  static const int maxVisibleMembers = 4;
  static const double avatarRadius = 15;
  static const double overlapOffset = 22;

  @override
  Widget build(BuildContext context) {
    if (members.isEmpty) {
      return const SizedBox.shrink();
    }

    final visibleMembers = members.take(maxVisibleMembers).toList();
    final remainingCount = members.length - visibleMembers.length;

    final totalItems =
        visibleMembers.length + (remainingCount > 0 ? 1 : 0);

    final stackWidth =
        (totalItems - 1) * overlapOffset + avatarRadius * 2;

    return SizedBox(
      height: avatarRadius * 2,
      width: stackWidth,
      child: Stack(
        children: [
          ...visibleMembers.asMap().entries.map((entry) {
            final index = entry.key;
            final member = entry.value;

            return Positioned(
              left: index * overlapOffset,
              child: _MemberAvatar(
                member: member,
              ),
            );
          }),

          if (remainingCount > 0)
            Positioned(
              left: visibleMembers.length * overlapOffset,
              child: CircleAvatar(
                radius: avatarRadius,
                backgroundColor: AppColors.bgHighlight,
                child: Text(
                  "+$remainingCount",
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _MemberAvatar extends StatelessWidget {
  const _MemberAvatar({
    required this.member,
  });

  final TripCardMember member;

  @override
  Widget build(BuildContext context) {
    final hasImage = member.profileImageUrl != null &&
        member.profileImageUrl!.isNotEmpty;

    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: AppColors.bgCard,
          width: 2,
        ),
      ),
      child: CircleAvatar(
        radius: 15,
        backgroundColor: AppColors.bgAccent,
        backgroundImage: hasImage
            ? NetworkImage(member.profileImageUrl!)
            : null,
        child: !hasImage
            ? const Icon(
                Icons.person,
                size: 17,
                color: AppColors.textSecondary,
              )
            : null,
      ),
    );
  }
}