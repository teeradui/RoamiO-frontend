import 'package:flutter/material.dart';
import 'package:roamio_frontend/theme/colors.dart';
import 'package:roamio_frontend/viewmodels/home_view_model.dart';

class TripFilterBar extends StatelessWidget {
  const TripFilterBar({
    super.key,
    required this.selectedFilter,
    required this.onChanged,
  });

  final TripFilter selectedFilter;
  final ValueChanged<TripFilter> onChanged;

  @override
  Widget build(BuildContext context) {
    final filters = {
      TripFilter.all: "All",
      TripFilter.upcoming: "Upcoming",
      TripFilter.active: "Active",
      TripFilter.completed: "Completed",
    };

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: filters.entries.map((entry) {
          final isSelected = selectedFilter == entry.key;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => onChanged(entry.key),
              child: Container(
                width: 100,
                padding: const EdgeInsets.symmetric(vertical: 10),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.filterActiveBg
                      : AppColors.filterInactiveBg,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  entry.value,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                    color: isSelected
                        ? AppColors.filterActiveText
                        : AppColors.filterInactiveText,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}