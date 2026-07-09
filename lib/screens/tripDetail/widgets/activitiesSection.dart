import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:roamio_frontend/theme/colors.dart';
import 'package:roamio_frontend/viewmodels/activitiesSectionViewmodel.dart';

class ActivitiesSection extends StatelessWidget {
  ActivitiesSection({super.key});

  final ActivitiesSectionViewModel viewModel =
      ActivitiesSectionViewModel();

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: viewModel,
      builder: (context, _) {
        if (!viewModel.hasActivities) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 48),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [

                  FaIcon(FontAwesomeIcons.satelliteDish, size: 36, color: AppColors.textDisabled),

                  const SizedBox(height: 10),

                  const Text(
                    "No activities yet",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDisabled,
                    ),
                  ),

                  const SizedBox(height: 8),

                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      "Your activities will automatically appear here once your trip starts.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textDisabled,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: viewModel.activities.length,
          itemBuilder: (context, index) {
            return const SizedBox();
          },
        );
      },
    );
  }
}