import 'package:flutter/material.dart';

class ActivitiesSectionViewModel extends ChangeNotifier {
  ActivitiesSectionViewModel();

  final List<dynamic> activities = [];

  bool get hasActivities => activities.isNotEmpty;
}