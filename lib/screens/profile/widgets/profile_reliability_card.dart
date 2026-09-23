import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:ming_cute_icons/ming_cute_icons.dart';
import 'package:roamio_frontend/screens/profile/widgets/profile_awards_section.dart';
import 'package:roamio_frontend/theme/colors.dart';

class ProfileReliabilityCard extends StatelessWidget {
  const ProfileReliabilityCard({
    super.key,
    required this.profileImage,
    required this.name,
    required this.username,
    required this.tripsCompleted,
    required this.score,
    required this.reliabilityTitle,
    required this.joined,
    required this.attended,
    required this.attendanceRate,
  });

  final ImageProvider profileImage;

  final String name;
  final String username;

  final int tripsCompleted;

  final int score;
  final String reliabilityTitle;

  final int joined;
  final int attended;
  final int attendanceRate;
  

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
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
      child: Column(
        children: [
          _buildProfile(),

          const SizedBox(height: 20),

          _buildReliabilityScoreBox(),
        ],
        
      ),
    );
  }

  Widget _buildProfile() {
    return Column(
      children: [
        Container(
          width: 88,
          height: 88,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.10),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: CircleAvatar(radius: 44, backgroundImage: profileImage),
        ),

        const SizedBox(height: 12),

        Text(
          name,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),

        const SizedBox(height: 1),

        Text(
          username.startsWith('@') ? username : '@$username',
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: AppColors.textMuted,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),

        const SizedBox(height: 4),

        Text(
          '$tripsCompleted trips completed',
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildReliabilityScoreBox() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F0D9),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          // Title
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                MingCuteIcons.mgc_medal_line,
                color: AppColors.textPrimary,
                size: 16,
              ),
              const SizedBox(width: 5),
              const Text(
                'Reliability Credit Score',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),

          const SizedBox(height: 5),

          // Score
          Text(
            '$score',
            style: TextStyle(
              color: score >= 200
                  ? const Color(0xFF4CAF50)
                  : const Color(0xFFD9534F),
              fontSize: 30,
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 2),

          // Reliability title
          Text(
            '"$reliabilityTitle"',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 8),

          // Starting score
          const Text(
            'Starting score: 200',
            style: TextStyle(
              color: AppColors.textMuted,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),

          const SizedBox(height: 8),

          // Score bar
          _buildScoreBar(),

          const SizedBox(height: 10),

          // Statistics
          _buildStatistics(),
        ],
      ),
    );
  }

  Widget _buildScoreBar() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        // Score range: 0 - 400
        // Starting score 200 = center
        final normalizedScore = (score.clamp(0, 400) / 400).toDouble();

        final markerPosition = width * normalizedScore;

        return SizedBox(
          height: 20,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                height: 8,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFFD9534F),
                      Color(0xFFE8A94A),
                      Color(0xFF8BC34A),
                      Color(0xFF4CAF50),
                    ],
                  ),
                ),
              ),

              Positioned(
                left: math.max(0, math.min(markerPosition - 7, width - 14)),
                child: Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: score >= 200
                          ? const Color(0xFF4CAF50)
                          : const Color(0xFFD9534F),
                      width: 3,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.12),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatistics() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildStat(label: 'Joined', value: '$joined'),
        _buildStat(label: 'Attended', value: '$attended'),
        _buildStat(label: 'Rate', value: '$attendanceRate%'),
      ],
    );
  }

  Widget _buildStat({required String label, required String value}) {
    return Text(
      '$label: $value',
      style: const TextStyle(
        color: AppColors.textMuted,
        fontSize: 12,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
