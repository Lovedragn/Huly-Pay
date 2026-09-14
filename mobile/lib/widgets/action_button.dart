import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../theme/app_theme.dart';

class QuickActionButton extends StatelessWidget {
  final IconData? icon;
  final String? svgAsset;
  final String label;
  final VoidCallback? onTap;

  const QuickActionButton({
    super.key,
    this.icon,
    this.svgAsset,
    required this.label,
    this.onTap,
  }) : assert(icon != null || svgAsset != null, 'Either icon or svgAsset must be provided');

  @override
  Widget build(BuildContext context) {
    final colors = AppThemeManager.colors;

    Widget iconWidget;
    if (svgAsset != null) {
      iconWidget = SvgPicture.asset(
        svgAsset!,
        width: 26,
        height: 26,
        colorFilter: ColorFilter.mode(colors.textPrimary, BlendMode.srcIn),
      );
    } else {
      iconWidget = Icon(
        icon,
        color: colors.textPrimary,
        size: 26,
      );
    }

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: colors.iconBackground,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: colors.border,
                width: 1,
              ),
            ),
            child: Center(
              child: iconWidget,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Google Sans',
              color: colors.textSecondary,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
