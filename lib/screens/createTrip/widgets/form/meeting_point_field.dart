import 'package:flutter/material.dart';
import 'package:roamio_frontend/screens/createTrip/widgets/meetingPoint/meeting_point_screen.dart';
import 'package:roamio_frontend/theme/colors.dart';

class MeetingPointField extends StatelessWidget {
  const MeetingPointField({
    super.key,
    this.value,
    this.onChanged,
  });

  final Map<String, dynamic>? value;
  final ValueChanged<Map<String, dynamic>?>? onChanged;

  Future<void> _openMeetingPointScreen(BuildContext context) async {
    final result = await Navigator.of(context).push<Map<String, dynamic>>(
      MaterialPageRoute(
        builder: (_) => const MeetingPointScreen(),
      ),
    );

    if (result == null) return;

    onChanged?.call(result);
  }

  @override
  Widget build(BuildContext context) {
    final meetingPointName =
        value?['name']?.toString() ??
        value?['address']?.toString();

    return InkWell(
      onTap: () => _openMeetingPointScreen(context),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 16,
        ),
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: .04),
              blurRadius: 5,
              offset: const Offset(0, 4),
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
                meetingPointName ?? "Select meeting point",
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: meetingPointName == null
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