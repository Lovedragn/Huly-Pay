import 'package:flutter/material.dart';
import '../../Data/external_data.dart';
import '../../Theme/app_theme.dart';

class CategoryPickerSheet extends StatelessWidget {
  final String activeCategory;
  final ValueChanged<String> onSelectCategory;

  const CategoryPickerSheet({
    super.key,
    required this.activeCategory,
    required this.onSelectCategory,
  });

  static Future<String?> show(
    BuildContext context, {
    required String activeCategory,
  }) {
    final colors = AppThemeManager.colors;
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: colors.surface,
      barrierColor: Colors.black.withValues(alpha: colors.isDark ? 0.70 : 0.45),
      shape: RoundedRectangleBorder(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        side: BorderSide(color: colors.border, width: 1.2),
      ),
      builder: (BuildContext sheetCtx) {
        return CategoryPickerSheet(
          activeCategory: activeCategory,
          onSelectCategory: (selected) {
            Navigator.of(sheetCtx).pop(selected);
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppThemeManager.colors;
    final categories = ExternalData.defaultCategories;

    return SafeArea(
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.75,
        ),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Sheet Drag Handle
            Center(
              child: Container(
                width: 40,
                height: 4.5,
                decoration: BoxDecoration(
                  color: colors.textSecondary.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
            const SizedBox(height: 18),

            // Header with title and close button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Categorize Payment',
                        style: TextStyle(
                          fontFamily: 'Google Sans',
                          color: colors.textPrimary,
                          fontSize: 19,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Assign a category for budgeting and analytics',
                        style: TextStyle(
                          fontFamily: 'Google Sans',
                          color: colors.textSecondary,
                          fontSize: 12.5,
                        ),
                      ),
                    ],
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
                      color: colors.textSecondary,
                      size: 20,
                    ),
                    padding: const EdgeInsets.all(8),
                    constraints: const BoxConstraints(),
                    splashRadius: 20,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),

            // Category Toggle List
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                physics: const BouncingScrollPhysics(),
                itemCount: categories.length,
                separatorBuilder: (ctx, idx) => const SizedBox(height: 8),
                itemBuilder: (ctx, idx) {
                  final item = categories[idx];
                  final bool isSelected =
                      activeCategory.toLowerCase() == item.name.toLowerCase();

                  return Material(
                    color: isSelected
                        ? item.color.withValues(alpha: 0.14)
                        : colors.surfaceSecondary,
                    borderRadius: BorderRadius.circular(16),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () => onSelectCategory(item.name),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected
                                ? item.color
                                : colors.border,
                            width: isSelected ? 1.5 : 1.0,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: item.color.withValues(alpha: 0.16),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(item.icon, color: item.color, size: 20),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.name,
                                    style: TextStyle(
                                      fontFamily: 'Google Sans',
                                      color: isSelected
                                          ? colors.textPrimary
                                          : colors.textSecondary,
                                      fontSize: 15,
                                      fontWeight: isSelected
                                          ? FontWeight.w700
                                          : FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    item.description,
                                    style: TextStyle(
                                      fontFamily: 'Google Sans',
                                      color: colors.textMuted,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (isSelected)
                              Container(
                                width: 22,
                                height: 22,
                                decoration: BoxDecoration(
                                  color: item.color,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.check_rounded,
                                  color: Colors.white,
                                  size: 15,
                                ),
                              )
                            else
                              Container(
                                width: 20,
                                height: 20,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: colors.border,
                                    width: 1.5,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
