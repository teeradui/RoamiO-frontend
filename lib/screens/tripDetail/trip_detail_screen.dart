import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:roamio_frontend/screens/editTrip/edit_trip_screen.dart';
import 'package:roamio_frontend/screens/tripDetail/widgets/activities_section.dart';
import 'package:roamio_frontend/screens/tripDetail/widgets/map_section.dart';
import 'package:roamio_frontend/screens/tripDetail/widgets/member_section.dart';
import 'package:roamio_frontend/screens/tripDetail/widgets/overview_section.dart';
import 'package:roamio_frontend/screens/tripDetail/widgets/photo_section.dart';
import 'package:roamio_frontend/screens/tripStory/story_slide_screen.dart';
import 'package:roamio_frontend/theme/colors.dart';
import 'package:roamio_frontend/viewmodels/photo_section_view_model.dart';
import 'package:roamio_frontend/viewmodels/trip_detail_view_model.dart';
import 'package:roamio_frontend/screens/tripDetail/widgets/section_tab.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';

class TripDetailScreen extends StatefulWidget {
  const TripDetailScreen({super.key, required this.tripId});

  final String tripId;

  @override
  State<TripDetailScreen> createState() => _TripDetailScreenState();
}

class _TripDetailScreenState extends State<TripDetailScreen> {
  late final TripDetailViewModel viewModel;

  final PhotoSectionController photoSectionController =
      PhotoSectionController();

  bool _tripChanged = false;

  @override
  void initState() {
    super.initState();

    debugPrint('TRIP DETAIL SCREEN ID: ${widget.tripId}');

    viewModel = TripDetailViewModel(tripId: widget.tripId);

    viewModel.loadTrip();
  }

  @override
  void dispose() {
    photoSectionController.dispose();
    viewModel.dispose();
    super.dispose();
  }

  Future<void> _handlePhotoSelectionConfirm() async {
    final action = photoSectionController.selectionAction;

    if (action == null) {
      return;
    }

    // DELETE ต้องถามยืนยันก่อน
    if (action == PhotoSelectionAction.delete) {
      final count = photoSectionController.selectedPhotoCount;

      final confirmed = await _showConfirmationDialog(
        title: 'Delete photos?',
        message:
            'Are you sure you want to delete '
            '$count selected photo${count > 1 ? 's' : ''}?',
        confirmText: 'Delete',
      );

      if (!confirmed || !mounted) {
        return;
      }
    }

    final success = await photoSectionController.confirmSelection();

    if (!mounted || !success) {
      return;
    }

    final message = action == PhotoSelectionAction.delete
        ? 'Photos deleted successfully.'
        : 'Photos saved successfully.';

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Widget _buildSelectedSection() {
    switch (viewModel.selectedSection) {
      case TripDetailSection.overview:
        return OverviewSection(
          tripId: widget.tripId,
          tripStatus: viewModel.status,
        );
      case TripDetailSection.map:
        return MapSection(tripId: widget.tripId, tripStatus: viewModel.status);
      case TripDetailSection.activities:
        return ActivitiesSection(tripId: widget.tripId);
      case TripDetailSection.photo:
        return PhotoSection(
          tripId: widget.tripId,
          tripStatus: viewModel.status,
          controller: photoSectionController,
        );
      case TripDetailSection.member:
        return MemberSection(
          tripId: widget.tripId,
          tripStatus: viewModel.status,
        );
    }
  }

  Future<bool> _showConfirmationDialog({
    required String title,
    required String message,
    required String confirmText,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.bgCard,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            title,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 19,
              fontWeight: FontWeight.bold,
            ),
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
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text(
                "Cancel",
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                confirmText,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );

    return result ?? false;
  }

  Future<void> _showActionError(String message) async {
    if (!mounted) return;

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
              Icon(Icons.error_outline_rounded, color: AppColors.red),
              SizedBox(width: 10),
              Text(
                "Something went wrong",
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
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _handleDeleteTrip() async {
    final confirmed = await _showConfirmationDialog(
      title: "Delete Trip?",
      message:
          "This trip and its related data will be permanently deleted. This action cannot be undone.",
      confirmText: "Delete",
    );

    if (!confirmed || !mounted) return;

    final success = await viewModel.deleteTrip();

    if (!mounted) return;

    if (success) {
      Navigator.pop(context, true);
      return;
    }

    await _showActionError(
      viewModel.actionErrorMessage ?? "Unable to delete trip.",
    );

    viewModel.clearActionError();
  }

  Future<void> _handleEndTrip() async {
    final confirmed = await _showConfirmationDialog(
      title: "End Trip?",
      message:
          "Tracking will stop and this trip will be moved to your trip history.",
      confirmText: "End Trip",
    );

    if (!confirmed || !mounted) return;

    final success = await viewModel.endTrip();

    if (!mounted) return;

    if (success) {
      setState(() {
        _tripChanged = true;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Trip ended successfully.")));

      return;
    }

    await _showActionError(
      viewModel.actionErrorMessage ?? "Unable to end trip.",
    );

    viewModel.clearActionError();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;

        Navigator.pop(context, _tripChanged);
      },
      child: AnimatedBuilder(
        animation: viewModel,
        builder: (context, _) {
          if (viewModel.isLoading) {
            return const Scaffold(
              backgroundColor: AppColors.bgPrimary,
              body: Center(child: CircularProgressIndicator()),
            );
          }

          if (viewModel.errorMessage != null) {
            return Scaffold(
              backgroundColor: AppColors.bgPrimary,
              body: SafeArea(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                      child: Row(
                        children: [
                          IconButton(
                            onPressed: () {
                              Navigator.pop(context, _tripChanged);
                            },
                            icon: const Icon(
                              Icons.arrow_back_ios_new,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const Text(
                            "Trip Detail",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),

                    Expanded(
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 32),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.error_outline_rounded,
                                size: 48,
                                color: AppColors.btnPrimary,
                              ),

                              const SizedBox(height: 12),

                              Text(
                                viewModel.errorMessage!,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),

                              const SizedBox(height: 18),

                              SizedBox(
                                width: 140,
                                height: 46,
                                child: ElevatedButton(
                                  onPressed: viewModel.loadTrip,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.btnPrimary,
                                    foregroundColor: AppColors.bgPrimary,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                  ),
                                  child: const Text(
                                    "Try Again",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return Scaffold(
            backgroundColor: AppColors.bgPrimary,
            body: SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () {
                            Navigator.pop(context, _tripChanged);
                          },
                          icon: const Icon(
                            Icons.arrow_back_ios_new,
                            color: AppColors.textPrimary,
                          ),
                        ),

                        const Expanded(
                          child: Text(
                            "Trip Detail",
                            textAlign: TextAlign.justify,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),

                        const Spacer(),

                        viewModel.isActive
                            ? InkWell(
                                onTap: viewModel.isProcessingAction
                                    ? null
                                    : _handleEndTrip,
                                borderRadius: BorderRadius.circular(100),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 18,
                                    vertical: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(
                                      0xFFFF6666,
                                    ).withValues(alpha: 0.26),
                                    borderRadius: BorderRadius.circular(100),
                                  ),
                                  child: const Text(
                                    "End Trip",
                                    style: TextStyle(
                                      color: AppColors.red,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              )
                            : InkWell(
                                onTap: viewModel.isProcessingAction
                                    ? null
                                    : _handleDeleteTrip,
                                borderRadius: BorderRadius.circular(99),
                                child: Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: const Color(
                                      0xFFFF6666,
                                    ).withValues(alpha: 0.26),
                                  ),
                                  child: const Center(
                                    child: HugeIcon(
                                      icon: HugeIcons.strokeRoundedDelete02,
                                      color: AppColors.red,
                                      size: 18,
                                    ),
                                  ),
                                ),
                              ),
                      ],
                    ),
                  ),

                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.bgCard,
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: .04),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Center(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(20),
                                    child: Container(
                                      height: 120,
                                      width: 120,
                                      color: AppColors.bgAccent,
                                      child:
                                          viewModel.imageUrl == null ||
                                              viewModel.imageUrl!.trim().isEmpty
                                          ? const Icon(
                                              Icons.image_outlined,
                                              size: 48,
                                              color: AppColors.textSecondary,
                                            )
                                          : Image.network(
                                              viewModel.imageUrl!,
                                              fit: BoxFit.cover,
                                              errorBuilder:
                                                  (context, error, stackTrace) {
                                                    debugPrint(
                                                      'LOAD TRIP DETAIL IMAGE ERROR: $error',
                                                    );

                                                    return const Icon(
                                                      Icons
                                                          .broken_image_outlined,
                                                      size: 48,
                                                      color: AppColors
                                                          .textSecondary,
                                                    );
                                                  },
                                            ),
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 1),

                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      viewModel.tripName,
                                      style: const TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    if (!viewModel.isCompleted &&
                                        !viewModel.isActive) ...[
                                      IconButton(
                                        onPressed: () async {
                                          final updated =
                                              await Navigator.push<bool>(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (_) =>
                                                      EditTripScreen(
                                                        tripId:
                                                            viewModel.tripId,
                                                      ),
                                                ),
                                              );

                                          if (!mounted) return;

                                          if (updated == true) {
                                            _tripChanged = true;

                                            await viewModel.loadTrip(
                                              forceRefresh: true,
                                            );
                                          }
                                        },
                                        icon: const HugeIcon(
                                          icon: HugeIcons
                                              .strokeRoundedPencilEdit01,
                                          color: AppColors.iconOrange,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),

                                const SizedBox(height: 2),

                                Text(
                                  viewModel.destination,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),

                                const SizedBox(height: 10),

                                Center(
                                  child: _InfoRow(
                                    icon: viewModel.statusIcon,
                                    iconColor: viewModel.statusColor,
                                    text: viewModel.statusText,
                                    textColor: viewModel.statusColor,
                                    backgroundColor:
                                        viewModel.statusBackgroundColor,
                                  ),
                                ),

                                const SizedBox(height: 8),

                                Center(
                                  child: _InfoRow(
                                    icon: Icons.calendar_today_outlined,
                                    text:
                                        "${viewModel.startDate} — ${viewModel.endDate}",
                                  ),
                                ),

                                const SizedBox(height: 2),

                                Center(
                                  child: _InfoRow(
                                    icon: Icons.location_on_outlined,
                                    text: viewModel.meetingPointText,
                                  ),
                                ),

                                const SizedBox(height: 10),

                                Container(
                                  width: double.infinity,
                                  height: 60,
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: AppColors.bgAccent,
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                  child: Row(
                                    children: [
                                      const HugeIcon(
                                        icon: HugeIcons.strokeRoundedRoute03,
                                        color: AppColors.iconOrange,
                                      ),

                                      const SizedBox(width: 12),
                                      const Text(
                                        "Travel Distance",
                                        style: TextStyle(
                                          color: AppColors.textSecondary,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const Spacer(),
                                      Text(
                                        "${viewModel.distanceKm.toStringAsFixed(1)} km",
                                        style: const TextStyle(
                                          color: AppColors.textPrimary,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                const SizedBox(height: 10),

                                Center(
                                  child: SizedBox(
                                    height: 56,
                                    width:
                                        48 +
                                        (viewModel.members.length - 1) * 30,
                                    child: Stack(
                                      children: List.generate(
                                        viewModel.members.length,
                                        (index) {
                                          final member =
                                              viewModel.members[index];

                                          return Positioned(
                                            left: index * 30.0,
                                            child: Container(
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                border: Border.all(
                                                  color: AppColors.bgCard,
                                                  width: 3,
                                                ),
                                              ),
                                              child: CircleAvatar(
                                                radius: 24,
                                                backgroundColor:
                                                    AppColors.bgAccent,
                                                backgroundImage:
                                                    member.imageUrl != null
                                                    ? NetworkImage(
                                                        member.imageUrl!,
                                                      )
                                                    : null,
                                                child: member.imageUrl == null
                                                    ? const Icon(
                                                        Icons.person,
                                                        color: AppColors
                                                            .textSecondary,
                                                      )
                                                    : null,
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),

                          if (viewModel.isCompleted) ...[
                            _ViewTripStoryButton(tripId: widget.tripId),

                            const SizedBox(height: 12),
                          ],
                          TripDetailSectionTab(viewModel: viewModel),

                          const SizedBox(height: 18),

                          _buildSelectedSection(),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            bottomNavigationBar:
                viewModel.selectedSection == TripDetailSection.photo
                ? AnimatedBuilder(
                    animation: photoSectionController,
                    builder: (context, _) {
                      if (!photoSectionController.isSelectionMode) {
                        return const SizedBox.shrink();
                      }

                      return _PhotoSelectionBottomBar(
                        action: photoSectionController.selectionAction!,
                        hasSelectedPhotos:
                            photoSectionController.hasSelectedPhotos,
                        selectedCount:
                            photoSectionController.selectedPhotoCount,
                        onCancel: photoSectionController.cancelSelection,
                        onConfirm: _handlePhotoSelectionConfirm,
                      );
                    },
                  )
                : null,
          );
        },
      ),
    );
  }
}

class _PhotoSelectionBottomBar extends StatelessWidget {
  const _PhotoSelectionBottomBar({
    required this.action,
    required this.hasSelectedPhotos,
    required this.selectedCount,
    required this.onCancel,
    required this.onConfirm,
  });

  final PhotoSelectionAction action;
  final bool hasSelectedPhotos;
  final int selectedCount;

  final VoidCallback onCancel;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    final isDelete = action == PhotoSelectionAction.delete;

    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
        decoration: BoxDecoration(
          color: AppColors.bgPrimary,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 8,
              spreadRadius: 0,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$selectedCount selected',
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 8),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onCancel,
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(50),
                      foregroundColor: AppColors.textPrimary,
                      side: const BorderSide(color: AppColors.textDisabled),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: ElevatedButton(
                    onPressed: hasSelectedPhotos ? onConfirm : null,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(50),
                      backgroundColor: isDelete
                          ? AppColors.red
                          : AppColors.btnPrimary,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: AppColors.bgAccent,
                      disabledForegroundColor: AppColors.textDisabled,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(
                      isDelete ? 'Delete' : 'Save',
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.text,
    this.iconColor = AppColors.textSecondary,
    this.textColor = AppColors.textSecondary,
    this.backgroundColor,
  });

  final dynamic icon;
  final String text;
  final Color iconColor;
  final Color textColor;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 300),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          icon is IconData
              ? Icon(icon, size: 18, color: iconColor)
              : HugeIcon(icon: icon, size: 18, color: iconColor),

          const SizedBox(width: 8),

          Flexible(
            child: Text(
              text,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: textColor,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ViewTripStoryButton extends StatelessWidget {
  const _ViewTripStoryButton({required this.tripId});

  final String tripId;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 52,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => StorySlideScreen(tripId: tripId)),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.bgCard,
          foregroundColor: AppColors.textPrimary,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        icon: ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: AppColors.sparkle,
          ).createShader(bounds),
          child: const Icon(
            FluentIcons.sparkle_32_filled,
            size: 20,
            color: Colors.white,
          ),
        ),
        label: const Text(
          "View Trip Wrap-up Story",
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
