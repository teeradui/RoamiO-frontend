import 'package:flutter/material.dart';

import 'package:roamio_frontend/theme/colors.dart';
import 'package:roamio_frontend/viewmodels/story_slide_view_model.dart';

class StoryShareSlideSelector extends StatelessWidget {
  const StoryShareSlideSelector({
    super.key,
    required this.slides,
  });

  final List<StorySlideItem> slides;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      appBar: AppBar(
        backgroundColor: AppColors.bgPrimary,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Choose a Story',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            20,
            12,
            20,
            24,
          ),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              const Text(
                'Select the slide you want to share',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
              ),

              const SizedBox(height: 20),

              Expanded(
                child: GridView.builder(
                  itemCount: slides.length,
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                    childAspectRatio: 0.72,
                  ),
                  itemBuilder: (context, index) {
                    final slide = slides[index];

                    return _StorySlideCard(
                      slide: slide,
                      index: index,
                      onTap: () {
                        Navigator.pop(
                          context,
                          slide,
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StorySlideCard extends StatelessWidget {
  const _StorySlideCard({
    required this.slide,
    required this.index,
    required this.onTap,
  });

  final StorySlideItem slide;
  final int index;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.bgCard,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppColors.textDisabled
                  .withValues(alpha: 0.35),
            ),
          ),
          child: Column(
            children: [
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius:
                        const BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.btnPrimary
                            .withValues(alpha: 0.85),
                        AppColors.textPrimary
                            .withValues(alpha: 0.85),
                      ],
                    ),
                  ),
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 42,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(14),
                child: Text(
                  _getSlideName(slide.type),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getSlideName(
    StorySlideType type,
  ) {
    switch (type) {
      case StorySlideType.cover:
        return 'Cover';

      case StorySlideType.tripOverview:
        return 'Trip Overview';

      case StorySlideType.activitySummary:
        return 'Activity Summary';

      case StorySlideType.photoHighlights:
        return 'Photo Highlights';

      case StorySlideType.myActivityStats:
        return 'My Activity Stats';

      case StorySlideType.tripAwards:
        return 'Trip Awards';

      case StorySlideType.reliabilityScores:
        return 'Reliability Scores';

      case StorySlideType.tripRoadmap:
        return 'Trip Roadmap';

      case StorySlideType.ending:
        return 'Ending';
    }
  }
}