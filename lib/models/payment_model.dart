import 'package:flutter/material.dart';
import 'dashboard_data.dart';

class PaymentModel {
  final String id;
  final String? userId;
  final String? expenseId;
  final double amount;
  final String currency;
  final String? upiTransactionId;
  final String? upiId;
  final String? merchantName;
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

  PaymentModel({
    required this.id,
    this.userId,
    this.expenseId,
    required this.amount,
    required this.currency,
    this.upiTransactionId,
    this.upiId,
    this.merchantName,
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

  PaymentModel copyWith({
    String? id,
    String? userId,
    String? expenseId,
    double? amount,
    String? currency,
    String? upiTransactionId,
    String? upiId,
    String? merchantName,
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
    return PaymentModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      expenseId: expenseId ?? this.expenseId,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      upiTransactionId: upiTransactionId ?? this.upiTransactionId,
      upiId: upiId ?? this.upiId,
      merchantName: merchantName ?? this.merchantName,
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

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      id: (json['id'] ?? '').toString(),
      userId: (json['userId'] ?? json['user_id']) as String?,
      expenseId: (json['expenseId'] ?? json['expense_id']) as String?,
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      currency: (json['currency'] ?? 'INR') as String,
      upiTransactionId: (json['upiTransactionId'] ?? json['upi_transaction_id']) as String?,
      upiId: (json['upiId'] ?? json['upi_id']) as String?,
      merchantName: (json['merchantName'] ?? json['merchant_name']) as String?,
      paymentMethod: (json['paymentMethod'] ?? json['payment_method']) as String?,
      transactionReference: (json['transactionReference'] ?? json['transaction_reference']) as String?,
      status: (json['paymentStatus'] ?? json['status'] ?? 'INITIATED') as String,
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

  TransactionItem toTransactionItem() {
    final title = (merchantName != null && merchantName!.trim().isNotEmpty)
        ? merchantName!.trim()
        : (upiId != null && upiId!.trim().isNotEmpty ? upiId!.trim() : 'UPI Payment');

    final sUpper = status.toUpperCase();
    final bool isFailedStatus = sUpper == 'FAILED' || sUpper == 'CANCELLED';
    final bool isPendingStatus = sUpper == 'PENDING' || sUpper == 'INITIATED' || sUpper == 'PAYMENT_INITIATED';
    final categoryText = isFailedStatus ? 'Failed' : (isPendingStatus ? 'Pending' : (paymentMethod ?? 'UPI'));

    final amountText = (isFailedStatus || isPendingStatus)
        ? '₹${amount.toStringAsFixed(amount.truncateToDouble() == amount ? 0 : 2)}'
        : '- ₹${amount.toStringAsFixed(amount.truncateToDouble() == amount ? 0 : 2)}';

    String timeText = 'Today';
    if (paymentTime != null && paymentTime!.isNotEmpty) {
      timeText = paymentTime!;
    } else if (createdAt != null && createdAt!.isNotEmpty) {
      try {
        final dt = DateTime.parse(createdAt!).toLocal();
        final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
        final minute = dt.minute.toString().padLeft(2, '0');
        final ampm = dt.hour >= 12 ? 'PM' : 'AM';
        timeText = '$hour:$minute $ampm';
      } catch (_) {
        timeText = createdAt!;
      }
    }

    // Determine icon based on merchant or category
    IconData icon = Icons.receipt_long_rounded;
    Color iconColor = const Color(0xFF007AFF);
    Color iconBgColor = const Color(0xFF14243B);

    final titleLower = title.toLowerCase();
    if (isFailedStatus) {
      icon = Icons.error_outline_rounded;
      iconColor = const Color(0xFFFF453A);
      iconBgColor = const Color(0xFF2C1517);
    } else if (isPendingStatus) {
      icon = Icons.hourglass_top_rounded;
      iconColor = const Color(0xFFFF9F0A);
      iconBgColor = const Color(0xFF2C2210);
    } else if (titleLower.contains('swiggy') || titleLower.contains('zomato') || titleLower.contains('food')) {
      icon = Icons.restaurant_rounded;
      iconColor = const Color(0xFFFF9500);
      iconBgColor = const Color(0xFF2C2014);
    } else if (titleLower.contains('amazon') || titleLower.contains('flipkart') || titleLower.contains('store')) {
      icon = Icons.shopping_bag_rounded;
      iconColor = const Color(0xFF007AFF);
      iconBgColor = const Color(0xFF14243B);
    } else if (titleLower.contains('uber') || titleLower.contains('ola') || titleLower.contains('fuel')) {
      icon = Icons.directions_car_rounded;
      iconColor = const Color(0xFF30D158);
      iconBgColor = const Color(0xFF142A1E);
    }

    return TransactionItem(
      id: id,
      title: title,
      category: categoryText,
      amount: amountText,
      time: timeText,
      icon: icon,
      iconColor: iconColor,
      iconBgColor: iconBgColor,
      isIncome: false,
      type: 'UPI',
      payment: this,
    );
  }

  static List<TransactionGroup> groupPayments(List<PaymentModel> payments) {
    if (payments.isEmpty) return [];

    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final yesterdayStart = todayStart.subtract(const Duration(days: 1));

    final todayList = <TransactionItem>[];
    final yesterdayList = <TransactionItem>[];
    final earlierList = <TransactionItem>[];

    for (final p in payments) {
      DateTime? dt;
      if (p.createdAt != null) {
        try {
          dt = DateTime.parse(p.createdAt!).toLocal();
        } catch (_) {}
      }
      final item = p.toTransactionItem();
      if (dt == null || dt.isAfter(todayStart)) {
        todayList.add(item);
      } else if (dt.isAfter(yesterdayStart)) {
        yesterdayList.add(item);
      } else {
        earlierList.add(item);
      }
    }

    final groups = <TransactionGroup>[];
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

class CreatePaymentPayload {
  final double amount;
  final String currency;
  final String? merchantName;
  final String? upiId;
  final String? paymentMethod;
  final String? transactionReference;
  final String? upiTransactionId;
  final String? provider;
  final double? latitude;
  final double? longitude;
  final double? locationAccuracyMeters;
  final String? expenseId;

  CreatePaymentPayload({
    required this.amount,
    this.currency = 'INR',
    this.merchantName,
    this.upiId,
    this.paymentMethod = 'UPI',
    this.transactionReference,
    this.upiTransactionId,
    this.provider,
    this.latitude,
    this.longitude,
    this.locationAccuracyMeters,
    this.expenseId,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'amount': amount,
      'currency': currency,
    };
    if (merchantName != null) map['merchantName'] = merchantName;
    if (upiId != null) map['upiId'] = upiId;
    if (paymentMethod != null) map['paymentMethod'] = paymentMethod;
    if (transactionReference != null) map['transactionReference'] = transactionReference;
    if (upiTransactionId != null) map['upiTransactionId'] = upiTransactionId;
    if (provider != null) map['provider'] = provider;
    if (latitude != null) map['latitude'] = latitude;
    if (longitude != null) map['longitude'] = longitude;
    if (locationAccuracyMeters != null) map['locationAccuracyMeters'] = locationAccuracyMeters;
    if (expenseId != null) map['expenseId'] = expenseId;
    return map;
  }
}

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

