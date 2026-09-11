import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:roamio_frontend/theme/colors.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:roamio_frontend/models/services/location_service.dart';
import 'package:roamio_frontend/models/services/trip_summary_service.dart';

class StoryRoadmapStop {
  final String id;
  final String name;
  final String type;
  final LatLng location;

  const StoryRoadmapStop({
    required this.id,
    required this.name,
    required this.type,
    required this.location,
  });
}

class StoryTripRoadmapViewModel extends ChangeNotifier {
  StoryTripRoadmapViewModel({
    required this.tripId,
    TripSummaryService? tripSummaryService,
  }) : _tripSummaryService = tripSummaryService ?? TripSummaryService();

  final String tripId;
  final TripSummaryService _tripSummaryService;
  final PolylinePoints _polylinePoints = PolylinePoints(
    apiKey: LocationService.googleApiKey,
  );

  bool isLoading = false;
  bool isAnimating = false;

  String? errorMessage;

  List<StoryRoadmapStop> stops = [];
  List<LatLng> routePoints = [];

  LatLng? carPosition;
  List<LatLng> visibleRoutePoints = [];

  bool hasJourneyStarted = false;

  int currentStopIndex = -1;

  bool get hasRoute {
    return routePoints.length >= 2 && stops.isNotEmpty;
  }

  bool get isAtLastStop {
    return hasJourneyStarted &&
        stops.isNotEmpty &&
        currentStopIndex >= stops.length - 1;
  }

  StoryRoadmapStop? get currentStop {
    if (!hasJourneyStarted || stops.isEmpty || currentStopIndex < 0) {
      return null;
    }

    final safeIndex = currentStopIndex.clamp(0, stops.length - 1);

    return stops[safeIndex];
  }

  Future<List<LatLng>> _fetchRouteBetweenStops({
  required LatLng origin,
  required LatLng destination,
}) async {
  try {
    final response =
        await _polylinePoints.getRouteBetweenCoordinatesV2(
      request: RoutesApiRequest(
        origin: PointLatLng(
          origin.latitude,
          origin.longitude,
        ),
        destination: PointLatLng(
          destination.latitude,
          destination.longitude,
        ),
        travelMode: TravelMode.driving,
        polylineQuality: PolylineQuality.highQuality,
      ),
    );

    if (response.routes.isEmpty) {
      debugPrint(
        'GOOGLE ROUTE ERROR: ${response.errorMessage}',
      );

      return [];
    }

    final points =
        response.routes.first.polylinePoints;

    if (points == null || points.isEmpty) {
      return [];
    }

    return points.map((point) {
      return LatLng(
        point.latitude,
        point.longitude,
      );
    }).toList();
  } catch (error, stackTrace) {
    debugPrint(
      'FETCH GOOGLE ROUTE ERROR: $error',
    );

    debugPrintStack(
      stackTrace: stackTrace,
    );

    return [];
  }
}

Future<void> _loadGoogleRoute() async {
  routePoints = [];

  if (stops.length < 2) {
    return;
  }

  for (var i = 0; i < stops.length - 1; i++) {
    final segment =
        await _fetchRouteBetweenStops(
      origin: stops[i].location,
      destination:
          stops[i + 1].location,
    );

    if (segment.isEmpty) {
      debugPrint(
        'NO ROUTE: '
        '${stops[i].name} → '
        '${stops[i + 1].name}',
      );

      continue;
    }

    if (routePoints.isNotEmpty &&
        segment.isNotEmpty) {
      segment.removeAt(0);
    }

    routePoints.addAll(segment);
  }

  debugPrint(
    'GOOGLE ROUTE POINTS: '
    '${routePoints.length}',
  );
}

  Future<void> startJourney() async {
    if (hasJourneyStarted || stops.isEmpty) {
      return;
    }

    debugPrint('========== START ROADMAP JOURNEY ==========');

    hasJourneyStarted = true;
    currentStopIndex = 0;

    carPosition = stops.first.location;

    visibleRoutePoints = [stops.first.location];

    notifyListeners();

    debugPrint('CAR APPEARED AT: ${stops.first.name}');

    debugPrint('==========================================');
  }

    Future<void> loadRoadmap() async {
    debugPrint('========== LOAD STORY TRIP ROADMAP ==========');
    debugPrint('Trip ID: $tripId');

    isLoading = true;
    errorMessage = null;

    try {
      final summary = await _tripSummaryService.getSummary(tripId);

      final validStops = summary.stops
          .where((s) => s.latitude != null && s.longitude != null)
          .toList();

      stops = validStops
          .map(
            (s) => StoryRoadmapStop(
              id: s.stopId,
              name: s.locationName ?? 'WIP (need to implement)',
              type: s.locationType ?? 'WIP (need to implement)',
              location: LatLng(s.latitude!, s.longitude!),
            ),
          )
          .toList();

      await _loadGoogleRoute();

      hasJourneyStarted = false;
      currentStopIndex = -1;
      carPosition = null;
      visibleRoutePoints = [];

      debugPrint('ROADMAP LOAD SUCCESS');
      debugPrint('Stops: ${stops.length}');
      debugPrint('Route points: ${routePoints.length}');
      debugPrint('Car position: $carPosition');

      for (var i = 0; i < stops.length; i++) {
        debugPrint(
          'STOP ${i + 1}: '
          '${stops[i].name} | '
          '${stops[i].type} | '
          '${stops[i].location}',
        );
      }
    } catch (error, stackTrace) {
      debugPrint('LOAD STORY ROADMAP ERROR: $error');

      debugPrintStack(stackTrace: stackTrace);

      stops = [];
      routePoints = [];
      carPosition = null;
      currentStopIndex = 0;

      final message = error.toString().toLowerCase();
      if (message.contains('socketexception') ||
          message.contains('connection refused') ||
          message.contains('network is unreachable') ||
          message.contains('failed host lookup') ||
          message.contains('timed out')) {
        errorMessage = 'Request failed. Please check your connection.';
      } else {
        errorMessage = 'Unable to load trip roadmap.';
      }
    } finally {
      isLoading = false;

      debugPrint('=============================================');

      notifyListeners();
    }
  }

  LatLng get initialCameraTarget {
    if (stops.isNotEmpty) {
      return stops.first.location;
    }

    return const LatLng(18.7883, 98.9853);
  }

  Set<Marker> get stopMarkers {
    if (!hasJourneyStarted || currentStopIndex < 0) {
      return {};
    }

    return stops
        .asMap()
        .entries
        .where((entry) => entry.key <= currentStopIndex)
        .map((entry) {
          final index = entry.key;
          final stop = entry.value;

          return Marker(
            markerId: MarkerId(stop.id),
            position: stop.location,
            infoWindow: InfoWindow(
              title: '${index + 1}. ${stop.name}',
              snippet: stop.type,
            ),
            icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueRed,
            ),
          );
        })
        .toSet();
  }

  Set<Marker> get mapMarkers {
    if (!hasJourneyStarted) {
      return {};
    }

    return stopMarkers;
  }

  Set<Polyline> get routePolylines {
    if (!hasJourneyStarted || visibleRoutePoints.length < 2) {
      return {};
    }

    return {
      Polyline(
        polylineId: const PolylineId('story_trip_route'),
        points: visibleRoutePoints,
        width: 5,
        color: AppColors.btnPrimary,
        geodesic: true,
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
        jointType: JointType.round,
      ),
    };
  }

  Future<void> goToNextStop() async {
    if (isAnimating) {
      debugPrint('ROADMAP ANIMATION IGNORED: animation is running');
      return;
    }

    if (!hasRoute) {
      debugPrint('ROADMAP ANIMATION IGNORED: route is empty');
      return;
    }

    if (!hasJourneyStarted) {
      return;
    }

    if (isAtLastStop) {
      debugPrint('ROADMAP: already at last stop');
      return;
    }

    final nextStopIndex = currentStopIndex + 1;

    final currentStopData = stops[currentStopIndex];

    final nextStopData = stops[nextStopIndex];

    debugPrint('========== ROADMAP NEXT STOP ==========');

    debugPrint('FROM: ${currentStopData.name}');

    debugPrint('TO: ${nextStopData.name}');

    isAnimating = true;
    notifyListeners();

    try {
      final segment = _findRouteSegment(
        start: currentStopData.location,
        destination: nextStopData.location,
      );

      debugPrint('Animation route points: ${segment.length}');

      if (segment.isEmpty) {
        carPosition = nextStopData.location;
        currentStopIndex = nextStopIndex;

        notifyListeners();
        return;
      }

      for (var i = 0; i < segment.length; i++) {
        final point = segment[i];

        carPosition = point;

        if (visibleRoutePoints.isEmpty ||
            visibleRoutePoints.last.latitude != point.latitude ||
            visibleRoutePoints.last.longitude != point.longitude) {
          visibleRoutePoints.add(point);
        }

        notifyListeners();

        await Future<void>.delayed(const Duration(milliseconds: 35));
      }

      carPosition = nextStopData.location;

      currentStopIndex = nextStopIndex;

      notifyListeners();

      debugPrint(
        'ARRIVED AT STOP '
        '${currentStopIndex + 1}/${stops.length}',
      );

      debugPrint('ARRIVED: ${nextStopData.name}');
    } catch (error, stackTrace) {
      debugPrint('ROADMAP ANIMATION ERROR: $error');

      debugPrintStack(stackTrace: stackTrace);
    } finally {
      isAnimating = false;

      notifyListeners();

      debugPrint('=======================================');
    }
  }

  List<LatLng> _findRouteSegment({
    required LatLng start,
    required LatLng destination,
  }) {
    if (routePoints.isEmpty) {
      return [start, destination];
    }

    final startIndex = _findNearestRouteIndex(start);

    final destinationIndex = _findNearestRouteIndex(destination);

    debugPrint(
      'Route segment: '
      '$startIndex → $destinationIndex',
    );

    if (startIndex == destinationIndex) {
      return [start, destination];
    }

    if (startIndex < destinationIndex) {
      return routePoints.sublist(startIndex, destinationIndex + 1);
    }

    return routePoints
        .sublist(destinationIndex, startIndex + 1)
        .reversed
        .toList();
  }

  int _findNearestRouteIndex(LatLng target) {
    var nearestIndex = 0;
    var nearestDistance = double.infinity;

    for (var i = 0; i < routePoints.length; i++) {
      final point = routePoints[i];

      final latDiff = point.latitude - target.latitude;

      final lngDiff = point.longitude - target.longitude;

      final distance = latDiff * latDiff + lngDiff * lngDiff;

      if (distance < nearestDistance) {
        nearestDistance = distance;

        nearestIndex = i;
      }
    }

    return nearestIndex;
  }
}
