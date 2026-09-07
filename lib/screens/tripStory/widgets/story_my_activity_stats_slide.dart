import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:confetti/confetti.dart';
import 'package:roamio_frontend/theme/colors.dart';
import 'package:roamio_frontend/viewmodels/overview_section_view_model.dart';
import 'package:roamio_frontend/viewmodels/story_my_activity_stats_view_model.dart';

class StoryMyActivityStatsSlide extends StatefulWidget {
  const StoryMyActivityStatsSlide({super.key, required this.tripId});

  final String tripId;

  @override
  State<StoryMyActivityStatsSlide> createState() =>
      _StoryMyActivityStatsSlideState();
}

class _StoryMyActivityStatsSlideState extends State<StoryMyActivityStatsSlide>
    with TickerProviderStateMixin {
  late final StoryMyActivityStatsViewModel viewModel;

  late final AnimationController _introController;
  late final AnimationController _highlightController;

  late final ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();

    viewModel = StoryMyActivityStatsViewModel(tripId: widget.tripId);

    _introController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1300),
    );

    _highlightController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _confettiController = ConfettiController(
      duration: const Duration(milliseconds: 900),
    );

    viewModel.addListener(_handleViewModelChange);

    viewModel.loadMyActivityStats();
  }

  void _handleViewModelChange() {
    if (!viewModel.isLoading &&
        viewModel.errorMessage == null &&
        _introController.value == 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (!mounted) return;

        await _introController.forward();

        await Future.delayed(const Duration(milliseconds: 50));

        if (!mounted) return;

        _highlightController.forward();
        _confettiController.play();
      });
    }
  }

  @override
  void dispose() {
    viewModel.removeListener(_handleViewModelChange);

    _introController.dispose();
    _highlightController.dispose();
    _confettiController.dispose();

    viewModel.dispose();

    super.dispose();
  }

  Widget _animatedItem({
    required Animation<double> animation,
    required Widget child,
    double offsetY = 20,
  }) {
    return FadeTransition(
      opacity: animation,
      child: AnimatedBuilder(
        animation: animation,
        child: child,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, offsetY * (1 - animation.value)),
            child: child,
          );
        },
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
              ),
            ),
          );
        }

        return Container(
          width: double.infinity,
          height: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SlideTransition(
                position:
                    Tween<Offset>(
                      begin: const Offset(0, -1.0),
                      end: Offset.zero,
                    ).animate(
                      CurvedAnimation(
                        parent: _introController,
                        curve: const Interval(
                          0.0,
                          0.45,
                          curve: Curves.bounceOut,
                        ),
                      ),
                    ),
                child: ScaleTransition(
                  scale: Tween<double>(begin: 0.6, end: 1.0).animate(
                    CurvedAnimation(
                      parent: _introController,
                      curve: const Interval(
                        0.0,
                        0.45,
                        curve: Curves.easeOutBack,
                      ),
                    ),
                  ),
                  child: const Text(
                    'How You Roamed',
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
                  curve: const Interval(0.25, 0.55, curve: Curves.easeOut),
                ),
                child: SlideTransition(
                  position:
                      Tween<Offset>(
                        begin: const Offset(0, 0.4),
                        end: Offset.zero,
                      ).animate(
                        CurvedAnimation(
                          parent: _introController,
                          curve: const Interval(
                            0.25,
                            0.55,
                            curve: Curves.easeOutBack,
                          ),
                        ),
                      ),
                  child: const Text(
                    'See what kind of traveler you were this trip!',
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

              AnimatedBuilder(
                animation: _introController,
                child: _MyActivityRadarCard(
                  data: viewModel.myActivityStats,
                  animation: CurvedAnimation(
                    parent: _introController,
                    curve: const Interval(
                      0.45,
                      0.90,
                      curve: Curves.easeOutCubic,
                    ),
                  ),
                ),
                builder: (context, child) {
                  final animation = CurvedAnimation(
                    parent: _introController,
                    curve: const Interval(0.35, 0.85, curve: Curves.elasticOut),
                  );

                  final value = animation.value;

                  return Opacity(
                    opacity: value.clamp(0.0, 1.0),
                    child: Transform.rotate(
                      angle: (1 - value) * -0.08,
                      child: Transform.scale(
                        scale: 0.65 + (0.35 * value),
                        child: child,
                      ),
                    ),
                  );
                },
              ),

              if (viewModel.highlight != null) ...[
                const SizedBox(height: 12),

                Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.topCenter,
                  children: [
                    AnimatedBuilder(
                      animation: _highlightController,
                      child: _ActivityHighlightCard(
                        highlight: viewModel.highlight!,
                      ),
                      builder: (context, child) {
                        final animation = CurvedAnimation(
                          parent: _highlightController,
                          curve: Curves.easeOutBack,
                        );

                        return Opacity(
                          opacity: _highlightController.value.clamp(0.0, 1.0),
                          child: Transform.translate(
                            offset: Offset(0, 45 * (1 - animation.value)),
                            child: Transform.scale(
                              scale: 0.75 + (0.25 * animation.value),
                              child: child,
                            ),
                          ),
                        );
                      },
                    ),

                    Positioned(
                      top: 0,
                      child: ConfettiWidget(
                        confettiController: _confettiController,

                        blastDirectionality: BlastDirectionality.explosive,

                        shouldLoop: false,

                        numberOfParticles: 18,

                        maxBlastForce: 18,
                        minBlastForce: 8,

                        gravity: 0.25,

                        emissionFrequency: 0.05,

                        colors: const [
                          AppColors.bgHighlight,
                          AppColors.btnPrimary,
                          AppColors.tabActive,
                          Colors.white,
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _MyActivityRadarCard extends StatelessWidget {
  const _MyActivityRadarCard({required this.data, required this.animation});

  final List<OverviewRadarItem> data;
  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 20),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppColors.btnPrimary.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  FluentIcons.video_person_sparkle_24_filled,
                  color: AppColors.btnPrimary,
                  size: 22,
                ),
              ),

              const SizedBox(width: 12),

              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Personal Activity',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    SizedBox(height: 2),

                    Text(
                      'Your activity distribution',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          SizedBox(
            height: 240,
            child: AnimatedBuilder(
              animation: animation,
              builder: (context, _) {
                final progress = animation.value;

                final maxValue = data.isEmpty
                    ? 1.0
                    : data
                          .map((item) => item.value)
                          .reduce((a, b) => a > b ? a : b)
                          .toDouble();

                return RadarChart(
                  RadarChartData(
                    radarShape: RadarShape.polygon,
                    tickCount: 4,

                    ticksTextStyle: const TextStyle(
                      color: Colors.transparent,
                      fontSize: 0,
                    ),

                    getTitle: (index, angle) {
                      return RadarChartTitle(
                        text: data[index].label,
                        angle: angle,
                      );
                    },

                    dataSets: [
                      RadarDataSet(
                        dataEntries: data.map((_) {
                          return RadarEntry(value: maxValue);
                        }).toList(),

                        borderColor: Colors.transparent,
                        fillColor: Colors.transparent,
                        borderWidth: 0,
                        entryRadius: 0,
                      ),

                     
                      RadarDataSet(
                        dataEntries: data.map((item) {
                          return RadarEntry(value: item.value * progress);
                        }).toList(),

                        borderColor: AppColors.btnPrimary,

                        fillColor: AppColors.btnPrimary.withValues(
                          alpha: 0.14 * progress,
                        ),

                        borderWidth: 2.5,
                        entryRadius: 3 * progress,
                      ),
                    ],

                    radarBorderData: BorderSide(
                      color: AppColors.textMuted.withValues(alpha: 0.22),
                    ),

                    gridBorderData: BorderSide(
                      color: AppColors.textMuted.withValues(alpha: 0.22),
                    ),

                    tickBorderData: BorderSide(
                      color: AppColors.textMuted.withValues(alpha: 0.18),
                    ),

                    titleTextStyle: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  duration: Duration.zero,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ActivityHighlightCard extends StatelessWidget {
  const _ActivityHighlightCard({required this.highlight});

  final StoryMyActivityHighlight highlight;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.bgHighlight.withValues(alpha: 0.35),
              shape: BoxShape.circle,
            ),
            child: Icon(highlight.icon, size: 24, color: AppColors.tabActive),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  highlight.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  highlight.subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.7, end: 1.0),
            duration: const Duration(milliseconds: 700),
            curve: Curves.elasticOut,
            builder: (context, value, child) {
              return Transform.scale(scale: value, child: child);
            },
            child: const Icon(
              Icons.auto_awesome_rounded,
              color: AppColors.tabActive,
              size: 22,
            ),
          ),
        ],
      ),
    );
  }
}
