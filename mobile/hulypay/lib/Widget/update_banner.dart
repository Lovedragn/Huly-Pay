import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../Service/app_update_service.dart';
import '../Theme/app_theme.dart';

class AppUpdateBanner extends StatelessWidget {
  final AppUpdateInfo updateInfo;

  const AppUpdateBanner({
    super.key,
    required this.updateInfo,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppThemeManager.colors;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colors.accent.withValues(alpha: 0.35),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: colors.accent.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: colors.accent.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Icon(
                    Icons.rocket_launch_rounded,
                    color: colors.accent,
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'New Version Available',
                          style: TextStyle(
                            fontFamily: 'Google Sans',
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: colors.textPrimary,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: colors.accent.withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'v${updateInfo.latestVersion}',
                            style: TextStyle(
                              fontFamily: 'Google Sans',
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: colors.accent,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      updateInfo.message.isNotEmpty
                          ? updateInfo.message
                          : 'A new version of HulyPay is ready for download.',
                      style: TextStyle(
                        fontFamily: 'Google Sans',
                        fontSize: 12,
                        color: colors.textSecondary,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () {
                  AppUpdateService().dismissBanner();
                },
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: SvgPicture.asset(
                    'assets/icon/close.svg',
                    width: 16,
                    height: 16,
                    colorFilter: ColorFilter.mode(colors.textMuted, BlendMode.srcIn),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 36,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      AppUpdateService().launchDownloadUrl(updateInfo.downloadUrl);
                    },
                    icon: const Icon(Icons.download_rounded, color: Colors.white, size: 16),
                    label: const Text(
                      'Download File',
                      style: TextStyle(
                        fontFamily: 'Google Sans',
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colors.accent,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: SizedBox(
                  height: 36,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      AppUpdateService().launchOfficialWebsiteDownload();
                    },
                    icon: Icon(
                      Icons.language_rounded,
                      size: 16,
                      color: colors.textPrimary,
                    ),
                    label: Text(
                      'Official Site',
                      style: TextStyle(
                        fontFamily: 'Google Sans',
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: colors.textPrimary,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: colors.border, width: 1.2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
