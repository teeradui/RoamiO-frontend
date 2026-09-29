import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

enum TripAwardType {
  lateArrival,
  earlyArrival,
  food,
  sightseeing,
  accommodation,
  transit,
  other,
}

class AwardMeta {
  final TripAwardType type;
  final IconData icon;
  const AwardMeta(this.type, this.icon);
}

final Map<String, AwardMeta> awardMetaByName = {
  // lateArrival
  'Late Turtle': const AwardMeta(TripAwardType.lateArrival, CupertinoIcons.tortoise_fill),
  'Fashionably Late': const AwardMeta(TripAwardType.lateArrival, Icons.watch_later_rounded),
  'Last Minute Legend': const AwardMeta(TripAwardType.lateArrival, Icons.timer_rounded),
  'Slow & Steady': const AwardMeta(TripAwardType.lateArrival, Icons.directions_walk_rounded),

  // earlyArrival
  'Early Bird': const AwardMeta(TripAwardType.earlyArrival, Icons.wb_sunny_rounded),
  'First on the Scene': const AwardMeta(TripAwardType.earlyArrival, Icons.flag_rounded),
  'Ready, Set, Roam!': const AwardMeta(TripAwardType.earlyArrival, Icons.rocket_launch_rounded),
  'Morning Hero': const AwardMeta(TripAwardType.earlyArrival, Icons.light_mode_rounded),

  // food
  'Snack Commander': const AwardMeta(TripAwardType.food, Icons.restaurant_rounded),
  'Foodie Supreme': const AwardMeta(TripAwardType.food, Icons.ramen_dining_rounded),
  'Bite Boss': const AwardMeta(TripAwardType.food, Icons.fastfood_rounded),
  'Taste Explorer': const AwardMeta(TripAwardType.food, Icons.local_dining_rounded),

  // sightseeing
  'Explorer Mode': const AwardMeta(TripAwardType.sightseeing, Icons.explore_rounded),
  'View Hunter': const AwardMeta(TripAwardType.sightseeing, Icons.landscape_rounded),
  'Sightseeing Star': const AwardMeta(TripAwardType.sightseeing, Icons.photo_camera_rounded),
  'Adventure Magnet': const AwardMeta(TripAwardType.sightseeing, Icons.travel_explore_rounded),

  // accommodation
  'Cozy Commander': const AwardMeta(TripAwardType.accommodation, Icons.hotel_rounded),
  'Rest Master': const AwardMeta(TripAwardType.accommodation, Icons.bed_rounded),
  'Chill Champion': const AwardMeta(TripAwardType.accommodation, Icons.night_shelter_rounded),
  'Recharge Pro': const AwardMeta(TripAwardType.accommodation, Icons.bedtime_rounded),

  // transit
  'Road Warrior': const AwardMeta(TripAwardType.transit, Icons.route_rounded),
  'Always on the Move': const AwardMeta(TripAwardType.transit, Icons.directions_rounded),
  'Born to Roam': const AwardMeta(TripAwardType.transit, Icons.navigation_rounded),
  'Transit Titan': const AwardMeta(TripAwardType.transit, Icons.directions_bus_rounded),
};

Color getAwardColor(TripAwardType type) {
  switch (type) {
    case TripAwardType.lateArrival:
      return const Color(0xFFF7630D);
    case TripAwardType.earlyArrival:
      return const Color(0xFFECA205);
    case TripAwardType.food:
      return const Color(0xFFFF8340);
    case TripAwardType.sightseeing:
      return const Color(0xFF36A1C7);
    case TripAwardType.accommodation:
      return const Color(0xFF8E5CF7);
    case TripAwardType.transit:
      return const Color(0xFF2D7DFB);
    case TripAwardType.other:
      return const Color(0xFF9E9E9E);
  }
}

Color getAwardBackgroundColor(TripAwardType type) {
  switch (type) {
    case TripAwardType.lateArrival:
      return const Color(0x30FF7D5C);
    case TripAwardType.earlyArrival:
      return const Color(0x3BFFE37A);
    case TripAwardType.food:
      return const Color(0x30FFD3BB);
    case TripAwardType.sightseeing:
      return const Color(0x2636A1C7);
    case TripAwardType.accommodation:
      return const Color(0x268E5CF7);
    case TripAwardType.transit:
      return const Color(0x262D7DFB);
    case TripAwardType.other:
      return const Color(0x1F9E9E9E);
  }
}