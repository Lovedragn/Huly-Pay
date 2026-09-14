import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../theme/app_theme.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final bool isQrActive;
  final ValueChanged<int> onItemSelected;
  final VoidCallback? onQrScanTap;

  const CustomBottomNavBar({
    super.key,
    required this.selectedIndex,
    this.isQrActive = false,
    required this.onItemSelected,
    this.onQrScanTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppThemeManager.colors;

    return Container(
      decoration: BoxDecoration(
        color: colors.navBarBackground,
        border: Border(
          top: BorderSide(
            color: colors.divider,
            width: 0.5,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.only(
            left: 12,
            right: 12,
            top: 10,
            bottom: 14,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 1. Home
              Expanded(
                child: _buildNavItem(
                  index: 0,
                  label: 'Home',
                  iconBuilder: (color) => SvgPicture.asset(
                    'asserts/icon/home.svg',
                    width: 22,
                    height: 22,
                    colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
                  ),
                ),
              ),

              // 2. Analyze
              Expanded(
                child: _buildNavItem(
                  index: 1,
                  label: 'Analyze',
                  iconBuilder: (color) => SvgPicture.asset(
                    'asserts/icon/analysis.svg',
                    width: 22,
                    height: 22,
                    colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
                  ),
                ),
              ),

              // 3. Transactions
              Expanded(
                child: _buildNavItem(
                  index: 2,
                  label: 'Transactions',
                  iconBuilder: (color) => SvgPicture.asset(
                    'asserts/icon/transaction.svg',
                    width: 22,
                    height: 22,
                    colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
                  ),
                ),
              ),

              // 4. QR Scan Circle Button
              Expanded(
                child: Center(
                  child: GestureDetector(
                    onTap: onQrScanTap,
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: isQrActive
                            ? colors.accent
                            : colors.iconBackground,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: SvgPicture.asset(
                          'asserts/icon/qr.svg',
                          width: 22,
                          height: 22,
                          colorFilter: ColorFilter.mode(
                            isQrActive
                                ? Colors.white
                                : colors.iconDefault,
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                    ),
                  ),
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
    required String label,
    required Widget Function(Color color) iconBuilder,
  }) {
    final colors = AppThemeManager.colors;
    final isSelected = selectedIndex == index;
    final itemColor = isSelected
        ? colors.navBarActive
        : colors.navBarInactive;

    return GestureDetector(
      onTap: () => onItemSelected(index),
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          iconBuilder(itemColor),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Google Sans',
              color: itemColor,
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
