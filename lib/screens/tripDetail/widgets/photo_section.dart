import 'dart:io';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:roamio_frontend/theme/colors.dart';
import 'package:roamio_frontend/viewmodels/photo_section_view_model.dart';
import 'package:roamio_frontend/viewmodels/trip_detail_view_model.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:roamio_frontend/models/services/photo_album_service.dart';

class PhotoSectionController extends ChangeNotifier {
  PhotoSectionViewModel? _viewModel;

  void attach(PhotoSectionViewModel viewModel) {
    if (identical(_viewModel, viewModel)) {
      return;
    }

    _viewModel?.removeListener(_handleViewModelChanged);

    _viewModel = viewModel;
    _viewModel!.addListener(_handleViewModelChanged);

    notifyListeners();
  }

  void detach(PhotoSectionViewModel viewModel) {
    if (!identical(_viewModel, viewModel)) {
      return;
    }

    _viewModel?.removeListener(_handleViewModelChanged);
    _viewModel = null;

    notifyListeners();
  }

  void _handleViewModelChanged() {
    notifyListeners();
  }

  bool get isSelectionMode => _viewModel?.isSelectionMode ?? false;

  PhotoSelectionAction? get selectionAction => _viewModel?.selectionAction;

  bool get hasSelectedPhotos => _viewModel?.hasSelectedPhotos ?? false;

  int get selectedPhotoCount => _viewModel?.selectedPhotoCount ?? 0;

  void cancelSelection() {
    _viewModel?.cancelSelection();
  }

  Future<bool> confirmSelection() async {
    final viewModel = _viewModel;

    if (viewModel == null) {
      return false;
    }

    return viewModel.confirmSelection();
  }
}

class PhotoSection extends StatefulWidget {
  const PhotoSection({
    super.key,
    required this.tripId,
    required this.tripStatus,
    required this.controller,
    required this.tripStartDateTime,
    required this.tripEndDateTime,
  });

  final String tripId;
  final TripStatus tripStatus;
  final PhotoSectionController controller;
  final DateTime? tripStartDateTime;
  final DateTime? tripEndDateTime;

  @override
  State<PhotoSection> createState() => _PhotoSectionState();
}

class _PhotoSectionState extends State<PhotoSection> {
  late final PhotoSectionViewModel viewModel;
  Timer? _photoRefreshDebounce;

  void _handlePhotoLibraryChanged(MethodCall call) {
    if (!mounted || !viewModel.hasSelectedAlbum || !viewModel.isActive) {
      return;
    }

    _photoRefreshDebounce?.cancel();

    _photoRefreshDebounce = Timer(const Duration(milliseconds: 700), () {
      if (!mounted) {
        return;
      }

      debugPrint('PHOTO LIBRARY CHANGED → REFRESH');

      viewModel.loadPhotosFromSelectedAlbum();
    });
  }

  @override
  void initState() {
    super.initState();

    viewModel = PhotoSectionViewModel(
      tripId: widget.tripId,
      tripStatus: widget.tripStatus,
      tripStartDateTime: widget.tripStartDateTime,
      tripEndDateTime: widget.tripEndDateTime,
    );

    widget.controller.attach(viewModel);

    viewModel.initialize();

    PhotoManager.addChangeCallback(_handlePhotoLibraryChanged);

    PhotoManager.startChangeNotify();
  }

  @override
  void dispose() {
    _photoRefreshDebounce?.cancel();
    PhotoManager.removeChangeCallback(_handlePhotoLibraryChanged);

    PhotoManager.stopChangeNotify();

    widget.controller.detach(viewModel);
    viewModel.dispose();

    super.dispose();
  }

  Future<void> _showAlbumPicker() async {
    try {
      final albums = await viewModel.loadAvailableAlbums();

      if (!mounted) return;

      if (albums.isEmpty) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('No photo albums found.')));
        return;
      }

      DevicePhotoAlbum? selectedAlbum;

      if (Platform.isIOS) {
        selectedAlbum = await _showIOSAlbumPicker(albums);
      } else {
        selectedAlbum = await _showAndroidAlbumPicker(albums);
      }

      if (!mounted || selectedAlbum == null) {
        return;
      }

      await viewModel.selectAlbum(selectedAlbum);
    } catch (error) {
      if (!mounted) return;

      final message = error.toString();

      if (message.contains('PHOTO_PERMISSION_DENIED')) {
        await _showPhotoPermissionDialog();
      }
    }
  }

  Future<DevicePhotoAlbum?> _showIOSAlbumPicker(
    List<DevicePhotoAlbum> albums,
  ) async {
    return showModalBottomSheet<DevicePhotoAlbum>(
      context: context,
      isScrollControlled: true,
      backgroundColor: CupertinoColors.systemBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return SafeArea(
          top: false,
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.72,
            child: Column(
              children: [
                const SizedBox(height: 10),

                Container(
                  width: 38,
                  height: 5,
                  decoration: BoxDecoration(
                    color: CupertinoColors.systemGrey4,
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),

                const SizedBox(height: 18),

                const Text(
                  'Select Album',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: CupertinoColors.label,
                  ),
                ),

                const SizedBox(height: 14),

                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: albums.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final album = albums[index];

                      final isSelected = viewModel.selectedAlbumId == album.id;

                      return CupertinoButton(
                        padding: EdgeInsets.zero,
                        onPressed: () {
                          Navigator.pop(context, album);
                        },
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: CupertinoColors.secondarySystemBackground,
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(14),
                                child: SizedBox(
                                  width: 72,
                                  height: 72,
                                  child: album.coverBytes != null
                                      ? Image.memory(
                                          album.coverBytes!,
                                          fit: BoxFit.cover,
                                        )
                                      : Container(
                                          color: CupertinoColors.systemGrey5,
                                          child: const Icon(
                                            CupertinoIcons.photo,
                                            color: CupertinoColors.systemGrey,
                                            size: 28,
                                          ),
                                        ),
                                ),
                              ),

                              const SizedBox(width: 14),

                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      album.name,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        color: CupertinoColors.label,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),

                                    const SizedBox(height: 4),

                                    Text(
                                      '${album.assetCount} photos',
                                      style: const TextStyle(
                                        color: CupertinoColors.secondaryLabel,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              if (isSelected)
                                const Icon(
                                  CupertinoIcons.check_mark_circled_solid,
                                  color: CupertinoColors.activeBlue,
                                  size: 24,
                                )
                              else
                                const Icon(
                                  CupertinoIcons.chevron_forward,
                                  color: CupertinoColors.systemGrey2,
                                  size: 18,
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<DevicePhotoAlbum?> _showAndroidAlbumPicker(
    List<DevicePhotoAlbum> albums,
  ) async {
    return showModalBottomSheet<DevicePhotoAlbum>(
      context: context,
      backgroundColor: AppColors.bgCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),

              Container(
                width: 42,
                height: 5,
                decoration: BoxDecoration(
                  color: AppColors.textDisabled,
                  borderRadius: BorderRadius.circular(99),
                ),
              ),

              const SizedBox(height: 18),

              const Text(
                'Select Photo Album',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),

              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: albums.length,
                  separatorBuilder: (_, __) =>
                      const Divider(height: 1, color: AppColors.bgAccent),
                  itemBuilder: (context, index) {
                    final album = albums[index];

                    final isSelected = viewModel.selectedAlbumId == album.id;

                    return ListTile(
                      leading: const HugeIcon(
                        icon: HugeIcons.strokeRoundedAlbum02,
                        color: AppColors.btnPrimary,
                        size: 24,
                      ),
                      title: Text(
                        album.name,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: Text(
                        '${album.assetCount} photos',
                        style: const TextStyle(color: AppColors.textSecondary),
                      ),
                      trailing: isSelected
                          ? const Icon(
                              Icons.check_circle_rounded,
                              color: AppColors.btnPrimary,
                            )
                          : null,
                      onTap: () {
                        Navigator.pop(context, album);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _showPhotoPermissionDialog() async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Photo Access Required'),
          content: const Text(
            'Please allow RoamiO to access your photo library to select a trip album.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(dialogContext);

                await PhotoManager.openSetting();
              },
              child: const Text('Settings'),
            ),
          ],
        );
      },
    );
  }

  Future<bool> _showDeleteConfirmation(BuildContext context, int count) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete photos?'),
          content: Text(
            'Are you sure you want to delete '
            '$count selected photo${count > 1 ? 's' : ''}?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text('Cancel'),
            ),

            TextButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );

    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: viewModel,
      builder: (context, _) {
        return Stack(
          clipBehavior: Clip.none,
          children: [
            Padding(
              padding: EdgeInsets.only(
                bottom: viewModel.isSelectionMode ? 82 : 0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!viewModel.isSelectionMode)
                    _SelectAlbumButton(
                      title: viewModel.albumTitleText,
                      subtitle: viewModel.albumSubtitleText,
                      isLoading: viewModel.isSelectingAlbum,
                      enabled: viewModel.canSelectAlbum,
                      hasSelectedAlbum: viewModel.hasSelectedAlbum,
                      onTap:
                          viewModel.canSelectAlbum &&
                              !viewModel.isSelectingAlbum
                          ? _showAlbumPicker
                          : null,
                    ),

                  if (viewModel.hasPhotos) ...[
                    const SizedBox(height: 18),

                    if (viewModel.isSelectionMode)
                      _SelectionHeader(
                        title: viewModel.selectionTitle,
                        selectedCount: viewModel.selectedPhotoCount,
                        isAllSelected: viewModel.areAllPhotosSelected,
                        onSelectAll: viewModel.toggleSelectAll,
                      )
                    else
                      _PhotoActionHeader(
                        onSave: () {
                          viewModel.enterSelectionMode(
                            PhotoSelectionAction.save,
                          );
                        },
                        onDelete: () {
                          viewModel.enterSelectionMode(
                            PhotoSelectionAction.delete,
                          );
                        },
                      ),
                  ],

                  const SizedBox(height: 22),

                  if (viewModel.isLoading)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 40),
                      child: Center(
                        child: CircularProgressIndicator(
                          color: AppColors.btnPrimary,
                        ),
                      ),
                    )
                  else if (viewModel.errorMessage != null)
                    _PhotoErrorState(
                      message: viewModel.errorMessage!,
                      onRetry: viewModel.retry,
                    )
                  else if (!viewModel.hasPhotos)
                    _NoPhotosState(
                      isCompleted: viewModel.isCompleted,
                      hasSelectedAlbum: viewModel.hasSelectedAlbum,
                    )
                  else
                    _PhotoGroups(
                      groups: viewModel.photoGroups,
                      isSelectionMode: viewModel.isSelectionMode,
                      isPhotoSelected: viewModel.isPhotoSelected,
                      onPhotoTap: viewModel.togglePhotoSelection,
                    ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _SelectAlbumButton extends StatelessWidget {
  const _SelectAlbumButton({
    required this.title,
    required this.subtitle,
    required this.onTap,
    required this.isLoading,
    required this.enabled,
    required this.hasSelectedAlbum,
  });

  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  final bool isLoading;
  final bool enabled;
  final bool hasSelectedAlbum;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          width: double.infinity,
          height: 80,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: enabled ? AppColors.bgCard : AppColors.bgAccent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              HugeIcon(
                icon: HugeIcons.strokeRoundedAlbum02,
                color: enabled ? AppColors.btnPrimary : AppColors.textDisabled,
                size: 28,
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: hasSelectedAlbum
                            ? AppColors.textPrimary
                            : AppColors.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    const SizedBox(height: 2),

                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: hasSelectedAlbum && enabled
                            ? AppColors.btnPrimary
                            : AppColors.textDisabled,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              if (isLoading)
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.btnPrimary,
                  ),
                )
              else if (enabled)
                const Icon(Icons.chevron_right, color: AppColors.textPrimary),
            ],
          ),
        ),
      ),
    );
  }
}

class _PhotoActionHeader extends StatelessWidget {
  const _PhotoActionHeader({required this.onSave, required this.onDelete});

  final VoidCallback onSave;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Trip Photos',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),

        PopupMenuButton<String>(
          icon: const Icon(
            Icons.more_horiz_rounded,
            color: AppColors.textPrimary,
          ),
          color: AppColors.bgCard,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          onSelected: (value) {
            if (value == 'save') {
              onSave();
            } else if (value == 'delete') {
              onDelete();
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'save',
              child: Row(
                children: [
                  Icon(Icons.download_rounded, color: AppColors.textPrimary),
                  SizedBox(width: 10),
                  Text('Save'),
                ],
              ),
            ),

            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete_outline_rounded, color: Colors.red),
                  SizedBox(width: 10),
                  Text('Delete', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _SelectionHeader extends StatelessWidget {
  const _SelectionHeader({
    required this.title,
    required this.selectedCount,
    required this.isAllSelected,
    required this.onSelectAll,
  });

  final String title;
  final int selectedCount;
  final bool isAllSelected;
  final VoidCallback onSelectAll;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),

              const SizedBox(height: 2),

              Text(
                '$selectedCount selected',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),

        TextButton.icon(
          onPressed: onSelectAll,
          icon: Icon(
            isAllSelected
                ? Icons.check_circle_rounded
                : Icons.radio_button_unchecked_rounded,
            color: AppColors.btnPrimary,
            size: 19,
          ),
          label: Text(
            isAllSelected ? 'Deselect All' : 'Select All',
            style: const TextStyle(
              color: AppColors.btnPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _PhotoGroups extends StatelessWidget {
  const _PhotoGroups({
    required this.groups,
    required this.isSelectionMode,
    required this.isPhotoSelected,
    required this.onPhotoTap,
  });

  final List<TripPhotoGroup> groups;

  final bool isSelectionMode;

  final bool Function(String photoId) isPhotoSelected;

  final void Function(String photoId) onPhotoTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: groups.map((group) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.location_on_rounded,
                    size: 17,
                    color: AppColors.btnPrimary,
                  ),

                  const SizedBox(width: 6),

                  Expanded(
                    child: Text(
                      group.showDate
                          ? '${group.dateText} · ${group.locationName}'
                          : group.locationName,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  Text(
                    '${group.photos.length} photos',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: group.photos.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                ),
                itemBuilder: (context, index) {
                  final photo = group.photos[index];

                  return _PhotoTile(
                    photo: photo,
                    isSelectionMode: isSelectionMode,
                    isSelected: isPhotoSelected(photo.id),
                    onTap: () {
                      onPhotoTap(photo.id);
                    },
                  );
                },
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _PhotoTile extends StatelessWidget {
  const _PhotoTile({
    required this.photo,
    required this.isSelectionMode,
    required this.isSelected,
    required this.onTap,
  });

  final TripPhotoItem photo;

  final bool isSelectionMode;
  final bool isSelected;

  final VoidCallback onTap;

  Widget _buildPhoto() {
    if (photo.localFile != null) {
      return Image.file(photo.localFile!, fit: BoxFit.cover);
    }

    if (photo.imageUrl != null && photo.imageUrl!.isNotEmpty) {
      return Image.network(
        photo.imageUrl!,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _buildErrorImage();
        },
      );
    }

    return _buildErrorImage();
  }

  Widget _buildErrorImage() {
    return Container(
      color: AppColors.bgAccent,
      child: const Icon(
        Icons.broken_image_outlined,
        color: AppColors.textDisabled,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isSelectionMode ? onTap : null,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          fit: StackFit.expand,
          children: [
            _buildPhoto(),
            if (isSelectionMode && isSelected)
              Container(color: Colors.black.withValues(alpha: 0.25)),

            // checkbox
            if (isSelectionMode)
              Positioned(
                top: 7,
                right: 7,
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.btnPrimary
                        : Colors.white.withValues(alpha: 0.85),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected
                          ? AppColors.btnPrimary
                          : AppColors.textDisabled,
                      width: 1.5,
                    ),
                  ),
                  child: isSelected
                      ? const Icon(
                          Icons.check_rounded,
                          size: 17,
                          color: Colors.white,
                        )
                      : null,
                ),
              ),

            // Owner profile
            if (!isSelectionMode)
              Positioned(
                right: 6,
                bottom: 6,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: CircleAvatar(
                    radius: 11,
                    backgroundColor: AppColors.bgAccent,
                    backgroundImage:
                        photo.ownerProfileImageUrl != null &&
                            photo.ownerProfileImageUrl!.trim().isNotEmpty
                        ? NetworkImage(photo.ownerProfileImageUrl!)
                        : null,
                    child:
                        photo.ownerProfileImageUrl == null ||
                            photo.ownerProfileImageUrl!.trim().isEmpty
                        ? const Icon(
                            Icons.person_rounded,
                            size: 13,
                            color: AppColors.textSecondary,
                          )
                        : null,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _NoPhotosState extends StatelessWidget {
  const _NoPhotosState({
    required this.isCompleted,
    required this.hasSelectedAlbum,
  });

  final bool isCompleted;
  final bool hasSelectedAlbum;

  @override
  Widget build(BuildContext context) {
    String title;
    String message;

    if (isCompleted && !hasSelectedAlbum) {
      title = 'No trip photos available';
      message = 'No photo album was selected before this trip was completed.';
    } else {
      title = 'No photos yet';
      message = 'Photos will be imported automatically from your album.';
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const FaIcon(
              FontAwesomeIcons.solidCamera,
              size: 36,
              color: AppColors.textDisabled,
            ),

            const SizedBox(height: 10),

            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textDisabled,
              ),
            ),

            const SizedBox(height: 8),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textDisabled,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PhotoErrorState extends StatelessWidget {
  const _PhotoErrorState({required this.message, required this.onRetry});

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
      child: Center(
        child: Column(
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 40,
              color: AppColors.btnPrimary,
            ),

            const SizedBox(height: 10),

            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 14),

            ElevatedButton(
              onPressed: () {
                onRetry();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.btnPrimary,
                foregroundColor: AppColors.bgPrimary,
              ),
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }
}
