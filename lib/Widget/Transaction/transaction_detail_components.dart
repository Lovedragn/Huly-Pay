import 'package:flutter/material.dart';
import '../../Theme/app_theme.dart';

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
    final colors = AppThemeManager.colors;
    final isDark = colors.isDark;

    final effectiveBgColor = backgroundColor ??
        (isPrimary ? (isDark ? Colors.white : colors.accent) : colors.surface);
    final effectiveFgColor =
        isPrimary ? (isDark ? Colors.black : Colors.white) : colors.textPrimary;
    final effectiveTextColor = textColor ?? effectiveFgColor;
    final effectiveIconColor = iconColor ?? effectiveFgColor;
    final effectiveBorder = borderColor != null
        ? Border.all(color: borderColor!, width: 1)
        : (isPrimary
            ? null
            : Border.all(color: colors.border, width: 1));

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
    final colors = AppThemeManager.colors;

    final content = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Google Sans',
              color: colors.textSecondary,
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
                    style: TextStyle(
                      fontFamily: 'Google Sans',
                      color: colors.textPrimary,
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
                    child: Icon(
                      Icons.copy_rounded,
                      color: colors.accent,
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
