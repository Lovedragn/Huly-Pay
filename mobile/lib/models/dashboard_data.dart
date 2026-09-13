import 'package:flutter/material.dart';

class TransactionItem {
  final String id;
  final String title;
  final String category;
  final String amount;
  final String time;
  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;
  final bool isIncome;
  final String type; // 'UPI', 'Expense', 'Income'

  const TransactionItem({
    required this.id,
    required this.title,
    required this.category,
    required this.amount,
    required this.time,
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
    this.isIncome = false,
    this.type = 'Expense',
  });

  bool get isFailed => category.toLowerCase() == 'failed';
}

class TransactionGroup {
  final String title;
  final List<TransactionItem> transactions;

  const TransactionGroup({
    required this.title,
    required this.transactions,
  });
}

class SpendingBarData {
  final String day;
  final double height;
  final Color color;

  const SpendingBarData({
    required this.day,
    required this.height,
    required this.color,
  });
}

class DashboardData {
  final String greeting;
  final String userName;
  final String avatarUrl;
  final String totalSpentFormatted;
  final double changePercent;
  final String changePeriodLabel;
  final List<SpendingBarData> weeklySpending;
  final List<TransactionItem> recentTransactions;

  const DashboardData({
    required this.greeting,
    required this.userName,
    required this.avatarUrl,
    required this.totalSpentFormatted,
    required this.changePercent,
    required this.changePeriodLabel,
    required this.weeklySpending,
    required this.recentTransactions,
  });
}

class CategorySpendingItem {
  final String title;
  final int percentage;
  final String amount;
  final Color color;

  const CategorySpendingItem({
    required this.title,
    required this.percentage,
    required this.amount,
    required this.color,
  });
}

