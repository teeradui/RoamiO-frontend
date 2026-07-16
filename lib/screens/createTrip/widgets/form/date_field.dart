import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:roamio_frontend/theme/colors.dart';

class DateField extends StatelessWidget {
  const DateField({
    super.key,
    required this.hint,
    this.firstDate,
    this.selectedDate,
    this.onChanged,
  });

  final String hint;
  final DateTime? firstDate;
  final DateTime? selectedDate;
  final ValueChanged<DateTime>? onChanged;

  DateTime get today {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  @override
  Widget build(BuildContext context) {
    final DateTime minimumDate = firstDate ?? today;

    final DateTime initialPickerDate =
        selectedDate != null && !selectedDate!.isBefore(minimumDate)
            ? selectedDate!
            : minimumDate;

    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: initialPickerDate,
          firstDate: minimumDate,
          lastDate: DateTime(2100),
          initialEntryMode: DatePickerEntryMode.calendarOnly,
          switchToInputEntryModeIcon: const Icon(
            Icons.close,
            size: 0,
          ),
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: const ColorScheme.light(
                  primary: AppColors.btnPrimary,
                  onPrimary: Colors.white,
                  surface: AppColors.bgCard,
                  onSurface: AppColors.textPrimary,
                ),
                dialogTheme: const DialogThemeData(
                  backgroundColor: AppColors.bgCard,
                ),
                textButtonTheme: TextButtonThemeData(
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.btnPrimary,
                  ),
                ),
              ),
              child: child!,
            );
          },
        );

        if (picked != null) {
          onChanged?.call(picked);
        }
      },
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
              Icons.calendar_today_outlined,
              size: 20,
              color: AppColors.tabInactive,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                selectedDate == null
                    ? hint
                    : DateFormat("dd MMM yyyy").format(selectedDate!),
                style: TextStyle(
                  color: selectedDate == null
                      ? AppColors.tabInactive
                      : AppColors.textPrimary,
                ),
              ),
            ),
            const Icon(
              Icons.keyboard_arrow_down,
              color: AppColors.tabInactive,
            ),
          ],
        ),
      ),
    );
  }
}