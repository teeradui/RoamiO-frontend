import 'package:flutter/material.dart';

import 'package:roamio_frontend/theme/colors.dart';
import 'package:roamio_frontend/viewmodels/story_slide_view_model.dart';
import 'package:roamio_frontend/screens/tripStory/widgets/story_cover_slide.dart';
import 'package:roamio_frontend/screens/tripStory/widgets/story_trip_overview_slide.dart';
import 'package:roamio_frontend/screens/tripStory/widgets/story_activity_summary_slide.dart';
import 'package:roamio_frontend/screens/tripStory/widgets/story_my_activity_stats_slide.dart';
import 'package:roamio_frontend/screens/tripStory/widgets/story_trip_awards_slide.dart';
import 'package:roamio_frontend/screens/tripStory/widgets/story_reliability_scores_slide.dart';
import 'package:roamio_frontend/screens/tripStory/widgets/story_trip_roadmap_slide.dart';
import 'package:roamio_frontend/screens/tripStory/widgets/story_ending_slide.dart';
import 'package:roamio_frontend/screens/tripStory/widgets/story_photo_highlights_slide.dart';

class StorySlideScreen extends StatefulWidget {
  const StorySlideScreen({super.key, required this.tripId});

  final String tripId;

  @override
  State<StorySlideScreen> createState() => _StorySlideScreenState();
}

class _StorySlideScreenState extends State<StorySlideScreen> {
  late final StorySlideViewModel viewModel;

  bool _isAlertShowing = false;

  @override
  void initState() {
    super.initState();

    viewModel = StorySlideViewModel(tripId: widget.tripId);

    viewModel.loadStory();
  }

  @override
  void dispose() {
    viewModel.dispose();

    super.dispose();
  }

  void _checkStoryState() {
    if (!mounted || _isAlertShowing || viewModel.isLoading) {
      return;
    }

    String? message;

    if (viewModel.errorMessage != null) {
      message = viewModel.errorMessage;
    } else if (viewModel.isEmpty) {
      message = "No story available for this trip.";
    }

    if (message == null) return;

    _isAlertShowing = true;

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;

      await _showStoryAlert(message!);

      _isAlertShowing = false;
    });
  }

  Future<void> _showStoryAlert(String message) async {
    if (!mounted) return;

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.bgCard,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Row(
            children: [
              Icon(Icons.info_outline_rounded, color: AppColors.btnPrimary),
              SizedBox(width: 10),
              Text(
                "Trip Story",
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Text(
            message,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
              height: 1.4,
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.btnPrimary,
                foregroundColor: AppColors.bgPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                "OK",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: AnimatedBuilder(
        animation: viewModel,
        builder: (context, _) {
          _checkStoryState();

          if (viewModel.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.btnPrimary),
            );
          }

          if (viewModel.errorMessage != null) {
            return _StoryErrorState(
              message: viewModel.errorMessage!,
              onRetry: viewModel.loadStory,
            );
          }

          if (viewModel.isEmpty) {
            return const _StoryEmptyState();
          }

          return _StoryContent(
            viewModel: viewModel,
            onClose: () {
              Navigator.of(context).pop();
            },
          );
        },
      ),
    );
  }
}

class _StoryContent extends StatelessWidget {
  const _StoryContent({required this.viewModel, required this.onClose});

  final StorySlideViewModel viewModel;

  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final slide = viewModel.currentSlide;

    if (slide == null) {
      return const _StoryEmptyState();
    }

    return Stack(
      children: [
        Positioned.fill(
          child: _StorySlideBody(
            slide: slide,
            tripId: viewModel.tripId,
            onDone: onClose,
          ),
        ),

        if (slide.type == StorySlideType.tripRoadmap) ...[
          Positioned(
            left: 0,
            top: 70,
            bottom: 90,
            width: 55,
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: viewModel.previousSlide,
            ),
          ),

          Positioned(
            right: 0,
            top: 70,
            bottom: 90,
            width: 55,
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: viewModel.nextSlide,
            ),
          ),
        ] else if (slide.type == StorySlideType.ending) ...[
         
          Positioned(
            left: 0,
            top: 70,
            bottom: 90,
            width: 55,
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: viewModel.previousSlide,
            ),
          ),
        ] else
          Positioned.fill(
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: viewModel.previousSlide,
                  ),
                ),

                Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: viewModel.nextSlide,
                  ),
                ),
              ],
            ),
          ),

        
        SafeArea(
          child: Stack(
            children: [
              Positioned(
                top: 12,
                left: 14,
                right: 14,
                child: Row(
                  children: List.generate(viewModel.slideCount, (index) {
                    return Expanded(
                      child: Container(
                        margin: EdgeInsets.only(
                          right: index == viewModel.slideCount - 1 ? 0 : 4,
                        ),
                        height: 3,
                        decoration: BoxDecoration(
                          color: index <= viewModel.currentIndex
                              ? Colors.white
                              : Colors.white.withValues(alpha: 0.35),
                          borderRadius: BorderRadius.circular(99),
                        ),
                      ),
                    );
                  }),
                ),
              ),

              Positioned(
                top: 26,
                right: 14,
                child: IconButton(
                  onPressed: onClose,
                  icon: const Icon(
                    Icons.close_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StorySlideBody extends StatelessWidget {
  const _StorySlideBody({
    required this.slide,
    required this.tripId,
    required this.onDone,
  });

  final StorySlideItem slide;
  final String tripId;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    if (slide.type == StorySlideType.cover) {
      return Stack(
        fit: StackFit.expand,
        children: [
          _StoryBackground(type: StorySlideType.cover),

          StoryCoverSlide(tripId: tripId),
        ],
      );
    }

    if (slide.type == StorySlideType.tripOverview) {
      return Stack(
        fit: StackFit.expand,
        children: [
          _StoryBackground(type: StorySlideType.tripOverview),

          StoryTripOverviewSlide(tripId: tripId),
        ],
      );
    }

    if (slide.type == StorySlideType.activitySummary) {
      return Stack(
        fit: StackFit.expand,
        children: [
          _StoryBackground(type: StorySlideType.activitySummary),

          StoryActivitySummarySlide(tripId: tripId),
        ],
      );
    }

    if (slide.type == StorySlideType.photoHighlights) {
      return Stack(
        fit: StackFit.expand,
        children: [
          _StoryBackground(type: StorySlideType.photoHighlights),

          StoryPhotoHighlightsSlide(tripId: tripId),
        ],
      );
    }

    if (slide.type == StorySlideType.myActivityStats) {
      return Stack(
        fit: StackFit.expand,
        children: [
          _StoryBackground(type: StorySlideType.myActivityStats),

          StoryMyActivityStatsSlide(tripId: tripId),
        ],
      );
    }

    if (slide.type == StorySlideType.tripAwards) {
      return Stack(
        fit: StackFit.expand,
        children: [
          _StoryBackground(type: StorySlideType.tripAwards),

          StoryTripAwardsSlide(tripId: tripId),
        ],
      );
    }

    if (slide.type == StorySlideType.reliabilityScores) {
      return Stack(
        fit: StackFit.expand,
        children: [
          _StoryBackground(type: StorySlideType.reliabilityScores),

          StoryReliabilityScoresSlide(tripId: tripId),
        ],
      );
    }

    if (slide.type == StorySlideType.tripRoadmap) {
      return Stack(
        fit: StackFit.expand,
        children: [
          _StoryBackground(type: StorySlideType.tripRoadmap),

          StoryTripRoadmapSlide(tripId: tripId),
        ],
      );
    }

    if (slide.type == StorySlideType.ending) {
      return Stack(
        fit: StackFit.expand,
        children: [
          _StoryBackground(type: StorySlideType.ending),

          StoryEndingSlide(tripId: tripId, onDone: onDone),
        ],
      );
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        _StoryBackground(type: slide.type),

        Padding(
          padding: const EdgeInsets.fromLTRB(28, 80, 28, 50),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (slide.imageUrl != null) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(22),
                  child: Image.network(
                    slide.imageUrl!,
                    width: double.infinity,
                    height: 330,
                    fit: BoxFit.cover,
                  ),
                ),

                const SizedBox(height: 26),
              ],

              if (slide.title != null)
                Text(
                  slide.title!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),

              if (slide.subtitle != null) ...[
                const SizedBox(height: 10),

                Text(
                  slide.subtitle!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],

              if (slide.description != null) ...[
                const SizedBox(height: 14),

                Text(
                  slide.description!,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
              ],

              if (slide.statValue != null) ...[
                const SizedBox(height: 24),

                Text(
                  slide.statValue!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 46,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                if (slide.statLabel != null)
                  Text(
                    slide.statLabel!,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _StoryEmptyState extends StatelessWidget {
  const _StoryEmptyState();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.auto_stories_outlined,
                color: AppColors.textDisabled,
                size: 48,
              ),

              const SizedBox(height: 14),

              const Text(
                "No story available for this trip.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),

        Positioned(
          top: 10,
          left: 6,
          child: IconButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: const Icon(
              Icons.arrow_back_ios_new,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}

class _StoryErrorState extends StatelessWidget {
  const _StoryErrorState({required this.message, required this.onRetry});

  final String message;

  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Center(
          child: Padding(
            padding: const EdgeInsets.all(30),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.error_outline_rounded,
                  color: AppColors.btnPrimary,
                  size: 46,
                ),

                const SizedBox(height: 14),

                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 18),

                ElevatedButton.icon(
                  onPressed: () {
                    onRetry();
                  },
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text("Try Again"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.btnPrimary,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),

        Positioned(
          top: 10,
          left: 6,
          child: IconButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: const Icon(
              Icons.arrow_back_ios_new,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}

String _getStoryBackgroundAsset(StorySlideType type) {
  switch (type) {
    case StorySlideType.cover:
      return 'assets/storyBg/14.png';

    case StorySlideType.tripOverview:
      return 'assets/storyBg/15.png';

    case StorySlideType.activitySummary:
      return 'assets/storyBg/5.png';

    case StorySlideType.photoHighlights:
      return 'assets/storyBg/21.png';

    case StorySlideType.myActivityStats:
      return 'assets/storyBg/19.png';

    case StorySlideType.tripAwards:
      return 'assets/storyBg/3.png';

    case StorySlideType.reliabilityScores:
      return 'assets/storyBg/17.png';

    case StorySlideType.tripRoadmap:
      return 'assets/storyBg/4.png';

    case StorySlideType.ending:
      return 'assets/storyBg/1.png';
  }
}

class _StoryBackground extends StatelessWidget {
  const _StoryBackground({required this.type});

  final StorySlideType type;

  @override
  Widget build(BuildContext context) {
    final background = _getStoryBackgroundAsset(type);

    return Positioned.fill(child: Image.asset(background, fit: BoxFit.cover));
  }
}
