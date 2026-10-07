import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../Data/external_data.dart';
import '../../Theme/app_theme.dart';

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
      return _buildMapFallbackCanvas();
    }

    final targetPos = LatLng(widget.latitude, widget.longitude);
    final isSatellite = widget.mapViewMode == 'satellite';
    final double sheetHeight = widget.screenHeight * 0.54;
    final colors = AppThemeManager.colors;
    final isDark = colors.isDark;

    try {
      return GoogleMap(
        initialCameraPosition: CameraPosition(
          target: targetPos,
          zoom: 17.0,
          tilt: isSatellite ? 45.0 : 0.0,
        ),
        mapType: isSatellite ? MapType.satellite : MapType.normal,
        style: isSatellite
            ? null
            : (isDark ? ExternalData.darkMapStyle : ExternalData.lightMapStyle),
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
                : colors.accent.withValues(alpha: 0.15),
            strokeColor: isSatellite
                ? const Color(0x90FFCC00)
                : colors.accent.withValues(alpha: 0.5),
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
      return _buildMapFallbackCanvas();
    }
  }

  Widget _buildMapFallbackCanvas() {
    final colors = AppThemeManager.colors;
    final isDark = colors.isDark;

    return Container(
      color: isDark
          ? const Color(0xFF181A20)
          : (colors.name == 'Milk white'
              ? const Color(0xFFEFF2F6)
              : const Color(0xFFF7F8FA)),
      child: Stack(
        fit: StackFit.expand,
        children: [
          CustomPaint(
            painter: MapGridPainter(
              gridColor: isDark
                  ? const Color(0xFF222630)
                  : const Color(0xFFE2E6EE),
              roadColor: isDark
                  ? const Color(0xFF2A3040)
                  : const Color(0xFFD6DBE5),
              highlightRoadColor: isDark
                  ? const Color(0xFF333B4D)
                  : const Color(0xFFCAD1DE),
            ),
          ),
          Align(
            alignment: const Alignment(0, -0.42),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: colors.accent.withValues(alpha: 0.18),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.location_on,
                    color: colors.accent,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: colors.surface,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: colors.border, width: 1),
                    boxShadow: [
                      BoxShadow(
                        color: isDark
                            ? Colors.black45
                            : Colors.black.withValues(alpha: 0.08),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    widget.merchantTitle,
                    style: TextStyle(
                      fontFamily: 'Google Sans',
                      color: colors.textPrimary,
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
    final colors = AppThemeManager.colors;
    final isDark = colors.isDark;

    return Container(
      color: isDark ? const Color(0xFF121215) : colors.background,
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
                gradient: LinearGradient(
                  colors: isDark
                      ? const [Color(0xFF1C2A3A), Color(0xFF1E1E28)]
                      : [colors.surfaceSecondary, colors.surface],
                ),
                shape: BoxShape.circle,
                border: Border.all(color: colors.border, width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: colors.accent.withValues(alpha: 0.25),
                    blurRadius: 16,
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: Center(
                child: Icon(
                  Icons.streetview_rounded,
                  color: colors.accent,
                  size: 28,
                ),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'Street View opens in Google Maps',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Google Sans',
                color: colors.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Tap below to view 360° panorama\nat ${widget.latitude.toStringAsFixed(4)}, ${widget.longitude.toStringAsFixed(4)}',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Google Sans',
                color: colors.textSecondary,
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
                  color: colors.accent,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: colors.accent.withValues(alpha: 0.35),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
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
    final colors = AppThemeManager.colors;
    final isDark = colors.isDark;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Mode Switch: MAP ↔ SATELLITE ↔ 360°
        Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1B1B20) : colors.surfaceSecondary,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: colors.border, width: 1),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTab(
                key: const Key('map_mode_button'),
                label: 'MAP',
                isActive: mapViewMode == 'map',
                onTap: () => onModeChanged('map'),
                colors: colors,
              ),
              _buildTab(
                key: const Key('satellite_mode_button'),
                label: 'SATELLITE',
                isActive: mapViewMode == 'satellite',
                onTap: () => onModeChanged('satellite'),
                colors: colors,
              ),
              _buildTab(
                key: const Key('street_view_toggle'),
                label: '360°',
                isActive: mapViewMode == 'street',
                onTap: () {
                  onModeChanged('street');
                  onOpenStreetView();
                },
                colors: colors,
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
              color: colors.accent,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: colors.accent.withValues(alpha: 0.35),
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
    required AppThemeData colors,
  }) {
    return GestureDetector(
      key: key,
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: isActive ? colors.accent : Colors.transparent,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'Google Sans',
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: isActive ? Colors.white : colors.textSecondary,
          ),
        ),
      ),
    );
  }
}

class MapGridPainter extends CustomPainter {
  final Color gridColor;
  final Color roadColor;
  final Color highlightRoadColor;

  MapGridPainter({
    this.gridColor = const Color(0xFF222630),
    this.roadColor = const Color(0xFF2A3040),
    this.highlightRoadColor = const Color(0xFF333B4D),
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = gridColor
      ..strokeWidth = 0.8
      ..style = PaintingStyle.stroke;

    final roadPaint = Paint()
      ..color = roadColor
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
  bool shouldRepaint(covariant MapGridPainter oldDelegate) =>
      oldDelegate.gridColor != gridColor ||
      oldDelegate.roadColor != roadColor ||
      oldDelegate.highlightRoadColor != highlightRoadColor;
}
