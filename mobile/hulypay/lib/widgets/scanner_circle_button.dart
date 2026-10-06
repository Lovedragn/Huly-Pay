import 'package:flutter/material.dart';

/// 44px circular glass button used on the scanner overlay.
class ScannerCircleButton extends StatelessWidget {
  final VoidCallback onTap;
  final Widget child;
  final Color background;
  final Color borderColor;
  final String? tooltip;

  const ScannerCircleButton({
    super.key,
    required this.onTap,
    required this.child,
    required this.background,
    required this.borderColor,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    Widget button = GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: background,
            shape: BoxShape.circle,
            border: Border.all(color: borderColor, width: 1.5),
          ),
          child: Center(child: child),
        ),
      ),
    );
    if (tooltip != null) {
      button = Tooltip(message: tooltip!, child: button);
    }
    return button;
  }
}
