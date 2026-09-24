import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:ming_cute_icons/ming_cute_icons.dart';
import 'package:roamio_frontend/theme/colors.dart';
import 'package:roamio_frontend/viewmodels/story_trip_awards_view_model.dart';

class ProfileAwardsSection extends StatelessWidget {
  const ProfileAwardsSection({super.key, required this.awards});

  final List<StoryTripAward> awards;

  @override
  Widget build(BuildContext context) {
    if (awards.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Awards header — อยู่นอกการ์ด
        Row(
          children: [
            ShaderMask(
              shaderCallback: (bounds) {
                return LinearGradient(
                  colors: AppColors.sparkle,
                ).createShader(bounds);
              },
              child: const Icon(
                FluentIcons.star_emphasis_24_filled,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 7),
            const Text(
              'Awards',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),

        const SizedBox(height: 4),

        const Text(
          'Achievements earned from your trips',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 13,
            fontWeight: FontWeight.w400,
          ),
        ),

        const SizedBox(height: 12),

        // การ์ด
        Container(
  width: double.infinity,
  padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
  decoration: BoxDecoration(
    color: AppColors.bgCard,
    borderRadius: BorderRadius.circular(24),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.08),
        blurRadius: 10,
        offset: const Offset(0, 4),
      ),
    ],
  ),
  child: SingleChildScrollView(
  scrollDirection: Axis.horizontal,
  child: ConstrainedBox(
    constraints: BoxConstraints(
      minWidth: MediaQuery.of(context).size.width - 40,
    ),
    child: Wrap(
      spacing: 8,
      runSpacing: 8,
      children: awards.map((award) {
        return _buildAwardItem(award);
      }).toList(),
      ),
    ),
  ),
),
      ],
    );
  }

  Widget _buildAwardItem(StoryTripAward award) {
    final awardColor = _getAwardColor(award.type);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: awardColor.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: awardColor.withValues(alpha: 0.18), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(award.awardIcon, size: 18, color: awardColor),

          const SizedBox(width: 7),

          Text(
            award.awardTitle,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Color _getAwardColor(TripAwardType type) {
    switch (type) {
      case TripAwardType.lateArrival:
        return const Color(0xFFF7630D);

      case TripAwardType.earlyArrival:
        return const Color(0xFFECA205);

      case TripAwardType.food:
        return const Color(0xFFFF8340);

      case TripAwardType.sightseeing:
        return const Color(0xFF36A1C7);

      case TripAwardType.accommodation:
        return const Color(0xFF8E5CF7);

      case TripAwardType.transit:
        return const Color(0xFF2D7DFB);

      case TripAwardType.other:
        return const Color(0xFF9E9E9E);
    }
  }
}
