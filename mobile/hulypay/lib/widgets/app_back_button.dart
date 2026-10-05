import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Reusable Back Button with exact circular radius, border, and dimensions (44x44)
/// matching the notification button across all screens.
class AppBackButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String tooltip;
  final Color? backgroundColor;
  final Color? borderColor;
  final Color? iconColor;
  final double iconSize;

  const AppBackButton({
    super.key,
    this.onPressed,
    this.tooltip = 'Back',
    this.backgroundColor,
    this.borderColor,
    this.iconColor,
    this.iconSize = 18,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppThemeManager.colors;

    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onPressed ??
            () {
              if (Navigator.canPop(context)) {
                Navigator.pop(context);
              }
            },
        behavior: HitTestBehavior.opaque,
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: backgroundColor ?? colors.surface,
              shape: BoxShape.circle,
              border: Border.all(
                color: borderColor ?? colors.border,
                width: 1.5,
              ),
            ),
            child: Center(
              child: Icon(
                Icons.arrow_back_ios_new_rounded,
                color: iconColor ?? colors.textPrimary,
                size: iconSize,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
