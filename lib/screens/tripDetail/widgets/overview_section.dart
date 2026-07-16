import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:ming_cute_icons/ming_cute_icons.dart';
import 'package:roamio_frontend/theme/colors.dart';
import 'package:roamio_frontend/viewmodels/overview_section_view_model.dart';
import 'package:roamio_frontend/viewmodels/trip_detail_view_model.dart';

class OverviewSection extends StatefulWidget {
  const OverviewSection({
    super.key,
    required this.tripId,
    required this.tripStatus,
  });

  final String tripId;
  final TripStatus tripStatus;

  @override
  State<OverviewSection> createState() => _OverviewSectionState();
}

class _OverviewSectionState extends State<OverviewSection> {
  late final OverviewSectionViewModel viewModel;

  @override
  void initState() {
    super.initState();

    viewModel = OverviewSectionViewModel(
      tripId: widget.tripId,
      tripStatus: widget.tripStatus,
    );

    viewModel.loadOverview();
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
        if (viewModel.isLoading) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 60),
            child: Center(
              child: CircularProgressIndicator(color: AppColors.btnPrimary),
            ),
          );
        }

        return Column(
          children: [
            if (viewModel.errorMessage != null) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: AppColors.bgCard,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.error_outline_rounded,
                      color: AppColors.btnPrimary,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        viewModel.errorMessage!,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: viewModel.loadOverview,
                      icon: const Icon(
                        Icons.refresh_rounded,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
            Row(
              children: [
                Expanded(
                  child: _OverviewMiniCard(
                    icon: HugeIcons.strokeRoundedCamera01,
                    count: viewModel.photosCount,
                    label: "Photos",
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _OverviewMiniCard(
                    icon: HugeIcons.strokeRoundedLocation01,
                    count: viewModel.placesCount,
                    label: "Places",
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _OverviewMiniCard(
                    icon: HugeIcons.strokeRoundedNavigation04,
                    count: viewModel.activitiesCount,
                    label: "Activities",
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            if (viewModel.isEmpty)
              const _ActivitiesEmptyOverview()
            else ...[
              _ActivitiesDetectedCard(viewModel: viewModel),
            ],

            const SizedBox(height: 16),

            if (viewModel.isEmpty)
              const _UpcomingEmptyOverview()
            else
              _ActiveOverviewCard(viewModel: viewModel),
          ],
        );
      },
    );
  }
}

class _OverviewMiniCard extends StatelessWidget {
  const _OverviewMiniCard({
    required this.icon,
    required this.count,
    required this.label,
  });

  final dynamic icon;
  final int count;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          HugeIcon(icon: icon, size: 16, color: AppColors.btnPrimary),
          const SizedBox(height: 1),
          Text(
            "$count",
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActiveOverviewCard extends StatelessWidget {
  const _ActiveOverviewCard({required this.viewModel});

  final OverviewSectionViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 14),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: AppColors.gradientUpAc,
                ).createShader(bounds),
                child: const Icon(
                  MingCuteIcons.mgc_location_2_fill,
                  size: 22,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                "Places Visited",
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          if (viewModel.hasPlaces)
            Column(
              children: viewModel.places.asMap().entries.map((entry) {
                final index = entry.key;
                final place = entry.value;

                return _PlaceVisitedTile(
                  place: place,
                  isLast: index == viewModel.places.length - 1,
                );
              }).toList(),
            )
          else
            const Text(
              "Places will appear as you travel.",
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
        ],
      ),
    );
  }
}

class _ActivitiesDetectedCard extends StatelessWidget {
  const _ActivitiesDetectedCard({required this.viewModel});

  final OverviewSectionViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: AppColors.gradientUpAc,
                ).createShader(bounds),
                child: const Icon(
                  MingCuteIcons.mgc_compass_fill,
                  size: 22,
                  color: Colors.white,
                ),
              ),

              const SizedBox(width: 10),

              const Text(
                "Activities Detected",
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          if (viewModel.hasActivityTypes)
            Row(
              children: viewModel.activityTypes.map((activity) {
                return Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: _ActivityTypeBadge(activity: activity),
                );
              }).toList(),
            )
          else
            const Text(
              "Activities will appear as you travel.",
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
        ],
      ),
    );
  }
}

class _ActivityTypeBadge extends StatelessWidget {
  const _ActivityTypeBadge({required this.activity});

  final OverviewActivityType activity;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 88,
      height: 45,
      decoration: BoxDecoration(
        color: activity.bgColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "${activity.count}",
            style: TextStyle(
              color: activity.textColor,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            activity.label,
            style: TextStyle(
              color: activity.textColor,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _PlaceVisitedTile extends StatelessWidget {
  const _PlaceVisitedTile({required this.place, required this.isLast});

  final OverviewPlace place;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 22,
          child: Column(
            children: [
              Container(
                width: 11,
                height: 11,
                decoration: const BoxDecoration(
                  color: AppColors.btnPrimary,
                  shape: BoxShape.circle,
                ),
              ),

              if (!isLast)
                Container(
                  width: 2,
                  height: 42,
                  margin: const EdgeInsets.only(top: 3),
                  decoration: BoxDecoration(
                    color: AppColors.textMuted.withValues(alpha: 0.45),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
            ],
          ),
        ),

        const SizedBox(width: 10),

        Expanded(
          child: Padding(
            padding: EdgeInsets.only(bottom: isLast ? 0 : 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  place.name,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  "${place.type} · ${place.timeText}",
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _UpcomingEmptyOverview extends StatelessWidget {
  const _UpcomingEmptyOverview();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 100,
      padding: const EdgeInsets.symmetric(horizontal: 22),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            top: 10,
            left: 2,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: AppColors.gradientUpAc,
                  ).createShader(bounds),
                  child: const Icon(
                    MingCuteIcons.mgc_location_2_fill,
                    size: 20,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 10),
                const Text(
                  "Places Visited",
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          const Center(
            child: Padding(
              padding: EdgeInsets.only(top: 20),
              child: Text(
                "Places will appear as you travel.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                  height: 1.3,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActivitiesEmptyOverview extends StatelessWidget {
  const _ActivitiesEmptyOverview();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 100,
      padding: const EdgeInsets.symmetric(horizontal: 22),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            top: 10,
            left: 2,
            child: Row(
              children: [
                ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: AppColors.gradientUpAc,
                  ).createShader(bounds),
                  child: const Icon(
                    MingCuteIcons.mgc_compass_fill,
                    size: 22,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(width: 10),

                const Text(
                  "Activities Detected",
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          const Center(
            child: Padding(
              padding: EdgeInsets.only(top: 20),
              child: Text(
                "Activity will appear as you travel.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                  height: 1.3,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
