import 'package:flutter/material.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:ming_cute_icons/ming_cute_icons.dart';
import 'package:roamio_frontend/theme/colors.dart';
import 'package:roamio_frontend/viewmodels/story_reliability_scores_view_model.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';

class ScoringRuleContent extends StatelessWidget {
  const ScoringRuleContent({super.key});

  Widget _buildReliabilityRuleItem({
    required ReliabilityArrivalStatus status,
    required String title,
    required String description,
    required String score,
  }) {
    IconData icon;

    switch (status) {
      case ReliabilityArrivalStatus.arrivedEarly:
        icon = MingCuteIcons.mgc_run_fill;
        break;

      case ReliabilityArrivalStatus.onTime:
        icon = MdiIcons.clockCheck;
        break;

      case ReliabilityArrivalStatus.slightDelay:
        icon = MdiIcons.clockRemove;
        break;

      case ReliabilityArrivalStatus.extendedDelay:
        icon = MdiIcons.alarmLight;
        break;

      case ReliabilityArrivalStatus.ghost:
        icon = TablerIcons.ghost2Filled;
        break;
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ShaderMask(
          shaderCallback: (bounds) {
            return getStatusGradient(status).createShader(bounds);
          },
          child: Icon(icon, color: Colors.white, size: 32),
        ),

        const SizedBox(width: 12),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),

                  const SizedBox(width: 8),

                  Text(
                    score,
                    style: TextStyle(
                      color: score.startsWith('+') ? Colors.green : Colors.red,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 6),

              Text(
                description,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  LinearGradient getStatusGradient(ReliabilityArrivalStatus status) {
    switch (status) {
      case ReliabilityArrivalStatus.arrivedEarly:
        return AppColors.arrivedEarlyGradient;

      case ReliabilityArrivalStatus.onTime:
        return AppColors.onTimeGradient;

      case ReliabilityArrivalStatus.slightDelay:
        return AppColors.slightDelayGradient;

      case ReliabilityArrivalStatus.extendedDelay:
        return AppColors.extendedDelayGradient;

      case ReliabilityArrivalStatus.ghost:
        return AppColors.ghostGradient;
    }
  }

  Widget _buildReliabilityRuleDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Divider(height: 1, thickness: 1, color: AppColors.bgPrimary),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            ShaderMask(
              shaderCallback: (bounds) {
                return const LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: AppColors.gradientMap,
                ).createShader(bounds);
              },
              child: const Icon(
                MingCuteIcons.mgc_inventory_fill,
                color: Colors.white,
                size: 22,
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              'Scoring Rules',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),

        const SizedBox(height: 6),

        const Text(
          'Auto-detected via GPS location at trip start time',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 13,
            fontWeight: FontWeight.w400,
          ),
        ),

        const SizedBox(height: 10),

        // Attendance Detection Card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppColors.bgCard,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ShaderMask(
                    shaderCallback: (bounds) {
                      return const LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: AppColors.gradientUpAc,
                      ).createShader(bounds);
                    },
                    child: const Icon(
                      MingCuteIcons.mgc_base_station_fill,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      'How attendance is detected',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  HugeIcon(
                    icon: HugeIcons.strokeRoundedLocation01,
                    color: AppColors.btnPrimary,
                    size: 22,
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: 'With meeting point: ',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          TextSpan(
                            text:
                                'App checks if your phone is within the set location at trip start time.',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 13,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  HugeIcon(
                    icon: HugeIcons.strokeRoundedClock01,
                    color: AppColors.black,
                    size: 22,
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: 'No meeting point: ',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          TextSpan(
                            text:
                                'If majority of members (e.g. 3/5) are at the same location for 15+ min, that spot becomes the auto meeting point.',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 13,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Reliability Scoring Card
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
          child: Column(
            children: [
              _buildReliabilityRuleItem(
                status: ReliabilityArrivalStatus.arrivedEarly,
                title: 'Arrived early',
                description:
                    'location detected at meeting point more than 5 minutes before trip start.',
                score: '+25',
              ),

              _buildReliabilityRuleDivider(),

              _buildReliabilityRuleItem(
                status: ReliabilityArrivalStatus.onTime,
                title: 'On time',
                description:
                    'Arrived up to 5 min before or 5 min after trip start.',
                score: '+15',
              ),

              _buildReliabilityRuleDivider(),

              _buildReliabilityRuleItem(
                status: ReliabilityArrivalStatus.slightDelay,
                title: 'Slight delay',
                description:
                    'location detected more than 5 min until 30 min after trip start',
                score: '-10',
              ),

              _buildReliabilityRuleDivider(),

              _buildReliabilityRuleItem(
                status: ReliabilityArrivalStatus.extendedDelay,
                title: 'Extended delay',
                description:
                    'Location detected more than 30 min after trip start',
                score: '-20',
              ),

              _buildReliabilityRuleDivider(),

              _buildReliabilityRuleItem(
                status: ReliabilityArrivalStatus.ghost,
                title: 'Ghost',
                description: 'Location never detected at meeting point',
                score: '-30',
              ),
            ],
          ),
        ),
      ],
    );
  }
}
