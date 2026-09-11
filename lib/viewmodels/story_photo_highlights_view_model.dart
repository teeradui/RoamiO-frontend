import 'dart:math';

import 'package:flutter/material.dart';
import 'package:roamio_frontend/models/services/trip_summary_service.dart';

class StoryHighlightPhoto {
  const StoryHighlightPhoto({
    required this.id,
    required this.imageUrl,
    required this.locationName,
    required this.capturedAt,
    required this.ownerUsername,
  });

  final String id;
  final String imageUrl;
  final String locationName;
  final DateTime capturedAt;
  final String ownerUsername;
}

class StoryHighlightLocation {
  const StoryHighlightLocation({
    required this.rank,
    required this.locationName,
    required this.photoCount,
    required this.highlightPhotos,
    required this.subtitle,
  });

  final int rank;
  final String locationName;
  final int photoCount;
  final List<StoryHighlightPhoto> highlightPhotos;
  final String subtitle;
}

class StoryPhotoHighlightsViewModel extends ChangeNotifier {
  StoryPhotoHighlightsViewModel({
    required this.tripId,
    TripSummaryService? tripSummaryService,
  }) : _tripSummaryService = tripSummaryService ?? TripSummaryService();

  final String tripId;
  final TripSummaryService _tripSummaryService;

  static final Map<String, Map<int, String>> _subtitleCache = {};

  bool isLoading = false;
  String? errorMessage;

  List<StoryHighlightPhoto> photos = [];
  List<StoryHighlightLocation> topLocations = [];

  int get totalPhotos => photos.length;

  bool get hasHighlights => topLocations.isNotEmpty;

  bool isLocationRankingWip = false;

  List<StoryHighlightPhoto> _getHighlightPhotos({
    required int rank,
    required String locationName,
    required List<StoryHighlightPhoto> locationPhotos,
  }) {
    if (locationPhotos.isEmpty) {
      return [];
    }
    final shuffled = List<StoryHighlightPhoto>.from(locationPhotos);

    final seed = _stableHash('$tripId-photo-slideshow-$rank-$locationName');

    final random = Random(seed);

    shuffled.shuffle(random);

    return shuffled.take(5).toList();
  }

  final Map<int, List<String>> _rankingSubtitles = {
    1: [
      'Your camera was obsessed!',
      'Main character of the camera roll!',
      'Clearly the trip’s photo MVP!',
      'You really said: one more photo!',
      'The camera simply couldn’t move on.',
    ],

    2: [
      'Almost stole the whole show!',
      'Your camera definitely had a crush!',
      'So close to camera roll royalty!',
      'Low-key one of the trip’s stars!',
      'You kept coming back for another shot!',
    ],

    3: [
      'Still made the iconic list!',
      'Podium secured. Memories secured.',
      'A little camera roll celebrity!',
      'Third place, first-class memories!',
      'Too memorable to leave out!',
    ],
  };

  int _stableHash(String value) {
    var hash = 0x811C9DC5;

    for (final codeUnit in value.codeUnits) {
      hash ^= codeUnit;
      hash = (hash * 0x01000193) & 0x7FFFFFFF;
    }

    return hash;
  }

  String _getRankingSubtitle({
    required int rank,
    required String locationName,
  }) {
    final tripCache = _subtitleCache.putIfAbsent(tripId, () => {});

    final cached = tripCache[rank];

    if (cached != null) {
      return cached;
    }

    final options = _rankingSubtitles[rank]!;

    final seed = _stableHash('$tripId-rank-$rank-$locationName');

    final random = Random(seed);

    final selected = options[random.nextInt(options.length)];

    tripCache[rank] = selected;

    return selected;
  }

  Future<void> loadPhotoHighlights() async {
    debugPrint('========== LOAD STORY PHOTO HIGHLIGHTS ==========');
    debugPrint('Trip ID: $tripId');

    isLoading = true;
    errorMessage = null;
    notifyListeners();

        try {
      final fetchedPhotos = await _tripSummaryService.getPhotos(tripId);

      // WIP (need to implement): backend does not yet return a location
      // for each photo (no join to activities/stops). All photos are
      // grouped under one placeholder location until that exists.
      photos = fetchedPhotos
          .map(
            (photo) => StoryHighlightPhoto(
              id: photo.photoId,
              imageUrl: photo.photoUrl,
              locationName: 'WIP (need to implement)',
              capturedAt: photo.uploadedAt ?? DateTime.now(),
              ownerUsername: photo.userId ?? 'WIP (need to implement)',
            ),
          )
          .toList();

      _buildTopLocations();
      isLocationRankingWip = true;

      debugPrint('PHOTO HIGHLIGHTS LOAD SUCCESS (location ranking WIP)');
      debugPrint('Total photos: $totalPhotos');

      for (final location in topLocations) {
        debugPrint(
          'TOP ${location.rank}: '
          '${location.locationName} '
          '(${location.photoCount} photos) '
          'highlight=${location.highlightPhotos.length}',
        );
      }
    } catch (error, stackTrace) {
      debugPrint('LOAD PHOTO HIGHLIGHTS ERROR: $error');

      debugPrintStack(stackTrace: stackTrace);

      photos = [];
      topLocations = [];
      isLocationRankingWip = false;

      final message = error.toString().toLowerCase();

      if (message.contains('socketexception') ||
          message.contains('connection refused') ||
          message.contains('network is unreachable') ||
          message.contains('failed host lookup') ||
          message.contains('timed out')) {
        errorMessage = 'Request failed. Please check your connection.';
      } else {
        errorMessage = 'Unable to load photo highlights.';
      }
    } finally {
      isLoading = false;

      debugPrint('===============================================');

      notifyListeners();
    }
  }

  // void _loadMockPhotos() {
  //   photos = [
  //     StoryHighlightPhoto(
  //       id: 'photo_1',
  //       imageUrl: 'https://picsum.photos/id/1015/900/1200',
  //       locationName: 'Chiang Mai University',
  //       capturedAt: DateTime(2026, 7, 17, 8, 30),
  //       ownerUsername: 'Jig',
  //     ),
  //     StoryHighlightPhoto(
  //       id: 'photo_2',
  //       imageUrl: 'https://picsum.photos/id/1016/900/1200',
  //       locationName: 'Chiang Mai University',
  //       capturedAt: DateTime(2026, 7, 17, 8, 45),
  //       ownerUsername: 'Sabrina',
  //     ),
  //     StoryHighlightPhoto(
  //       id: 'photo_3',
  //       imageUrl: 'https://picsum.photos/id/1020/900/1200',
  //       locationName: 'Chiang Mai University',
  //       capturedAt: DateTime(2026, 7, 17, 9, 10),
  //       ownerUsername: 'Cherry',
  //     ),
  //     StoryHighlightPhoto(
  //       id: 'photo_4',
  //       imageUrl: 'https://picsum.photos/id/1024/900/1200',
  //       locationName: 'Chiang Mai University',
  //       capturedAt: DateTime(2026, 7, 17, 9, 20),
  //       ownerUsername: 'Pang',
  //     ),
  //     StoryHighlightPhoto(
  //       id: 'photo_5',
  //       imageUrl: 'https://picsum.photos/id/1031/900/1200',
  //       locationName: 'Chiang Mai University',
  //       capturedAt: DateTime(2026, 7, 17, 9, 35),
  //       ownerUsername: 'Jig',
  //     ),
  //     StoryHighlightPhoto(
  //       id: 'photo_6',
  //       imageUrl: 'https://picsum.photos/id/1033/900/1200',
  //       locationName: 'Chiang Mai University',
  //       capturedAt: DateTime(2026, 7, 17, 9, 50),
  //       ownerUsername: 'Sabrina',
  //     ),

  //     StoryHighlightPhoto(
  //       id: 'photo_7',
  //       imageUrl: 'https://picsum.photos/id/1035/900/1200',
  //       locationName: 'One Nimman',
  //       capturedAt: DateTime(2026, 7, 17, 12, 10),
  //       ownerUsername: 'Cherry',
  //     ),
  //     StoryHighlightPhoto(
  //       id: 'photo_8',
  //       imageUrl: 'https://picsum.photos/id/1036/900/1200',
  //       locationName: 'One Nimman',
  //       capturedAt: DateTime(2026, 7, 17, 12, 20),
  //       ownerUsername: 'Jig',
  //     ),
  //     StoryHighlightPhoto(
  //       id: 'photo_9',
  //       imageUrl: 'https://picsum.photos/id/1037/900/1200',
  //       locationName: 'One Nimman',
  //       capturedAt: DateTime(2026, 7, 17, 12, 30),
  //       ownerUsername: 'Pang',
  //     ),
  //     StoryHighlightPhoto(
  //       id: 'photo_10',
  //       imageUrl: 'https://picsum.photos/id/1038/900/1200',
  //       locationName: 'One Nimman',
  //       capturedAt: DateTime(2026, 7, 17, 12, 40),
  //       ownerUsername: 'Sabrina',
  //     ),
  //     StoryHighlightPhoto(
  //       id: 'photo_11',
  //       imageUrl: 'https://picsum.photos/id/1039/900/1200',
  //       locationName: 'One Nimman',
  //       capturedAt: DateTime(2026, 7, 17, 12, 55),
  //       ownerUsername: 'Cherry',
  //     ),

  //     StoryHighlightPhoto(
  //       id: 'photo_12',
  //       imageUrl: 'https://picsum.photos/id/1040/900/1200',
  //       locationName: 'Tha Phae Gate',
  //       capturedAt: DateTime(2026, 7, 17, 15, 10),
  //       ownerUsername: 'Jig',
  //     ),
  //     StoryHighlightPhoto(
  //       id: 'photo_13',
  //       imageUrl: 'https://picsum.photos/id/1041/900/1200',
  //       locationName: 'Tha Phae Gate',
  //       capturedAt: DateTime(2026, 7, 17, 15, 20),
  //       ownerUsername: 'Sabrina',
  //     ),
  //     StoryHighlightPhoto(
  //       id: 'photo_14',
  //       imageUrl: 'https://picsum.photos/id/1042/900/1200',
  //       locationName: 'Tha Phae Gate',
  //       capturedAt: DateTime(2026, 7, 17, 15, 30),
  //       ownerUsername: 'Pang',
  //     ),
  //     StoryHighlightPhoto(
  //       id: 'photo_15',
  //       imageUrl: 'https://picsum.photos/id/1043/900/1200',
  //       locationName: 'Tha Phae Gate',
  //       capturedAt: DateTime(2026, 7, 17, 15, 45),
  //       ownerUsername: 'Cherry',
  //     ),

  //     StoryHighlightPhoto(
  //       id: 'photo_16',
  //       imageUrl: 'https://picsum.photos/id/1044/900/1200',
  //       locationName: 'Warorot Market',
  //       capturedAt: DateTime(2026, 7, 17, 18, 10),
  //       ownerUsername: 'Jig',
  //     ),
  //     StoryHighlightPhoto(
  //       id: 'photo_17',
  //       imageUrl: 'https://picsum.photos/id/1045/900/1200',
  //       locationName: 'Warorot Market',
  //       capturedAt: DateTime(2026, 7, 17, 18, 20),
  //       ownerUsername: 'Sabrina',
  //     ),
  //   ];
  // }

  void _buildTopLocations() {
    final grouped = <String, List<StoryHighlightPhoto>>{};

    for (final photo in photos) {
      grouped.putIfAbsent(photo.locationName, () => []);

      grouped[photo.locationName]!.add(photo);
    }

    final sortedLocations = grouped.entries.toList()
      ..sort((a, b) => b.value.length.compareTo(a.value.length));

    final topThree = sortedLocations.take(3).toList();

    topLocations = topThree.asMap().entries.map((entry) {
      final index = entry.key;
      final rank = index + 1;

      final location = entry.value;
      final locationPhotos = location.value;

      final highlightPhotos = _getHighlightPhotos(
        rank: rank,
        locationName: location.key,
        locationPhotos: locationPhotos,
      );
      final subtitle = _getRankingSubtitle(
        rank: rank,
        locationName: location.key,
      );

      return StoryHighlightLocation(
        rank: rank,
        locationName: location.key,
        photoCount: locationPhotos.length,
        highlightPhotos: highlightPhotos,
        subtitle: subtitle,
      );
    }).toList();
  }
}
