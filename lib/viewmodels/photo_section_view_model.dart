import 'dart:io';

import 'package:flutter/material.dart';
import 'package:roamio_frontend/viewmodels/trip_detail_view_model.dart';
import 'package:roamio_frontend/models/services/trip_summary_service.dart';

class TripPhotoItem {
  const TripPhotoItem({
    required this.id,
    required this.imageUrl,
    required this.capturedAt,
    required this.ownerUserId,
    required this.ownerUsername,
    this.ownerProfileImageUrl,
    this.locationName,
    this.activityType,
  });

  final String id;
  final String imageUrl;
  final DateTime capturedAt;

  final String ownerUserId;
  final String ownerUsername;
  final String? ownerProfileImageUrl;

  final String? locationName;
  final String? activityType;
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
    TripSummaryService? tripSummaryService,
  }) : _tripSummaryService = tripSummaryService ?? TripSummaryService() {
    selectedAlbumName = _selectedAlbumCache[tripId] ?? '';
  }

  final TripSummaryService _tripSummaryService;

  final String tripId;
  final TripStatus tripStatus;

  // =========================================================
  // TEMP SESSION CACHE
  //
  // ป้องกันเลือก album แล้วพอสลับ section กลับมาต้องเลือกใหม่
  //
  // TODO:
  // backend จริงควรเก็บ selected album ของ trip
  // =========================================================

  static final Map<String, String> _selectedAlbumCache = {};

  String selectedAlbumName = '';

  List<TripPhotoItem> photos = [];
  List<TripPhotoGroup> photoGroups = [];

  bool isLoading = false;
  bool isSelectingAlbum = false;

  String? errorMessage;

  bool _hasLoadedPhotos = false;

  // =========================================================
  // PHOTO SELECTION
  // =========================================================

  bool isSelectionMode = false;

  PhotoSelectionAction? selectionAction;

  final Set<String> selectedPhotoIds = {};

  bool get hasSelectedPhotos => selectedPhotoIds.isNotEmpty;

  int get selectedPhotoCount => selectedPhotoIds.length;

  bool get areAllPhotosSelected =>
      photos.isNotEmpty && selectedPhotoIds.length == photos.length;

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

  bool get hasSelectedAlbum => selectedAlbumName.trim().isNotEmpty;

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

  Future<void> initialize() async {
    debugPrint('========== INITIALIZE PHOTO SECTION ==========');
    debugPrint('Trip ID: $tripId');
    debugPrint('Status: $tripStatus');
    debugPrint('Cached album: ${_selectedAlbumCache[tripId]}');

    // Completed:
    // ไม่ต้องเลือก album แล้ว โหลด summarized trip photos เลย
    if (isCompleted) {
      await loadTripPhotos();
      return;
    }

    // Upcoming / Active:
    // ถ้าเคยเลือก album แล้ว ให้โหลดรูปต่อทันที
    if (hasSelectedAlbum) {
      debugPrint('ALBUM ALREADY SELECTED → LOAD PHOTOS');

      await loadTripPhotos();
      return;
    }

    debugPrint('NO ALBUM SELECTED YET');
  }

  // =========================================================
  // SELECT ALBUM
  // =========================================================

  Future<void> selectAlbum() async {
    if (!canSelectAlbum) {
      debugPrint(
        'SELECT ALBUM BLOCKED: '
        'trip status = $tripStatus',
      );
      return;
    }

    if (isSelectingAlbum) {
      return;
    }

    debugPrint('========== SELECT PHOTO ALBUM ==========');
    debugPrint('Trip ID: $tripId');

    isSelectingAlbum = true;
    errorMessage = null;
    notifyListeners();

    try {
      /*
       * TEMP MOCK
       *
       * TODO:
       * เปลี่ยนเป็น native album picker
       */

      await Future<void>.delayed(const Duration(milliseconds: 300));

      selectedAlbumName = 'My Trip Album';

      // จำไว้ตาม trip
      _selectedAlbumCache[tripId] = selectedAlbumName;

      debugPrint('SELECTED ALBUM: $selectedAlbumName');

      debugPrint(
        'SAVED ALBUM CACHE: '
        '${_selectedAlbumCache[tripId]}',
      );

      await loadTripPhotos(forceRefresh: true);
    } catch (error, stackTrace) {
      debugPrint('SELECT PHOTO ALBUM ERROR: $error');

      debugPrintStack(stackTrace: stackTrace);

      errorMessage = 'Unable to load trip photos. Please try again.';
    } finally {
      isSelectingAlbum = false;
      notifyListeners();

      debugPrint('========================================');
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

    if (!isCompleted && !hasSelectedAlbum) {
      debugPrint(
        'LOAD PHOTOS SKIPPED: '
        'no album selected',
      );

      _clearPhotos();
      notifyListeners();
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
          capturedAt: photo.uploadedAt ?? DateTime.now(),
          ownerUserId: photo.userId ?? '',
          ownerUsername: photo.userId ?? 'Unknown',
          ownerProfileImageUrl: null,
          locationName: null,
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

  Future<bool> _saveSelectedPhotos() async {
    try {
      /*
     * TEMP MOCK
     *
     * TODO:
     * download/save selected photos
     * to device gallery
     */

      debugPrint('SAVING ${selectedPhotoIds.length} PHOTOS...');

      await Future<void>.delayed(const Duration(milliseconds: 500));

      debugPrint('SAVE PHOTOS SUCCESS');

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
    try {
      /*
     * TEMP MOCK
     *
     * TODO:
     * delete selected photos through backend
     */

      debugPrint('DELETING ${selectedPhotoIds.length} PHOTOS...');

      await Future<void>.delayed(const Duration(milliseconds: 500));

      photos.removeWhere((photo) => selectedPhotoIds.contains(photo.id));

      _groupPhotos();

      debugPrint('DELETE PHOTOS SUCCESS');
      debugPrint('REMAINING PHOTOS: ${photos.length}');

      cancelSelection();

      return true;
    } catch (error, stackTrace) {
      debugPrint('DELETE PHOTOS ERROR: $error');
      debugPrintStack(stackTrace: stackTrace);

      errorMessage = 'Unable to delete photos. Please try again.';

      notifyListeners();

      return false;
    }
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

    await loadTripPhotos(forceRefresh: true);
  }
}
