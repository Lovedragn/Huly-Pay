import 'package:flutter/material.dart';
import 'round_button.dart';

/// Legacy adapter for backward compatibility. Uses [RoundButton.back].
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
    return RoundButton.back(
      onTap: onPressed,
      tooltip: tooltip,
      backgroundColor: backgroundColor,
      borderColor: borderColor,
      iconColor: iconColor,
      iconSize: iconSize,
    );
  }
}
