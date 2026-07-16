import 'dart:io';

import 'package:flutter/material.dart';
import 'package:roamio_frontend/models/services/location_service.dart';
import 'package:roamio_frontend/models/services/trip_service.dart';
import 'package:roamio_frontend/models/trip_model.dart';

class EditTripViewModel extends ChangeNotifier {
  final String tripId;
  final LocationService _locationService = LocationService();
  final TripService _tripService;

  EditTripViewModel({required this.tripId, TripService? tripService})
    : _tripService = tripService ?? TripService();

  String tripName = "";
  Map<String, dynamic>? selectedCountry;
  Map<String, dynamic>? selectedState;
  DateTime? startDate;
  DateTime? endDate;
  TimeOfDay? startTime;
  File? tripPhoto;
  String? existingImageUrl;
  Map<String, dynamic>? meetingPoint;

  List<Map<String, dynamic>> countries = [];
  List<Map<String, dynamic>> states = [];

  bool isLoadingCountries = false;
  bool isSaving = false;
  String? errorMessage;

  Future<void> loadInitialData() async {
    isLoadingCountries = true;
    notifyListeners();

    countries = await _locationService.getCountries();

    try {
      final trip = await _tripService.getTripById(tripId);
      _applyTrip(trip);
    } catch (e) {
      errorMessage = "Unable to load trip details.";
    }

    isLoadingCountries = false;
    notifyListeners();
  }

  void setTripPhoto(File? photo) {
    tripPhoto = photo;
    notifyListeners();
  }

  void _applyTrip(Trip trip) {
    tripName = trip.tripName;
    startDate = trip.startDate;
    endDate = trip.endDate;
    startTime = _parseStartTime(trip.startTime);

    if (trip.meetingPointName != null &&
        trip.meetingPointName!.trim().isNotEmpty) {
      meetingPoint = {
        'name': trip.meetingPointName,
        'address': trip.meetingPointName,
        if (trip.meetingPointLat != null) 'lat': trip.meetingPointLat,
        if (trip.meetingPointLon != null) 'lng': trip.meetingPointLon,
      };
    } else {
      meetingPoint = null;
    }

    _applyDestination(trip.tripDestination);
  }

  TimeOfDay? _parseStartTime(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }

    // กรณี Backend ส่ง timestamp เต็ม
    // เช่น 2026-07-31T12:12:00.000
    final parsedDateTime = DateTime.tryParse(value);

    if (parsedDateTime != null) {
      final localDateTime = parsedDateTime.toLocal();

      return TimeOfDay(hour: localDateTime.hour, minute: localDateTime.minute);
    }

    // กรณี Backend ส่งเฉพาะเวลา เช่น 12:12 หรือ 12:12:00
    final parts = value.split(':');

    if (parts.length < 2) {
      return null;
    }

    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);

    if (hour == null || minute == null) {
      return null;
    }

    return TimeOfDay(hour: hour, minute: minute);
  }

  void _applyDestination(String? destination) {
    if (destination == null || countries.isEmpty) return;

    // destination is either "Country" or "State, Country"
    final parts = destination.split(',').map((p) => p.trim()).toList();
    final countryName = parts.length > 1 ? parts[1] : parts[0];
    final stateName = parts.length > 1 ? parts[0] : null;

    final matchedCountry = countries.cast<Map<String, dynamic>?>().firstWhere(
      (c) => c?['name'] == countryName,
      orElse: () => null,
    );

    if (matchedCountry == null) return;

    selectedCountry = matchedCountry;
    states = _locationService.getStatesByCountry(matchedCountry);

    if (stateName != null) {
      selectedState = states.cast<Map<String, dynamic>?>().firstWhere(
        (s) => s?['name'] == stateName,
        orElse: () => null,
      );
    }
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

  void setMeetingPoint(Map<String, dynamic>? point) {
    meetingPoint = point;
    notifyListeners();
  }

  bool get istripNameValid => tripName.trim().isNotEmpty;
  bool get isCountryValid => selectedCountry != null;
  bool get isStartDateValid => startDate != null;
  bool get isEndDateValid => endDate != null;
  bool get isStartTimeValid => startTime != null;

  bool get canSave {
    return istripNameValid &&
        isCountryValid &&
        isStartDateValid &&
        isEndDateValid &&
        isStartTimeValid;
  }

  String _formatStartTime(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  String? _buildTripDestination() {
    final countryName = selectedCountry?['name'] as String?;
    final stateName = selectedState?['name'] as String?;
    if (countryName == null) return null;
    if (stateName == null) return countryName;
    return '$stateName, $countryName';
  }

  String? _buildMeetingPointText() {
    if (meetingPoint == null) return null;

    final value =
        meetingPoint!['address']?.toString() ??
        meetingPoint!['name']?.toString();

    if (value == null || value.trim().isEmpty) {
      return null;
    }

    return value.trim();
  }

  Map<String, dynamic> _buildChangedFields() {
    final fields = <String, dynamic>{};

    if (istripNameValid) fields['tripName'] = tripName.trim();
    if (startDate != null) fields['startDate'] = startDate!.toIso8601String();
    if (endDate != null) fields['endDate'] = endDate!.toIso8601String();
    if (startDate != null && startTime != null) {
      final startDateTime = DateTime(
        startDate!.year,
        startDate!.month,
        startDate!.day,
        startTime!.hour,
        startTime!.minute,
      );

      fields['startTime'] = startDateTime.toIso8601String();
    }

    final destination = _buildTripDestination();
    if (destination != null) fields['tripDestination'] = destination;

    final meetingPointText = _buildMeetingPointText();

    if (meetingPointText != null) {
      fields['meetingPointName'] = meetingPointText;
      fields['meetingPointLat'] = (meetingPoint?['lat'] as num?)?.toDouble();
      fields['meetingPointLon'] = (meetingPoint?['lng'] as num?)?.toDouble();
    } else {
      fields['meetingPointName'] = null;
      fields['meetingPointLat'] = null;
      fields['meetingPointLon'] = null;
    }

    return fields;
  }

  String _getValidationError() {
    if (!istripNameValid) return "Trip name is required.";
    if (!isCountryValid) return "Trip destination is required.";
    if (!isStartDateValid || !isEndDateValid) {
      return "Trip dates are required.";
    }
    if (!isStartTimeValid) return "Start time is required.";

    return "Please complete all required fields.";
  }

  Future<bool> saveChanges() async {
    debugPrint('========== EDIT TRIP VALIDATION ==========');
    debugPrint('tripId: $tripId');
    debugPrint('tripName valid: $istripNameValid');
    debugPrint('country valid: $isCountryValid');
    debugPrint('startDate valid: $isStartDateValid');
    debugPrint('endDate valid: $isEndDateValid');
    debugPrint('startTime valid: $isStartTimeValid');
    debugPrint('canSave: $canSave');
    debugPrint('==========================================');

    if (!canSave) {
      errorMessage = _getValidationError();
      debugPrint('EDIT TRIP VALIDATION ERROR: $errorMessage');
      notifyListeners();
      return false;
    }

    isSaving = true;
    errorMessage = null;
    notifyListeners();

    try {
      final fields = _buildChangedFields();

      debugPrint('========== UPDATE TRIP REQUEST ==========');
      debugPrint('tripId: $tripId');
      debugPrint('fields: $fields');
      debugPrint('image path: ${tripPhoto?.path}');
      debugPrint('=========================================');

      final updatedTrip = await _tripService.updateTrip(
        tripId,
        fields,
        image: tripPhoto,
      );

      debugPrint('UPDATE TRIP SUCCESS');
      debugPrint('updated trip id: ${updatedTrip.id}');
      debugPrint('updated trip name: ${updatedTrip.tripName}');

      return true;
    } catch (error, stackTrace) {
      debugPrint('UPDATE TRIP ERROR: $error');
      debugPrintStack(stackTrace: stackTrace);

      errorMessage = "Unable to save changes.";
      return false;
    } finally {
      isSaving = false;
      notifyListeners();
    }
  }
}
