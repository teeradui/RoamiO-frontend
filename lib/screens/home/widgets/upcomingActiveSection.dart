import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:roamio_frontend/screens/tripDetail/tripDetailScreen.dart';
import 'package:roamio_frontend/theme/colors.dart';
import 'package:roamio_frontend/viewmodels/tripCardViewmodel.dart';
import 'package:roamio_frontend/widgets/tripCard.dart';

class UpcomingActiveSection extends StatelessWidget {
  const UpcomingActiveSection({
    super.key,
    required this.trips,
  });

  final List<TripCardViewModel> trips;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: AppColors.gradientUpAc,
              ).createShader(bounds),
              child: const FaIcon(
                FontAwesomeIcons.locationArrow,
                size: 20,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              "Upcoming & Active",
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
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => TripDetailScreen(tripId: trip.tripId),
                    ),
                  );
                },
              );
            }).toList(),
          )
        else
          const _UpcomingActiveEmptyState(),
      ],
    );
  }
}

class _UpcomingActiveEmptyState extends StatelessWidget {
  const _UpcomingActiveEmptyState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Column(
          children: [
            HugeIcon(
              icon: HugeIcons.strokeRoundedAddCircle,
              size: 40,
              color: AppColors.tabInactive,
            ),
            SizedBox(height: 8),
            Text(
              "Add your new trip",
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