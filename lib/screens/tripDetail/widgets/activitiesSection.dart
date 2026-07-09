import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:ming_cute_icons/ming_cute_icons.dart';
import 'package:roamio_frontend/theme/colors.dart';
import 'package:roamio_frontend/viewmodels/activitiesSectionViewmodel.dart';

class ActivitiesSection extends StatefulWidget {
  const ActivitiesSection({super.key});

  @override
  State<ActivitiesSection> createState() => _ActivitiesSectionState();
}

class _ActivitiesSectionState extends State<ActivitiesSection> {
  final ActivitiesSectionViewModel viewModel = ActivitiesSectionViewModel();

  @override
  void initState() {
    super.initState();
    viewModel.loadActivities();
  }

  @override
  void dispose() {
    viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: viewModel,
      builder: (context, _) {
        if (!viewModel.hasActivities) {
          return const _EmptyActivities();
        }

        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: viewModel.activities.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final activity = viewModel.activities[index];

            return _ActivityTimelineCard(
              viewModel: viewModel,
              activity: activity,
            );
          },
        );
      },
    );
  }
}

class _ActivityTimelineCard extends StatelessWidget {
  const _ActivityTimelineCard({
    required this.viewModel,
    required this.activity,
  });

  final ActivitiesSectionViewModel viewModel;
  final TripActivityItem activity;

  @override
  Widget build(BuildContext context) {
    final label = viewModel.getActivityLabel(activity.activityType);

    return Container(
      height: 74,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.10),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          SizedBox(
            width: 42,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  activity.timeText,
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  width: 1,
                  height: 22,
                  color: AppColors.textMuted,
                ),
              ],
            ),
          ),

          const SizedBox(width: 14),

          _ActivityIconBox(
            type: activity.activityType,
            gradientColors: viewModel.getActivityGradient(activity.activityType),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 22,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: viewModel.getActivityBgColor(activity.activityType),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Align(
                    alignment: Alignment.center,
                    child: Text(
                      label,
                      style: TextStyle(
                        color: viewModel.getActivityTextColor(
                          activity.activityType,
                        ),
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  "${activity.placeType}, ${activity.placeName} · ${activity.durationText}",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActivityIconBox extends StatelessWidget {
  const _ActivityIconBox({
    required this.type,
    required this.gradientColors,
  });

  final ActivityType type;
  final List<Color> gradientColors;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: AppColors.bgAccent,
        borderRadius: BorderRadius.circular(10),
      ),
      child: ShaderMask(
        shaderCallback: (bounds) {
          return LinearGradient(
            colors: gradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ).createShader(bounds);
        },
        child: _ActivityIcon(type: type),
      ),
    );
  }
}

class _ActivityIcon extends StatelessWidget {
  const _ActivityIcon({
    required this.type,
  });

  final ActivityType type;

  @override
  Widget build(BuildContext context) {
    switch (type) {
      case ActivityType.food:
        return const Icon(
          MingCuteIcons.mgc_fork_knife_fill,
          size: 25,
          color: Colors.white,
        );

      case ActivityType.sightseeing:
        return Icon(
          MingCuteIcons.mgc_umbrella_2_line,
          size: 25,
          color: Colors.white,
        );

      case ActivityType.accommodation:
        return const Icon(
          MingCuteIcons.mgc_hotel_line,
          size: 25,
          color: Colors.white,
        );

      case ActivityType.transit:
        return Icon(
          MingCuteIcons.mgc_bus_2_line,
          size: 25,
          color: Colors.white,
        );
    }
  }
}

class _EmptyActivities extends StatelessWidget {
  const _EmptyActivities();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 48),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FaIcon(
              FontAwesomeIcons.satelliteDish,
              size: 36,
              color: AppColors.textDisabled,
            ),
            SizedBox(height: 10),
            Text(
              "No activities yet",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textDisabled,
              ),
            ),
            SizedBox(height: 8),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                "Your activities will automatically appear here once your trip starts.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textDisabled,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}