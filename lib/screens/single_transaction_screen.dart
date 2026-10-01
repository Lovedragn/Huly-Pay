import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../data/external_data.dart';
import '../models/dashboard_data.dart';
import '../models/transaction_model.dart';
import '../repositories/transaction_repository.dart';
import '../services/auth_service.dart';
import '../services/local_database_service.dart';
import '../services/transaction_pdf_service.dart';
import '../theme/app_theme.dart';
import '../widgets/category_picker_sheet.dart';
import '../widgets/edit_amount_sheet.dart';
import '../widgets/transaction_detail_components.dart';
import '../widgets/transaction_details_card.dart';
import '../widgets/transaction_map_section.dart';
import '../widgets/transaction_receipt_card.dart';

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
  bool _hasChanged = false;
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
      final payment = await TransactionRepository().getTransactionById(idToFetch);
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

  TransactionCategoryItem? get _matchedCategoryItem {
    final cur = _category.toLowerCase().trim();
    for (final item in ExternalData.defaultCategories) {
      if (item.name.toLowerCase() == cur ||
          item.name.toLowerCase().contains(cur) ||
          cur.contains(item.name.toLowerCase())) {
        return item;
      }
    }
    return null;
  }

  String get _status {
    if (_currentPayment != null) {
      return _currentPayment!.status;
    }
    return widget.transaction.isFailed ? 'FAILED' : 'CONFIRMED';
  }

  double get _numericAmount {
    if (_currentPayment != null) {
      return _currentPayment!.amount;
    }
    final clean = widget.transaction.amount.replaceAll(RegExp(r'[^0-9.]'), '');
    return double.tryParse(clean) ?? 0.0;
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

  bool _isGeneratingPdf = false;

  Future<void> _handleShare() async {
    if (_isGeneratingPdf) return;
    setState(() => _isGeneratingPdf = true);

    try {
      final pdfPath = await TransactionPdfService.generateReceipt(
        merchantTitle: _merchantTitle,
        displayAmount: _displayAmount,
        status: _status,
        dateTime: widget.transaction.time,
        paymentMethod: _paymentMethod,
        referenceId: _referenceId,
        upiTransactionId: _currentPayment?.upiTransactionId,
        upiId: _currentPayment?.upiId,
        category: _category,
        provider: _currentPayment?.provider,
        currency: _currentPayment?.currency ?? 'INR',
        latitude: _currentPayment?.latitude,
        longitude: _currentPayment?.longitude,
        accuracy: _currentPayment?.locationAccuracyMeters,
        transactionType: widget.transaction.type,
        createdAt: _currentPayment?.createdAt,
        isIncome: widget.transaction.isIncome,
      );

      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(pdfPath, mimeType: 'application/pdf')],
          subject: 'Huly Pay Receipt: $_merchantTitle ($_displayAmount)',
          text: 'Payment receipt for $_displayAmount to $_merchantTitle — generated by Huly Pay.',
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Could not generate receipt: $e',
              style: const TextStyle(fontFamily: 'Google Sans'),
            ),
            backgroundColor: const Color(0xFFD93025),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isGeneratingPdf = false);
      }
    }
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

  Future<void> _handleOpenStreetViewExternal() async {
    final url = Uri.parse(
      'https://www.google.com/maps/@?api=1&map_action=pano&viewpoint=$_latitude,$_longitude',
    );
    try {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } catch (_) {}
  }

  Future<void> _showEditAmountSheet() async {
    final paymentId = _currentPayment?.id ?? widget.transaction.id;

    final updatedAmount = await EditAmountSheet.show(
      context,
      currentAmount: _numericAmount,
      merchantTitle: _merchantTitle,
      onSave: (newAmount) async {
        try {
          final updated = await TransactionRepository().updateTransactionAmount(
            paymentId,
            newAmount,
          );
          if (mounted) {
            setState(() {
              _hasChanged = true;
              if (updated != null) {
                _currentPayment = updated;
              } else if (_currentPayment != null) {
                _currentPayment = _currentPayment!.copyWith(amount: newAmount);
              }
            });
          }
          return true;
        } catch (_) {
          return false;
        }
      },
    );

    if (!mounted || updatedAmount == null) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Color(0xFF30D158), size: 18),
            const SizedBox(width: 8),
            Text(
              'Amount updated to ₹${updatedAmount.toStringAsFixed(2)}',
              style: const TextStyle(
                fontFamily: 'Google Sans',
                color: Colors.white,
                fontWeight: FontWeight.w500,
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
  }

  Future<void> _handleReconcilePayment() async {
    final paymentId = _currentPayment?.id ?? widget.transaction.id;
    setState(() => _isReconciling = true);

    try {
      final updated = await TransactionRepository().reconcileTransaction(
        paymentId,
        'CONFIRMED',
        upiTransactionId: 'UPI_${DateTime.now().millisecondsSinceEpoch}',
        transactionReference: 'REF_${DateTime.now().millisecondsSinceEpoch}',
      );
      if (mounted) {
        setState(() {
          _currentPayment = updated;
          _isReconciling = false;
          _hasChanged = true;
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
          content: Text(
            'Successful transactions are finalized and cannot be deleted or cancelled.',
          ),
          backgroundColor: Color(0xFF1E1E24),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final paymentId = _currentPayment?.id ?? widget.transaction.id;
    setState(() => _isCancelling = true);

    try {
      final updated = await TransactionRepository().reconcileTransaction(
        paymentId,
        'CANCELLED',
      );
      if (mounted) {
        setState(() {
          _currentPayment = updated;
          _isCancelling = false;
          _hasChanged = true;
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
      await TransactionRepository().deleteTransaction(paymentId);
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
      _hasChanged = true;
    });

    // 1. Persist category locally in metadata cache
    try {
      await LocalDatabaseService().setMetadata('category_$paymentId', newCategory);
    } catch (_) {}

    // 1b. Persist UPI ID → category mapping for auto-categorization
    try {
      final upiId = _currentPayment?.upiId ?? widget.payment?.upiId;
      if (upiId != null && upiId.trim().isNotEmpty) {
        await LocalDatabaseService().setMetadata(
          'upi_category_${upiId.toLowerCase().trim()}',
          newCategory,
        );
      }
    } catch (_) {}

    // 1c. Persist merchant name → category mapping for auto-categorization
    try {
      final merchant = _merchantTitle;
      if (merchant.trim().isNotEmpty) {
        await LocalDatabaseService().setMetadata(
          'merchant_category_${merchant.toLowerCase().trim()}',
          newCategory,
        );
      }
    } catch (_) {}

    // 2. If cached locally, update paymentMethod
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

    // 3. Update Supabase transactions table
    try {
      final client = AuthService().client;
      if (client != null && !paymentId.startsWith('tx_') && !paymentId.startsWith('local_')) {
        try {
          await client.from('transactions').update({
            'category': newCategory,
            'updated_at': DateTime.now().toUtc().toIso8601String(),
          }).eq('id', paymentId);
        } catch (_) {}
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
          Navigator.of(context).pop(_hasChanged ? true : _customCategory);
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
                child: TransactionMapSection(
                  latitude: _latitude,
                  longitude: _longitude,
                  accuracy: _accuracy,
                  merchantTitle: _merchantTitle,
                  mapViewMode: _mapViewMode,
                  onModeChanged: (mode) => setState(() => _mapViewMode = mode),
                  onMapCreated: (ctrl) => _mapController = ctrl,
                  screenHeight: mediaQuery.size.height,
                ),
              ),
            ),

            // 2. FIXED TOP-LEFT BACK BUTTON
            Positioned(
              top: topPadding + 10,
              left: 16,
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(_hasChanged ? true : _customCategory),
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

            // 3. FIXED TOP-RIGHT SHARE BUTTON (generates PDF receipt)
            Positioned(
              top: topPadding + 10,
              right: 16,
              child: GestureDetector(
                onTap: _isGeneratingPdf ? null : _handleShare,
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
                  child: Center(
                    child: _isGeneratingPdf
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.share_rounded, color: Colors.white, size: 20),
                  ),
                ),
              ),
            ),

            // 4. OVERLAPPING DETAILS SHEET
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
                          TransactionMapControlBar(
                            mapViewMode: _mapViewMode,
                            onModeChanged: (mode) => setState(() => _mapViewMode = mode),
                            onStartRoute: _handleStartRoute,
                            onOpenStreetView: _handleOpenStreetViewExternal,
                          ),
                          const SizedBox(height: 14),
                          // Hero Receipt Card
                          TransactionReceiptCard(
                            status: _status,
                            displayAmount: _displayAmount,
                            merchantTitle: _merchantTitle,
                            time: widget.transaction.time,
                            isIncome: widget.transaction.isIncome,
                          ),
                          const SizedBox(height: 18),
                          // Quick Action Buttons
                          _buildQuickActionButtons(context),
                          const SizedBox(height: 24),
                          // Section Header
                          _buildSectionHeader('TRANSACTION DETAILS'),
                          const SizedBox(height: 12),
                          // Details Card
                          TransactionDetailsCard(
                            paymentMethod: _paymentMethod,
                            category: _category,
                            transactionType: widget.transaction.type,
                            referenceId: _referenceId,
                            latitude: _latitude,
                            longitude: _longitude,
                            accuracy: _accuracy,
                            status: _status,
                            time: widget.transaction.time,
                            onCategoryTap: () => _showCategoryPickerSheet(context),
                            onCopy: (text, label) => _copyToClipboard(context, text, label),
                          ),
                          const SizedBox(height: 36),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            // 5. TOP PROGRESS INDICATOR
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

  Widget _buildQuickActionButtons(BuildContext context) {
    final s = _status.toUpperCase();
    final isFailed = s == 'FAILED';
    final isCancelled = s == 'CANCELLED';
    final isPending = s == 'PENDING' || s == 'INITIATED' || s == 'PAYMENT_INITIATED';

    final categoryItem = _matchedCategoryItem;

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

        // Category Action Button - Displays selected category icon & symbol directly
        Expanded(
          child: TransactionActionButton(
            icon: categoryItem?.icon ?? Icons.label_outline_rounded,
            customIcon: categoryItem != null
                ? Icon(
                    categoryItem.icon,
                    color: categoryItem.color,
                    size: 20,
                  )
                : null,
            label: categoryItem != null ? categoryItem.name.split(' ').first : 'Category',
            isPrimary: false,
            onTap: () => _showCategoryPickerSheet(context),
          ),
        ),

        const SizedBox(width: 10),

        // Edit Amount Action Button (placed where the Share button used to be)
        Expanded(
          child: TransactionActionButton(
            icon: Icons.edit_outlined,
            label: 'Edit',
            isPrimary: false,
            onTap: _showEditAmountSheet,
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
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.2,
      ),
    );
  }
}
