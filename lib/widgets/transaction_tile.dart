import 'package:flutter/material.dart';
import '../models/dashboard_data.dart';
import '../models/payment_model.dart';
import '../screens/single_transaction_screen.dart';

class TransactionTile extends StatelessWidget {
  final TransactionItem transaction;
  final PaymentModel? payment;
  final VoidCallback? onTap;

  const TransactionTile({
    super.key,
    required this.transaction,
    this.payment,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap ??
            () {
              final activePayment = payment ?? transaction.payment;
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => SingleTransactionScreen(
                    transaction: transaction,
                    payment: activePayment,
                    paymentId: activePayment?.id ?? (transaction.id.startsWith('tx_') ? null : transaction.id),
                  ),
                ),
              );
            },
        child: Padding(
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
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (transaction.isFailed)
                    Container(
                      margin: const EdgeInsets.only(right: 6),
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2C1517),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: const Color(0xFF5A1C22),
                          width: 0.5,
                        ),
                      ),
                      child: const Text(
                        'Failed',
                        style: TextStyle(
                          fontFamily: 'Google Sans',
                          color: Color(0xFFFF453A),
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  Text(
                    transaction.amount,
                    style: TextStyle(
                      fontFamily: 'Google Sans',
                      color: transaction.isFailed
                          ? const Color(0xFFFF453A)
                          : transaction.isIncome
                              ? const Color(0xFF30D158)
                              : Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
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
    ),
  ),
);
  }
}
