import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:roamio_frontend/theme/colors.dart';

class RoamiOBottomNavBar extends StatelessWidget {
  const RoamiOBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.bgPrimary, // ลบสีม่วงรอบ Navbar
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        child: Container(
          height: 78,
          padding: const EdgeInsets.symmetric(horizontal: 6),
          decoration: BoxDecoration(
            color: AppColors.bgPrimary,
            borderRadius: BorderRadius.circular(50),
            border: Border.all(
              color: AppColors.textSecondary.withValues(alpha: 0.08),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 20,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              _buildItem(
                icon: HugeIcons.strokeRoundedHome07,
                label: 'Home',
                index: 0,
              ),
              _buildItem(
                icon: HugeIcons.strokeRoundedChampion,
                label: 'Leaderboard',
                index: 1,
              ),
              _buildItem(
                icon: HugeIcons.strokeRoundedAddCircle,
                label: 'Create Trip',
                index: 2,
              ),
              _buildItem(
                icon: HugeIcons.strokeRoundedUserGroup,
                label: 'Friends',
                index: 3,
              ),
              _buildItem(
                icon: HugeIcons.strokeRoundedUserCircle,
                label: 'Profile',
                index: 4,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildItem({
    required dynamic icon,
    required String label,
    required int index,
  }) {
    final isSelected = currentIndex == index;

    return Expanded(
      flex: isSelected ? 2 : 1,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => onTap(index),
        child: Center(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeOutBack,
            width: isSelected ? 78 : 48,
            height: 62,
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.tabActive.withValues(alpha: 0.12)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedScale(
                  scale: isSelected ? 1.08 : 1.0,
                  duration: const Duration(milliseconds: 350),
                  curve: Curves.easeOutBack,
                  child: HugeIcon(
                    icon: icon,
                    size: isSelected ? 23 : 22,
                    color: isSelected
                        ? AppColors.tabActive
                        : AppColors.tabInactive,
                  ),
                ),

                // Label อยู่ใต้ Icon
                AnimatedSize(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOutBack,
                  child: isSelected
                      ? TweenAnimationBuilder<double>(
                          tween: Tween<double>(begin: 0, end: 1),
                          duration: const Duration(milliseconds: 350),
                          curve: Curves.easeOutBack,
                          builder: (context, value, child) {
                            return Transform.translate(
                              offset: Offset(
                                0,
                                7 * (1 - value),
                              ),
                              child: Opacity(
                                opacity: value.clamp(0.0, 1.0),
                                child: child,
                              ),
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.only(top: 3),
                            child: Text(
                              label,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                height: 1,
                                color: AppColors.tabActive,
                              ),
                            ),
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}