import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import 'package:roamio_frontend/theme/colors.dart';
import 'package:roamio_frontend/viewmodels/story_ending_view_model.dart';

class StoryEndingSlide extends StatefulWidget {
  const StoryEndingSlide({
    super.key,
    required this.tripId,
    required this.onDone,
  });

  final String tripId;

  final VoidCallback onDone;

  @override
  State<StoryEndingSlide> createState() => _StoryEndingSlideState();
}

class _StoryEndingSlideState extends State<StoryEndingSlide>
    with SingleTickerProviderStateMixin {
  late final StoryEndingViewModel viewModel;
  late final AnimationController _introController;

  @override
  void initState() {
    super.initState();

    viewModel = StoryEndingViewModel(tripId: widget.tripId);
    _introController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _introController.forward();
  }

  @override
  void dispose() {
    _introController.dispose();
    viewModel.dispose();
    super.dispose();
  }

  Future<void> _handleShare() async {
    debugPrint('ENDING SLIDE: SHARE BUTTON PRESSED');

    final generated = await viewModel.prepareStoryVideo();

    if (!mounted) return;

    if (!generated) {
      await _showErrorAlert();
      return;
    }

    await _showSharePlatformSheet();
  }

  Future<void> _showSharePlatformSheet() async {
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
                  textAlign: TextAlign.center,
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

                const SizedBox(height: 10),

                _SharePlatformTile(
                  icon: Icons.facebook_rounded,
                  label: 'Facebook',
                  onTap: () {
                    Navigator.pop(sheetContext, StorySharePlatform.facebook);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );

    if (selectedPlatform == null) {
      debugPrint('SHARE PROCESS CANCELLED');
      return;
    }

    debugPrint(
      'SELECTED SHARE PLATFORM: '
      '${viewModel.getPlatformName(selectedPlatform)}',
    );

    final success = await viewModel.shareToPlatform(selectedPlatform);

    if (!mounted) return;

    if (!success) {
      await _showErrorAlert();
    }
  }

  Future<void> _showErrorAlert() async {
    final message = viewModel.errorMessage;

    if (message == null || !mounted) {
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
          title: const Row(
            children: [
              Icon(Icons.error_outline_rounded, color: AppColors.btnPrimary),
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
              ),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );

    viewModel.clearError();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: viewModel,
      builder: (context, _) {
        return Container(
          width: double.infinity,
          height: double.infinity,
          padding: const EdgeInsets.fromLTRB(28, 70, 28, 44),

          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FadeTransition(
                opacity: CurvedAnimation(
                  parent: _introController,
                  curve: const Interval(0.00, 0.30, curve: Curves.easeOut),
                ),
                child: ScaleTransition(
                  scale: Tween<double>(begin: 0.65, end: 1.0).animate(
                    CurvedAnimation(
                      parent: _introController,
                      curve: const Interval(
                        0.00,
                        0.40,
                        curve: Curves.easeOutBack,
                      ),
                    ),
                  ),
                  child: Lottie.asset(
                    'assets/storyicon.json',
                    width: 260,
                    height: 260,
                    repeat: true,
                    fit: BoxFit.contain,
                  ),
                ),
              ),

              const SizedBox(height: 8),

              FadeTransition(
                opacity: CurvedAnimation(
                  parent: _introController,
                  curve: const Interval(0.20, 0.48, curve: Curves.easeOut),
                ),
                child: ScaleTransition(
                  scale: Tween<double>(begin: 0.88, end: 1.0).animate(
                    CurvedAnimation(
                      parent: _introController,
                      curve: const Interval(
                        0.20,
                        0.50,
                        curve: Curves.easeOutBack,
                      ),
                    ),
                  ),
                  child: const Text(
                    'Until We Roam Again!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 8),

              FadeTransition(
                opacity: CurvedAnimation(
                  parent: _introController,
                  curve: const Interval(0.35, 0.60, curve: Curves.easeOut),
                ),
                child: SlideTransition(
                  position:
                      Tween<Offset>(
                        begin: const Offset(0, 0.25),
                        end: Offset.zero,
                      ).animate(
                        CurvedAnimation(
                          parent: _introController,
                          curve: const Interval(
                            0.35,
                            0.60,
                            curve: Curves.easeOutCubic,
                          ),
                        ),
                      ),
                  child: const Text(
                    'Can’t wait to make more memories with you!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 34),

              FadeTransition(
                opacity: CurvedAnimation(
                  parent: _introController,
                  curve: const Interval(0.50, 0.78, curve: Curves.easeOut),
                ),
                child: SlideTransition(
                  position:
                      Tween<Offset>(
                        begin: const Offset(0, 0.45),
                        end: Offset.zero,
                      ).animate(
                        CurvedAnimation(
                          parent: _introController,
                          curve: const Interval(
                            0.50,
                            0.80,
                            curve: Curves.easeOutBack,
                          ),
                        ),
                      ),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.16),
                          blurRadius: 14,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: viewModel.isProcessing ? null : _handleShare,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.bgCard,
                          foregroundColor: AppColors.black,
                          disabledBackgroundColor: AppColors.textDisabled,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: viewModel.isGeneratingVideo
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: AppColors.black,
                                ),
                              )
                            : const Text(
                                'Share',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              FadeTransition(
                opacity: CurvedAnimation(
                  parent: _introController,
                  curve: const Interval(0.65, 0.92, curve: Curves.easeOut),
                ),
                child: SlideTransition(
                  position:
                      Tween<Offset>(
                        begin: const Offset(0, 0.45),
                        end: Offset.zero,
                      ).animate(
                        CurvedAnimation(
                          parent: _introController,
                          curve: const Interval(
                            0.65,
                            1.00,
                            curve: Curves.easeOutBack,
                          ),
                        ),
                      ),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.22),
                          blurRadius: 14,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: viewModel.isProcessing
                            ? null
                            : () {
                                debugPrint('ENDING SLIDE: DONE BUTTON PRESSED');

                                widget.onDone();
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.black,
                          foregroundColor: AppColors.bgCard,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text(
                          'Done',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
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
