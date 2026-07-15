import 'dart:io';

import 'package:flutter/material.dart';
import 'package:roamio_frontend/models/services/locationService.dart';
import 'package:roamio_frontend/models/services/tripService.dart';
import 'package:roamio_frontend/models/tripModel.dart';

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

  void setTripName(String value) {
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

  bool get isTripNameValid => tripName.trim().isNotEmpty;
  bool get isCountryValid => selectedCountry != null;
  bool get isStartDateValid => startDate != null;
  bool get isEndDateValid => endDate != null;
  bool get isStartTimeValid => startTime != null;

  bool get isStep1Valid {
    return isTripNameValid &&
        isCountryValid &&
        isStartDateValid &&
        isEndDateValid &&
        isStartTimeValid;
  }

  String? validateStep1() {
    if (!isTripNameValid) return "Trip name is required";
    if (!isCountryValid) return "Trip destination is required";
    if (!isStartDateValid || !isEndDateValid) return "Dates are required";
    if (startDate != null && endDate != null && endDate!.isBefore(startDate!)) {
      return "Start and end date are mismatched";
    }
    if (!isStartTimeValid) return "Start time is required";

    return null;
  }
  
    /// Builds "HH:mm" from TimeOfDay, e.g. 9:05 -> "09:05".
  String _formatStartTime(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
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
    return meetingPoint!['address']?.toString() ?? meetingPoint!['name']?.toString();
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
        startDate: startDate,
        endDate: endDate,
        startTime: _formatStartTime(startTime!),
        tripDestination: _buildTripDestination(),
        meetingPointName: _buildMeetingPointText(),
        meetingPointLat: (meetingPoint?['lat'] as num?)?.toDouble(),
        meetingPointLon: (meetingPoint?['lng'] as num?)?.toDouble(),
      );

      createdTrip = await _tripService.createTrip(trip, image: tripPhoto);

      isSubmitting = false;
      notifyListeners();
      return true;

    } catch (e) {
      errorMessage = "Unable to create trip.";
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    errorMessage = null;
    notifyListeners();
  }
}
