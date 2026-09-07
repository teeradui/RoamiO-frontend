import 'dart:async';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:roamio_frontend/theme/colors.dart';
import 'package:roamio_frontend/viewmodels/story_activity_summary_view_model.dart';

class StoryActivitySummarySlide extends StatefulWidget {
  const StoryActivitySummarySlide({
    super.key,
    required this.tripId,
    this.onRevealChanged,
  });

  final String tripId;
  final ValueChanged<bool>? onRevealChanged;

  @override
  State<StoryActivitySummarySlide> createState() =>
      _StoryActivitySummarySlideState();
}

class _StoryActivitySummarySlideState extends State<StoryActivitySummarySlide>
    with TickerProviderStateMixin {
  late final StoryActivitySummaryViewModel viewModel;

  late final AnimationController _introController;
  late final AnimationController _contentController;
  late final AnimationController _rewardController;

  Timer? _slotTimer;
  Timer? _introTimer;

  bool _showContent = false;
  bool _introStarted = false;
  int _slotIndex = 0;
  bool _slotStopped = false;

  @override
  void initState() {
    super.initState();

    viewModel = StoryActivitySummaryViewModel(tripId: widget.tripId);

    _introController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _rewardController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _contentController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    viewModel.addListener(_handleViewModelChange);

    viewModel.loadActivitySummary();
  }

  void _handleViewModelChange() {
    if (!viewModel.isLoading &&
        viewModel.errorMessage == null &&
        !_introStarted) {
      _introStarted = true;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;

        _introController.forward();

        _startSlotAnimation();
      });
    }
  }

  void _startSlotAnimation() {
    if (viewModel.activityStats.isEmpty) {
      _showActivityContent();
      return;
    }

    int spinCount = 0;

    void spin(Duration delay) {
      _slotTimer?.cancel();

      _slotTimer = Timer(delay, () {
        if (!mounted) return;

        spinCount++;

        setState(() {
          _slotIndex = (_slotIndex + 1) % viewModel.activityStats.length;
        });

        if (spinCount < 7) {
          spin(const Duration(milliseconds: 110));
        } else if (spinCount < 10) {
          spin(const Duration(milliseconds: 180));
        } else if (spinCount < 12) {
          spin(const Duration(milliseconds: 280));
        } else {
          _stopAtMostActivity();
        }
      });
    }

    spin(const Duration(milliseconds: 100));
  }

  void _stopAtMostActivity() {
    final mostActivity = viewModel.mostActivity;

    if (mostActivity == null) {
      _showActivityContent();
      return;
    }

    final index = viewModel.activityStats.indexWhere(
      (activity) => activity.type == mostActivity.type,
    );

    setState(() {
      if (index >= 0) {
        _slotIndex = index;
      }

      _slotStopped = true;
    });

    _rewardController.forward(from: 0);

    _introTimer = Timer(const Duration(milliseconds: 1800), () {
      if (mounted) {
        _showActivityContent();
      }
    });
  }

  void _showActivityContent() {
    debugPrint('SHOW ACTIVITY CONTENT CALLED');

    if (_showContent) {
      debugPrint('CONTENT ALREADY SHOWN');
      return;
    }

    setState(() {
      _showContent = true;
    });

    debugPrint('_showContent = $_showContent');

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      _contentController.forward(from: 0);
    });
  }

  @override
  void dispose() {
    _slotTimer?.cancel();
    _introTimer?.cancel();

    viewModel.removeListener(_handleViewModelChange);

    _introController.dispose();
    _rewardController.dispose();
    _contentController.dispose();

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

        return SizedBox.expand(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 600),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,
            child: _showContent
                ? _buildActivityContent()
                : _buildMostActivityIntro(),
          ),
        );
      },
    );
  }

  Widget _buildMostActivityIntro() {
    if (viewModel.activityStats.isEmpty) {
      return const SizedBox.shrink();
    }

    final currentActivity = viewModel.activityStats[_slotIndex];

    final backgroundColor = viewModel.getBackgroundColor(currentActivity.type);

    final iconColor = viewModel.getTextColor(currentActivity.type);

    return Container(
      key: const ValueKey('intro'),
      width: double.infinity,
      height: double.infinity,
      color: Colors.black.withValues(alpha: 0.45),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'What ruled this trip?',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 32),

          SizedBox(
            width: 260,
            height: 260,
            child: Stack(
              alignment: Alignment.center,
              children: [
                if (_slotStopped)
                  FadeTransition(
                    opacity: CurvedAnimation(
                      parent: _rewardController,
                      curve: Curves.easeOut,
                    ),
                    child: ScaleTransition(
                      scale: Tween<double>(begin: 0.5, end: 1.0).animate(
                        CurvedAnimation(
                          parent: _rewardController,
                          curve: Curves.easeOutBack,
                        ),
                      ),
                      child: Lottie.asset(
                        'assets/Rewardlighteffect.json',
                        width: 300,
                        height: 300,
                        fit: BoxFit.contain,
                        repeat: true,
                      ),
                    ),
                  ),

                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 100),
                  transitionBuilder: (child, animation) {
                    return ScaleTransition(
                      scale: Tween<double>(begin: 0.5, end: 1.0).animate(
                        CurvedAnimation(
                          parent: animation,
                          curve: Curves.easeOutBack,
                        ),
                      ),
                      child: FadeTransition(opacity: animation, child: child),
                    );
                  },

                  child: Container(
                    key: ValueKey(currentActivity.type),
                    width: 126,
                    height: 126,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.12),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),

                    child: Container(
                      decoration: BoxDecoration(
                        color: backgroundColor,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        currentActivity.icon,
                        size: 52,
                        color: iconColor,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          AnimatedSwitcher(
            duration: const Duration(milliseconds: 180),
            child: Text(
              currentActivity.label,
              key: ValueKey(currentActivity.label),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _slotStopped ? Colors.white : Colors.white70,
                fontSize: _slotStopped ? 32 : 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          if (_slotStopped) ...[
            const SizedBox(height: 10),

            FadeTransition(
              opacity: _rewardController,
              child: const Text(
                'MOST ACTIVITY',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.5,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActivityContent() {
    return Container(
      key: const ValueKey('content'),
      width: double.infinity,
      height: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 36),
      child: Transform.translate(
        offset: const Offset(0, 25),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _animatedItem(
              start: 0.0,
              end: 0.3,
              child: const Text(
                'Activity Summary',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 6),

            _animatedItem(
              start: 0.1,
              end: 0.4,
              child: const Text(
                'Here’s what your group did during the trip',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

            const SizedBox(height: 16),

            _animatedItem(
              start: 0.2,
              end: 0.55,
              scale: true,
              child: _ActivityOverviewCard(
                totalActivities: viewModel.totalActivities,
                mostActivity: viewModel.mostActivity,
              ),
            ),

            const SizedBox(height: 8),

            ListView.separated(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: viewModel.activityStats.length,
              separatorBuilder: (context, index) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final activity = viewModel.activityStats[index];

                final start = 0.4 + (index * 0.1);
                final end = (start + 0.3).clamp(0.0, 1.0);

                return _animatedItem(
                  start: start.clamp(0.0, 1.0),
                  end: end,
                  scale: true,
                  child: _ActivityStatCard(
                    activity: activity,
                    backgroundColor: viewModel.getBackgroundColor(
                      activity.type,
                    ),
                    textColor: viewModel.getTextColor(activity.type),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _animatedItem({
    required double start,
    required double end,
    required Widget child,
    bool scale = false,
  }) {
    final animation = CurvedAnimation(
      parent: _contentController,
      curve: Interval(start, end, curve: Curves.easeOutCubic),
    );

    Widget result = FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.25),
          end: Offset.zero,
        ).animate(animation),
        child: child,
      ),
    );

    if (scale) {
      result = ScaleTransition(
        scale: Tween<double>(begin: 0.9, end: 1.0).animate(
          CurvedAnimation(
            parent: _contentController,
            curve: Interval(start, end, curve: Curves.easeOutBack),
          ),
        ),
        child: result,
      );
    }

    return result;
  }
}

class _ActivityOverviewCard extends StatelessWidget {
  const _ActivityOverviewCard({
    required this.totalActivities,
    required this.mostActivity,
  });

  final int totalActivities;
  final StoryActivityStat? mostActivity;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
    
          Text(
            '$totalActivities',
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 34,
              fontWeight: FontWeight.bold,
              height: 1,
            ),
          ),

          const SizedBox(height: 6),

          const Text(
            'Activities Detected',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 16),

          Container(
            width: double.infinity,
            height: 1,
            color: AppColors.textMuted.withValues(alpha: 0.18),
          ),

          const SizedBox(height: 14),

          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: AppColors.bgHighlight.withValues(alpha: 0.35),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.emoji_events_rounded,
                  color: AppColors.tabActive,
                  size: 20,
                ),
              ),

              const SizedBox(width: 10),

              const Text(
                'Most Activity',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const Spacer(),

              Text(
                mostActivity?.label ?? '-',
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActivityStatCard extends StatelessWidget {
  const _ActivityStatCard({
    required this.activity,
    required this.backgroundColor,
    required this.textColor,
  });

  final StoryActivityStat activity;
  final Color backgroundColor;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: backgroundColor,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Icon(activity.icon, color: textColor, size: 26),
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Text(
              activity.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),

          const SizedBox(width: 12),

          Text(
            '${activity.count}',
            style: TextStyle(
              color: textColor,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
