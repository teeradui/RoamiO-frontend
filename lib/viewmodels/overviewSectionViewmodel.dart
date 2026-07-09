import 'package:flutter/material.dart';

class OverviewSectionViewModel extends ChangeNotifier {
  int photosCount = 0;
  int placesCount = 0;
  int activitiesCount = 0;

  bool get isEmpty {
    return photosCount == 0 && placesCount == 0 && activitiesCount == 0;
  }
}