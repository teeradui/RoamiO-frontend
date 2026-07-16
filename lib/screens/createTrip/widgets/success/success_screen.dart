import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:roamio_frontend/theme/colors.dart';
import 'package:roamio_frontend/viewmodels/success_view_model.dart';

class Step3Success extends StatelessWidget {
  const Step3Success({
    super.key,
    required this.onViewTrip
  });

  final VoidCallback onViewTrip;

  @override
  Widget build(BuildContext context) {
    final viewModel = CreateTripSuccessViewModel(
      tripName: "Japan Autumn Trip",
      startTime: "09:00 AM",
    );

    return SingleChildScrollView(
      child: Column(
        children: [

          Lottie.asset(
            "assets/Travelisfun.json",
            width: 220,
            height: 220,
            repeat: true,
          ),

          const SizedBox(height: 6),

          Text(
            viewModel.title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),

          const SizedBox(height: 2),

          Text(
            viewModel.subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 15,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            viewModel.trackingText,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500
            ),
          ),

          const SizedBox(height: 16),

          _InfoBox(
            color: const Color(0x56BBE7FF),
            textColor: const Color(0xFF2DB3FB),
            text: viewModel.gpsMessage,
          ),

          const SizedBox(height: 14),

          _InfoBox(
            color: const Color(0x56FFD3BB),
            textColor: const Color(0xFFFF8340),
            text: viewModel.notificationMessage,
          ),

          const SizedBox(height: 20),

          /*SizedBox(
            width: 180,
            height: 50,
            child: ElevatedButton(
              onPressed: onViewTrip,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.btnPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                "View Trip",
                style: TextStyle(
                  color: AppColors.bgPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),*/

          const SizedBox(height: 20),

        ],
      ),
    );
  }
}

class _InfoBox extends StatelessWidget {
  const _InfoBox({
    required this.color,
    required this.textColor,
    required this.text,
  });

  final Color color;
  final Color textColor;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      alignment: Alignment.center,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: textColor,
          fontSize: 14,
          height: 1.4,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}