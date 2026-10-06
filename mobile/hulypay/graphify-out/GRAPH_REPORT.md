# Graph Report - hulypay  (2026-10-06)

## Corpus Check
- 80 files · ~167,339 words
- Verdict: corpus is large enough that graph structure adds value.

## Summary
- 1577 nodes · 2047 edges · 76 communities (65 shown, 7 thin omitted)
- Extraction: 100% EXTRACTED · 0% INFERRED · 0% AMBIGUOUS
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `cbc1f705`
- Run `git rev-parse HEAD` and compare to check if the graph is stale.
- Run `graphify update .` after code changes (no API cost).

## Community Hubs (Navigation)
- upload_qr_screen.dart
- app_theme.dart
- single_transaction_screen.dart
- ../data/external_data.dart
- AppDelegate
- upi_service.dart
- scan_and_pay_screen.dart
- home_spend_trend_line_chart.dart
- local_database_service.dart
- upi_payment_service.dart
- google_pay_service.dart
- home_weekly_bar_chart.dart
- home_dashboard_screen.dart
- user_profile.dart
- api_client.dart
- dashboard_data.dart
- settings_screen.dart
- MainActivity
- external_data.dart
- user_preferences_service.dart
- transaction_model.dart
- analysis_screen.dart
- spending_heatmap.dart
- transactions_screen.dart
- auth_service.dart
- card_dialog.dart
- user_repository.dart
- sign_in_screen.dart
- location_service.dart
- home_today_spend_gauge.dart
- scan_payment_service.dart
- main.dart
- transaction_detail_components.dart
- sms_verification_dialog.dart
- about_hulypay_screen.dart
- scan_amount_screen.dart
- transaction_repository.dart
- hulypay/MainActivity.kt
- MaterialPageRoute
- transaction_map_section.dart
- custom_bottom_nav_bar.dart
- StatelessWidget
- CustomPainter
- payment_details_page.dart
- splash_screen.dart
- ../models/transaction_model.dart
- payment_methods_screen.dart
- 💳 Huly Pay Mobile Application
- qr_share_service.dart
- String?
- State
- app_update_service.dart
- qr_service.dart
- AppThemeContextExtension
- edit_amount_sheet.dart
- LaunchImage.imageset/README.md
- analysis_category_pie_chart.dart
- AppThemeData
- bool?
- transaction_details_card.dart
- package:flutter/material.dart
- ../theme/app_theme.dart
- payment_dialogs.dart
- transaction_pdf_service.dart
- customization_bottom_sheet.dart
- app_back_button.dart
- scanner_circle_button.dart
- Color
- transaction_receipt_card.dart
- sms_filter_service.dart
- ApiException
- SingleTransactionScreen

## God Nodes (most connected - your core abstractions)
1. `MainActivity` - 16 edges
2. `PaymentModel` - 7 edges
3. `💳 Huly Pay Mobile Application` - 7 edges
4. `BroadcastReceiver` - 6 edges
5. `AppDelegate` - 5 edges
6. `_HomeDashboardScreenState` - 5 edges
7. `_SignInScreenState` - 4 edges
8. `_SplashScreenState` - 4 edges
9. `AppThemeData` - 4 edges
10. `_CardNotificationOverlayState` - 4 edges

## Surprising Connections (you probably didn't know these)
- `HulyPayApp` --inherits--> `StatelessWidget`  [EXTRACTED]
  lib/main.dart → None  _Bridges community 31 → community 41_
- `AboutHulyPayScreen` --inherits--> `StatelessWidget`  [EXTRACTED]
  lib/screens/about_hulypay_screen.dart → None  _Bridges community 41 → community 34_
- `NotificationsScreen` --inherits--> `StatelessWidget`  [EXTRACTED]
  lib/screens/notifications_screen.dart → None  _Bridges community 41 → community 3_
- `QuickActionButton` --inherits--> `StatelessWidget`  [EXTRACTED]
  lib/widgets/action_button.dart → None  _Bridges community 41 → community 49_
- `AppBackButton` --inherits--> `StatelessWidget`  [EXTRACTED]
  lib/widgets/app_back_button.dart → None  _Bridges community 41 → community 69_

## Import Cycles
- None detected.

## Communities (76 total, 7 thin omitted)

### Community 0 - "upload_qr_screen.dart"
Cohesion: 0.08
Nodes (24): _amountController, _amountFocusNode, build, createState, dispose, _handlePayButton, initialAmount, initState (+16 more)

### Community 1 - "app_theme.dart"
Cohesion: 0.02
Nodes (96): AppThemeData get, Brightness, Color get, ColorScheme get, accent, allPalettes, amber, AppChartColors (+88 more)

### Community 2 - "single_transaction_screen.dart"
Cohesion: 0.04
Nodes (47): DraggableScrollableNotification, GoogleMapController?, _accuracy, build, _buildQuickActionButtons, _buildSectionHeader, _copyToClipboard, createState (+39 more)

### Community 3 - "../data/external_data.dart"
Cohesion: 0.18
Nodes (10): ../data/external_data.dart, build, _buildAppBar, _buildCurrentlyInDevelopmentCard, NotificationsScreen, build, _buildAppBar, _buildSectionHeader (+2 more)

### Community 4 - "AppDelegate"
Cohesion: 0.11
Nodes (14): Any, Flutter, FlutterAppDelegate, FlutterImplicitEngineBridge, FlutterImplicitEngineDelegate, FlutterSceneDelegate, AppDelegate, Bool (+6 more)

### Community 5 - "upi_service.dart"
Cohesion: 0.11
Nodes (17): amazonPayPackageName, amount, buildPaymentUri, currency, googlePayPackageName, isUpiUri, launchUpiPayment, merchantCode (+9 more)

### Community 6 - "scan_and_pay_screen.dart"
Cohesion: 0.04
Nodes (48): DateTime?, amount, build, buttonBg, buttonBorder, buttonIcon, createState, dispose (+40 more)

### Community 7 - "home_spend_trend_line_chart.dart"
Cohesion: 0.09
Nodes (23): amount, _bottomTitleWidgets, build, _buildCardFooter, _buildCardHeader, _buildCurvedGradientData, _buildDualZoneData, _calculateMaxY (+15 more)

### Community 8 - "local_database_service.dart"
Cohesion: 0.05
Nodes (39): Database?, cleanupStalePayments, clearAll, clearPayments, clearUserProfile, close, _db, dbName (+31 more)

### Community 9 - "upi_payment_service.dart"
Cohesion: 0.05
Nodes (38): allApps, amazon, amazonPay, appNotInstalled, askEveryTime, bhim, bhimApp, buildSafeUpiUri (+30 more)

### Community 10 - "google_pay_service.dart"
Cohesion: 0.05
Nodes (43): dart:convert, amazonPayPackage, amount, approvalRefNo, _channel, errorMessage, fromNativeMap, fromQueryString (+35 more)

### Community 11 - "home_weekly_bar_chart.dart"
Cohesion: 0.12
Nodes (17): build, _buildBarChartData, _buildLegendItem, _calculateMax, _computeWeeklyData, createState, _defaultBarColor, _getBottomTitles (+9 more)

### Community 12 - "home_dashboard_screen.dart"
Cohesion: 0.05
Nodes (36): Animation, _applyData, build, _buildAvatarFallback, _buildBody, _buildDashboardContent, _buildQuickActions, _buildTotalSpentCard (+28 more)

### Community 13 - "user_profile.dart"
Cohesion: 0.14
Nodes (13): active, authProvider, avatarUrl, copyWith, email, firstName, fromJson, fullName (+5 more)

### Community 14 - "api_client.dart"
Cohesion: 0.08
Nodes (25): auth_service.dart, Dio, int?, checkAppVersion, createPayment, data, defaultAndroidHost, dio (+17 more)

### Community 15 - "dashboard_data.dart"
Cohesion: 0.06
Nodes (30): amount, avatarUrl, category, CategorySpendingItem, changePercent, changePeriodLabel, color, DashboardData (+22 more)

### Community 16 - "settings_screen.dart"
Cohesion: 0.06
Nodes (33): about_hulypay_screen.dart, help_support_screen.dart, appVersion, _avatarUrl, build, _buildAppInfoFooter, _buildGroupCard, _buildLogoutCard (+25 more)

### Community 17 - "MainActivity"
Cohesion: 0.19
Nodes (9): FlutterActivity, MainActivity, BroadcastReceiver, Context, FlutterEngine, IntArray, Intent, MethodChannel (+1 more)

### Community 18 - "external_data.dart"
Cohesion: 0.02
Nodes (113): Acceptance of, Account, Changes to, Contact Regarding, Disclaimer of, Information We, aboutEnvironmentNoticeBody, aboutEnvironmentNoticeTitle (+105 more)

### Community 19 - "user_preferences_service.dart"
Cohesion: 0.04
Nodes (45): double? get, build, _buildAppBar, _buildContactCard, _buildFaqItem, _buildFaqSection, _copyToClipboard, createState (+37 more)

### Community 20 - "transaction_model.dart"
Cohesion: 0.06
Nodes (35): dashboard_data.dart, amount, category, copyWith, createdAt, CreatePaymentPayload, CreateTransactionPayload, currency (+27 more)

### Community 21 - "analysis_screen.dart"
Cohesion: 0.05
Nodes (37): _allPayments, AnalysisScreen, _AnalysisScreenState, build, _buildCategoryList, _buildClassificationToggleButton, _buildHeader, _categories (+29 more)

### Community 22 - "spending_heatmap.dart"
Cohesion: 0.07
Nodes (27): build, _buildFooter, _buildGrid, _buildHeader, cells, columns, _computePeriodTotal, createState (+19 more)

### Community 23 - "transactions_screen.dart"
Cohesion: 0.09
Nodes (22): analysis_screen.dart, _allGroups, build, _buildFilterChips, _buildSearchBar, createState, dispose, _filterActivePayments (+14 more)

### Community 24 - "auth_service.dart"
Cohesion: 0.07
Nodes (26): AuthService, client, currentAccessToken, currentSession, currentUser, hasValidActiveToken, initialize, _initialized (+18 more)

### Community 25 - "card_dialog.dart"
Cohesion: 0.04
Nodes (46): Color? barrierColor,
  String, EdgeInsets, EdgeInsetsGeometry, accentColor, actions, _animController, backgroundColor, barrierDismissible (+38 more)

### Community 26 - "user_repository.dart"
Cohesion: 0.13
Nodes (14): _apiClient, getCachedUserProfile, getUserProfile, _instance, _localDb, saveUserProfile, UserRepository, ApiClient (+6 more)

### Community 27 - "sign_in_screen.dart"
Cohesion: 0.10
Nodes (20): home_dashboard_screen.dart, _authSubscription, _authTimeoutTimer, build, createState, didChangeAppLifecycleState, dispose, _finishSignIn (+12 more)

### Community 28 - "location_service.dart"
Cohesion: 0.09
Nodes (22): bool get, accuracyMeters, errorMessage, failure, failureReason, getCurrentPaymentLocation, getPaymentLocationWithStatus, _instance (+14 more)

### Community 29 - "home_today_spend_gauge.dart"
Cohesion: 0.10
Nodes (20): dart:math, activeColor, build, _buildZoneIndicator, _computeTodaySpend, createState, _customLimit, dailyBudget (+12 more)

### Community 30 - "scan_payment_service.dart"
Cohesion: 0.06
Nodes (32): google_pay_service.dart, app, appName, checkPreferredAppReadiness, createPendingPayment, ensureSmsPermission, generateAmountQr, initialStatus (+24 more)

### Community 31 - "main.dart"
Cohesion: 0.15
Nodes (12): build, home, HulyPayApp, initializeAuth, isAuthenticated, main, nextScreen, showSplash (+4 more)

### Community 32 - "transaction_detail_components.dart"
Cohesion: 0.12
Nodes (15): backgroundColor, borderColor, build, canCopy, customIcon, icon, iconColor, isPrimary (+7 more)

### Community 33 - "sms_verification_dialog.dart"
Cohesion: 0.07
Nodes (30): _badgeText, _bodyText, build, _cancel, _close, createState, dispose, icon (+22 more)

### Community 34 - "about_hulypay_screen.dart"
Cohesion: 0.18
Nodes (10): AboutHulyPayScreen, appVersion, build, _buildAppBar, _buildCreatorSection, _buildHeroBrandCard, _buildSpecRow, _buildSpecsCard (+2 more)

### Community 35 - "scan_amount_screen.dart"
Cohesion: 0.13
Nodes (15): FocusNode, _amountController, _amountFocusNode, build, createState, dispose, _handleScanButton, initialAmount (+7 more)

### Community 36 - "transaction_repository.dart"
Cohesion: 0.08
Nodes (26): _apiClient, cleanupStalePayments, cleanupStaleTransactions, createPayment, createTransaction, deletePayment, deleteTransaction, getCachedPayments (+18 more)

### Community 38 - "MaterialPageRoute"
Cohesion: 0.20
Nodes (10): _buildHeader, _openUploadQr, _openUploadFromScanner, _startSmsVerificationWorkflow, _buildAccountSection, _buildNotificationsSection, _buildSupportSection, _buildGroupedTransactions (+2 more)

### Community 39 - "transaction_map_section.dart"
Cohesion: 0.08
Nodes (26): accuracy, build, _buildGoogleMapContent, _buildMapFallbackCanvas, _buildStreetViewContent, _buildTab, createState, gridColor (+18 more)

### Community 40 - "custom_bottom_nav_bar.dart"
Cohesion: 0.14
Nodes (12): activeCategory, build, CategoryPickerSheet, onSelectCategory, show, build, _buildNavItem, CustomBottomNavBar (+4 more)

### Community 41 - "StatelessWidget"
Cohesion: 0.20
Nodes (10): _AmountBadge, CardDialog, CardDialogTitleIcon, _HeatmapGridWidget, TransactionActionButton, TransactionDetailRow, TransactionDetailsCard, TransactionMapControlBar (+2 more)

### Community 42 - "CustomPainter"
Cohesion: 0.50
Nodes (4): CustomPainter, _SpeedometerGaugePainter, ScannerOverlayPainter, MapGridPainter

### Community 43 - "payment_details_page.dart"
Cohesion: 0.08
Nodes (25): amount, _amountController, build, _buildAmountBox, _buildAppBar, _buildAvatar, _buildNoteField, _buildPayButton (+17 more)

### Community 44 - "splash_screen.dart"
Cohesion: 0.10
Nodes (20): AnimationController, Duration, build, _controller, createState, dispose, duration, _hasLocalUser (+12 more)

### Community 45 - "../models/transaction_model.dart"
Cohesion: 0.22
Nodes (8): TransactionItem, build, onTap, payment, transaction, ../models/dashboard_data.dart, ../models/transaction_model.dart, ../screens/single_transaction_screen.dart

### Community 46 - "payment_methods_screen.dart"
Cohesion: 0.12
Nodes (15): build, _buildAppBar, _buildInstalledAppsList, _buildPaymentAppCard, _buildSectionTitle, createState, initState, _installedStatus (+7 more)

### Community 47 - "💳 Huly Pay Mobile Application"
Cohesion: 0.18
Nodes (10): Build optimized release APK:, ⚙️ Configuration & Environment, 📦 Core Dependencies & Tech Stack, 💳 Huly Pay Mobile Application, 🌟 Key Features, Output:, 📁 Project Architecture & Directory Layout, Run locally on an Android device or emulator: (+2 more)

### Community 48 - "qr_share_service.dart"
Cohesion: 0.15
Nodes (12): _channel, googlePayPackage, pickAndShareQrImage, pickQrImage, QrShareService, shareQrImage, _showSnackBar, _supportedImageExtensions (+4 more)

### Community 49 - "String?"
Cohesion: 0.22
Nodes (8): IconData?, build, icon, label, onTap, QuickActionButton, svgAsset, String?

### Community 50 - "State"
Cohesion: 0.17
Nodes (17): HomeDashboardScreen, _HomeDashboardScreenState, PaymentMethodsScreen, _PaymentMethodsScreenState, SignInScreen, _SignInScreenState, SplashScreen, _SplashScreenState (+9 more)

### Community 51 - "app_update_service.dart"
Cohesion: 0.10
Nodes (20): api_client.dart, AppUpdateService, checkAppVersion, currentVersion, dismissBanner, downloadUrl, forceUpdate, fromJson (+12 more)

### Community 52 - "qr_service.dart"
Cohesion: 0.11
Nodes (17): dart:async, dart:ui, _cacheKey, clearCache, _debounceTimer, _fileCache, _generateInternal, getOrGenerateQrFile (+9 more)

### Community 54 - "edit_amount_sheet.dart"
Cohesion: 0.12
Nodes (16): _addAmount, build, _buildQuickChip, _controller, createState, currentAmount, dispose, EditAmountSheet (+8 more)

### Community 56 - "analysis_category_pie_chart.dart"
Cohesion: 0.14
Nodes (14): AnalysisCategoryPieChart, _AnalysisCategoryPieChartState, bottomRightAction, build, centerLabel, createState, items, showCardBackground (+6 more)

### Community 63 - "transaction_details_card.dart"
Cohesion: 0.14
Nodes (13): double?, accuracy, build, category, latitude, longitude, onCategoryTap, paymentMethod (+5 more)

### Community 64 - "package:flutter/material.dart"
Cohesion: 0.15
Nodes (11): package:flutter/material.dart, package:flutter_test/flutter_test.dart, package:hulypay/services/app_update_service.dart, package:hulypay/services/qr_service.dart, package:hulypay/theme/app_theme.dart, package:hulypay/widgets/app_update_banner.dart, package:hulypay/widgets/app_update_dialog.dart, package:hulypay/widgets/card_dialog.dart (+3 more)

### Community 65 - "../theme/app_theme.dart"
Cohesion: 0.18
Nodes (11): card_dialog.dart, AppUpdateInfo, AppUpdateBanner, build, updateInfo, AppUpdateDialog, build, show (+3 more)

### Community 66 - "payment_dialogs.dart"
Cohesion: 0.15
Nodes (12): build, colors, false, filledDialogButton, MissingAppAction, payment, PaymentSummaryLines, result (+4 more)

### Community 67 - "transaction_pdf_service.dart"
Cohesion: 0.18
Nodes (10): dart:io, _buildDetailRow, _buildDivider, _formatProvider, generateReceipt, TransactionPdfService, package:flutter/services.dart, package:path_provider/path_provider.dart (+2 more)

### Community 68 - "customization_bottom_sheet.dart"
Cohesion: 0.25
Nodes (8): build, _buildThemeOptionCard, createState, CustomizationBottomSheet, _CustomizationBottomSheetState, onThemeChanged, show, ../services/user_preferences_service.dart

### Community 69 - "app_back_button.dart"
Cohesion: 0.20
Nodes (9): AppBackButton, backgroundColor, borderColor, build, iconColor, iconSize, onPressed, tooltip (+1 more)

### Community 70 - "scanner_circle_button.dart"
Cohesion: 0.22
Nodes (8): background, borderColor, build, child, onTap, ScannerCircleButton, tooltip, Widget?

### Community 71 - "Color"
Cohesion: 0.25
Nodes (7): Color, cornerRadius, cutoutRect, overlayColor, paint, shouldRepaint, Rect

### Community 72 - "transaction_receipt_card.dart"
Cohesion: 0.25
Nodes (7): build, displayAmount, isIncome, merchantTitle, status, time, TransactionReceiptCard

### Community 73 - "sms_filter_service.dart"
Cohesion: 0.40
Nodes (4): financialKeywords, isFinancialTransactionSms, SmsFilterService, static const List

## Knowledge Gaps
- **1151 isolated node(s):** `XCTest`, `FeatureHighlightItem`, `TechSpecItem`, `ScopeBulletItem`, `SecurityProtocolItem` (+1146 more)
  These have ≤1 connection - possible missing edges or undocumented components. (Counts symbols only; 1288 node(s) total have ≤1 connection when file, concept and rationale nodes are included.)
- **7 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `ApiException` connect `ApiException` to `api_client.dart`?**
  _High betweenness centrality (0.010) - this node is a cross-community bridge._
- **Why does `MapGridPainter` connect `CustomPainter` to `transaction_map_section.dart`?**
  _High betweenness centrality (0.005) - this node is a cross-community bridge._
- **Why does `_SpeedometerGaugePainter` connect `CustomPainter` to `home_today_spend_gauge.dart`?**
  _High betweenness centrality (0.004) - this node is a cross-community bridge._
- **What connects `XCTest`, `FeatureHighlightItem`, `TechSpecItem` to the rest of the system?**
  _1151 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `upload_qr_screen.dart` be split into smaller, more focused modules?**
  _Cohesion score 0.08333333333333333 - nodes in this community are weakly interconnected._
- **Should `app_theme.dart` be split into smaller, more focused modules?**
  _Cohesion score 0.020618556701030927 - nodes in this community are weakly interconnected._
- **Should `single_transaction_screen.dart` be split into smaller, more focused modules?**
  _Cohesion score 0.041666666666666664 - nodes in this community are weakly interconnected._