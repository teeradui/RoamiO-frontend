import 'package:flutter/material.dart';

class AppColors {
  // Background Colors
  static const Color bgPrimary = Color(0xFFFFF8EC);
  static const Color bgAccent = Color(0xFFFAF1E2);
  static const Color bgHighlight = Color(0xFFFFE37A);
  static const Color bgCard = Color(0xFFFFFDF8);
  static const Color bgCard2 = Color(0xFFFFFAF1);

  // Text Colors
  static const Color textPrimary = Color(0xFF6E3A0F);
  static const Color textSecondary = Color(0xFFAB653A);
  static const Color textMuted = Color(0xFFBEA690);
  static const Color textDisabled = Color(0xFFDCC6B4);
  static const Color textAddBtn = Color(0xFF36A1C7);
  static const Color textRemoveBtn = Color(0xFFF24822);

  // Tab Bar Colors
  static const Color tabActive = Color(0xFFECA205);
  static const Color tabInactive = Color(0xFFDCC6B4);
  static const Color tabGlow = Color(0xFFFFE37A);

  // Filter Tabs Colors
  static const Color filterActiveBg = Color(0xFFFFE37A);
  static const Color filterActiveText = Color(0xFFAB653A);
  static const Color filterInactiveBg = Color(0xFFFAF1E2);
  static const Color filterInactiveText = Color(0xFFBEA690);

  // Button Colors
  static const Color btnPrimary = Color(0xFFFF7D5C);
  static const Color btnSecondary = Color(0xFFFFFAF1);
  static const Color btnAdd = Color(0x56BBE7FF);
  static const Color btnRemove = Color(0xFFFFD4CD);

  // Status Colors
  static const Color bgUpcoming = Color(0x453B54E0);
  static const Color textUpcoming = Color(0xFF3B54E0);

  static const Color bgActive = Color(0x45F97316);
  static const Color textActive = Color(0xFFF97316);

  static const Color bgCompleted = Color(0x4564FF76);
  static const Color textCompleted = Color(0xFF33BA42);

  // Step Bar Colors
  static const Color stepActive = Color(0xFFFF613A);
  static const Color stepInactive = Color(0xFFD9D9D9);

  // Other Colors
  static const Color green = Color(0xFF33BA42);
  static const Color red = Color(0xFFE70017);
  static const Color black = Color(0xFF403E3E);

  // Icon Colors
  static const Color iconOrange = Color(0xFFFF613A);
  static const Color iconBrown = Color(0xFFCC9160);

  // photo upload
  static const Color bgPhoto = Color(0x39FBDD6F);
  static const Color borderPhoto = Color(0xFFFFCD29);

  // icon graph
  static const List<Color> iconGroupGraph = [
    Color(0xFFFFC4C4),
    Color(0xFFFF9191),
    Color(0xFFC36FAA),
    Color(0xFFA96494),
  ];
  static const List<Color> iconPersonalGraph = [
    Color(0xFFFFAC07),
    Color(0xFFE26109),
    Color(0xFFC20C0C),
    Color(0xFF860909),
  ];

  static const List<Color> sparkle = [
    Color(0xFFFFDB80),
    Color(0xFFFFD365),
    Color(0xFFFFB700),
  ];

  static const Color add = Color(0xFF403E3E);

  // Gradients
  static const List<Color> gradientUpAc = [
    Color(0xFFFFCABD),
    Color(0xFFFB905B),
    Color(0xFFF7630D),
    Color(0xFFFF613A),
  ];

  static const List<Color> gradientMap = [
    Color(0xFF55B8DC),
    Color(0xFF3DBA9F),
    Color(0xFF1E6F58),
  ];

  static const List<Color> storyCover = [
    Color(0xFF76D7A5),
    Color(0xFFEFFFF0),
    Color(0xFFB8F2C8),
    Color(0xFFFFE89A),
    Color(0xFF4EAD82),
  ];

  static const List<Color> storyTripOverview = [
    Color(0xFFFF985C),
    Color(0xFFFFF4DC),
    Color(0xFFFFC078),
    Color(0xFFFFD7B5),
    Color(0xFFE96A3A),
  ];

  static const List<Color> storyActivitySummary = [
    Color(0xFFB48CFF),
    Color(0xFFFFF0FA),
    Color(0xFFE0C2FF),
    Color(0xFFFFA9D4),
    Color(0xFF815AC7),
  ];

  static const List<Color> storyPhotoHighlights = [
    Color(0xFFFFD84D),
    Color(0xFFFFFBE6),
    Color(0xFFFFEFA3),
    Color(0xFFAEEBFF),
    Color(0xFFE9AD21),
  ];

  static const List<Color> storyMyActivityStats = [
    Color(0xFF80E0FF),
    Color(0xFFFFFBE6),
    Color(0xFFBFF0FF),
    Color(0xFFFFEC80),
    Color(0xFF60A8BF),
  ];

  static const List<Color> storyTripAwards = [
    Color(0xFFFF8FB8),
    Color(0xFFFFF0E8),
    Color(0xFFFFC1D8),
    Color(0xFFFFC477),
    Color(0xFFD95B91),
  ];

  static const List<Color> storyReliabilityScores = [
    Color(0xFF72C9FF),
    Color(0xFFF4EEFF),
    Color(0xFFB9DEFF),
    Color(0xFFC59BFF),
    Color(0xFF7066D8),
  ];

  static const List<Color> storyTripRoadmap = [
    Color(0xFF64DCC3),
    Color(0xFFF2FFF9),
    Color(0xFFA9EFDC),
    Color(0xFFFFC978),
    Color(0xFF329F91),
  ];

  static const List<Color> storyEnding = [
    Color(0xFFFFE66D),
    Color(0xFFFFF6E5),
    Color(0xFFFFB879),
    Color(0xFFFF8FA3),
    Color(0xFFFF6B57),
  ];

  // Reliability Icon Gradients

  static const LinearGradient arrivedEarlyGradient = LinearGradient(
    colors: [Color(0xFF579AF7), Color(0xFF468FF5), Color(0xFF0048AC)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient onTimeGradient = LinearGradient(
    colors: [Color(0xFFFFD56C), Color(0xFFF68E2D), Color(0xFFFF7C01)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient slightDelayGradient = LinearGradient(
    colors: [Color(0xFFFFA1A1), Color(0xFFFF9191), Color(0xFFFF5454)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient extendedDelayGradient = LinearGradient(
    colors: [Color(0xFFEB2135), Color(0xFFB81424), Color(0xFF81000D)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient ghostGradient = LinearGradient(
    colors: [Color(0xFF7E7C7C), Color(0xFF403E3E), Color(0xFF040404)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Reliability Status Colors

  static const Color arrivedEarlyColor = Color(0xFF0048AC);
  static const Color arrivedEarlyBackground = Color(0x1F579AF7);

  static const Color onTimeColor = Color(0xFFF68E2D);
  static const Color onTimeBackground = Color(0x24FFD56C);

  static const Color slightDelayColor = Color(0xFFFF5454);
  static const Color slightDelayBackground = Color(0x24FFA1A1);

  static const Color extendedDelayColor = Color(0xFFB81424);
  static const Color extendedDelayBackground = Color(0x1FEB2135);

  static const Color ghostColor = Color(0xFF403E3E);
  static const Color ghostBackground = Color(0x1F7E7C7C);
}
