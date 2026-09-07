import 'dart:math';

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:roamio_frontend/theme/colors.dart';
import 'package:roamio_frontend/viewmodels/story_reliability_scores_view_model.dart';

class StoryReliabilityScoresSlide extends StatefulWidget {
  const StoryReliabilityScoresSlide({super.key, required this.tripId});

  final String tripId;

  @override
  State<StoryReliabilityScoresSlide> createState() =>
      _StoryReliabilityScoresSlideState();
}

class _StoryReliabilityScoresSlideState
    extends State<StoryReliabilityScoresSlide>
    with SingleTickerProviderStateMixin {
  late final StoryReliabilityScoresViewModel viewModel;

  late final AnimationController _animationController;

  bool _animationStarted = false;
  bool _showFireworks = false;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    );

    viewModel = StoryReliabilityScoresViewModel(tripId: widget.tripId);

    viewModel.addListener(_handleViewModelChange);
    viewModel.loadReliabilityScores();
  }

  void _handleViewModelChange() {
    if (!viewModel.isLoading &&
        viewModel.errorMessage == null &&
        !_animationStarted) {
      _animationStarted = true;

      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (!mounted) return;

        await _animationController.forward();

        if (!mounted) return;
        await Future<void>.delayed(const Duration(milliseconds: 250));

        if (!mounted) return;

        setState(() {
          _showFireworks = true;
        });
      });
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

        final visibleMemberCount = viewModel.members.length > 5
            ? 5
            : viewModel.members.length;

        const memberCardHeight = 80.0;
        const memberSpacing = 10.0;

        final memberListHeight =
            (visibleMemberCount * memberCardHeight) +
            ((visibleMemberCount - 1) * memberSpacing);

        return Stack(
          fit: StackFit.expand,
          children: [
            if (_showFireworks)
              const Positioned.fill(child: _FireworksBackground()),

            Container(
              width: double.infinity,
              height: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 28),
              child: Transform.translate(
                offset: const Offset(0, 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FadeTransition(
                      opacity: CurvedAnimation(
                        parent: _animationController,
                        curve: const Interval(
                          0.00,
                          0.20,
                          curve: Curves.easeOut,
                        ),
                      ),
                      child: ScaleTransition(
                        scale: Tween<double>(begin: 0.75, end: 1.0).animate(
                          CurvedAnimation(
                            parent: _animationController,
                            curve: const Interval(
                              0.00,
                              0.20,
                              curve: Curves.easeOutBack,
                            ),
                          ),
                        ),
                        child: const Text(
                          'Reliability Scores',
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
                        parent: _animationController,
                        curve: const Interval(
                          0.10,
                          0.28,
                          curve: Curves.easeOut,
                        ),
                      ),
                      child: SlideTransition(
                        position:
                            Tween<Offset>(
                              begin: const Offset(0, 0.20),
                              end: Offset.zero,
                            ).animate(
                              CurvedAnimation(
                                parent: _animationController,
                                curve: const Interval(
                                  0.10,
                                  0.28,
                                  curve: Curves.easeOutCubic,
                                ),
                              ),
                            ),
                        child: const Text(
                          'Who showed up for the adventure?',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    SizedBox(
                      height: memberListHeight,
                      child: ListView.separated(
                        padding: EdgeInsets.zero,

                        physics: viewModel.members.length > 5
                            ? const BouncingScrollPhysics()
                            : const NeverScrollableScrollPhysics(),

                        itemCount: viewModel.members.length,

                        separatorBuilder: (_, __) {
                          return const SizedBox(height: memberSpacing);
                        },

                        itemBuilder: (context, index) {
                          final member = viewModel.members[index];

                          return SizedBox(
                            height: memberCardHeight,
                            child: _AnimatedMemberCard(
                              index: index,
                              controller: _animationController,
                              child: _ReliabilityMemberCard(
                                member: member,
                                viewModel: viewModel,
                                animationController: _animationController,
                                animationIndex: index,
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 14),

                    FadeTransition(
                      opacity: CurvedAnimation(
                        parent: _animationController,
                        curve: const Interval(
                          0.68,
                          0.90,
                          curve: Curves.easeOut,
                        ),
                      ),
                      child: SlideTransition(
                        position:
                            Tween<Offset>(
                              begin: const Offset(0, 0.25),
                              end: Offset.zero,
                            ).animate(
                              CurvedAnimation(
                                parent: _animationController,
                                curve: const Interval(
                                  0.68,
                                  0.90,
                                  curve: Curves.easeOutBack,
                                ),
                              ),
                            ),
                        child: _ReliabilityRulesCard(viewModel: viewModel),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _ReliabilityMemberCard extends StatelessWidget {
  const _ReliabilityMemberCard({
    required this.member,
    required this.viewModel,
    required this.animationController,
    required this.animationIndex,
  });

  final StoryReliabilityMember member;
  final StoryReliabilityScoresViewModel viewModel;
  final AnimationController animationController;
  final int animationIndex;

  @override
  Widget build(BuildContext context) {
    final statusColor = viewModel.getStatusColor(member.arrivalStatus);

    final scoreColor = viewModel.getScoreColor(member.currentScore);

    final progressStart = 0.28 + (animationIndex * 0.08);
    final progressEnd = (progressStart + 0.25).clamp(0.0, 1.0);

    final progressAnimation = CurvedAnimation(
      parent: animationController,
      curve: Interval(
        progressStart.clamp(0.0, 1.0),
        progressEnd,
        curve: Curves.easeOutCubic,
      ),
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
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
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 25,
            backgroundColor: AppColors.bgAccent,
            backgroundImage:
                member.profileImageUrl != null &&
                    member.profileImageUrl!.trim().isNotEmpty
                ? NetworkImage(member.profileImageUrl!)
                : null,
            child:
                member.profileImageUrl == null ||
                    member.profileImageUrl!.trim().isEmpty
                ? const Icon(
                    Icons.person_rounded,
                    size: 26,
                    color: AppColors.textSecondary,
                  )
                : null,
          ),

          const SizedBox(width: 13),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        member.username,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    const SizedBox(width: 8),

                    _ArrivalBadge(
                      text: viewModel.getStatusLabel(member.arrivalStatus),
                      icon: viewModel.getStatusIcon(member.arrivalStatus),
                      gradient: viewModel.getStatusGradient(
                        member.arrivalStatus,
                      ),
                      color: statusColor,
                      backgroundColor: viewModel.getStatusBackgroundColor(
                        member.arrivalStatus,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                ClipRRect(
                  borderRadius: BorderRadius.circular(99),
                  child: AnimatedBuilder(
                    animation: progressAnimation,
                    builder: (context, _) {
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(99),
                        child: LinearProgressIndicator(
                          minHeight: 8,
                          value:
                              viewModel.getScoreProgress(member.currentScore) *
                              progressAnimation.value,
                          backgroundColor: AppColors.bgAccent,
                          valueColor: AlwaysStoppedAnimation<Color>(scoreColor),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 14),

          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ScaleTransition(
                scale: Tween<double>(begin: 0.5, end: 1).animate(
                  CurvedAnimation(
                    parent: animationController,
                    curve: Interval(
                      (0.40 + animationIndex * 0.08).clamp(0.0, 1.0),
                      (0.62 + animationIndex * 0.08).clamp(0.0, 1.0),
                      curve: Curves.elasticOut,
                    ),
                  ),
                ),
                child: Text(
                  '${member.currentScore}',
                  style: TextStyle(
                    color: scoreColor,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    height: 1,
                  ),
                ),
              ),

              const SizedBox(height: 5),

              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    viewModel.getScoreChangeIcon(member.scoreChange),
                    size: 15,
                    color: scoreColor,
                  ),

                  const SizedBox(width: 2),

                  Text(
                    viewModel.formatScoreChange(member.scoreChange),
                    style: TextStyle(
                      color: scoreColor,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ArrivalBadge extends StatelessWidget {
  const _ArrivalBadge({
    required this.text,
    required this.icon,
    required this.gradient,
    required this.color,
    required this.backgroundColor,
  });

  final String text;
  final IconData icon;
  final Color color;
  final LinearGradient gradient;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(99),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _GradientStatusIcon(icon: icon, gradient: gradient, size: 12),

          const SizedBox(width: 3),

          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _ReliabilityRulesCard extends StatelessWidget {
  const _ReliabilityRulesCard({required this.viewModel});

  final StoryReliabilityScoresViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const spacing = 8.0;

        final itemWidth = (constraints.maxWidth - (spacing * 2)) / 3;

        return Wrap(
          alignment: WrapAlignment.center,
          spacing: spacing,
          runSpacing: 8,
          children: viewModel.rules.map((rule) {
            return SizedBox(
              width: itemWidth,
              child: _ScoreRuleBox(
                rule: rule,
                viewModel: viewModel,
                color: viewModel.getStatusColor(rule.status),
                backgroundColor: viewModel.getStatusBackgroundColor(
                  rule.status,
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}

class _ScoreRuleBox extends StatelessWidget {
  const _ScoreRuleBox({
    required this.rule,
    required this.color,
    required this.viewModel,
    required this.backgroundColor,
  });

  final ReliabilityRuleItem rule;
  final StoryReliabilityScoresViewModel viewModel;
  final Color color;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    final scoreText = rule.scoreChange > 0
        ? '+${rule.scoreChange}'
        : '${rule.scoreChange}';

    return Container(
      height: 66,
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: backgroundColor,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: _GradientStatusIcon(
                    icon: viewModel.getStatusIcon(rule.status),
                    gradient: viewModel.getStatusGradient(rule.status),
                    size: 14,
                  ),
                ),
              ),

              const SizedBox(width: 5),

              Text(
                scoreText,
                style: TextStyle(
                  color: color,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),

          const SizedBox(height: 5),

          Text(
            rule.label,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _GradientStatusIcon extends StatelessWidget {
  const _GradientStatusIcon({
    required this.icon,
    required this.gradient,
    this.size = 20,
  });

  final IconData icon;
  final LinearGradient gradient;
  final double size;

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (bounds) {
        return gradient.createShader(bounds);
      },
      blendMode: BlendMode.srcIn,
      child: Icon(icon, color: Colors.white, size: size),
    );
  }
}

class _AnimatedMemberCard extends StatelessWidget {
  const _AnimatedMemberCard({
    required this.index,
    required this.controller,
    required this.child,
  });

  final int index;
  final AnimationController controller;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final start = 0.18 + (index * 0.08);
    final end = (start + 0.22).clamp(0.0, 1.0);

    final animation = CurvedAnimation(
      parent: controller,
      curve: Interval(start.clamp(0.0, 1.0), end, curve: Curves.easeOutBack),
    );

    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0.25, 0),
          end: Offset.zero,
        ).animate(animation),
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.92, end: 1).animate(animation),
          child: child,
        ),
      ),
    );
  }
}

class _FireworksBackground extends StatefulWidget {
  const _FireworksBackground();

  @override
  State<_FireworksBackground> createState() => _FireworksBackgroundState();
}

class _FireworksBackgroundState extends State<_FireworksBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return CustomPaint(
            painter: _FireworksPainter(progress: _controller.value),
            size: Size.infinite,
          );
        },
      ),
    );
  }
}

class _FireworksPainter extends CustomPainter {
  const _FireworksPainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    _drawFirework(
      canvas,
      center: Offset(size.width * 0.20, size.height * 0.45),
      progress: _phase(progress, 0.00),
      radius: 105,
      colors: const [Color(0xFFFFD54F), Color(0xFFFF8A65), Color(0xFFFFFFFF)],
    );

    _drawFirework(
      canvas,
      center: Offset(size.width * 0.80, size.height * 0.50),
      progress: _phase(progress, 0.22),
      radius: 125,
      colors: const [Color(0xFF81D4FA), Color(0xFFB39DDB), Color(0xFFFFFFFF)],
    );

    _drawFirework(
      canvas,
      center: Offset(size.width * 0.48, size.height * 0.60),
      progress: _phase(progress, 0.48),
      radius: 90,
      colors: const [Color(0xFFFFAB91), Color(0xFFFFE082), Color(0xFFFFFFFF)],
    );

    _drawFirework(
      canvas,
      center: Offset(size.width * 0.15, size.height * 0.78),
      progress: _phase(progress, 0.74),
      radius: 125,
      colors: const [Color(0xFF81D4FA), Color(0xFFB39DDB), Color(0xFFFFFFFF)],
    );
  }

  double _phase(double value, double delay) {
    final shifted = value - delay;

    if (shifted < 0) {
      return 0;
    }

    return (shifted / 0.52).clamp(0.0, 1.0);
  }

  void _drawFirework(
    Canvas canvas, {
    required Offset center,
    required double progress,
    required double radius,
    required List<Color> colors,
  }) {
    if (progress <= 0 || progress >= 1) {
      return;
    }

    const particleCount = 22;

    final expansion = Curves.easeOutCubic.transform(progress);

    final opacity = progress < 0.65 ? 1.0 : 1 - ((progress - 0.65) / 0.35);

    for (var i = 0; i < particleCount; i++) {
      final angle = (pi * 2 / particleCount) * i;

      final distance = radius * expansion;

      final startDistance = distance - 18;

      final end = Offset(
        center.dx + cos(angle) * distance,
        center.dy + sin(angle) * distance,
      );

      final start = Offset(
        center.dx + cos(angle) * startDistance,
        center.dy + sin(angle) * startDistance,
      );

      final color = colors[i % colors.length];

      final paint = Paint()
        ..color = color.withValues(alpha: opacity.clamp(0.0, 1.0))
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round;

      canvas.drawLine(start, end, paint);

      canvas.drawCircle(end, 2.8, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _FireworksPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
