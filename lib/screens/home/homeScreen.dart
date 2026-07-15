import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:roamio_frontend/screens/home/widgets/completedSection.dart';
import 'package:roamio_frontend/screens/home/widgets/header.dart';
import 'package:roamio_frontend/screens/home/widgets/tripFilterBar.dart';
import 'package:roamio_frontend/screens/home/widgets/upcomingActiveSection.dart';
import 'package:roamio_frontend/screens/tripDetail/tripDetailScreen.dart';
import 'package:roamio_frontend/theme/colors.dart';
import 'package:roamio_frontend/viewmodels/homeViewModel.dart';
import 'package:roamio_frontend/widgets/tripCard.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final HomeViewModel viewModel = HomeViewModel();

    @override
  void initState() {
    super.initState();
    viewModel.loadTrips();
  }

  @override
  void dispose() {
    viewModel.dispose();
    super.dispose();
  }

  void _openTripDetail(String tripId) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => TripDetailScreen(tripId: tripId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: SafeArea(
        child: AnimatedBuilder(
          animation: viewModel,
          builder: (context, _) {
            if (viewModel.isLoading && viewModel.trips.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const HomeHeader(),
                  const SizedBox(height: 16),

                  TripFilterBar(
                    selectedFilter: viewModel.selectedFilter,
                    onChanged: viewModel.changeFilter,
                  ),

                  const SizedBox(height: 24),

                  if (viewModel.selectedFilter == TripFilter.all) ...[
                    UpcomingActiveSection(trips: viewModel.upcomingActiveTrips),

                    const SizedBox(height: 24),

                    CompletedSection(trips: viewModel.completedTrips),
                  ] else ...[
                    if (viewModel.hasFilteredTrips)
                      Column(
                        children: viewModel.filteredTrips.map((trip) {
                          return TripCard(
                            viewModel: trip,
                            onTap: () => _openTripDetail(trip.tripId),
                          );
                        }).toList(),
                      )
                    else
                      viewModel.selectedFilter == TripFilter.completed
                          ? const _CompletedEmptyState()
                          : const _UpcomingActiveEmptyState(),
                  ],
                ],
              ),
            );
          },
        ),
      ),
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
