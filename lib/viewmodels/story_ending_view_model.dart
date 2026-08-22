import 'package:flutter/material.dart';

enum StorySharePlatform {
  instagram,
  facebook,
}

class StoryEndingViewModel extends ChangeNotifier {
  StoryEndingViewModel({
    required this.tripId,
  });

  final String tripId;

  bool isGeneratingVideo = false;
  bool isOpeningPlatform = false;

  String? errorMessage;

  bool get isProcessing =>
      isGeneratingVideo || isOpeningPlatform;


  Future<bool> prepareStoryVideo() async {
    if (isProcessing) {
      return false;
    }

    debugPrint(
      '========== GENERATE STORY VIDEO ==========',
    );
    debugPrint('Trip ID: $tripId');

    isGeneratingVideo = true;
    errorMessage = null;
    notifyListeners();

    try {
      /*
       * TEMP MOCK
       *
       * TODO:
       * ภายหลังตรงนี้จะเรียก Service สำหรับ
       * generate trip story video จริง
       */

      await Future<void>.delayed(
        const Duration(milliseconds: 500),
      );

      debugPrint(
        'STORY VIDEO MOCK GENERATION SUCCESS',
      );

      return true;
    } catch (error, stackTrace) {
      debugPrint(
        'GENERATE STORY VIDEO ERROR: $error',
      );

      debugPrintStack(
        stackTrace: stackTrace,
      );

      errorMessage =
          'Unable to generate trip story. Please try again.';

      return false;
    } finally {
      isGeneratingVideo = false;
      notifyListeners();

      debugPrint(
        '==========================================',
      );
    }
  }


  Future<bool> shareToPlatform(
    StorySharePlatform platform,
  ) async {
    if (isProcessing) {
      return false;
    }

    debugPrint(
      '========== SHARE STORY ==========',
    );

    debugPrint(
      'Platform: ${getPlatformName(platform)}',
    );

    isOpeningPlatform = true;
    errorMessage = null;
    notifyListeners();

    try {
      /*
       * TEMP MOCK
       *
       * TODO:
       * ภายหลัง:
       *
       * 1. เช็กว่า application เปิดได้หรือไม่
       * 2. ส่ง generated video ไปยัง application
       * 3. เปิด sharing interface
       */

      await Future<void>.delayed(
        const Duration(milliseconds: 400),
      );

      debugPrint(
        'OPEN ${getPlatformName(platform)} MOCK SUCCESS',
      );

      return true;
    } catch (error, stackTrace) {
      debugPrint(
        'OPEN SHARE PLATFORM ERROR: $error',
      );

      debugPrintStack(
        stackTrace: stackTrace,
      );
      errorMessage =
          'Unable to open the selected application. Please try again.';

      return false;
    } finally {
      isOpeningPlatform = false;
      notifyListeners();

      debugPrint(
        '=================================',
      );
    }
  }

  String getPlatformName(
    StorySharePlatform platform,
  ) {
    switch (platform) {
      case StorySharePlatform.instagram:
        return 'Instagram';

      case StorySharePlatform.facebook:
        return 'Facebook';
    }
  }

  IconData getPlatformIcon(
    StorySharePlatform platform,
  ) {
    switch (platform) {
      case StorySharePlatform.instagram:
        return Icons.camera_alt_rounded;

      case StorySharePlatform.facebook:
        return Icons.facebook_rounded;
    }
  }

  void clearError() {
    errorMessage = null;
    notifyListeners();
  }
}