
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:roamio_frontend/theme/colors.dart';
import 'package:roamio_frontend/viewmodels/story_cover_view_model.dart';

class StoryCoverSlide extends StatefulWidget {
  const StoryCoverSlide({
    super.key,
    required this.tripId,
  });

  final String tripId;

  @override
  State<StoryCoverSlide> createState() => _StoryCoverSlideState();
}

class _StoryCoverSlideState extends State<StoryCoverSlide>
    with SingleTickerProviderStateMixin {
  late final StoryCoverViewModel viewModel;
  late final AnimationController _animationController;

  @override
  void initState() {
    super.initState();

    viewModel = StoryCoverViewModel(
      tripId: widget.tripId,
    );

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );

    viewModel.addListener(_handleViewModelChange);

    viewModel.loadCoverData();
  }

  void _handleViewModelChange() {
    if (!viewModel.isLoading &&
        viewModel.errorMessage == null &&
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
              ),
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FadeTransition(
                opacity: CurvedAnimation(
                  parent: _animationController,
                  curve: const Interval(
                    0.0,
                    0.45,
                    curve: Curves.easeOut,
                  ),
                ),
                child: ScaleTransition(
                  scale: Tween<double>(
                    begin: 0.75,
                    end: 1.0,
                  ).animate(
                    CurvedAnimation(
                      parent: _animationController,
                      curve: const Interval(
                        0.0,
                        0.5,
                        curve: Curves.easeOutBack,
                      ),
                    ),
                  ),
                  child: Lottie.asset(
                    'assets/roadTrip.json',
                    width: 320,
                    height: 320,
                    fit: BoxFit.contain,
                    repeat: true,
                  ),
                ),
              ),

              const SizedBox(height: 12),

              FadeTransition(
                opacity: CurvedAnimation(
                  parent: _animationController,
                  curve: const Interval(
                    0.3,
                    0.7,
                    curve: Curves.easeOut,
                  ),
                ),
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.35),
                    end: Offset.zero,
                  ).animate(
                    CurvedAnimation(
                      parent: _animationController,
                      curve: const Interval(
                        0.3,
                        0.7,
                        curve: Curves.easeOutCubic,
                      ),
                    ),
                  ),
                  child: const Text(
                    'Your Trip Story',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              FadeTransition(
                opacity: CurvedAnimation(
                  parent: _animationController,
                  curve: const Interval(
                    0.55,
                    1.0,
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
                        0.55,
                        1.0,
                        curve: Curves.easeOutCubic,
                      ),
                    ),
                  ),
                  child: Text(
                    '${viewModel.tripName} · ${viewModel.tripDateText}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

