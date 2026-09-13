import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/dashboard_data.dart';

class SingleTransactionScreen extends StatelessWidget {
  final TransactionItem transaction;

  const SingleTransactionScreen({
    super.key,
    required this.transaction,
  });

  String get _referenceId {
    final hash = transaction.id.hashCode.abs().toString().padLeft(12, '0');
    return 'UPI/$hash';
  }

  String get _paymentMethod {
    final titleLower = transaction.title.toLowerCase();
    if (titleLower.contains('amazon')) {
      return 'Amazon Pay';
    }
    if (titleLower.contains('swiggy') ||
        titleLower.contains('google') ||
        titleLower.contains('zomato') ||
        transaction.type.toLowerCase().contains('upi')) {
      return 'GPay';
    }
    // Only two allowed: GPay and Amazon Pay
    return transaction.id.hashCode.isEven ? 'GPay' : 'Amazon Pay';
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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        duration: const Duration(seconds: 2),
      ),
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
            'Do you want to raise a dispute for this payment of ${transaction.amount} to ${transaction.title}?',
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF000000),
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(context),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildShopBanner(context),
                    const SizedBox(height: 16),
                    _buildHeroReceiptCard(context),
                    const SizedBox(height: 20),
                    _buildQuickActionButtons(context),
                    const SizedBox(height: 24),
                    _buildSectionHeader('TRANSACTION DETAILS'),
                    const SizedBox(height: 12),
                    _buildDetailsCard(context),
                    const SizedBox(height: 24),
                    _buildSupportCard(context),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            behavior: HitTestBehavior.opaque,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFF141416),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFF222226),
                  width: 1,
                ),
              ),
              child: const Center(
                child: Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),
          const Text(
            'Transaction Details',
            style: TextStyle(
              fontFamily: 'Google Sans',
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.3,
            ),
          ),
          GestureDetector(
            onTap: () => _copyToClipboard(
              context,
              'Huly Pay Receipt: ${transaction.title} - ${transaction.amount} (${transaction.time})',
              'Receipt details',
            ),
            behavior: HitTestBehavior.opaque,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFF141416),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFF222226),
                  width: 1,
                ),
              ),
              child: const Center(
                child: Icon(
                  Icons.share_outlined,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShopBanner(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 155,
      decoration: BoxDecoration(
        color: const Color(0xFF141416),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF222226),
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Shop image from asserts folder
            Image.asset(
              'asserts/pictures/shop_banner.png',
              fit: BoxFit.cover,
              errorBuilder: (ctx, err, stack) {
                return Image.asset(
                  'asserts/pictures/quick_actions.png',
                  fit: BoxFit.cover,
                  errorBuilder: (c, e, s) => Container(
                    color: const Color(0xFF1E1E24),
                    child: const Center(
                      child: Icon(
                        Icons.storefront_rounded,
                        color: Color(0xFF8E8E93),
                        size: 40,
                      ),
                    ),
                  ),
                );
              },
            ),
            // Subtle gradient overlay for polish
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.3),
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
    final isFailed = transaction.isFailed;
    final isIncome = transaction.isIncome;

    final Color statusColor = isFailed
        ? const Color(0xFFFF453A)
        : (isIncome ? const Color(0xFF30D158) : const Color(0xFF30D158));

    final Color statusBg = isFailed
        ? const Color(0xFF2C1517)
        : const Color(0xFF10281B);

    final Color statusBorder = isFailed
        ? const Color(0xFF5A1C22)
        : const Color(0xFF1B4D2E);

    final String statusText = isFailed
        ? 'Payment Failed'
        : (isIncome ? 'Money Received' : 'Payment Successful');

    final IconData statusIcon = isFailed
        ? Icons.cancel_rounded
        : Icons.check_circle_rounded;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      decoration: BoxDecoration(
        color: const Color(0xFF141416),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFF222226),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // Status Pill Badge (NOT a circle profile)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: statusBg,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: statusBorder,
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  statusIcon,
                  color: statusColor,
                  size: 15,
                ),
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
            transaction.amount,
            style: TextStyle(
              fontFamily: 'Google Sans',
              color: isFailed
                  ? const Color(0xFFFF453A)
                  : (isIncome ? const Color(0xFF30D158) : Colors.white),
              fontSize: 38,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 10),
          // Payee / Source Title
          Text(
            isIncome
                ? 'Received from ${transaction.title}'
                : 'Paid to ${transaction.title}',
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
            transaction.time,
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
    final isFailed = transaction.isFailed;

    return Row(
      children: [
        // Repeat / Retry Payment
        Expanded(
          child: _buildActionButton(
            icon: isFailed ? Icons.refresh_rounded : Icons.replay_rounded,
            label: isFailed ? 'Retry' : 'Pay Again',
            isPrimary: true,
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    isFailed
                        ? 'Retrying payment of ${transaction.amount} to ${transaction.title}...'
                        : 'Initiating repeat payment to ${transaction.title}...',
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
        const SizedBox(width: 12),
        // Share Receipt
        Expanded(
          child: _buildActionButton(
            icon: Icons.share_outlined,
            label: 'Share',
            isPrimary: false,
            onTap: () => _copyToClipboard(
              context,
              'Huly Pay Receipt: ${transaction.title} - ${transaction.amount} on ${transaction.time}. Ref: $_referenceId',
              'Receipt details',
            ),
          ),
        ),
        const SizedBox(width: 12),
        // Download Receipt
        Expanded(
          child: _buildActionButton(
            icon: Icons.receipt_long_outlined,
            label: 'Receipt',
            isPrimary: false,
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Receipt for ${transaction.title} downloaded successfully.',
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
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required bool isPrimary,
    required VoidCallback onTap,
  }) {
    return Material(
      color: isPrimary ? Colors.white : const Color(0xFF141416),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: isPrimary
                ? null
                : Border.all(
                    color: const Color(0xFF222226),
                    width: 1,
                  ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: isPrimary ? Colors.black : Colors.white,
                size: 20,
              ),
              const SizedBox(height: 6),
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'Google Sans',
                  color: isPrimary ? Colors.black : Colors.white,
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
        border: Border.all(
          color: const Color(0xFF222226),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          _buildDetailRow(
            label: 'Payment Method',
            value: _paymentMethod,
          ),
          const Divider(color: Color(0xFF202024), height: 1, thickness: 1, indent: 16, endIndent: 16),
          _buildDetailRow(
            label: 'Category',
            value: transaction.category,
          ),
          const Divider(color: Color(0xFF202024), height: 1, thickness: 1, indent: 16, endIndent: 16),
          _buildDetailRow(
            label: 'Transaction Type',
            value: transaction.type,
          ),
          const Divider(color: Color(0xFF202024), height: 1, thickness: 1, indent: 16, endIndent: 16),
          _buildDetailRow(
            label: 'UPI Ref No.',
            value: _referenceId,
            canCopy: true,
            onCopy: () => _copyToClipboard(context, _referenceId, 'UPI Reference No.'),
          ),
          const Divider(color: Color(0xFF202024), height: 1, thickness: 1, indent: 16, endIndent: 16),
          _buildDetailRow(
            label: 'Transaction ID',
            value: transaction.id,
            canCopy: true,
            onCopy: () => _copyToClipboard(context, transaction.id, 'Transaction ID'),
          ),
          const Divider(color: Color(0xFF202024), height: 1, thickness: 1, indent: 16, endIndent: 16),
          _buildDetailRow(
            label: 'Date & Time',
            value: transaction.time,
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow({
    required String label,
    required String value,
    bool canCopy = false,
    VoidCallback? onCopy,
  }) {
    return Padding(
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
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontFamily: 'Google Sans',
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (canCopy) ...[
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: onCopy,
                  behavior: HitTestBehavior.opaque,
                  child: const Padding(
                    padding: EdgeInsets.all(2),
                    child: Icon(
                      Icons.copy_rounded,
                      color: Color(0xFF8E8E93),
                      size: 16,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSupportCard(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF141416),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF222226),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => _showReportIssueDialog(context),
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              children: [
                Icon(
                  Icons.help_outline_rounded,
                  color: Color(0xFF8E8E93),
                  size: 22,
                ),
                SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Have an issue with this payment?',
                        style: TextStyle(
                          fontFamily: 'Google Sans',
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Raise a dispute or contact 24/7 support',
                        style: TextStyle(
                          fontFamily: 'Google Sans',
                          color: Color(0xFF8E8E93),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: Color(0xFF6B6B70),
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
