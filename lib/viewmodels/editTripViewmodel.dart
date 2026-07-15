import 'dart:io';

import 'package:flutter/material.dart';
import 'package:roamio_frontend/models/services/locationService.dart';
import 'package:roamio_frontend/models/services/tripService.dart';
import 'package:roamio_frontend/models/tripModel.dart';

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

  void _applyTrip(Trip trip) {
    tripName = trip.tripName;
    startDate = trip.startDate;
    endDate = trip.endDate;
    startTime = _parseStartTime(trip.startTime);
 
    if (trip.meetingPointName != null) {
      meetingPoint = {
        'address': trip.meetingPointName,
        if (trip.meetingPointLat != null) 'lat': trip.meetingPointLat,
        if (trip.meetingPointLon != null) 'lng': trip.meetingPointLon,
      };
    }
 
    _applyDestination(trip.tripDestination);
  }
 
  TimeOfDay? _parseStartTime(String? value) {
    if (value == null) return null;
    final parts = value.split(':');
    if (parts.length != 2) return null;
    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null || minute == null) return null;
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

  void setMeetingPoint(Map<String, dynamic>? point) {
    meetingPoint = point;
    notifyListeners();
  }

  bool get isTripNameValid => tripName.trim().isNotEmpty;
  bool get isCountryValid => selectedCountry != null;
  bool get isStartDateValid => startDate != null;
  bool get isEndDateValid => endDate != null;
  bool get isStartTimeValid => startTime != null;

  bool get canSave {
    return isTripNameValid &&
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
    return meetingPoint!['address']?.toString() ?? meetingPoint!['name']?.toString();
  }


  Map<String, dynamic> _buildChangedFields() {
    final fields = <String, dynamic>{};
 
    if (isTripNameValid) fields['tripName'] = tripName.trim();
    if (startDate != null) fields['startDate'] = startDate!.toIso8601String();
    if (endDate != null) fields['endDate'] = endDate!.toIso8601String();
    if (startTime != null) fields['startTime'] = _formatStartTime(startTime!);
 
    final destination = _buildTripDestination();
    if (destination != null) fields['tripDestination'] = destination;
 
    final meetingPointText = _buildMeetingPointText();
    if (meetingPointText != null) {
      fields['meetingPointName'] = meetingPointText;
      if (meetingPoint?['lat'] != null) fields['meetingPointLat'] = meetingPoint!['lat'];
      if (meetingPoint?['lng'] != null) fields['meetingPointLon'] = meetingPoint!['lng'];
    }
 
    return fields;
  }


    Future<bool> saveChanges() async {
    if (!canSave) return false;
 
    isSaving = true;
    errorMessage = null;
    notifyListeners();
 
    try {
      await _tripService.updateTrip(
        tripId,
        _buildChangedFields(),
        image: tripPhoto,
      );
 
      isSaving = false;
      notifyListeners();
      return true;
    } catch (e) {
      isSaving = false;
      errorMessage = "Unable to save changes.";
      notifyListeners();
      return false;
    }
  }
}