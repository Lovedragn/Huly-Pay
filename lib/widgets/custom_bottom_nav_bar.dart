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

    return Container(
      decoration: BoxDecoration(
        color: colors.navBarBackground,
        border: Border(top: BorderSide(color: colors.divider, width: 0.5)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.only(top: 12, bottom: 14),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // 1. Home
              _buildNavItem(
                index: 0,
                iconBuilder: (color) => SvgPicture.asset(
                  'asserts/icon/home.svg',
                  width: 24,
                  height: 24,
                  colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
                ),
              ),

              // 2. Analyze
              _buildNavItem(
                index: 1,
                iconBuilder: (color) => SvgPicture.asset(
                  'asserts/icon/analysis.svg',
                  width: 24,
                  height: 24,
                  colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
                ),
              ),

              // 3. Transactions
              _buildNavItem(
                index: 2,
                iconBuilder: (color) => SvgPicture.asset(
                  'asserts/icon/transaction.svg',
                  width: 24,
                  height: 24,
                  colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required Widget Function(Color color) iconBuilder,
  }) {
    final colors = AppThemeManager.colors;
    final isSelected = selectedIndex == index;
    final itemColor = isSelected ? colors.navBarActive : colors.navBarInactive;

    return GestureDetector(
      onTap: () => onItemSelected(index),
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: iconBuilder(itemColor),
      ),
    );
  }
}
