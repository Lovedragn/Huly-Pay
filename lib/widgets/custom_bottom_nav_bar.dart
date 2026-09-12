import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

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
    return Container(
      color: const Color(0xFF000000),
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
                            ? const Color(0xFF007AFF)
                            : const Color(0xFF202024),
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
                                : const Color(0xFF8E8E93),
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
    final isSelected = selectedIndex == index;
    final color = isSelected ? Colors.white : const Color(0xFF6B6B70);

    return GestureDetector(
      onTap: () => onItemSelected(index),
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 26,
              child: Center(child: iconBuilder(color)),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Google Sans',
                color: color,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                letterSpacing: -0.1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
