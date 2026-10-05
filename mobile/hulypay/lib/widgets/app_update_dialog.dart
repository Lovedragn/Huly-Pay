import 'package:flutter/material.dart';
import '../services/app_update_service.dart';
import '../theme/app_theme.dart';

class AppUpdateDialog extends StatelessWidget {
  final AppUpdateInfo updateInfo;

  const AppUpdateDialog({
    super.key,
    required this.updateInfo,
  });

  /// Displays the appropriate dialog (blocking for forceUpdate, dismissible for optional update)
  static Future<void> show(BuildContext context, AppUpdateInfo updateInfo) async {
    await showDialog(
      context: context,
      barrierDismissible: !updateInfo.forceUpdate,
      builder: (ctx) => PopScope(
        canPop: !updateInfo.forceUpdate,
        child: AppUpdateDialog(updateInfo: updateInfo),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppThemeManager.colors;
    final isForce = updateInfo.forceUpdate;

    return Dialog(
      backgroundColor: colors.surface,
      elevation: 16,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(
          color: isForce
              ? const Color(0xFFFF453A).withValues(alpha: 0.3)
              : colors.border,
          width: 1.5,
        ),
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: isForce
                        ? const Color(0xFFFF453A).withValues(alpha: 0.15)
                        : colors.accent.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: Icon(
                      isForce
                          ? Icons.warning_amber_rounded
                          : Icons.rocket_launch_rounded,
                      color: isForce ? const Color(0xFFFF453A) : colors.accent,
                      size: 26,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isForce ? 'Update Required' : 'New Version Available',
                        style: TextStyle(
                          fontFamily: 'Google Sans',
                          fontSize: 19,
                          fontWeight: FontWeight.w700,
                          color: colors.textPrimary,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'v${updateInfo.currentVersion} → v${updateInfo.latestVersion}',
                        style: TextStyle(
                          fontFamily: 'Google Sans',
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: colors.accent,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Text(
              isForce
                  ? 'Your installed version of HulyPay (${updateInfo.currentVersion}) is no longer supported. Please update to continue using the application.'
                  : 'HulyPay ${updateInfo.latestVersion} is now available with new improvements, performance optimizations, and bug fixes.',
              style: TextStyle(
                fontFamily: 'Google Sans',
                fontSize: 14,
                height: 1.45,
                color: colors.textSecondary,
              ),
            ),
            const SizedBox(height: 20),
            // Direct Download Button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: () {
                  AppUpdateService().launchDownloadUrl(updateInfo.downloadUrl);
                  if (!isForce) {
                    Navigator.of(context).pop();
                  }
                },
                icon: const Icon(Icons.download_rounded, color: Colors.white, size: 20),
                label: Text(
                  isForce ? 'Update Now' : 'Download Update',
                  style: const TextStyle(
                    fontFamily: 'Google Sans',
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isForce ? const Color(0xFFFF453A) : colors.accent,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            // Website Download Link
            Center(
              child: TextButton.icon(
                onPressed: () {
                  AppUpdateService().launchOfficialWebsiteDownload();
                  if (!isForce) {
                    Navigator.of(context).pop();
                  }
                },
                icon: Icon(
                  Icons.open_in_browser_rounded,
                  size: 16,
                  color: colors.textSecondary,
                ),
                label: Text(
                  'Visit Official Download Page',
                  style: TextStyle(
                    fontFamily: 'Google Sans',
                    fontSize: 13,
                    color: colors.textSecondary,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ),
            if (!isForce) ...[
              const SizedBox(height: 4),
              Center(
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    'Later',
                    style: TextStyle(
                      fontFamily: 'Google Sans',
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: colors.textMuted,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
