import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../theme/app_theme.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemSelected;

  const CustomBottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppThemeManager.colors;
    final bottomInset = MediaQuery.of(context).padding.bottom;
    final bottomMargin = bottomInset > 0 ? bottomInset + 8.0 : 16.0;
    final navBarBg = colors.isDark
        ? (colors.navBarBackground == const Color(0xFF000000)
            ? const Color(0xFF141416)
            : colors.navBarBackground)
        : colors.navBarBackground;

    final gradientHeight = bottomMargin + 64.0 + 36.0;

    return SizedBox(
      height: gradientHeight,
      child: Stack(
        alignment: Alignment.bottomCenter,
        clipBehavior: Clip.none,
        children: [
          // 1. Soft bottom-to-top gradient overlay below/behind the navbar
          // Colors are managed directly in app_theme.dart (from -> to)
          Positioned.fill(
            child: IgnorePointer(
              child: Container(
                key: const Key('bottom_nav_gradient'),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      colors.navBarGradientFrom, // From (bottom)
                      colors.navBarGradientTo,   // To (top)
                    ],
                  ),
                ),
              ),
            ),
          ),

          // 2. Floating navbar dock
          Positioned(
            left: 20.0,
            right: 20.0,
            bottom: bottomMargin,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: Container(
                  key: const Key('floating_navbar_container'),
                  height: 64,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: navBarBg,
              borderRadius: BorderRadius.circular(32),
              border: Border.all(
                color: colors.border.withValues(alpha: colors.isDark ? 0.35 : 0.7),
                width: 1.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(
                    alpha: colors.isDark ? 0.45 : 0.08,
                  ),
                  blurRadius: 24,
                  spreadRadius: 0,
                  offset: const Offset(0, 8),
                ),
                if (colors.isDark)
                  BoxShadow(
                    color: Colors.white.withValues(alpha: 0.04),
                    blurRadius: 1,
                    spreadRadius: 0,
                    offset: const Offset(0, -1),
                  ),
              ],
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                const itemCount = 3;
                final totalWidth = constraints.maxWidth;
                final itemWidth = totalWidth / itemCount;
                const pillWidth = 86.0;
                const pillHeight = 50.0;
                final pillTop = (constraints.maxHeight - pillHeight) / 2;

                final isVisible =
                    selectedIndex >= 0 && selectedIndex < itemCount;
                final activeIndex = isVisible ? selectedIndex : 0;
                final pillLeft =
                    (itemWidth * activeIndex) + (itemWidth - pillWidth) / 2;

                return Stack(
                  children: [
                    // Sliding background pill card
                    AnimatedPositioned(
                      duration: const Duration(milliseconds: 260),
                      curve: Curves.easeInOutCubic,
                      left: pillLeft,
                      top: pillTop,
                      width: pillWidth,
                      height: pillHeight,
                      child: AnimatedOpacity(
                        duration: const Duration(milliseconds: 200),
                        opacity: isVisible ? 1.0 : 0.0,
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFFE5E7EB),
                            borderRadius: BorderRadius.circular(AppRadii.pill),
                          ),
                        ),
                      ),
                    ),

                    // Interactive navigation items (Row on top)
                    Row(
                      children: [
                        // 1. Home
                        _buildNavItem(
                          index: 0,
                          iconBuilder: (color) => SvgPicture.asset(
                            'assets/icon/home.svg',
                            width: 24,
                            height: 24,
                            colorFilter:
                                ColorFilter.mode(color, BlendMode.srcIn),
                          ),
                        ),

                        // 2. Analyze
                        _buildNavItem(
                          index: 1,
                          iconBuilder: (color) => SvgPicture.asset(
                            'assets/icon/analysis.svg',
                            width: 24,
                            height: 24,
                            colorFilter:
                                ColorFilter.mode(color, BlendMode.srcIn),
                          ),
                        ),

                        // 3. Transactions
                        _buildNavItem(
                          index: 2,
                          iconBuilder: (color) => SvgPicture.asset(
                            'assets/icon/transaction.svg',
                            width: 24,
                            height: 24,
                            colorFilter:
                                ColorFilter.mode(color, BlendMode.srcIn),
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    ),
  ],
),
);
}

  Widget _buildNavItem({
    required int index,
    required Widget Function(Color color) iconBuilder,
  }) {
    final colors = AppThemeManager.colors;
    final isSelected = selectedIndex == index;
    final activeIconColor =
        colors.isDark ? const Color(0xFF141416) : colors.textPrimary;
    final targetColor = isSelected ? activeIconColor : colors.navBarInactive;

    return Expanded(
      child: GestureDetector(
        onTap: () => onItemSelected(index),
        behavior: HitTestBehavior.opaque,
        child: Center(
          child: SizedBox(
            width: 86,
            height: 50,
            child: Center(
              child: TweenAnimationBuilder<Color?>(
                tween: ColorTween(end: targetColor),
                duration: const Duration(milliseconds: 240),
                curve: Curves.easeInOutCubic,
                builder: (context, color, child) {
                  return iconBuilder(color ?? targetColor);
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
