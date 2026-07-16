import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:roamio_frontend/config/api_config.dart';
import 'package:roamio_frontend/config/auth_headers.dart';

class OverviewPlaceResponse {
  final String name;
  final String type;
  final String timeText;

  const OverviewPlaceResponse({
    required this.name,
    required this.type,
    required this.timeText,
  });

  factory OverviewPlaceResponse.fromJson(Map<String, dynamic> json) {
    return OverviewPlaceResponse(
      name:
          json['placeName']?.toString() ??
          json['place_name']?.toString() ??
          'Unknown Place',
      type:
          json['placeType']?.toString() ??
          json['place_type']?.toString() ??
          'Unknown',
      timeText:
          json['timeText']?.toString() ??
          json['arrivalTime']?.toString() ??
          json['arrival_time']?.toString() ??
          '',
    );
  }
}

class OverviewActivityTypeResponse {
  final String label;
  final int count;

  const OverviewActivityTypeResponse({
    required this.label,
    required this.count,
  });

  factory OverviewActivityTypeResponse.fromJson(
    Map<String, dynamic> json,
  ) {
    return OverviewActivityTypeResponse(
      label:
          json['label']?.toString() ??
          json['activityType']?.toString() ??
          json['activity_type']?.toString() ??
          'Unknown',
      count: _parseInt(json['count']),
    );
  }
}

class TripOverviewResponse {
  final int photosCount;
  final int placesCount;
  final int activitiesCount;
  final List<OverviewPlaceResponse> places;
  final List<OverviewActivityTypeResponse> activityTypes;

  const TripOverviewResponse({
    required this.photosCount,
    required this.placesCount,
    required this.activitiesCount,
    required this.places,
    required this.activityTypes,
  });

  factory TripOverviewResponse.fromJson(Map<String, dynamic> json) {
    final placesJson = json['places'];
    final activityTypesJson =
        json['activityTypes'] ?? json['activity_types'];

    return TripOverviewResponse(
      photosCount: _parseInt(
        json['photosCount'] ?? json['photos_count'],
      ),
      placesCount: _parseInt(
        json['placesCount'] ?? json['places_count'],
      ),
      activitiesCount: _parseInt(
        json['activitiesCount'] ?? json['activities_count'],
      ),
      places: placesJson is List
          ? placesJson
                .whereType<Map>()
                .map(
                  (item) => OverviewPlaceResponse.fromJson(
                    Map<String, dynamic>.from(item),
                  ),
                )
                .toList()
          : [],
      activityTypes: activityTypesJson is List
          ? activityTypesJson
                .whereType<Map>()
                .map(
                  (item) =>
                      OverviewActivityTypeResponse.fromJson(
                        Map<String, dynamic>.from(item),
                      ),
                )
                .toList()
          : [],
    );
  }
}

int _parseInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();

  return int.tryParse(value?.toString() ?? '') ?? 0;
}

class OverviewService {
  Future<TripOverviewResponse> getTripOverview(
    String tripId,
  ) async {
    final uri = Uri.parse(
      '${ApiConfig.trips}/$tripId/overview',
    );

    final headers = await AuthHeaders.build();

    debugPrint('========== LOAD TRIP OVERVIEW ==========');
    debugPrint('URL: $uri');
    debugPrint('Trip ID: $tripId');

    final response = await http.get(
      uri,
      headers: headers,
    );

    debugPrint('Status code: ${response.statusCode}');
    debugPrint('Response body: ${response.body}');
    debugPrint('========================================');

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to load trip overview '
        '(${response.statusCode}): ${response.body}',
      );
    }

    final decoded = jsonDecode(response.body);

    if (decoded is! Map<String, dynamic>) {
      throw const FormatException(
        'Invalid trip overview response.',
      );
    }

    return TripOverviewResponse.fromJson(decoded);
  }
}