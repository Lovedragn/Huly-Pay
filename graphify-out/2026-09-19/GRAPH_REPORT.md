# Graph Report - mobile  (2026-09-19)

## Corpus Check
- 94 files · ~124,238 words
- Verdict: corpus is large enough that graph structure adds value.

## Summary
- 1325 nodes · 1718 edges · 70 communities (54 shown, 11 thin omitted)
- Extraction: 99% EXTRACTED · 1% INFERRED · 0% AMBIGUOUS · INFERRED: 18 edges (avg confidence: 0.85)
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `3bcf5e79`
- Run `git rev-parse HEAD` and compare to check if the graph is stale.
- Run `graphify update .` after code changes (no API cost).

## Community Hubs (Navigation)
- Win32Window
- app_theme.dart
- single_transaction_screen.dart
- notifications_screen.dart
- GeneratedPluginRegistrant.swift
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
- my_application.cc
- payment_repository.dart
- sign_in_screen.dart
- location_service.dart
- home_today_spend_gauge.dart
- fl_chart_widgets_test.dart
- main.dart
- user_profile.dart
- analysis_category_pie_chart.dart
- package:flutter_test/flutter_test.dart
- daily_limit_chart_test.dart
- widget_test.dart
- wWinMain
- token_validator.dart
- ../theme/app_theme.dart
- StatelessWidget
- Animation
- auth_and_api_test.dart
- action_button.dart
- transaction_tile.dart
- payment_methods_screen.dart
- CustomPainter
- package:flutter/foundation.dart
- api_service.dart
- State
- mobile
- setCustomClient
- AppThemeContextExtension
- MaterialPageRoute
- LaunchImage.imageset/README.md
- package:mobile/models/payment_model.dart
- AppThemeData
- bool?
- Rect
- String?
- ScanAndPayScreen
- custom_bottom_nav_bar.dart
- _HomeDashboardScreenState
- package:flutter/material.dart
- ApiException

## God Nodes (most connected - your core abstractions)
1. `Win32Window` - 24 edges
2. `MainActivity` - 13 edges
3. `MessageHandler` - 12 edges
4. `FlutterWindow` - 10 edges
5. `Create` - 10 edges
6. `WndProc` - 10 edges
7. `MessageHandler` - 9 edges
8. `LocalDatabaseService` - 8 edges
9. `_MyApplication` - 7 edges
10. `OnCreate` - 7 edges

## Surprising Connections (you probably didn't know these)
- `wWinMain()` --calls--> `CreateAndAttachConsole()`  [INFERRED]
  windows/runner/main.cpp → windows/runner/utils.cpp
- `Win32Window::Win32Window()` --calls--> `Destroy`  [INFERRED]
  windows/runner/win32_window.cpp → windows/runner/win32_window.h
- `my_application_activate()` --calls--> `fl_register_plugins()`  [INFERRED]
  linux/runner/my_application.cc → linux/flutter/generated_plugin_registrant.cc
- `main()` --calls--> `my_application_new()`  [INFERRED]
  linux/runner/main.cc → linux/runner/my_application.cc
- `OnCreate` --calls--> `RegisterPlugins()`  [INFERRED]
  windows/runner/flutter_window.h → windows/flutter/generated_plugin_registrant.cc

## Import Cycles
- None detected.

## Communities (70 total, 11 thin omitted)

### Community 0 - "Win32Window"
Cohesion: 0.05
Nodes (57): PluginRegistry, unique_ptr, RegisterPlugins(), DartProject, HWND, LPARAM, LRESULT, UINT (+49 more)

### Community 1 - "app_theme.dart"
Cohesion: 0.03
Nodes (61): AppThemeData get, Brightness, ColorScheme get, accent, AppRadii, AppSpacing, AppThemeManager, background (+53 more)

### Community 2 - "single_transaction_screen.dart"
Cohesion: 0.04
Nodes (48): DraggableScrollableNotification, GoogleMapController?, _accuracy, build, _buildActionButton, _buildDarkMapFallbackCanvas, _buildDetailRow, _buildDetailsCard (+40 more)

### Community 3 - "notifications_screen.dart"
Cohesion: 0.10
Nodes (19): _budgetExceededWarnings, build, _buildAppBar, _buildDevNoticeBanner, _buildInboxTab, _buildNotificationCard, _buildPreferencesTab, _buildSwitchTile (+11 more)

### Community 4 - "GeneratedPluginRegistrant.swift"
Cohesion: 0.05
Nodes (32): Any, app_links, Cocoa, Flutter, FlutterAppDelegate, FlutterImplicitEngineBridge, FlutterImplicitEngineDelegate, FlutterMacOS (+24 more)

### Community 5 - "upi_service.dart"
Cohesion: 0.04
Nodes (43): double?, appVersion, build, _buildAppBar, _buildCreatorSection, _buildEnvironmentNoticeCard, _buildFeatureHighlights, _buildFeatureItem (+35 more)

### Community 6 - "scan_and_pay_screen.dart"
Cohesion: 0.06
Nodes (35): DateTime?, build, cornerColor, cornerLength, cornerRadius, createState, cutoutRect, dispose (+27 more)

### Community 7 - "home_spend_trend_line_chart.dart"
Cohesion: 0.05
Nodes (41): amount, _bottomTitleWidgets, build, _buildCardFooter, _buildCardHeader, _buildCurvedGradientData, _buildDualZoneData, _calculateMaxY (+33 more)

### Community 8 - "local_database_service.dart"
Cohesion: 0.05
Nodes (39): Database?, cleanupStalePayments, clearAll, clearPayments, clearUserProfile, close, _db, dbName (+31 more)

### Community 9 - "upi_payment_service.dart"
Cohesion: 0.05
Nodes (39): allApps, amazon, amazonPay, appNotInstalled, askEveryTime, bhim, bhimApp, buildSafeUpiUri (+31 more)

### Community 10 - "google_pay_service.dart"
Cohesion: 0.05
Nodes (37): amazonPayPackage, amount, approvalRefNo, _channel, errorMessage, fromNativeMap, fromQueryString, googlePayPackage (+29 more)

### Community 11 - "chart_colors.dart"
Cohesion: 0.06
Nodes (33): app_theme.dart, financialKeywords, isFinancialTransactionSms, SmsFilterService, allPalettes, amber, AppChartColors, barDefault (+25 more)

### Community 12 - "home_dashboard_screen.dart"
Cohesion: 0.06
Nodes (33): AnimationController, _applyData, build, _buildAvatarFallback, _buildBody, _buildDashboardContent, _buildQuickActions, _buildTotalSpentCard (+25 more)

### Community 13 - "expense_model.dart"
Cohesion: 0.06
Nodes (29): category_model.dart, CategoryModel, color, fromJson, icon, id, isDefault, name (+21 more)

### Community 14 - "api_client.dart"
Cohesion: 0.06
Nodes (31): auth_service.dart, dart:io, Dio, int?, createCategory, createExpense, createPayment, data (+23 more)

### Community 15 - "dashboard_data.dart"
Cohesion: 0.06
Nodes (30): amount, avatarUrl, category, CategorySpendingItem, changePercent, changePeriodLabel, color, DashboardData (+22 more)

### Community 16 - "settings_screen.dart"
Cohesion: 0.06
Nodes (31): about_hulypay_screen.dart, help_support_screen.dart, appVersion, _avatarUrl, build, _buildChartPaletteOptionCard, _buildGroupCard, _buildLogoutCard (+23 more)

### Community 17 - "MainActivity"
Cohesion: 0.11
Nodes (18): MainActivity, BroadcastReceiver, Context, FlutterActivity, FlutterEngine, IntArray, Intent, MethodChannel (+10 more)

### Community 18 - "splash_screen.dart"
Cohesion: 0.05
Nodes (38): dart:ui, Duration, animation, build, _controller, createState, dispose, _drawBlades (+30 more)

### Community 19 - "user_preferences_service.dart"
Cohesion: 0.06
Nodes (30): double? get, _cachedAnalysisPeriod, _cachedDailyLimit, _cachedDefaultPaymentApp, _cachedQuickConfirm, _client, _customClient, getAnalysisPeriod (+22 more)

### Community 20 - "payment_model.dart"
Cohesion: 0.07
Nodes (27): dashboard_data.dart, amount, copyWith, createdAt, CreatePaymentPayload, currency, expenseId, fromJson (+19 more)

### Community 21 - "analysis_screen.dart"
Cohesion: 0.08
Nodes (25): _allPayments, build, _buildCategoryList, _buildHeader, _categories, createState, didUpdateWidget, _filterAndRecalculate (+17 more)

### Community 22 - "spending_heatmap.dart"
Cohesion: 0.07
Nodes (27): build, _buildFooter, _buildGrid, _buildHeader, cells, columns, _computePeriodTotal, createState (+19 more)

### Community 23 - "transactions_screen.dart"
Cohesion: 0.08
Nodes (24): analysis_screen.dart, home_dashboard_screen.dart, _allGroups, build, _buildFilterChips, _buildGroupedTransactions, _buildHeader, _buildSearchBar (+16 more)

### Community 24 - "auth_service.dart"
Cohesion: 0.07
Nodes (26): dart:async, AuthService, client, currentAccessToken, currentSession, currentUser, hasValidActiveToken, initialize (+18 more)

### Community 25 - "my_application.cc"
Cohesion: 0.09
Nodes (22): FlPluginRegistry, FlView, GApplication, gboolean, gchar, GObject, GtkApplication, fl_register_plugins() (+14 more)

### Community 26 - "payment_repository.dart"
Cohesion: 0.08
Nodes (25): _apiClient, cleanupStalePayments, createPayment, getCachedPayments, getPaymentById, getPayments, _instance, _localDb (+17 more)

### Community 27 - "sign_in_screen.dart"
Cohesion: 0.08
Nodes (25): _authSubscription, _authTimeoutTimer, build, createState, didChangeAppLifecycleState, dispose, _finishSignIn, _handleGitHubSignIn (+17 more)

### Community 28 - "location_service.dart"
Cohesion: 0.09
Nodes (22): bool get, accuracyMeters, errorMessage, failure, failureReason, getCurrentPaymentLocation, getPaymentLocationWithStatus, _instance (+14 more)

### Community 29 - "home_today_spend_gauge.dart"
Cohesion: 0.10
Nodes (21): Color, dart:math, activeColor, build, _buildZoneIndicator, _computeTodaySpend, createState, _customLimit (+13 more)

### Community 30 - "fl_chart_widgets_test.dart"
Cohesion: 0.14
Nodes (13): BarChart, package:fl_chart/fl_chart.dart, package:mobile/screens/settings_screen.dart, package:mobile/theme/app_theme.dart, package:mobile/theme/chart_colors.dart, package:mobile/widgets/analysis_category_pie_chart.dart, package:mobile/widgets/home_spend_trend_line_chart.dart, package:mobile/widgets/home_weekly_bar_chart.dart (+5 more)

### Community 31 - "main.dart"
Cohesion: 0.14
Nodes (13): build, home, initializeAuth, isAuthenticated, main, nextScreen, showSplash, widgetsBinding (+5 more)

### Community 32 - "user_profile.dart"
Cohesion: 0.14
Nodes (13): active, authProvider, avatarUrl, copyWith, email, firstName, fromJson, fullName (+5 more)

### Community 33 - "analysis_category_pie_chart.dart"
Cohesion: 0.15
Nodes (13): AnalysisCategoryPieChart, _AnalysisCategoryPieChartState, build, centerLabel, createState, items, showCardBackground, _showingSections (+5 more)

### Community 34 - "package:flutter_test/flutter_test.dart"
Cohesion: 0.15
Nodes (11): package:flutter_test/flutter_test.dart, package:mobile/models/category_model.dart, package:mobile/models/expense_model.dart, package:mobile/screens/scan_and_pay_screen.dart, package:mobile/services/location_service.dart, package:mobile/services/sms_filter_service.dart, package:mobile/services/upi_payment_service.dart, package:mobile/services/upi_service.dart (+3 more)

### Community 35 - "daily_limit_chart_test.dart"
Cohesion: 0.15
Nodes (14): LocalDatabaseService, UserPreferencesService, package:mobile/services/local_database_service.dart, package:mobile/services/user_preferences_service.dart, package:mobile/widgets/home_today_spend_gauge.dart, package:sqflite_common_ffi/sqflite_ffi.dart, dbService, main (+6 more)

### Community 36 - "widget_test.dart"
Cohesion: 0.15
Nodes (14): package:mobile/main.dart, package:mobile/repositories/payment_repository.dart, package:mobile/repositories/user_repository.dart, package:mobile/screens/analysis_screen.dart, package:mobile/screens/home_dashboard_screen.dart, package:mobile/screens/transactions_screen.dart, package:mobile/widgets/action_button.dart, package:mobile/widgets/custom_bottom_nav_bar.dart (+6 more)

### Community 37 - "wWinMain"
Cohesion: 0.24
Nodes (9): _In_, _In_opt_, vector, wWinMain(), string, wchar_t, CreateAndAttachConsole(), GetCommandLineArguments() (+1 more)

### Community 39 - "token_validator.dart"
Cohesion: 0.18
Nodes (9): dart:convert, getEmail, getExpirationDate, getPayload, getSubject, isExpired, TokenValidator, package:mobile/services/token_validator.dart (+1 more)

### Community 40 - "../theme/app_theme.dart"
Cohesion: 0.20
Nodes (9): build, _buildAppBar, _buildBulletPoint, _buildDataCollectionCard, _buildDevelopmentPrivacyNotice, _buildProtocolItem, _buildSecurityBanner, _buildSecurityProtocolsCard (+1 more)

### Community 41 - "StatelessWidget"
Cohesion: 0.25
Nodes (8): HulyPayApp, AboutHulyPayScreen, PrivacySecurityScreen, AnimatedHulyLogo, AnimatedWaveBackground, _HeatmapGridWidget, TransactionTile, StatelessWidget

### Community 43 - "auth_and_api_test.dart"
Cohesion: 0.29
Nodes (6): AuthException, package:mobile/screens/sign_in_screen.dart, package:mobile/services/api_client.dart, package:mobile/services/auth_service.dart, package:supabase_flutter/supabase_flutter.dart, main

### Community 44 - "action_button.dart"
Cohesion: 0.22
Nodes (8): IconData?, build, icon, label, onTap, QuickActionButton, svgAsset, VoidCallback?

### Community 45 - "transaction_tile.dart"
Cohesion: 0.25
Nodes (7): TransactionItem, PaymentModel, onTap, payment, transaction, ../models/payment_model.dart, ../screens/single_transaction_screen.dart

### Community 46 - "payment_methods_screen.dart"
Cohesion: 0.12
Nodes (17): build, _buildAppBar, _buildInstalledAppsList, _buildPaymentAppCard, _buildSectionTitle, createState, initState, _installedStatus (+9 more)

### Community 47 - "CustomPainter"
Cohesion: 0.29
Nodes (7): CustomPainter, ScannerFramePainter, ScannerOverlayPainter, _MapGridPainter, LogoStrokePainter, WaveSilkPainter, _SpeedometerGaugePainter

### Community 48 - "package:flutter/foundation.dart"
Cohesion: 0.40
Nodes (4): package:flutter/foundation.dart, package:flutter/services.dart, package:mobile/services/google_pay_service.dart, main

### Community 49 - "api_service.dart"
Cohesion: 0.18
Nodes (10): api_client.dart, ApiService, baseUrl, client, fetchUserProfile, getCurrentUser, ../models/user_profile.dart, package:http/http.dart (+2 more)

### Community 50 - "State"
Cohesion: 0.19
Nodes (15): AnalysisScreen, _AnalysisScreenState, HelpSupportScreen, _HelpSupportScreenState, NotificationsScreen, _NotificationsScreenState, SingleTransactionScreen, _SingleTransactionScreenState (+7 more)

### Community 54 - "MaterialPageRoute"
Cohesion: 0.22
Nodes (9): _buildHeader, _showPaymentConfirmationModal, _startSmsVerificationWorkflow, _buildAccountSection, _buildPreferencesSection, _buildSupportSection, _openScanAndPay, build (+1 more)

### Community 56 - "package:mobile/models/payment_model.dart"
Cohesion: 0.25
Nodes (7): package:mobile/models/dashboard_data.dart, package:mobile/models/payment_model.dart, package:mobile/models/user_profile.dart, package:mobile/screens/single_transaction_screen.dart, package:mobile/widgets/transaction_tile.dart, main, main

### Community 66 - "custom_bottom_nav_bar.dart"
Cohesion: 0.25
Nodes (7): build, _buildNavItem, CustomBottomNavBar, onItemSelected, selectedIndex, package:flutter_svg/flutter_svg.dart, ValueChanged

### Community 67 - "_HomeDashboardScreenState"
Cohesion: 0.67
Nodes (3): HomeDashboardScreen, _HomeDashboardScreenState, TickerProviderStateMixin

### Community 68 - "package:flutter/material.dart"
Cohesion: 0.50
Nodes (3): package:flutter/material.dart, package:mobile/screens/splash_screen.dart, main

## Knowledge Gaps
- **844 isolated node(s):** `widgetsBinding`, `showSplash`, `home`, `initializeAuth`, `nextScreen` (+839 more)
  These have ≤1 connection - possible missing edges or undocumented components. (Counts symbols only; 1000 node(s) total have ≤1 connection when file, concept and rationale nodes are included.)
- **11 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `LocalDatabaseService` connect `daily_limit_chart_test.dart` to `local_database_service.dart`, `payment_repository.dart`, `widget_test.dart`?**
  _High betweenness centrality (0.010) - this node is a cross-community bridge._
- **What connects `widgetsBinding`, `showSplash`, `home` to the rest of the system?**
  _844 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `Win32Window` be split into smaller, more focused modules?**
  _Cohesion score 0.05311676909569798 - nodes in this community are weakly interconnected._
- **Should `app_theme.dart` be split into smaller, more focused modules?**
  _Cohesion score 0.03225806451612903 - nodes in this community are weakly interconnected._
- **Should `single_transaction_screen.dart` be split into smaller, more focused modules?**
  _Cohesion score 0.04081632653061224 - nodes in this community are weakly interconnected._
- **Should `notifications_screen.dart` be split into smaller, more focused modules?**
  _Cohesion score 0.1 - nodes in this community are weakly interconnected._
- **Should `GeneratedPluginRegistrant.swift` be split into smaller, more focused modules?**
  _Cohesion score 0.05217391304347826 - nodes in this community are weakly interconnected._