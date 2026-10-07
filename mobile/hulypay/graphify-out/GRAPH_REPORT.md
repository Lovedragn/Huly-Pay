# Graph Report - hulypay  (2026-10-07)

## Corpus Check
- 82 files · ~67,603 words
- Verdict: corpus is large enough that graph structure adds value.

## Summary
- 1603 nodes · 2080 edges · 74 communities (62 shown, 8 thin omitted)
- Extraction: 100% EXTRACTED · 0% INFERRED · 0% AMBIGUOUS
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `1d0b33cb`
- Run `git rev-parse HEAD` and compare to check if the graph is stale.
- Run `graphify update .` after code changes (no API cost).

## Community Hubs (Navigation)
- upload_qr_screen.dart
- app_theme.dart
- single_transaction_screen.dart
- ../Data/external_data.dart
- AppDelegate
- payment_details_page.dart
- scan_and_pay_screen.dart
- spend_trend_line_chart.dart
- local_database_service.dart
- upi_payment_service.dart
- google_pay_service.dart
- weekly_bar_chart.dart
- home_dashboard_screen.dart
- round_button.dart
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
- today_spend_gauge.dart
- scan_payment_service.dart
- main.dart
- upi_service.dart
- sms_verification_dialog.dart
- help_support_screen.dart
- edit_amount_sheet.dart
- transaction_repository.dart
- hulypay/MainActivity.kt
- MaterialPageRoute
- transaction_map_section.dart
- Theme/app_theme.dart
- StatelessWidget
- scan_amount_screen.dart
- transaction_detail_components.dart
- splash_screen.dart
- String?
- payment_methods_screen.dart
- 💳 Huly Pay Mobile Application
- qr_share_service.dart
- navbar_switch_button.dart
- _SplashScreenState
- app_update_service.dart
- qr_service.dart
- AppThemeContextExtension
- about_hulypay_screen.dart
- LaunchImage.imageset/README.md
- category_pie_chart.dart
- AppThemeData
- bool?
- transaction_details_card.dart
- package:flutter/material.dart
- package:flutter/foundation.dart
- transaction_tile.dart
- transaction_pdf_service.dart
- transaction_receipt_card.dart
- AnalysisScreen
- ScanAndPayScreen
- State
- sms_filter_service.dart
- ApiException

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
- `AboutHulyPayScreen` --inherits--> `StatefulWidget`  [EXTRACTED]
  lib/Screen/about_hulypay_screen.dart → None  _Bridges community 54 → community 72_
- `AnalysisScreen` --inherits--> `StatefulWidget`  [EXTRACTED]
  lib/Screen/analysis_screen.dart → None  _Bridges community 72 → community 69_
- `HelpSupportScreen` --inherits--> `StatefulWidget`  [EXTRACTED]
  lib/Screen/help_support_screen.dart → None  _Bridges community 72 → community 34_
- `PaymentMethodsScreen` --inherits--> `StatefulWidget`  [EXTRACTED]
  lib/Screen/payment_methods_screen.dart → None  _Bridges community 72 → community 46_
- `ScanAmountScreen` --inherits--> `StatefulWidget`  [EXTRACTED]
  lib/Screen/scan_amount_screen.dart → None  _Bridges community 72 → community 42_

## Import Cycles
- None detected.

## Communities (74 total, 8 thin omitted)

### Community 0 - "upload_qr_screen.dart"
Cohesion: 0.08
Nodes (25): _amountController, _amountFocusNode, build, _buildAppBar, createState, dispose, _handlePayButton, initialAmount (+17 more)

### Community 1 - "app_theme.dart"
Cohesion: 0.02
Nodes (102): AppThemeData get, Brightness, Color get, ColorScheme get, accent, allPalettes, amber, AppChartColors (+94 more)

### Community 2 - "single_transaction_screen.dart"
Cohesion: 0.04
Nodes (47): DraggableScrollableNotification, GoogleMapController?, _accuracy, build, _buildQuickActionButtons, _buildSectionHeader, _copyToClipboard, createState (+39 more)

### Community 3 - "../Data/external_data.dart"
Cohesion: 0.18
Nodes (10): ../Data/external_data.dart, build, _buildAppBar, _buildCurrentlyInDevelopmentCard, NotificationsScreen, build, _buildAppBar, _buildSectionHeader (+2 more)

### Community 4 - "AppDelegate"
Cohesion: 0.11
Nodes (14): Any, Flutter, FlutterAppDelegate, FlutterImplicitEngineBridge, FlutterImplicitEngineDelegate, FlutterSceneDelegate, AppDelegate, Bool (+6 more)

### Community 5 - "payment_details_page.dart"
Cohesion: 0.08
Nodes (24): amount, _amountController, _amountFocusNode, build, _buildAmountBox, _buildAppBar, _buildAvatar, _buildNoteField (+16 more)

### Community 6 - "scan_and_pay_screen.dart"
Cohesion: 0.04
Nodes (50): DateTime?, amount, build, buttonBg, buttonBorder, buttonIcon, cornerRadius, createState (+42 more)

### Community 7 - "spend_trend_line_chart.dart"
Cohesion: 0.09
Nodes (21): amount, _bottomTitleWidgets, build, _buildCardFooter, _buildCardHeader, _buildCurvedGradientData, _buildDualZoneData, _calculateMaxY (+13 more)

### Community 8 - "local_database_service.dart"
Cohesion: 0.05
Nodes (39): Database?, cleanupStalePayments, clearAll, clearPayments, clearUserProfile, close, _db, dbName (+31 more)

### Community 9 - "upi_payment_service.dart"
Cohesion: 0.05
Nodes (38): allApps, amazon, amazonPay, appNotInstalled, askEveryTime, bhim, bhimApp, buildSafeUpiUri (+30 more)

### Community 10 - "google_pay_service.dart"
Cohesion: 0.06
Nodes (35): amazonPayPackage, amount, approvalRefNo, _channel, errorMessage, fromNativeMap, fromQueryString, googlePayPackage (+27 more)

### Community 11 - "weekly_bar_chart.dart"
Cohesion: 0.12
Nodes (17): build, _buildBarChartData, _buildLegendItem, _calculateMax, _computeWeeklyData, createState, _defaultBarColor, _getBottomTitles (+9 more)

### Community 12 - "home_dashboard_screen.dart"
Cohesion: 0.05
Nodes (38): Animation, _applyData, build, _buildAvatarFallback, _buildBody, _buildDashboardContent, _buildQuickActions, _buildTotalSpentCard (+30 more)

### Community 13 - "round_button.dart"
Cohesion: 0.11
Nodes (18): activeBackgroundColor, back, backgroundColor, badgeColor, borderColor, build, child, icon (+10 more)

### Community 14 - "api_client.dart"
Cohesion: 0.08
Nodes (25): auth_service.dart, Dio, int?, checkAppVersion, createPayment, data, defaultAndroidHost, dio (+17 more)

### Community 15 - "dashboard_data.dart"
Cohesion: 0.06
Nodes (30): amount, avatarUrl, category, CategorySpendingItem, changePercent, changePeriodLabel, color, DashboardData (+22 more)

### Community 16 - "settings_screen.dart"
Cohesion: 0.06
Nodes (30): about_hulypay_screen.dart, help_support_screen.dart, appVersion, _avatarUrl, build, _buildGroupCard, _buildLogoutCard, _buildPreferencesSection (+22 more)

### Community 17 - "MainActivity"
Cohesion: 0.19
Nodes (9): FlutterActivity, MainActivity, BroadcastReceiver, Context, FlutterEngine, IntArray, Intent, MethodChannel (+1 more)

### Community 18 - "external_data.dart"
Cohesion: 0.02
Nodes (113): Acceptance of, Account, Changes to, Contact Regarding, Disclaimer of, Information We, aboutEnvironmentNoticeBody, aboutEnvironmentNoticeTitle (+105 more)

### Community 19 - "user_preferences_service.dart"
Cohesion: 0.06
Nodes (31): double? get, _cachedAnalysisPeriod, _cachedDailyLimit, _cachedDefaultPaymentApp, _cachedQuickConfirm, _cachedQuickScan, getAnalysisPeriod, getDailyLimit (+23 more)

### Community 20 - "transaction_model.dart"
Cohesion: 0.06
Nodes (35): dashboard_data.dart, amount, category, copyWith, createdAt, CreatePaymentPayload, CreateTransactionPayload, currency (+27 more)

### Community 21 - "analysis_screen.dart"
Cohesion: 0.06
Nodes (35): _allPayments, build, _buildCategoryList, _buildClassificationToggleButton, _buildHeader, _categories, _categoryOverrides, _classificationMode (+27 more)

### Community 22 - "spending_heatmap.dart"
Cohesion: 0.06
Nodes (33): activeCategory, build, CategoryPickerSheet, onSelectCategory, show, build, _buildFooter, _buildGrid (+25 more)

### Community 23 - "transactions_screen.dart"
Cohesion: 0.08
Nodes (24): analysis_screen.dart, home_dashboard_screen.dart, _allGroups, build, _buildFilterChips, _buildHeader, _buildSearchBar, createState (+16 more)

### Community 24 - "auth_service.dart"
Cohesion: 0.08
Nodes (25): AuthService, client, currentAccessToken, currentSession, currentUser, hasValidActiveToken, initialize, _initialized (+17 more)

### Community 25 - "card_dialog.dart"
Cohesion: 0.04
Nodes (46): Color? barrierColor,
  String, EdgeInsets, EdgeInsetsGeometry, accentColor, actions, _animController, backgroundColor, barrierDismissible (+38 more)

### Community 26 - "user_repository.dart"
Cohesion: 0.13
Nodes (14): _apiClient, getCachedUserProfile, getUserProfile, _instance, _localDb, saveUserProfile, UserRepository, ApiClient (+6 more)

### Community 27 - "sign_in_screen.dart"
Cohesion: 0.09
Nodes (21): _authSubscription, _authTimeoutTimer, build, createState, didChangeAppLifecycleState, dispose, _finishSignIn, _handleGitHubSignIn (+13 more)

### Community 28 - "location_service.dart"
Cohesion: 0.09
Nodes (22): bool get, accuracyMeters, errorMessage, failure, failureReason, getCurrentPaymentLocation, getPaymentLocationWithStatus, _instance (+14 more)

### Community 29 - "today_spend_gauge.dart"
Cohesion: 0.08
Nodes (24): CustomPainter, dart:math, ScannerOverlayPainter, activeColor, build, _buildZoneIndicator, _computeTodaySpend, createState (+16 more)

### Community 30 - "scan_payment_service.dart"
Cohesion: 0.06
Nodes (32): google_pay_service.dart, app, appName, checkPreferredAppReadiness, createPendingPayment, ensureSmsPermission, generateAmountQr, initialStatus (+24 more)

### Community 31 - "main.dart"
Cohesion: 0.14
Nodes (13): build, home, HulyPayApp, initializeAuth, isAuthenticated, main, nextScreen, showSplash (+5 more)

### Community 32 - "upi_service.dart"
Cohesion: 0.11
Nodes (17): amazonPayPackageName, amount, buildPaymentUri, currency, googlePayPackageName, isUpiUri, launchUpiPayment, merchantCode (+9 more)

### Community 33 - "sms_verification_dialog.dart"
Cohesion: 0.05
Nodes (43): card_dialog.dart, build, colors, false, filledDialogButton, MissingAppAction, payment, result (+35 more)

### Community 34 - "help_support_screen.dart"
Cohesion: 0.14
Nodes (14): build, _buildAppBar, _buildContactCard, _buildFaqItem, _buildFaqSection, _copyToClipboard, createState, HelpSupportScreen (+6 more)

### Community 35 - "edit_amount_sheet.dart"
Cohesion: 0.12
Nodes (17): _addAmount, build, _buildQuickChip, _controller, createState, currentAmount, dispose, EditAmountSheet (+9 more)

### Community 36 - "transaction_repository.dart"
Cohesion: 0.08
Nodes (25): _apiClient, cleanupStalePayments, cleanupStaleTransactions, createPayment, createTransaction, deletePayment, deleteTransaction, getCachedPayments (+17 more)

### Community 38 - "MaterialPageRoute"
Cohesion: 0.20
Nodes (10): _buildHeader, _openUploadQr, _openUploadFromScanner, _startSmsVerificationWorkflow, _buildAccountSection, _buildNotificationsSection, _buildSupportSection, _buildGroupedTransactions (+2 more)

### Community 39 - "transaction_map_section.dart"
Cohesion: 0.08
Nodes (26): accuracy, build, _buildGoogleMapContent, _buildMapFallbackCanvas, _buildStreetViewContent, _buildTab, createState, gridColor (+18 more)

### Community 40 - "Theme/app_theme.dart"
Cohesion: 0.15
Nodes (12): AppUpdateInfo, build, _buildNavItem, CustomBottomNavBar, onItemSelected, selectedIndex, AppUpdateBanner, build (+4 more)

### Community 41 - "StatelessWidget"
Cohesion: 0.18
Nodes (11): _AmountBadge, CardDialog, CardDialogTitleIcon, _HeatmapGridWidget, PaymentSummaryLines, RoundButton, TransactionActionButton, TransactionDetailRow (+3 more)

### Community 42 - "scan_amount_screen.dart"
Cohesion: 0.12
Nodes (16): FocusNode, _amountController, _amountFocusNode, build, _buildAppBar, createState, dispose, _handleScanButton (+8 more)

### Community 43 - "transaction_detail_components.dart"
Cohesion: 0.12
Nodes (16): Color?, backgroundColor, borderColor, build, canCopy, customIcon, icon, iconColor (+8 more)

### Community 44 - "splash_screen.dart"
Cohesion: 0.10
Nodes (19): AnimationController, Duration, build, _controller, createState, dispose, duration, _hasLocalUser (+11 more)

### Community 45 - "String?"
Cohesion: 0.13
Nodes (14): active, authProvider, avatarUrl, copyWith, email, firstName, fromJson, fullName (+6 more)

### Community 46 - "payment_methods_screen.dart"
Cohesion: 0.08
Nodes (24): build, _buildAppBar, _buildInstalledAppsGrid, _buildSectionTitle, createState, initState, _installedStatus, _isLoading (+16 more)

### Community 47 - "💳 Huly Pay Mobile Application"
Cohesion: 0.18
Nodes (10): Build optimized release APK:, ⚙️ Configuration & Environment, 📦 Core Dependencies & Tech Stack, 💳 Huly Pay Mobile Application, 🌟 Key Features, Output:, 📁 Project Architecture & Directory Layout, Run locally on an Android device or emulator: (+2 more)

### Community 48 - "qr_share_service.dart"
Cohesion: 0.14
Nodes (13): _channel, googlePayPackage, pickAndShareQrImage, pickQrImage, QrShareService, shareQrImage, _showSnackBar, _supportedImageExtensions (+5 more)

### Community 49 - "navbar_switch_button.dart"
Cohesion: 0.22
Nodes (9): IconData, build, icon, label, NavbarSwitchButton, onTap, QuickActionButton, svgAsset (+1 more)

### Community 50 - "_SplashScreenState"
Cohesion: 0.40
Nodes (5): SplashScreen, _SplashScreenState, _CardNotificationOverlay, _CardNotificationOverlayState, SingleTickerProviderStateMixin

### Community 51 - "app_update_service.dart"
Cohesion: 0.10
Nodes (20): api_client.dart, AppUpdateService, checkAppVersion, currentVersion, dismissBanner, downloadUrl, forceUpdate, fromJson (+12 more)

### Community 52 - "qr_service.dart"
Cohesion: 0.11
Nodes (17): dart:async, dart:ui, _cacheKey, clearCache, _debounceTimer, _fileCache, _generateInternal, getOrGenerateQrFile (+9 more)

### Community 54 - "about_hulypay_screen.dart"
Cohesion: 0.14
Nodes (14): AboutHulyPayScreen, _AboutHulyPayScreenState, appVersion, build, _buildAppBar, _buildCreatorSection, _buildHeroBrandCard, _buildSpecRow (+6 more)

### Community 56 - "category_pie_chart.dart"
Cohesion: 0.14
Nodes (14): AnalysisCategoryPieChart, _AnalysisCategoryPieChartState, bottomRightAction, build, centerLabel, createState, items, showCardBackground (+6 more)

### Community 63 - "transaction_details_card.dart"
Cohesion: 0.14
Nodes (13): double?, accuracy, build, category, latitude, longitude, onCategoryTap, paymentMethod (+5 more)

### Community 64 - "package:flutter/material.dart"
Cohesion: 0.09
Nodes (23): Container, package:flutter/material.dart, package:flutter_test/flutter_test.dart, package:hulypay/Screen/scan_amount_screen.dart, package:hulypay/Screen/scan_and_pay_screen.dart, package:hulypay/Screen/upload_qr_screen.dart, package:hulypay/Service/app_update_service.dart, package:hulypay/Service/qr_service.dart (+15 more)

### Community 65 - "package:flutter/foundation.dart"
Cohesion: 0.22
Nodes (8): dart:convert, getEmail, getExpirationDate, getPayload, getSubject, isExpired, TokenValidator, package:flutter/foundation.dart

### Community 66 - "transaction_tile.dart"
Cohesion: 0.22
Nodes (8): TransactionItem, onTap, payment, transaction, TransactionTile, ../../Model/dashboard_data.dart, ../../Screen/single_transaction_screen.dart, VoidCallback?

### Community 67 - "transaction_pdf_service.dart"
Cohesion: 0.18
Nodes (10): dart:io, _buildDetailRow, _buildDivider, _formatProvider, generateReceipt, TransactionPdfService, package:flutter/services.dart, package:path_provider/path_provider.dart (+2 more)

### Community 68 - "transaction_receipt_card.dart"
Cohesion: 0.25
Nodes (7): build, displayAmount, isIncome, merchantTitle, status, time, TransactionReceiptCard

### Community 72 - "State"
Cohesion: 0.17
Nodes (16): HomeDashboardScreen, _HomeDashboardScreenState, SettingsScreen, _SettingsScreenState, SignInScreen, _SignInScreenState, UploadQrScreen, _UploadQrScreenState (+8 more)

### Community 73 - "sms_filter_service.dart"
Cohesion: 0.40
Nodes (4): financialKeywords, isFinancialTransactionSms, SmsFilterService, static const List

## Knowledge Gaps
- **1171 isolated node(s):** `main`, `main`, `main`, `main`, `main` (+1166 more)
  These have ≤1 connection - possible missing edges or undocumented components. (Counts symbols only; 1314 node(s) total have ≤1 connection when file, concept and rationale nodes are included.)
- **8 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `PaymentModel` connect `transaction_model.dart` to `sms_verification_dialog.dart`, `single_transaction_screen.dart`, `transaction_tile.dart`, `dashboard_data.dart`?**
  _High betweenness centrality (0.004) - this node is a cross-community bridge._
- **Why does `_HomeDashboardScreenState` connect `State` to `home_dashboard_screen.dart`?**
  _High betweenness centrality (0.001) - this node is a cross-community bridge._
- **Why does `ApiClient` connect `user_repository.dart` to `transaction_repository.dart`, `api_client.dart`?**
  _High betweenness centrality (0.001) - this node is a cross-community bridge._
- **What connects `main`, `main`, `main` to the rest of the system?**
  _1171 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `upload_qr_screen.dart` be split into smaller, more focused modules?**
  _Cohesion score 0.07692307692307693 - nodes in this community are weakly interconnected._
- **Should `app_theme.dart` be split into smaller, more focused modules?**
  _Cohesion score 0.019417475728155338 - nodes in this community are weakly interconnected._
- **Should `single_transaction_screen.dart` be split into smaller, more focused modules?**
  _Cohesion score 0.0425531914893617 - nodes in this community are weakly interconnected._