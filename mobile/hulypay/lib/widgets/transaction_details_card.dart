import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../theme/app_theme.dart';
import 'transaction_detail_components.dart';

class TransactionDetailsCard extends StatelessWidget {
  final String paymentMethod;
  final String category;
  final String transactionType;
  final String referenceId;
  final double latitude;
  final double longitude;
  final double? accuracy;
  final String status;
  final String time;
  final VoidCallback onCategoryTap;
  final void Function(String text, String label) onCopy;

  const TransactionDetailsCard({
    super.key,
    required this.paymentMethod,
    required this.category,
    required this.transactionType,
    required this.referenceId,
    required this.latitude,
    required this.longitude,
    this.accuracy,
    required this.status,
    required this.time,
    required this.onCategoryTap,
    required this.onCopy,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppThemeManager.colors;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.border, width: 1),
      ),
      child: Column(
        children: [
          TransactionDetailRow(
            label: 'Payment Method',
            value: paymentMethod,
            leadingWidget: paymentMethod.toLowerCase().contains('gpay') ||
                    paymentMethod.toLowerCase().contains('google')
                ? Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: SvgPicture.asset(
                      'assets/icon/google-pay.svg',
                      width: 18,
                      height: 18,
                    ),
                  )
                : (paymentMethod.toLowerCase().contains('amazon')
                    ? Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: SvgPicture.asset(
                          'assets/icon/amazon-icon.svg',
                          width: 18,
                          height: 18,
                        ),
                      )
                    : null),
          ),
          Divider(
            color: colors.divider,
            height: 1,
            thickness: 1,
            indent: 16,
            endIndent: 16,
          ),
          TransactionDetailRow(
            label: 'Category',
            value: category,
            trailingWidget: Padding(
              padding: const EdgeInsets.only(left: 6),
              child: Icon(
                Icons.edit_outlined,
                color: colors.accent,
                size: 14,
              ),
            ),
            onTap: onCategoryTap,
          ),
          Divider(
            color: colors.divider,
            height: 1,
            thickness: 1,
            indent: 16,
            endIndent: 16,
          ),
          TransactionDetailRow(
            label: 'Transaction Type',
            value: transactionType,
          ),
          Divider(
            color: colors.divider,
            height: 1,
            thickness: 1,
            indent: 16,
            endIndent: 16,
          ),
          TransactionDetailRow(
            label: 'UPI Ref No.',
            value: referenceId,
            canCopy: true,
            onCopy: () => onCopy(referenceId, 'UPI Reference No.'),
          ),
          Divider(
            color: colors.divider,
            height: 1,
            thickness: 1,
            indent: 16,
            endIndent: 16,
          ),
          TransactionDetailRow(
            label: 'Payment Location',
            value:
                '${latitude.toStringAsFixed(4)}, ${longitude.toStringAsFixed(4)} (±${accuracy != null ? accuracy!.toStringAsFixed(1) : "5.0"}m)',
            canCopy: true,
            onCopy: () => onCopy(
              '$latitude, $longitude',
              'Coordinates',
            ),
          ),
          Divider(
            color: colors.divider,
            height: 1,
            thickness: 1,
            indent: 16,
            endIndent: 16,
          ),
          TransactionDetailRow(label: 'Payment Status', value: status),
          Divider(
            color: colors.divider,
            height: 1,
            thickness: 1,
            indent: 16,
            endIndent: 16,
          ),
          TransactionDetailRow(label: 'Date & Time', value: time),
        ],
      ),
    );
  }
}
