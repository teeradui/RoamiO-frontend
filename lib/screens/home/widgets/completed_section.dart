import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:roamio_frontend/screens/tripDetail/trip_detail_screen.dart';
import 'package:roamio_frontend/theme/colors.dart';
import 'package:roamio_frontend/viewmodels/trip_card_view_model.dart';
import 'package:roamio_frontend/widgets/trip_card.dart';

class CompletedSection extends StatelessWidget {
  const CompletedSection({
    super.key,
    required this.trips,
    required this.onTripTap,
  });

  final List<TripCardViewModel> trips;
  final ValueChanged<String> onTripTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: AppColors.gradientMap,
              ).createShader(bounds),
              child: const FaIcon(
                FontAwesomeIcons.route,
                size: 20,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              "History",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),

        const SizedBox(height: 10),

        if (trips.isNotEmpty)
          Column(
            children: trips.map((trip) {
              return TripCard(
                viewModel: trip,
                onTap: () => onTripTap(trip.tripId),
              );
            }).toList(),
          )
        else
          const _CompletedEmptyState(),
      ],
    );
  }
}

class _CompletedEmptyState extends StatelessWidget {
  const _CompletedEmptyState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 40),
        child: Column(
          children: [
            HugeIcon(
              icon: HugeIcons.strokeRoundedCrying,
              size: 40,
              color: AppColors.tabInactive,
            ),
            SizedBox(height: 8),
            Text(
              "No trip history available",
              style: TextStyle(
                color: AppColors.tabInactive,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}