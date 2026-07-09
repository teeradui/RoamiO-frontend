import 'package:flutter/material.dart';
import 'package:roamio_frontend/screens/createTrip/widgets/form/countryField.dart';
import 'package:roamio_frontend/screens/createTrip/widgets/form/dateField.dart';
import 'package:roamio_frontend/screens/createTrip/widgets/form/meetingPointField.dart';
import 'package:roamio_frontend/screens/createTrip/widgets/form/photoPicker.dart';
import 'package:roamio_frontend/screens/createTrip/widgets/form/stateField.dart';
import 'package:roamio_frontend/screens/createTrip/widgets/form/timeField.dart';
import 'package:roamio_frontend/theme/colors.dart';
import 'package:roamio_frontend/viewmodels/createTripViewmodel.dart';
import 'package:roamio_frontend/viewmodels/editTripViewmodel.dart';

class EditTripScreen extends StatefulWidget {
  const EditTripScreen({super.key});

  @override
  State<EditTripScreen> createState() => _EditTripScreenState();
}

class _EditTripScreenState extends State<EditTripScreen> {
  final EditTripViewModel viewModel = EditTripViewModel();

  @override
  void initState() {
    super.initState();
    viewModel.loadInitialData();
  }

  @override
  void dispose() {
    viewModel.dispose();
    super.dispose();
  }

  CreateTripViewModel get formViewModel {
    final vm = CreateTripViewModel();

    vm.countries = viewModel.countries;
    vm.states = viewModel.states;
    vm.selectedCountry = viewModel.selectedCountry;
    vm.selectedState = viewModel.selectedState;

    return vm;
  }

  Future<void> save() async {
    final success = await viewModel.saveChanges();

    if (success && mounted) {
      Navigator.pop(context);
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
                        const PhotoPicker(),

                        const SizedBox(height: 20),

                        _Label(title: "Trip Name", required: true),

                        const SizedBox(height: 8),

                        _TextInput(
                          initialValue: viewModel.tripName,
                          hint: "Enter trip name",
                          onChanged: viewModel.setTripName,
                        ),

                        const SizedBox(height: 20),

                        _Label(title: "Trip Destination", required: true),

                        const SizedBox(height: 8),

                        const Row(
                          children: [
                            Expanded(
                              child: _SmallLabel(title: "Country"),
                            ),
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

                        Row(
                          children: [
                            Expanded(
                              child: CountryField(
                                viewModel: formViewModel,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: StateField(
                                viewModel: formViewModel,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        _Label(title: "Trip Date", required: true),

                        const SizedBox(height: 8),

                        Row(
                          children: [
                            Expanded(
                              child: DateField(
                                hint: "Start Date",
                                onChanged: viewModel.setStartDate,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: DateField(
                                key: ValueKey(viewModel.startDate),
                                hint: "End Date",
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
                          onChanged: viewModel.setStartTime,
                        ),

                        const SizedBox(height: 20),

                        _Label(title: "Meeting Point", optional: true),

                        const SizedBox(height: 8),

                        const MeetingPointField(),

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
  const _SmallLabel({
    required this.title,
    this.optional = false,
  });

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
    required this.initialValue,
    required this.hint,
    required this.onChanged,
  });

  final String initialValue;
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
        initialValue: initialValue,
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