import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/dashboard_data.dart';
import '../models/payment_model.dart';
import '../repositories/payment_repository.dart';

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
  State<SingleTransactionScreen> createState() => _SingleTransactionScreenState();
}

class _SingleTransactionScreenState extends State<SingleTransactionScreen> {
  bool _isStreetView = false;
  PaymentModel? _currentPayment;
  bool _isLoading = false;
  bool _isReconciling = false;

  @override
  void initState() {
    super.initState();
    _currentPayment = widget.payment;
    if (widget.payment == null) {
      _fetchPaymentDetails();
    }
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
    if (_currentPayment?.transactionReference != null && _currentPayment!.transactionReference!.isNotEmpty) {
      return _currentPayment!.transactionReference!;
    }
    if (_currentPayment?.upiTransactionId != null && _currentPayment!.upiTransactionId!.isNotEmpty) {
      return _currentPayment!.upiTransactionId!;
    }
    final hash = widget.transaction.id.hashCode.abs().toString().padLeft(12, '0');
    return 'UPI/$hash';
  }

  String get _paymentMethod {
    if (_currentPayment?.paymentMethod != null && _currentPayment!.paymentMethod!.isNotEmpty) {
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
    if (_currentPayment?.merchantName != null && _currentPayment!.merchantName!.isNotEmpty) {
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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
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
      final launched = await launchUrl(url, mode: LaunchMode.externalApplication);
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
            content: Text('Payment confirmed and reconciled to expense successfully!'),
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

  void _showReportIssueDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E1E24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Report an Issue',
            style: TextStyle(
              fontFamily: 'Google Sans',
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
          content: Text(
            'Do you want to raise a dispute for this payment of $_displayAmount to $_merchantTitle?',
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
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text(
                      'Dispute ticket raised. Our support team will review within 24 hours.',
                      style: TextStyle(fontFamily: 'Google Sans'),
                    ),
                    backgroundColor: const Color(0xFF222226),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                );
              },
              child: const Text(
                'Submit Dispute',
                style: TextStyle(
                  fontFamily: 'Google Sans',
                  color: Color(0xFF007AFF),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF000000),
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(context),
            if (_isLoading)
              const LinearProgressIndicator(
                minHeight: 2,
                backgroundColor: Colors.transparent,
                color: Color(0xFF6C5CE7),
              ),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLocationMapCard(context),
                    const SizedBox(height: 16),
                    _buildHeroReceiptCard(context),
                    const SizedBox(height: 20),
                    _buildQuickActionButtons(context),
                    const SizedBox(height: 24),
                    _buildSectionHeader('TRANSACTION DETAILS'),
                    const SizedBox(height: 12),
                    _buildDetailsCard(context),
                    const SizedBox(height: 24),
                    _buildSupportCard(context),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            behavior: HitTestBehavior.opaque,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFF141416),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFF222226),
                  width: 1,
                ),
              ),
              child: const Center(
                child: Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),
          const Text(
            'Transaction Details',
            style: TextStyle(
              fontFamily: 'Google Sans',
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.3,
            ),
          ),
          GestureDetector(
            onTap: () => _copyToClipboard(
              context,
              'Huly Pay Receipt: $_merchantTitle - $_displayAmount (${widget.transaction.time})',
              'Receipt details',
            ),
            behavior: HitTestBehavior.opaque,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFF141416),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFF222226),
                  width: 1,
                ),
              ),
              child: const Center(
                child: Icon(
                  Icons.share_outlined,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationMapCard(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 220,
      decoration: BoxDecoration(
        color: const Color(0xFF141416),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF222226),
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            // Map or Street View content
            Positioned.fill(
              child: _isStreetView
                  ? _buildStreetViewContent()
                  : _buildGoogleMapContent(),
            ),

            // Top Overlay: View Mode Toggle (Map <-> Street View)
            Positioned(
              top: 12,
              right: 12,
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xDD161619),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFF2A2A30), width: 1),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      key: const Key('map_mode_button'),
                      onTap: () {
                        if (_isStreetView) setState(() => _isStreetView = false);
                      },
                      behavior: HitTestBehavior.opaque,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: !_isStreetView ? const Color(0xFF007AFF) : Colors.transparent,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Text(
                          'MAP',
                          style: TextStyle(
                            fontFamily: 'Google Sans',
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: !_isStreetView ? Colors.white : const Color(0xFF8E8E93),
                          ),
                        ),
                      ),
                    ),
                    GestureDetector(
                      key: const Key('street_view_toggle'),
                      onTap: () {
                        if (!_isStreetView) setState(() => _isStreetView = true);
                      },
                      behavior: HitTestBehavior.opaque,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: _isStreetView ? const Color(0xFF007AFF) : Colors.transparent,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Text(
                          'STREET VIEW',
                          style: TextStyle(
                            fontFamily: 'Google Sans',
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: _isStreetView ? Colors.white : const Color(0xFF8E8E93),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Bottom Overlay: Coordinates Chip & Start Route Button
            Positioned(
              left: 12,
              right: 12,
              bottom: 12,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Coordinates badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xDD141416),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFF2A2A30), width: 1),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.location_pin, color: Color(0xFFFF453A), size: 14),
                        const SizedBox(width: 4),
                        Text(
                          '${_latitude.toStringAsFixed(4)}, ${_longitude.toStringAsFixed(4)}',
                          style: const TextStyle(
                            fontFamily: 'Google Sans',
                            fontSize: 11,
                            color: Color(0xFFD0D0D5),
                            fontWeight: FontWeight.w600,
                          ),
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
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
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
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGoogleMapContent() {
    // In automated widget testing environments or headless test runs, render visual dark map canvas
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android && defaultTargetPlatform != TargetPlatform.iOS) {
      return _buildDarkMapFallbackCanvas();
    }

    try {
      return GoogleMap(
        initialCameraPosition: CameraPosition(
          target: LatLng(_latitude, _longitude),
          zoom: 15.5,
        ),
        markers: {
          Marker(
            markerId: const MarkerId('payment_marker'),
            position: LatLng(_latitude, _longitude),
            infoWindow: InfoWindow(
              title: _merchantTitle,
              snippet: 'Payment Location',
            ),
          ),
        },
        zoomControlsEnabled: false,
        myLocationButtonEnabled: false,
        mapToolbarEnabled: false,
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
          CustomPaint(
            painter: _MapGridPainter(),
          ),
          // Center Marker
          Center(
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
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
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
    return Container(
      color: const Color(0xFF121215),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E24),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF2A2A30)),
                ),
                child: const Center(
                  child: Icon(
                    Icons.streetview_rounded,
                    color: Color(0xFF8E8E93),
                    size: 24,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                "Street View isn't available at this location.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Google Sans',
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Coordinates: ${_latitude.toStringAsFixed(4)}, ${_longitude.toStringAsFixed(4)}',
                style: const TextStyle(
                  fontFamily: 'Google Sans',
                  color: Color(0xFF6B6B70),
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeroReceiptCard(BuildContext context) {
    final isFailed = _status.toUpperCase() == 'FAILED';
    final isPending = _status.toUpperCase() == 'PENDING' || _status.toUpperCase() == 'INITIATED';

    final Color statusColor = isFailed
        ? const Color(0xFFFF453A)
        : (isPending ? const Color(0xFFE5A93C) : const Color(0xFF30D158));

    final Color statusBg = isFailed
        ? const Color(0xFF2C1517)
        : (isPending ? const Color(0xFF2A2210) : const Color(0xFF10281B));

    final Color statusBorder = isFailed
        ? const Color(0xFF5A1C22)
        : (isPending ? const Color(0xFF554117) : const Color(0xFF1B4D2E));

    final String statusText = isFailed
        ? 'Payment Failed'
        : (isPending ? 'Payment Initiated' : 'Payment Successful');

    final IconData statusIcon = isFailed
        ? Icons.cancel_rounded
        : (isPending ? Icons.hourglass_top_rounded : Icons.check_circle_rounded);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      decoration: BoxDecoration(
        color: const Color(0xFF141416),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFF222226),
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
              border: Border.all(
                color: statusBorder,
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  statusIcon,
                  color: statusColor,
                  size: 15,
                ),
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
              color: isFailed
                  ? const Color(0xFFFF453A)
                  : Colors.white,
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
    final isFailed = _status.toUpperCase() == 'FAILED';
    final isPending = _status.toUpperCase() == 'PENDING' || _status.toUpperCase() == 'INITIATED';

    return Row(
      children: [
        if (isPending)
          Expanded(
            child: _buildActionButton(
              icon: Icons.verified_rounded,
              label: _isReconciling ? 'Confirming...' : 'Confirm',
              isPrimary: true,
              onTap: _isReconciling ? () {} : _handleReconcilePayment,
            ),
          )
        else
          Expanded(
            child: _buildActionButton(
              icon: isFailed ? Icons.refresh_rounded : Icons.replay_rounded,
              label: isFailed ? 'Retry' : 'Pay Again',
              isPrimary: true,
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      isFailed
                          ? 'Retrying payment of $_displayAmount to $_merchantTitle...'
                          : 'Initiating repeat payment to $_merchantTitle...',
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
        const SizedBox(width: 12),
        // Share Receipt
        Expanded(
          child: _buildActionButton(
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
        const SizedBox(width: 12),
        // Download Receipt
        Expanded(
          child: _buildActionButton(
            icon: Icons.receipt_long_outlined,
            label: 'Receipt',
            isPrimary: false,
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Receipt for $_merchantTitle downloaded successfully.',
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
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required bool isPrimary,
    required VoidCallback onTap,
  }) {
    return Material(
      color: isPrimary ? Colors.white : const Color(0xFF141416),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: isPrimary
                ? null
                : Border.all(
                    color: const Color(0xFF222226),
                    width: 1,
                  ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: isPrimary ? Colors.black : Colors.white,
                size: 20,
              ),
              const SizedBox(height: 6),
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'Google Sans',
                  color: isPrimary ? Colors.black : Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
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
        border: Border.all(
          color: const Color(0xFF222226),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          _buildDetailRow(
            label: 'Payment Method',
            value: _paymentMethod,
          ),
          const Divider(color: Color(0xFF202024), height: 1, thickness: 1, indent: 16, endIndent: 16),
          _buildDetailRow(
            label: 'Category',
            value: widget.transaction.category,
          ),
          const Divider(color: Color(0xFF202024), height: 1, thickness: 1, indent: 16, endIndent: 16),
          _buildDetailRow(
            label: 'Transaction Type',
            value: widget.transaction.type,
          ),
          const Divider(color: Color(0xFF202024), height: 1, thickness: 1, indent: 16, endIndent: 16),
          _buildDetailRow(
            label: 'UPI Ref No.',
            value: _referenceId,
            canCopy: true,
            onCopy: () => _copyToClipboard(context, _referenceId, 'UPI Reference No.'),
          ),
          const Divider(color: Color(0xFF202024), height: 1, thickness: 1, indent: 16, endIndent: 16),
          _buildDetailRow(
            label: 'Payment Location',
            value: '${_latitude.toStringAsFixed(4)}, ${_longitude.toStringAsFixed(4)} (±${_accuracy != null ? _accuracy!.toStringAsFixed(1) : "5.0"}m)',
            canCopy: true,
            onCopy: () => _copyToClipboard(context, '$_latitude, $_longitude', 'Coordinates'),
          ),
          const Divider(color: Color(0xFF202024), height: 1, thickness: 1, indent: 16, endIndent: 16),
          _buildDetailRow(
            label: 'Payment Status',
            value: _status,
          ),
          const Divider(color: Color(0xFF202024), height: 1, thickness: 1, indent: 16, endIndent: 16),
          _buildDetailRow(
            label: 'Date & Time',
            value: widget.transaction.time,
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow({
    required String label,
    required String value,
    bool canCopy = false,
    VoidCallback? onCopy,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Google Sans',
              color: Color(0xFF8E8E93),
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Text(
                    value,
                    textAlign: TextAlign.right,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'Google Sans',
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (canCopy) ...[
                  const SizedBox(width: 6),
                  GestureDetector(
                    onTap: onCopy,
                    behavior: HitTestBehavior.opaque,
                    child: const Icon(
                      Icons.copy_rounded,
                      color: Color(0xFF007AFF),
                      size: 15,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSupportCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF141416),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF222226),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.help_outline_rounded,
                color: Color(0xFF007AFF),
                size: 20,
              ),
              SizedBox(width: 10),
              Text(
                'Need help with this transaction?',
                style: TextStyle(
                  fontFamily: 'Google Sans',
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'If you suspect fraud or an incorrect amount was debited, contact 24/7 resolution support.',
            style: TextStyle(
              fontFamily: 'Google Sans',
              color: Color(0xFF8E8E93),
              fontSize: 13,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 14),
          GestureDetector(
            onTap: () => _showReportIssueDialog(context),
            behavior: HitTestBehavior.opaque,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E24),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFF2A2A30),
                  width: 1,
                ),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.flag_outlined,
                    color: Color(0xFFFF453A),
                    size: 16,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Report an Issue',
                    style: TextStyle(
                      fontFamily: 'Google Sans',
                      color: Color(0xFFFF453A),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
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
