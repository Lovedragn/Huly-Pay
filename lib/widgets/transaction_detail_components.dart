import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class TransactionActionButton extends StatelessWidget {
  final IconData? icon;
  final Widget? customIcon;
  final String label;
  final bool isPrimary;
  final VoidCallback onTap;
  final Color? textColor;
  final Color? iconColor;
  final Color? backgroundColor;
  final Color? borderColor;

  const TransactionActionButton({
    super.key,
    this.icon,
    this.customIcon,
    required this.label,
    required this.isPrimary,
    required this.onTap,
    this.textColor,
    this.iconColor,
    this.backgroundColor,
    this.borderColor,
  }) : assert(icon != null || customIcon != null, 'Either icon or customIcon must be provided');

  @override
  Widget build(BuildContext context) {
    final effectiveBgColor = backgroundColor ??
        (isPrimary ? Colors.white : const Color(0xFF141416));
    final effectiveFgColor = isPrimary ? Colors.black : Colors.white;
    final effectiveTextColor = textColor ?? effectiveFgColor;
    final effectiveIconColor = iconColor ?? effectiveFgColor;
    final effectiveBorder = borderColor != null
        ? Border.all(color: borderColor!, width: 1)
        : (isPrimary
            ? null
            : Border.all(color: AppThemeManager.colors.border, width: 1));

    return Material(
      color: effectiveBgColor,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: effectiveBorder,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              customIcon ??
                  Icon(
                    icon,
                    color: effectiveIconColor,
                    size: 20,
                  ),
              const SizedBox(height: 6),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: 'Google Sans',
                  color: effectiveTextColor,
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
}

/// Key-value detail row for transaction info cards
class TransactionDetailRow extends StatelessWidget {
  final String label;
  final String value;
  final Widget? leadingWidget;
  final Widget? trailingWidget;
  final bool canCopy;
  final VoidCallback? onCopy;
  final VoidCallback? onTap;

  const TransactionDetailRow({
    super.key,
    required this.label,
    required this.value,
    this.leadingWidget,
    this.trailingWidget,
    this.canCopy = false,
    this.onCopy,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final content = Padding(
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
          const SizedBox(width: 8),
          Flexible(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ?leadingWidget,
                Flexible(
                  child: Text(
                    value,
                    textAlign: TextAlign.right,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'Google Sans',
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (canCopy) ...[
                  const SizedBox(width: 6),
                  GestureDetector(
                    onTap: onCopy,
                    behavior: HitTestBehavior.opaque,
                    child: const Icon(
                      Icons.copy_rounded,
                      color: Color(0xFF007AFF),
                      size: 15,
                    ),
                  ),
                ],
                ?trailingWidget,
              ],
            ),
          ),
        ],
      ),
    );

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: content,
        ),
      );
    }
    return content;
  }
}
