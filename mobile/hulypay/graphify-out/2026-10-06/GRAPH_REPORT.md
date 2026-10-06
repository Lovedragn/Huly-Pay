# Graph Report - hulypay  (2026-09-28)

## Corpus Check
- 63 files · ~59,897 words
- Verdict: corpus is large enough that graph structure adds value.

## Summary
- 1266 nodes · 1605 edges · 59 communities (48 shown, 7 thin omitted)
- Extraction: 100% EXTRACTED · 0% INFERRED · 0% AMBIGUOUS
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `80b3db42`
- Run `git rev-parse HEAD` and compare to check if the graph is stale.
- Run `graphify update .` after code changes (no API cost).

## Community Hubs (Navigation)
- upload_qr_screen.dart
- app_theme.dart
- single_transaction_screen.dart
- package:flutter/material.dart
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
- external_data.dart
- user_preferences_service.dart
- payment_model.dart
- analysis_screen.dart
- spending_heatmap.dart
- transactions_screen.dart
- auth_service.dart
- _HomeDashboardScreenState
- user_repository.dart
- sign_in_screen.dart
- location_service.dart
- home_today_spend_gauge.dart
- help_support_screen.dart
- main.dart
- transaction_detail_components.dart
- about_hulypay_screen.dart
- scan_amount_screen.dart
- payment_repository.dart
- hulypay/MainActivity.kt
- MaterialPageRoute
- package:flutter/foundation.dart
- category_picker_sheet.dart
- StatelessWidget
- CustomPainter
- package:flutter_svg/flutter_svg.dart
- ../models/payment_model.dart
- payment_methods_screen.dart
- README.md
- qr_share_service.dart
- action_button.dart
- State
- setCustomClient
- AppThemeContextExtension
- LaunchImage.imageset/README.md
- AppThemeData
- bool?
- customization_bottom_sheet.dart

## God Nodes (most connected - your core abstractions)
1. `MainActivity` - 15 edges
2. `BroadcastReceiver` - 6 edges
3. `AppDelegate` - 5 edges
4. `_HomeDashboardScreenState` - 5 edges
5. `PaymentModel` - 4 edges
6. `_SignInScreenState` - 4 edges
7. `_SplashScreenState` - 4 edges
8. `AppThemeData` - 4 edges
9. `Flutter` - 3 edges
10. `RunnerTests` - 3 edges

## Surprising Connections (you probably didn't know these)
- `NotificationsScreen` --inherits--> `StatelessWidget`  [EXTRACTED]
  lib/screens/notifications_screen.dart → None  _Bridges community 41 → community 3_
- `CategoryPickerSheet` --inherits--> `StatelessWidget`  [EXTRACTED]
  lib/widgets/category_picker_sheet.dart → None  _Bridges community 41 → community 40_
- `CustomBottomNavBar` --inherits--> `StatelessWidget`  [EXTRACTED]
  lib/widgets/custom_bottom_nav_bar.dart → None  _Bridges community 41 → community 44_
- `HomeDashboardScreen` --inherits--> `StatefulWidget`  [EXTRACTED]
  lib/screens/home_dashboard_screen.dart → None  _Bridges community 50 → community 25_
- `PaymentMethodsScreen` --inherits--> `StatefulWidget`  [EXTRACTED]
  lib/screens/payment_methods_screen.dart → None  _Bridges community 50 → community 46_

## Import Cycles
- None detected.

## Communities (59 total, 7 thin omitted)

### Community 0 - "upload_qr_screen.dart"
Cohesion: 0.10
Nodes (19): _amountController, _amountFocusNode, build, createState, dispose, _handleUploadButton, initialAmount, initState (+11 more)

### Community 1 - "app_theme.dart"
Cohesion: 0.03
Nodes (62): AppThemeData get, Brightness, ColorScheme get, accent, AppRadii, AppSpacing, AppThemeManager, background (+54 more)

### Community 2 - "single_transaction_screen.dart"
Cohesion: 0.04
Nodes (51): DraggableScrollableNotification, GoogleMapController?, _accuracy, build, _buildDarkMapFallbackCanvas, _buildDetailsCard, _buildGoogleMapContent, _buildGoogleMapOrStreetView (+43 more)

### Community 3 - "package:flutter/material.dart"
Cohesion: 0.20
Nodes (10): ../data/external_data.dart, build, _buildAppBar, _buildCurrentlyInDevelopmentCard, NotificationsScreen, build, _buildAppBar, _buildSectionHeader (+2 more)

### Community 4 - "AppDelegate"
Cohesion: 0.11
Nodes (14): Any, Flutter, FlutterAppDelegate, FlutterImplicitEngineBridge, FlutterImplicitEngineDelegate, FlutterSceneDelegate, AppDelegate, Bool (+6 more)

### Community 5 - "upi_service.dart"
Cohesion: 0.11
Nodes (17): amazonPayPackageName, amount, buildPaymentUri, currency, googlePayPackageName, isUpiUri, launchUpiPayment, merchantCode (+9 more)

### Community 6 - "scan_and_pay_screen.dart"
Cohesion: 0.05
Nodes (39): DateTime?, _amountController, build, cornerColor, cornerLength, cornerRadius, createState, cutoutRect (+31 more)

### Community 7 - "home_spend_trend_line_chart.dart"
Cohesion: 0.09
Nodes (23): amount, _bottomTitleWidgets, build, _buildCardFooter, _buildCardHeader, _buildCurvedGradientData, _buildDualZoneData, _calculateMaxY (+15 more)

### Community 8 - "local_database_service.dart"
Cohesion: 0.05
Nodes (41): Database?, cleanupStalePayments, clearAll, clearPayments, clearUserProfile, close, _db, dbName (+33 more)

### Community 9 - "upi_payment_service.dart"
Cohesion: 0.04
Nodes (43): financialKeywords, isFinancialTransactionSms, SmsFilterService, allApps, amazon, amazonPay, appNotInstalled, askEveryTime (+35 more)

### Community 10 - "google_pay_service.dart"
Cohesion: 0.05
Nodes (36): amazonPayPackage, amount, approvalRefNo, _channel, errorMessage, fromNativeMap, fromQueryString, googlePayPackage (+28 more)

### Community 11 - "chart_colors.dart"
Cohesion: 0.04
Nodes (47): app_theme.dart, allPalettes, amber, AppChartColors, barDefault, barToday, barTouched, barTrack (+39 more)

### Community 12 - "home_dashboard_screen.dart"
Cohesion: 0.06
Nodes (35): Animation, _applyData, build, _buildAvatarFallback, _buildBody, _buildDashboardContent, _buildQuickActions, _buildTotalSpentCard (+27 more)

### Community 13 - "expense_model.dart"
Cohesion: 0.04
Nodes (43): category_model.dart, CategoryModel, color, fromJson, icon, id, isDefault, name (+35 more)

### Community 14 - "api_client.dart"
Cohesion: 0.06
Nodes (32): auth_service.dart, Dio, Exception, int?, ApiException, createCategory, createExpense, createPayment (+24 more)

### Community 15 - "dashboard_data.dart"
Cohesion: 0.06
Nodes (30): amount, avatarUrl, category, CategorySpendingItem, changePercent, changePeriodLabel, color, DashboardData (+22 more)

### Community 16 - "settings_screen.dart"
Cohesion: 0.06
Nodes (30): about_hulypay_screen.dart, help_support_screen.dart, appVersion, _avatarUrl, build, _buildAppInfoFooter, _buildGroupCard, _buildLogoutCard (+22 more)

### Community 17 - "MainActivity"
Cohesion: 0.20
Nodes (9): FlutterActivity, MainActivity, BroadcastReceiver, Context, FlutterEngine, IntArray, Intent, MethodChannel (+1 more)

### Community 18 - "external_data.dart"
Cohesion: 0.02
Nodes (110): Acceptance of, Account, Changes to, Contact Regarding, Disclaimer of, Information We, aboutEnvironmentNoticeBody, aboutEnvironmentNoticeTitle (+102 more)

### Community 19 - "user_preferences_service.dart"
Cohesion: 0.06
Nodes (35): double? get, _cachedAnalysisPeriod, _cachedDailyLimit, _cachedDefaultPaymentApp, _cachedQuickConfirm, _cachedQuickScan, _client, _customClient (+27 more)

### Community 20 - "payment_model.dart"
Cohesion: 0.07
Nodes (27): dashboard_data.dart, amount, copyWith, createdAt, CreatePaymentPayload, currency, expenseId, fromJson (+19 more)

### Community 21 - "analysis_screen.dart"
Cohesion: 0.04
Nodes (46): _allPayments, build, _buildCategoryList, _buildClassificationToggleButton, _buildHeader, _categories, _categoryOverrides, _classificationMode (+38 more)

### Community 22 - "spending_heatmap.dart"
Cohesion: 0.07
Nodes (27): build, _buildFooter, _buildGrid, _buildHeader, cells, columns, _computePeriodTotal, createState (+19 more)

### Community 23 - "transactions_screen.dart"
Cohesion: 0.08
Nodes (23): analysis_screen.dart, _allGroups, build, _buildFilterChips, _buildSearchBar, createState, dispose, _filterActivePayments (+15 more)

### Community 24 - "auth_service.dart"
Cohesion: 0.07
Nodes (26): AuthService, client, currentAccessToken, currentSession, currentUser, hasValidActiveToken, initialize, _initialized (+18 more)

### Community 25 - "_HomeDashboardScreenState"
Cohesion: 0.33
Nodes (6): HomeDashboardScreen, _HomeDashboardScreenState, SignInScreen, _SignInScreenState, TickerProviderStateMixin, WidgetsBindingObserver

### Community 26 - "user_repository.dart"
Cohesion: 0.14
Nodes (13): _apiClient, getCachedUserProfile, getUserProfile, _instance, _localDb, saveUserProfile, UserRepository, ApiClient (+5 more)

### Community 27 - "sign_in_screen.dart"
Cohesion: 0.05
Nodes (42): AnimationController, dart:async, Duration, home_dashboard_screen.dart, _authSubscription, _authTimeoutTimer, build, createState (+34 more)

### Community 28 - "location_service.dart"
Cohesion: 0.09
Nodes (22): bool get, accuracyMeters, errorMessage, failure, failureReason, getCurrentPaymentLocation, getPaymentLocationWithStatus, _instance (+14 more)

### Community 29 - "home_today_spend_gauge.dart"
Cohesion: 0.10
Nodes (20): dart:math, activeColor, build, _buildZoneIndicator, _computeTodaySpend, createState, _customLimit, dailyBudget (+12 more)

### Community 30 - "help_support_screen.dart"
Cohesion: 0.14
Nodes (13): build, _buildAppBar, _buildDeveloperWebsiteCard, _buildEmailContactCard, _buildFaqItem, _buildFaqSection, _copyToClipboard, createState (+5 more)

### Community 31 - "main.dart"
Cohesion: 0.14
Nodes (13): build, home, initializeAuth, isAuthenticated, main, nextScreen, showSplash, widgetsBinding (+5 more)

### Community 32 - "transaction_detail_components.dart"
Cohesion: 0.12
Nodes (15): Color?, backgroundColor, borderColor, build, canCopy, icon, iconColor, isPrimary (+7 more)

### Community 34 - "about_hulypay_screen.dart"
Cohesion: 0.15
Nodes (12): appVersion, build, _buildAppBar, _buildCreatorSection, _buildEnvironmentNoticeCard, _buildFeatureHighlights, _buildFeatureItem, _buildHeroBrandCard (+4 more)

### Community 35 - "scan_amount_screen.dart"
Cohesion: 0.13
Nodes (14): double?, FocusNode, _amountController, _amountFocusNode, build, createState, dispose, _handleScanButton (+6 more)

### Community 36 - "payment_repository.dart"
Cohesion: 0.12
Nodes (15): _apiClient, cleanupStalePayments, createPayment, deletePayment, getCachedPayments, getPaymentById, getPayments, _instance (+7 more)

### Community 38 - "MaterialPageRoute"
Cohesion: 0.18
Nodes (11): _buildHeader, _openUploadQr, _showPaymentConfirmationModal, _startSmsVerificationWorkflow, _buildAccountSection, _buildNotificationsSection, _buildSupportSection, _buildGroupedTransactions (+3 more)

### Community 39 - "package:flutter/foundation.dart"
Cohesion: 0.22
Nodes (8): dart:convert, getEmail, getExpirationDate, getPayload, getSubject, isExpired, TokenValidator, package:flutter/foundation.dart

### Community 40 - "category_picker_sheet.dart"
Cohesion: 0.29
Nodes (6): activeCategory, build, CategoryPickerSheet, onSelectCategory, show, ValueChanged

### Community 41 - "StatelessWidget"
Cohesion: 0.22
Nodes (9): HulyPayApp, AboutHulyPayScreen, PrivacySecurityScreen, QuickActionButton, _HeatmapGridWidget, TransactionActionButton, TransactionDetailRow, TransactionTile (+1 more)

### Community 42 - "CustomPainter"
Cohesion: 0.40
Nodes (5): CustomPainter, ScannerFramePainter, ScannerOverlayPainter, _MapGridPainter, _SpeedometerGaugePainter

### Community 44 - "package:flutter_svg/flutter_svg.dart"
Cohesion: 0.29
Nodes (6): build, _buildNavItem, CustomBottomNavBar, onItemSelected, selectedIndex, package:flutter_svg/flutter_svg.dart

### Community 45 - "../models/payment_model.dart"
Cohesion: 0.25
Nodes (7): TransactionItem, PaymentModel, onTap, payment, transaction, ../models/payment_model.dart, ../screens/single_transaction_screen.dart

### Community 46 - "payment_methods_screen.dart"
Cohesion: 0.12
Nodes (17): build, _buildAppBar, _buildInstalledAppsList, _buildPaymentAppCard, _buildSectionTitle, createState, initState, _installedStatus (+9 more)

### Community 48 - "qr_share_service.dart"
Cohesion: 0.15
Nodes (12): dart:io, _channel, googlePayPackage, pickAndShareQrImage, pickQrImage, QrShareService, shareQrImage, _showSnackBar (+4 more)

### Community 49 - "action_button.dart"
Cohesion: 0.25
Nodes (7): IconData, build, icon, label, onTap, svgAsset, VoidCallback?

### Community 50 - "State"
Cohesion: 0.12
Nodes (23): AnalysisScreen, _AnalysisScreenState, HelpSupportScreen, _HelpSupportScreenState, ScanAmountScreen, _ScanAmountScreenState, ScanAndPayScreen, _ScanAndPayScreenState (+15 more)

### Community 68 - "customization_bottom_sheet.dart"
Cohesion: 0.20
Nodes (10): build, _buildChartPaletteOptionCard, _buildThemeOptionCard, createState, CustomizationBottomSheet, _CustomizationBottomSheetState, onThemeChanged, show (+2 more)

## Knowledge Gaps
- **932 isolated node(s):** `XCTest`, `FeatureHighlightItem`, `TechSpecItem`, `ScopeBulletItem`, `SecurityProtocolItem` (+927 more)
  These have ≤1 connection - possible missing edges or undocumented components. (Counts symbols only; 1043 node(s) total have ≤1 connection when file, concept and rationale nodes are included.)
- **7 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `PaymentModel` connect `../models/payment_model.dart` to `single_transaction_screen.dart`, `payment_model.dart`, `dashboard_data.dart`?**
  _High betweenness centrality (0.003) - this node is a cross-community bridge._
- **Why does `_HomeDashboardScreenState` connect `_HomeDashboardScreenState` to `State`, `home_dashboard_screen.dart`?**
  _High betweenness centrality (0.002) - this node is a cross-community bridge._
- **Why does `TransactionItem` connect `../models/payment_model.dart` to `single_transaction_screen.dart`, `dashboard_data.dart`?**
  _High betweenness centrality (0.001) - this node is a cross-community bridge._
- **What connects `XCTest`, `FeatureHighlightItem`, `TechSpecItem` to the rest of the system?**
  _932 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `upload_qr_screen.dart` be split into smaller, more focused modules?**
  _Cohesion score 0.1 - nodes in this community are weakly interconnected._
- **Should `app_theme.dart` be split into smaller, more focused modules?**
  _Cohesion score 0.031746031746031744 - nodes in this community are weakly interconnected._
- **Should `single_transaction_screen.dart` be split into smaller, more focused modules?**
  _Cohesion score 0.038461538461538464 - nodes in this community are weakly interconnected._