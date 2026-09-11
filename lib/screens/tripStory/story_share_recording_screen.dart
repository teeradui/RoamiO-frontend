import 'package:flutter/material.dart';
import 'package:widget_recorder_plus/widget_recorder_plus.dart';

import 'package:roamio_frontend/theme/colors.dart';
import 'package:roamio_frontend/viewmodels/story_slide_view_model.dart';
import 'package:roamio_frontend/screens/tripStory/widgets/story_slide_body.dart';

class StoryShareRecordingScreen extends StatefulWidget {
  const StoryShareRecordingScreen({
    super.key,
    required this.tripId,
    required this.slide,
  });

  final String tripId;
  final StorySlideItem slide;

  @override
  State<StoryShareRecordingScreen> createState() =>
      _StoryShareRecordingScreenState();
}

class _StoryShareRecordingScreenState
    extends State<StoryShareRecordingScreen> {
  late final WidgetRecorderController _recorderController;

  bool _isRecording = false;

  int _animationVersion = 0;

  @override
  void initState() {
    super.initState();

    _recorderController = WidgetRecorderController(
      recordAudio: false,
      onComplete: (path) {
        debugPrint(
          'STORY VIDEO GENERATED: $path',
        );
      },
      onError: (error) {
        debugPrint(
          'STORY VIDEO ERROR: $error',
        );
      },
    );

    _recorderController.applyVideoQuality(
      VideoQuality.medium,
    );

    WidgetsBinding.instance.addPostFrameCallback(
      (_) {
        _generateVideo();
      },
    );
  }

  Future<void> _generateVideo() async {
    if (_isRecording) {
      return;
    }

    setState(() {
      _isRecording = true;
    });

    try {
      await _recorderController.start();

      if (!mounted) {
        return;
      }

      // สร้าง Story slide ใหม่หลัง recorder เริ่มแล้ว
      // เพื่อให้ animation เริ่มตั้งแต่ต้นจริง
      setState(() {
        _animationVersion++;
      });

      // อัด animation ของ slide เดียว 5 วินาที
      await Future.delayed(
        const Duration(seconds: 5),
      );

      final videoPath =
          await _recorderController.stop();

      if (!mounted) {
        return;
      }

      if (videoPath == null ||
          videoPath.isEmpty) {
        Navigator.pop<String?>(
          context,
          null,
        );

        return;
      }

      debugPrint(
        'GENERATED VIDEO PATH: $videoPath',
      );

      Navigator.pop<String>(
        context,
        videoPath,
      );
    } catch (error) {
      debugPrint(
        'GENERATE STORY VIDEO FAILED: $error',
      );

      if (!mounted) {
        return;
      }

      Navigator.pop<String?>(
        context,
        null,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(
            child: WidgetRecorder(
              controller: _recorderController,
              child: StorySlideBody(
                key: ValueKey(
                  '${widget.slide.type}-'
                  '$_animationVersion',
                ),
                slide: widget.slide,
                tripId: widget.tripId,

                // เราไม่ได้เลือก Ending มาใช้งาน action
                // ระหว่าง recording
                onDone: () {},

                onShare: () async {},
              ),
            ),
          ),

          // ตัวนี้อยู่นอก WidgetRecorder
          // เพราะฉะนั้นจะไม่ติดเข้าไปใน video
          Positioned.fill(
            child: Container(
              color: Colors.black,
              alignment: Alignment.center,
              child: const Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(
                    color: AppColors.btnPrimary,
                  ),
                  SizedBox(height: 18),
                  Text(
                    'Preparing your story...',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}