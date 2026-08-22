import 'dart:math';

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'dart:async';
import 'package:roamio_frontend/theme/colors.dart';
import 'package:roamio_frontend/viewmodels/story_trip_awards_view_model.dart';

class StoryTripAwardsSlide extends StatefulWidget {
  const StoryTripAwardsSlide({super.key, required this.tripId});

  final String tripId;

  @override
  State<StoryTripAwardsSlide> createState() => _StoryTripAwardsSlideState();
}

class _StoryTripAwardsSlideState extends State<StoryTripAwardsSlide>
    with TickerProviderStateMixin {
  late final StoryTripAwardsViewModel viewModel;
  late final AnimationController _introController;
  late final AnimationController _animationController;

  Timer? _introTimer;

  bool _showAwards = false;
  bool _introStarted = false;

  @override
  void initState() {
    super.initState();

    viewModel = StoryTripAwardsViewModel(tripId: widget.tripId);

    _introController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    viewModel.addListener(_handleViewModelChange);

    viewModel.loadTripAwards();
  }

  void _handleViewModelChange() {
    if (!viewModel.isLoading &&
        viewModel.errorMessage == null &&
        !_introStarted) {
      _introStarted = true;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;

        _introController.forward();

        _introTimer = Timer(const Duration(milliseconds: 2000), () {
          if (mounted) {
            _showAwardContent();
          }
        });
      });
    }
  }

  void _showAwardContent() {
    if (_showAwards) return;

    setState(() {
      _showAwards = true;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      _animationController.forward(from: 0);
    });
  }

  @override
  void dispose() {
    _introTimer?.cancel();

    viewModel.removeListener(_handleViewModelChange);

    _introController.dispose();
    _animationController.dispose();

    viewModel.dispose();

    super.dispose();
  }

  Widget _buildAwardIntro() {
    return Container(
      key: const ValueKey('awardIntro'),
      width: double.infinity,
      height: double.infinity,
      color: Colors.black.withValues(alpha: 0.45),
      child: FadeTransition(
        opacity: CurvedAnimation(
          parent: _introController,
          curve: Curves.easeOut,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ScaleTransition(
              scale: Tween<double>(begin: 0.5, end: 1.0).animate(
                CurvedAnimation(
                  parent: _introController,
                  curve: Curves.elasticOut,
                ),
              ),
              child: Lottie.asset(
                'assets/Trophy.json',
                width: 260,
                height: 260,
                fit: BoxFit.contain,
                repeat: true,
              ),
            ),

            const SizedBox(height: 4),

            SlideTransition(
              position:
                  Tween<Offset>(
                    begin: const Offset(0, 0.5),
                    end: Offset.zero,
                  ).animate(
                    CurvedAnimation(
                      parent: _introController,
                      curve: Curves.easeOutBack,
                    ),
                  ),
              child: const Text(
                'Trip Awards',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 8),

            FadeTransition(
              opacity: CurvedAnimation(
                parent: _introController,
                curve: const Interval(0.4, 1.0, curve: Curves.easeOut),
              ),
              child: const Text(
                'And the awards go to...',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAwardContent() {
    return Container(
      key: const ValueKey('awardContent'),
      width: double.infinity,
      height: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ScaleTransition(
            scale: Tween<double>(begin: 0.55, end: 1.0).animate(
              CurvedAnimation(
                parent: _animationController,
                curve: const Interval(0.0, 0.30, curve: Curves.easeOutBack),
              ),
            ),
            child: const Text(
              'Trip Awards',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const SizedBox(height: 6),

          FadeTransition(
            opacity: CurvedAnimation(
              parent: _animationController,
              curve: const Interval(0.15, 0.38, curve: Curves.easeOut),
            ),
            child: const Text(
              'Every trip has its legends',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

          const SizedBox(height: 18),

          if (viewModel.hasAwards)
            ListView.separated(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: viewModel.awards.length,
              separatorBuilder: (_, __) {
                return const SizedBox(height: 10);
              },
              itemBuilder: (context, index) {
                final award = viewModel.awards[index];

                return _AnimatedAwardCard(
                  index: index,
                  controller: _animationController,
                  isCurrentUser: award.isCurrentUser,
                  child: _TripAwardCard(
                    award: award,
                    awardColor: viewModel.getAwardColor(award.type),
                    backgroundColor: viewModel.getAwardBackgroundColor(
                      award.type,
                    ),
                  ),
                );
              },
            )
          else
            const Text(
              'No trip awards available.',
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
        ],
      ),
    );
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
                fontWeight: FontWeight.w600,
              ),
            ),
          );
        }

        return SizedBox.expand(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 500),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,
            child: _showAwards ? _buildAwardContent() : _buildAwardIntro(),
          ),
        );
      },
    );
  }
}

class _AnimatedAwardCard extends StatefulWidget {
  const _AnimatedAwardCard({
    required this.index,
    required this.controller,
    required this.isCurrentUser,
    required this.child,
  });

  final int index;
  final AnimationController controller;
  final bool isCurrentUser;
  final Widget child;

  @override
  State<_AnimatedAwardCard> createState() => _AnimatedAwardCardState();
}

class _AnimatedAwardCardState extends State<_AnimatedAwardCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _shakeController;

  @override
  void initState() {
    super.initState();

    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4000),
    );

    if (widget.isCurrentUser) {
      widget.controller.addStatusListener(_handleEntranceStatus);
    }
  }

  void _handleEntranceStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed &&
        widget.isCurrentUser &&
        mounted) {
      Future.delayed(const Duration(milliseconds: 250), () {
        if (mounted) {
          _shakeController.repeat();
        }
      });
    }
  }

  @override
  void dispose() {
    widget.controller.removeStatusListener(_handleEntranceStatus);
    _shakeController.dispose();
    super.dispose();
  }

  double _shakeAngle(double value) {
    const shakeDuration = 0.25;

    if (value <= shakeDuration) {
      final t = value / shakeDuration;

      return sin(t * pi * 6) * 0.045;
    }

    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final start = 0.25 + (widget.index * 0.12);
    final end = (start + 0.30).clamp(0.0, 1.0);

    final entranceAnimation = CurvedAnimation(
      parent: widget.controller,
      curve: Interval(start, end, curve: Curves.easeOutBack),
    );

    final isFromLeft = widget.index.isEven;

    return AnimatedBuilder(
      animation: _shakeController,
      builder: (context, child) {
        final angle = widget.isCurrentUser
            ? _shakeAngle(_shakeController.value)
            : 0.0;

        return Transform.rotate(angle: angle, child: child);
      },
      child: FadeTransition(
        opacity: entranceAnimation,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: Offset(isFromLeft ? -0.7 : 0.7, 0),
            end: Offset.zero,
          ).animate(entranceAnimation),
          child: ScaleTransition(
            scale: Tween<double>(
              begin: 0.82,
              end: 1.0,
            ).animate(entranceAnimation),
            child: widget.child,
          ),
        ),
      ),
    );
  }
}

class _TripAwardCard extends StatelessWidget {
  const _TripAwardCard({
    required this.award,
    required this.awardColor,
    required this.backgroundColor,
  });

  final StoryTripAward award;
  final Color awardColor;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.07),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: AppColors.bgAccent,
                backgroundImage:
                    award.profileImageUrl != null &&
                        award.profileImageUrl!.trim().isNotEmpty
                    ? NetworkImage(award.profileImageUrl!)
                    : null,
                child:
                    award.profileImageUrl == null ||
                        award.profileImageUrl!.trim().isEmpty
                    ? const Icon(
                        Icons.person_rounded,
                        size: 26,
                        color: AppColors.textSecondary,
                      )
                    : null,
              ),

              Positioned(
                right: -7,
                bottom: -6,
                child: Container(
                  width: 31,
                  height: 31,
                  decoration: BoxDecoration(
                    color: backgroundColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 5,
                      ),
                    ],
                  ),
                  child: Icon(award.awardIcon, color: awardColor, size: 17),
                ),
              ),
            ],
          ),

          const SizedBox(width: 18),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        award.awardTitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: awardColor,
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),

                    if (award.isCurrentUser) ...[
                      const SizedBox(width: 8),

                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.btnPrimary.withValues(alpha: 0.13),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'YOU',
                          style: TextStyle(
                            color: AppColors.btnPrimary,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),

                const SizedBox(height: 4),

                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: '${award.username} ',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      TextSpan(
                        text: award.awardSubtitle,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(height: 1.35),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
