import 'package:flutter/material.dart';
import 'package:roamio_frontend/theme/colors.dart';
import 'package:flutter/cupertino.dart';

class TimeField extends StatefulWidget {
  const TimeField({super.key, this.hint = "Start Time", this.onChanged});

  final String hint;
  final ValueChanged<TimeOfDay>? onChanged;

  @override
  State<TimeField> createState() => _TimeFieldState();
}

class _TimeFieldState extends State<TimeField> {
  TimeOfDay? selectedTime;
  String formatTime12Hour(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';

    return '$hour:$minute $period';
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () async {
        DateTime tempDateTime = DateTime(
          2025,
          1,
          1,
          selectedTime?.hour ?? TimeOfDay.now().hour,
          selectedTime?.minute ?? TimeOfDay.now().minute,
        );

        await showModalBottomSheet(
          context: context,
          backgroundColor: AppColors.bgCard,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          builder: (context) {
            return SizedBox(
              height: 320,
              child: Column(
                children: [
                  const SizedBox(height: 12),

                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade400,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    "Select Time",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),

                  Expanded(
                    child: CupertinoDatePicker(
                      mode: CupertinoDatePickerMode.time,
                      use24hFormat: false,
                      initialDateTime: tempDateTime,
                      onDateTimeChanged: (value) {
                        tempDateTime = value;
                      },
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.btnPrimary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onPressed: () {
                          final picked = TimeOfDay(
                            hour: tempDateTime.hour,
                            minute: tempDateTime.minute,
                          );

                          setState(() {
                            selectedTime = picked;
                          });

                          widget.onChanged?.call(picked);

                          Navigator.pop(context);
                        },
                        child: const Text("Done"),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
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
              Icons.access_time,
              size: 20,
              color: AppColors.tabInactive,
            ),

            const SizedBox(width: 10),

            Expanded(
              child: Text(
                selectedTime == null
                    ? widget.hint
                    : formatTime12Hour(selectedTime!),
                style: TextStyle(
                  color: selectedTime == null
                      ? AppColors.tabInactive
                      : AppColors.textPrimary,
                ),
              ),
            ),

            const Icon(Icons.keyboard_arrow_down, color: AppColors.tabInactive),
          ],
        ),
      ),
    );
  }
}
