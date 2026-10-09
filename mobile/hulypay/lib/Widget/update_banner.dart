import 'package:flutter/material.dart';
import '../Service/app_update_service.dart';
import '../Service/user_preferences_service.dart';
import '../Theme/app_theme.dart';
import 'Components/round_button.dart';

/// 3:4 Aspect Ratio Update Banner Card with top-right rounded close button (reusing RoundButton.close),
/// point-wise detailed update notes, and bottom-center rounded update button.
class AppUpdateBanner extends StatelessWidget {
  final AppUpdateInfo updateInfo;

  const AppUpdateBanner({
    super.key,
    required this.updateInfo,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppThemeManager.colors;

    // Rich point-wise highlights from server release notes or detailed defaults
    final List<String> releasePoints = updateInfo.releaseNotes.isNotEmpty
        ? updateInfo.releaseNotes
        : const [
            'Faster QR code scanning with instant UPI payment handoff',
            'Interactive spend analytics & real-time daily budget tracker',
            'Secure offline transaction ledger with cloud auto-sync',
            'Smoother animations, UI refinements & stability enhancements',
          ];

    final isFunky = colors.name == 'Funky';
    final primaryAccent = isFunky ? const Color(0xFF0284C7) : colors.accent;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 310,
          ),
          child: AspectRatio(
            aspectRatio: 3 / 4,
            child: Container(
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: colors.border,
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: colors.isDark ? 0.45 : 0.12),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              clipBehavior: Clip.antiAlias,
              child: Stack(
                children: [
                  // Main card content layout
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header: Title & Latest Version Badge (clearance for 44px close button)
                        Padding(
                          padding: const EdgeInsets.only(right: 48.0, top: 4.0),
                          child: Row(
                            children: [
                              Flexible(
                                child: Text(
                                  'New Version Available',
                                  style: TextStyle(
                                    fontFamily: 'Google Sans',
                                    fontSize: 14.5,
                                    fontWeight: FontWeight.w700,
                                    color: colors.textPrimary,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 7,
                                  vertical: 2.5,
                                ),
                                decoration: BoxDecoration(
                                  color: primaryAccent.withValues(alpha: 0.14),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  'v${updateInfo.latestVersion}',
                                  style: TextStyle(
                                    fontFamily: 'Google Sans',
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w700,
                                    color: primaryAccent,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Middle point-wise detailed update information
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: colors.surfaceSecondary.withValues(alpha: 0.5),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: colors.border.withValues(alpha: 0.5),
                                  width: 0.8,
                                ),
                              ),
                              child: SingleChildScrollView(
                                physics: const BouncingScrollPhysics(),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "What's New in this Update:",
                                      style: TextStyle(
                                        fontFamily: 'Google Sans',
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: colors.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    ...releasePoints.map(
                                      (point) => Padding(
                                        padding: const EdgeInsets.only(bottom: 7),
                                        child: Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              margin: const EdgeInsets.only(top: 5, right: 8),
                                              width: 5,
                                              height: 5,
                                              decoration: BoxDecoration(
                                                color: primaryAccent,
                                                shape: BoxShape.circle,
                                              ),
                                            ),
                                            Expanded(
                                              child: Text(
                                                point,
                                                style: TextStyle(
                                                  fontFamily: 'Google Sans',
                                                  fontSize: 11.5,
                                                  color: colors.textSecondary,
                                                  height: 1.35,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),

                        // Bottom-center Update button with rounded corners
                        SizedBox(
                          width: double.infinity,
                          height: 42,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              AppUpdateService().launchDownloadUrl(updateInfo.downloadUrl);
                            },
                            icon: const Icon(
                              Icons.download_rounded,
                              color: Colors.white,
                              size: 17,
                            ),
                            label: const Text(
                              'Download File',
                              style: TextStyle(
                                fontFamily: 'Google Sans',
                                fontSize: 13.5,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryAccent,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(22),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 14),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Top-right close button reusing RoundButton component (equals back button size 44x44)
                  Positioned(
                    top: 10,
                    right: 10,
                    child: RoundButton.close(
                      onTap: () {
                        AppUpdateService().dismissBanner();
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Global floating update overlay positioned with highest z-index above all screens.
class AppUpdateFloatingBanner extends StatelessWidget {
  const AppUpdateFloatingBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AppUpdateInfo?>(
      valueListenable: AppUpdateService().updateInfoNotifier,
      builder: (context, updateInfo, _) {
        return ValueListenableBuilder<bool>(
          valueListenable: AppUpdateService().isBannerDismissedNotifier,
          builder: (context, isDismissed, _) {
            return ValueListenableBuilder<bool>(
              valueListenable: AppUpdateService().isAppReadyNotifier,
              builder: (context, isAppReady, _) {
                final bool isQuickScan = UserPreferencesService().cachedQuickScan;
                if (updateInfo == null ||
                    !updateInfo.updateAvailable ||
                    isDismissed ||
                    !isAppReady ||
                    isQuickScan) {
                  return const SizedBox.shrink();
                }

                return Positioned.fill(
                  child: Material(
                    color: Colors.black.withValues(alpha: 0.55),
                    child: GestureDetector(
                      onTap: () {
                        // Tapping background dismisses banner
                        AppUpdateService().dismissBanner();
                      },
                      behavior: HitTestBehavior.opaque,
                      child: Center(
                        child: GestureDetector(
                          onTap: () {
                            // Absorb taps on card content so tapping card does not dismiss
                          },
                          behavior: HitTestBehavior.opaque,
                          child: AppUpdateBanner(updateInfo: updateInfo),
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
