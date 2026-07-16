import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ming_cute_icons/ming_cute_icons.dart';
import 'package:roamio_frontend/theme/colors.dart';
import 'package:roamio_frontend/viewmodels/map_section_view_model.dart';
import 'package:roamio_frontend/viewmodels/trip_detail_view_model.dart';

class MapSection extends StatefulWidget {
  const MapSection({super.key, required this.tripId, required this.tripStatus});

  final String tripId;
  final TripStatus tripStatus;

  @override
  State<MapSection> createState() => _MapSectionState();
}

class _MapSectionState extends State<MapSection> {
  late final MapSectionViewModel viewModel;

  GoogleMapController? mapController;
  Set<Marker> markers = {};

  @override
  void initState() {
    super.initState();

    viewModel = MapSectionViewModel(
      tripId: widget.tripId,
      tripStatus: widget.tripStatus,
    );

    viewModel.addListener(_handleViewModelChanged);
    viewModel.loadMapData();
  }

  Future<void> _handleViewModelChanged() async {
    if (!mounted || viewModel.isLoading) return;

    await _createMapMarkers();
  }

  Future<void> _createMapMarkers() async {
    final Set<Marker> newMarkers = {};

    for (final member in viewModel.members) {
      final icon = await _createUserMarkerIcon(member.username);

      newMarkers.add(
        Marker(
          markerId: MarkerId(member.id),
          position: member.location,
          icon: icon,
          infoWindow: InfoWindow(title: member.username),
        ),
      );
    }

    if (viewModel.isActive) {
      for (final place in viewModel.visitedPlaces) {
        final icon = await _createVisitedPlaceMarkerIcon(place.name);

        newMarkers.add(
          Marker(
            markerId: MarkerId(place.id),
            position: place.location,
            icon: icon,
            infoWindow: InfoWindow(
              title: place.name,
              snippet: "${place.type} · ${place.timeText}",
            ),
          ),
        );
      }
    }

    if (!mounted) return;

    setState(() {
      markers = newMarkers;
    });
  }

  Future<BitmapDescriptor> _createVisitedPlaceMarkerIcon(
    String placeName,
  ) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    const double height = 44;
    const double paddingX = 14;

    final textPainter = TextPainter(
      text: TextSpan(
        text: placeName,
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
      maxLines: 1,
      ellipsis: "...",
      textDirection: TextDirection.ltr,
    );

    textPainter.layout(maxWidth: 160);

    final double width = textPainter.width + paddingX * 2;

    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, width, height),
      const Radius.circular(100),
    );

    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.18)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);

    final bgPaint = Paint()..color = AppColors.bgCard;

    canvas.drawRRect(rect.shift(const Offset(0, 3)), shadowPaint);

    canvas.drawRRect(rect, bgPaint);

    textPainter.paint(
      canvas,
      Offset(paddingX, height / 2 - textPainter.height / 2),
    );

    final picture = recorder.endRecording();
    final image = await picture.toImage(width.ceil(), height.toInt());
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);

    return BitmapDescriptor.bytes(byteData!.buffer.asUint8List());
  }

  Future<BitmapDescriptor> _createUserMarkerIcon(String username) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    const double size = 60;
    const double border = 4;
    final Offset center = const Offset(size / 2, size / 2);

    final Paint shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.18)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);

    final Paint outerPaint = Paint()..color = AppColors.btnPrimary;
    final Paint innerPaint = Paint()..color = AppColors.bgHighlight;

    canvas.drawCircle(center.translate(0, 4), size / 2 - 6, shadowPaint);
    canvas.drawCircle(center, size / 2 - 6, outerPaint);
    canvas.drawCircle(center, size / 2 - 6 - border, innerPaint);

    final textPainter = TextPainter(
      text: TextSpan(
        text: username[0].toUpperCase(),
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 34,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();

    textPainter.paint(
      canvas,
      Offset(
        center.dx - textPainter.width / 2,
        center.dy - textPainter.height / 2,
      ),
    );

    final picture = recorder.endRecording();
    final image = await picture.toImage(size.toInt(), size.toInt());
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);

    return BitmapDescriptor.bytes(byteData!.buffer.asUint8List());
  }

  @override
  void dispose() {
    viewModel.removeListener(_handleViewModelChanged);
    mapController?.dispose();
    viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: viewModel,
      builder: (context, _) {
        return Column(
          children: [
            Container(
              width: double.infinity,
              height: 300,
              decoration: BoxDecoration(
                color: AppColors.bgCard,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              clipBehavior: Clip.antiAlias,
              child: GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: viewModel.mapCenter,
                  zoom: 13,
                ),
                onMapCreated: (controller) {
                  mapController = controller;
                },
                markers: markers,
                polylines: viewModel.routePolylines,
                zoomControlsEnabled: true,
                myLocationButtonEnabled: false,
                compassEnabled: false,
              ),
            ),

            const SizedBox(height: 14),

            if (viewModel.isActive && viewModel.hasVisitedPlaces)
              _VisitedRouteSummary(viewModel: viewModel),

            const SizedBox(height: 12),
          ],
        );
      },
    );
  }
}

class _VisitedRouteSummary extends StatelessWidget {
  const _VisitedRouteSummary({required this.viewModel});

  final MapSectionViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 14),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: AppColors.gradientUpAc,
                ).createShader(bounds),
                child: const Icon(
                  MingCuteIcons.mgc_location_2_fill,
                  size: 22,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                "Places Visited",
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          Column(
            children: viewModel.visitedPlaces.asMap().entries.map((entry) {
              final index = entry.key;
              final place = entry.value;

              return _VisitedPlaceTimelineTile(
                place: place,
                isLast: index == viewModel.visitedPlaces.length - 1,
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _VisitedPlaceTimelineTile extends StatelessWidget {
  const _VisitedPlaceTimelineTile({required this.place, required this.isLast});

  final VisitedPlaceMapPoint place;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 22,
          child: Column(
            children: [
              Container(
                width: 11,
                height: 11,
                decoration: const BoxDecoration(
                  color: AppColors.btnPrimary,
                  shape: BoxShape.circle,
                ),
              ),
              if (!isLast)
                Container(
                  width: 2,
                  height: 42,
                  margin: const EdgeInsets.only(top: 3),
                  decoration: BoxDecoration(
                    color: AppColors.textMuted.withValues(alpha: 0.45),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
            ],
          ),
        ),

        const SizedBox(width: 10),

        Expanded(
          child: Padding(
            padding: EdgeInsets.only(bottom: isLast ? 10 : 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  place.name,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  "${place.type} · ${place.timeText}",
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
