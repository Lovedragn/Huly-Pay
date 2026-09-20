# Graph Report - Huly.pay  (2026-09-19)

## Corpus Check
- 158 files · ~144,082 words
- Verdict: corpus is large enough that graph structure adds value.

## Summary
- 1711 nodes · 2810 edges · 126 communities (73 shown, 44 thin omitted)
- Extraction: 97% EXTRACTED · 3% INFERRED · 0% AMBIGUOUS · INFERRED: 94 edges (avg confidence: 0.81)
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `2326d6a9`
- Run `git rev-parse HEAD` and compare to check if the graph is stale.
- Run `graphify update .` after code changes (no API cost).

## Community Hubs (Navigation)
- home_spend_trend_line_chart.dart
- location_service.dart
- upi_service.dart
- dashboard_data.dart
- upi_payment_service.dart
- GeneratedPluginRegistrant.swift
- local_database_service.dart
- my_application.cc
- home_dashboard_screen.dart
- settings_screen.dart
- transactions_screen.dart
- payment_model.dart
- lombok.AllArgsConstructor
- analysis_screen.dart
- user_preferences_service.dart
- scan_and_pay_screen.dart
- Win32Window
- org.junit.jupiter.api.Test
- SecurityConfig.java
- wWinMain
- single_transaction_screen.dart
- ErrorResponse
- splash_screen.dart
- expense_model.dart
- api_client.dart
- MainActivity
- Docker Compose Configuration
- mvnw
- sign_in_screen.dart
- package:flutter/foundation.dart
- Application Configuration
- chart_colors.dart
- Rect
- main.dart
- Payment
- user_profile.dart
- State
- Flutter Pubspec
- auth_service.dart
- AppThemeContextExtension
- PaymentStatus
- Linux Project CMakeLists
- Web Index HTML
- Windows Project CMakeLists
- lombok.RequiredArgsConstructor
- iOS Launch Image
- StatelessWidget
- AppThemeData
- payment_methods_screen.dart
- notifications_screen.dart
- action_button.dart
- org.springframework.web.bind.annotation.GetMapping
- Mobile Analysis Options
- App Icon (1024x1024)
- App Icon (20x20 @1x)
- App Icon (20x20 @2x)
- App Icon (20x20 @3x)
- App Icon (29x29 @1x)
- App Icon (29x29 @2x)
- App Icon (29x29 @3x)
- App Icon (40x40 @1x)
- App Icon (40x40 @2x)
- App Icon (40x40 @3x)
- App Icon (60x60 @2x)
- App Icon (60x60 @3x)
- App Icon (76x76 @1x)
- App Icon (76x76 @2x)
- iOS App Icon (83.5x83.5@2x)
- iOS Launch Image (@2x)
- iOS Launch Image (@3x)
- macOS App Icon (128x128)
- macOS App Icon (16x16)
- macOS App Icon (256x256)
- macOS App Icon (1024)
- Flutter Logo (32x32)
- Flutter Logo (512x512)
- Flutter Logo (64x64)
- Mobile App Documentation
- Web Icon (512)
- Web Maskable Icon (192)
- Web Maskable Icon (512)
- com.hulypay:backend
- analysis_category_pie_chart.dart
- app_theme.dart
- rules/graphify.md
- workflows/graphify.md
- String?
- BackendApplication
- help_support_screen.dart
- home_today_spend_gauge.dart
- org.springframework.http.ResponseEntity
- package:flutter/material.dart
- spending_heatmap.dart
- google_pay_service.dart
- about_hulypay_screen.dart
- User
- payment_repository.dart
- Category
- api_service.dart
- CategoryResponse
- home_weekly_bar_chart.dart
- ../theme/app_theme.dart
- custom_bottom_nav_bar.dart
- connection_matrix_test.dart
- bool?
- package:flutter/services.dart
- transaction_tile.dart
- widget_test.dart
- fl_chart_widgets_test.dart
- daily_limit_chart_test.dart
- auth_and_api_test.dart
- package:flutter_test/flutter_test.dart
- ExpenseRepository
- CustomPainter
- setCustomClient
- MaterialPageRoute
- ApiException

## God Nodes (most connected - your core abstractions)
1. `User` - 49 edges
2. `Payment` - 25 edges
3. `Category` - 24 edges
4. `Win32Window` - 24 edges
5. `Expense` - 22 edges
6. `PaymentStatus` - 21 edges
7. `PaymentResponse` - 19 edges
8. `ResourceNotFoundException` - 17 edges
9. `ExpenseResponse` - 17 edges
10. `UserService` - 17 edges

## Surprising Connections (you probably didn't know these)
- `Launch Screen Assets README` --references--> `iOS Launch Image`  [INFERRED]
  mobile/ios/Runner/Assets.xcassets/LaunchImage.imageset/README.md → mobile/ios/Runner/Assets.xcassets/LaunchImage.imageset/LaunchImage.png
- `wWinMain()` --calls--> `CreateAndAttachConsole()`  [INFERRED]
  mobile/windows/runner/main.cpp → mobile/windows/runner/utils.cpp
- `Win32Window::Win32Window()` --calls--> `Destroy`  [INFERRED]
  mobile/windows/runner/win32_window.cpp → mobile/windows/runner/win32_window.h
- `Web Index HTML` --references--> `Web Favicon`  [EXTRACTED]
  mobile/web/index.html → mobile/web/favicon.png
- `Web Index HTML` --references--> `Web Icon (192)`  [EXTRACTED]
  mobile/web/index.html → mobile/web/icons/Icon-192.png

## Import Cycles
- None detected.

## Hyperedges (group relationships)
- **Hulypay App Branding Assets** — mobile_ios_runner_assets_appicon_1024, mobile_macos_runner_assets_appicon_256, mobile_ios_runner_assets_appicon_60_3x [EXTRACTED 1.00]
- **Linux Build Configuration** — mobile_linux_cmakelists, mobile_linux_flutter_cmakelists, mobile_linux_runner_cmakelists [EXTRACTED 1.00]
- **Windows Build Configuration** — mobile_windows_cmakelists, mobile_windows_flutter_cmakelists, mobile_windows_runner_cmakelists [EXTRACTED 1.00]

## Communities (126 total, 44 thin omitted)

### Community 0 - "home_spend_trend_line_chart.dart"
Cohesion: 0.09
Nodes (23): amount, _bottomTitleWidgets, build, _buildCardFooter, _buildCardHeader, _buildCurvedGradientData, _buildDualZoneData, _calculateMaxY (+15 more)

### Community 1 - "location_service.dart"
Cohesion: 0.09
Nodes (22): bool get, accuracyMeters, errorMessage, failure, failureReason, getCurrentPaymentLocation, getPaymentLocationWithStatus, _instance (+14 more)

### Community 2 - "upi_service.dart"
Cohesion: 0.11
Nodes (18): double?, amazonPayPackageName, amount, buildPaymentUri, currency, googlePayPackageName, isUpiUri, launchUpiPayment (+10 more)

### Community 3 - "dashboard_data.dart"
Cohesion: 0.06
Nodes (30): amount, avatarUrl, category, CategorySpendingItem, changePercent, changePeriodLabel, color, DashboardData (+22 more)

### Community 4 - "upi_payment_service.dart"
Cohesion: 0.05
Nodes (39): allApps, amazon, amazonPay, appNotInstalled, askEveryTime, bhim, bhimApp, buildSafeUpiUri (+31 more)

### Community 5 - "GeneratedPluginRegistrant.swift"
Cohesion: 0.05
Nodes (32): Any, app_links, Cocoa, Flutter, FlutterAppDelegate, FlutterImplicitEngineBridge, FlutterImplicitEngineDelegate, FlutterMacOS (+24 more)

### Community 6 - "local_database_service.dart"
Cohesion: 0.05
Nodes (39): Database?, cleanupStalePayments, clearAll, clearPayments, clearUserProfile, close, _db, dbName (+31 more)

### Community 7 - "my_application.cc"
Cohesion: 0.09
Nodes (22): FlPluginRegistry, FlView, GApplication, gboolean, gchar, GObject, GtkApplication, fl_register_plugins() (+14 more)

### Community 8 - "home_dashboard_screen.dart"
Cohesion: 0.06
Nodes (34): Animation, AnimationController, _applyData, build, _buildAvatarFallback, _buildBody, _buildDashboardContent, _buildQuickActions (+26 more)

### Community 9 - "settings_screen.dart"
Cohesion: 0.06
Nodes (31): about_hulypay_screen.dart, help_support_screen.dart, appVersion, _avatarUrl, build, _buildChartPaletteOptionCard, _buildGroupCard, _buildLogoutCard (+23 more)

### Community 10 - "transactions_screen.dart"
Cohesion: 0.08
Nodes (26): analysis_screen.dart, _allGroups, build, _buildFilterChips, _buildGroupedTransactions, _buildHeader, _buildSearchBar, createState (+18 more)

### Community 11 - "payment_model.dart"
Cohesion: 0.07
Nodes (27): dashboard_data.dart, amount, copyWith, createdAt, CreatePaymentPayload, currency, expenseId, fromJson (+19 more)

### Community 12 - "lombok.AllArgsConstructor"
Cohesion: 0.23
Nodes (18): CategoryBreakdownResponse, DailySpendingResponse, MonthlySpendingResponse, SpendingSummaryResponse, CreateExpenseRequest, UpdateExpenseRequest, CreatePaymentRequest, ReconcilePaymentRequest (+10 more)

### Community 13 - "analysis_screen.dart"
Cohesion: 0.07
Nodes (27): _allPayments, AnalysisScreen, _AnalysisScreenState, build, _buildCategoryList, _buildHeader, _categories, createState (+19 more)

### Community 14 - "user_preferences_service.dart"
Cohesion: 0.06
Nodes (30): double? get, local_database_service.dart, _cachedAnalysisPeriod, _cachedDailyLimit, _cachedDefaultPaymentApp, _cachedQuickConfirm, _client, _customClient (+22 more)

### Community 15 - "scan_and_pay_screen.dart"
Cohesion: 0.05
Nodes (37): DateTime?, build, cornerColor, cornerLength, cornerRadius, createState, cutoutRect, dispose (+29 more)

### Community 16 - "Win32Window"
Cohesion: 0.05
Nodes (57): RegisterPlugins(), DartProject, HWND, LPARAM, LRESULT, UINT, WPARAM, FlutterWindow (+49 more)

### Community 17 - "org.junit.jupiter.api.Test"
Cohesion: 0.14
Nodes (12): AnalyticsControllerTests, BackendApplicationTests, CategoryControllerTests, ExpenseControllerTests, HealthControllerTests, PaymentControllerTests, SecurityAndUserTests, java.util.Map (+4 more)

### Community 18 - "SecurityConfig.java"
Cohesion: 0.21
Nodes (11): OpenApiConfig, SecurityConfig, io.swagger.v3.oas.models.OpenAPI, JwtDecoder, OpenAPI, org.springframework.context.annotation.Bean, org.springframework.context.annotation.Configuration, org.springframework.security.config.annotation.web.builders.HttpSecurity (+3 more)

### Community 19 - "wWinMain"
Cohesion: 0.24
Nodes (9): _In_, _In_opt_, wWinMain(), string, wchar_t, CreateAndAttachConsole(), GetCommandLineArguments(), Utf8FromUtf16() (+1 more)

### Community 20 - "single_transaction_screen.dart"
Cohesion: 0.04
Nodes (48): DraggableScrollableNotification, GoogleMapController?, MapType, _accuracy, build, _buildActionButton, _buildDarkMapFallbackCanvas, _buildDetailRow (+40 more)

### Community 21 - "ErrorResponse"
Cohesion: 0.19
Nodes (12): ErrorResponse, GlobalExceptionHandler, com.fasterxml.jackson.annotation.JsonInclude, NoResourceFoundException, org.springframework.dao.DataIntegrityViolationException, org.springframework.security.access.AccessDeniedException, org.springframework.security.core.AuthenticationException, org.springframework.web.bind.annotation.ExceptionHandler (+4 more)

### Community 22 - "splash_screen.dart"
Cohesion: 0.06
Nodes (33): Duration, animation, _BladeDefinition, _blades, build, calculateOpacity, _controller, createState (+25 more)

### Community 23 - "expense_model.dart"
Cohesion: 0.06
Nodes (29): category_model.dart, CategoryModel, color, fromJson, icon, id, isDefault, name (+21 more)

### Community 24 - "api_client.dart"
Cohesion: 0.06
Nodes (31): auth_service.dart, dart:io, Dio, int?, createCategory, createExpense, createPayment, data (+23 more)

### Community 25 - "MainActivity"
Cohesion: 0.11
Nodes (18): Context, FlutterActivity, FlutterEngine, IntArray, Intent, MethodChannel, MainActivity, BroadcastReceiver (+10 more)

### Community 27 - "mvnw"
Cohesion: 0.38
Nodes (8): mvnw script, clean(), die(), exec_maven(), hash_string(), set_java_home(), trim(), verbose()

### Community 28 - "sign_in_screen.dart"
Cohesion: 0.09
Nodes (22): home_dashboard_screen.dart, _authSubscription, _authTimeoutTimer, build, createState, didChangeAppLifecycleState, dispose, _finishSignIn (+14 more)

### Community 29 - "package:flutter/foundation.dart"
Cohesion: 0.17
Nodes (10): dart:convert, getEmail, getExpirationDate, getPayload, getSubject, isExpired, TokenValidator, main (+2 more)

### Community 31 - "chart_colors.dart"
Cohesion: 0.06
Nodes (33): app_theme.dart, financialKeywords, isFinancialTransactionSms, SmsFilterService, allPalettes, amber, AppChartColors, barDefault (+25 more)

### Community 33 - "main.dart"
Cohesion: 0.14
Nodes (13): build, home, initializeAuth, isAuthenticated, main, nextScreen, showSplash, widgetsBinding (+5 more)

### Community 34 - "Payment"
Cohesion: 0.13
Nodes (13): AllArgsConstructor, Builder, Entity, Getter, NoArgsConstructor, Setter, Table, Payment (+5 more)

### Community 35 - "user_profile.dart"
Cohesion: 0.14
Nodes (13): active, authProvider, avatarUrl, copyWith, email, firstName, fromJson, fullName (+5 more)

### Community 36 - "State"
Cohesion: 0.15
Nodes (19): HelpSupportScreen, _HelpSupportScreenState, HomeDashboardScreen, _HomeDashboardScreenState, NotificationsScreen, _NotificationsScreenState, SignInScreen, _SignInScreenState (+11 more)

### Community 38 - "auth_service.dart"
Cohesion: 0.07
Nodes (26): dart:async, AuthService, client, currentAccessToken, currentSession, currentUser, hasValidActiveToken, initialize (+18 more)

### Community 40 - "PaymentStatus"
Cohesion: 0.14
Nodes (12): PaymentStatus, CANCELLED, CONFIRMED, FAILED, INITIATED, PAYMENT_INITIATED, PENDING, SUCCESS (+4 more)

### Community 41 - "Linux Project CMakeLists"
Cohesion: 1.00
Nodes (3): Linux Project CMakeLists, Linux Flutter CMakeLists, Linux Runner CMakeLists

### Community 42 - "Web Index HTML"
Cohesion: 0.67
Nodes (3): Web Favicon, Web Icon (192), Web Index HTML

### Community 43 - "Windows Project CMakeLists"
Cohesion: 1.00
Nodes (3): Windows Project CMakeLists, Windows Flutter CMakeLists, Windows Runner CMakeLists

### Community 44 - "lombok.RequiredArgsConstructor"
Cohesion: 0.21
Nodes (16): AnalyticsController, AnalyticsService, CategoryController, RequestMapping, RestController, CategoryService, ExpenseController, RequestMapping (+8 more)

### Community 47 - "StatelessWidget"
Cohesion: 0.25
Nodes (8): HulyPayApp, AboutHulyPayScreen, PrivacySecurityScreen, AnimatedHulyLogo, AnimatedWaveBackground, _HeatmapGridWidget, TransactionTile, StatelessWidget

### Community 51 - "payment_methods_screen.dart"
Cohesion: 0.12
Nodes (17): Map, build, _buildAppBar, _buildInstalledAppsList, _buildPaymentAppCard, _buildSectionTitle, createState, initState (+9 more)

### Community 53 - "notifications_screen.dart"
Cohesion: 0.10
Nodes (19): _budgetExceededWarnings, build, _buildAppBar, _buildDevNoticeBanner, _buildInboxTab, _buildNotificationCard, _buildPreferencesTab, _buildSwitchTile (+11 more)

### Community 54 - "action_button.dart"
Cohesion: 0.22
Nodes (8): IconData?, build, icon, label, onTap, QuickActionButton, svgAsset, VoidCallback?

### Community 55 - "org.springframework.web.bind.annotation.GetMapping"
Cohesion: 0.28
Nodes (7): DatabaseHealthController, DatabaseHealthResponse, HealthController, HealthResponse, javax.sql.DataSource, org.springframework.web.bind.annotation.GetMapping, org.springframework.web.bind.annotation.RestController

### Community 90 - "analysis_category_pie_chart.dart"
Cohesion: 0.15
Nodes (13): List, AnalysisCategoryPieChart, _AnalysisCategoryPieChartState, build, centerLabel, createState, items, showCardBackground (+5 more)

### Community 91 - "app_theme.dart"
Cohesion: 0.03
Nodes (61): AppThemeData get, Brightness, ColorScheme get, accent, AppRadii, AppSpacing, AppThemeManager, background (+53 more)

### Community 96 - "help_support_screen.dart"
Cohesion: 0.14
Nodes (13): build, _buildAppBar, _buildDeveloperWebsiteCard, _buildEmailContactCard, _buildFaqItem, _buildFaqSection, _copyToClipboard, createState (+5 more)

### Community 97 - "home_today_spend_gauge.dart"
Cohesion: 0.10
Nodes (19): Color, dart:math, activeColor, build, _buildZoneIndicator, _computeTodaySpend, createState, _customLimit (+11 more)

### Community 98 - "org.springframework.http.ResponseEntity"
Cohesion: 0.11
Nodes (18): DeleteMapping, PutMapping, DeleteMapping, PostMapping, PutMapping, GetMapping, PostMapping, PutMapping (+10 more)

### Community 99 - "package:flutter/material.dart"
Cohesion: 0.50
Nodes (3): main, package:flutter/material.dart, package:mobile/screens/splash_screen.dart

### Community 100 - "spending_heatmap.dart"
Cohesion: 0.07
Nodes (27): build, _buildFooter, _buildGrid, _buildHeader, cells, columns, _computePeriodTotal, createState (+19 more)

### Community 102 - "google_pay_service.dart"
Cohesion: 0.05
Nodes (37): amazonPayPackage, amount, approvalRefNo, _channel, errorMessage, fromNativeMap, fromQueryString, googlePayPackage (+29 more)

### Community 103 - "about_hulypay_screen.dart"
Cohesion: 0.15
Nodes (12): appVersion, build, _buildAppBar, _buildCreatorSection, _buildEnvironmentNoticeCard, _buildFeatureHighlights, _buildFeatureItem, _buildHeroBrandCard (+4 more)

### Community 104 - "User"
Cohesion: 0.08
Nodes (26): BadRequestException, ResourceNotFoundException, ExpenseResponse, Expense, AllArgsConstructor, Builder, Entity, Getter (+18 more)

### Community 105 - "payment_repository.dart"
Cohesion: 0.08
Nodes (25): _apiClient, cleanupStalePayments, createPayment, getCachedPayments, getPaymentById, getPayments, _instance, _localDb (+17 more)

### Community 106 - "Category"
Cohesion: 0.15
Nodes (9): Category, AllArgsConstructor, Builder, Entity, Getter, NoArgsConstructor, Setter, Table (+1 more)

### Community 107 - "api_service.dart"
Cohesion: 0.18
Nodes (10): api_client.dart, ApiService, baseUrl, client, fetchUserProfile, getCurrentUser, ../models/user_profile.dart, package:http/http.dart (+2 more)

### Community 108 - "CategoryResponse"
Cohesion: 0.33
Nodes (4): GetMapping, PostMapping, CategoryRequest, CategoryResponse

### Community 109 - "home_weekly_bar_chart.dart"
Cohesion: 0.11
Nodes (18): build, _buildBarChartData, _buildLegendItem, _calculateMax, _computeWeeklyData, createState, _defaultBarColor, _getBottomTitles (+10 more)

### Community 110 - "../theme/app_theme.dart"
Cohesion: 0.20
Nodes (9): build, _buildAppBar, _buildBulletPoint, _buildDataCollectionCard, _buildDevelopmentPrivacyNotice, _buildProtocolItem, _buildSecurityBanner, _buildSecurityProtocolsCard (+1 more)

### Community 111 - "custom_bottom_nav_bar.dart"
Cohesion: 0.25
Nodes (7): build, _buildNavItem, CustomBottomNavBar, onItemSelected, selectedIndex, package:flutter_svg/flutter_svg.dart, ValueChanged

### Community 112 - "connection_matrix_test.dart"
Cohesion: 0.25
Nodes (7): main, main, package:mobile/models/dashboard_data.dart, package:mobile/models/payment_model.dart, package:mobile/models/user_profile.dart, package:mobile/screens/single_transaction_screen.dart, package:mobile/widgets/transaction_tile.dart

### Community 114 - "package:flutter/services.dart"
Cohesion: 0.50
Nodes (3): main, package:flutter/services.dart, package:mobile/services/google_pay_service.dart

### Community 115 - "transaction_tile.dart"
Cohesion: 0.25
Nodes (7): TransactionItem, PaymentModel, onTap, payment, transaction, ../models/payment_model.dart, ../screens/single_transaction_screen.dart

### Community 116 - "widget_test.dart"
Cohesion: 0.15
Nodes (14): dbService, main, dbService, main, emptyDashboard, main, package:mobile/main.dart, package:mobile/repositories/payment_repository.dart (+6 more)

### Community 117 - "fl_chart_widgets_test.dart"
Cohesion: 0.14
Nodes (13): BarChart, main, samplePayments, main, package:fl_chart/fl_chart.dart, package:mobile/screens/settings_screen.dart, package:mobile/theme/app_theme.dart, package:mobile/theme/chart_colors.dart (+5 more)

### Community 118 - "daily_limit_chart_test.dart"
Cohesion: 0.15
Nodes (14): LocalDatabaseService, UserPreferencesService, dbService, main, dbService, main, prefService, dbService (+6 more)

### Community 119 - "auth_and_api_test.dart"
Cohesion: 0.29
Nodes (6): AuthException, main, package:mobile/screens/sign_in_screen.dart, package:mobile/services/api_client.dart, package:mobile/services/auth_service.dart, package:supabase_flutter/supabase_flutter.dart

### Community 121 - "package:flutter_test/flutter_test.dart"
Cohesion: 0.15
Nodes (11): main, main, main, package:flutter_test/flutter_test.dart, package:mobile/models/category_model.dart, package:mobile/models/expense_model.dart, package:mobile/screens/scan_and_pay_screen.dart, package:mobile/services/location_service.dart (+3 more)

### Community 123 - "ExpenseRepository"
Cohesion: 0.25
Nodes (5): ExpenseRepository, UserRepository, org.springframework.data.jpa.repository.JpaRepository, org.springframework.data.jpa.repository.Query, org.springframework.stereotype.Repository

### Community 125 - "CustomPainter"
Cohesion: 0.33
Nodes (6): CustomPainter, ScannerFramePainter, ScannerOverlayPainter, _MapGridPainter, WaveSilkPainter, _SpeedometerGaugePainter

### Community 127 - "MaterialPageRoute"
Cohesion: 0.22
Nodes (9): MaterialPageRoute, _buildHeader, _showPaymentConfirmationModal, _startSmsVerificationWorkflow, _buildAccountSection, _buildPreferencesSection, _buildSupportSection, _openScanAndPay (+1 more)

## Knowledge Gaps
- **891 isolated node(s):** `com.hulypay:backend`, `INITIATED`, `PAYMENT_INITIATED`, `PENDING`, `CONFIRMED` (+886 more)
  These have ≤1 connection - possible missing edges or undocumented components. (Counts symbols only; 1100 node(s) total have ≤1 connection when file, concept and rationale nodes are included.)
- **44 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `LocalDatabaseService` connect `daily_limit_chart_test.dart` to `payment_repository.dart`, `widget_test.dart`, `local_database_service.dart`?**
  _High betweenness centrality (0.008) - this node is a cross-community bridge._
- **Why does `User` connect `User` to `Payment`, `org.springframework.http.ResponseEntity`, `Category`, `CategoryResponse`, `lombok.RequiredArgsConstructor`, `lombok.AllArgsConstructor`, `org.junit.jupiter.api.Test`, `ExpenseRepository`?**
  _High betweenness centrality (0.008) - this node is a cross-community bridge._
- **Why does `PaymentStatus` connect `PaymentStatus` to `User`, `Payment`, `lombok.AllArgsConstructor`?**
  _High betweenness centrality (0.005) - this node is a cross-community bridge._
- **What connects `com.hulypay:backend`, `INITIATED`, `PAYMENT_INITIATED` to the rest of the system?**
  _891 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `home_spend_trend_line_chart.dart` be split into smaller, more focused modules?**
  _Cohesion score 0.08695652173913043 - nodes in this community are weakly interconnected._
- **Should `location_service.dart` be split into smaller, more focused modules?**
  _Cohesion score 0.08695652173913043 - nodes in this community are weakly interconnected._
- **Should `upi_service.dart` be split into smaller, more focused modules?**
  _Cohesion score 0.10526315789473684 - nodes in this community are weakly interconnected._