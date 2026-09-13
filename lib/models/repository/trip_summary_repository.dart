import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import '../../config/api_config.dart';
import '../../config/auth_headers.dart';
import '../trip_summary_model.dart';

/// Raw data access for trip summary/story/awards/photos.
/// Throws on any failure — callers (TripSummaryService) decide how to handle it.
class TripSummaryRepository {
  String _base(String tripId) => '${ApiConfig.trips}/$tripId/summary';

  Future<TripPhoto> uploadPhoto(
    String tripId,
    File photo, {
    DateTime? capturedAt,
    String? locationName,
    double? latitude,
    double? longitude,
    String? sourceAssetId,
  }) async {
    final uri = Uri.parse('${_base(tripId)}/$tripId/photo');

    final request = http.MultipartRequest('POST', uri);

    request.headers.addAll(await AuthHeaders.build(isJson: false));

    request.files.add(
      await http.MultipartFile.fromPath(
        'photo',
        photo.path,
        filename: 'photo_${DateTime.now().millisecondsSinceEpoch}.jpg',
        contentType: MediaType('image', 'jpeg'),
      ),
    );

    if (capturedAt != null) {
      request.fields['capturedAt'] = capturedAt.toUtc().toIso8601String();
    }

    if (locationName != null && locationName.trim().isNotEmpty) {
      request.fields['locationName'] = locationName.trim();
    }

    if (latitude != null) {
      request.fields['latitude'] = latitude.toString();
    }

    if (longitude != null) {
      request.fields['longitude'] = longitude.toString();
    }

    if (sourceAssetId != null && sourceAssetId.isNotEmpty) {
      request.fields['sourceAssetId'] = sourceAssetId;
    }

    final streamed = await request.send();

    final response = await http.Response.fromStream(streamed);

    if (response.statusCode != 201 && response.statusCode != 200) {
      throw Exception(
        'Failed to upload photo '
        '(${response.statusCode}): '
        '${response.body}',
      );
    }

    final decoded = jsonDecode(response.body);

    return TripPhoto.fromJson(decoded['photo'] as Map<String, dynamic>);
  }

  Future<List<TripPhoto>> getPhotos(String tripId) async {
    final uri = Uri.parse('${_base(tripId)}/photos');
    final headers = await AuthHeaders.build();
    final response = await http.get(uri, headers: headers);

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to load photos (${response.statusCode}): ${response.body}',
      );
    }

    final decoded = jsonDecode(response.body);
    final List<dynamic> data = decoded['photos'] as List<dynamic>? ?? [];
    return data
        .map((e) => TripPhoto.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<TripAward>> getAwards(String tripId) async {
    final uri = Uri.parse('${_base(tripId)}/awards');
    final headers = await AuthHeaders.build();
    final response = await http.get(uri, headers: headers);

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to load awards (${response.statusCode}): ${response.body}',
      );
    }

    final decoded = jsonDecode(response.body);
    final List<dynamic> data = decoded['awards'] as List<dynamic>? ?? [];
    return data
        .map((e) => TripAward.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<TripSummary> getSummary(String tripId) async {
    final uri = Uri.parse('${_base(tripId)}/summary');
    final headers = await AuthHeaders.build();
    final response = await http.get(uri, headers: headers);

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to load summary (${response.statusCode}): ${response.body}',
      );
    }

    final decoded = jsonDecode(response.body);
    return TripSummary.fromJson(decoded['summary'] as Map<String, dynamic>);
  }

  Future<ActivityGraphData> getActivityGraphData(
    String tripId, {
    String userId = '1',
  }) async {
    final uri = Uri.parse('${_base(tripId)}/activityGraphUser?userId=$userId');
    final headers = await AuthHeaders.build();
    final response = await http.get(uri, headers: headers);

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to load activity graph data (${response.statusCode}): ${response.body}',
      );
    }

    final decoded = jsonDecode(response.body);
    return ActivityGraphData.fromJson(
      decoded['graphData'] as Map<String, dynamic>,
    );
  }

  Future<StoryData> getStoryData(String tripId, {String userId = '1'}) async {
    final uri = Uri.parse('${_base(tripId)}/story?userId=$userId');
    final headers = await AuthHeaders.build();
    final response = await http.get(uri, headers: headers);

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to load story data (${response.statusCode}): ${response.body}',
      );
    }

    final decoded = jsonDecode(response.body);
    return StoryData.fromJson(decoded['storyData'] as Map<String, dynamic>);
  }

  Future<ActivityGraphData> getActivityGraphDataByTrip(String tripId) async {
    final uri = Uri.parse('${_base(tripId)}/activityGraphTrip');
    final headers = await AuthHeaders.build();
    final response = await http.get(uri, headers: headers);

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to load activity graph data (${response.statusCode}): ${response.body}',
      );
    }

    final decoded = jsonDecode(response.body);
    return ActivityGraphData.fromJson(
      decoded['graphData'] as Map<String, dynamic>,
    );
  }

  Future<void> deletePhoto(String tripId, String photoId) async {
    final uri = Uri.parse('${_base(tripId)}/photo/$photoId');
    final headers = await AuthHeaders.build();
    final response = await http.delete(uri, headers: headers);

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to delete photo (${response.statusCode}): ${response.body}',
      );
    }
  }
}
