import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:roamio_frontend/screens/createTrip/widgets/form/meeting_point_field.dart';
import 'package:roamio_frontend/viewmodels/create_trip_view_model.dart';
import 'package:roamio_frontend/screens/createTrip/widgets/form/country_field.dart';
import 'package:roamio_frontend/screens/createTrip/widgets/form/state_field.dart';
import 'package:roamio_frontend/screens/createTrip/widgets/form/date_field.dart';
import 'package:roamio_frontend/screens/createTrip/widgets/form/time_field.dart';
import 'package:roamio_frontend/screens/createTrip/widgets/form/photo_picker.dart';
import 'package:roamio_frontend/theme/colors.dart';

class Step1TripInfo extends StatefulWidget {
  const Step1TripInfo({super.key, required this.onNext});

  final VoidCallback onNext;

  @override
  _Step1TripInfoState createState() => _Step1TripInfoState();
}

class _Step1TripInfoState extends State<Step1TripInfo> {
  bool _countriesLoaded = false;

  void _handleNext(CreateTripViewModel viewModel) {
    if (viewModel.isStep1Valid) {
      widget.onNext();
    }
  }

  late final TextEditingController tripNameController;

  @override
  void initState() {
    super.initState();

    final viewModel = context.read<CreateTripViewModel>();

    tripNameController = TextEditingController(text: viewModel.tripName);
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<CreateTripViewModel>();

    if (!_countriesLoaded) {
      _countriesLoaded = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        viewModel.loadCountries();
      });
    }

    @override
    void dispose() {
      tripNameController.dispose();
      super.dispose();
    }

    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          PhotoPicker(
            initialImage: viewModel.tripPhoto,
            onChanged: viewModel.setTripPhoto,
          ),

          const SizedBox(height: 20),

          /// Trip Name
          const Align(
            alignment: Alignment.centerLeft,
            child: Row(
              children: [
                Text(
                  "Trip Name",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                ),
                SizedBox(width: 1),
                Text(
                  "*",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.btnPrimary,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 5,
                  offset: const Offset(0, 4),
                ),
              ],
            ),

            child: TextField(
              controller: tripNameController,
              onChanged: viewModel.settripName,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: InputDecoration(
                hintText: "Enter trip name e.g. Japan Autumn Trip",

                hintStyle: const TextStyle(color: AppColors.tabInactive),

                filled: true,
                fillColor: AppColors.bgCard,

                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),

                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: AppColors.bgCard),
                ),

                focusedBorder: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(14)),
                  borderSide: BorderSide(color: AppColors.textSecondary),
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),

          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "Trip Destination",
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
          ),

          const SizedBox(height: 8),

          Column(
            children: [
              const Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Text(
                          "Country",
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                        SizedBox(width: 1),
                        Text(
                          "*",
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: AppColors.btnPrimary,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Row(
                      children: [
                        const Text(
                          "State",
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(width: 2),
                        Text(
                          "(Optional)",
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: AppColors.btnPrimary,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              AnimatedBuilder(
                animation: viewModel,
                builder: (context, _) {
                  return Row(
                    children: [
                      Expanded(child: CountryField(viewModel: viewModel)),
                      const SizedBox(width: 12),
                      Expanded(child: StateField(viewModel: viewModel)),
                    ],
                  );
                },
              ),
            ],
          ),

          const SizedBox(height: 20),

          const Align(
            alignment: Alignment.centerLeft,
            child: Row(
              children: [
                Text(
                  "Trip Date",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                ),
                SizedBox(width: 1),
                Text(
                  "*",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.btnPrimary,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          /// Date
          Row(
            children: [
              Expanded(
                child: DateField(
                  hint: "Start Date",
                  selectedDate: viewModel.startDate,
                  onChanged: viewModel.setStartDate,
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: DateField(
                  key: ValueKey(viewModel.startDate),
                  hint: "End Date",
                  selectedDate: viewModel.endDate,
                  firstDate: viewModel.startDate,
                  onChanged: viewModel.setEndDate,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          const Align(
            alignment: Alignment.centerLeft,
            child: Row(
              children: [
                Text(
                  "Start Time",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                ),
                SizedBox(width: 1),
                Text(
                  "*",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.btnPrimary,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          /// Time
          TimeField(
            hint: "Select Time",
            selectedTime: viewModel.startTime,
            onChanged: viewModel.setStartTime,
          ),

          const SizedBox(height: 20),

          const Align(
            alignment: Alignment.centerLeft,
            child: Row(
              children: [
                Text(
                  "Meeting Point",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(width: 2),
                Text(
                  "(Optional)",
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: AppColors.btnPrimary,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          /// Meeting Point
          MeetingPointField(
            value: viewModel.meetingPoint,
            onChanged: viewModel.setMeetingPoint,
          ),

          const SizedBox(height: 35),

          SizedBox(
            width: 180,
            height: 50,
            child: ElevatedButton(
              onPressed: viewModel.isStep1Valid
                  ? () => _handleNext(viewModel)
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: viewModel.isStep1Valid
                    ? AppColors.btnPrimary
                    : AppColors.tabInactive,
                disabledBackgroundColor: AppColors.tabInactive,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                "Next",
                style: TextStyle(fontSize: 17, color: AppColors.bgPrimary),
              ),
            ),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
