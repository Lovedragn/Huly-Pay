import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/main.dart';
import 'package:mobile/models/dashboard_data.dart';
import 'package:mobile/models/user_profile.dart';
import 'package:mobile/repositories/user_repository.dart';
import 'package:mobile/screens/analysis_screen.dart';
import 'package:mobile/screens/home_dashboard_screen.dart';
import 'package:mobile/screens/scan_and_pay_screen.dart';
import 'package:mobile/screens/settings_screen.dart';
import 'package:mobile/screens/sign_in_screen.dart';
import 'package:mobile/screens/single_transaction_screen.dart';
import 'package:mobile/screens/splash_screen.dart';
import 'package:mobile/screens/transactions_screen.dart';
import 'package:mobile/services/local_database_service.dart';
import 'package:mobile/widgets/action_button.dart';
import 'package:mobile/widgets/custom_bottom_nav_bar.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const emptyDashboard = DashboardData(
    greeting: 'Good Morning,',
    userName: 'User',
    avatarUrl: '',
    totalSpentFormatted: '₹0',
    changePercent: 0,
    changePeriodLabel: 'this month',
    weeklySpending: [],
    recentTransactions: [],
  );

  testWidgets('HomeDashboardScreen and CustomBottomNavBar smoke test',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: HomeDashboardScreen(initialData: emptyDashboard),
    ));

    // Verify key elements from the dashboard are present.
    expect(find.text('TOTAL SPENT'), findsOneWidget);
    expect(find.text('₹0'), findsOneWidget);

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
    await tester.pumpWidget(const HulyPayApp(
      home: HomeDashboardScreen(initialData: emptyDashboard),
    ));

    // Tap center Scan action in QuickActionButton
    await tester.tap(find.text('Scan'));
    await tester.pumpAndSettle();

    // Verify ScanAndPayScreen is loaded
    expect(find.byType(ScanAndPayScreen), findsOneWidget);
    expect(find.text('Scan any UPI QR code'), findsOneWidget);

    // Tap Back to Home
    await tester.tap(find.text('Back to Home'));
    await tester.pumpAndSettle();

    // Verify returned to Home
    expect(find.text('TOTAL SPENT'), findsOneWidget);
  });

  testWidgets('Navigate to TransactionsScreen smoke test',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: TransactionsScreen(initialGroups: []),
    ));

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

    // Verify clean empty state for real data without mock transactions
    expect(find.text('No transactions found'), findsOneWidget);
    expect(find.text('Transactions will appear here once you make payments.'), findsOneWidget);
  });

  testWidgets('Navigate to AnalysisScreen smoke test',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: AnalysisScreen(
        initialCategories: [],
        totalSpent: '₹0',
      ),
    ));
    await tester.pumpAndSettle();

    // Verify AnalysisScreen is loaded
    expect(find.byType(AnalysisScreen), findsOneWidget);
    expect(find.text('Spending Insights'), findsOneWidget);
    expect(find.text('This Month'), findsOneWidget);

    // Verify clean empty zero-state for real data
    expect(find.byType(PieChart), findsOneWidget);
    expect(find.text('No spending data yet'), findsOneWidget);
    expect(find.text('₹0'), findsOneWidget);
  });

  testWidgets(
      'Navbar sequence: Home -> Analyze -> Transactions -> Home returns directly to Home',
      (WidgetTester tester) async {
    await tester.pumpWidget(const HulyPayApp(
      home: HomeDashboardScreen(initialData: emptyDashboard),
    ));

    // 1. Initially on Home
    expect(find.text('TOTAL SPENT'), findsOneWidget);

    // 2. Tap Analyze
    await tester.tap(find.text('Analyze'));
    await tester.runAsync(() async => await Future.delayed(const Duration(milliseconds: 100)));
    await tester.pumpAndSettle();
    expect(find.byType(AnalysisScreen), findsOneWidget);

    // 3. Tap Transactions
    await tester.tap(find.text('Transactions'));
    await tester.runAsync(() async => await Future.delayed(const Duration(milliseconds: 100)));
    await tester.pumpAndSettle();
    expect(find.byType(TransactionsScreen), findsOneWidget);

    // 4. Tap Home - returns directly to Home
    await tester.tap(find.text('Home'));
    await tester.runAsync(() async => await Future.delayed(const Duration(milliseconds: 250)));
    await tester.pumpAndSettle();
    expect(find.text('TOTAL SPENT'), findsOneWidget);
  });

  testWidgets('Navigate to SettingsScreen, verify all sections and logout dialog',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: SettingsScreen(
        userName: 'User',
        userEmail: 'user@hulypay.com',
      ),
    ));
    await tester.runAsync(() async => await Future.delayed(const Duration(milliseconds: 100)));
    await tester.pumpAndSettle();

    // 1. Verify SettingsScreen is loaded
    expect(find.byType(SettingsScreen), findsOneWidget);
    expect(find.text('Profile & Settings'), findsOneWidget);

    // 2. Verify user profile card default state
    expect(find.text('US'), findsOneWidget);
    expect(find.text('User'), findsOneWidget);

    // 3. Verify Account section
    expect(find.text('Personal Information'), findsOneWidget);
    expect(find.text('Linked Accounts'), findsNothing);
    expect(find.text('Payment Methods'), findsOneWidget);

    // 4. Verify Preferences section
    expect(find.text('Expense Categories'), findsNothing);
    expect(find.text('Notifications'), findsOneWidget);
    expect(find.text('Customization'), findsOneWidget);
    expect(find.text('Themes & Skins'), findsNothing);
    expect(find.text('Dark Mode'), findsNothing);

    // Open Customization modal sheet
    await tester.tap(find.text('Customization'));
    await tester.pumpAndSettle();
    expect(find.text('Midnight Dark'), findsOneWidget);
    expect(find.text('Cyber Purple'), findsOneWidget);

    // Select Midnight Dark
    await tester.tap(find.text('Midnight Dark'));
    await tester.runAsync(() async => await Future.delayed(const Duration(milliseconds: 100)));
    await tester.pumpAndSettle();

    // Dismiss modal sheet via close icon
    await tester.tap(find.byIcon(Icons.close_rounded));
    await tester.pumpAndSettle();

    // 5. Verify Support & About section
    expect(find.text('Privacy & Security'), findsOneWidget);
    expect(find.text('Help & Support'), findsOneWidget);
    expect(find.text('About Hulypay'), findsOneWidget);
    expect(find.text('v1.0.0'), findsOneWidget);

    // 6. Verify Logout button & dialog
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
  });

  testWidgets('Tap profile button navigates directly to SettingsScreen',
      (WidgetTester tester) async {
    await tester.pumpWidget(const HulyPayApp(
      home: HomeDashboardScreen(initialData: emptyDashboard),
    ));

    // 1. Verify profile button exists on Home
    final profileButtonFinder = find.byKey(const Key('profile_button'));
    expect(profileButtonFinder, findsOneWidget);

    // 2. Tap profile button
    await tester.tap(profileButtonFinder);
    await tester.runAsync(() async => await Future.delayed(const Duration(milliseconds: 100)));
    await tester.pumpAndSettle();

    // 3. Verify SettingsScreen is loaded with Profile & Settings title
    expect(find.byType(SettingsScreen), findsOneWidget);
    expect(find.text('Profile & Settings'), findsOneWidget);
    expect(find.text('User'), findsOneWidget);
  });

  testWidgets(
      'Tap transaction in transaction history navigates to SingleTransactionScreen without circle profile',
      (WidgetTester tester) async {
    const sampleTx = TransactionItem(
      id: 'tx_sample_1',
      title: 'Cafe Coffee Day',
      category: 'Food & Dining',
      amount: '- ₹320',
      time: '10:24 AM',
      icon: Icons.restaurant_rounded,
      iconColor: Color(0xFFFF375F),
      iconBgColor: Color(0xFF2E1519),
      isIncome: false,
      type: 'Expense',
    );

    await tester.pumpWidget(
      const MaterialApp(
        home: TransactionsScreen(
          initialGroups: [
            TransactionGroup(
              title: 'TODAY',
              transactions: [sampleTx],
            ),
          ],
        ),
      ),
    );

    // 1. Verify Cafe Coffee Day transaction exists
    expect(find.text('Cafe Coffee Day'), findsOneWidget);
    await tester.tap(find.text('Cafe Coffee Day'));
    await tester.pumpAndSettle();

    // 2. Verify SingleTransactionScreen is loaded and title is removed per requirement
    expect(find.byType(SingleTransactionScreen), findsOneWidget);
    expect(find.text('Transaction Details'), findsNothing);
    expect(find.text('- ₹320'), findsOneWidget);
    expect(find.text('Paid to Cafe Coffee Day'), findsOneWidget);
    expect(find.text('Payment Successful'), findsOneWidget);
    expect(find.text('UPI Ref No.'), findsOneWidget);
    expect(find.text('TRANSACTION DETAILS'), findsOneWidget);
    expect(find.text('PAYMENT BREAKDOWN'), findsNothing);
    expect(find.text('Payment Method'), findsOneWidget);
    expect(find.text('Pay Again'), findsOneWidget);

    // 3. Verify NO CircleAvatar is present
    expect(find.byType(CircleAvatar), findsNothing);

    // 4. Tap Back button and return to TransactionsScreen
    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();
    expect(find.byType(TransactionsScreen), findsOneWidget);
  });

  testWidgets(
      'SplashScreen displays logo, brand elements, and transitions unauthenticated user to SignInScreen',
      (WidgetTester tester) async {
    await tester.pumpWidget(const HulyPayApp(showSplash: true, initializeAuth: false));

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
    expect(find.text('Experience HulyPay'), findsOneWidget);
  });

  testWidgets(
      'SplashScreen tap anywhere skips directly to SignInScreen when unauthenticated',
      (WidgetTester tester) async {
    await tester.pumpWidget(const HulyPayApp(showSplash: true, initializeAuth: false));

    expect(find.byType(SplashScreen), findsOneWidget);
    expect(find.text('Hulypay'), findsOneWidget);
    expect(find.text('Track. Pay. Grow.'), findsOneWidget);

    // Tap splash screen to fast-track/skip without bypassing auth
    await tester.tap(find.byKey(const Key('splash_gesture_detector')));
    await tester.pumpAndSettle();

    expect(find.byType(SignInScreen), findsOneWidget);
    expect(find.text('Experience HulyPay'), findsOneWidget);
  });

  testWidgets(
      'SplashScreen with authenticated local profile transitions to HomeDashboardScreen',
      (WidgetTester tester) async {
    await tester.runAsync(() async {
      await LocalDatabaseService().initDatabase(inMemory: true);
      final user = UserProfile(
        id: 'usr_auth_test',
        email: 'user@hulypay.com',
        fullName: 'Test User',
        authProvider: 'google',
        active: true,
      );
      await UserRepository().saveUserProfile(user);
    });

    await tester.pumpWidget(const HulyPayApp(
      showSplash: true,
      initializeAuth: false,
      isAuthenticated: true,
      nextScreen: HomeDashboardScreen(initialData: emptyDashboard),
    ));

    expect(find.byType(SplashScreen), findsOneWidget);

    // Advance time past splash duration and route transition
    await tester.pump(const Duration(milliseconds: 1000));
    await tester.pump(const Duration(milliseconds: 1500));
    await tester.pump(const Duration(milliseconds: 500));

    // Authenticated session navigates to HomeDashboardScreen
    expect(find.byType(HomeDashboardScreen), findsOneWidget);

    await tester.pumpWidget(const SizedBox());

    await tester.runAsync(() async {
      await LocalDatabaseService().clearAll();
      await LocalDatabaseService().close();
    });
  });

  testWidgets(
      'SignInScreen displays branding, OAuth buttons, and policy links',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: SignInScreen()));

    // Verify header and greeting
    expect(find.byKey(const Key('signin_back_button')), findsNothing);
    expect(find.text('Sign Up'), findsNothing);
    expect(find.text('Experience HulyPay'), findsOneWidget);
    expect(find.text('Track. Pay. Grow.'), findsOneWidget);

    // Verify Google and GitHub buttons
    expect(find.text('Google'), findsOneWidget);
    expect(find.text('GitHub'), findsOneWidget);

    // Verify footer policy texts
    expect(find.text('Terms of Service'), findsOneWidget);
    expect(find.text('Privacy Policy.'), findsOneWidget);
  });

  testWidgets('SignInScreen Google and GitHub buttons render and respond to tap',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: SignInScreen(),
      ),
    );

    // Verify Google button exists
    final googleBtn = find.byKey(const Key('google_signin_button'));
    expect(googleBtn, findsOneWidget);
    await tester.tap(googleBtn);
    await tester.pump(const Duration(milliseconds: 100));

    // Reset processing state via cancel button if present so second tap works cleanly
    final cancelBtn = find.byKey(const Key('auth_processing_button'));
    if (cancelBtn.evaluate().isNotEmpty) {
      await tester.tap(cancelBtn);
      await tester.pump(const Duration(milliseconds: 100));
    }

    // Verify GitHub button exists
    final githubBtn = find.byKey(const Key('github_signin_button'));
    expect(githubBtn, findsOneWidget);
    await tester.tap(githubBtn);
    await tester.pump(const Duration(milliseconds: 100));

    // Clean up any pending snackbar timers
    await tester.pump(const Duration(seconds: 5));
  });

  testWidgets('SettingsScreen logout dialog displays confirmation and cancel actions',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: SettingsScreen(
          userName: 'Test User',
          userEmail: 'test@example.com',
        ),
      ),
    );

    // 1. Verify SettingsScreen is loaded
    expect(find.byType(SettingsScreen), findsOneWidget);

    // 2. Tap Logout to show dialog
    await tester.ensureVisible(find.text('Logout'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Logout'));
    await tester.pumpAndSettle();

    // 3. Verify dialog content
    expect(find.text('Are you sure you want to log out of Huly Pay?'), findsOneWidget);
    expect(find.text('Cancel'), findsOneWidget);
    expect(find.widgetWithText(TextButton, 'Logout'), findsOneWidget);

    // 4. Tap Cancel to dismiss
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(find.text('Are you sure you want to log out of Huly Pay?'), findsNothing);
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

    // Verify back button is removed
    expect(find.byKey(const Key('signin_back_button')), findsNothing);

    // Tap Terms of Service link
    await tester.tap(find.text('Terms of Service'));
    await tester.pumpAndSettle();
    expect(
      find.text('By accessing or using Huly Pay, you agree to comply with our user agreement and transaction terms.'),
      findsOneWidget,
    );

    // Dismiss policy dialog
    await tester.tap(find.text('Close'));
    await tester.pumpAndSettle();
    expect(
      find.text('By accessing or using Huly Pay, you agree to comply with our user agreement and transaction terms.'),
      findsNothing,
    );
  });
}
