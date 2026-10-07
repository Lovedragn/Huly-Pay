import 'dart:async';
import 'package:flutter/material.dart';

import '../Theme/app_theme.dart';

/// ---------------------------------------------------------------------------
/// Card Dialog System
/// Provides card-like modal dialogs and notification toasts with a smooth
/// fade-in and slide-up from bottom animation across all pages of HulyPay.
/// ---------------------------------------------------------------------------

/// Universal card dialog transition with fade-in and slide-up from bottom.
Widget buildCardBottomFadeTransition(
  BuildContext context,
  Animation<double> animation,
  Animation<double> secondaryAnimation,
  Widget child,
) {
  final curved = CurvedAnimation(
    parent: animation,
    curve: Curves.easeOutCubic,
    reverseCurve: Curves.easeInCubic,
  );
  return FadeTransition(
    opacity: curved,
    child: SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0.0, 0.12),
        end: Offset.zero,
      ).animate(curved),
      child: child,
    ),
  );
}

/// Shows a dialog wrapped in a card with fade-in from bottom animation.
Future<T?> showCardDialog<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool barrierDismissible = true,
  Color? barrierColor,
  String barrierLabel = 'Dismiss',
  Duration transitionDuration = const Duration(milliseconds: 280),
}) {
  return showGeneralDialog<T>(
    context: context,
    barrierDismissible: barrierDismissible,
    barrierLabel: barrierLabel,
    barrierColor: barrierColor ?? Colors.black.withValues(alpha: 0.65),
    transitionDuration: transitionDuration,
    pageBuilder: (ctx, anim1, anim2) => builder(ctx),
    transitionBuilder: buildCardBottomFadeTransition,
  );
}

/// A card-like dialog container adhering to HulyPay design tokens.
class CardDialog extends StatelessWidget {
  final Widget? icon;
  final Widget? title;
  final Widget content;
  final List<Widget>? actions;
  final EdgeInsets insetPadding;
  final EdgeInsetsGeometry contentPadding;
  final double maxWidth;
  final Color? backgroundColor;
  final Color? borderColor;

  const CardDialog({
    super.key,
    this.icon,
    this.title,
    required this.content,
    this.actions,
    this.insetPadding = const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
    this.contentPadding = const EdgeInsets.all(24),
    this.maxWidth = 420,
    this.backgroundColor,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final bg = backgroundColor ?? colors.surface;
    final border = borderColor ?? colors.border;

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: insetPadding,
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: Container(
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(AppRadii.card),
              border: Border.all(color: border, width: 1.2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: colors.isDark ? 0.45 : 0.08),
                  blurRadius: 28,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Padding(
              padding: contentPadding,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (icon != null || title != null) ...[
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        if (icon != null) ...[
                          icon!,
                          const SizedBox(width: 12),
                        ],
                        if (title != null)
                          Expanded(
                            child: DefaultTextStyle(
                              style: TextStyle(
                                fontFamily: 'Google Sans',
                                color: colors.textPrimary,
                                fontWeight: FontWeight.w700,
                                fontSize: 18,
                              ),
                              child: title!,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],
                  DefaultTextStyle(
                    style: TextStyle(
                      fontFamily: 'Google Sans',
                      color: colors.textSecondary,
                      fontSize: 14,
                      height: 1.45,
                    ),
                    child: content,
                  ),
                  if (actions != null && actions!.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: actions!,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Square tinted icon container for card dialog headers.
class CardDialogTitleIcon extends StatelessWidget {
  final Color color;
  final Widget child;
  final double size;

  const CardDialogTitleIcon({
    super.key,
    required this.color,
    required this.child,
    this.size = 36,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Center(child: child),
    );
  }
}

/// Notification type for card toasts and dialog banners.
enum CardNotificationType { info, success, warning, error }

/// Displays an animated card-like notification toast with fade-in and
/// slide-up from bottom animation across any page.
void showCardNotification(
  BuildContext context, {
  required String message,
  String? title,
  Widget? leading,
  CardNotificationType type = CardNotificationType.info,
  Duration duration = const Duration(seconds: 3),
  VoidCallback? onTap,
}) {
  if (!context.mounted) return;
  final colors = AppThemeManager.colors;

  final Color accentColor = switch (type) {
    CardNotificationType.success => colors.success,
    CardNotificationType.warning => colors.warning,
    CardNotificationType.error => colors.error,
    CardNotificationType.info => colors.accent,
  };

  final IconData defaultIcon = switch (type) {
    CardNotificationType.success => Icons.check_circle_rounded,
    CardNotificationType.warning => Icons.warning_amber_rounded,
    CardNotificationType.error => Icons.error_outline_rounded,
    CardNotificationType.info => Icons.info_outline_rounded,
  };

  final overlay = Overlay.maybeOf(context);
  if (overlay == null) {
    // Fallback to floating card SnackBar if overlay is not accessible
    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger == null) return;
    messenger.clearSnackBars();
    messenger.showSnackBar(
      SnackBar(
        elevation: 8,
        backgroundColor: colors.surface,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.lg),
          side: BorderSide(color: colors.border, width: 1.2),
        ),
        duration: duration,
        content: Row(
          children: [
            leading ??
                Icon(defaultIcon, color: accentColor, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  fontFamily: 'Google Sans',
                  color: colors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
    return;
  }

  late final OverlayEntry entry;
  entry = OverlayEntry(
    builder: (ctx) => _CardNotificationOverlay(
      message: message,
      title: title,
      leading: leading,
      accentColor: accentColor,
      defaultIcon: defaultIcon,
      duration: duration,
      onTap: onTap,
      onDismiss: () {
        if (entry.mounted) {
          entry.remove();
        }
      },
    ),
  );

  overlay.insert(entry);
}

class _CardNotificationOverlay extends StatefulWidget {
  final String message;
  final String? title;
  final Widget? leading;
  final Color accentColor;
  final IconData defaultIcon;
  final Duration duration;
  final VoidCallback? onTap;
  final VoidCallback onDismiss;

  const _CardNotificationOverlay({
    required this.message,
    this.title,
    this.leading,
    required this.accentColor,
    required this.defaultIcon,
    required this.duration,
    this.onTap,
    required this.onDismiss,
  });

  @override
  State<_CardNotificationOverlay> createState() => _CardNotificationOverlayState();
}

class _CardNotificationOverlayState extends State<_CardNotificationOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;
  Timer? _dismissTimer;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
      reverseDuration: const Duration(milliseconds: 220),
    );

    final curved = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(curved);
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.4),
      end: Offset.zero,
    ).animate(curved);

    _animController.forward();
    _dismissTimer = Timer(widget.duration, _dismiss);
  }

  void _dismiss() {
    if (!mounted) return;
    _dismissTimer?.cancel();
    _animController.reverse().then((_) {
      if (mounted) widget.onDismiss();
    });
  }

  @override
  void dispose() {
    _dismissTimer?.cancel();
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppThemeManager.colors;
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom +
        MediaQuery.paddingOf(context).bottom +
        16;

    return Positioned(
      bottom: bottomInset,
      left: 20,
      right: 20,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: SlideTransition(
            position: _slideAnimation,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Material(
                color: Colors.transparent,
                child: Dismissible(
                  key: UniqueKey(),
                  direction: DismissDirection.down,
                  onDismissed: (_) => widget.onDismiss(),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(AppRadii.card),
                    onTap: () {
                      widget.onTap?.call();
                      _dismiss();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: colors.surface,
                        borderRadius: BorderRadius.circular(AppRadii.card),
                        border: Border.all(color: colors.border, width: 1.2),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(
                              alpha: colors.isDark ? 0.45 : 0.10,
                            ),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          widget.leading ??
                              CardDialogTitleIcon(
                                color: widget.accentColor,
                                size: 36,
                                child: Icon(
                                  widget.defaultIcon,
                                  color: widget.accentColor,
                                  size: 20,
                                ),
                              ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (widget.title != null) ...[
                                  Text(
                                    widget.title!,
                                    style: TextStyle(
                                      fontFamily: 'Google Sans',
                                      color: colors.textPrimary,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                ],
                                Text(
                                  widget.message,
                                  style: TextStyle(
                                    fontFamily: 'Google Sans',
                                    color: widget.title != null
                                        ? colors.textSecondary
                                        : colors.textPrimary,
                                    fontSize: 13.5,
                                    fontWeight: widget.title != null
                                        ? FontWeight.w400
                                        : FontWeight.w500,
                                    height: 1.35,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: _dismiss,
                            child: Icon(
                              Icons.close_rounded,
                              size: 18,
                              color: colors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
