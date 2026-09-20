import 'package:flutter/material.dart';
import '../models/dashboard_data.dart';
import '../models/payment_model.dart';
import '../screens/single_transaction_screen.dart';
import '../theme/app_theme.dart';

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
    final colors = AppThemeManager.colors;
    final iconBgColor = colors.isDark ? transaction.iconBgColor : colors.iconBackground;

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
              color: iconBgColor,
              borderRadius: BorderRadius.circular(14),
              border: colors.isDark
                  ? null
                  : Border.all(
                      color: colors.border.withValues(alpha: 0.7),
                      width: 1,
                    ),
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
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'Google Sans',
                    color: AppThemeManager.colors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  transaction.category,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'Google Sans',
                    color: AppThemeManager.colors.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (transaction.isPending)
                    Container(
                      margin: const EdgeInsets.only(right: 6),
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2C2210),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: const Color(0xFF5A3E15),
                          width: 0.5,
                        ),
                      ),
                      child: const Text(
                        'Pending',
                        style: TextStyle(
                          fontFamily: 'Google Sans',
                          color: Color(0xFFFF9F0A),
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  Text(
                    transaction.amount,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: 'Google Sans',
                      color: transaction.isFailed
                          ? const Color(0xFFFF453A)
                          : transaction.isPending
                              ? const Color(0xFFFF9F0A)
                              : transaction.isIncome
                                  ? const Color(0xFF30D158)
                                  : AppThemeManager.colors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 3),
              Text(
                transaction.time,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: 'Google Sans',
                  color: AppThemeManager.colors.textSecondary,
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
