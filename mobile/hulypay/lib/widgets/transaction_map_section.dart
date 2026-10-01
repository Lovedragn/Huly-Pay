import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../data/external_data.dart';
import '../theme/app_theme.dart';

class TransactionMapSection extends StatefulWidget {
  final double latitude;
  final double longitude;
  final double? accuracy;
  final String merchantTitle;
  final String mapViewMode;
  final ValueChanged<String> onModeChanged;
  final void Function(GoogleMapController controller)? onMapCreated;
  final double screenHeight;

  const TransactionMapSection({
    super.key,
    required this.latitude,
    required this.longitude,
    this.accuracy,
    required this.merchantTitle,
    required this.mapViewMode,
    required this.onModeChanged,
    this.onMapCreated,
    required this.screenHeight,
  });

  @override
  State<TransactionMapSection> createState() => _TransactionMapSectionState();
}

class _TransactionMapSectionState extends State<TransactionMapSection> {
  Future<void> _handleOpenStreetViewExternal() async {
    final url = Uri.parse(
      'https://www.google.com/maps/@?api=1&map_action=pano&viewpoint=${widget.latitude},${widget.longitude}',
    );
    try {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    if (widget.mapViewMode == 'street') {
      return _buildStreetViewContent();
    }
    return _buildGoogleMapContent();
  }

  Widget _buildGoogleMapContent() {
    // Automated widget testing or desktop platforms fallback
    if (kIsWeb ||
        (defaultTargetPlatform != TargetPlatform.android &&
            defaultTargetPlatform != TargetPlatform.iOS)) {
      return _buildDarkMapFallbackCanvas();
    }

    final targetPos = LatLng(widget.latitude, widget.longitude);
    final isSatellite = widget.mapViewMode == 'satellite';
    final double sheetHeight = widget.screenHeight * 0.54;

    try {
      return GoogleMap(
        initialCameraPosition: CameraPosition(
          target: targetPos,
          zoom: 17.0,
          tilt: isSatellite ? 45.0 : 0.0,
        ),
        mapType: isSatellite ? MapType.satellite : MapType.normal,
        style: isSatellite ? null : ExternalData.darkMapStyle,
        markers: {
          Marker(
            markerId: const MarkerId('payment_marker'),
            position: targetPos,
            infoWindow: InfoWindow(
              title: widget.merchantTitle,
              snippet:
                  '${widget.latitude.toStringAsFixed(5)}, ${widget.longitude.toStringAsFixed(5)}',
            ),
            icon: BitmapDescriptor.defaultMarkerWithHue(
              isSatellite
                  ? BitmapDescriptor.hueYellow
                  : BitmapDescriptor.hueRed,
            ),
          ),
        },
        circles: {
          Circle(
            circleId: const CircleId('payment_accuracy_circle'),
            center: targetPos,
            radius: (widget.accuracy != null && widget.accuracy! > 0)
                ? widget.accuracy!
                : 20.0,
            fillColor: isSatellite
                ? const Color(0x30FFCC00)
                : const Color(0x28007AFF),
            strokeColor: isSatellite
                ? const Color(0x90FFCC00)
                : const Color(0x80007AFF),
            strokeWidth: 1,
          ),
        },
        gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
          Factory<OneSequenceGestureRecognizer>(() => EagerGestureRecognizer()),
        },
        padding: EdgeInsets.only(bottom: sheetHeight),
        zoomControlsEnabled: false,
        myLocationEnabled: false,
        myLocationButtonEnabled: false,
        mapToolbarEnabled: false,
        compassEnabled: true,
        onMapCreated: (GoogleMapController controller) {
          widget.onMapCreated?.call(controller);
          Future.delayed(const Duration(milliseconds: 400), () {
            if (mounted) {
              controller.animateCamera(
                CameraUpdate.newCameraPosition(
                  CameraPosition(
                    target: targetPos,
                    zoom: 17.0,
                    tilt: isSatellite ? 45.0 : 0.0,
                  ),
                ),
              );
            }
          });
        },
      );
    } catch (_) {
      return _buildDarkMapFallbackCanvas();
    }
  }

  Widget _buildDarkMapFallbackCanvas() {
    return Container(
      color: const Color(0xFF181A20),
      child: Stack(
        fit: StackFit.expand,
        children: [
          CustomPaint(painter: MapGridPainter()),
          Align(
            alignment: const Alignment(0, -0.42),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF453A).withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.location_on,
                    color: Color(0xFFFF453A),
                    size: 32,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF141416),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: const Color(0xFF2A2A30)),
                  ),
                  child: Text(
                    widget.merchantTitle,
                    style: const TextStyle(
                      fontFamily: 'Google Sans',
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStreetViewContent() {
    return Container(
      color: const Color(0xFF121215),
      alignment: const Alignment(0, -0.42),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1C2A3A), Color(0xFF1E1E28)],
                ),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF2A2A3A), width: 1.5),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x40007AFF),
                    blurRadius: 16,
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: const Center(
                child: Icon(
                  Icons.streetview_rounded,
                  color: Color(0xFF007AFF),
                  size: 28,
                ),
              ),
            ),
            const SizedBox(height: 14),
            const Text(
              'Street View opens in Google Maps',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Google Sans',
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Tap below to view 360° panorama\nat ${widget.latitude.toStringAsFixed(4)}, ${widget.longitude.toStringAsFixed(4)}',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Google Sans',
                color: Color(0xFF6B6B70),
                fontSize: 11.5,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 14),
            GestureDetector(
              onTap: _handleOpenStreetViewExternal,
              behavior: HitTestBehavior.opaque,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0062CC), Color(0xFF007AFF)],
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x50007AFF),
                      blurRadius: 10,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.open_in_new_rounded,
                      color: Colors.white,
                      size: 14,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Open 360° Street View',
                      style: TextStyle(
                        fontFamily: 'Google Sans',
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Control bar with Map / Satellite / 360° mode switcher and Start Route button
class TransactionMapControlBar extends StatelessWidget {
  final String mapViewMode;
  final ValueChanged<String> onModeChanged;
  final VoidCallback onStartRoute;
  final VoidCallback onOpenStreetView;

  const TransactionMapControlBar({
    super.key,
    required this.mapViewMode,
    required this.onModeChanged,
    required this.onStartRoute,
    required this.onOpenStreetView,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Mode Switch: MAP ↔ SATELLITE ↔ 360°
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1B1B20),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppThemeManager.colors.border, width: 1),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTab(
                key: const Key('map_mode_button'),
                label: 'MAP',
                isActive: mapViewMode == 'map',
                onTap: () => onModeChanged('map'),
              ),
              _buildTab(
                key: const Key('satellite_mode_button'),
                label: 'SATELLITE',
                isActive: mapViewMode == 'satellite',
                onTap: () => onModeChanged('satellite'),
              ),
              _buildTab(
                key: const Key('street_view_toggle'),
                label: '360°',
                isActive: mapViewMode == 'street',
                onTap: () {
                  onModeChanged('street');
                  onOpenStreetView();
                },
              ),
            ],
          ),
        ),

        // Start Route Button
        GestureDetector(
          key: const Key('start_route_button'),
          onTap: onStartRoute,
          behavior: HitTestBehavior.opaque,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF007AFF),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF007AFF).withValues(alpha: 0.4),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.near_me_rounded, color: Colors.white, size: 15),
                SizedBox(width: 6),
                Text(
                  'Start Route',
                  style: TextStyle(
                    fontFamily: 'Google Sans',
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTab({
    required Key key,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      key: key,
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF007AFF) : Colors.transparent,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'Google Sans',
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: isActive ? Colors.white : const Color(0xFF8E8E93),
          ),
        ),
      ),
    );
  }
}

class MapGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF222630)
      ..strokeWidth = 0.8
      ..style = PaintingStyle.stroke;

    final roadPaint = Paint()
      ..color = const Color(0xFF2A3040)
      ..strokeWidth = 4.0
      ..style = PaintingStyle.stroke;

    const step = 48.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }

    final path1 = Path()
      ..moveTo(0, size.height * 0.35)
      ..lineTo(size.width * 0.45, size.height * 0.38)
      ..lineTo(size.width, size.height * 0.28);
    canvas.drawPath(path1, roadPaint);

    final path2 = Path()
      ..moveTo(size.width * 0.5, 0)
      ..lineTo(size.width * 0.52, size.height * 0.6)
      ..lineTo(size.width * 0.48, size.height);
    canvas.drawPath(path2, roadPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
