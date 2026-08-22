import 'package:flutter/material.dart';
import 'package:roamio_frontend/models/services/trip_service.dart';
import 'package:roamio_frontend/models/trip_model.dart';

class StoryCoverViewModel extends ChangeNotifier {
  StoryCoverViewModel({
    required this.tripId,
    TripService? tripService,
  }) : _tripService = tripService ?? TripService();

  final String tripId;
  final TripService _tripService;

  String tripName = '';
  String tripDateText = '';

  bool isLoading = false;
  String? errorMessage;

  Future<void> loadCoverData() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final Trip trip = await _tripService.getTripById(
        tripId,
        forceRefresh: true,
      );

      tripName = trip.tripName;
      tripDateText = _formatTripDate(trip.startDate);
    } catch (error, stackTrace) {
      debugPrint('LOAD STORY COVER ERROR: $error');
      debugPrintStack(stackTrace: stackTrace);

      errorMessage = 'Unable to load story. Please try again.';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  String _formatTripDate(DateTime? date) {
    if (date == null) return '';

    final localDate = date.toLocal();

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

    return '${localDate.day} '
        '${months[localDate.month - 1]} '
        '${localDate.year}';
  }
}