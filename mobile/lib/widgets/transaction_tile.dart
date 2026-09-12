import 'package:flutter/material.dart';
import '../models/dashboard_data.dart';

class TransactionTile extends StatelessWidget {
  final TransactionItem transaction;

  const TransactionTile({
    super.key,
    required this.transaction,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: transaction.iconBgColor,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              transaction.icon,
              color: transaction.iconColor,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.title,
                  style: const TextStyle(
                    fontFamily: 'Google Sans',
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  transaction.category,
                  style: const TextStyle(
                    fontFamily: 'Google Sans',
                    color: Color(0xFF8E8E93),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                transaction.amount,
                style: TextStyle(
                  fontFamily: 'Google Sans',
                  color: transaction.isIncome
                      ? const Color(0xFF30D158)
                      : Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                transaction.time,
                style: const TextStyle(
                  fontFamily: 'Google Sans',
                  color: Color(0xFF8E8E93),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
