import 'package:flutter/material.dart';
import '../../Data/external_data.dart';
import '../../Service/user_preferences_service.dart';
import '../../Theme/app_theme.dart';

/// Modal bottom sheet for customizing App Themes and Chart Color Palettes
class CustomizationBottomSheet extends StatefulWidget {
  final VoidCallback onThemeChanged;

  const CustomizationBottomSheet({
    super.key,
    required this.onThemeChanged,
  });

  static Future<void> show(
    BuildContext context, {
    required VoidCallback onThemeChanged,
  }) {
    final colors = AppThemeManager.colors;
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: colors.surface,
      barrierColor: Colors.black.withValues(alpha: colors.isDark ? 0.70 : 0.45),
      shape: RoundedRectangleBorder(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        side: BorderSide(color: colors.border, width: 1.2),
      ),
      builder: (BuildContext ctx) {
        return CustomizationBottomSheet(
          onThemeChanged: onThemeChanged,
        );
      },
    );
  }

  @override
  State<CustomizationBottomSheet> createState() =>
      _CustomizationBottomSheetState();
}

class _CustomizationBottomSheetState extends State<CustomizationBottomSheet> {
  @override
  Widget build(BuildContext context) {
    final colors = AppThemeManager.colors;
    final currentAppTheme = AppThemeManager.currentTheme.value;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Sheet Drag Handle
              Center(
                child: Container(
                  width: 38,
                  height: 4,
                  decoration: BoxDecoration(
                    color: colors.textSecondary.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 18),

              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Theme & Style',
                    style: TextStyle(
                      fontFamily: 'Google Sans',
                      color: colors.textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: colors.surfaceSecondary,
                      shape: BoxShape.circle,
                      border: Border.all(color: colors.border),
                    ),
                    child: IconButton(
                      icon: Icon(
                        Icons.close_rounded,
                        color: colors.textPrimary,
                        size: 18,
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                      tooltip: 'Close',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // Unified Theme Selection
              for (final theme in ExternalData.themePresets) ...[
                _buildThemeOptionCard(
                  name: theme['name']!,
                  isSelected: currentAppTheme == theme['id'],
                  onTap: () {
                    final selectedTheme = theme['id']!;
                    AppThemeManager.setTheme(selectedTheme);
                    UserPreferencesService().savePreferences(
                      theme: selectedTheme,
                      chartPalette: selectedTheme,
                    );
                    widget.onThemeChanged();
                    setState(() {});
                  },
                ),
                const SizedBox(height: 10),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThemeOptionCard({
    required String name,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final colors = AppThemeManager.colors;
    final swatches = AppChartColors.allPalettes[name] ?? AppChartColors.defaultPalette;

    return Material(
      color: isSelected ? colors.surfaceSecondary : Colors.transparent,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? colors.accent : colors.border,
              width: isSelected ? 1.8 : 1,
            ),
          ),
          child: Row(
            children: [
              // 4-swatch mini palette preview indicator
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (int i = 0; i < 4 && i < swatches.length; i++)
                    Container(
                      margin: const EdgeInsets.only(right: 3),
                      width: 8,
                      height: 22,
                      decoration: BoxDecoration(
                        color: swatches[i],
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  name,
                  style: TextStyle(
                    fontFamily: 'Google Sans',
                    color: colors.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              if (isSelected)
                Icon(
                  Icons.check_circle_rounded,
                  color: colors.accent,
                  size: 22,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
