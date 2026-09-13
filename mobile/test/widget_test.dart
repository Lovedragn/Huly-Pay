import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/main.dart';
import 'package:mobile/screens/analysis_screen.dart';
import 'package:mobile/screens/home_dashboard_screen.dart';
import 'package:mobile/screens/scan_and_pay_screen.dart';
import 'package:mobile/screens/settings_screen.dart';
import 'package:mobile/screens/sign_in_screen.dart';
import 'package:mobile/screens/single_transaction_screen.dart';
import 'package:mobile/screens/splash_screen.dart';
import 'package:mobile/screens/transactions_screen.dart';
import 'package:mobile/services/auth_service.dart';
import 'package:mobile/widgets/action_button.dart';
import 'package:mobile/widgets/custom_bottom_nav_bar.dart';

void main() {
  testWidgets('HomeDashboardScreen and CustomBottomNavBar smoke test',
      (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const HulyPayApp());

    // Verify key elements from the dashboard mockup are present.
    expect(find.text('Good Morning,'), findsNothing);
    expect(find.text('Sujith'), findsNothing);
    expect(find.text('TOTAL SPENT'), findsOneWidget);
    expect(find.text('₹12,480'), findsOneWidget);

    // Verify quick action buttons
    expect(find.byType(QuickActionButton), findsNWidgets(3));
    expect(find.text('upload'), findsOneWidget);
    expect(find.text('Scan'), findsOneWidget);
    expect(find.text('More'), findsOneWidget);

    // Verify BarChart from fl_chart & verify Recent Transactions section is removed from Home
    expect(find.byType(BarChart), findsOneWidget);
    expect(find.text('WEEKLY SPENDING'), findsOneWidget);
    expect(find.text('Recent Transactions'), findsNothing);

    // Verify CustomBottomNavBar and its tabs
    expect(find.byType(CustomBottomNavBar), findsOneWidget);
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Analyze'), findsOneWidget);
    expect(find.text('Transactions'), findsOneWidget);
  });

  testWidgets('Navigate to ScanAndPayScreen and return smoke test',
      (WidgetTester tester) async {
    await tester.pumpWidget(const HulyPayApp());

    // Tap the Scan button
    await tester.tap(find.text('Scan'));
    await tester.pumpAndSettle();

    // Verify ScanAndPayScreen elements
    expect(find.byType(ScanAndPayScreen), findsOneWidget);
    expect(find.text('Scan any UPI QR code'), findsOneWidget);
    expect(find.text('Align the QR code within the frame'), findsOneWidget);
    expect(find.text('Back to Home'), findsOneWidget);

    // Verify center extra switch and rear camera buttons are removed from viewfinder
    expect(find.byKey(const Key('scanner_corner_switch_button')), findsNothing);
    expect(find.byKey(const Key('scanner_switch_button')), findsNothing);
    expect(find.text('Rear Camera'), findsNothing);
    expect(find.text('Front Camera'), findsNothing);

    // Verify Flash and Switch buttons exist on the right side bottom near QR icon
    final flashButton = find.byKey(const Key('flash_button'));
    final switchCameraButton = find.byKey(const Key('switch_camera_button'));

    expect(flashButton, findsOneWidget);
    expect(switchCameraButton, findsOneWidget);

    // Toggle to Front Camera using switch camera button
    await tester.tap(switchCameraButton);
    await tester.pumpAndSettle();
    expect(find.text('Switched to Front Camera'), findsOneWidget);

    // Toggle back to Rear Camera using switch camera button
    await tester.tap(switchCameraButton);
    await tester.pumpAndSettle();
    expect(find.text('Switched to Rear Camera'), findsOneWidget);

    // Tap Back to Home button to return
    await tester.tap(find.text('Back to Home'));
    await tester.pumpAndSettle();

    // Verify returned to Home
    expect(find.text('TOTAL SPENT'), findsOneWidget);
  });

  testWidgets('Navigate to TransactionsScreen smoke test',
      (WidgetTester tester) async {
    await tester.pumpWidget(const HulyPayApp());

    // Tap Transactions tab in bottom navigation bar
    await tester.tap(find.text('Transactions'));
    await tester.pumpAndSettle();

    // Verify TransactionsScreen is loaded
    expect(find.byType(TransactionsScreen), findsOneWidget);
    expect(find.text('Search transactions'), findsOneWidget);

    // Verify filter chips
    expect(find.byKey(const Key('filter_chip_All')), findsOneWidget);
    expect(find.byKey(const Key('filter_chip_Failed')), findsOneWidget);
    expect(find.byKey(const Key('filter_chip_Food')), findsOneWidget);
    expect(find.byKey(const Key('filter_chip_Internet')), findsOneWidget);
    expect(find.byKey(const Key('filter_chip_Shopping')), findsOneWidget);
    expect(find.byKey(const Key('filter_chip_Bills')), findsOneWidget);
    expect(find.text('UPI'), findsNothing);
    expect(find.text('Income'), findsNothing);

    // Verify group sections
    expect(find.text('TODAY'), findsOneWidget);
    expect(find.text('YESTERDAY'), findsOneWidget);

    // Verify transactions
    expect(find.text('CRED'), findsOneWidget);
    expect(find.text('Google Play'), findsOneWidget);
    expect(find.text('Zomato'), findsOneWidget);
    expect(find.text('Metro'), findsOneWidget);
    expect(find.text('Airtel Fiber'), findsOneWidget);

    // Filter by Failed
    await tester.tap(find.byKey(const Key('filter_chip_Failed')));
    await tester.pumpAndSettle();
    expect(find.text('Uber'), findsOneWidget);
    expect(find.text('Netflix'), findsOneWidget);
    expect(find.text('Swiggy'), findsNothing); // Non-failed excluded

    // Filter by Internet
    await tester.tap(find.byKey(const Key('filter_chip_Internet')));
    await tester.pumpAndSettle();
    expect(find.text('Airtel Fiber'), findsOneWidget);
    expect(find.text('Uber'), findsNothing);
  });

  testWidgets('Navigate to AnalysisScreen smoke test',
      (WidgetTester tester) async {
    await tester.pumpWidget(const HulyPayApp());

    // Tap Analyze tab in bottom navigation bar
    await tester.tap(find.text('Analyze'));
    await tester.pumpAndSettle();

    // Verify AnalysisScreen is loaded
    expect(find.byType(AnalysisScreen), findsOneWidget);
    expect(find.text('Spending Insights'), findsOneWidget);
    expect(find.text('This Month'), findsOneWidget);

    // Verify PieChart from fl_chart and donut chart center texts
    expect(find.byType(PieChart), findsOneWidget);
    expect(find.text('Spent this month'), findsOneWidget);

    // Verify categories
    expect(find.text('Food & Dining'), findsOneWidget);
    expect(find.text('Shopping'), findsOneWidget);
    expect(find.text('Transport'), findsOneWidget);
    expect(find.text('Bills & Utilities'), findsOneWidget);
    expect(find.text('Entertainment'), findsOneWidget);
    expect(find.text('Others'), findsOneWidget);
  });

  testWidgets(
      'Navbar sequence: Home -> Analyze -> Transactions -> Home returns directly to Home',
      (WidgetTester tester) async {
    await tester.pumpWidget(const HulyPayApp());

    // 1. Initially on Home
    expect(find.text('TOTAL SPENT'), findsOneWidget);

    // 2. Tap Analyze
    await tester.tap(find.text('Analyze'));
    await tester.pumpAndSettle();
    expect(find.byType(AnalysisScreen), findsOneWidget);
    expect(find.text('Spending Insights'), findsOneWidget);

    // 3. Tap Transactions
    await tester.tap(find.text('Transactions'));
    await tester.pumpAndSettle();
    expect(find.byType(TransactionsScreen), findsOneWidget);
    expect(find.text('Search transactions'), findsOneWidget);

    // 4. Tap Home - MUST return directly to Home, NOT Analyze!
    await tester.tap(find.text('Home'));
    await tester.pumpAndSettle();
    expect(find.text('TOTAL SPENT'), findsOneWidget);
    expect(find.byType(AnalysisScreen), findsNothing);
    expect(find.byType(TransactionsScreen), findsNothing);
  });

  testWidgets('Navigate to SettingsScreen, verify all sections and logout dialog',
      (WidgetTester tester) async {
    await tester.pumpWidget(const HulyPayApp());

    // 1. Tap More button to navigate to Settings
    await tester.tap(find.text('More'));
    await tester.pumpAndSettle();

    // 2. Verify SettingsScreen is loaded
    expect(find.byType(SettingsScreen), findsOneWidget);
    expect(find.text('Profile & Settings'), findsOneWidget);

    // 3. Verify user profile card
    expect(find.text('SS'), findsOneWidget);
    expect(find.text('Sujit Saha'), findsOneWidget);
    expect(find.text('sujit@example.com'), findsOneWidget);

    // 4. Verify Account section
    expect(find.text('Personal Information'), findsOneWidget);
    expect(find.text('Linked Accounts'), findsNothing);
    expect(find.text('Payment Methods'), findsOneWidget);

    // 5. Verify Preferences section
    expect(find.text('Expense Categories'), findsNothing);
    expect(find.text('Notifications'), findsOneWidget);
    expect(find.text('Themes & Skins'), findsOneWidget);
    expect(find.text('Dark Mode'), findsNothing);

    // Open Themes & Skins modal sheet
    await tester.tap(find.text('Themes & Skins'));
    await tester.pumpAndSettle();
    expect(find.text('Midnight Dark'), findsOneWidget);
    expect(find.text('Cyber Purple'), findsOneWidget);
    expect(find.text('Emerald Slate'), findsOneWidget);

    // Select Midnight Dark
    await tester.tap(find.text('Midnight Dark'));
    await tester.pumpAndSettle();
    expect(find.text('Midnight Dark'), findsOneWidget); // Trailing text updated

    // 6. Verify Support section
    expect(find.text('Privacy & Security'), findsOneWidget);
    expect(find.text('Help & Support'), findsOneWidget);
    expect(find.text('About Hulypay'), findsOneWidget);
    expect(find.text('v1.0.0'), findsOneWidget);

    // 7. Verify Logout button & dialog
    expect(find.text('Logout'), findsOneWidget);
    await tester.ensureVisible(find.text('Logout'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Logout'));
    await tester.pumpAndSettle();

    // Verify dialog content
    expect(find.text('Are you sure you want to log out of Huly Pay?'), findsOneWidget);
    expect(find.text('Cancel'), findsOneWidget);

    // Dismiss dialog
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    // 8. Tap back button to return to Home
    await tester.ensureVisible(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();

    expect(find.text('TOTAL SPENT'), findsOneWidget);
  });

  testWidgets('Tap profile button navigates directly to SettingsScreen',
      (WidgetTester tester) async {
    await tester.pumpWidget(const HulyPayApp());

    // 1. Verify profile button exists on Home
    final profileButtonFinder = find.byKey(const Key('profile_button'));
    expect(profileButtonFinder, findsOneWidget);

    // 2. Tap profile button
    await tester.tap(profileButtonFinder);
    await tester.pumpAndSettle();

    // 3. Verify SettingsScreen is loaded with Profile & Settings title
    expect(find.byType(SettingsScreen), findsOneWidget);
    expect(find.text('Profile & Settings'), findsOneWidget);
    expect(find.text('Sujit Saha'), findsOneWidget);
  });

  testWidgets(
      'Tap transaction in transaction history navigates to SingleTransactionScreen without circle profile',
      (WidgetTester tester) async {
    await tester.pumpWidget(const HulyPayApp());

    // 1. Navigate to Transactions tab
    await tester.tap(find.text('Transactions'));
    await tester.pumpAndSettle();
    expect(find.byType(TransactionsScreen), findsOneWidget);

    // 2. Tap Swiggy transaction
    expect(find.text('Swiggy'), findsOneWidget);
    await tester.tap(find.text('Swiggy'));
    await tester.pumpAndSettle();

    // 3. Verify SingleTransactionScreen is loaded
    expect(find.byType(SingleTransactionScreen), findsOneWidget);
    expect(find.text('Transaction Details'), findsOneWidget);
    expect(find.text('- ₹320'), findsOneWidget); // Hero amount only (breakdown removed)
    expect(find.text('Paid to Swiggy'), findsOneWidget);
    expect(find.text('Payment Successful'), findsOneWidget);
    expect(find.text('UPI Ref No.'), findsOneWidget);
    expect(find.text('TRANSACTION DETAILS'), findsOneWidget);
    expect(find.text('PAYMENT BREAKDOWN'), findsNothing); // Breakdown removed as requested
    expect(find.text('Payment Method'), findsOneWidget);
    expect(find.text('GPay'), findsOneWidget); // GPay or Amazon Pay only
    expect(find.text('Verified Shop'), findsNothing); // Verified Shop tag removed as requested
    expect(find.text('Pay Again'), findsOneWidget);

    // 4. Verify NO CircleAvatar is present
    expect(find.byType(CircleAvatar), findsNothing);

    // 5. Tap Back button and return to TransactionsScreen
    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();
    expect(find.byType(TransactionsScreen), findsOneWidget);
  });

  testWidgets(
      'SplashScreen displays logo, brand elements, and transitions unauthenticated user to SignInScreen',
      (WidgetTester tester) async {
    await AuthService().signOut();
    await tester.pumpWidget(const HulyPayApp(showSplash: true));

    // 1. Verify SplashScreen is loaded with Hulypay branding
    expect(find.byType(SplashScreen), findsOneWidget);
    expect(find.text('Hulypay'), findsOneWidget);
    expect(find.text('Track. Pay. Grow.'), findsOneWidget);

    // 2. Advance time past splash duration
    await tester.pump(const Duration(milliseconds: 1000));
    await tester.pump(const Duration(milliseconds: 1500));
    await tester.pumpAndSettle();

    // 3. Verify transition to SignInScreen when unauthenticated
    expect(find.byType(SignInScreen), findsOneWidget);
    expect(find.text('Welcome Back'), findsOneWidget);
  });

  testWidgets(
      'SplashScreen tap anywhere skips directly to SignInScreen when unauthenticated',
      (WidgetTester tester) async {
    await AuthService().signOut();
    await tester.pumpWidget(const HulyPayApp(showSplash: true));

    expect(find.byType(SplashScreen), findsOneWidget);
    expect(find.text('Hulypay'), findsOneWidget);
    expect(find.text('Track. Pay. Grow.'), findsOneWidget);

    // Tap splash screen to fast-track/skip without bypassing auth
    await tester.tap(find.byKey(const Key('splash_gesture_detector')));
    await tester.pumpAndSettle();

    expect(find.byType(SignInScreen), findsOneWidget);
    expect(find.text('Welcome Back'), findsOneWidget);
  });

  testWidgets(
      'SplashScreen with authenticated session transitions to HomeDashboardScreen',
      (WidgetTester tester) async {
    await AuthService().signInWithPassword(
      email: 'session-test@hulypay.com',
      password: 'pass',
    );
    await tester.pumpWidget(const HulyPayApp(showSplash: true));

    expect(find.byType(SplashScreen), findsOneWidget);

    // Advance time past splash duration
    await tester.pump(const Duration(milliseconds: 1000));
    await tester.pump(const Duration(milliseconds: 1500));
    await tester.pumpAndSettle();

    // Authenticated session navigates to HomeDashboardScreen
    expect(find.byType(HomeDashboardScreen), findsOneWidget);
    expect(find.text('TOTAL SPENT'), findsOneWidget);

    await AuthService().signOut();
  });

  testWidgets(
      'SignInScreen displays branding, OAuth buttons, and policy links',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: SignInScreen()));

    // Verify header and greeting
    expect(find.byKey(const Key('signin_back_button')), findsOneWidget);
    expect(find.text('Sign Up'), findsOneWidget);
    expect(find.text('Welcome Back'), findsOneWidget);
    expect(
        find.text('Enter your credentials to access your account.'), findsOneWidget);

    // Verify Google and GitHub buttons
    expect(find.text('Google'), findsOneWidget);
    expect(find.text('GitHub'), findsOneWidget);

    // Verify footer policy texts
    expect(find.text('Terms of Service'), findsOneWidget);
    expect(find.text('Privacy Policy.'), findsOneWidget);
  });

  testWidgets('SignInScreen Google and GitHub buttons trigger sign in',
      (WidgetTester tester) async {
    bool googleClicked = false;
    bool githubClicked = false;

    await tester.pumpWidget(
      MaterialApp(
        home: SignInScreen(
          onSignInSuccess: () => googleClicked = true,
        ),
      ),
    );

    // Tap Google button and verify callback after duration
    await tester.tap(find.byKey(const Key('google_signin_button')));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpAndSettle();
    expect(googleClicked, isTrue);

    // Now test GitHub button callback
    await tester.pumpWidget(
      MaterialApp(
        home: SignInScreen(
          onSignInSuccess: () => githubClicked = true,
        ),
      ),
    );

    await tester.tap(find.byKey(const Key('github_signin_button')));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpAndSettle();
    expect(githubClicked, isTrue);
  });

  testWidgets('SettingsScreen logout confirms and routes to SignInScreen',
      (WidgetTester tester) async {
    await tester.pumpWidget(const HulyPayApp());

    // 1. Navigate to Settings
    await tester.tap(find.byKey(const Key('profile_button')));
    await tester.pumpAndSettle();
    expect(find.byType(SettingsScreen), findsOneWidget);

    // 2. Tap Logout to show dialog
    await tester.ensureVisible(find.text('Logout'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Logout'));
    await tester.pumpAndSettle();

    // 3. Confirm Logout in dialog targeting the TextButton
    final dialogLogoutButton = find.widgetWithText(TextButton, 'Logout');
    await tester.tap(dialogLogoutButton);
    await tester.runAsync(() async {
      await Future.delayed(const Duration(milliseconds: 150));
    });
    await tester.pumpAndSettle();

    // 4. Verify user is now on SignInScreen
    expect(find.byType(SignInScreen), findsOneWidget);
    expect(find.text('Welcome Back'), findsOneWidget);
    expect(find.text('Google'), findsOneWidget);
  });

  testWidgets(
      'SignInScreen back button and policy dialog trigger correctly',
      (WidgetTester tester) async {
    bool backClicked = false;

    await tester.pumpWidget(
      MaterialApp(
        home: SignInScreen(
          onBackTap: () => backClicked = true,
        ),
      ),
    );

    // 1. Tap Back Button
    await tester.tap(find.byKey(const Key('signin_back_button')));
    await tester.pumpAndSettle();
    expect(backClicked, isTrue);

    // 2. Tap Terms of Service to open policy dialog
    await tester.tap(find.text('Terms of Service'));
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsOneWidget);
    expect(find.text('Close'), findsOneWidget);

    // 3. Dismiss dialog
    await tester.tap(find.text('Close'));
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsNothing);
  });
}
