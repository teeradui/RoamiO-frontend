import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:roamio_frontend/models/services/location_service.dart';
import 'package:roamio_frontend/theme/colors.dart';
import 'package:roamio_frontend/viewmodels/meeting_point_view_model.dart';

class MeetingPointScreen extends StatefulWidget {
  const MeetingPointScreen({super.key});

  @override
  State<MeetingPointScreen> createState() => _MeetingPointScreenState();
}

class _MeetingPointScreenState extends State<MeetingPointScreen> {
  final TextEditingController searchController = TextEditingController();
  GoogleMapController? mapController;

  late final MeetingPointViewModel viewModel;

  @override
  void initState() {
    super.initState();

    viewModel = MeetingPointViewModel(locationService: LocationService());
  }

  @override
  void dispose() {
    searchController.dispose();
    mapController?.dispose();
    viewModel.dispose();
    super.dispose();
  }

  void confirmLocation() {
    Navigator.pop(context, viewModel.confirmData);
  }

  Future<void> selectPlace(dynamic place) async {
    await viewModel.selectPlace(
      placeId: place["place_id"],
      description: place["description"],
    );

    mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(viewModel.selectedLocation, 16),
    );
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
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back_ios_new),
                      ),
                      const Text(
                        "Meeting Point",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TextField(
                    controller: searchController,
                    onChanged: viewModel.searchPlaces,
                    decoration: InputDecoration(
                      hintText: "Search meeting point",
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: IconButton(
                        onPressed: () {
                          searchController.clear();
                          viewModel.clearPredictions();
                        },
                        icon: const Icon(Icons.close),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),

                if (viewModel.placePredictions.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                    constraints: const BoxConstraints(maxHeight: 220),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Material(
                      color: Colors.transparent,
                      child: ListView.separated(
                        shrinkWrap: true,
                        itemCount: viewModel.placePredictions.length,
                        separatorBuilder: (_, __) =>
                            Divider(height: 1, color: Colors.grey.shade200),
                        itemBuilder: (context, index) {
                          final place = viewModel.placePredictions[index];

                          return ListTile(
                            leading: const Icon(
                              Icons.location_on_outlined,
                              color: AppColors.btnPrimary,
                            ),
                            title: Text(
                              place["description"] ?? "",
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            onTap: () {
                              searchController.text =
                                  place["description"] ?? "";
                              selectPlace(place);
                            },
                          );
                        },
                      ),
                    ),
                  ),

                const SizedBox(height: 12),

                Expanded(
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(24),
                    ),
                    child: GoogleMap(
                      initialCameraPosition: CameraPosition(
                        target: viewModel.selectedLocation,
                        zoom: 14,
                      ),
                      zoomControlsEnabled: true,
                      zoomGesturesEnabled: true,
                      scrollGesturesEnabled: true,
                      rotateGesturesEnabled: true,
                      tiltGesturesEnabled: true,
                      myLocationButtonEnabled: true,
                      onMapCreated: (controller) async {
                        mapController = controller;
                        await viewModel.loadCurrentLocation();

                        mapController?.animateCamera(
                          CameraUpdate.newLatLngZoom(
                            viewModel.selectedLocation,
                            16,
                          ),
                        );
                      },
                      markers: {
                        Marker(
                          markerId: const MarkerId("meeting_point"),
                          position: viewModel.selectedLocation,
                        ),
                      },
                      onTap: viewModel.updateAddressFromLatLng,
                    ),
                  ),
                ),

                Container(
                  padding: const EdgeInsets.all(16),
                  color: Colors.white,
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on,
                            color: AppColors.btnPrimary,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              viewModel.selectedAddress,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: ElevatedButton(
                          onPressed: confirmLocation,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.btnPrimary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: const Text(
                            "Confirm Location",
                            style: TextStyle(
                              color: AppColors.bgPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
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
