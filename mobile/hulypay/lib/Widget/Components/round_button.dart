import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../Theme/app_theme.dart';

/// Reusable circular 44x44 action button with standardized styling,
/// supporting back, notifications (with optional badge), settings, SVGs, or custom icons.
class RoundButton extends StatelessWidget {
  final VoidCallback? onTap;
  final IconData? icon;
  final String? svgAsset;
  final Widget? child;
  final String? tooltip;
  final bool isActive;
  final bool showBadge;
  final Color? badgeColor;
  final Color? backgroundColor;
  final Color? activeBackgroundColor;
  final Color? borderColor;
  final Color? iconColor;
  final double size;
  final double iconSize;

  const RoundButton({
    super.key,
    this.onTap,
    this.icon,
    this.svgAsset,
    this.child,
    this.tooltip,
    this.isActive = false,
    this.showBadge = false,
    this.badgeColor,
    this.backgroundColor,
    this.activeBackgroundColor,
    this.borderColor,
    this.iconColor,
    this.size = 44.0,
    this.iconSize = 20.0,
  });

  /// Factory constructor for a standardized Back button
  factory RoundButton.back({
    Key? key,
    VoidCallback? onTap,
    String tooltip = 'Back',
    double iconSize = 18.0,
    Color? iconColor,
    Color? backgroundColor,
    Color? borderColor,
  }) {
    return RoundButton(
      key: key,
      onTap: onTap,
      svgAsset: 'assets/icon/back.svg',
      tooltip: tooltip,
      iconSize: iconSize,
      iconColor: iconColor,
      backgroundColor: backgroundColor,
      borderColor: borderColor,
    );
  }

  /// Factory constructor for a standardized Close button
  factory RoundButton.close({
    Key? key,
    VoidCallback? onTap,
    String tooltip = 'Close',
    double iconSize = 18.0,
    double size = 44.0,
    Color? iconColor,
    Color? backgroundColor,
    Color? borderColor,
  }) {
    return RoundButton(
      key: key,
      onTap: onTap,
      icon: Icons.close_rounded,
      tooltip: tooltip,
      size: size,
      iconSize: iconSize,
      iconColor: iconColor,
      backgroundColor: backgroundColor,
      borderColor: borderColor,
    );
  }

  /// Factory constructor for a standardized Notification button
  factory RoundButton.notification({
    Key? key,
    required VoidCallback onTap,
    bool showBadge = true,
    String tooltip = 'Notifications',
    Color? badgeColor,
    Color? iconColor,
    Color? backgroundColor,
    Color? borderColor,
  }) {
    return RoundButton(
      key: key,
      onTap: onTap,
      icon: Icons.notifications_outlined,
      tooltip: tooltip,
      showBadge: showBadge,
      badgeColor: badgeColor ?? const Color(0xFFFF9500),
      iconSize: 22.0,
      iconColor: iconColor,
      backgroundColor: backgroundColor,
      borderColor: borderColor,
    );
  }

  /// Factory constructor for a standardized Settings button
  factory RoundButton.settings({
    Key? key,
    required VoidCallback onTap,
    String tooltip = 'Settings',
    Color? iconColor,
    Color? backgroundColor,
    Color? borderColor,
  }) {
    return RoundButton(
      key: key,
      onTap: onTap,
      icon: Icons.settings_outlined,
      tooltip: tooltip,
      iconSize: 22.0,
      iconColor: iconColor,
      backgroundColor: backgroundColor,
      borderColor: borderColor,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppThemeManager.colors;

    final resolvedBg = isActive
        ? (activeBackgroundColor ?? colors.accent.withValues(alpha: 0.15))
        : (backgroundColor ?? colors.surface);

    final resolvedBorder = isActive
        ? (borderColor ?? colors.accent)
        : (borderColor ?? colors.border);

    final resolvedIconColor = isActive
        ? (iconColor ?? colors.accent)
        : (iconColor ?? colors.textPrimary);

    Widget? innerContent;
    if (child != null) {
      innerContent = child!;
    } else if (svgAsset != null) {
      innerContent = SvgPicture.asset(
        svgAsset!,
        width: iconSize,
        height: iconSize,
        colorFilter: ColorFilter.mode(resolvedIconColor, BlendMode.srcIn),
      );
    } else if (icon != null) {
      innerContent = Icon(
        icon,
        size: iconSize,
        color: resolvedIconColor,
      );
    }

    Widget content = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: resolvedBg,
        shape: BoxShape.circle,
        border: Border.all(
          color: resolvedBorder,
          width: 1.5,
        ),
      ),
      child: Center(child: innerContent),
    );

    if (showBadge) {
      content = Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          content,
          Positioned(
            top: 10,
            right: 11,
            child: Container(
              width: 7,
              height: 7,
              decoration: BoxDecoration(
                color: badgeColor ?? const Color(0xFFFF9500),
                shape: BoxShape.circle,
              ),
            ),
          ),
        ],
      );
    }

    Widget button = GestureDetector(
      onTap: onTap ??
          () {
            if ((icon == Icons.arrow_back_ios_new_rounded ||
                    svgAsset == 'assets/icon/back.svg') &&
                Navigator.canPop(context)) {
              Navigator.pop(context);
            }
          },
      behavior: HitTestBehavior.opaque,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: content,
      ),
    );

    if (tooltip != null && tooltip!.isNotEmpty) {
      button = Tooltip(
        message: tooltip!,
        child: button,
      );
    }

    return button;
  }
}
