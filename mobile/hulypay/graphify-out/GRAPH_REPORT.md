# Graph Report - hulypay  (2026-09-26)

## Corpus Check
- 58 files · ~59,872 words
- Verdict: corpus is large enough that graph structure adds value.

## Summary
- 1169 nodes · 1470 edges · 57 communities (47 shown, 6 thin omitted)
- Extraction: 100% EXTRACTED · 0% INFERRED · 0% AMBIGUOUS
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `c5e9b255`
- Run `git rev-parse HEAD` and compare to check if the graph is stale.
- Run `graphify update .` after code changes (no API cost).

## Community Hubs (Navigation)
- upload_qr_screen.dart
- app_theme.dart
- single_transaction_screen.dart
- notifications_screen.dart
- AppDelegate
- upi_service.dart
- scan_and_pay_screen.dart
- home_spend_trend_line_chart.dart
- local_database_service.dart
- upi_payment_service.dart
- google_pay_service.dart
- chart_colors.dart
- home_dashboard_screen.dart
- expense_model.dart
- api_client.dart
- dashboard_data.dart
- settings_screen.dart
- MainActivity
- splash_screen.dart
- user_preferences_service.dart
- payment_model.dart
- analysis_screen.dart
- spending_heatmap.dart
- transactions_screen.dart
- auth_service.dart
- home_weekly_bar_chart.dart
- payment_repository.dart
- sign_in_screen.dart
- location_service.dart
- home_today_spend_gauge.dart
- help_support_screen.dart
- main.dart
- user_profile.dart
- analysis_category_pie_chart.dart
- about_hulypay_screen.dart
- Upload QR Feature (v2.5.0)
- String?
- hulypay/MainActivity.kt
- package:flutter/foundation.dart
- privacy_security_screen.dart
- StatelessWidget
- ../theme/app_theme.dart
- transaction_tile.dart
- payment_methods_screen.dart
- qr_share_service.dart
- _HomeDashboardScreenState
- setCustomClient
- AppThemeContextExtension
- LaunchImage.imageset/README.md
- AppThemeData
- bool?
- package:flutter/material.dart
- State

## God Nodes (most connected - your core abstractions)
1. `MainActivity` - 15 edges
2. `BroadcastReceiver` - 6 edges
3. `Upload QR Feature (v2.5.0)` - 6 edges
4. `AppDelegate` - 5 edges
5. `_HomeDashboardScreenState` - 5 edges
6. `PaymentModel` - 4 edges
7. `_NotificationsScreenState` - 4 edges
8. `_SignInScreenState` - 4 edges
9. `_SplashScreenState` - 4 edges
10. `AppThemeData` - 4 edges

## Surprising Connections (you probably didn't know these)
- `PrivacySecurityScreen` --inherits--> `StatelessWidget`  [EXTRACTED]
  lib/screens/privacy_security_screen.dart → None  _Bridges community 41 → community 40_
- `HelpSupportScreen` --inherits--> `StatefulWidget`  [EXTRACTED]
  lib/screens/help_support_screen.dart → None  _Bridges community 71 → community 30_
- `HomeDashboardScreen` --inherits--> `StatefulWidget`  [EXTRACTED]
  lib/screens/home_dashboard_screen.dart → None  _Bridges community 71 → community 50_
- `ScanAndPayScreen` --inherits--> `StatefulWidget`  [EXTRACTED]
  lib/screens/scan_and_pay_screen.dart → None  _Bridges community 71 → community 6_
- `SettingsScreen` --inherits--> `StatefulWidget`  [EXTRACTED]
  lib/screens/settings_screen.dart → None  _Bridges community 71 → community 16_

## Import Cycles
- None detected.

## Communities (57 total, 6 thin omitted)

### Community 0 - "upload_qr_screen.dart"
Cohesion: 0.11
Nodes (19): FocusNode, _amountController, _amountFocusNode, build, createState, dispose, _handleUploadButton, initialAmount (+11 more)

### Community 1 - "app_theme.dart"
Cohesion: 0.03
Nodes (61): AppThemeData get, Brightness, ColorScheme get, accent, AppRadii, AppSpacing, AppThemeManager, background (+53 more)

### Community 2 - "single_transaction_screen.dart"
Cohesion: 0.04
Nodes (52): DraggableScrollableNotification, GoogleMapController?, _accuracy, build, _buildActionButton, _buildDarkMapFallbackCanvas, _buildDetailRow, _buildDetailsCard (+44 more)

### Community 3 - "notifications_screen.dart"
Cohesion: 0.10
Nodes (19): _budgetExceededWarnings, build, _buildAppBar, _buildDevNoticeBanner, _buildInboxTab, _buildNotificationCard, _buildPreferencesTab, _buildSwitchTile (+11 more)

### Community 4 - "AppDelegate"
Cohesion: 0.11
Nodes (14): Any, Flutter, FlutterAppDelegate, FlutterImplicitEngineBridge, FlutterImplicitEngineDelegate, FlutterSceneDelegate, AppDelegate, Bool (+6 more)

### Community 5 - "upi_service.dart"
Cohesion: 0.11
Nodes (18): double?, amazonPayPackageName, amount, buildPaymentUri, currency, googlePayPackageName, isUpiUri, launchUpiPayment (+10 more)

### Community 6 - "scan_and_pay_screen.dart"
Cohesion: 0.05
Nodes (45): CustomPainter, DateTime?, build, cornerColor, cornerLength, cornerRadius, createState, cutoutRect (+37 more)

### Community 7 - "home_spend_trend_line_chart.dart"
Cohesion: 0.09
Nodes (23): amount, _bottomTitleWidgets, build, _buildCardFooter, _buildCardHeader, _buildCurvedGradientData, _buildDualZoneData, _calculateMaxY (+15 more)

### Community 8 - "local_database_service.dart"
Cohesion: 0.05
Nodes (41): Database?, cleanupStalePayments, clearAll, clearPayments, clearUserProfile, close, _db, dbName (+33 more)

### Community 9 - "upi_payment_service.dart"
Cohesion: 0.05
Nodes (39): allApps, amazon, amazonPay, appNotInstalled, askEveryTime, bhim, bhimApp, buildSafeUpiUri (+31 more)

### Community 10 - "google_pay_service.dart"
Cohesion: 0.05
Nodes (36): amazonPayPackage, amount, approvalRefNo, _channel, errorMessage, fromNativeMap, fromQueryString, googlePayPackage (+28 more)

### Community 11 - "chart_colors.dart"
Cohesion: 0.06
Nodes (33): app_theme.dart, financialKeywords, isFinancialTransactionSms, SmsFilterService, allPalettes, amber, AppChartColors, barDefault (+25 more)

### Community 12 - "home_dashboard_screen.dart"
Cohesion: 0.05
Nodes (37): Animation, AnimationController, _applyData, build, _buildAvatarFallback, _buildBody, _buildDashboardContent, _buildQuickActions (+29 more)

### Community 13 - "expense_model.dart"
Cohesion: 0.09
Nodes (21): category_model.dart, amount, category, categoryId, createdAt, CreateExpensePayload, currency, description (+13 more)

### Community 14 - "api_client.dart"
Cohesion: 0.06
Nodes (33): auth_service.dart, Dio, Exception, int?, ApiException, createCategory, createExpense, createPayment (+25 more)

### Community 15 - "dashboard_data.dart"
Cohesion: 0.06
Nodes (30): amount, avatarUrl, category, CategorySpendingItem, changePercent, changePeriodLabel, color, DashboardData (+22 more)

### Community 16 - "settings_screen.dart"
Cohesion: 0.05
Nodes (41): about_hulypay_screen.dart, help_support_screen.dart, _buildHeader, _openUploadQr, _showPaymentConfirmationModal, _startSmsVerificationWorkflow, appVersion, _avatarUrl (+33 more)

### Community 17 - "MainActivity"
Cohesion: 0.20
Nodes (9): FlutterActivity, MainActivity, BroadcastReceiver, Context, FlutterEngine, IntArray, Intent, MethodChannel (+1 more)

### Community 18 - "splash_screen.dart"
Cohesion: 0.04
Nodes (51): , dart:ui, Duration, animation, build, _controller, createState, dispose (+43 more)

### Community 19 - "user_preferences_service.dart"
Cohesion: 0.06
Nodes (35): double? get, _cachedAnalysisPeriod, _cachedDailyLimit, _cachedDefaultPaymentApp, _cachedQuickConfirm, _cachedQuickScan, _client, _customClient (+27 more)

### Community 20 - "payment_model.dart"
Cohesion: 0.07
Nodes (27): dashboard_data.dart, amount, copyWith, createdAt, CreatePaymentPayload, currency, expenseId, fromJson (+19 more)

### Community 21 - "analysis_screen.dart"
Cohesion: 0.06
Nodes (34): _allPayments, build, _buildCategoryList, _buildClassificationToggleButton, _buildHeader, _categories, _categoryOverrides, _classificationMode (+26 more)

### Community 22 - "spending_heatmap.dart"
Cohesion: 0.07
Nodes (27): build, _buildFooter, _buildGrid, _buildHeader, cells, columns, _computePeriodTotal, createState (+19 more)

### Community 23 - "transactions_screen.dart"
Cohesion: 0.08
Nodes (25): analysis_screen.dart, home_dashboard_screen.dart, _allGroups, build, _buildFilterChips, _buildHeader, _buildSearchBar, createState (+17 more)

### Community 24 - "auth_service.dart"
Cohesion: 0.07
Nodes (27): dart:async, AuthService, client, currentAccessToken, currentSession, currentUser, hasValidActiveToken, initialize (+19 more)

### Community 25 - "home_weekly_bar_chart.dart"
Cohesion: 0.11
Nodes (18): build, _buildBarChartData, _buildLegendItem, _calculateMax, _computeWeeklyData, createState, _defaultBarColor, _getBottomTitles (+10 more)

### Community 26 - "payment_repository.dart"
Cohesion: 0.08
Nodes (27): _apiClient, cleanupStalePayments, createPayment, getCachedPayments, getPaymentById, getPayments, _instance, _localDb (+19 more)

### Community 27 - "sign_in_screen.dart"
Cohesion: 0.09
Nodes (22): _authSubscription, _authTimeoutTimer, build, createState, didChangeAppLifecycleState, dispose, _finishSignIn, _handleGitHubSignIn (+14 more)

### Community 28 - "location_service.dart"
Cohesion: 0.09
Nodes (22): bool get, accuracyMeters, errorMessage, failure, failureReason, getCurrentPaymentLocation, getPaymentLocationWithStatus, _instance (+14 more)

### Community 29 - "home_today_spend_gauge.dart"
Cohesion: 0.10
Nodes (21): Color, dart:math, activeColor, build, _buildZoneIndicator, _computeTodaySpend, createState, _customLimit (+13 more)

### Community 30 - "help_support_screen.dart"
Cohesion: 0.13
Nodes (15): build, _buildAppBar, _buildDeveloperWebsiteCard, _buildEmailContactCard, _buildFaqItem, _buildFaqSection, _copyToClipboard, createState (+7 more)

### Community 31 - "main.dart"
Cohesion: 0.14
Nodes (13): build, home, initializeAuth, isAuthenticated, main, nextScreen, showSplash, widgetsBinding (+5 more)

### Community 32 - "user_profile.dart"
Cohesion: 0.14
Nodes (13): active, authProvider, avatarUrl, copyWith, email, firstName, fromJson, fullName (+5 more)

### Community 33 - "analysis_category_pie_chart.dart"
Cohesion: 0.14
Nodes (14): AnalysisCategoryPieChart, _AnalysisCategoryPieChartState, bottomRightAction, build, centerLabel, createState, items, showCardBackground (+6 more)

### Community 34 - "about_hulypay_screen.dart"
Cohesion: 0.15
Nodes (12): appVersion, build, _buildAppBar, _buildCreatorSection, _buildEnvironmentNoticeCard, _buildFeatureHighlights, _buildFeatureItem, _buildHeroBrandCard (+4 more)

### Community 35 - "Upload QR Feature (v2.5.0)"
Cohesion: 0.15
Nodes (12): 1. **Frictionless Amount & Note Entry**, 1. Presentation Layer, 2. **Lossless Gallery Image Selection**, 2. Service Layer, 3. Native Android Layer, 3. **Native Sharesheet Integration**, 🏗 Architecture & Code Structure, 🚀 Key Highlights & User Flow (+4 more)

### Community 36 - "String?"
Cohesion: 0.20
Nodes (9): CategoryModel, color, fromJson, icon, id, isDefault, name, toJson (+1 more)

### Community 39 - "package:flutter/foundation.dart"
Cohesion: 0.22
Nodes (8): dart:convert, getEmail, getExpirationDate, getPayload, getSubject, isExpired, TokenValidator, package:flutter/foundation.dart

### Community 40 - "privacy_security_screen.dart"
Cohesion: 0.20
Nodes (9): build, _buildAppBar, _buildBulletPoint, _buildDataCollectionCard, _buildDevelopmentPrivacyNotice, _buildProtocolItem, _buildSecurityBanner, _buildSecurityProtocolsCard (+1 more)

### Community 41 - "StatelessWidget"
Cohesion: 0.22
Nodes (9): HulyPayApp, AboutHulyPayScreen, AnimatedHulyLogo, AnimatedWaveBackground, QuickActionButton, CustomBottomNavBar, _HeatmapGridWidget, TransactionTile (+1 more)

### Community 44 - "../theme/app_theme.dart"
Cohesion: 0.25
Nodes (7): build, _buildNavItem, onItemSelected, selectedIndex, package:flutter_svg/flutter_svg.dart, ../theme/app_theme.dart, ValueChanged

### Community 45 - "transaction_tile.dart"
Cohesion: 0.22
Nodes (8): TransactionItem, PaymentModel, onTap, payment, transaction, ../models/dashboard_data.dart, ../models/payment_model.dart, ../screens/single_transaction_screen.dart

### Community 46 - "payment_methods_screen.dart"
Cohesion: 0.12
Nodes (15): build, _buildAppBar, _buildInstalledAppsList, _buildPaymentAppCard, _buildSectionTitle, createState, initState, _installedStatus (+7 more)

### Community 48 - "qr_share_service.dart"
Cohesion: 0.15
Nodes (12): dart:io, _channel, pickAndShareQrImage, pickQrImage, QrShareService, shareQrImage, _showSnackBar, _supportedImageExtensions (+4 more)

### Community 50 - "_HomeDashboardScreenState"
Cohesion: 0.33
Nodes (6): HomeDashboardScreen, _HomeDashboardScreenState, SignInScreen, _SignInScreenState, TickerProviderStateMixin, WidgetsBindingObserver

### Community 68 - "package:flutter/material.dart"
Cohesion: 0.22
Nodes (8): IconData?, build, icon, label, onTap, svgAsset, package:flutter/material.dart, VoidCallback?

### Community 71 - "State"
Cohesion: 0.22
Nodes (13): AnalysisScreen, _AnalysisScreenState, NotificationsScreen, _NotificationsScreenState, PaymentMethodsScreen, _PaymentMethodsScreenState, SingleTransactionScreen, _SingleTransactionScreenState (+5 more)

## Knowledge Gaps
- **844 isolated node(s):** `XCTest`, `widgetsBinding`, `showSplash`, `home`, `initializeAuth` (+839 more)
  These have ≤1 connection - possible missing edges or undocumented components. (Counts symbols only; 953 node(s) total have ≤1 connection when file, concept and rationale nodes are included.)
- **6 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `AppThemeContextExtension` connect `AppThemeContextExtension` to `app_theme.dart`?**
  _High betweenness centrality (0.010) - this node is a cross-community bridge._
- **Why does `PaymentModel` connect `transaction_tile.dart` to `single_transaction_screen.dart`, `payment_model.dart`, `dashboard_data.dart`?**
  _High betweenness centrality (0.006) - this node is a cross-community bridge._
- **Why does `LocalDatabaseService` connect `payment_repository.dart` to `local_database_service.dart`?**
  _High betweenness centrality (0.003) - this node is a cross-community bridge._
- **What connects `XCTest`, `widgetsBinding`, `showSplash` to the rest of the system?**
  _844 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `upload_qr_screen.dart` be split into smaller, more focused modules?**
  _Cohesion score 0.10526315789473684 - nodes in this community are weakly interconnected._
- **Should `app_theme.dart` be split into smaller, more focused modules?**
  _Cohesion score 0.03225806451612903 - nodes in this community are weakly interconnected._
- **Should `single_transaction_screen.dart` be split into smaller, more focused modules?**
  _Cohesion score 0.03773584905660377 - nodes in this community are weakly interconnected._