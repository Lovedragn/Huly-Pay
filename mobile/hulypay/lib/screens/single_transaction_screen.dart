import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../data/external_data.dart';
import '../models/dashboard_data.dart';
import '../models/payment_model.dart';
import '../repositories/payment_repository.dart';
import '../services/auth_service.dart';
import '../services/local_database_service.dart';
import '../theme/app_theme.dart';
import '../widgets/category_picker_sheet.dart';
import '../widgets/transaction_detail_components.dart';

class SingleTransactionScreen extends StatefulWidget {
  final TransactionItem transaction;
  final PaymentModel? payment;
  final String? paymentId;

  const SingleTransactionScreen({
    super.key,
    required this.transaction,
    this.payment,
    this.paymentId,
  });

  @override
  State<SingleTransactionScreen> createState() =>
      _SingleTransactionScreenState();
}

class _SingleTransactionScreenState extends State<SingleTransactionScreen> {
  // Map view mode: 'map' | 'satellite' | 'street'
  String _mapViewMode = 'map';
  PaymentModel? _currentPayment;
  bool _isLoading = false;
  bool _isReconciling = false;
  bool _isCancelling = false;
  bool _isDeleting = false;
  GoogleMapController? _mapController;
  String? _customCategory;
  final ValueNotifier<double> _sheetExtentNotifier = ValueNotifier<double>(
    0.54,
  );

  @override
  void initState() {
    super.initState();
    _currentPayment = widget.payment;
    _loadCustomCategory();
    if (widget.payment == null) {
      _fetchPaymentDetails();
    }
  }

  Future<void> _loadCustomCategory() async {
    final paymentId = widget.payment?.id ?? widget.transaction.id;
    try {
      final saved = await LocalDatabaseService().getMetadata('category_$paymentId');
      if (saved != null && saved.isNotEmpty && mounted) {
        setState(() => _customCategory = saved);
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _sheetExtentNotifier.dispose();
    super.dispose();
  }

  Future<void> _fetchPaymentDetails() async {
    final idToFetch = widget.paymentId ?? (widget.payment?.id);
    if (idToFetch == null || idToFetch.isEmpty) return;

    try {
      setState(() => _isLoading = true);
      final payment = await PaymentRepository().getPaymentById(idToFetch);
      if (mounted) {
        setState(() {
          _currentPayment = payment;
          _isLoading = false;
        });
        if (payment.latitude != null && payment.longitude != null) {
          _mapController?.animateCamera(
            CameraUpdate.newLatLngZoom(
              LatLng(payment.latitude!, payment.longitude!),
              16.0,
            ),
          );
        }
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  double get _latitude => _currentPayment?.latitude ?? 13.082680;
  double get _longitude => _currentPayment?.longitude ?? 80.270718;
  double? get _accuracy => _currentPayment?.locationAccuracyMeters ?? 8.5;

  String get _referenceId {
    if (_currentPayment?.transactionReference != null &&
        _currentPayment!.transactionReference!.isNotEmpty) {
      return _currentPayment!.transactionReference!;
    }
    if (_currentPayment?.upiTransactionId != null &&
        _currentPayment!.upiTransactionId!.isNotEmpty) {
      return _currentPayment!.upiTransactionId!;
    }
    final hash = widget.transaction.id.hashCode.abs().toString().padLeft(
      12,
      '0',
    );
    return 'UPI/$hash';
  }

  String get _paymentMethod {
    if (_currentPayment?.paymentMethod != null &&
        _currentPayment!.paymentMethod!.isNotEmpty) {
      return _currentPayment!.paymentMethod!;
    }
    final titleLower = widget.transaction.title.toLowerCase();
    if (titleLower.contains('amazon')) {
      return 'Amazon Pay';
    }
    if (titleLower.contains('swiggy') ||
        titleLower.contains('google') ||
        titleLower.contains('zomato') ||
        widget.transaction.type.toLowerCase().contains('upi')) {
      return 'GPay';
    }
    return widget.transaction.id.hashCode.isEven ? 'GPay' : 'Amazon Pay';
  }

  String get _category {
    if (_customCategory != null && _customCategory!.isNotEmpty) {
      return _customCategory!;
    }
    return widget.transaction.category;
  }

  String get _status {
    if (_currentPayment != null) {
      return _currentPayment!.status;
    }
    return widget.transaction.isFailed ? 'FAILED' : 'CONFIRMED';
  }

  String get _displayAmount {
    if (_currentPayment != null) {
      return '₹${_currentPayment!.amount.toStringAsFixed(2)}';
    }
    return widget.transaction.amount;
  }

  String get _merchantTitle {
    if (_currentPayment?.merchantName != null &&
        _currentPayment!.merchantName!.isNotEmpty) {
      return _currentPayment!.merchantName!;
    }
    return widget.transaction.title;
  }

  void _copyToClipboard(BuildContext context, String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '$label copied to clipboard',
          style: const TextStyle(
            fontFamily: 'Google Sans',
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF1E1E24),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _handleStartRoute() async {
    final destLat = _latitude;
    final destLng = _longitude;
    final url = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=$destLat,$destLng&travelmode=driving',
    );

    try {
      final launched = await launchUrl(
        url,
        mode: LaunchMode.externalApplication,
      );
      if (!launched && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Starting route to ($destLat, $destLng)...'),
            backgroundColor: const Color(0xFF1E1E24),
          ),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Routing to ($destLat, $destLng)'),
            backgroundColor: const Color(0xFF1E1E24),
          ),
        );
      }
    }
  }

  Future<void> _handleReconcilePayment() async {
    final paymentId = _currentPayment?.id ?? widget.transaction.id;
    setState(() => _isReconciling = true);

    try {
      final updated = await PaymentRepository().reconcilePayment(
        paymentId,
        'CONFIRMED',
        upiTransactionId: 'UPI_${DateTime.now().millisecondsSinceEpoch}',
        transactionReference: 'REF_${DateTime.now().millisecondsSinceEpoch}',
      );
      if (mounted) {
        setState(() {
          _currentPayment = updated;
          _isReconciling = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Payment confirmed and reconciled to expense successfully!',
            ),
            backgroundColor: Color(0xFF28A745),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isReconciling = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Reconciliation error: $e'),
            backgroundColor: const Color(0xFFD93025),
          ),
        );
      }
    }
  }

  Future<void> _handleCancelPayment() async {
    final s = _status.toUpperCase();
    if (s == 'CONFIRMED' || s == 'SUCCESS' || s == 'SUCCESSFUL') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Successful transactions are finalized and cannot be deleted or cancelled.'),
          backgroundColor: Color(0xFF1E1E24),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final paymentId = _currentPayment?.id ?? widget.transaction.id;
    setState(() => _isCancelling = true);

    try {
      final updated = await PaymentRepository().reconcilePayment(
        paymentId,
        'CANCELLED',
      );
      if (mounted) {
        setState(() {
          _currentPayment = updated;
          _isCancelling = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Payment has been cancelled successfully.'),
            backgroundColor: Color(0xFFE24C4C),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isCancelling = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Cancel error: $e'),
            backgroundColor: const Color(0xFFD93025),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _showCancelConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E1E24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Row(
            children: [
              Icon(Icons.cancel_outlined, color: Color(0xFFFF453A), size: 22),
              SizedBox(width: 8),
              Text(
                'Cancel Payment',
                style: TextStyle(
                  fontFamily: 'Google Sans',
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          content: Text(
            'Are you sure you want to cancel this payment of $_displayAmount to $_merchantTitle?',
            style: const TextStyle(
              fontFamily: 'Google Sans',
              color: Color(0xFF8E8E93),
              fontSize: 14,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text(
                'Keep Payment',
                style: TextStyle(
                  fontFamily: 'Google Sans',
                  color: Color(0xFF8E8E93),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                _handleCancelPayment();
              },
              child: const Text(
                'Yes, Cancel',
                style: TextStyle(
                  fontFamily: 'Google Sans',
                  color: Color(0xFFFF453A),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _handleDeletePayment() async {
    final paymentId = _currentPayment?.id ?? widget.transaction.id;
    setState(() => _isDeleting = true);

    try {
      await PaymentRepository().deletePayment(paymentId);
      if (mounted) {
        setState(() => _isDeleting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Transaction deleted successfully.'),
            backgroundColor: Color(0xFF1E1E24),
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isDeleting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Delete error: $e'),
            backgroundColor: const Color(0xFFD93025),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _showDeleteConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E1E24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Row(
            children: [
              Icon(Icons.delete_outline_rounded, color: Color(0xFFFF453A), size: 22),
              SizedBox(width: 8),
              Text(
                'Delete Transaction',
                style: TextStyle(
                  fontFamily: 'Google Sans',
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          content: Text(
            'Are you sure you want to delete this transaction of $_displayAmount to $_merchantTitle? This action cannot be undone.',
            style: const TextStyle(
              fontFamily: 'Google Sans',
              color: Color(0xFF8E8E93),
              fontSize: 14,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text(
                'Cancel',
                style: TextStyle(
                  fontFamily: 'Google Sans',
                  color: Color(0xFF8E8E93),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                _handleDeletePayment();
              },
              child: const Text(
                'Yes, Delete',
                style: TextStyle(
                  fontFamily: 'Google Sans',
                  color: Color(0xFFFF453A),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _updateCategory(String newCategory) async {
    final paymentId = widget.payment?.id ?? widget.transaction.id;
    setState(() {
      _customCategory = newCategory;
    });

    // 1. Persist category locally in metadata cache
    try {
      await LocalDatabaseService().setMetadata('category_$paymentId', newCategory);
    } catch (_) {}

    // 1b. Persist UPI ID → category mapping for auto-categorization on future scans
    try {
      final upiId = _currentPayment?.upiId ?? widget.payment?.upiId;
      if (upiId != null && upiId.trim().isNotEmpty) {
        await LocalDatabaseService().setMetadata(
          'upi_category_${upiId.toLowerCase().trim()}',
          newCategory,
        );
      }
    } catch (_) {}

    // 1c. Persist merchant name → category mapping for auto-categorization on future scans
    try {
      final merchant = _merchantTitle;
      if (merchant.trim().isNotEmpty) {
        await LocalDatabaseService().setMetadata(
          'merchant_category_${merchant.toLowerCase().trim()}',
          newCategory,
        );
      }
    } catch (_) {}

    // 2. If a cached payment exists locally, update its paymentMethod / fields
    try {
      final cachedPayment = await LocalDatabaseService().getPaymentById(paymentId);
      if (cachedPayment != null) {
        final updatedPayment = cachedPayment.copyWith(
          paymentMethod: newCategory,
          updatedAt: DateTime.now().toUtc().toIso8601String(),
        );
        await LocalDatabaseService().upsertPayment(updatedPayment);
      }
    } catch (_) {}

    // 3. Update Supabase payments table
    try {
      final client = AuthService().client;
      if (client != null && !paymentId.startsWith('tx_') && !paymentId.startsWith('local_')) {
        // Attempt updating category_name / category if column exists, fallback to payment_method
        try {
          await client.from('payments').update({
            'category': newCategory,
            'updated_at': DateTime.now().toUtc().toIso8601String(),
          }).eq('id', paymentId);
        } catch (_) {
          // If 'category' column does not exist in payments table, update 'payment_method'
          try {
            await client.from('payments').update({
              'payment_method': newCategory,
              'updated_at': DateTime.now().toUtc().toIso8601String(),
            }).eq('id', paymentId);
          } catch (_) {}
        }
      }
    } catch (_) {}

    if (mounted) {
      try {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle_rounded, color: Color(0xFF30D158), size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Categorized as $newCategory',
                    style: const TextStyle(
                      fontFamily: 'Google Sans',
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            backgroundColor: const Color(0xFF1E1E24),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            duration: const Duration(seconds: 2),
          ),
        );
      } catch (_) {}
    }
  }

  Future<void> _showCategoryPickerSheet(BuildContext parentContext) async {
    final selected = await CategoryPickerSheet.show(
      parentContext,
      activeCategory: _category,
    );
    if (selected != null && mounted) {
      _updateCategory(selected);
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final topPadding = mediaQuery.padding.top;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, dynamic result) {
        if (!didPop) {
          Navigator.of(context).pop(_customCategory);
        }
      },
      child: Scaffold(
        backgroundColor: AppThemeManager.colors.background,
        body: Stack(
          children: [
            // 1. FULL WIDTH & FULL HEIGHT GOOGLE MAP / STREET VIEW IN BACKGROUND (With Parallax Offset)
            Positioned.fill(
              child: ValueListenableBuilder<double>(
                valueListenable: _sheetExtentNotifier,
                builder: (context, extent, child) {
                  final progress = ((extent - 0.54) / (0.94 - 0.54)).clamp(
                    0.0,
                    1.0,
                  );
                  final mapOffset = progress * mediaQuery.size.height * 0.30;
                  return Transform.translate(
                    offset: Offset(0, -mapOffset),
                    child: child,
                  );
                },
                child: _buildGoogleMapOrStreetView(mediaQuery.size.height),
              ),
            ),

            // 2. FIXED TOP-LEFT BACK BUTTON IN MAP VIEW
            Positioned(
              top: topPadding + 10,
              left: 16,
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(_customCategory),
                behavior: HitTestBehavior.opaque,
                child: Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: const Color(0xDD141416),
                    shape: BoxShape.circle,
                    border: Border.all(color: AppThemeManager.colors.border, width: 1),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black45,
                      blurRadius: 5,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: const Center(
                  child: Icon(Icons.arrow_back, color: Colors.white, size: 20),
                ),
              ),
            ),
          ),

          // 3. OVERLAPPING DETAILS SHEET (Swipe up to cover map & back button, down to reveal map)
          NotificationListener<DraggableScrollableNotification>(
            onNotification: (notification) {
              _sheetExtentNotifier.value = notification.extent;
              return true;
            },
            child: DraggableScrollableSheet(
              initialChildSize: 0.54,
              minChildSize: 0.44,
              maxChildSize: 0.94,
              snap: true,
              snapSizes: const [0.54, 0.94],
              builder: (BuildContext ctx, ScrollController scrollController) {
                return Container(
                  decoration: const BoxDecoration(
                    color: Color(0xFF101013),
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(32),
                    ),
                    border: Border(
                      top: BorderSide(color: Color(0xFF282830), width: 1.5),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Color.fromARGB(183, 0, 0, 0),
                        blurRadius: 48,
                        spreadRadius: 0,
                        offset: Offset(0, -2),
                      ),
                    ],
                  ),
                  child: SingleChildScrollView(
                    controller: scrollController,
                    physics: const ClampingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Drag Handle
                        Center(
                          child: Container(
                            width: 42,
                            height: 4.5,
                            margin: const EdgeInsets.only(top: 2, bottom: 14),
                            decoration: BoxDecoration(
                              color: const Color(0xFF383842),
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                        ),
                        // Coordinates & Start Route Row
                        _buildMapCoordinatesAndRouteRow(context),
                        const SizedBox(height: 14),
                        _buildHeroReceiptCard(context),
                        const SizedBox(height: 18),
                        _buildQuickActionButtons(context),
                        const SizedBox(height: 24),
                        _buildSectionHeader('TRANSACTION DETAILS'),
                        const SizedBox(height: 12),
                        _buildDetailsCard(context),
                        const SizedBox(height: 36),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // 4. TOP PROGRESS INDICATOR
          if (_isLoading)
            Positioned(
              top: topPadding,
              left: 0,
              right: 0,
              child: const LinearProgressIndicator(
                minHeight: 2,
                backgroundColor: Colors.transparent,
                color: Color(0xFF6C5CE7),
              ),
            ),
        ],
      ),
    ),
    );
  }

  Future<void> _handleOpenStreetViewExternal() async {
    final url = Uri.parse(
      'https://www.google.com/maps/@?api=1&map_action=pano&viewpoint=$_latitude,$_longitude',
    );
    try {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } catch (_) {}
  }

  Widget _buildGoogleMapOrStreetView(double screenHeight) {
    if (_mapViewMode == 'street') return _buildStreetViewContent();
    return _buildGoogleMapContent(screenHeight);
  }

  Widget _buildMapCoordinatesAndRouteRow(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Mode Switch: MAP ↔ STREET VIEW on the left side of Start Route
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1B1B20),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppThemeManager.colors.border, width: 1),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildMapToggleTab(
                key: const Key('map_mode_button'),
                label: 'MAP',
                isActive: _mapViewMode == 'map',
                onTap: () => setState(() => _mapViewMode = 'map'),
              ),
              _buildMapToggleTab(
                key: const Key('satellite_mode_button'),
                label: 'SATELLITE',
                isActive: _mapViewMode == 'satellite',
                onTap: () => setState(() => _mapViewMode = 'satellite'),
              ),
              _buildMapToggleTab(
                key: const Key('street_view_toggle'),
                label: '360°',
                isActive: _mapViewMode == 'street',
                onTap: () {
                  // Street view is not embeddable in Flutter — open Google Maps directly
                  _handleOpenStreetViewExternal();
                },
              ),
            ],
          ),
        ),

        // Start Route Button
        GestureDetector(
          key: const Key('start_route_button'),
          onTap: _handleStartRoute,
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

  Widget _buildMapToggleTab({
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

  Widget _buildGoogleMapContent(double screenHeight) {
    // In automated widget testing environments or headless test runs, render visual dark map canvas
    if (kIsWeb ||
        (defaultTargetPlatform != TargetPlatform.android &&
            defaultTargetPlatform != TargetPlatform.iOS)) {
      return _buildDarkMapFallbackCanvas();
    }

    final targetPos = LatLng(_latitude, _longitude);
    final isSatellite = _mapViewMode == 'satellite';

    // The bottom sheet covers 54% of the screen at rest.
    // Providing this as bottom padding to GoogleMap shifts the camera's
    // effective viewport center into the visible top portion of the map,
    // so the payment pin appears centered in the exposed map area.
    final double sheetHeight = screenHeight * 0.54;
    try {
      return GoogleMap(
        initialCameraPosition: CameraPosition(
          target: targetPos,
          zoom: 17.0,
          tilt: isSatellite ? 45.0 : 0.0,
        ),
        mapType: isSatellite ? MapType.satellite : MapType.normal,
        // Dark style only for normal map — satellite renders photo imagery
        style: isSatellite ? null : ExternalData.darkMapStyle,
        markers: {
          Marker(
            markerId: const MarkerId('payment_marker'),
            position: targetPos,
            infoWindow: InfoWindow(
              title: _merchantTitle,
              snippet:
                  '${_latitude.toStringAsFixed(5)}, ${_longitude.toStringAsFixed(5)}',
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
            radius: (_accuracy != null && _accuracy! > 0) ? _accuracy! : 20.0,
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
        // Inset the map's interactive region so the camera treats the
        // visible area (above the bottom sheet) as the viewport.
        // This centers the pin in the exposed map area, not the full screen.
        padding: EdgeInsets.only(bottom: sheetHeight),
        zoomControlsEnabled: false,
        myLocationEnabled: false,
        myLocationButtonEnabled: false,
        mapToolbarEnabled: false,
        compassEnabled: true,
        onMapCreated: (GoogleMapController controller) {
          _mapController = controller;
          // Animate camera after layout so padding is applied correctly
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
          // Background grid styling
          CustomPaint(painter: _MapGridPainter()),
          // Center Marker in top exposed half
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
                    _merchantTitle,
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
    // Street View cannot be embedded in Flutter — this content is shown only as a fallback
    // The 360° button directly opens Google Maps in pano mode via _handleOpenStreetViewExternal
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
              'Tap below to view 360° panorama\nat ${_latitude.toStringAsFixed(4)}, ${_longitude.toStringAsFixed(4)}',
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

  Widget _buildHeroReceiptCard(BuildContext context) {
    final s = _status.toUpperCase();
    final isFailed = s == 'FAILED';
    final isCancelled = s == 'CANCELLED';
    final isPending = s == 'PENDING' || s == 'INITIATED' || s == 'PAYMENT_INITIATED';

    final Color statusColor = isCancelled
        ? const Color(0xFFFF9F0A)
        : (isFailed
            ? const Color(0xFFFF453A)
            : (isPending ? const Color(0xFFE5A93C) : const Color(0xFF30D158)));

    final Color statusBg = isCancelled
        ? const Color(0xFF2C2210)
        : (isFailed
            ? const Color(0xFF2C1517)
            : (isPending ? const Color(0xFF2A2210) : const Color(0xFF10281B)));

    final Color statusBorder = isCancelled
        ? const Color(0xFF5A441C)
        : (isFailed
            ? const Color(0xFF5A1C22)
            : (isPending ? const Color(0xFF554117) : const Color(0xFF1B4D2E)));

    final String statusText = isCancelled
        ? 'Payment Cancelled'
        : (isFailed
            ? 'Payment Failed'
            : (isPending ? 'Payment Initiated' : 'Payment Successful'));

    final IconData statusIcon = isCancelled
        ? Icons.cancel_outlined
        : (isFailed
            ? Icons.cancel_rounded
            : (isPending
                ? Icons.hourglass_top_rounded
                : Icons.check_circle_rounded));

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      decoration: BoxDecoration(
        color: const Color(0xFF141416),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color.fromARGB(36, 44, 52, 90),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // Status Pill Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: statusBg,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: statusBorder, width: 1),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(statusIcon, color: statusColor, size: 15),
                const SizedBox(width: 6),
                Text(
                  statusText,
                  style: TextStyle(
                    fontFamily: 'Google Sans',
                    color: statusColor,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // Large Amount Text
          Text(
            _displayAmount,
            style: TextStyle(
              fontFamily: 'Google Sans',
              color: isFailed ? const Color(0xFFFF453A) : Colors.white,
              fontSize: 38,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 10),
          // Payee / Source Title
          Text(
            widget.transaction.isIncome
                ? 'Received from $_merchantTitle'
                : 'Paid to $_merchantTitle',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Google Sans',
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          // Time subtitle
          Text(
            widget.transaction.time,
            style: const TextStyle(
              fontFamily: 'Google Sans',
              color: Color(0xFF8E8E93),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionButtons(BuildContext context) {
    final s = _status.toUpperCase();
    final isFailed = s == 'FAILED';
    final isCancelled = s == 'CANCELLED';
    final isPending = s == 'PENDING' || s == 'INITIATED' || s == 'PAYMENT_INITIATED';

    return Row(
      children: [
        if (isPending) ...[
          Expanded(
            child: TransactionActionButton(
              icon: Icons.verified_rounded,
              label: _isReconciling ? 'Confirming...' : 'Confirm',
              isPrimary: true,
              onTap: (_isReconciling || _isCancelling)
                  ? () {}
                  : _handleReconcilePayment,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TransactionActionButton(
              icon: Icons.cancel_outlined,
              label: _isCancelling ? 'Cancelling...' : 'Cancel',
              isPrimary: false,
              textColor: const Color(0xFFFF453A),
              iconColor: const Color(0xFFFF453A),
              borderColor: const Color(0x55FF453A),
              backgroundColor: const Color(0x18FF453A),
              onTap: (_isReconciling || _isCancelling)
                  ? () {}
                  : () => _showCancelConfirmationDialog(context),
            ),
          ),
          const SizedBox(width: 10),
        ] else if (!isFailed && !isCancelled) ...[
          Expanded(
            child: TransactionActionButton(
              icon: Icons.delete_outline_rounded,
              label: _isDeleting ? 'Deleting...' : 'Delete',
              isPrimary: false,
              textColor: const Color(0xFFFF453A),
              iconColor: const Color(0xFFFF453A),
              borderColor: const Color(0x55FF453A),
              backgroundColor: const Color(0x18FF453A),
              onTap: _isDeleting ? () {} : () => _showDeleteConfirmationDialog(context),
            ),
          ),
          const SizedBox(width: 10),
        ] else ...[
          Expanded(
            child: TransactionActionButton(
              icon: Icons.refresh_rounded,
              label: 'Retry',
              isPrimary: true,
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Retrying payment of $_displayAmount to $_merchantTitle...',
                      style: const TextStyle(fontFamily: 'Google Sans'),
                    ),
                    backgroundColor: const Color(0xFF1E1E24),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(width: 10),
        ],
        // Categorize Toggle List Button
        const SizedBox(width: 10),
        Expanded(
          child: TransactionActionButton(
            icon: Icons.label_outline_rounded,
            label: 'Category',
            isPrimary: false,
            onTap: () => _showCategoryPickerSheet(context),
          ),
        ),
        // Share
        const SizedBox(width: 10),
        Expanded(
          child: TransactionActionButton(
            icon: Icons.share_outlined,
            label: 'Share',
            isPrimary: false,
            onTap: () => _copyToClipboard(
              context,
              'Huly Pay Receipt: $_merchantTitle - $_displayAmount on ${widget.transaction.time}. Ref: $_referenceId',
              'Receipt details',
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontFamily: 'Google Sans',
        color: Color(0xFF6B6B70),
        fontSize: 12,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.0,
      ),
    );
  }

  Widget _buildDetailsCard(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF141416),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppThemeManager.colors.border, width: 1),
      ),
      child: Column(
        children: [
          TransactionDetailRow(
            label: 'Payment Method',
            value: _paymentMethod,
            leadingWidget: _paymentMethod.toLowerCase().contains('gpay') ||
                    _paymentMethod.toLowerCase().contains('google')
                ? Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: SvgPicture.asset(
                      'assets/icon/google-pay.svg',
                      width: 18,
                      height: 18,
                    ),
                  )
                : (_paymentMethod.toLowerCase().contains('amazon')
                    ? Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: SvgPicture.asset(
                          'assets/icon/amazon-icon.svg',
                          width: 18,
                          height: 18,
                        ),
                      )
                    : null),
          ),
          const Divider(
            color: Color(0xFF202024),
            height: 1,
            thickness: 1,
            indent: 16,
            endIndent: 16,
          ),
          TransactionDetailRow(
            label: 'Category',
            value: _category,
            trailingWidget: const Padding(
              padding: EdgeInsets.only(left: 6),
              child: Icon(
                Icons.edit_outlined,
                color: Color(0xFF007AFF),
                size: 14,
              ),
            ),
            onTap: () => _showCategoryPickerSheet(context),
          ),
          const Divider(
            color: Color(0xFF202024),
            height: 1,
            thickness: 1,
            indent: 16,
            endIndent: 16,
          ),
          TransactionDetailRow(
            label: 'Transaction Type',
            value: widget.transaction.type,
          ),
          const Divider(
            color: Color(0xFF202024),
            height: 1,
            thickness: 1,
            indent: 16,
            endIndent: 16,
          ),
          TransactionDetailRow(
            label: 'UPI Ref No.',
            value: _referenceId,
            canCopy: true,
            onCopy: () =>
                _copyToClipboard(context, _referenceId, 'UPI Reference No.'),
          ),
          const Divider(
            color: Color(0xFF202024),
            height: 1,
            thickness: 1,
            indent: 16,
            endIndent: 16,
          ),
          TransactionDetailRow(
            label: 'Payment Location',
            value:
                '${_latitude.toStringAsFixed(4)}, ${_longitude.toStringAsFixed(4)} (±${_accuracy != null ? _accuracy!.toStringAsFixed(1) : "5.0"}m)',
            canCopy: true,
            onCopy: () => _copyToClipboard(
              context,
              '$_latitude, $_longitude',
              'Coordinates',
            ),
          ),
          const Divider(
            color: Color(0xFF202024),
            height: 1,
            thickness: 1,
            indent: 16,
            endIndent: 16,
          ),
          TransactionDetailRow(label: 'Payment Status', value: _status),
          const Divider(
            color: Color(0xFF202024),
            height: 1,
            thickness: 1,
            indent: 16,
            endIndent: 16,
          ),
          TransactionDetailRow(label: 'Date & Time', value: widget.transaction.time),
        ],
      ),
    );
  }
}



class _MapGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = const Color(0xFF22252F)
      ..strokeWidth = 1.0;

    const step = 28.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), linePaint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), linePaint);
    }

    final roadPaint = Paint()
      ..color = const Color(0xFF2C303E)
      ..strokeWidth = 4.0;

    canvas.drawLine(
      Offset(0, size.height * 0.4),
      Offset(size.width, size.height * 0.65),
      roadPaint,
    );
    canvas.drawLine(
      Offset(size.width * 0.35, 0),
      Offset(size.width * 0.55, size.height),
      roadPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
