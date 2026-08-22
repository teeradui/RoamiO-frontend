import 'package:flutter/material.dart';
import 'package:ming_cute_icons/ming_cute_icons.dart';
import 'dart:async';
import 'package:lottie/lottie.dart';
import 'package:roamio_frontend/theme/colors.dart';
import 'package:roamio_frontend/viewmodels/story_photo_highlights_view_model.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';

class StoryPhotoHighlightsSlide extends StatefulWidget {
  const StoryPhotoHighlightsSlide({super.key, required this.tripId});

  final String tripId;

  @override
  State<StoryPhotoHighlightsSlide> createState() =>
      _StoryPhotoHighlightsSlideState();
}

class _StoryPhotoHighlightsSlideState extends State<StoryPhotoHighlightsSlide>
    with SingleTickerProviderStateMixin {
  late final StoryPhotoHighlightsViewModel viewModel;
  late final AnimationController _animationController;

  @override
  void initState() {
    super.initState();

    viewModel = StoryPhotoHighlightsViewModel(tripId: widget.tripId);

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    viewModel.loadPhotoHighlights().then((_) {
      if (!mounted) return;

      _animationController.forward();
    });
  }

  @override
  void dispose() {
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
            child: CircularProgressIndicator(color: AppColors.btnPrimary),
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

        if (!viewModel.hasHighlights) {
          return const Center(
            child: Text(
              'No photo highlights available.',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          );
        }

        return Container(
          width: double.infinity,
          height: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 36),
          child: Transform.translate(
            offset: const Offset(0, 18),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FadeTransition(
                  opacity: CurvedAnimation(
                    parent: _animationController,
                    curve: const Interval(0.00, 0.25, curve: Curves.easeOut),
                  ),
                  child: SlideTransition(
                    position:
                        Tween<Offset>(
                          begin: const Offset(0, -0.18),
                          end: Offset.zero,
                        ).animate(
                          CurvedAnimation(
                            parent: _animationController,
                            curve: const Interval(
                              0.00,
                              0.30,
                              curve: Curves.easeOutCubic,
                            ),
                          ),
                        ),
                    child: const Column(
                      children: [
                        Text(
                          'Photo Highlights',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        SizedBox(height: 6),

                        Text(
                          'The places you couldn’t stop snapping',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(100),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.32),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        MingCuteIcons.mgc_photo_album_fill,
                        color: Colors.white,
                        size: 16,
                      ),

                      const SizedBox(width: 6),

                      Text(
                        '${viewModel.totalPhotos} memories snapped',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                ScaleTransition(
                  scale: Tween<double>(begin: 0.75, end: 1.0).animate(
                    CurvedAnimation(
                      parent: _animationController,
                      curve: const Interval(
                        0.15,
                        0.40,
                        curve: Curves.easeOutBack,
                      ),
                    ),
                  ),
                  child: FadeTransition(
                    opacity: CurvedAnimation(
                      parent: _animationController,
                      curve: const Interval(0.15, 0.35, curve: Curves.easeOut),
                    ),
                    child: Container(
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                FadeTransition(
                  opacity: CurvedAnimation(
                    parent: _animationController,
                    curve: const Interval(0.28, 0.55, curve: Curves.easeOut),
                  ),
                  child: ScaleTransition(
                    scale: Tween<double>(begin: 0.82, end: 1.0).animate(
                      CurvedAnimation(
                        parent: _animationController,
                        curve: const Interval(
                          0.28,
                          0.62,
                          curve: Curves.easeOutBack,
                        ),
                      ),
                    ),
                    child: SizedBox(
                      height: 245,
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Row(
                            children: [
                              // #1
                              Expanded(
                                flex: 6,
                                child: FadeTransition(
                                  opacity: CurvedAnimation(
                                    parent: _animationController,
                                    curve: const Interval(
                                      0.25,
                                      0.48,
                                      curve: Curves.easeOut,
                                    ),
                                  ),
                                  child: ScaleTransition(
                                    scale: Tween<double>(begin: 0.82, end: 1.0)
                                        .animate(
                                          CurvedAnimation(
                                            parent: _animationController,
                                            curve: const Interval(
                                              0.25,
                                              0.52,
                                              curve: Curves.easeOutBack,
                                            ),
                                          ),
                                        ),
                                    child: _HighlightPhotoCard(
                                      location: viewModel.topLocations[0],
                                      large: true,
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(width: 10),

                              Expanded(
                                flex: 4,
                                child: Column(
                                  children: [
                                    // #2
                                    Expanded(
                                      child: FadeTransition(
                                        opacity: CurvedAnimation(
                                          parent: _animationController,
                                          curve: const Interval(
                                            0.38,
                                            0.60,
                                            curve: Curves.easeOut,
                                          ),
                                        ),
                                        child: ScaleTransition(
                                          scale:
                                              Tween<double>(
                                                begin: 0.82,
                                                end: 1.0,
                                              ).animate(
                                                CurvedAnimation(
                                                  parent: _animationController,
                                                  curve: const Interval(
                                                    0.38,
                                                    0.64,
                                                    curve: Curves.easeOutBack,
                                                  ),
                                                ),
                                              ),
                                          child: _HighlightPhotoCard(
                                            location: viewModel.topLocations[1],
                                          ),
                                        ),
                                      ),
                                    ),

                                    const SizedBox(height: 10),

                                    // #3
                                    Expanded(
                                      child: FadeTransition(
                                        opacity: CurvedAnimation(
                                          parent: _animationController,
                                          curve: const Interval(
                                            0.51,
                                            0.73,
                                            curve: Curves.easeOut,
                                          ),
                                        ),
                                        child: ScaleTransition(
                                          scale:
                                              Tween<double>(
                                                begin: 0.82,
                                                end: 1.0,
                                              ).animate(
                                                CurvedAnimation(
                                                  parent: _animationController,
                                                  curve: const Interval(
                                                    0.51,
                                                    0.77,
                                                    curve: Curves.easeOutBack,
                                                  ),
                                                ),
                                              ),
                                          child: _HighlightPhotoCard(
                                            location: viewModel.topLocations[2],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          Positioned.fill(
                            child: IgnorePointer(
                              child: FadeTransition(
                                opacity: CurvedAnimation(
                                  parent: _animationController,
                                  curve: const Interval(
                                    0.24,
                                    0.72,
                                    curve: Curves.easeOut,
                                  ),
                                ),
                                child: Transform.scale(
                                  scale: 1.5,

                                  child: Lottie.asset(
                                    'assets/Confetti.json',
                                    fit: BoxFit.cover,
                                    repeat: false,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                Column(
                  children: List.generate(viewModel.topLocations.length, (
                    index,
                  ) {
                    final location = viewModel.topLocations[index];

                    final start = 0.48 + (index * 0.10);

                    final end = 0.72 + (index * 0.10);

                    return Padding(
                      padding: EdgeInsets.only(
                        bottom: index == viewModel.topLocations.length - 1
                            ? 0
                            : 9,
                      ),
                      child: FadeTransition(
                        opacity: CurvedAnimation(
                          parent: _animationController,
                          curve: Interval(start, end, curve: Curves.easeOut),
                        ),
                        child: SlideTransition(
                          position:
                              Tween<Offset>(
                                begin: const Offset(0, 0.35),
                                end: Offset.zero,
                              ).animate(
                                CurvedAnimation(
                                  parent: _animationController,
                                  curve: Interval(
                                    start,
                                    end,
                                    curve: Curves.easeOutCubic,
                                  ),
                                ),
                              ),
                          child: _LocationRankingBanner(location: location),
                        ),
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _HighlightPhotoCard extends StatefulWidget {
  const _HighlightPhotoCard({required this.location, this.large = false});

  final StoryHighlightLocation location;
  final bool large;

  @override
  State<_HighlightPhotoCard> createState() => _HighlightPhotoCardState();
}

class _HighlightPhotoCardState extends State<_HighlightPhotoCard> {
  int _currentPhotoIndex = 0;

  Timer? _photoTimer;

  bool _initialized = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_initialized) {
      return;
    }

    _initialized = true;

    _prepareSlideshow();
  }

  Future<void> _prepareSlideshow() async {
    final photos = widget.location.highlightPhotos;

    if (photos.isEmpty) {
      return;
    }


    try {
      await Future.wait(
        photos.map((photo) {
          return precacheImage(NetworkImage(photo.imageUrl), context);
        }),
      );
    } catch (error) {
      debugPrint('PHOTO PRELOAD ERROR: $error');
    }

    if (!mounted) {
      return;
    }

    if (photos.length <= 1) {
      return;
    }

    _startPhotoSlideshow();
  }

  void _startPhotoSlideshow() {
    final photos = widget.location.highlightPhotos;

    _photoTimer?.cancel();

    final interval = switch (widget.location.rank) {
      1 => const Duration(milliseconds: 3200),
      2 => const Duration(milliseconds: 3600),
      3 => const Duration(milliseconds: 4000),
      _ => const Duration(milliseconds: 3500),
    };

    _photoTimer = Timer.periodic(interval, (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _currentPhotoIndex = (_currentPhotoIndex + 1) % photos.length;
      });
    });
  }

  @override
  void dispose() {
    _photoTimer?.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final photos = widget.location.highlightPhotos;

    if (photos.isEmpty) {
      return Container(
        decoration: BoxDecoration(
          color: AppColors.bgAccent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Center(
          child: Icon(
            MingCuteIcons.mgc_photo_album_fill,
            color: AppColors.textDisabled,
          ),
        ),
      );
    }

    final currentPhoto = photos[_currentPhotoIndex];

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Stack(
        fit: StackFit.expand,
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 980),

            reverseDuration: const Duration(milliseconds: 980),

            switchInCurve: Curves.easeInOutCubic,

            switchOutCurve: Curves.easeInOutCubic,

            layoutBuilder: (currentChild, previousChildren) {
              return Stack(
                fit: StackFit.expand,
                children: [
                  ...previousChildren,

                  if (currentChild != null) currentChild,
                ],
              );
            },

            transitionBuilder: (child, animation) {
              return FadeTransition(opacity: animation, child: child);
            },

            child: Image(
              key: ValueKey(currentPhoto.id),

              image: NetworkImage(currentPhoto.imageUrl),

              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,

              gaplessPlayback: true,

              errorBuilder: (context, error, stackTrace) {
                return Container(
                  key: ValueKey('error_${currentPhoto.id}'),
                  color: AppColors.bgAccent,
                  alignment: Alignment.center,
                  child: const Icon(
                    MingCuteIcons.mgc_photo_album_fill,
                    color: AppColors.textDisabled,
                  ),
                );
              },
            ),
          ),

          Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.55),
                    ],
                  ),
                ),
              ),
            ),
          ),

          Positioned(
            left: 10,
            right: 10,
            bottom: 10,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '#${widget.location.rank}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 2),

                Text(
                  widget.location.locationName,
                  maxLines: widget.large ? 2 : 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: widget.large ? 15 : 12,
                    fontWeight: FontWeight.bold,
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

class _LocationRankingBanner extends StatelessWidget {
  const _LocationRankingBanner({required this.location});

  final StoryHighlightLocation location;

  Color get _rankColor {
    switch (location.rank) {
      case 1:
        return const Color(0xFFD99A00);

      case 2:
        return const Color(0xFF8E98A3);

      case 3:
        return const Color(0xFFB86B3D);

      default:
        return AppColors.textSecondary;
    }
  }

  Color get _rankBackground {
    switch (location.rank) {
      case 1:
        return const Color(0xFFFFF3C4);

      case 2:
        return const Color(0xFFF0F2F4);

      case 3:
        return const Color(0xFFF8E4D8);

      default:
        return AppColors.bgAccent;
    }
  }

  IconData get _rankIcon {
    switch (location.rank) {
      case 1:
        return TablerIcons.laurelWreath1;

      case 2:
        return TablerIcons.laurelWreath2;

      case 3:
        return TablerIcons.laurelWreath3;

      default:
        return TablerIcons.laurelWreath;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 9,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: _rankBackground,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(_rankIcon, color: _rankColor, size: 21),
          ),

          const SizedBox(width: 11),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      '#${location.rank}',
                      style: TextStyle(
                        color: _rankColor,
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                      ),
                    ),

                    const SizedBox(width: 6),

                    Expanded(
                      child: Text(
                        location.locationName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 3),

                Text(
                  location.subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 10),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
            decoration: BoxDecoration(
              color: _rankBackground,
              borderRadius: BorderRadius.circular(100),
            ),
            child: Row(
              children: [
                Icon(
                  MingCuteIcons.mgc_camera_2_ai_fill,
                  size: 14,
                  color: _rankColor,
                ),

                const SizedBox(width: 4),

                Text(
                  '${location.photoCount}',
                  style: TextStyle(
                    color: _rankColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
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
