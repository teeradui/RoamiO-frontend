import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';
import 'package:lottie/lottie.dart';
import 'package:confetti/confetti.dart';
import 'package:roamio_frontend/theme/colors.dart';
import 'package:roamio_frontend/viewmodels/story_trip_roadmap_view_model.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';

class StoryTripRoadmapSlide extends StatefulWidget {
  const StoryTripRoadmapSlide({super.key, required this.tripId});

  final String tripId;

  @override
  State<StoryTripRoadmapSlide> createState() => _StoryTripRoadmapSlideState();
}

class _StoryTripRoadmapSlideState extends State<StoryTripRoadmapSlide>
    with SingleTickerProviderStateMixin {
  late final StoryTripRoadmapViewModel viewModel;
  late final AnimationController _introController;

  bool _isUpdatingCarPosition = false;

  GoogleMapController? _mapController;

  Offset? _carScreenPosition;
  LatLng? _lastCarPosition;

  @override
  void initState() {
    super.initState();

    _introController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );

    viewModel = StoryTripRoadmapViewModel(tripId: widget.tripId);

    viewModel.addListener(_handleRoadmapChange);

    viewModel.loadRoadmap();

    _introController.forward();
  }

  void _handleRoadmapChange() {
    final carPosition = viewModel.carPosition;

    if (carPosition == null) {
      return;
    }

    if (_lastCarPosition != null &&
        _lastCarPosition!.latitude == carPosition.latitude &&
        _lastCarPosition!.longitude == carPosition.longitude) {
      return;
    }

    _lastCarPosition = carPosition;

    _updateCarScreenPosition();
  }

  @override
  void dispose() {
    viewModel.removeListener(_handleRoadmapChange);

    _mapController?.dispose();

    _introController.dispose();

    viewModel.dispose();

    super.dispose();
  }

  Future<void> _updateCarScreenPosition() async {
    if (_isUpdatingCarPosition ||
        _mapController == null ||
        viewModel.carPosition == null ||
        !mounted) {
      return;
    }

    _isUpdatingCarPosition = true;

    try {
      final coordinate = await _mapController!.getScreenCoordinate(
        viewModel.carPosition!,
      );

      if (!mounted) return;

      final newPosition = Offset(
        coordinate.x.toDouble(),
        coordinate.y.toDouble(),
      );

      setState(() {
        _carScreenPosition = newPosition;
      });
    } catch (error) {
      debugPrint('CAR SCREEN POSITION ERROR: $error');
    } finally {
      _isUpdatingCarPosition = false;
    }
  }

  Future<void> _fitMapToTrip() async {
    if (_mapController == null || viewModel.stops.isEmpty) {
      return;
    }

    var minLat = viewModel.stops.first.location.latitude;
    var maxLat = minLat;

    var minLng = viewModel.stops.first.location.longitude;
    var maxLng = minLng;

    for (final stop in viewModel.stops) {
      final lat = stop.location.latitude;

      final lng = stop.location.longitude;

      if (lat < minLat) minLat = lat;
      if (lat > maxLat) maxLat = lat;

      if (lng < minLng) minLng = lng;
      if (lng > maxLng) maxLng = lng;
    }

    await _mapController!.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(
          southwest: LatLng(minLat, minLng),
          northeast: LatLng(maxLat, maxLng),
        ),
        55,
      ),
    );

    await Future<void>.delayed(const Duration(milliseconds: 350));

    await _updateCarScreenPosition();
  }

  Future<void> _handleJourneyButton() async {
    if (viewModel.isAnimating) {
      return;
    }

    if (!viewModel.hasJourneyStarted) {
      debugPrint('ROADMAP BUTTON: START JOURNEY');

      await viewModel.startJourney();

      await _updateCarScreenPosition();

      return;
    }

    if (viewModel.isAtLastStop) {
      return;
    }

    debugPrint('ROADMAP BUTTON: CONTINUE JOURNEY');

    await viewModel.goToNextStop();
  }

  String get _journeyButtonText {
    if (!viewModel.hasJourneyStarted) {
      return 'Start your journey';
    }

    if (viewModel.isAtLastStop) {
      return 'Your journey already finished';
    }

    return 'Continue your journey';
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: viewModel,
      builder: (context, _) {
        /*if (viewModel.isLoading) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.btnPrimary),
          );
        }*/

        if (viewModel.errorMessage != null) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Text(
                viewModel.errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          );
        }

        return Container(
          width: double.infinity,
          height: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 36),
          child: Transform.translate(
            offset: const Offset(0, 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FadeTransition(
                  opacity: CurvedAnimation(
                    parent: _introController,
                    curve: const Interval(0.00, 0.30, curve: Curves.easeOut),
                  ),
                  child: SlideTransition(
                    position:
                        Tween<Offset>(
                          begin: const Offset(0, -0.25),
                          end: Offset.zero,
                        ).animate(
                          CurvedAnimation(
                            parent: _introController,
                            curve: const Interval(
                              0.00,
                              0.35,
                              curve: Curves.easeOutCubic,
                            ),
                          ),
                        ),
                    child: const Text(
                      'Trip Roadmap',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 6),

                FadeTransition(
                  opacity: CurvedAnimation(
                    parent: _introController,
                    curve: const Interval(0.15, 0.45, curve: Curves.easeOut),
                  ),
                  child: Text(
                    !viewModel.hasJourneyStarted
                        ? 'Ready to retrace your adventure?'
                        : viewModel.isAtLastStop
                        ? 'You made it to every stop!'
                        : viewModel.isAnimating
                        ? 'On the way to the next stop...'
                        : 'Where did the adventure take you next?',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),

                const SizedBox(height: 18),

                FadeTransition(
                  opacity: CurvedAnimation(
                    parent: _introController,
                    curve: const Interval(0.25, 0.65, curve: Curves.easeOut),
                  ),
                  child: ScaleTransition(
                    scale: Tween<double>(begin: 0.94, end: 1.0).animate(
                      CurvedAnimation(
                        parent: _introController,
                        curve: const Interval(
                          0.25,
                          0.70,
                          curve: Curves.easeOutBack,
                        ),
                      ),
                    ),
                    child: Container(
                      width: double.infinity,
                      height: 430,

                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.10),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: Stack(
                          children: [
                            Positioned.fill(
                              child: GoogleMap(
                                initialCameraPosition: CameraPosition(
                                  target: viewModel.initialCameraTarget,
                                  zoom: 13.5,
                                ),

                                onMapCreated: (controller) async {
                                  debugPrint('STORY ROADMAP MAP CREATED');

                                  _mapController = controller;

                                  await Future<void>.delayed(
                                    const Duration(milliseconds: 250),
                                  );

                                  await _fitMapToTrip();
                                },

                                onCameraMove: (_) {
                                  _updateCarScreenPosition();
                                },

                                onCameraIdle: () {
                                  _updateCarScreenPosition();
                                },

                                markers: viewModel.mapMarkers,
                                polylines: viewModel.routePolylines,

                                zoomControlsEnabled: false,
                                mapToolbarEnabled: false,
                                compassEnabled: false,
                                myLocationButtonEnabled: false,
                                myLocationEnabled: false,
                                rotateGesturesEnabled: false,
                                tiltGesturesEnabled: false,
                                buildingsEnabled: true,
                                trafficEnabled: false,
                              ),
                            ),

                            Positioned.fill(
                              child: IgnorePointer(
                                child: Container(
                                  color: const Color(
                                    0xFFFFF1D6,
                                  ).withValues(alpha: 0.08),
                                ),
                              ),
                            ),

                            if (viewModel.hasJourneyStarted &&
                                viewModel.carPosition != null &&
                                _carScreenPosition != null)
                              AnimatedPositioned(
                                duration: const Duration(milliseconds: 180),
                                curve: Curves.linear,

                                left: _carScreenPosition!.dx - 48,
                                top: _carScreenPosition!.dy - 48,

                                child: IgnorePointer(
                                  child: SizedBox(
                                    width: 100,
                                    height: 100,
                                    child: Lottie.asset(
                                      'assets/Car.json',
                                      fit: BoxFit.contain,
                                      animate: viewModel.isAnimating,
                                      repeat: true,
                                    ),
                                  ),
                                ),
                              ),

                            Positioned(
                              left: 12,
                              right: 12,
                              bottom: 12,
                              child: _CurrentStopCard(
                                stop: viewModel.currentStop,
                                currentIndex: viewModel.currentStopIndex,
                                totalStops: viewModel.stops.length,
                                isAnimating: viewModel.isAnimating,
                                isLastStop: viewModel.isAtLastStop,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                FadeTransition(
                  opacity: CurvedAnimation(
                    parent: _introController,
                    curve: const Interval(0.55, 0.90, curve: Curves.easeOut),
                  ),
                  child: SlideTransition(
                    position:
                        Tween<Offset>(
                          begin: const Offset(0, 0.35),
                          end: Offset.zero,
                        ).animate(
                          CurvedAnimation(
                            parent: _introController,
                            curve: const Interval(
                              0.55,
                              0.95,
                              curve: Curves.easeOutCubic,
                            ),
                          ),
                        ),
                    child: _JourneyActionButton(
                      text: _journeyButtonText,
                      isAnimating: viewModel.isAnimating,
                      isFinished: viewModel.isAtLastStop,
                      onPressed: _handleJourneyButton,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _CurrentStopCard extends StatelessWidget {
  const _CurrentStopCard({
    required this.stop,
    required this.currentIndex,
    required this.totalStops,
    required this.isAnimating,
    required this.isLastStop,
  });

  final StoryRoadmapStop? stop;

  final int currentIndex;

  final int totalStops;

  final bool isAnimating;

  final bool isLastStop;

  @override
  Widget build(BuildContext context) {
    if (stop == null) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.bgCard.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: isLastStop
                  ? const Color(0xFFAFCA15).withValues(alpha: 0.18)
                  : AppColors.btnPrimary.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Icon(
                isLastStop ? Icons.flag_rounded : Icons.directions_car_rounded,
                color: isLastStop
                    ? const Color(0xFF8DA600)
                    : AppColors.btnPrimary,
                size: 22,
              ),
            ),
          ),

          const SizedBox(width: 11),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isAnimating ? 'On the way...' : stop!.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  isAnimating
                      ? 'Heading to the next stop'
                      : isLastStop
                      ? 'Final destination'
                      : stop!.type,
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
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.bgAccent,
              borderRadius: BorderRadius.circular(100),
            ),
            child: Text(
              '${currentIndex + 1}/$totalStops',
              style: const TextStyle(
                color: AppColors.btnPrimary,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RoadmapProgress extends StatelessWidget {
  const _RoadmapProgress({
    required this.currentIndex,
    required this.totalStops,
  });

  final int currentIndex;

  final int totalStops;

  @override
  Widget build(BuildContext context) {
    if (totalStops <= 0) {
      return const SizedBox.shrink();
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(totalStops, (index) {
        final reached = index <= currentIndex;

        final isCurrent = index == currentIndex;

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: isCurrent ? 12 : 9,
              height: isCurrent ? 12 : 9,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: reached ? AppColors.btnPrimary : AppColors.textDisabled,
                border: isCurrent
                    ? Border.all(color: AppColors.bgCard, width: 2)
                    : null,
                boxShadow: isCurrent
                    ? [
                        BoxShadow(
                          color: AppColors.btnPrimary.withValues(alpha: 0.25),
                          blurRadius: 6,
                        ),
                      ]
                    : null,
              ),
            ),

            if (index < totalStops - 1)
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                width: 25,
                height: 3,
                margin: const EdgeInsets.symmetric(horizontal: 3),
                decoration: BoxDecoration(
                  color: index < currentIndex
                      ? AppColors.btnPrimary
                      : AppColors.textDisabled,
                  borderRadius: BorderRadius.circular(100),
                ),
              ),
          ],
        );
      }),
    );
  }
}

class _DrivingCarIndicator extends StatefulWidget {
  const _DrivingCarIndicator();

  @override
  State<_DrivingCarIndicator> createState() => _DrivingCarIndicatorState();
}

class _DrivingCarIndicatorState extends State<_DrivingCarIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 58,
      height: 26,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final progress = Curves.easeInOut.transform(_controller.value);

          return Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                left: 0,
                right: 0,
                bottom: 3,
                child: Container(
                  height: 3,
                  decoration: BoxDecoration(
                    color: AppColors.stepActive.withValues(alpha: 0.45),
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
              ),

              Positioned(
                left: 4,
                right: 4,
                bottom: 3,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(
                    5,
                    (_) => Container(
                      width: 5,
                      height: 1,
                      color: AppColors.stepActive.withValues(alpha: 0.9),
                    ),
                  ),
                ),
              ),

              Positioned(
                left: progress * 36,
                top: 0,
                child: const Icon(
                  TablerIcons.carSuvFilled,
                  size: 21,
                  color: AppColors.stepActive,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _JourneyActionButton extends StatefulWidget {
  const _JourneyActionButton({
    required this.text,
    required this.isAnimating,
    required this.isFinished,
    required this.onPressed,
  });

  final String text;
  final bool isAnimating;
  final bool isFinished;
  final VoidCallback onPressed;

  @override
  State<_JourneyActionButton> createState() => _JourneyActionButtonState();
}

class _JourneyActionButtonState extends State<_JourneyActionButton>
    with TickerProviderStateMixin {
  late final AnimationController _shakeController;
  late final AnimationController _finishController;

  late final Animation<double> _finishScale;

  late final ConfettiController _confettiController;

  Timer? _confettiLoopTimer;
  Timer? _finishBounceTimer;

  @override
  void initState() {
    super.initState();

    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    );

    _finishController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 750),
    );

    _finishScale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(
          begin: 1.0,
          end: 1.08,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 35,
      ),
      TweenSequenceItem(
        tween: Tween(
          begin: 1.08,
          end: 0.97,
        ).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 25,
      ),
      TweenSequenceItem(
        tween: Tween(
          begin: 0.97,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.easeOutBack)),
        weight: 40,
      ),
    ]).animate(_finishController);

    _confettiController = ConfettiController(
      duration: const Duration(milliseconds: 900),
    );

    _updateStateAnimations();

    if (widget.isFinished) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;

        _playFinishedAnimation();
      });
    }
  }

  @override
  void didUpdateWidget(covariant _JourneyActionButton oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (!oldWidget.isFinished && widget.isFinished) {
      _playFinishedAnimation();
    }

    if (oldWidget.isFinished && !widget.isFinished) {
      _stopFinishedAnimation();
    }

    if (oldWidget.isAnimating != widget.isAnimating ||
        oldWidget.isFinished != widget.isFinished) {
      _updateStateAnimations();
    }
  }

  void _updateStateAnimations() {
    if (!widget.isAnimating && !widget.isFinished) {
      if (!_shakeController.isAnimating) {
        _shakeController.repeat();
      }
    } else {
      _shakeController.stop();
      _shakeController.reset();
    }
  }

  double _getShakeAngle(double value) {
    if (value < 0.04) return 0;

    if (value < 0.08) return -0.025;
    if (value < 0.12) return 0.025;

    if (value < 0.16) return -0.022;
    if (value < 0.20) return 0.022;

    if (value < 0.24) return -0.015;
    if (value < 0.28) return 0.015;

    return 0;
  }

  void _playFinishedAnimation() {
    _shakeController.stop();
    _shakeController.reset();

    _finishController.forward(from: 0);
    _confettiController.play();

    _finishBounceTimer?.cancel();
    _confettiLoopTimer?.cancel();

    _finishBounceTimer = Timer.periodic(const Duration(milliseconds: 3200), (
      _,
    ) {
      if (!mounted || !widget.isFinished) {
        return;
      }

      _finishController.forward(from: 0);
    });

    _confettiLoopTimer = Timer.periodic(const Duration(milliseconds: 3200), (
      _,
    ) {
      if (!mounted || !widget.isFinished) {
        return;
      }

      _confettiController.play();
    });
  }

  void _stopFinishedAnimation() {
    _finishBounceTimer?.cancel();
    _confettiLoopTimer?.cancel();

    _confettiController.stop();
    _finishController.reset();
  }

  @override
  void dispose() {
    _finishBounceTimer?.cancel();
    _confettiLoopTimer?.cancel();

    _shakeController.dispose();
    _finishController.dispose();
    _confettiController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        if (widget.isFinished)
          Positioned(
            bottom: 12,
            child: IgnorePointer(
              child: ConfettiWidget(
                confettiController: _confettiController,

                blastDirection: -3.14159 / 2,

                blastDirectionality: BlastDirectionality.directional,

                emissionFrequency: 0.04,

                numberOfParticles: 14,

                maxBlastForce: 18,
                minBlastForce: 8,

                gravity: 0.18,

                shouldLoop: false,

                colors: const [
                  AppColors.btnPrimary,
                  AppColors.bgHighlight,
                  AppColors.tabActive,
                  AppColors.extendedDelayColor,
                  Colors.white,
                ],
              ),
            ),
          ),

        AnimatedBuilder(
          animation: Listenable.merge([_shakeController, _finishController]),
          builder: (context, child) {
            Widget result = child!;

            if (widget.isFinished) {
              result = Transform.scale(
                scale: _finishScale.value,
                child: result,
              );
            } else if (!widget.isAnimating) {
              result = Transform.rotate(
                angle: _getShakeAngle(_shakeController.value),
                child: result,
              );
            }

            return result;
          },

          child: SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: widget.isAnimating || widget.isFinished
                  ? null
                  : widget.onPressed,

              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.btnPrimary,

                foregroundColor: Colors.white,

                disabledBackgroundColor: widget.isFinished
                    ? AppColors.bgCard
                    : AppColors.bgCard,

                disabledForegroundColor: AppColors.btnPrimary,

                elevation: 0,

                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),

              child: widget.isAnimating
                  ? const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _DrivingCarIndicator(),

                        SizedBox(width: 10),

                        Text(
                          'On the way...',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    )
                  : widget.isFinished
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.flag_rounded,
                          size: 19,
                          color: AppColors.extendedDelayColor,
                        ),

                        const SizedBox(width: 8),

                        Text(
                          widget.text,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    )
                  : Text(
                      widget.text,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
            ),
          ),
        ),
      ],
    );
  }
}
