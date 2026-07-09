import 'package:flutter/material.dart';
import 'package:roamio_frontend/theme/colors.dart';
import 'package:roamio_frontend/viewmodels/overviewSectionViewmodel.dart';

class OverviewSection extends StatefulWidget {
  const OverviewSection({super.key});

  @override
  State<OverviewSection> createState() => _OverviewSectionState();
}

class _OverviewSectionState extends State<OverviewSection> {
  final OverviewSectionViewModel viewModel = OverviewSectionViewModel();

  @override
  void dispose() {
    viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: viewModel,
      builder: (context, _) {
        return Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: _OverviewMiniCard(
                    icon: Icons.photo_camera_outlined,
                    count: viewModel.photosCount,
                    label: "Photos",
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _OverviewMiniCard(
                    icon: Icons.place_outlined,
                    count: viewModel.placesCount,
                    label: "Places",
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _OverviewMiniCard(
                    icon: Icons.navigation_outlined,
                    count: viewModel.activitiesCount,
                    label: "Activities",
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            if (viewModel.isEmpty) const _UpcomingEmptyOverview(),
          ],
        );
      },
    );
  }
}

class _OverviewMiniCard extends StatelessWidget {
  const _OverviewMiniCard({
    required this.icon,
    required this.count,
    required this.label,
  });

  final IconData icon;
  final int count;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 58,
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 18, color: AppColors.btnPrimary),
          const SizedBox(height: 4),
          Text(
            "$count",
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _UpcomingEmptyOverview extends StatelessWidget {
  const _UpcomingEmptyOverview();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 28),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: const Column(
        children: [
          Icon(
            Icons.explore_outlined,
            size: 40,
            color: AppColors.btnPrimary,
          ),
          SizedBox(height: 12),
          Text(
            "Your trip hasn’t started yet",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          SizedBox(height: 6),
          Text(
            "Photos, places, and activities will appear here automatically when the trip starts.",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}