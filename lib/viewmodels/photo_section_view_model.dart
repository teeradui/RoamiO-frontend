import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:geocoding/geocoding.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:roamio_frontend/viewmodels/trip_detail_view_model.dart';
import 'package:roamio_frontend/models/services/trip_summary_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:roamio_frontend/models/services/photo_album_service.dart';

class TripPhotoItem {
  const TripPhotoItem({
    required this.id,
    required this.capturedAt,
    required this.ownerUserId,
    required this.ownerUsername,
    this.imageUrl,
    this.localFile,
    this.ownerProfileImageUrl,
    this.locationName,
    this.activityType,
    this.latitude,
    this.longitude,
  });

  final String id;

  final String? imageUrl;
  final File? localFile;

  final DateTime capturedAt;

  final String ownerUserId;
  final String ownerUsername;
  final String? ownerProfileImageUrl;

  final String? locationName;
  final String? activityType;

  final double? latitude;
  final double? longitude;
}

class TripPhotoGroup {
  const TripPhotoGroup({
    required this.dateText,
    required this.locationName,
    required this.showDate,
    required this.photos,
  });

  final String dateText;
  final String locationName;
  final bool showDate;
  final List<TripPhotoItem> photos;
}

enum PhotoSelectionAction { save, delete }

class PhotoSectionViewModel extends ChangeNotifier {
  PhotoSectionViewModel({
    required this.tripId,
    required this.tripStatus,
    required this.tripStartDateTime,
    required this.tripEndDateTime,
    TripSummaryService? tripSummaryService,
    PhotoAlbumService? photoAlbumService,
  }) : _tripSummaryService = tripSummaryService ?? TripSummaryService(),
       _photoAlbumService = photoAlbumService ?? PhotoAlbumService() {
    selectedAlbumName = _selectedAlbumNameCache[tripId] ?? '';
    selectedAlbumId = _selectedAlbumIdCache[tripId];
  }

  final TripSummaryService _tripSummaryService;
  final PhotoAlbumService _photoAlbumService;
  final String tripId;
  final TripStatus tripStatus;
  final DateTime? tripStartDateTime;
  final DateTime? tripEndDateTime;

  final Geocoding _geocoding = Geocoding();

  static final Map<String, String> _selectedAlbumNameCache = {};

  static final Map<String, String> _selectedAlbumIdCache = {};

  static final Map<String, Set<String>> _uploadedAssetIdsCache = {};

  String selectedAlbumName = '';

  String? selectedAlbumId;

  List<TripPhotoItem> photos = [];
  List<TripPhotoGroup> photoGroups = [];

  bool isLoading = false;
  bool isSelectingAlbum = false;

  String? errorMessage;
  String? deletingPhotoId;

  bool _hasLoadedPhotos = false;

  final Set<String> _uploadedLocalAssetIds = {};

  bool isSelectionMode = false;

  PhotoSelectionAction? selectionAction;

  final Set<String> selectedPhotoIds = {};

  bool get hasSelectedPhotos => selectedPhotoIds.isNotEmpty;

  int get selectedPhotoCount => selectedPhotoIds.length;

  bool get areAllPhotosSelected =>
      photos.isNotEmpty && selectedPhotoIds.length == photos.length;

  Set<String> get _uploadedAssetIds {
    return _uploadedAssetIdsCache.putIfAbsent(tripId, () => <String>{});
  }

  String get selectionTitle {
    switch (selectionAction) {
      case PhotoSelectionAction.save:
        return 'Select photos to save';

      case PhotoSelectionAction.delete:
        return 'Select photos to delete';

      case null:
        return '';
    }
  }

  String get confirmButtonText {
    switch (selectionAction) {
      case PhotoSelectionAction.save:
        return 'Save';

      case PhotoSelectionAction.delete:
        return 'Delete';

      case null:
        return '';
    }
  }

  bool get isUpcoming => tripStatus == TripStatus.upcoming;

  bool get isActive => tripStatus == TripStatus.active;

  bool get isCompleted => tripStatus == TripStatus.completed;

  bool get canSelectAlbum {
    if (isUpcoming || isActive) {
      return true;
    }

    if (isCompleted) {
      if (!hasSelectedAlbum) {
        return false;
      }

      return !hasPhotos || errorMessage != null;
    }

    return false;
  }

  bool get hasSelectedAlbum =>
      selectedAlbumId != null &&
      selectedAlbumId!.isNotEmpty &&
      selectedAlbumName.trim().isNotEmpty;

  bool get hasPhotos => photos.isNotEmpty;

  bool get hasPhotoGroups => photoGroups.isNotEmpty;

  String get albumTitleText {
    if (hasSelectedAlbum) {
      return selectedAlbumName;
    }

    if (isCompleted) {
      return 'Album Selection Unavailable';
    }

    return 'Select Photo Album';
  }

  String get albumSubtitleText {
    if (isUpcoming || isActive) {
      if (hasSelectedAlbum) {
        return 'Change album';
      }

      return 'Please select photo album before your trip start';
    }
    if (isCompleted && !hasSelectedAlbum) {
      return 'No album was selected before this trip was completed';
    }

    if (isCompleted &&
        hasSelectedAlbum &&
        (!hasPhotos || errorMessage != null)) {
      return 'Change album';
    }

    return 'Album selection is unavailable after the trip is completed';
  }

  String get _albumIdKey => 'trip_${tripId}_selected_album_id';

  String get _albumNameKey => 'trip_${tripId}_selected_album_name';

  Future<void> _saveSelectedAlbum() async {
    final prefs = await SharedPreferences.getInstance();

    if (selectedAlbumId != null && selectedAlbumId!.isNotEmpty) {
      await prefs.setString(_albumIdKey, selectedAlbumId!);
    }

    if (selectedAlbumName.isNotEmpty) {
      await prefs.setString(_albumNameKey, selectedAlbumName);
    }

    debugPrint(
      'SAVED ALBUM TO PREFS: '
      '$selectedAlbumName ($selectedAlbumId)',
    );
  }

  Future<void> _loadSelectedAlbum() async {
    final prefs = await SharedPreferences.getInstance();

    selectedAlbumId = prefs.getString(_albumIdKey);
    selectedAlbumName = prefs.getString(_albumNameKey) ?? '';

    debugPrint(
      'RESTORED ALBUM: '
      '$selectedAlbumName ($selectedAlbumId)',
    );
  }

  Future<File?> _preparePhotoForUpload(File sourceFile) async {
    try {
      final tempDir = await getTemporaryDirectory();

      final targetPath =
          '${tempDir.path}/'
          'roamio_${DateTime.now().microsecondsSinceEpoch}.jpg';

      final compressedFile = await FlutterImageCompress.compressAndGetFile(
        sourceFile.absolute.path,
        targetPath,
        format: CompressFormat.jpeg,
        quality: 90,
        keepExif: true,
      );

      if (compressedFile == null) {
        debugPrint('IMAGE CONVERSION FAILED: ${sourceFile.path}');

        return null;
      }

      debugPrint('IMAGE READY FOR UPLOAD: ${compressedFile.path}');

      return File(compressedFile.path);
    } catch (error, stackTrace) {
      debugPrint('PREPARE PHOTO FOR UPLOAD ERROR: $error');

      debugPrintStack(stackTrace: stackTrace);

      return null;
    }
  }

  Future<String?> _getLocationNameFromCoordinates(
    double latitude,
    double longitude,
  ) async {
    try {
      final placemarks = await _geocoding.placemarkFromCoordinates(
        latitude,
        longitude,
      );

      if (placemarks.isEmpty) {
        return null;
      }

      final place = placemarks.first;

      if (place.name != null && place.name!.trim().isNotEmpty) {
        return place.name;
      }

      if (place.subLocality != null && place.subLocality!.trim().isNotEmpty) {
        return place.subLocality;
      }

      if (place.locality != null && place.locality!.trim().isNotEmpty) {
        return place.locality;
      }

      return null;
    } catch (error) {
      debugPrint('REVERSE GEOCODING ERROR: $error');

      return null;
    }
  }

  Future<void> loadPhotosFromSelectedAlbum() async {
    if (selectedAlbumId == null) {
      return;
    }

    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final assets = await _photoAlbumService.getPhotosFromAlbum(
        selectedAlbumId!,
      );

      debugPrint('========== LOAD LOCAL ALBUM PHOTOS ==========');
      debugPrint('Album: $selectedAlbumName');
      debugPrint('Album ID: $selectedAlbumId');
      debugPrint('All photos in album: ${assets.length}');
      debugPrint('Trip start: $tripStartDateTime');
      debugPrint('Trip end: $tripEndDateTime');
      debugPrint('Trip status: $tripStatus');

      final now = DateTime.now();
      final filteredAssets = assets.where((asset) {
        final capturedAt = asset.createDateTime.toLocal();

        if (tripStartDateTime == null) {
          return false;
        }

        final start = tripStartDateTime!.toLocal();

        if (isActive) {
          return !capturedAt.isBefore(start) && !capturedAt.isAfter(now);
        }

        if (isCompleted && tripEndDateTime != null) {
          final end = tripEndDateTime!.toLocal();

          return !capturedAt.isBefore(start) && !capturedAt.isAfter(end);
        }

        if (isUpcoming) {
          return false;
        }

        return false;
      }).toList();

      debugPrint('Photos inside trip period: ${filteredAssets.length}');

      final result = <TripPhotoItem>[];

      for (final asset in filteredAssets) {
        final file = await asset.file;

        if (file == null) {
          continue;
        }

        String? locationName;

        final latitude = asset.latitude;
        final longitude = asset.longitude;

        if (latitude != null &&
            longitude != null &&
            latitude != 0 &&
            longitude != 0) {
          locationName = await _getLocationNameFromCoordinates(
            latitude,
            longitude,
          );
        }

        result.add(
          TripPhotoItem(
            id: asset.id,
            localFile: file,
            capturedAt: asset.createDateTime.toLocal(),
            ownerUserId: '',
            ownerUsername: '',
            locationName: locationName,
            latitude: latitude,
            longitude: longitude,
          ),
        );
      }

      debugPrint('Local files loaded: ${result.length}');

      await _uploadTripPhotos(result);

      await loadTripPhotos(forceRefresh: true);

      debugPrint('============================================');
    } catch (error, stackTrace) {
      debugPrint('LOAD ALBUM PHOTOS ERROR: $error');

      debugPrintStack(stackTrace: stackTrace);

      _clearPhotos();

      errorMessage = 'Unable to load trip photos. Please try again.';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> initialize() async {
  debugPrint(
    '========== INITIALIZE PHOTO SECTION ==========',
  );

  debugPrint('Trip ID: $tripId');
  debugPrint('Status: $tripStatus');

  // โหลด album ที่เคยเลือก
  await _loadSelectedAlbum();

  debugPrint(
    'Saved album: '
    '$selectedAlbumName ($selectedAlbumId)',
  );

  await loadTripPhotos(
    forceRefresh: true,
  );

  if (isCompleted) {
    return;
  }

  if (isActive && hasSelectedAlbum) {
    debugPrint(
      'ACTIVE TRIP + SAVED ALBUM '
      '→ SYNC LOCAL PHOTOS',
    );

    await loadPhotosFromSelectedAlbum();

    return;
  }

  if (isUpcoming && hasSelectedAlbum) {
    debugPrint(
      'UPCOMING TRIP + SAVED ALBUM '
      '→ WAIT UNTIL ACTIVE',
    );

    return;
  }

  debugPrint('NO ALBUM SELECTED YET');
}

  // =========================================================
  // SELECT ALBUM
  // =========================================================

  Future<List<DevicePhotoAlbum>> loadAvailableAlbums() async {
    try {
      return await _photoAlbumService.getAlbums();
    } catch (error, stackTrace) {
      debugPrint('LOAD DEVICE ALBUMS ERROR: $error');

      debugPrintStack(stackTrace: stackTrace);

      rethrow;
    }
  }

  Future<void> selectAlbum(DevicePhotoAlbum album) async {
    if (!canSelectAlbum) {
      return;
    }

    if (isSelectingAlbum) {
      return;
    }

    isSelectingAlbum = true;
    errorMessage = null;
    notifyListeners();

    try {
      selectedAlbumId = album.id;
      selectedAlbumName = album.name;

      _selectedAlbumIdCache[tripId] = album.id;
      _selectedAlbumNameCache[tripId] = album.name;

      // ต้องมีบรรทัดนี้
      await _saveSelectedAlbum();

      debugPrint('SELECTED ALBUM: ${album.name} (${album.id})');

      await loadPhotosFromSelectedAlbum();
    } catch (error, stackTrace) {
      debugPrint('SELECT PHOTO ALBUM ERROR: $error');
      debugPrintStack(stackTrace: stackTrace);

      errorMessage = 'Unable to load trip photos. Please try again.';
    } finally {
      isSelectingAlbum = false;
      notifyListeners();
    }
  }

  // =========================================================
  // LOAD PHOTOS
  // =========================================================

  Future<void> loadTripPhotos({bool forceRefresh = false}) async {
    if (_hasLoadedPhotos && !forceRefresh) {
      debugPrint('LOAD PHOTOS SKIPPED: already loaded');
      return;
    }

    debugPrint('========== LOAD TRIP PHOTOS ==========');
    debugPrint('Trip ID: $tripId');
    debugPrint('Status: $tripStatus');
    debugPrint('Album: $selectedAlbumName');

    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final fetchedPhotos = await _tripSummaryService.getPhotos(tripId);

      photos = fetchedPhotos.map((photo) {
        return TripPhotoItem(
          id: photo.photoId,
          imageUrl: photo.photoUrl,

          capturedAt:
              photo.capturedAt?.toLocal() ??
              photo.uploadedAt?.toLocal() ??
              DateTime.now(),

          ownerUserId: photo.userId ?? '',
          ownerUsername: photo.userId ?? 'Unknown',

          ownerProfileImageUrl: null,

          locationName: photo.locationName,
          latitude: photo.latitude,
          longitude: photo.longitude,

          activityType: null,
        );
      }).toList();

      photos.sort((a, b) => a.capturedAt.compareTo(b.capturedAt));

      _groupPhotos();

      _hasLoadedPhotos = true;

      debugPrint('TRIP PHOTOS LOAD SUCCESS');
      debugPrint('Total photos: ${photos.length}');
    } on SocketException {
      _clearPhotos();
      errorMessage = 'Request failed. Please check your connection.';
    } catch (error, stackTrace) {
      debugPrint('LOAD TRIP PHOTOS ERROR: $error');
      debugPrintStack(stackTrace: stackTrace);

      _clearPhotos();

      final message = error.toString().toLowerCase();

      if (message.contains('socketexception') ||
          message.contains('connection refused') ||
          message.contains('failed host lookup') ||
          message.contains('network is unreachable') ||
          message.contains('timed out')) {
        errorMessage = 'Request failed. Please check your connection.';
      } else {
        errorMessage = 'Unable to load trip photos. Please try again.';
      }
    } finally {
      isLoading = false;
      notifyListeners();

      debugPrint('======================================');
    }
  }

  // =========================================================
  // PHOTO SELECTION
  // =========================================================

  void enterSelectionMode(PhotoSelectionAction action) {
    debugPrint('========== ENTER PHOTO SELECTION ==========');
    debugPrint('ACTION: $action');

    isSelectionMode = true;
    selectionAction = action;

    selectedPhotoIds.clear();

    notifyListeners();
  }

  void togglePhotoSelection(String photoId) {
    if (!isSelectionMode) {
      return;
    }

    if (selectedPhotoIds.contains(photoId)) {
      selectedPhotoIds.remove(photoId);

      debugPrint('UNSELECT PHOTO: $photoId');
    } else {
      selectedPhotoIds.add(photoId);

      debugPrint('SELECT PHOTO: $photoId');
    }

    debugPrint('SELECTED COUNT: ${selectedPhotoIds.length}');

    notifyListeners();
  }

  bool isPhotoSelected(String photoId) {
    return selectedPhotoIds.contains(photoId);
  }

  void toggleSelectAll() {
    if (!isSelectionMode) {
      return;
    }

    if (areAllPhotosSelected) {
      selectedPhotoIds.clear();

      debugPrint('UNSELECT ALL PHOTOS');
    } else {
      selectedPhotoIds
        ..clear()
        ..addAll(photos.map((photo) => photo.id));

      debugPrint('SELECT ALL PHOTOS: ${selectedPhotoIds.length}');
    }

    notifyListeners();
  }

  void cancelSelection() {
    debugPrint('CANCEL PHOTO SELECTION');

    isSelectionMode = false;
    selectionAction = null;
    selectedPhotoIds.clear();

    notifyListeners();
  }

  Future<bool> confirmSelection() async {
    if (!hasSelectedPhotos || selectionAction == null) {
      return false;
    }

    debugPrint('========== CONFIRM PHOTO SELECTION ==========');
    debugPrint('ACTION: $selectionAction');
    debugPrint('SELECTED PHOTOS: $selectedPhotoIds');

    switch (selectionAction!) {
      case PhotoSelectionAction.save:
        return _saveSelectedPhotos();

      case PhotoSelectionAction.delete:
        return _deleteSelectedPhotos();
    }
  }

  Future<void> _uploadTripPhotos(List<TripPhotoItem> localPhotos) async {
    debugPrint('========== UPLOAD TRIP PHOTOS ==========');

    for (final photo in localPhotos) {
      final sourceFile = photo.localFile;

      if (sourceFile == null) {
        continue;
      }

      if (_uploadedAssetIds.contains(photo.id)) {
        debugPrint('SKIP ALREADY UPLOADED: ${photo.id}');
        continue;
      }

      try {
        final uploadFile = await _preparePhotoForUpload(sourceFile);

        if (uploadFile == null) {
          continue;
        }

        debugPrint('UPLOAD PHOTO: ${photo.id}');

        await _tripSummaryService.uploadPhoto(
          tripId,
          uploadFile,
          capturedAt: photo.capturedAt,
          locationName: photo.locationName,
          latitude: photo.latitude,
          longitude: photo.longitude,
        );

        _uploadedAssetIds.add(photo.id);

        debugPrint('UPLOAD SUCCESS: ${photo.id}');

        if (await uploadFile.exists()) {
          await uploadFile.delete();
        }
      } catch (error, stackTrace) {
        debugPrint('UPLOAD ERROR (${photo.id}): $error');
        debugPrintStack(stackTrace: stackTrace);
      }
    }

    debugPrint('========================================');
  }

  Future<bool> _saveSelectedPhotos() async {
    try {
      final selectedPhotos = photos
          .where((photo) => selectedPhotoIds.contains(photo.id))
          .toList();

      if (selectedPhotos.isEmpty) {
        return false;
      }

      debugPrint('SAVING ${selectedPhotos.length} PHOTOS...');

      int savedCount = 0;

      for (final photo in selectedPhotos) {
        File? file = photo.localFile;

        // ถ้าไม่มี local file แต่มี URL จาก backend
        if (file == null &&
            photo.imageUrl != null &&
            photo.imageUrl!.trim().isNotEmpty) {
          try {
            final response = await http.get(Uri.parse(photo.imageUrl!));

            if (response.statusCode != 200) {
              debugPrint(
                'DOWNLOAD FAILED: ${photo.id} '
                'status=${response.statusCode}',
              );
              continue;
            }

            final tempDir = await getTemporaryDirectory();

            final tempFile = File(
              '${tempDir.path}/'
              'roamio_download_${photo.id}.jpg',
            );

            await tempFile.writeAsBytes(response.bodyBytes);

            file = tempFile;

            debugPrint('DOWNLOADED PHOTO: ${photo.id}');
          } catch (error) {
            debugPrint(
              'DOWNLOAD PHOTO ERROR '
              '(${photo.id}): $error',
            );
            continue;
          }
        }

        if (file == null) {
          debugPrint(
            'SKIP SAVE: ${photo.id} '
            'has no local file or image URL',
          );
          continue;
        }

        if (!await file.exists()) {
          debugPrint(
            'SKIP SAVE: '
            'file does not exist ${file.path}',
          );
          continue;
        }

        final extension = file.path.contains('.')
            ? file.path.split('.').last
            : 'jpg';

        final result = await PhotoManager.editor.saveImageWithPath(
          file.path,
          title:
              'roamio_'
              '${DateTime.now().millisecondsSinceEpoch}_'
              '$savedCount.$extension',
          creationDate: photo.capturedAt,
        );

        debugPrint('SAVE RESULT: ${result.id}');

        savedCount++;
      }

      debugPrint(
        'SAVE PHOTOS SUCCESS: '
        '$savedCount/${selectedPhotos.length}',
      );

      if (savedCount == 0) {
        errorMessage = 'Unable to save photos. Please try again.';
        notifyListeners();
        return false;
      }

      cancelSelection();

      return true;
    } catch (error, stackTrace) {
      debugPrint('SAVE PHOTOS ERROR: $error');

      debugPrintStack(stackTrace: stackTrace);

      errorMessage = 'Unable to save photos. Please try again.';

      notifyListeners();

      return false;
    }
  }

  Future<bool> _deleteSelectedPhotos() async {
    final idsToDelete = List<String>.from(selectedPhotoIds);

    debugPrint('========== DELETE TRIP PHOTOS ==========');
    debugPrint('Trip ID: $tripId');
    debugPrint('Photo IDs: $idsToDelete');

    errorMessage = null;
    notifyListeners();

    final failedIds = <String>[];

    for (final photoId in idsToDelete) {
      deletingPhotoId = photoId;
      notifyListeners();

      try {
        debugPrint(
          'DELETE REQUEST: '
          'tripId=$tripId, photoId=$photoId',
        );

        await _tripSummaryService.deletePhoto(tripId, photoId);

        debugPrint('DELETE BACKEND SUCCESS: $photoId');

        photos = photos.where((photo) => photo.id != photoId).toList();

        debugPrint('DELETED FROM UI: $photoId');
      } catch (error, stackTrace) {
        debugPrint('DELETE PHOTO ERROR ($photoId): $error');

        debugPrintStack(stackTrace: stackTrace);

        failedIds.add(photoId);
      }
    }

    _groupPhotos();
    deletingPhotoId = null;

    if (failedIds.isNotEmpty) {
      errorMessage = failedIds.length == idsToDelete.length
          ? 'Unable to delete photos. Please try again.'
          : '${failedIds.length} of ${idsToDelete.length} photos could not be deleted.';

      selectedPhotoIds
        ..clear()
        ..addAll(failedIds);

      notifyListeners();

      debugPrint('DELETE PHOTOS PARTIAL/FAILED: $failedIds');
      debugPrint('========================================');

      return false;
    }

    debugPrint('DELETE PHOTOS SUCCESS');
    await loadTripPhotos(forceRefresh: true);
    debugPrint('Remaining photos: ${photos.length}');
    debugPrint('========================================');

    cancelSelection();

    return true;
  }

  // =========================================================
  // GROUP PHOTOS
  // =========================================================

  void _groupPhotos() {
    final grouped = <String, List<TripPhotoItem>>{};

    for (final photo in photos) {
      final location = photo.locationName?.trim().isNotEmpty == true
          ? photo.locationName!.trim()
          : 'Unknown location';

      final dateKey =
          '${photo.capturedAt.year}-'
          '${photo.capturedAt.month}-'
          '${photo.capturedAt.day}';

      final key = '$dateKey|$location';

      grouped.putIfAbsent(key, () => []);

      grouped[key]!.add(photo);
    }

    final result = <TripPhotoGroup>[];

    String? previousDate;

    for (final entry in grouped.entries) {
      final firstPhoto = entry.value.first;

      final dateText = _formatDate(firstPhoto.capturedAt);

      final location = firstPhoto.locationName?.trim().isNotEmpty == true
          ? firstPhoto.locationName!.trim()
          : 'Unknown location';

      final showDate = previousDate != dateText;

      result.add(
        TripPhotoGroup(
          dateText: dateText,
          locationName: location,
          showDate: showDate,
          photos: entry.value,
        ),
      );

      previousDate = dateText;
    }

    photoGroups = result;
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return '${date.day} '
        '${months[date.month - 1]} '
        '${date.year}';
  }

  void _clearPhotos() {
    photos = [];
    photoGroups = [];
    _hasLoadedPhotos = false;
  }

  Future<void> retry() async {
    errorMessage = null;
    notifyListeners();

    if ((isUpcoming || isActive) && hasSelectedAlbum) {
      await loadPhotosFromSelectedAlbum();
      return;
    }

    await loadTripPhotos(forceRefresh: true);
  }
}
