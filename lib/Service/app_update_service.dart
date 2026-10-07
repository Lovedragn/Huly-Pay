import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../Data/external_data.dart';
import 'api_client.dart';

class AppUpdateInfo {
  final String currentVersion;
  final String latestVersion;
  final String minimumVersion;
  final bool updateAvailable;
  final bool forceUpdate;
  final String downloadUrl;
  final String message;
  final List<String> releaseNotes;

  AppUpdateInfo({
    required this.currentVersion,
    required this.latestVersion,
    required this.minimumVersion,
    required this.updateAvailable,
    required this.forceUpdate,
    required this.downloadUrl,
    required this.message,
    this.releaseNotes = const [],
  });

  factory AppUpdateInfo.fromJson(Map<String, dynamic> json) {
    List<String> parsedNotes = [];
    if (json['releaseNotes'] is List) {
      parsedNotes = (json['releaseNotes'] as List)
          .map((e) => e?.toString() ?? '')
          .where((e) => e.trim().isNotEmpty)
          .toList();
    }

    return AppUpdateInfo(
      currentVersion: json['currentVersion']?.toString() ?? '1.0.0',
      latestVersion: json['latestVersion']?.toString() ?? '1.0.0',
      minimumVersion: json['minimumVersion']?.toString() ?? '1.0.0',
      updateAvailable: json['updateAvailable'] == true,
      forceUpdate: json['forceUpdate'] == true,
      downloadUrl: json['downloadUrl']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
      releaseNotes: parsedNotes,
    );
  }
}

class AppUpdateService {
  static final AppUpdateService _instance = AppUpdateService._internal();
  factory AppUpdateService() => _instance;
  AppUpdateService._internal();

  /// Holds the latest update information once checked
  final ValueNotifier<AppUpdateInfo?> updateInfoNotifier = ValueNotifier<AppUpdateInfo?>(null);

  /// Dismissal flag for optional banner in the current session
  final ValueNotifier<bool> isBannerDismissedNotifier = ValueNotifier<bool>(false);

  /// Flag indicating that the main app UI has loaded and is ready to display overlays
  final ValueNotifier<bool> isAppReadyNotifier = ValueNotifier<bool>(false);

  void markAppReady() {
    isAppReadyNotifier.value = true;
  }

  /// Triggers backend health check and version check silently on startup
  Future<AppUpdateInfo?> checkAppVersion() async {
    // 1. Trigger backend health check silently as requested
    try {
      await ApiClient().getHealth();
    } catch (e) {
      if (kDebugMode) {
        print('AppUpdateService: Health check ping warning: $e');
      }
    }

    // 2. Fetch installed version via package_info_plus (with fallback to ExternalData.defaultAppVersion)
    String installedVersion = ExternalData.defaultAppVersion.replaceFirst(RegExp(r'^v'), '');
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      if (packageInfo.version.trim().isNotEmpty && packageInfo.version.trim() != '1.0.0') {
        installedVersion = packageInfo.version.trim();
      }
    } catch (e) {
      if (kDebugMode) {
        print('AppUpdateService: Failed to read package info: $e');
      }
    }

    // 3. Detect platform
    String platform = 'android';
    if (!kIsWeb) {
      if (Platform.isIOS) {
        platform = 'ios';
      } else if (Platform.isAndroid) {
        platform = 'android';
      }
    }

    // 4. Query backend version endpoint
    try {
      final response = await ApiClient().checkAppVersion(
        platform: platform,
        installedVersion: installedVersion,
      );

      final updateInfo = AppUpdateInfo.fromJson(response);
      updateInfoNotifier.value = updateInfo;
      return updateInfo;
    } catch (e) {
      if (kDebugMode) {
        print('AppUpdateService: Version check bypassed gracefully due to error: $e');
      }
      return null;
    }
  }

  /// Launch external download URL in browser
  Future<bool> launchDownloadUrl(String url) async {
    if (url.trim().isEmpty) return false;
    final uri = Uri.parse(url.trim());
    try {
      return await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
    } catch (e) {
      if (kDebugMode) {
        print('AppUpdateService: Error launching download url: $e');
      }
      return false;
    }
  }

  /// Launch official HulyPay download page
  Future<bool> launchOfficialWebsiteDownload() async {
    const officialUrl = 'https://huly-pay.vercel.app/download';
    return launchDownloadUrl(officialUrl);
  }

  void dismissBanner() {
    isBannerDismissedNotifier.value = true;
  }
}
