import 'package:flutter/material.dart';

import 'package:roamio_frontend/viewmodels/story_slide_view_model.dart';

import 'package:roamio_frontend/screens/tripStory/widgets/story_cover_slide.dart';
import 'package:roamio_frontend/screens/tripStory/widgets/story_trip_overview_slide.dart';
import 'package:roamio_frontend/screens/tripStory/widgets/story_activity_summary_slide.dart';
import 'package:roamio_frontend/screens/tripStory/widgets/story_photo_highlights_slide.dart';
import 'package:roamio_frontend/screens/tripStory/widgets/story_my_activity_stats_slide.dart';
import 'package:roamio_frontend/screens/tripStory/widgets/story_trip_awards_slide.dart';
import 'package:roamio_frontend/screens/tripStory/widgets/story_reliability_scores_slide.dart';
import 'package:roamio_frontend/screens/tripStory/widgets/story_trip_roadmap_slide.dart';
import 'package:roamio_frontend/screens/tripStory/widgets/story_ending_slide.dart';

class StorySlideBody extends StatelessWidget {
  const StorySlideBody({
    super.key,
    required this.slide,
    required this.tripId,
    required this.onDone,
    required this.onShare,
  });

  final StorySlideItem slide;
  final String tripId;

  final VoidCallback onDone;

  final Future<void> Function() onShare;

  @override
  Widget build(BuildContext context) {
    switch (slide.type) {
      case StorySlideType.cover:
        return _buildWithBackground(
          StorySlideType.cover,
          StoryCoverSlide(
            tripId: tripId,
          ),
        );

      case StorySlideType.tripOverview:
        return _buildWithBackground(
          StorySlideType.tripOverview,
          StoryTripOverviewSlide(
            tripId: tripId,
          ),
        );

      case StorySlideType.activitySummary:
        return _buildWithBackground(
          StorySlideType.activitySummary,
          StoryActivitySummarySlide(
            tripId: tripId,
          ),
        );

      case StorySlideType.photoHighlights:
        return _buildWithBackground(
          StorySlideType.photoHighlights,
          StoryPhotoHighlightsSlide(
            tripId: tripId,
          ),
        );

      case StorySlideType.myActivityStats:
        return _buildWithBackground(
          StorySlideType.myActivityStats,
          StoryMyActivityStatsSlide(
            tripId: tripId,
          ),
        );

      case StorySlideType.tripAwards:
        return _buildWithBackground(
          StorySlideType.tripAwards,
          StoryTripAwardsSlide(
            tripId: tripId,
          ),
        );

      case StorySlideType.reliabilityScores:
        return _buildWithBackground(
          StorySlideType.reliabilityScores,
          StoryReliabilityScoresSlide(
            tripId: tripId,
          ),
        );

      case StorySlideType.tripRoadmap:
        return _buildWithBackground(
          StorySlideType.tripRoadmap,
          StoryTripRoadmapSlide(
            tripId: tripId,
          ),
        );

      case StorySlideType.ending:
        return _buildWithBackground(
          StorySlideType.ending,
          StoryEndingSlide(
            tripId: tripId,
            onDone: onDone,
            onShare: onShare,
          ),
        );
    }
  }

  Widget _buildWithBackground(
    StorySlideType type,
    Widget child,
  ) {
    return Stack(
      fit: StackFit.expand,
      children: [
        _StoryBackground(
          type: type,
        ),
        child,
      ],
    );
  }
}

class _StoryBackground extends StatelessWidget {
  const _StoryBackground({
    required this.type,
  });

  final StorySlideType type;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Image.asset(
        _getStoryBackgroundAsset(type),
        fit: BoxFit.cover,
      ),
    );
  }
}

String _getStoryBackgroundAsset(
  StorySlideType type,
) {
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