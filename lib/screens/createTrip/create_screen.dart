import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:roamio_frontend/screens/createTrip/widgets/form/trip_info.dart';
import 'package:roamio_frontend/screens/createTrip/widgets/invitefriend/invite_screen.dart';
import 'package:roamio_frontend/screens/createTrip/widgets/success/success_screen.dart';
import 'package:roamio_frontend/theme/colors.dart';
import 'package:roamio_frontend/viewmodels/create_trip_view_model.dart';

class CreateTripScreen extends StatelessWidget {
  const CreateTripScreen({super.key});

  @override
    Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CreateTripViewModel(),
      child: const _CreateTripScreenBody(),
    );
  }

}
class _CreateTripScreenBody extends StatefulWidget {
  const _CreateTripScreenBody();
 
  @override
  State<_CreateTripScreenBody> createState() => _CreateTripScreenBodyState();
}

class _CreateTripScreenBodyState extends State<_CreateTripScreenBody> {
  int currentStep = 0;

  void nextStep() {
    if (currentStep < 2) {
      setState(() {
        currentStep++;
      });
    }
  }

  void previousStep() {
    if (currentStep > 0) {
      setState(() {
        currentStep--;
      });
    }
  }

  Widget _buildStep() {
    final viewModel = context.watch<CreateTripViewModel>();
    
    switch (currentStep) {
      case 0:
        return Step1TripInfo(onNext: nextStep);
      case 1:
        return Step2InviteFriends(onNext: nextStep, onBack: previousStep);
      default:
        return Step3Success(
          onViewTrip: () {
            /* TODO: Navigator ไปหน้า Trip Detail*/
          },
        );
    }
  }

  Widget stepIndicator(int currentStep) {
    return SizedBox(
      height: 5,
      child: Row(
        children: [
          Expanded(child: _stepBar(currentStep == 0)),
          const SizedBox(width: 20),
          Expanded(child: _stepBar(currentStep == 1)),
          const SizedBox(width: 20),
          Expanded(child: _stepBar(currentStep == 2)),
        ],
      ),
    );
  }

  Widget _stepBar(bool active) {
    return Container(
      height: 5,
      decoration: BoxDecoration(
        color: active ? AppColors.btnPrimary : const Color(0xFFD9D9D9),
        borderRadius: BorderRadius.circular(2.5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              const SizedBox(height: 12),

              Row(
                children: [
                  if (currentStep == 1)
                    IconButton(
                      onPressed: previousStep,
                      icon: const Icon(Icons.arrow_back_ios_new),
                    )
                  else
                    const SizedBox(width: 48),

                  const Expanded(
                    child: Center(
                      child: Text(
                        "Create Trip",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 48),
                ],
              ),

              const SizedBox(height: 16),

              stepIndicator(currentStep),

              const SizedBox(height: 24),

              Expanded(child: _buildStep()),
            ],
          ),
        ),
      ),
    );
  }
}
