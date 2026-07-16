import 'package:flutter/material.dart';
import 'package:roamio_frontend/theme/colors.dart';
import 'package:roamio_frontend/viewmodels/trip_detail_view_model.dart';

class TripDetailSectionTab extends StatelessWidget {
  const TripDetailSectionTab({
    super.key,
    required this.viewModel,
  });

  final TripDetailViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 45,
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.bgAccent,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          _TabItem(
            title: "Overview",
            active: viewModel.isSelectedSection(TripDetailSection.overview),
            onTap: () => viewModel.selectSection(TripDetailSection.overview),
          ),
          _TabItem(
            title: "Map",
            active: viewModel.isSelectedSection(TripDetailSection.map),
            onTap: () => viewModel.selectSection(TripDetailSection.map),
          ),
          _TabItem(
            title: "Activities",
            active: viewModel.isSelectedSection(TripDetailSection.activities),
            onTap: () => viewModel.selectSection(TripDetailSection.activities),
          ),
          _TabItem(
            title: "Photo",
            active: viewModel.isSelectedSection(TripDetailSection.photo),
            onTap: () => viewModel.selectSection(TripDetailSection.photo),
          ),
          _TabItem(
            title: "Member",
            active: viewModel.isSelectedSection(TripDetailSection.member),
            onTap: () => viewModel.selectSection(TripDetailSection.member),
          ),
        ],
      ),
    );
  }
}

class _TabItem extends StatelessWidget {
  const _TabItem({
    required this.title,
    required this.active,
    required this.onTap,
  });

  final String title;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: active ? AppColors.bgHighlight : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: active ? AppColors.textSecondary : AppColors.textMuted,
              fontSize: 12,
              fontWeight: active ? FontWeight.w700 : FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}