import 'package:flutter/material.dart';
import 'package:roamio_frontend/theme/colors.dart';

class FriendTabSelector extends StatelessWidget {
  const FriendTabSelector({
    super.key,
    required this.selectedIndex,
    required this.onChanged,
  });

  final int selectedIndex;
  final ValueChanged<int> onChanged;

  static const List<String> _tabs = [
    'My Friends',
    'Request',
    'Recommend',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.filterInactiveBg,
        borderRadius: BorderRadius.circular(14),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final tabWidth = constraints.maxWidth / _tabs.length;

          return Stack(
            children: [
              AnimatedPositioned(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                left: selectedIndex * tabWidth,
                top: 0,
                bottom: 0,
                width: tabWidth,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.filterActiveBg,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),

              Row(
                children: List.generate(
                  _tabs.length,
                  (index) {
                    return Expanded(
                      child: _buildTab(
                        title: _tabs[index],
                        selected: selectedIndex == index,
                        onTap: () => onChanged(index),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTab({
    required String title,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Center(
        child: AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 200),
          style: TextStyle(
            color: selected
                ? AppColors.filterActiveText
                : AppColors.filterInactiveText,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
          child: Text(title),
        ),
      ),
    );
  }
}