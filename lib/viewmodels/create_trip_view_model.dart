import 'dart:io';
import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:roamio_frontend/models/services/location_service.dart';
import 'package:roamio_frontend/models/services/trip_service.dart';
import 'package:roamio_frontend/models/trip_model.dart';

class CreateTripViewModel extends ChangeNotifier {
  final LocationService _locationService = LocationService();
  final TripService _tripService;

  CreateTripViewModel({TripService? tripService})
    : _tripService = tripService ?? TripService();

  // Required fields
  String tripName = '';
  Map<String, dynamic>? selectedCountry;
  DateTime? startDate;
  DateTime? endDate;
  TimeOfDay? startTime;

  // Optional fields
  File? tripPhoto;
  Map<String, dynamic>? selectedState;
  Map<String, dynamic>? meetingPoint;

  // Country / State
  List<Map<String, dynamic>> countries = [];
  List<Map<String, dynamic>> states = [];

  bool isLoadingCountries = false;
  bool isSubmitting = false;

  String? errorMessage;

  Trip? createdTrip;

  Future<void> loadCountries() async {
    isLoadingCountries = true;
    notifyListeners();

    countries = await _locationService.getCountries();

    isLoadingCountries = false;
    notifyListeners();
  }

  void settripName(String value) {
    tripName = value;
    notifyListeners();
  }

  void selectCountry(Map<String, dynamic> country) {
    selectedCountry = country;
    selectedState = null;
    states = _locationService.getStatesByCountry(country);
    notifyListeners();
  }

  void selectState(Map<String, dynamic> state) {
    selectedState = state;
    notifyListeners();
  }

  void setStartDate(DateTime date) {
    startDate = date;

    if (endDate != null && endDate!.isBefore(date)) {
      endDate = null;
    }

    notifyListeners();
  }

  void setEndDate(DateTime date) {
    endDate = date;
    notifyListeners();
  }

  void setStartTime(TimeOfDay time) {
    startTime = time;
    notifyListeners();
  }

  void setTripPhoto(File? photo) {
    tripPhoto = photo;
    notifyListeners();
  }

  void setMeetingPoint(Map<String, dynamic>? point) {
    meetingPoint = point;
    notifyListeners();
  }

  bool get istripNameValid => tripName.trim().isNotEmpty;
  bool get isCountryValid => selectedCountry != null;
  bool get isStartDateValid => startDate != null;
  bool get isEndDateValid => endDate != null;
  bool get isStartTimeValid => startTime != null;

  bool get isStep1Valid {
    return istripNameValid &&
        isCountryValid &&
        isStartDateValid &&
        isEndDateValid &&
        isStartTimeValid;
  }

  String? validateStep1() {
    if (!istripNameValid) return "Trip name is required";
    if (!isCountryValid) return "Trip destination is required";
    if (!isStartDateValid || !isEndDateValid) return "Dates are required";
    if (startDate != null && endDate != null && endDate!.isBefore(startDate!)) {
      return "Start and end date are mismatched";
    }
    if (!isStartTimeValid) return "Start time is required";

    return null;
  }

  /// Builds "HH:mm" from TimeOfDay, e.g. 9:05 -> "09:05".
  DateTime _buildStartDateUtc() {
    if (startDate == null) {
      throw Exception('Start date is null');
    }

    final localDate = DateTime(
      startDate!.year,
      startDate!.month,
      startDate!.day,
    );

    return localDate.toUtc();
  }

  DateTime _buildEndDateUtc() {
    if (endDate == null) {
      throw Exception('End date is null');
    }

    final localDate = DateTime(endDate!.year, endDate!.month, endDate!.day);

    return localDate.toUtc();
  }

  DateTime _buildStartDateTimeUtc() {
    if (startDate == null || startTime == null) {
      throw Exception('Start date or start time is null');
    }

    final localDateTime = DateTime(
      startDate!.year,
      startDate!.month,
      startDate!.day,
      startTime!.hour,
      startTime!.minute,
    );

    return localDateTime.toUtc();
  }

  /// Combines country + state into a single destination string.
  String? _buildTripDestination() {
    final countryName = selectedCountry?['name'] as String?;
    final stateName = selectedState?['name'] as String?;
    if (countryName == null) return null;
    if (stateName == null) return countryName;
    return '$stateName, $countryName';
  }

  String? _buildMeetingPointText() {
    if (meetingPoint == null) return null;
    return meetingPoint!['address']?.toString() ??
        meetingPoint!['name']?.toString();
  }

  Future<bool> submitCreateTrip() async {
    final validationError = validateStep1();

    if (validationError != null) {
      errorMessage = validationError;
      notifyListeners();
      return false;
    }

    isSubmitting = true;
    errorMessage = null;
    notifyListeners();

    try {
      final trip = Trip(
        tripName: tripName.trim(),
        startDate: _buildStartDateUtc(),
        endDate: _buildEndDateUtc(),
        startTime: _buildStartDateTimeUtc(),
        tripDestination: _buildTripDestination(),
        meetingPointName: _buildMeetingPointText(),
        meetingPointLat: (meetingPoint?['lat'] as num?)?.toDouble(),
        meetingPointLon: (meetingPoint?['lng'] as num?)?.toDouble(),
      );

      developer.log('''
Creating trip:
tripName: ${trip.tripName}
startDate: ${trip.startDate}
endDate: ${trip.endDate}
startTime: ${trip.startTime}
destination: ${trip.tripDestination}
meetingPoint: ${trip.meetingPointName}
meetingPointLat: ${trip.meetingPointLat}
meetingPointLon: ${trip.meetingPointLon}
photo: ${tripPhoto?.path}
''', name: 'CreateTripViewModel');

      createdTrip = await _tripService.createTrip(trip, image: tripPhoto);

      developer.log(
        'Trip created successfully: $createdTrip',
        name: 'CreateTripViewModel',
      );

      return true;
    } catch (error, stackTrace) {
      developer.log(
        'Unable to create trip',
        name: 'CreateTripViewModel',
        error: error,
        stackTrace: stackTrace,
      );

      debugPrint('CREATE TRIP ERROR: $error');
      debugPrintStack(stackTrace: stackTrace);

      errorMessage = _getCreateTripErrorMessage(error);
      return false;
    } finally {
      isSubmitting = false;
      notifyListeners();
    }
  }

  String _getCreateTripErrorMessage(Object error) {
    final message = error.toString();

    if (message.contains('SocketException') ||
        message.contains('Connection refused') ||
        message.contains('Failed host lookup') ||
        message.contains('Network is unreachable')) {
      return 'Request failed. Please check your connection.';
    }

    if (message.contains('401') || message.contains('Unauthorized')) {
      return 'Your session has expired. Please log in again.';
    }

    if (message.contains('403') || message.contains('Forbidden')) {
      return 'You do not have permission to create this trip.';
    }

    if (message.contains('400') ||
        message.contains('422') ||
        message.contains('validation')) {
      return 'Some trip information is invalid. Please check and try again.';
    }

    if (message.contains('500') ||
        message.contains('502') ||
        message.contains('503')) {
      return 'Unable to create trip. Please try again.';
    }

    return 'Unable to create trip.';
  }

  void clearError() {
    errorMessage = null;
    notifyListeners();
  }
}
