import 'category_model.dart';

class ExpenseModel {
  final String id;
  final String? userId;
  final double amount;
  final String currency;
  final String? merchantName;
  final CategoryModel? category;
  final String? description;
  final String? transactionTime;
  final String? paymentMethod;
  final String? upiTransactionId;
  final String? status;
  final double? latitude;
  final double? longitude;
  final String? createdAt;
  final String? updatedAt;

  ExpenseModel({
    required this.id,
    this.userId,
    required this.amount,
    required this.currency,
    this.merchantName,
    this.category,
    this.description,
    this.transactionTime,
    this.paymentMethod,
    this.upiTransactionId,
    this.status,
    this.latitude,
    this.longitude,
    this.createdAt,
    this.updatedAt,
  });

  factory ExpenseModel.fromJson(Map<String, dynamic> json) {
    return ExpenseModel(
      id: json['id'] as String,
      userId: json['userId'] as String?,
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'] as String? ?? 'INR',
      merchantName: json['merchantName'] as String?,
      category: json['category'] != null
          ? CategoryModel.fromJson(json['category'] as Map<String, dynamic>)
          : null,
      description: json['description'] as String?,
      transactionTime: json['transactionTime'] as String?,
      paymentMethod: json['paymentMethod'] as String?,
      upiTransactionId: json['upiTransactionId'] as String?,
      status: json['status'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      createdAt: json['createdAt'] as String?,
      updatedAt: json['updatedAt'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'amount': amount,
      'currency': currency,
      'merchantName': merchantName,
      'category': category?.toJson(),
      'description': description,
      'transactionTime': transactionTime,
      'paymentMethod': paymentMethod,
      'upiTransactionId': upiTransactionId,
      'status': status,
      'latitude': latitude,
      'longitude': longitude,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}

class CreateExpensePayload {
  final double amount;
  final String currency;
  final String? merchantName;
  final String? categoryId;
  final String? description;
  final String? transactionTime;
  final String? paymentMethod;
  final String? upiTransactionId;
  final double? latitude;
  final double? longitude;

  CreateExpensePayload({
    required this.amount,
    this.currency = 'INR',
    this.merchantName,
    this.categoryId,
    this.description,
    this.transactionTime,
    this.paymentMethod = 'UPI',
    this.upiTransactionId,
    this.latitude,
    this.longitude,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'amount': amount,
      'currency': currency,
    };
    if (merchantName != null) map['merchantName'] = merchantName;
    if (categoryId != null) map['categoryId'] = categoryId;
    if (description != null) map['description'] = description;
    if (transactionTime != null) map['transactionTime'] = transactionTime;
    if (paymentMethod != null) map['paymentMethod'] = paymentMethod;
    if (upiTransactionId != null) map['upiTransactionId'] = upiTransactionId;
    if (latitude != null) map['latitude'] = latitude;
    if (longitude != null) map['longitude'] = longitude;
    return map;
  }
}
