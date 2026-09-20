import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/dashboard_data.dart';
import '../models/payment_model.dart';
import '../repositories/payment_repository.dart';
import '../services/auth_service.dart';
import '../services/local_database_service.dart';
import '../theme/app_theme.dart';

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
  bool _isStreetView = false;
  PaymentModel? _currentPayment;
  bool _isLoading = false;
  bool _isReconciling = false;
  bool _isCancelling = false;
  GoogleMapController? _mapController;
  final MapType _currentMapType = MapType.normal;
  String? _customCategory;
  final ValueNotifier<double> _sheetExtentNotifier = ValueNotifier<double>(
    0.54,
  );

  static const String _darkMapStyle = '''[
  {"elementType": "geometry", "stylers": [{"color": "#181a20"}]},
  {"elementType": "labels.icon", "stylers": [{"visibility": "off"}]},
  {"elementType": "labels.text.fill", "stylers": [{"color": "#8c93a0"}]},
  {"elementType": "labels.text.stroke", "stylers": [{"color": "#141416"}]},
  {"featureType": "administrative", "elementType": "geometry", "stylers": [{"color": "#383c48"}]},
  {"featureType": "administrative.country", "elementType": "labels.text.fill", "stylers": [{"color": "#9ca3af"}]},
  {"featureType": "poi", "elementType": "labels.text.fill", "stylers": [{"color": "#6b7280"}]},
  {"featureType": "poi.park", "elementType": "geometry", "stylers": [{"color": "#16221c"}]},
  {"featureType": "road", "elementType": "geometry.fill", "stylers": [{"color": "#232630"}]},
  {"featureType": "road", "elementType": "labels.text.fill", "stylers": [{"color": "#8a919e"}]},
  {"featureType": "road.arterial", "elementType": "geometry", "stylers": [{"color": "#2c313d"}]},
  {"featureType": "road.highway", "elementType": "geometry.fill", "stylers": [{"color": "#343b49"}]},
  {"featureType": "road.highway", "elementType": "geometry.stroke", "stylers": [{"color": "#222731"}]},
  {"featureType": "water", "elementType": "geometry", "stylers": [{"color": "#101622"}]},
  {"featureType": "water", "elementType": "labels.text.fill", "stylers": [{"color": "#4b5563"}]}
]''';

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

  static const List<Map<String, dynamic>> _kDefaultCategories = [
    {
      'name': 'Food & Dining',
      'icon': Icons.restaurant_rounded,
      'color': Color(0xFFFF9500),
      'description': 'Restaurants, cafes, food delivery & groceries',
    },
    {
      'name': 'Shopping',
      'icon': Icons.shopping_bag_rounded,
      'color': Color(0xFF007AFF),
      'description': 'E-commerce, apparel, electronics & retail',
    },
    {
      'name': 'Bills & Utilities',
      'icon': Icons.receipt_long_rounded,
      'color': Color(0xFFAF52DE),
      'description': 'Electricity, water, mobile recharge & broadband',
    },
    {
      'name': 'Transportation',
      'icon': Icons.directions_car_rounded,
      'color': Color(0xFF30D158),
      'description': 'Cabs, fuel, tolls, train & metro tickets',
    },
    {
      'name': 'Entertainment',
      'icon': Icons.movie_outlined,
      'color': Color(0xFFFF2D55),
      'description': 'Movies, streaming subscriptions & events',
    },
    {
      'name': 'Groceries',
      'icon': Icons.local_grocery_store_rounded,
      'color': Color(0xFF34C759),
      'description': 'Supermarkets, daily essentials & produce',
    },
    {
      'name': 'Health & Fitness',
      'icon': Icons.favorite_rounded,
      'color': Color(0xFF5AC8FA),
      'description': 'Pharmacies, clinics, doctors & gym',
    },
    {
      'name': 'Travel',
      'icon': Icons.flight_takeoff_rounded,
      'color': Color(0xFFFFCC00),
      'description': 'Hotels, flights & vacations',
    },
    {
      'name': 'Personal Care',
      'icon': Icons.spa_rounded,
      'color': Color(0xFFFF6482),
      'description': 'Salons, grooming & self-care',
    },
    {
      'name': 'Education',
      'icon': Icons.school_rounded,
      'color': Color(0xFF5856D6),
      'description': 'Courses, books & tuition fees',
    },
    {
      'name': 'Other',
      'icon': Icons.category_rounded,
      'color': Color(0xFF8E8E93),
      'description': 'General transactions & miscellaneous',
    },
  ];

  Future<void> _updateCategory(String newCategory, [BuildContext? targetContext]) async {
    final paymentId = widget.payment?.id ?? widget.transaction.id;
    setState(() {
      _customCategory = newCategory;
    });

    // 1. Persist category locally in metadata cache
    try {
      await LocalDatabaseService().setMetadata('category_$paymentId', newCategory);
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

    final messengerContext = targetContext ?? (mounted ? context : null);
    if (messengerContext != null) {
      try {
        ScaffoldMessenger.of(messengerContext).showSnackBar(
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

  void _showCategoryPickerSheet(BuildContext parentContext) {
    final messenger = ScaffoldMessenger.of(parentContext);
    showModalBottomSheet(
      context: parentContext,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF141416),
      barrierColor: Colors.black.withValues(alpha: 0.65),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (BuildContext sheetCtx) {
        return StatefulBuilder(
          builder: (sheetInnerCtx, setSheetState) {
            final activeCategory = _category;

            return SafeArea(
              child: Container(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(sheetCtx).size.height * 0.75,
                ),
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Sheet Drag Handle
                    Center(
                      child: Container(
                        width: 40,
                        height: 4.5,
                        decoration: BoxDecoration(
                          color: const Color(0xFF383842),
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Header with title and close button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Categorize Payment',
                                style: TextStyle(
                                  fontFamily: 'Google Sans',
                                  color: Colors.white,
                                  fontSize: 19,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Assign a category for budgeting and analytics',
                                style: TextStyle(
                                  fontFamily: 'Google Sans',
                                  color: Color(0xFF8E8E93),
                                  fontSize: 12.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close_rounded, color: Color(0xFF8E8E93), size: 22),
                          splashRadius: 20,
                          onPressed: () => Navigator.of(sheetCtx).pop(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),

                    // Category Toggle List
                    Flexible(
                      child: ListView.separated(
                        shrinkWrap: true,
                        physics: const BouncingScrollPhysics(),
                        itemCount: _kDefaultCategories.length,
                        separatorBuilder: (ctx, idx) => const SizedBox(height: 8),
                        itemBuilder: (ctx, idx) {
                          final item = _kDefaultCategories[idx];
                          final String catName = item['name'] as String;
                          final IconData catIcon = item['icon'] as IconData;
                          final Color catColor = item['color'] as Color;
                          final String catDesc = item['description'] as String;
                          final bool isSelected = activeCategory.toLowerCase() == catName.toLowerCase();

                          return Material(
                            color: isSelected
                                ? catColor.withValues(alpha: 0.14)
                                : const Color(0xFF1B1B1F),
                            borderRadius: BorderRadius.circular(16),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(16),
                              onTap: () {
                                Navigator.of(sheetCtx).pop();
                                _updateCategory(catName, parentContext);
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: isSelected
                                        ? catColor
                                        : const Color(0xFF282830),
                                    width: isSelected ? 1.5 : 1.0,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: catColor.withValues(alpha: 0.16),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Icon(catIcon, color: catColor, size: 20),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            catName,
                                            style: TextStyle(
                                              fontFamily: 'Google Sans',
                                              color: isSelected ? Colors.white : const Color(0xFFE4E4E6),
                                              fontSize: 15,
                                              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            catDesc,
                                            style: const TextStyle(
                                              fontFamily: 'Google Sans',
                                              color: Color(0xFF8E8E93),
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (isSelected)
                                      Container(
                                        width: 22,
                                        height: 22,
                                        decoration: BoxDecoration(
                                          color: catColor,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.check_rounded,
                                          color: Colors.black,
                                          size: 15,
                                        ),
                                      )
                                    else
                                      Container(
                                        width: 20,
                                        height: 20,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: const Color(0xFF484852),
                                            width: 1.5,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
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
                child: _buildGoogleMapOrStreetView(),
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
                        const SizedBox(height: 24),
                        _buildSupportCard(context),
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

  Widget _buildGoogleMapOrStreetView() {
    return _isStreetView ? _buildStreetViewContent() : _buildGoogleMapContent();
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
              GestureDetector(
                key: const Key('map_mode_button'),
                onTap: () {
                  if (_isStreetView) setState(() => _isStreetView = false);
                },
                behavior: HitTestBehavior.opaque,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 11,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: !_isStreetView
                        ? const Color(0xFF007AFF)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Text(
                    'MAP',
                    style: TextStyle(
                      fontFamily: 'Google Sans',
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: !_isStreetView
                          ? Colors.white
                          : const Color(0xFF8E8E93),
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 11,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: _isStreetView
                        ? const Color(0xFF007AFF)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Text(
                    'STREET VIEW',
                    style: TextStyle(
                      fontFamily: 'Google Sans',
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: _isStreetView
                          ? Colors.white
                          : const Color(0xFF8E8E93),
                    ),
                  ),
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

  Widget _buildGoogleMapContent() {
    // In automated widget testing environments or headless test runs, render visual dark map canvas
    if (kIsWeb ||
        (defaultTargetPlatform != TargetPlatform.android &&
            defaultTargetPlatform != TargetPlatform.iOS)) {
      return _buildDarkMapFallbackCanvas();
    }

    final targetPos = LatLng(_latitude, _longitude);

    try {
      return GoogleMap(
        initialCameraPosition: CameraPosition(target: targetPos, zoom: 16.0),
        mapType: _currentMapType,
        style: _darkMapStyle,
        markers: {
          Marker(
            markerId: const MarkerId('payment_marker'),
            position: targetPos,
            infoWindow: InfoWindow(
              title: _merchantTitle,
              snippet:
                  'Payment Location: ${_latitude.toStringAsFixed(4)}, ${_longitude.toStringAsFixed(4)}',
            ),
            icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueRed,
            ),
          ),
        },
        circles: {
          Circle(
            circleId: const CircleId('payment_accuracy_circle'),
            center: targetPos,
            radius: (_accuracy != null && _accuracy! > 0) ? _accuracy! : 20.0,
            fillColor: const Color(0x28007AFF),
            strokeColor: const Color(0x80007AFF),
            strokeWidth: 1,
          ),
        },
        gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
          Factory<OneSequenceGestureRecognizer>(() => EagerGestureRecognizer()),
        },
        zoomControlsEnabled: false,
        myLocationButtonEnabled: false,
        mapToolbarEnabled: false,
        compassEnabled: true,
        onMapCreated: (GoogleMapController controller) {
          _mapController = controller;
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
    return Container(
      color: const Color(0xFF121215),
      alignment: const Alignment(0, -0.42),
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
            const SizedBox(height: 10),
            GestureDetector(
              onTap: _handleOpenStreetViewExternal,
              behavior: HitTestBehavior.opaque,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E24),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF2A2A30)),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.open_in_new_rounded,
                      color: Color(0xFF007AFF),
                      size: 13,
                    ),
                    SizedBox(width: 6),
                    Text(
                      'Check 360° in Google Maps',
                      style: TextStyle(
                        fontFamily: 'Google Sans',
                        color: Color(0xFF007AFF),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
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
            child: _buildActionButton(
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
            child: _buildActionButton(
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
            child: _buildActionButton(
              icon: Icons.replay_rounded,
              label: 'Pay Again',
              isPrimary: true,
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Initiating repeat payment to $_merchantTitle...',
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
        ] else ...[
          Expanded(
            child: _buildActionButton(
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
          child: _buildActionButton(
            icon: Icons.label_outline_rounded,
            label: 'Category',
            isPrimary: false,
            onTap: () => _showCategoryPickerSheet(context),
          ),
        ),
        // Share
        const SizedBox(width: 10),
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
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required bool isPrimary,
    required VoidCallback onTap,
    Color? textColor,
    Color? iconColor,
    Color? backgroundColor,
    Color? borderColor,
  }) {
    final effectiveBgColor = backgroundColor ??
        (isPrimary ? Colors.white : const Color(0xFF141416));
    final effectiveFgColor = isPrimary ? Colors.black : Colors.white;
    final effectiveTextColor = textColor ?? effectiveFgColor;
    final effectiveIconColor = iconColor ?? effectiveFgColor;
    final effectiveBorder = borderColor != null
        ? Border.all(color: borderColor, width: 1)
        : (isPrimary
            ? null
            : Border.all(color: AppThemeManager.colors.border, width: 1));

    return Material(
      color: effectiveBgColor,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: effectiveBorder,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: effectiveIconColor,
                size: 20,
              ),
              const SizedBox(height: 6),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: 'Google Sans',
                  color: effectiveTextColor,
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
        border: Border.all(color: AppThemeManager.colors.border, width: 1),
      ),
      child: Column(
        children: [
          _buildDetailRow(
            label: 'Payment Method',
            value: _paymentMethod,
            leadingWidget: _paymentMethod.toLowerCase().contains('gpay') ||
                    _paymentMethod.toLowerCase().contains('google')
                ? Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: SvgPicture.asset(
                      'assets/icon/google-pay-icon.svg',
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
          _buildDetailRow(
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
          _buildDetailRow(
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
          _buildDetailRow(
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
          _buildDetailRow(
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
          _buildDetailRow(label: 'Payment Status', value: _status),
          const Divider(
            color: Color(0xFF202024),
            height: 1,
            thickness: 1,
            indent: 16,
            endIndent: 16,
          ),
          _buildDetailRow(label: 'Date & Time', value: widget.transaction.time),
        ],
      ),
    );
  }

  Widget _buildDetailRow({
    required String label,
    required String value,
    Widget? leadingWidget,
    Widget? trailingWidget,
    bool canCopy = false,
    VoidCallback? onCopy,
    VoidCallback? onTap,
  }) {
    final content = Padding(
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
                ?leadingWidget,
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
                ?trailingWidget,
              ],
            ),
          ),
        ],
      ),
    );

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: content,
        ),
      );
    }
    return content;
  }

  Widget _buildSupportCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF141416),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppThemeManager.colors.border, width: 1),
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
                border: Border.all(color: const Color(0xFF2A2A30), width: 1),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.flag_outlined, color: Color(0xFFFF453A), size: 16),
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
