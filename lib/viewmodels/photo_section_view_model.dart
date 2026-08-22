import 'dart:io';

import 'package:flutter/material.dart';
import 'package:roamio_frontend/viewmodels/trip_detail_view_model.dart';

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

class PhotoSectionViewModel extends ChangeNotifier {
  PhotoSectionViewModel({required this.tripId, required this.tripStatus}) {
    // restore album ที่เคยเลือกไว้ใน session นี้
    selectedAlbumName = _selectedAlbumCache[tripId] ?? '';
  }

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

  bool get isUpcoming => tripStatus == TripStatus.upcoming;

  bool get isActive => tripStatus == TripStatus.active;

  bool get isCompleted => tripStatus == TripStatus.completed;

  bool get canSelectAlbum => isUpcoming || isActive;

  bool get hasSelectedAlbum => selectedAlbumName.trim().isNotEmpty;

  bool get hasPhotos => photos.isNotEmpty;

  bool get hasPhotoGroups => photoGroups.isNotEmpty;

  String get selectAlbumText {
    if (hasSelectedAlbum) {
      return selectedAlbumName;
    }

    if (isCompleted) {
      return 'Album selection is unavailable after the trip is completed';
    }

    return 'Please select photo album before your trip start';
  }

  // =========================================================
  // INITIAL LOAD
  // =========================================================

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
      await Future<void>.delayed(const Duration(milliseconds: 400));

      // =====================================
      // TEMP MOCK
      //
      // 1 วัน = 5 รูป
      // มีรูปจากหลาย account
      // =====================================

      photos = [
        // =========================
        // DAY 1 — 5 PHOTOS
        // =========================
        TripPhotoItem(
          id: 'photo_1',
          imageUrl: 'https://picsum.photos/id/1015/600/600',
          capturedAt: DateTime(2026, 7, 17, 8, 30),
          ownerUserId: '1',
          ownerUsername: 'Jig',
          ownerProfileImageUrl: null,
          locationName: 'Chiang Mai University',
          activityType: 'Sightseeing',
        ),

        TripPhotoItem(
          id: 'photo_2',
          imageUrl: 'https://picsum.photos/id/1016/600/600',
          capturedAt: DateTime(2026, 7, 17, 9, 45),
          ownerUserId: '2',
          ownerUsername: 'Sabrina',
          ownerProfileImageUrl: null,
          locationName: 'Chiang Mai University',
          activityType: 'Sightseeing',
        ),

        TripPhotoItem(
          id: 'photo_3',
          imageUrl: 'https://picsum.photos/id/1080/600/600',
          capturedAt: DateTime(2026, 7, 17, 12, 20),
          ownerUserId: '3',
          ownerUsername: 'Cherry',
          ownerProfileImageUrl: null,
          locationName: 'One Nimman',
          activityType: 'Food',
        ),

        TripPhotoItem(
          id: 'photo_4',
          imageUrl: 'https://picsum.photos/id/1025/600/600',
          capturedAt: DateTime(2026, 7, 17, 15, 10),
          ownerUserId: '4',
          ownerUsername: 'Pang',
          ownerProfileImageUrl: null,
          locationName: 'Tha Phae Gate',
          activityType: 'Sightseeing',
        ),

        TripPhotoItem(
          id: 'photo_5',
          imageUrl: 'https://picsum.photos/id/1035/600/600',
          capturedAt: DateTime(2026, 7, 17, 18, 30),
          ownerUserId: '2',
          ownerUsername: 'Sabrina',
          ownerProfileImageUrl: null,
          locationName: 'Warorot Market',
          activityType: 'Food',
        ),

        // =========================
        // DAY 2 — 5 PHOTOS
        // =========================
        TripPhotoItem(
          id: 'photo_6',
          imageUrl: 'https://picsum.photos/id/1043/600/600',
          capturedAt: DateTime(2026, 7, 18, 8, 15),
          ownerUserId: '3',
          ownerUsername: 'Cherry',
          ownerProfileImageUrl: null,
          locationName: 'Doi Suthep',
          activityType: 'Sightseeing',
        ),

        TripPhotoItem(
          id: 'photo_7',
          imageUrl: 'https://picsum.photos/id/1040/600/600',
          capturedAt: DateTime(2026, 7, 18, 9, 40),
          ownerUserId: '1',
          ownerUsername: 'Jig',
          ownerProfileImageUrl: null,
          locationName: 'Doi Suthep',
          activityType: 'Sightseeing',
        ),

        TripPhotoItem(
          id: 'photo_8',
          imageUrl: 'https://picsum.photos/id/1050/600/600',
          capturedAt: DateTime(2026, 7, 18, 12, 10),
          ownerUserId: '4',
          ownerUsername: 'Pang',
          ownerProfileImageUrl: null,
          locationName: 'Nimman',
          activityType: 'Food',
        ),

        TripPhotoItem(
          id: 'photo_9',
          imageUrl: 'https://picsum.photos/id/1060/600/600',
          capturedAt: DateTime(2026, 7, 18, 14, 45),
          ownerUserId: '2',
          ownerUsername: 'Sabrina',
          ownerProfileImageUrl: null,
          locationName: 'Nimman',
          activityType: 'Transit',
        ),

        TripPhotoItem(
          id: 'photo_10',
          imageUrl: 'https://picsum.photos/id/1074/600/600',
          capturedAt: DateTime(2026, 7, 18, 17, 20),
          ownerUserId: '1',
          ownerUsername: 'Jig',
          ownerProfileImageUrl: null,
          locationName: 'Chiang Mai Old City',
          activityType: 'Sightseeing',
        ),
      ];

      photos.sort((a, b) => a.capturedAt.compareTo(b.capturedAt));

      _groupPhotos();

      _hasLoadedPhotos = true;

      debugPrint('TRIP PHOTOS LOAD SUCCESS');

      debugPrint('Total photos: ${photos.length}');

      for (final group in photoGroups) {
        debugPrint(
          'PHOTO GROUP: '
          '${group.photos.length} photos',
        );
      }

      for (final photo in photos) {
        debugPrint(
          'PHOTO ${photo.id}: '
          'owner=${photo.ownerUsername}, '
          'time=${photo.capturedAt}, '
          'location=${photo.locationName}',
        );
      }
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
