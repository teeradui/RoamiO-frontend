import 'package:flutter/material.dart';
import 'package:flutter_social_share_plus/flutter_social_share_plus.dart';
import 'package:roamio_frontend/theme/colors.dart';
import 'package:roamio_frontend/viewmodels/story_slide_view_model.dart';
import 'package:roamio_frontend/screens/tripStory/story_share_recording_screen.dart';
import 'package:roamio_frontend/screens/tripStory/story_share_slide_selector.dart';
import 'package:roamio_frontend/screens/tripStory/widgets/story_slide_body.dart';

enum StorySharePlatform { instagram }

class StorySlideScreen extends StatefulWidget {
  const StorySlideScreen({super.key, required this.tripId});

  final String tripId;

  @override
  State<StorySlideScreen> createState() => _StorySlideScreenState();
}

class _StorySlideScreenState extends State<StorySlideScreen> {
  late final StorySlideViewModel viewModel;

  bool _isAlertShowing = false;

  @override
  void initState() {
    super.initState();

    viewModel = StorySlideViewModel(tripId: widget.tripId);

    viewModel.loadStory();
  }

  @override
  void dispose() {
    viewModel.dispose();

    super.dispose();
  }

  void _checkStoryState() {
    if (!mounted || _isAlertShowing || viewModel.isLoading) {
      return;
    }

    String? message;

    if (viewModel.errorMessage != null) {
      message = viewModel.errorMessage;
    } else if (viewModel.isEmpty) {
      message = 'No story available for this trip.';
    }

    if (message == null) {
      return;
    }

    _isAlertShowing = true;

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) {
        return;
      }

      await _showStoryAlert(message!);

      _isAlertShowing = false;
    });
  }

  Future<void> _handleShareStory() async {
    final selectedSlide = await Navigator.push<StorySlideItem>(
      context,
      MaterialPageRoute(
        builder: (_) => StoryShareSlideSelector(slides: viewModel.slides),
      ),
    );

    if (!mounted || selectedSlide == null) {
      return;
    }

    debugPrint('SELECTED STORY SLIDE: ${selectedSlide.type}');

    final selectedPlatform = await showModalBottomSheet<StorySharePlatform>(
      context: context,
      backgroundColor: AppColors.bgCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 42,
                  height: 5,
                  decoration: BoxDecoration(
                    color: AppColors.textDisabled,
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),

                const SizedBox(height: 20),

                const Text(
                  'Share your trip story',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 6),

                const Text(
                  'Choose where you want to share it',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),

                const SizedBox(height: 20),

                _SharePlatformTile(
                  icon: Icons.camera_alt_rounded,
                  label: 'Instagram',
                  onTap: () {
                    Navigator.pop(sheetContext, StorySharePlatform.instagram);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );

    if (!mounted || selectedPlatform == null) {
      return;
    }

    debugPrint('SELECTED PLATFORM: $selectedPlatform');

    debugPrint('SLIDE TO SHARE: ${selectedSlide.type}');

    final videoPath = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (_) => StoryShareRecordingScreen(
          tripId: viewModel.tripId,
          slide: selectedSlide,
        ),
      ),
    );

    if (!mounted) {
      return;
    }

    if (videoPath == null || videoPath.isEmpty) {
      await _showShareError('Unable to generate trip story. Please try again.');

      return;
    }

    debugPrint('STORY VIDEO READY: $videoPath');

    debugPrint('SHARE TO: $selectedPlatform');

    debugPrint('STORY VIDEO READY: $videoPath');

    debugPrint('SHARE TO: $selectedPlatform');

    await _shareStoryVideo(videoPath: videoPath, platform: selectedPlatform);
  }

  Future<void> _shareStoryVideo({
    required String videoPath,
    required StorySharePlatform platform,
  }) async {
    try {
      late final ShareTarget target;

      switch (platform) {
        case StorySharePlatform.instagram:
          target = ShareTarget.instagramStory;
          break;
      }

      final isAvailable = await SocialSharePlus.isAvailable(target);

      if (!mounted) {
        return;
      }

      if (!isAvailable) {
        await _showShareError(
          'Unable to open the selected application. Please try again.',
        );

        return;
      }

      late final ShareResult result;

      switch (platform) {
        case StorySharePlatform.instagram:
          result = await SocialSharePlus.instagramStory(
            config: StoryConfig(
              appId: 'YOUR_FACEBOOK_APP_ID',
              backgroundVideoPath: videoPath,
            ),
          );
          break;
      }

      if (!mounted) {
        return;
      }

      switch (result) {
        case ShareLaunched():
          debugPrint('SHARE APP OPENED');
          break;

        case ShareCompleted():
          debugPrint('SHARE COMPLETED');
          break;

        case ShareCancelled():
          debugPrint('SHARE CANCELLED');
          break;

        case ShareUnavailable():
          await _showShareError(
            'Unable to open the selected application. Please try again.',
          );
          break;

        case ShareFailed(:final code, :final message):
          debugPrint('SHARE FAILED: $code $message');

          await _showShareError(
            'Unable to open the selected application. Please try again.',
          );
          break;
      }
    } catch (error) {
      debugPrint('SHARE STORY ERROR: $error');

      if (!mounted) {
        return;
      }

      await _showShareError(
        'Unable to open the selected application. Please try again.',
      );
    }
  }

  Future<void> _showShareError(String message) async {
    if (!mounted) {
      return;
    }

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.bgCard,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Trip Story',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            message,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.btnPrimary,
                foregroundColor: Colors.white,
              ),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showStoryAlert(String message) async {
    if (!mounted) {
      return;
    }

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.bgCard,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Row(
            children: [
              Icon(Icons.info_outline_rounded, color: AppColors.btnPrimary),
              SizedBox(width: 10),
              Text(
                'Trip Story',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Text(
            message,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
              height: 1.4,
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.btnPrimary,
                foregroundColor: AppColors.bgPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'OK',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );

    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: AnimatedBuilder(
        animation: viewModel,
        builder: (context, _) {
          _checkStoryState();

          if (viewModel.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.btnPrimary),
            );
          }

          if (viewModel.errorMessage != null) {
            return _StoryErrorState(
              message: viewModel.errorMessage!,
              onRetry: viewModel.loadStory,
            );
          }

          if (viewModel.isEmpty) {
            return const _StoryEmptyState();
          }

          return _StoryContent(
            viewModel: viewModel,
            onClose: () {
              Navigator.of(context).pop();
            },
            onShare: _handleShareStory,
          );
        },
      ),
    );
  }
}

class _StoryContent extends StatelessWidget {
  const _StoryContent({
    required this.viewModel,
    required this.onClose,
    required this.onShare,
  });

  final StorySlideViewModel viewModel;
  final VoidCallback onClose;
  final Future<void> Function() onShare;

  @override
  Widget build(BuildContext context) {
    final slide = viewModel.currentSlide;

    if (slide == null) {
      return const _StoryEmptyState();
    }

    return Stack(
      children: [
        Positioned.fill(
          child: StorySlideBody(
            slide: slide,
            tripId: viewModel.tripId,
            onDone: onClose,
            onShare: onShare,
          ),
        ),

        if (slide.type == StorySlideType.tripRoadmap) ...[
          Positioned(
            left: 0,
            top: 70,
            bottom: 90,
            width: 55,
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: viewModel.previousSlide,
            ),
          ),
          Positioned(
            right: 0,
            top: 70,
            bottom: 90,
            width: 55,
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: viewModel.nextSlide,
            ),
          ),
        ] else if (slide.type == StorySlideType.ending) ...[
          Positioned(
            left: 0,
            top: 70,
            bottom: 90,
            width: 55,
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: viewModel.previousSlide,
            ),
          ),
        ] else
          Positioned.fill(
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: viewModel.previousSlide,
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: viewModel.nextSlide,
                  ),
                ),
              ],
            ),
          ),

        SafeArea(
          child: Stack(
            children: [
              Positioned(
                top: 12,
                left: 14,
                right: 14,
                child: Row(
                  children: List.generate(viewModel.slideCount, (index) {
                    return Expanded(
                      child: Container(
                        margin: EdgeInsets.only(
                          right: index == viewModel.slideCount - 1 ? 0 : 4,
                        ),
                        height: 3,
                        decoration: BoxDecoration(
                          color: index <= viewModel.currentIndex
                              ? Colors.white
                              : Colors.white.withValues(alpha: 0.35),
                          borderRadius: BorderRadius.circular(99),
                        ),
                      ),
                    );
                  }),
                ),
              ),
              Positioned(
                top: 26,
                right: 14,
                child: IconButton(
                  onPressed: onClose,
                  icon: const Icon(
                    Icons.close_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StoryEmptyState extends StatelessWidget {
  const _StoryEmptyState();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.auto_stories_outlined,
                color: AppColors.textDisabled,
                size: 48,
              ),
              const SizedBox(height: 14),
              const Text(
                'No story available for this trip.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        Positioned(
          top: 10,
          left: 6,
          child: IconButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: const Icon(
              Icons.arrow_back_ios_new,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}

class _StoryErrorState extends StatelessWidget {
  const _StoryErrorState({required this.message, required this.onRetry});

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Center(
          child: Padding(
            padding: const EdgeInsets.all(30),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.error_outline_rounded,
                  color: AppColors.btnPrimary,
                  size: 46,
                ),
                const SizedBox(height: 14),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 18),
                ElevatedButton.icon(
                  onPressed: () {
                    onRetry();
                  },
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Try Again'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.btnPrimary,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
        Positioned(
          top: 10,
          left: 6,
          child: IconButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: const Icon(
              Icons.arrow_back_ios_new,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}

class _SharePlatformTile extends StatelessWidget {
  const _SharePlatformTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.bgAccent,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: const BoxDecoration(
                  color: AppColors.bgCard,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: AppColors.btnPrimary, size: 22),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),

              const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 15,
                color: AppColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
