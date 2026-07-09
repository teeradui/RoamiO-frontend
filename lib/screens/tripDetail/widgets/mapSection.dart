import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:roamio_frontend/theme/colors.dart';
import 'package:roamio_frontend/viewmodels/mapSectionViewmodel.dart';

class MapSection extends StatefulWidget {
  const MapSection({super.key});

  @override
  State<MapSection> createState() => _MapSectionState();
}

class _MapSectionState extends State<MapSection> {
  final MapSectionViewModel viewModel = MapSectionViewModel();

  GoogleMapController? mapController;
  Set<Marker> markers = {};

  @override
  void initState() {
    super.initState();
    _createUserMarkers();
  }

  Future<void> _createUserMarkers() async {
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

    if (!mounted) return;

    setState(() {
      markers = newMarkers;
    });
  }

  Future<BitmapDescriptor> _createUserMarkerIcon(String username) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    const double size = 60;
    const double border = 4;

    final Paint shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.18)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);

    final Paint outerPaint = Paint()
      ..color = AppColors.btnPrimary;

    final Paint innerPaint = Paint()
      ..color = AppColors.bgHighlight;

    final Offset center = const Offset(size / 2, size / 2);

    canvas.drawCircle(
      center.translate(0, 4),
      size / 2 - 6,
      shadowPaint,
    );

    canvas.drawCircle(
      center,
      size / 2 - 6,
      outerPaint,
    );

    canvas.drawCircle(
      center,
      size / 2 - 6 - border,
      innerPaint,
    );

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
                  zoom: 15,
                ),
                onMapCreated: (controller) {
                  mapController = controller;
                },
                markers: markers,
                zoomControlsEnabled: false,
                myLocationButtonEnabled: false,
                compassEnabled: false,
              ),
            ),

            const SizedBox(height: 14),

            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: viewModel.members.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final member = viewModel.members[index];

                
              },
            ),
          ],
        );
      },
    );
  }
}

