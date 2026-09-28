import 'package:flutter/material.dart';
import '../data/external_data.dart';
import '../services/user_preferences_service.dart';
import '../theme/app_theme.dart';
import '../theme/chart_colors.dart';

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
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: AppThemeManager.colors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
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
    final currentChartPalette = AppThemeManager.currentChartPalette.value;

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
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Customization',
                        style: TextStyle(
                          fontFamily: 'Google Sans',
                          color: colors.textPrimary,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Themes & Chart Color Palettes',
                        style: TextStyle(
                          fontFamily: 'Google Sans',
                          color: colors.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                    ],
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
              const SizedBox(height: 16),

              // Section 1: App Theme Presets
              Text(
                'APP THEME',
                style: TextStyle(
                  fontFamily: 'Google Sans',
                  color: colors.accent,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.1,
                ),
              ),
              const SizedBox(height: 10),

              for (final theme in ExternalData.themePresets) ...[
                _buildThemeOptionCard(
                  name: theme['name']!,
                  label: theme['label']!,
                  description: theme['description']!,
                  isSelected: currentAppTheme == theme['id'],
                  onTap: () {
                    final selectedTheme = theme['id']!;
                    AppThemeManager.setTheme(selectedTheme);
                    UserPreferencesService().savePreferences(
                      theme: selectedTheme,
                      chartPalette: AppThemeManager.chartPalette,
                    );
                    widget.onThemeChanged();
                    setState(() {});
                  },
                ),
                const SizedBox(height: 8),
              ],

              const SizedBox(height: 16),
              Divider(color: colors.divider, height: 1, thickness: 1),
              const SizedBox(height: 16),

              // Section 2: Chart Color & Skin Presets
              Text(
                'CHART COLORS',
                style: TextStyle(
                  fontFamily: 'Google Sans',
                  color: colors.accent,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.1,
                ),
              ),
              const SizedBox(height: 10),

              for (final paletteName in kChartPaletteNames) ...[
                _buildChartPaletteOptionCard(
                  name: paletteName,
                  isSelected: currentChartPalette == paletteName,
                  onTap: () {
                    AppThemeManager.setChartPalette(paletteName);
                    UserPreferencesService().savePreferences(
                      theme: AppThemeManager.theme,
                      chartPalette: paletteName,
                    );
                    widget.onThemeChanged();
                    setState(() {});
                  },
                ),
                const SizedBox(height: 8),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThemeOptionCard({
    required String name,
    required String label,
    required String description,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final colors = AppThemeManager.colors;

    return Material(
      color: isSelected ? colors.surfaceSecondary : Colors.transparent,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected ? colors.accent : colors.border,
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          name,
                          style: TextStyle(
                            fontFamily: 'Google Sans',
                            color: colors.textPrimary,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: colors.surfaceSecondary,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: colors.border,
                              width: 0.5,
                            ),
                          ),
                          child: Text(
                            label,
                            style: TextStyle(
                              fontFamily: 'Google Sans',
                              color: colors.textSecondary,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      description,
                      style: TextStyle(
                        fontFamily: 'Google Sans',
                        color: colors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
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

  Widget _buildChartPaletteOptionCard({
    required String name,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final colors = AppThemeManager.colors;
    final swatches =
        AppChartColors.allPalettes[name] ?? AppChartColors.defaultPalette;
    final description = ExternalData.chartPaletteDescriptions[name] ??
        'Electric Blue, vibrant Cyan, Mint, Amber & Rose (Default)';

    return Material(
      color: isSelected ? colors.surfaceSecondary : Colors.transparent,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected ? colors.accent : colors.border,
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              // Swatches row (5 dots)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (int i = 0; i < 5 && i < swatches.length; i++)
                    Container(
                      margin: const EdgeInsets.only(right: 3),
                      width: 9,
                      height: 20,
                      decoration: BoxDecoration(
                        color: swatches[i],
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                        fontFamily: 'Google Sans',
                        color: colors.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      description,
                      style: TextStyle(
                        fontFamily: 'Google Sans',
                        color: colors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
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
