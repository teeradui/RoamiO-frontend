import 'package:flutter/material.dart';

import 'package:roamio_frontend/theme/colors.dart';
import 'package:roamio_frontend/viewmodels/story_trip_overview_view_model.dart';

class StoryTripOverviewSlide extends StatefulWidget {
  const StoryTripOverviewSlide({
    super.key,
    required this.tripId,
  });

  final String tripId;

  @override
  State<StoryTripOverviewSlide> createState() =>
      _StoryTripOverviewSlideState();
}

class _StoryTripOverviewSlideState
    extends State<StoryTripOverviewSlide>
    with SingleTickerProviderStateMixin {
  late final StoryTripOverviewViewModel viewModel;
  late final AnimationController _animationController;

  @override
  void initState() {
    super.initState();

    viewModel = StoryTripOverviewViewModel(
      tripId: widget.tripId,
    );

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    viewModel.addListener(_handleViewModelChange);

    viewModel.loadTripOverview();
  }

  void _handleViewModelChange() {
    if (!viewModel.isLoading &&
        viewModel.errorMessage == null &&
        !_animationController.isAnimating &&
        _animationController.value == 0) {
      _animationController.forward();
    }
  }

  @override
  void dispose() {
    viewModel.removeListener(_handleViewModelChange);
    _animationController.dispose();
    viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: viewModel,
      builder: (context, _) {
        if (viewModel.isLoading) {
          return const Center(
            child: CircularProgressIndicator(
              color: AppColors.btnPrimary,
            ),
          );
        }

        if (viewModel.errorMessage != null) {
          return Center(
            child: Text(
              viewModel.errorMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          );
        }

        return Container(
          width: double.infinity,
          height: double.infinity,
          padding: const EdgeInsets.fromLTRB(
            28,
            80,
            28,
            50,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FadeTransition(
                opacity: CurvedAnimation(
                  parent: _animationController,
                  curve: const Interval(
                    0.0,
                    0.35,
                    curve: Curves.easeOut,
                  ),
                ),
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, -0.3),
                    end: Offset.zero,
                  ).animate(
                    CurvedAnimation(
                      parent: _animationController,
                      curve: const Interval(
                        0.0,
                        0.35,
                        curve: Curves.easeOutCubic,
                      ),
                    ),
                  ),
                  child: const Text(
                    'Trip Overview',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 8),

              FadeTransition(
                opacity: CurvedAnimation(
                  parent: _animationController,
                  curve: const Interval(
                    0.15,
                    0.45,
                    curve: Curves.easeOut,
                  ),
                ),
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.25),
                    end: Offset.zero,
                  ).animate(
                    CurvedAnimation(
                      parent: _animationController,
                      curve: const Interval(
                        0.15,
                        0.45,
                        curve: Curves.easeOutCubic,
                      ),
                    ),
                  ),
                  child: const Text(
                    'Here’s your trip at a glance',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 18),

              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: viewModel.stats.length,
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.15,
                ),
                itemBuilder: (context, index) {
                  final stat = viewModel.stats[index];

                  return _AnimatedStatCard(
                    index: index,
                    controller: _animationController,
                    stat: stat,
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

class _TripOverviewStatCard
    extends StatelessWidget {
  const _TripOverviewStatCard({
    required this.stat,
  });

  final StoryTripOverviewStat stat;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: 0.06,
            ),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment:
            MainAxisAlignment.center,
        children: [
          Icon(
            stat.icon,
            size: 30,
            color: AppColors.btnPrimary,
          ),

          const SizedBox(height: 12),

          Text(
            stat.value,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 5),

          Text(
            stat.label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _AnimatedStatCard extends StatelessWidget {
  const _AnimatedStatCard({
    required this.index,
    required this.controller,
    required this.stat,
  });

  final int index;
  final AnimationController controller;
  final StoryTripOverviewStat stat;

  @override
  Widget build(BuildContext context) {
    final double start = 0.3 + (index * 0.1);
    final double end = (start + 0.35).clamp(0.0, 1.0);

    final animation = CurvedAnimation(
      parent: controller,
      curve: Interval(
        start,
        end,
        curve: Curves.easeOutBack,
      ),
    );

    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.35),
          end: Offset.zero,
        ).animate(animation),
        child: ScaleTransition(
          scale: Tween<double>(
            begin: 0.75,
            end: 1.0,
          ).animate(animation),
          child: _TripOverviewStatCard(
            stat: stat,
          ),
        ),
      ),
    );
  }
}