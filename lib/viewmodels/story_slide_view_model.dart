import 'package:flutter/material.dart';

enum StorySlideType {
  cover,
  tripOverview,
  activitySummary,
  photoHighlights,
  myActivityStats,
  tripAwards,
  reliabilityScores,
  tripRoadmap,
  ending,
}

class StorySlideItem {
  const StorySlideItem({
    required this.type,
    this.title,
    this.subtitle,
    this.description,
    this.imageUrl,
    this.locationName,
    this.activityName,
    this.statValue,
    this.statLabel,
  });

  final StorySlideType type;

  final String? title;
  final String? subtitle;
  final String? description;

  final String? imageUrl;

  final String? locationName;
  final String? activityName;

  final String? statValue;
  final String? statLabel;
}

class StorySlideViewModel extends ChangeNotifier {
  StorySlideViewModel({
    required this.tripId,
  });

  final String tripId;

  List<StorySlideItem> slides = [];

  int currentIndex = 0;

  bool isLoading = false;

  String? errorMessage;

  bool get hasSlides => slides.isNotEmpty;

  bool get isEmpty => slides.isEmpty;

  bool get isFirstSlide => currentIndex == 0;

  bool get isLastSlide {
    if (slides.isEmpty) {
      return true;
    }

    return currentIndex == slides.length - 1;
  }

  int get slideCount => slides.length;

  StorySlideItem? get currentSlide {
    if (slides.isEmpty) {
      return null;
    }

    if (currentIndex < 0 ||
        currentIndex >= slides.length) {
      return null;
    }

    return slides[currentIndex];
  }

  double get progress {
    if (slides.isEmpty) {
      return 0;
    }

    return (currentIndex + 1) /
        slides.length;
  }


  Future<void> loadStory() async {
    debugPrint('========== LOAD TRIP STORY ==========');
    debugPrint('Trip ID: $tripId');

    isLoading = true;
    errorMessage = null;

    notifyListeners();

    try {
      //MOCK DATA
      slides = const [
      StorySlideItem(
        type: StorySlideType.cover,
      ),

      StorySlideItem(
        type: StorySlideType.tripOverview,
        title: 'Trip Overview',
        subtitle: 'A look back at your journey',
      ),

      StorySlideItem(
        type: StorySlideType.activitySummary,
        title: 'Activity Summary',
        subtitle: 'What your group did together',
      ),

      StorySlideItem(
        type: StorySlideType.photoHighlights,
        title: 'Photo Highlights',
        subtitle: 'Your favorite moments',
      ),

      StorySlideItem(
        type: StorySlideType.myActivityStats,
        title: 'My Activity Stats',
        subtitle: 'Your personal trip activity',
      ),

      StorySlideItem(
        type: StorySlideType.tripAwards,
        title: 'Trip Awards',
        subtitle: 'Highlights from the group',
      ),

      StorySlideItem(
        type: StorySlideType.reliabilityScores,
        title: 'Reliability Scores',
        subtitle: 'How everyone showed up',
      ),

      StorySlideItem(
        type: StorySlideType.tripRoadmap,
        title: 'Trip Roadmap',
        subtitle: 'The route you travelled',
      ),

      StorySlideItem(
        type: StorySlideType.ending,
        title: 'That’s a Wrap!',
        subtitle: 'Thanks for travelling with RoamiO',
      ),
    ];

    currentIndex = 0;

    debugPrint('STORY LOAD SUCCESS');
    debugPrint('Story slide count: ${slides.length}');

    for (var i = 0; i < slides.length; i++) {
      debugPrint(
        'STORY SLIDE ${i + 1}: ${slides[i].type}',
      );
    }

      /*
       * TODO:
       * ตอนทำ Service/Repository/Backend
       * จะเรียก API ตรงนี้
       *
       * final response =
       *     await _storyService.getStory(
       *       tripId,
       *     );
       *
       * slides = response.slides
       *     .map(...)
       *     .toList();
       */

      // ตอนนี้ยังไม่มี backend
      //slides = [];

      //currentIndex = 0;
    } catch (error, stackTrace) {
      debugPrint('LOAD STORY ERROR: $error');
      debugPrintStack(stackTrace: stackTrace);

      slides = [];
      currentIndex = 0;

      final message =
          error.toString().toLowerCase();

      if (message.contains(
            'socketexception',
          ) ||
          message.contains(
            'connection refused',
          ) ||
          message.contains(
            'network is unreachable',
          ) ||
          message.contains(
            'failed host lookup',
          ) ||
          message.contains(
            'timed out',
          )) {
        errorMessage =
            'Request failed. Please check your connection.';
      } else {
        errorMessage =
            'Unable to load story. Please try again.';
      }
    } finally {
      isLoading = false;

      debugPrint('Current index: $currentIndex');
      debugPrint('Has slides: $hasSlides');
      debugPrint('Is empty: $isEmpty');
      debugPrint('=====================================');

      notifyListeners();
    }
  }

  void nextSlide() {
    if (slides.isEmpty) {
      debugPrint('NEXT SLIDE: slides are empty');
      return;
    }

    if (currentIndex <
        slides.length - 1) {
      currentIndex++;
      debugPrint(
      'NEXT SLIDE → '
      '${currentIndex + 1}/${slides.length} '
      '${slides[currentIndex].type}',
    );

      notifyListeners();
    } else {
      debugPrint(
        'NEXT SLIDE: already at last slide',
      );
    }
  }

  void previousSlide() {
    if (slides.isEmpty) {
      debugPrint('PREVIOUS SLIDE: slides are empty');
      return;
    }

    if (currentIndex > 0) {
      currentIndex--;

      debugPrint(
      'PREVIOUS SLIDE → '
      '${currentIndex + 1}/${slides.length} '
      '${slides[currentIndex].type}',
    );

      notifyListeners();
    } else {
      debugPrint(
        'PREVIOUS SLIDE: already at first slide',
      );
    }
  }

  void goToSlide(int index) {
    if (index < 0 ||
        index >= slides.length) {
      return;
    }

    currentIndex = index;

    notifyListeners();
  }

  void clearError() {
    errorMessage = null;

    notifyListeners();
  }
}