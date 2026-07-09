import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:roamio_frontend/screens/editTrip/editTripScreen.dart';
import 'package:roamio_frontend/screens/tripDetail/widgets/activitiesSection.dart';
import 'package:roamio_frontend/screens/tripDetail/widgets/mapSection.dart';
import 'package:roamio_frontend/screens/tripDetail/widgets/memberSection.dart';
import 'package:roamio_frontend/screens/tripDetail/widgets/overviewSection.dart';
import 'package:roamio_frontend/screens/tripDetail/widgets/photoSection.dart';
import 'package:roamio_frontend/theme/colors.dart';
import 'package:roamio_frontend/viewmodels/tripDetailViewmodel.dart';
import 'package:roamio_frontend/screens/tripDetail/widgets/sectionTab.dart';

class TripDetailScreen extends StatefulWidget {
  const TripDetailScreen({super.key});

  @override
  State<TripDetailScreen> createState() => _TripDetailScreenState();
}

class _TripDetailScreenState extends State<TripDetailScreen> {
  final TripDetailViewModel viewModel = TripDetailViewModel();

  @override
  void dispose() {
    viewModel.dispose();
    super.dispose();
  }

  Widget _buildSelectedSection() {
    switch (viewModel.selectedSection) {
      case TripDetailSection.overview:
        return OverviewSection();
      case TripDetailSection.map:
        return MapSection();
      case TripDetailSection.activities:
        return ActivitiesSection();
      case TripDetailSection.photo:
        return PhotoSection();
      case TripDetailSection.member:
        return MemberSection();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: viewModel,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: AppColors.bgPrimary,
          body: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(
                          Icons.arrow_back_ios_new,
                          color: AppColors.textPrimary,
                        ),
                      ),

                      const Expanded(
                        child: Text(
                          "Trip Detail",
                          textAlign: TextAlign.justify,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),

                      const Spacer(),

                      viewModel.isActive
                          ? InkWell(
                              onTap: viewModel.endTrip,
                              borderRadius: BorderRadius.circular(100),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 18,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(
                                    0xFFFF6666,
                                  ).withValues(alpha: 0.26),
                                  borderRadius: BorderRadius.circular(100),
                                ),
                                child: const Text(
                                  "End Trip",
                                  style: TextStyle(
                                    color: AppColors.red,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            )
                          : InkWell(
                              onTap: viewModel.deleteTrip,
                              borderRadius: BorderRadius.circular(99),
                              child: Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: const Color(
                                    0xFFFF6666,
                                  ).withValues(alpha: 0.26),
                                ),
                                child: const Center(
                                  child: HugeIcon(
                                    icon: HugeIcons.strokeRoundedDelete02,
                                    color: AppColors.red,
                                    size: 18,
                                  ),
                                ),
                              ),
                            ),
                    ],
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.bgCard,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: .04),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Center(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(20),
                                  child: Container(
                                    height: 120,
                                    width: 120,
                                    color: AppColors.bgAccent,
                                    child: const Icon(
                                      Icons.image_outlined,
                                      size: 48,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 1),

                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    viewModel.tripName,
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () async {
                                      await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              const EditTripScreen(),
                                        ),
                                      );

                                      // TODO: ตอนเชื่อม backend ค่อย reload trip detail ตรงนี้
                                      // viewModel.loadTrip();
                                    },
                                    icon: const HugeIcon(
                                      icon: HugeIcons.strokeRoundedPencilEdit01,
                                      color: AppColors.iconOrange,
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 2),

                              Text(
                                viewModel.destination,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),

                              const SizedBox(height: 10),

                              Center(
                                child: _InfoRow(
                                  icon: viewModel.statusIcon,
                                  iconColor: viewModel.statusColor,
                                  text: viewModel.statusText,
                                  textColor: viewModel.statusColor,
                                  backgroundColor:
                                      viewModel.statusBackgroundColor,
                                ),
                              ),

                              const SizedBox(height: 8),

                              Center(
                                child: _InfoRow(
                                  icon: Icons.calendar_today_outlined,
                                  text:
                                      "${viewModel.startDate} — ${viewModel.endDate}",
                                ),
                              ),

                              const SizedBox(height: 2),

                              Center(
                                child: _InfoRow(
                                  icon: Icons.location_on_outlined,
                                  text: viewModel.meetingPointText,
                                ),
                              ),

                              const SizedBox(height: 10),

                              Container(
                                width: double.infinity,
                                height: 60,
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: AppColors.bgAccent,
                                  borderRadius: BorderRadius.circular(18),
                                ),
                                child: Row(
                                  children: [
                                    const HugeIcon(
                                      icon: HugeIcons.strokeRoundedRoute03,
                                      color: AppColors.iconOrange,
                                    ),

                                    const SizedBox(width: 12),
                                    const Text(
                                      "Travel Distance",
                                      style: TextStyle(
                                        color: AppColors.textSecondary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const Spacer(),
                                    Text(
                                      "${viewModel.distanceKm.toStringAsFixed(1)} km",
                                      style: const TextStyle(
                                        color: AppColors.textPrimary,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 10),

                              Center(
                                child: SizedBox(
                                  height: 56,
                                  width:
                                      48 + (viewModel.members.length - 1) * 30,
                                  child: Stack(
                                    children: List.generate(
                                      viewModel.members.length,
                                      (index) {
                                        final member = viewModel.members[index];

                                        return Positioned(
                                          left: index * 30.0,
                                          child: Container(
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                color: AppColors.bgCard,
                                                width: 3,
                                              ),
                                            ),
                                            child: CircleAvatar(
                                              radius: 24,
                                              backgroundColor:
                                                  AppColors.bgAccent,
                                              backgroundImage:
                                                  member.imageUrl != null
                                                  ? NetworkImage(
                                                      member.imageUrl!,
                                                    )
                                                  : null,
                                              child: member.imageUrl == null
                                                  ? const Icon(
                                                      Icons.person,
                                                      color: AppColors
                                                          .textSecondary,
                                                    )
                                                  : null,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        TripDetailSectionTab(viewModel: viewModel),

                        const SizedBox(height: 18),

                        _buildSelectedSection(),
                      ],
                      
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.text,
    this.iconColor = AppColors.textSecondary,
    this.textColor = AppColors.textSecondary,
    this.backgroundColor,
  });

  final dynamic icon;
  final String text;
  final Color iconColor;
  final Color textColor;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          icon is IconData
              ? Icon(icon, size: 18, color: iconColor)
              : HugeIcon(icon: icon, size: 18, color: iconColor),

          const SizedBox(width: 8),

          Text(
            text,
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
