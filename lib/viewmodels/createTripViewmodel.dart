import 'dart:io';

import 'package:flutter/material.dart';
import 'package:roamio_frontend/models/services/locationService.dart';

class CreateTripViewModel extends ChangeNotifier {
  final LocationService _locationService = LocationService();

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

  Future<bool> submitCreateTrip() async {
    final validationError = validateStep1();

    if (validationError != null) {
      errorMessage = validationError;
      notifyListeners();
      return false;
    }

    try {
      // await TripService.createTrip(...);

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
