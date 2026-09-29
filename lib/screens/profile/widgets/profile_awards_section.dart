import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:roamio_frontend/theme/colors.dart';
import 'package:roamio_frontend/models/trip_account_model.dart';
import 'package:roamio_frontend/models/trip_award_presets.dart';

class ProfileAwardsSection extends StatelessWidget {
  const ProfileAwardsSection({super.key, required this.awards});

  final List<AccountAward> awards;

  @override
  Widget build(BuildContext context) {
    if (awards.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            ShaderMask(
              shaderCallback: (bounds) {
                return LinearGradient(colors: AppColors.sparkle).createShader(bounds);
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

  Widget _buildAwardItem(AccountAward award) {
    final meta = awardMetaByName[award.awardName];
    final type = meta?.type ?? TripAwardType.other;
    final icon = meta?.icon ?? Icons.emoji_events_rounded;
    final awardColor = getAwardColor(type);

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
          Icon(icon, size: 18, color: awardColor),
          const SizedBox(width: 7),
          Text(
            award.awardName,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}