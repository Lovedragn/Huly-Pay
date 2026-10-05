import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hulypay/services/app_update_service.dart';
import 'package:hulypay/widgets/app_update_banner.dart';
import 'package:hulypay/widgets/app_update_dialog.dart';

void main() {
  test('AppUpdateInfo model deserializes JSON properly', () {
    final json = {
      'currentVersion': '1.1.0',
      'latestVersion': '1.2.0',
      'minimumVersion': '1.0.0',
      'updateAvailable': true,
      'forceUpdate': false,
      'downloadUrl': 'https://huly-pay.vercel.app/downloads/hulypay-1.2.0.apk',
      'message': 'A new version of HulyPay is available.',
    };

    final info = AppUpdateInfo.fromJson(json);

    expect(info.currentVersion, equals('1.1.0'));
    expect(info.latestVersion, equals('1.2.0'));
    expect(info.minimumVersion, equals('1.0.0'));
    expect(info.updateAvailable, isTrue);
    expect(info.forceUpdate, isFalse);
    expect(info.downloadUrl, equals('https://huly-pay.vercel.app/downloads/hulypay-1.2.0.apk'));
    expect(info.message, equals('A new version of HulyPay is available.'));
  });

  testWidgets('AppUpdateBanner renders latest version and action buttons', (tester) async {
    final updateInfo = AppUpdateInfo(
      currentVersion: '1.1.0',
      latestVersion: '1.2.0',
      minimumVersion: '1.0.0',
      updateAvailable: true,
      forceUpdate: false,
      downloadUrl: 'https://huly-pay.vercel.app/downloads/hulypay-1.2.0.apk',
      message: 'New features ready',
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AppUpdateBanner(updateInfo: updateInfo),
        ),
      ),
    );

    expect(find.text('New Version Available'), findsOneWidget);
    expect(find.text('v1.2.0'), findsOneWidget);
    expect(find.text('Download File'), findsOneWidget);
    expect(find.text('Official Site'), findsOneWidget);
  });

  testWidgets('AppUpdateDialog renders force update without Later button', (tester) async {
    final updateInfo = AppUpdateInfo(
      currentVersion: '1.0.0',
      latestVersion: '1.2.0',
      minimumVersion: '1.1.0',
      updateAvailable: true,
      forceUpdate: true,
      downloadUrl: 'https://huly-pay.vercel.app/downloads/hulypay-1.2.0.apk',
      message: 'Update required',
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AppUpdateDialog(updateInfo: updateInfo),
        ),
      ),
    );

    expect(find.text('Update Required'), findsOneWidget);
    expect(find.text('Update Now'), findsOneWidget);
    expect(find.text('Later'), findsNothing);
  });

  testWidgets('AppUpdateDialog renders optional update with Later button', (tester) async {
    final updateInfo = AppUpdateInfo(
      currentVersion: '1.1.0',
      latestVersion: '1.2.0',
      minimumVersion: '1.0.0',
      updateAvailable: true,
      forceUpdate: false,
      downloadUrl: 'https://huly-pay.vercel.app/downloads/hulypay-1.2.0.apk',
      message: 'Optional update',
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AppUpdateDialog(updateInfo: updateInfo),
        ),
      ),
    );

    expect(find.text('New Version Available'), findsOneWidget);
    expect(find.text('Download Update'), findsOneWidget);
    expect(find.text('Later'), findsOneWidget);
  });
}
