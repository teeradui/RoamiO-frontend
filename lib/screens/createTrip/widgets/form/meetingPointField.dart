import 'package:flutter/material.dart';
import 'package:roamio_frontend/screens/createTrip/widgets/meetingPoint/meetingPointScreen.dart';
import 'package:roamio_frontend/theme/colors.dart';

class MeetingPointField extends StatefulWidget {
  const MeetingPointField({super.key});

  @override
  State<MeetingPointField> createState() => _MeetingPointFieldState();
}

class _MeetingPointFieldState extends State<MeetingPointField> {
  String? meetingPoint;

  Future<void> openMeetingPointScreen() async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const MeetingPointScreen(),
      ),
    );

    if (result != null) {
      setState(() {
        meetingPoint = result["name"];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: openMeetingPointScreen,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: .04),
              blurRadius: 5,
              offset: const Offset(0,4),
            ),
          ],
        ),
        child: Row(
          children: [
            const Icon(
              Icons.location_on_outlined,
              color: AppColors.tabInactive,
              size: 20,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                meetingPoint ?? "Select meeting point",
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: meetingPoint == null
                      ? AppColors.tabInactive
                      : AppColors.textPrimary,
                ),
              ),
            ),
            const Icon(
              Icons.keyboard_arrow_right,
              color: AppColors.tabInactive,
            ),
          ],
        ),
      ),
    );
  }
}