import 'package:flutter/material.dart';
import 'package:roamio_frontend/screens/createTrip/widgets/form/country_field.dart';
import 'package:roamio_frontend/screens/createTrip/widgets/form/date_field.dart';
import 'package:roamio_frontend/screens/createTrip/widgets/form/meeting_point_field.dart';
import 'package:roamio_frontend/screens/createTrip/widgets/form/photo_picker.dart';
import 'package:roamio_frontend/screens/createTrip/widgets/form/state_field.dart';
import 'package:roamio_frontend/screens/createTrip/widgets/form/time_field.dart';
import 'package:roamio_frontend/theme/colors.dart';
import 'package:roamio_frontend/viewmodels/create_trip_view_model.dart';
import 'package:roamio_frontend/viewmodels/edit_trip_view_model.dart';

class EditTripScreen extends StatefulWidget {
  const EditTripScreen({super.key, required this.tripId});

  final String tripId;

  @override
  State<EditTripScreen> createState() => _EditTripScreenState();
}

class _EditTripScreenState extends State<EditTripScreen> {
  late final EditTripViewModel viewModel = EditTripViewModel(
    tripId: widget.tripId,
  );

  late final CreateTripViewModel formViewModel = CreateTripViewModel();

  late final TextEditingController _tripNameController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    viewModel.loadInitialData();
    viewModel.addListener(_syncFromViewModel);
  }

  void _syncFromViewModel() {
    formViewModel.countries = viewModel.countries;
    formViewModel.states = viewModel.states;
    formViewModel.selectedCountry = viewModel.selectedCountry;
    formViewModel.selectedState = viewModel.selectedState;

    if (_tripNameController.text != viewModel.tripName) {
      _tripNameController.value = TextEditingValue(
        text: viewModel.tripName,
        selection: TextSelection.collapsed(offset: viewModel.tripName.length),
      );
    }

    formViewModel.notifyListeners();
  }

  @override
  void dispose() {
    viewModel.removeListener(_syncFromViewModel);
    _tripNameController.dispose();
    viewModel.dispose();
    formViewModel.dispose();
    super.dispose();
  }

  Future<void> save() async {
  debugPrint('========== SAVE CHANGES BUTTON ==========');
  debugPrint('tripId: ${widget.tripId}');
  debugPrint('canSave: ${viewModel.canSave}');
  debugPrint('isSaving: ${viewModel.isSaving}');
  debugPrint('tripName: ${viewModel.tripName}');
  debugPrint('country: ${viewModel.selectedCountry}');
  debugPrint('state: ${viewModel.selectedState}');
  debugPrint('startDate: ${viewModel.startDate}');
  debugPrint('endDate: ${viewModel.endDate}');
  debugPrint('startTime: ${viewModel.startTime}');
  debugPrint('meetingPoint: ${viewModel.meetingPoint}');
  debugPrint('=========================================');

  final success = await viewModel.saveChanges();

  debugPrint('SAVE CHANGES RESULT: $success');
  debugPrint('SAVE CHANGES ERROR: ${viewModel.errorMessage}');

  if (!mounted) return;

  if (success) {
    Navigator.pop(context, true);
  }
}

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: viewModel,
      builder: (context, _) {
        if (viewModel.isLoadingCountries) {
          return const Scaffold(
            backgroundColor: AppColors.bgPrimary,
            body: Center(
              child: CircularProgressIndicator(color: AppColors.btnPrimary),
            ),
          );
        }
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
                          "Edit Trip",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 48),
                    ],
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                    child: Column(
                      children: [
                        PhotoPicker(
                          initialImage: viewModel.tripPhoto,
                          initialImageUrl: viewModel.existingImageUrl,
                          onChanged: (image) {
                            viewModel.setTripPhoto(image);
                          },
                        ),

                        const SizedBox(height: 20),

                        _Label(title: "Trip Name", required: true),

                        const SizedBox(height: 8),

                        _TextInput(
                          controller: _tripNameController,
                          hint: "Enter trip name",
                          onChanged: viewModel.settripName,
                        ),

                        const SizedBox(height: 20),

                        _Label(title: "Trip Destination", required: true),

                        const SizedBox(height: 8),

                        const Row(
                          children: [
                            Expanded(child: _SmallLabel(title: "Country")),
                            SizedBox(width: 12),
                            Expanded(
                              child: _SmallLabel(
                                title: "State",
                                optional: true,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 8),

                        AnimatedBuilder(
                          animation: formViewModel,
                          builder: (context, _) {
                            return Row(
                              children: [
                                Expanded(
                                  child: CountryField(
                                    viewModel: formViewModel,
                                    onChanged: viewModel.selectCountry,
                                  ),
                                ),

                                const SizedBox(width: 12),

                                Expanded(
                                  child: StateField(
                                    viewModel: formViewModel,
                                    onChanged: viewModel.selectState,
                                  ),
                                ),
                              ],
                            );
                          },
                        ),

                        const SizedBox(height: 20),

                        _Label(title: "Trip Date", required: true),

                        const SizedBox(height: 8),

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
                                hint: "End Date",
                                selectedDate: viewModel.endDate,
                                firstDate: viewModel.startDate,
                                onChanged: viewModel.setEndDate,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        _Label(title: "Start Time", required: true),

                        const SizedBox(height: 8),

                        TimeField(
                          hint: "Select Time",
                          selectedTime: viewModel.startTime,
                          onChanged: viewModel.setStartTime,
                        ),

                        const SizedBox(height: 20),

                        _Label(title: "Meeting Point", optional: true),

                        const SizedBox(height: 8),

                        MeetingPointField(
                          value: viewModel.meetingPoint,
                          onChanged: viewModel.setMeetingPoint,
                        ),

                        const SizedBox(height: 35),

                        SizedBox(
                          width: 200,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: viewModel.canSave && !viewModel.isSaving
                                ? save
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: viewModel.canSave
                                  ? AppColors.btnPrimary
                                  : AppColors.tabInactive,
                              disabledBackgroundColor: AppColors.tabInactive,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: Text(
                              viewModel.isSaving ? "Saving..." : "Save Changes",
                              style: const TextStyle(
                                fontSize: 16,
                                color: AppColors.bgPrimary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),
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

class _Label extends StatelessWidget {
  const _Label({
    required this.title,
    this.required = false,
    this.optional = false,
  });

  final String title;
  final bool required;
  final bool optional;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
          if (required) ...[
            const SizedBox(width: 4),
            const Text(
              "*",
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: AppColors.btnPrimary,
                fontSize: 14,
              ),
            ),
          ],
          if (optional) ...[
            const SizedBox(width: 4),
            const Text(
              "(Optional)",
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: AppColors.btnPrimary,
                fontSize: 11,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SmallLabel extends StatelessWidget {
  const _SmallLabel({required this.title, this.optional = false});

  final String title;
  final bool optional;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
            fontSize: 14,
          ),
        ),
        if (optional) ...[
          const SizedBox(width: 4),
          const Text(
            "(Optional)",
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: AppColors.btnPrimary,
              fontSize: 10,
            ),
          ),
        ],
      ],
    );
  }
}

class _TextInput extends StatelessWidget {
  const _TextInput({
    required this.controller,
    required this.hint,
    required this.onChanged,
  });

  final TextEditingController controller;
  final String hint;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
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
      child: TextFormField(
        controller: controller,
        onChanged: onChanged,
        style: const TextStyle(color: AppColors.textPrimary),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: AppColors.tabInactive),
          filled: true,
          fillColor: AppColors.bgCard,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppColors.bgCard),
          ),
          focusedBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(14)),
            borderSide: BorderSide(color: AppColors.textSecondary),
          ),
        ),
      ),
    );
  }
}
