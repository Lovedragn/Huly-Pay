import 'package:flutter/material.dart';

class TransactionReceiptCard extends StatelessWidget {
  final String status;
  final String displayAmount;
  final String merchantTitle;
  final String time;
  final bool isIncome;

  const TransactionReceiptCard({
    super.key,
    required this.status,
    required this.displayAmount,
    required this.merchantTitle,
    required this.time,
    this.isIncome = false,
  });

  @override
  Widget build(BuildContext context) {
    final s = status.toUpperCase();
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
            displayAmount,
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
            isIncome
                ? 'Received from $merchantTitle'
                : 'Paid to $merchantTitle',
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
            time,
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
}
