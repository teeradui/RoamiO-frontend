import 'package:flutter/material.dart';
import 'package:ming_cute_icons/ming_cute_icons.dart';
import 'package:provider/provider.dart';
import 'package:roamio_frontend/theme/colors.dart';
import 'package:roamio_frontend/viewmodels/leaderboard_view_model.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';
import 'package:lottie/lottie.dart';

class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => LeaderboardViewModel()..loadLeaderboard(),
      child: const _LeaderboardContent(),
    );
  }
}

class _LeaderboardContent extends StatefulWidget {
  const _LeaderboardContent();

  @override
  State<_LeaderboardContent> createState() => _LeaderboardContentState();
}

class _LeaderboardContentState extends State<_LeaderboardContent>
    with TickerProviderStateMixin {
  late AnimationController _mainController;
  late AnimationController _crownController;
  late AnimationController _listController;

  @override
  void initState() {
    super.initState();

    _mainController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    );

    _crownController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 750),
    );

    _listController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );

    _startAnimation();
  }

  Future<void> _startAnimation() async {
    await Future.delayed(const Duration(milliseconds: 150));

    if (!mounted) return;

    _mainController.forward();

    await Future.delayed(const Duration(milliseconds: 1500));

    if (!mounted) return;

    _crownController.forward();

    await Future.delayed(const Duration(milliseconds: 400));

    if (!mounted) return;

    _listController.forward();
  }

  @override
  void dispose() {
    _mainController.dispose();
    _crownController.dispose();
    _listController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: SafeArea(
        child: Consumer<LeaderboardViewModel>(
          builder: (context, viewModel, _) {
            final users = viewModel.users;

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                  child: _buildHeaderAnimation(),
                ),

                const SizedBox(height: 18),

                if (viewModel.errorMessage != null)
                  Expanded(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Text(
                          viewModel.errorMessage!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  )
                else if (users.isEmpty)
                  Expanded(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 30),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              MingCuteIcons.mgc_trophy_line,
                              size: 52,
                              color: AppColors.textMuted,
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Start your journey',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: AppColors.textMuted,
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'Complete your first trip and start building your reliability score.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: AppColors.textMuted,
                                fontSize: 16,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                else
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 30),
                      child: Column(
                        children: [
                          _buildPodium(viewModel),
                          const SizedBox(height: 30),
                          _buildLeaderboardList(viewModel),
                        ],
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeaderAnimation() {
    final animation = CurvedAnimation(
      parent: _mainController,
      curve: const Interval(0.0, 0.12, curve: Curves.easeOut),
    );

    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final value = animation.value;

        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 15 * (1 - value)),
            child: child,
          ),
        );
      },
      child: _buildHeader(),
    );
  }

  Widget _buildHeader() {
    return const Column(
      children: [
        Text(
          'Leaderboard',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 26,
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(height: 4),
        Text(
          'Top Reliability Score Holder',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildPodium(LeaderboardViewModel viewModel) {
    final users = viewModel.topThree;

    if (users.length < 3) {
      return const SizedBox.shrink();
    }

    final first = users[0];
    final second = users[1];
    final third = users[2];

    return SizedBox(
      height: 350,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.bottomCenter,
        children: [
          Positioned(
            right: 5,
            bottom: 0,
            child: _buildPodiumUserAnimation(
              user: third,
              rank: 3,
              podiumHeight: 135,

              start: 0.10,
              end: 0.35,
            ),
          ),

          Positioned(
            left: 5,
            bottom: 0,
            child: _buildPodiumUserAnimation(
              user: second,
              rank: 2,
              podiumHeight: 155,

              start: 0.30,
              end: 0.55,
            ),
          ),

          Positioned(
            bottom: 0,
            child: _buildPodiumUserAnimation(
              user: first,
              rank: 1,
              podiumHeight: 180,
              isFirst: true,
              start: 0.52,
              end: 0.80,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPodiumUserAnimation({
    required LeaderboardUser user,
    required int rank,
    required double podiumHeight,
    required double start,
    required double end,
    bool isFirst = false,
  }) {
    return AnimatedBuilder(
      animation: _mainController,
      builder: (context, child) {
        final progress = ((_mainController.value - start) / (end - start))
            .clamp(0.0, 1.0);

        final curved = Curves.easeOutBack.transform(progress);

        return Opacity(
          opacity: progress,
          child: Transform.translate(
            offset: Offset(0, 50 * (1 - curved)),
            child: Transform.scale(scale: 0.88 + (0.12 * curved), child: child),
          ),
        );
      },
      child: _buildPodiumUser(
        user: user,
        rank: rank,
        podiumHeight: podiumHeight,
        isFirst: isFirst,
      ),
    );
  }

  Widget _buildPodiumUser({
    required LeaderboardUser user,
    required int rank,
    required double podiumHeight,
    bool isFirst = false,
  }) {
    final String podiumAsset;

    switch (rank) {
      case 1:
        podiumAsset = 'assets/bgPodium/first.png';
        break;

      case 2:
        podiumAsset = 'assets/bgPodium/sec.png';
        break;

      case 3:
        podiumAsset = 'assets/bgPodium/third.png';
        break;

      default:
        podiumAsset = 'assets/bgPodium/third.png';
    }

    return SizedBox(
      width: isFirst ? 120 : 110,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              CircleAvatar(
                radius: isFirst ? 35 : 34,
                backgroundColor: Colors.white,
                child: CircleAvatar(
                  radius: isFirst ? 32 : 31,
                  backgroundImage: user.profileImageUrl != null
                      ? NetworkImage(user.profileImageUrl!)
                      : const AssetImage('assets/images/default_profile.png'),
                ),
              ),

              if (isFirst)
                AnimatedBuilder(
                  animation: _crownController,
                  builder: (context, child) {
                    final value = Curves.elasticOut.transform(
                      _crownController.value,
                    );

                    return Positioned(
                      top: -34,
                      child: Transform.scale(
                        scale: 0.05 + (0.95 * value),
                        child: child,
                      ),
                    );
                  },
                  child: SizedBox(
                    width: 60,
                    height: 60,
                    child: Lottie.asset(
                      'assets/crown.json',
                      fit: BoxFit.contain,
                      repeat: true,
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 6),

          Text(
            user.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: isFirst ? 24 : 22,
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 3),

          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ShaderMask(
                shaderCallback: (bounds) {
                  return const LinearGradient(
                    colors: AppColors.medal,
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ).createShader(bounds);
                },
                child: const Icon(
                  Icons.workspace_premium_rounded,
                  color: Color(0xFFFFB000),
                  size: 17,
                ),
              ),

              const SizedBox(width: 3),

              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: user.reliabilityScore.toDouble()),
                duration: const Duration(milliseconds: 900),
                curve: Curves.easeOutCubic,
                builder: (context, value, child) {
                  return Text(
                    '${value.round()}',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  );
                },
              ),
            ],
          ),

          const SizedBox(height: 8),

          _buildAnimatedPodiumBar(
            podiumAsset: podiumAsset,
            podiumHeight: podiumHeight,
            rank: rank,
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedPodiumBar({
    required String podiumAsset,
    required double podiumHeight,
    required int rank,
  }) {
    double start;
    double end;

    switch (rank) {
      case 3:
        start = 0.10;
        end = 0.42;
        break;

      case 2:
        start = 0.30;
        end = 0.62;
        break;

      case 1:
        start = 0.52;
        end = 0.88;
        break;

      default:
        start = 0.0;
        end = 1.0;
    }

    return AnimatedBuilder(
      animation: _mainController,
      builder: (context, child) {
        final progress = ((_mainController.value - start) / (end - start))
            .clamp(0.0, 1.0);

        final curved = Curves.easeOutCubic.transform(progress);

        return SizedBox(
          width: double.infinity,
          height: podiumHeight,
          child: Align(
            alignment: Alignment.bottomCenter,
            child: SizedBox(
              width: double.infinity,
              height: podiumHeight * curved,
              child: child,
            ),
          ),
        );
      },
      child: Container(
        width: double.infinity,
        height: podiumHeight,
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
          image: DecorationImage(
            image: AssetImage(podiumAsset),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Icon(
            rank == 1
                ? TablerIcons.laurelWreath1
                : rank == 2
                ? TablerIcons.laurelWreath2
                : TablerIcons.laurelWreath3,
            size: 52,
            color: rank == 1
                ? AppColors.first
                : rank == 2
                ? AppColors.sec
                : AppColors.third,
          ),
        ),
      ),
    );
  }

  Widget _buildLeaderboardList(LeaderboardViewModel viewModel) {
    return Column(
      children: List.generate(viewModel.users.length, (index) {
        final user = viewModel.users[index];
        final rank = index + 1;

        return _buildAnimatedCard(
          index: index,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _buildLeaderboardCard(user: user, rank: rank),
          ),
        );
      }),
    );
  }

  Widget _buildAnimatedCard({required int index, required Widget child}) {
    final start = index * 0.10;
    final end = start + 0.28;

    return AnimatedBuilder(
      animation: _listController,
      builder: (context, _) {
        final progress = ((_listController.value - start) / (end - start))
            .clamp(0.0, 1.0);

        final curved = Curves.easeOutCubic.transform(progress);

        return Opacity(
          opacity: progress,
          child: Transform.translate(
            offset: Offset(30 * (1 - curved), 0),
            child: child,
          ),
        );
      },
    );
  }

  Widget _buildRankBadge(int rank) {
    final isTopThree = rank <= 3;

    String? backgroundImage;
    Color backgroundColor;

    switch (rank) {
      case 1:
        backgroundImage = 'assets/bgPodium/first.png';
        backgroundColor = Colors.transparent;
        break;

      case 2:
        backgroundImage = 'assets/bgPodium/sec.png';
        backgroundColor = Colors.transparent;
        break;

      case 3:
        backgroundImage = 'assets/bgPodium/third.png';
        backgroundColor = Colors.transparent;
        break;

      default:
        backgroundImage = null;
        backgroundColor = AppColors.filterInactiveBg;
    }

    return Container(
      width: 42,
      height: 42,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: backgroundColor,
        shape: BoxShape.circle,
        image: backgroundImage != null
            ? DecorationImage(
                image: AssetImage(backgroundImage),
                fit: BoxFit.cover,
              )
            : null,
      ),
      child: isTopThree
          ? Icon(
              rank == 1
                  ? TablerIcons.laurelWreath1
                  : rank == 2
                  ? TablerIcons.laurelWreath2
                  : TablerIcons.laurelWreath3,
              color: rank == 1
                  ? AppColors.first
                  : rank == 2
                  ? AppColors.sec
                  : AppColors.third,
              size: 24,
            )
          : Text(
              '$rank',
              style: const TextStyle(
                color: AppColors.filterInactiveText,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
    );
  }

  Widget _buildTitleBadge(String title, int rank) {
    Color backgroundColor;
    Color textColor;

    switch (rank) {
      case 1:
        backgroundColor = const Color(0xFFFFF0A8);
        textColor = const Color(0xFFD89C00);
        break;

      case 2:
        backgroundColor = const Color(0xFFE5E5E5);
        textColor = const Color(0xFF929292);
        break;

      case 3:
        backgroundColor = const Color(0xFFFFC49D);
        textColor = const Color(0xFFE36C13);
        break;

      default:
        backgroundColor = AppColors.bgPrimary;
        textColor = AppColors.textSecondary;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildLeaderboardCard({
    required LeaderboardUser user,
    required int rank,
  }) {
    return Container(
      height: 92,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildRankBadge(rank),

          const SizedBox(width: 10),

          CircleAvatar(
            radius: 25,
            backgroundImage: user.profileImageUrl != null
                ? NetworkImage(user.profileImageUrl!)
                : const AssetImage('assets/images/default_profile.png'),
          ),

          const SizedBox(width: 10),

          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        user.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),

                    if (user.userId == '1') ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.btnPrimary,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text(
                          'YOU',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),

                if (user.title != null) ...[
                  const SizedBox(height: 4),
                  _buildTitleBadge(user.title!, rank),
                ],
              ],
            ),
          ),

          const SizedBox(width: 8),

          Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '${user.reliabilityScore}',
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 3),
              const Text(
                'pts',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
