import 'dart:io';

import 'package:flutter/material.dart';
import 'package:roamio_frontend/models/services/locationService.dart';

class EditTripViewModel extends ChangeNotifier {
  final LocationService _locationService = LocationService();

  String tripName = "Japan Autumn Trip";
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

  Future<void> loadInitialData() async {
    isLoadingCountries = true;
    notifyListeners();

    countries = await _locationService.getCountries();

    // TODO: ดึงข้อมูล trip เดิมจาก backend แล้ว set ค่าใส่ตรงนี้
    // ตอนนี้ mock ไว้ก่อน

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

  Future<bool> saveChanges() async {
    if (!canSave) return false;

    isSaving = true;
    notifyListeners();

    // TODO: call backend update trip
    await Future.delayed(const Duration(milliseconds: 500));

    isSaving = false;
    notifyListeners();

    return true;
  }
}