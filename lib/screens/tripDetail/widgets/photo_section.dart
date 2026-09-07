import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:roamio_frontend/theme/colors.dart';
import 'package:roamio_frontend/viewmodels/photo_section_view_model.dart';
import 'package:roamio_frontend/viewmodels/trip_detail_view_model.dart';

class PhotoSection extends StatefulWidget {
  const PhotoSection({
    super.key,
    required this.tripId,
    required this.tripStatus,
  });

  final String tripId;
  final TripStatus tripStatus;

  @override
  State<PhotoSection> createState() => _PhotoSectionState();
}

class _PhotoSectionState extends State<PhotoSection> {
  late final PhotoSectionViewModel viewModel;

  @override
  void initState() {
    super.initState();

    viewModel = PhotoSectionViewModel(
      tripId: widget.tripId,
      tripStatus: widget.tripStatus,
    );

    viewModel.initialize();
  }

  @override
  void dispose() {
    viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: viewModel,
      builder: (context, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SelectAlbumButton(
              text: viewModel.selectAlbumText,
              isLoading: viewModel.isSelectingAlbum,
              enabled: viewModel.canSelectAlbum,
              onTap: viewModel.canSelectAlbum && !viewModel.isSelectingAlbum
                  ? viewModel.selectAlbum
                  : null,
            ),

            const SizedBox(height: 22),

            if (viewModel.isLoading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 40),
                child: Center(
                  child: CircularProgressIndicator(color: AppColors.btnPrimary),
                ),
              )
            else if (viewModel.errorMessage != null)
              _PhotoErrorState(
                message: viewModel.errorMessage!,
                onRetry: viewModel.retry,
              )
            else if (!viewModel.hasPhotos)
              const _NoPhotosState()
            else
              _PhotoGroups(groups: viewModel.photoGroups),
          ],
        );
      },
    );
  }
}

class _SelectAlbumButton extends StatelessWidget {
  const _SelectAlbumButton({
    required this.text,
    required this.onTap,
    required this.isLoading,
    required this.enabled,
  });

  final String text;
  final VoidCallback? onTap;
  final bool isLoading;
  final bool enabled;

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
                    const Text(
                      'Select Photo Album',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    const SizedBox(height: 2),

                    Text(
                      text,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.textDisabled,
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
              else
                const Icon(Icons.chevron_right, color: AppColors.textPrimary),
            ],
          ),
        ),
      ),
    );
  }
}

class _PhotoGroups extends StatelessWidget {
  const _PhotoGroups({required this.groups});

  final List<TripPhotoGroup> groups;

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

                  return _PhotoTile(photo: photo);
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
  const _PhotoTile({required this.photo});

  final TripPhotoItem photo;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.network(
            photo.imageUrl,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: AppColors.bgAccent,
                child: const Icon(
                  Icons.broken_image_outlined,
                  color: AppColors.textDisabled,
                ),
              );
            },
          ),

          if (photo.activityType != null)
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
    );
  }
}


class _NoPhotosState extends StatelessWidget {
  const _NoPhotosState();

  @override
  Widget build(BuildContext context) {
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

            const Text(
              'No photos yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textDisabled,
              ),
            ),

            const SizedBox(height: 8),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                'Photos will be imported automatically from your album.',
                textAlign: TextAlign.center,
                style: TextStyle(
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
