import 'package:flutter/material.dart';
import 'dashboard_data.dart';

class TransactionModel {
  final String id;
  final String? userId;
  final String? expenseId;
  final double amount;
  final String currency;
  final String? upiTransactionId;
  final String? upiId;
  final String? merchantName;
  final String? category;
  final String? paymentMethod;
  final String? transactionReference;
  final String status;
  final String? provider;
  final double? latitude;
  final double? longitude;
  final double? locationAccuracyMeters;
  final String? paymentDate;
  final String? paymentTime;
  final String? createdAt;
  final String? updatedAt;

  TransactionModel({
    required this.id,
    this.userId,
    this.expenseId,
    required this.amount,
    required this.currency,
    this.upiTransactionId,
    this.upiId,
    this.merchantName,
    this.category,
    this.paymentMethod,
    this.transactionReference,
    required this.status,
    this.provider,
    this.latitude,
    this.longitude,
    this.locationAccuracyMeters,
    this.paymentDate,
    this.paymentTime,
    this.createdAt,
    this.updatedAt,
  });

  /// Whether this transaction is currently pending/initiated.
  bool get isPending {
    final s = status.toUpperCase().trim();
    return s == 'PENDING' || s == 'INITIATED' || s == 'PAYMENT_INITIATED';
  }

  /// Whether this transaction completed successfully.
  /// Only completed / confirmed / paid / settled statuses count as successful.
  bool get isSuccessful {
    final s = status.toUpperCase().trim();
    if (s == 'FAILED' ||
        s == 'CANCELLED' ||
        s == 'TIMEOUT' ||
        s == 'DECLINED' ||
        s == 'REJECTED' ||
        s == 'PENDING' ||
        s == 'INITIATED' ||
        s == 'PAYMENT_INITIATED') {
      return false;
    }
    return true;
  }

  TransactionModel copyWith({
    String? id,
    String? userId,
    String? expenseId,
    double? amount,
    String? currency,
    String? upiTransactionId,
    String? upiId,
    String? merchantName,
    String? category,
    String? paymentMethod,
    String? transactionReference,
    String? status,
    String? provider,
    double? latitude,
    double? longitude,
    double? locationAccuracyMeters,
    String? paymentDate,
    String? paymentTime,
    String? createdAt,
    String? updatedAt,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      expenseId: expenseId ?? this.expenseId,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      upiTransactionId: upiTransactionId ?? this.upiTransactionId,
      upiId: upiId ?? this.upiId,
      merchantName: merchantName ?? this.merchantName,
      category: category ?? this.category,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      transactionReference: transactionReference ?? this.transactionReference,
      status: status ?? this.status,
      provider: provider ?? this.provider,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      locationAccuracyMeters: locationAccuracyMeters ?? this.locationAccuracyMeters,
      paymentDate: paymentDate ?? this.paymentDate,
      paymentTime: paymentTime ?? this.paymentTime,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Formats raw merchant names or UPI IDs into clean, readable merchant names.
  /// Handles VPAs like "cafe_coffee_day@okhdfcbank" -> "Cafe Coffee Day",
  /// "9876543210@paytm" -> "Merchant (9876543210)", etc.
  static String formatMerchantName(String? raw) {
    if (raw == null) return 'UPI Merchant';
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return 'UPI Merchant';

    // If it's a UPI ID / VPA handle containing '@'
    if (trimmed.contains('@')) {
      final handle = trimmed.split('@').first.trim();
      if (handle.isEmpty) return 'UPI Merchant';

      // If handle is a pure numeric phone number or ID
      if (RegExp(r'^\d+$').hasMatch(handle)) {
        return 'Merchant ($handle)';
      }

      // Replace delimiters (. _ - +) with spaces
      final cleaned = handle.replaceAll(RegExp(r'[._\-\+]'), ' ').trim();
      if (cleaned.isEmpty) return 'UPI Merchant';

      return cleaned
          .split(RegExp(r'\s+'))
          .where((w) => w.isNotEmpty)
          .map((w) => w[0].toUpperCase() + w.substring(1).toLowerCase())
          .join(' ');
    }

    return trimmed;
  }

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    final rawMerchant = (json['merchantName'] ?? json['merchant_name']) as String?;
    final rawUpi = (json['upiId'] ?? json['upi_id']) as String?;
    final resolvedMerchant = (rawMerchant != null && rawMerchant.trim().isNotEmpty)
        ? formatMerchantName(rawMerchant)
        : (rawUpi != null && rawUpi.trim().isNotEmpty ? formatMerchantName(rawUpi) : null);

    return TransactionModel(
      id: (json['id'] ?? '').toString(),
      userId: (json['userId'] ?? json['user_id']) as String?,
      expenseId: (json['expenseId'] ?? json['expense_id']) as String?,
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      currency: (json['currency'] ?? 'INR') as String,
      upiTransactionId: (json['upiTransactionId'] ?? json['upi_transaction_id']) as String?,
      upiId: (json['upiId'] ?? json['upi_id']) as String?,
      merchantName: resolvedMerchant,
      category: (json['category'] as String?) ?? 'Others',
      paymentMethod: (json['paymentMethod'] ?? json['payment_method']) as String?,
      transactionReference: (json['transactionReference'] ?? json['transaction_reference']) as String?,
      status: (json['paymentStatus'] ?? json['status'] ?? 'SUCCESS') as String,
      provider: json['provider'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      locationAccuracyMeters: (json['locationAccuracyMeters'] ?? json['location_accuracy_meters'] as num?)?.toDouble(),
      paymentDate: (json['paymentDate'] ?? json['payment_date']) as String?,
      paymentTime: (json['paymentTime'] ?? json['payment_time']) as String?,
      createdAt: (json['createdAt'] ?? json['created_at']) as String?,
      updatedAt: (json['updatedAt'] ?? json['updated_at']) as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'expenseId': expenseId,
      'amount': amount,
      'currency': currency,
      'upiTransactionId': upiTransactionId,
      'upiId': upiId,
      'merchantName': merchantName,
      'category': category ?? 'Others',
      'paymentMethod': paymentMethod,
      'transactionReference': transactionReference,
      'status': status,
      'paymentStatus': status,
      'provider': provider,
      'latitude': latitude,
      'longitude': longitude,
      'locationAccuracyMeters': locationAccuracyMeters,
      'paymentDate': paymentDate,
      'paymentTime': paymentTime,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  TransactionItem toTransactionItem({String? customCategory}) {
    final title = (merchantName != null && merchantName!.trim().isNotEmpty)
        ? formatMerchantName(merchantName!)
        : (upiId != null && upiId!.trim().isNotEmpty ? formatMerchantName(upiId!) : 'UPI Payment');

    final sUpper = status.toUpperCase();
    final bool isFailedStatus = sUpper == 'FAILED' || sUpper == 'CANCELLED';
    final categoryText = customCategory ??
        (isFailedStatus ? 'Failed' : (isPending ? 'Pending' : (category != null && category!.trim().isNotEmpty ? category! : (paymentMethod ?? 'Others'))));

    final bool isIncomePayment = category?.toLowerCase() == 'income';
    final String amountText = '${isIncomePayment ? '+' : '-'} ₹${amount.toStringAsFixed(2)}';

    return TransactionItem(
      id: id,
      title: title,
      category: categoryText,
      amount: amountText,
      time: formattedTime,
      icon: _getCategoryIcon(categoryText),
      iconColor: _getCategoryIconColor(categoryText),
      iconBgColor: _getCategoryIconBgColor(categoryText),
      isIncome: isIncomePayment,
      type: paymentMethod ?? 'UPI',
      payment: this,
    );
  }

  String get formattedTime {
    if (paymentTime != null && paymentTime!.isNotEmpty) {
      return paymentTime!;
    }
    if (createdAt != null && createdAt!.isNotEmpty) {
      try {
        final dt = DateTime.parse(createdAt!).toLocal();
        final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
        final minute = dt.minute.toString().padLeft(2, '0');
        final period = dt.hour >= 12 ? 'PM' : 'AM';
        return '$hour:$minute $period';
      } catch (_) {}
    }
    return 'Just now';
  }

  static IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'food':
      case 'food & dining':
      case 'dining':
        return Icons.restaurant_rounded;
      case 'groceries':
        return Icons.local_grocery_store_rounded;
      case 'shopping':
        return Icons.shopping_bag_rounded;
      case 'bills':
      case 'bills & utilities':
      case 'utilities':
      case 'internet':
        return Icons.receipt_long_rounded;
      case 'entertainment':
        return Icons.movie_rounded;
      case 'travel':
      case 'transport':
      case 'travel & transport':
      case 'transportation':
        return Icons.directions_car_rounded;
      case 'health':
      case 'medical':
      case 'health & medical':
      case 'health & fitness':
        return Icons.medical_services_rounded;
      case 'education':
        return Icons.school_rounded;
      case 'investments':
      case 'investment':
        return Icons.trending_up_rounded;
      case 'personal care':
      case 'personal':
        return Icons.spa_rounded;
      case 'pending':
        return Icons.hourglass_top_rounded;
      case 'failed':
        return Icons.error_outline_rounded;
      case 'others':
      case 'other':
      default:
        return Icons.category_rounded;
    }
  }

  static Color _getCategoryIconColor(String category) {
    switch (category.toLowerCase()) {
      case 'food':
      case 'food & dining':
      case 'dining':
        return const Color(0xFFFF9500);
      case 'groceries':
        return const Color(0xFF34C759);
      case 'shopping':
        return const Color(0xFF007AFF);
      case 'bills':
      case 'bills & utilities':
      case 'utilities':
      case 'internet':
        return const Color(0xFFAF52DE);
      case 'entertainment':
        return const Color(0xFFFF2D55);
      case 'travel':
      case 'transport':
      case 'travel & transport':
      case 'transportation':
        return const Color(0xFF30D158);
      case 'health':
      case 'medical':
      case 'health & medical':
      case 'health & fitness':
        return const Color(0xFF5AC8FA);
      case 'education':
        return const Color(0xFF5856D6);
      case 'investments':
      case 'investment':
        return const Color(0xFFFFCC00);
      case 'personal care':
      case 'personal':
        return const Color(0xFFFF6482);
      case 'pending':
        return const Color(0xFFFF9500);
      case 'failed':
        return const Color(0xFFFF3B30);
      case 'others':
      case 'other':
      default:
        return const Color(0xFF8E8E93);
    }
  }

  static Color _getCategoryIconBgColor(String category) {
    return _getCategoryIconColor(category).withValues(alpha: 0.15);
  }

  static List<TransactionGroup> groupPayments(List<TransactionModel> payments, [Map<String, String>? categoryOverrides]) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    final List<TransactionItem> todayList = [];
    final List<TransactionItem> yesterdayList = [];
    final List<TransactionItem> earlierList = [];

    for (final p in payments) {
      DateTime? pDate;
      if (p.createdAt != null && p.createdAt!.isNotEmpty) {
        try {
          pDate = DateTime.parse(p.createdAt!).toLocal();
        } catch (_) {}
      } else if (p.paymentDate != null && p.paymentDate!.isNotEmpty) {
        try {
          pDate = DateTime.parse(p.paymentDate!).toLocal();
        } catch (_) {}
      }

      final dateOnly = pDate != null ? DateTime(pDate.year, pDate.month, pDate.day) : today;
      final customCategory = categoryOverrides?[p.id];
      final item = p.toTransactionItem(customCategory: customCategory);

      if (dateOnly.isAtSameMomentAs(today)) {
        todayList.add(item);
      } else if (dateOnly.isAtSameMomentAs(yesterday)) {
        yesterdayList.add(item);
      } else {
        earlierList.add(item);
      }
    }

    final List<TransactionGroup> groups = [];
    if (todayList.isNotEmpty) {
      groups.add(TransactionGroup(title: 'Today', transactions: todayList));
    }
    if (yesterdayList.isNotEmpty) {
      groups.add(TransactionGroup(title: 'Yesterday', transactions: yesterdayList));
    }
    if (earlierList.isNotEmpty) {
      groups.add(TransactionGroup(title: 'Earlier', transactions: earlierList));
    }
    return groups;
  }
}

// Backward-compatibility alias
typedef PaymentModel = TransactionModel;

class CreatePaymentPayload {
  final double amount;
  final String currency;
  final String? merchantName;
  final String? category;
  final String? upiId;
  final String? paymentMethod;
  final String? transactionReference;
  final String? upiTransactionId;
  final String? provider;
  final double? latitude;
  final double? longitude;
  final double? locationAccuracyMeters;
  final String? expenseId;
  final String? status;

  CreatePaymentPayload({
    required this.amount,
    this.currency = 'INR',
    this.merchantName,
    this.category,
    this.upiId,
    this.paymentMethod = 'UPI',
    this.transactionReference,
    this.upiTransactionId,
    this.provider,
    this.latitude,
    this.longitude,
    this.locationAccuracyMeters,
    this.expenseId,
    this.status,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'amount': amount,
      'currency': currency,
    };
    if (merchantName != null) map['merchantName'] = merchantName;
    if (category != null) {
      map['category'] = category;
    } else {
      map['category'] = 'Others';
    }
    if (upiId != null) map['upiId'] = upiId;
    if (paymentMethod != null) map['paymentMethod'] = paymentMethod;
    if (transactionReference != null) map['transactionReference'] = transactionReference;
    if (upiTransactionId != null) map['upiTransactionId'] = upiTransactionId;
    if (provider != null) map['provider'] = provider;
    if (latitude != null) map['latitude'] = latitude;
    if (longitude != null) map['longitude'] = longitude;
    if (locationAccuracyMeters != null) map['locationAccuracyMeters'] = locationAccuracyMeters;
    if (expenseId != null) map['expenseId'] = expenseId;
    if (status != null) {
      map['status'] = status;
      map['paymentStatus'] = status;
    }
    return map;
  }
}

// Transaction alias
typedef CreateTransactionPayload = CreatePaymentPayload;

class ReconcilePaymentPayload {
  final String status;
  final String? upiTransactionId;
  final String? transactionReference;

  ReconcilePaymentPayload({
    required this.status,
    this.upiTransactionId,
    this.transactionReference,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'status': status,
    };
    if (upiTransactionId != null) map['upiTransactionId'] = upiTransactionId;
    if (transactionReference != null) map['transactionReference'] = transactionReference;
    return map;
  }
}

// Transaction alias
typedef ReconcileTransactionPayload = ReconcilePaymentPayload;
