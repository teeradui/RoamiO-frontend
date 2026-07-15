import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:roamio_frontend/screens/createTrip/widgets/form/meetingPointField.dart';
import 'package:roamio_frontend/viewmodels/createTripViewmodel.dart';
import 'package:roamio_frontend/screens/createTrip/widgets/form/countryField.dart';
import 'package:roamio_frontend/screens/createTrip/widgets/form/stateField.dart';
import 'package:roamio_frontend/screens/createTrip/widgets/form/dateField.dart';
import 'package:roamio_frontend/screens/createTrip/widgets/form/timeField.dart';
import 'package:roamio_frontend/screens/createTrip/widgets/form/photoPicker.dart';
import 'package:roamio_frontend/theme/colors.dart';

class Step1TripInfo extends StatefulWidget {
  const Step1TripInfo({super.key, required this.onNext});

  final VoidCallback onNext;

  @override
  _Step1TripInfoState createState() => _Step1TripInfoState();
}

class _Step1TripInfoState extends State<Step1TripInfo> {
  DateTime? startDate;
  DateTime? endDate;
  TimeOfDay? startTime;

  bool _countriesLoaded = false;
 
  void _handleNext(CreateTripViewModel viewModel) {
    if (viewModel.isStep1Valid) {
      widget.onNext();
    }
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

    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const PhotoPicker(),

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
              onChanged: viewModel.setTripName,
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
                  onChanged: (date) {
                    setState(() {
                      startDate = date;
                    });
                    viewModel.setStartDate(date);
                  },
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: DateField(
                  key: ValueKey(startDate),
                  hint: "End Date",
                  firstDate: startDate,
                  onChanged: (date) {
                    viewModel.setEndDate(date);
                  },
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
            onChanged: (time) {
              viewModel.setStartTime(time);
            },
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
          const MeetingPointField(),

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
