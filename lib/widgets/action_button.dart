import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

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
    Widget iconWidget;
    if (svgAsset != null) {
      iconWidget = SvgPicture.asset(
        svgAsset!,
        width: 26,
        height: 26,
        colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
      );
    } else {
      iconWidget = Icon(
        icon,
        color: Colors.white,
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
              color: const Color(0xFF161619),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFF24242A),
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
            style: const TextStyle(
              fontFamily: 'Google Sans',
              color: Color(0xFF8E8E93),
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
