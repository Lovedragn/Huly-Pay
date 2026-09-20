# Graph Report - Huly.pay  (2026-09-17)

## Corpus Check
- 155 files · ~205,686 words
- Verdict: corpus is large enough that graph structure adds value.

## Summary
- 1693 nodes · 2777 edges · 131 communities (75 shown, 48 thin omitted)
- Extraction: 97% EXTRACTED · 3% INFERRED · 0% AMBIGUOUS · INFERRED: 96 edges (avg confidence: 0.81)
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `02228916`
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
- lombok.RequiredArgsConstructor
- SecurityConfig.java
- wWinMain
- single_transaction_screen.dart
- local_database_service_test.dart
- splash_screen.dart
- expense_model.dart
- api_client.dart
- MainActivity
- Docker Compose Configuration
- mvnw
- sign_in_screen.dart
- token_validator.dart
- Application Configuration
- chart_colors.dart
- Home Dashboard UI
- main.dart
- Scan and Pay UI
- user_profile.dart
- State
- Flutter Pubspec
- auth_service.dart
- AppThemeContextExtension
- Transactions List UI Screenshot
- Linux Project CMakeLists
- Web Index HTML
- Windows Project CMakeLists
- Spending Analysis UI
- iOS Launch Image
- Expense
- AppThemeData
- payment_methods_screen.dart
- notifications_screen.dart
- ../theme/app_theme.dart
- DatabaseHealthController
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
- user_repository.dart
- spending_heatmap.dart
- ErrorResponse
- google_pay_service.dart
- about_hulypay_screen.dart
- org.springframework.transaction.annotation.Transactional
- payment_repository.dart
- org.junit.jupiter.api.Test
- api_service.dart
- CategoryResponse
- home_weekly_bar_chart.dart
- privacy_security_screen.dart
- ScanAndPayScreen
- User
- bool?
- package:flutter/foundation.dart
- transaction_tile.dart
- widget_test.dart
- fl_chart_widgets_test.dart
- daily_limit_chart_test.dart
- auth_and_api_test.dart
- package:flutter/material.dart
- package:flutter_test/flutter_test.dart
- StatelessWidget
- ExpenseRepository
- PaymentService.java
- CustomPainter
- setCustomClient
- MaterialPageRoute
- _HomeDashboardScreenState
- ApiException
- SingleTransactionScreen

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
- **Hulypay Mobile UI Design** — mobile_design_setting, mobile_design_single_transaction, mobile_design_transactions [EXTRACTED 1.00]
- **Linux Build Configuration** — mobile_linux_cmakelists, mobile_linux_flutter_cmakelists, mobile_linux_runner_cmakelists [EXTRACTED 1.00]
- **Windows Build Configuration** — mobile_windows_cmakelists, mobile_windows_flutter_cmakelists, mobile_windows_runner_cmakelists [EXTRACTED 1.00]

## Communities (131 total, 48 thin omitted)

### Community 0 - "home_spend_trend_line_chart.dart"
Cohesion: 0.09
Nodes (22): amount, _bottomTitleWidgets, build, _buildCardFooter, _buildCardHeader, _buildCurvedGradientData, _buildDualZoneData, _buildStyleTab (+14 more)

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
Nodes (32): _applyData, build, _buildAvatarFallback, _buildBody, _buildDashboardContent, _buildQuickActions, _buildTotalSpentCard, _computeWeeklySpending (+24 more)

### Community 9 - "settings_screen.dart"
Cohesion: 0.07
Nodes (29): about_hulypay_screen.dart, help_support_screen.dart, appVersion, _avatarUrl, build, _buildChartPaletteOptionCard, _buildGroupCard, _buildLogoutCard (+21 more)

### Community 10 - "transactions_screen.dart"
Cohesion: 0.08
Nodes (24): analysis_screen.dart, home_dashboard_screen.dart, _allGroups, build, _buildFilterChips, _buildGroupedTransactions, _buildHeader, _buildSearchBar (+16 more)

### Community 11 - "payment_model.dart"
Cohesion: 0.07
Nodes (27): dashboard_data.dart, amount, copyWith, createdAt, CreatePaymentPayload, currency, expenseId, fromJson (+19 more)

### Community 12 - "lombok.AllArgsConstructor"
Cohesion: 0.13
Nodes (31): CategoryBreakdownResponse, DailySpendingResponse, MonthlySpendingResponse, SpendingSummaryResponse, CategoryRequest, CreateExpenseRequest, UpdateExpenseRequest, CreatePaymentRequest (+23 more)

### Community 13 - "analysis_screen.dart"
Cohesion: 0.08
Nodes (25): _allPayments, build, _buildCategoryList, _buildHeader, _categories, createState, didUpdateWidget, _filterAndRecalculate (+17 more)

### Community 14 - "user_preferences_service.dart"
Cohesion: 0.07
Nodes (27): auth_service.dart, double? get, local_database_service.dart, _cachedAnalysisPeriod, _cachedDailyLimit, _cachedDefaultPaymentApp, _client, _customClient (+19 more)

### Community 15 - "scan_and_pay_screen.dart"
Cohesion: 0.06
Nodes (33): DateTime?, build, cornerColor, cornerLength, cornerRadius, createState, dispose, _handleBack (+25 more)

### Community 16 - "Win32Window"
Cohesion: 0.05
Nodes (57): RegisterPlugins(), DartProject, HWND, LPARAM, LRESULT, UINT, WPARAM, FlutterWindow (+49 more)

### Community 17 - "lombok.RequiredArgsConstructor"
Cohesion: 0.21
Nodes (14): AnalyticsController, CategoryController, RequestMapping, RestController, ExpenseController, RequestMapping, RestController, RequestMapping (+6 more)

### Community 18 - "SecurityConfig.java"
Cohesion: 0.21
Nodes (11): OpenApiConfig, SecurityConfig, io.swagger.v3.oas.models.OpenAPI, JwtDecoder, OpenAPI, org.springframework.context.annotation.Bean, org.springframework.context.annotation.Configuration, org.springframework.security.config.annotation.web.builders.HttpSecurity (+3 more)

### Community 19 - "wWinMain"
Cohesion: 0.24
Nodes (9): _In_, _In_opt_, wWinMain(), string, wchar_t, CreateAndAttachConsole(), GetCommandLineArguments(), Utf8FromUtf16() (+1 more)

### Community 20 - "single_transaction_screen.dart"
Cohesion: 0.04
Nodes (48): DraggableScrollableNotification, GoogleMapController?, MapType, _accuracy, build, _buildActionButton, _buildDarkMapFallbackCanvas, _buildDetailRow (+40 more)

### Community 21 - "local_database_service_test.dart"
Cohesion: 0.40
Nodes (4): dbService, main, package:mobile/repositories/payment_repository.dart, package:mobile/repositories/user_repository.dart

### Community 22 - "splash_screen.dart"
Cohesion: 0.07
Nodes (27): Animation, AnimationController, Duration, animation, build, _controller, createState, dispose (+19 more)

### Community 23 - "expense_model.dart"
Cohesion: 0.06
Nodes (29): category_model.dart, CategoryModel, color, fromJson, icon, id, isDefault, name (+21 more)

### Community 24 - "api_client.dart"
Cohesion: 0.06
Nodes (30): dart:io, Dio, int?, createCategory, createExpense, createPayment, data, defaultAndroidHost (+22 more)

### Community 25 - "MainActivity"
Cohesion: 0.11
Nodes (18): Context, FlutterActivity, FlutterEngine, IntArray, Intent, MethodChannel, MainActivity, BroadcastReceiver (+10 more)

### Community 27 - "mvnw"
Cohesion: 0.38
Nodes (8): mvnw script, clean(), die(), exec_maven(), hash_string(), set_java_home(), trim(), verbose()

### Community 28 - "sign_in_screen.dart"
Cohesion: 0.09
Nodes (22): _authSubscription, _authTimeoutTimer, build, createState, didChangeAppLifecycleState, dispose, _finishSignIn, _handleGitHubSignIn (+14 more)

### Community 29 - "token_validator.dart"
Cohesion: 0.18
Nodes (9): dart:convert, getEmail, getExpirationDate, getPayload, getSubject, isExpired, TokenValidator, main (+1 more)

### Community 31 - "chart_colors.dart"
Cohesion: 0.06
Nodes (33): app_theme.dart, financialKeywords, isFinancialTransactionSms, SmsFilterService, allPalettes, amber, AppChartColors, barDefault (+25 more)

### Community 33 - "main.dart"
Cohesion: 0.14
Nodes (13): build, home, initializeAuth, isAuthenticated, main, nextScreen, showSplash, widgetsBinding (+5 more)

### Community 35 - "user_profile.dart"
Cohesion: 0.14
Nodes (13): active, authProvider, avatarUrl, copyWith, email, firstName, fromJson, fullName (+5 more)

### Community 36 - "State"
Cohesion: 0.19
Nodes (15): AnalysisScreen, _AnalysisScreenState, NotificationsScreen, _NotificationsScreenState, SplashScreen, _SplashScreenState, TransactionsScreen, _TransactionsScreenState (+7 more)

### Community 38 - "auth_service.dart"
Cohesion: 0.07
Nodes (26): dart:async, AuthService, client, currentAccessToken, currentSession, currentUser, hasValidActiveToken, initialize (+18 more)

### Community 40 - "Transactions List UI Screenshot"
Cohesion: 0.67
Nodes (3): Profile & Settings UI Screenshot, Single Transaction Detail UI Screenshot, Transactions List UI Screenshot

### Community 41 - "Linux Project CMakeLists"
Cohesion: 1.00
Nodes (3): Linux Project CMakeLists, Linux Flutter CMakeLists, Linux Runner CMakeLists

### Community 42 - "Web Index HTML"
Cohesion: 0.67
Nodes (3): Web Favicon, Web Icon (192), Web Index HTML

### Community 43 - "Windows Project CMakeLists"
Cohesion: 1.00
Nodes (3): Windows Project CMakeLists, Windows Flutter CMakeLists, Windows Runner CMakeLists

### Community 47 - "Expense"
Cohesion: 0.15
Nodes (10): Expense, AllArgsConstructor, Builder, Entity, Getter, NoArgsConstructor, Setter, Table (+2 more)

### Community 51 - "payment_methods_screen.dart"
Cohesion: 0.11
Nodes (19): Map, build, _buildAmazonPayBrandIcon, _buildAppBar, _buildExternalAppLaunchList, _buildGPayBrandIcon, _buildPaymentAppCard, _buildSectionTitle (+11 more)

### Community 53 - "notifications_screen.dart"
Cohesion: 0.10
Nodes (19): _budgetExceededWarnings, build, _buildAppBar, _buildDevNoticeBanner, _buildInboxTab, _buildNotificationCard, _buildPreferencesTab, _buildSwitchTile (+11 more)

### Community 54 - "../theme/app_theme.dart"
Cohesion: 0.12
Nodes (15): IconData?, build, icon, label, onTap, svgAsset, build, _buildNavItem (+7 more)

### Community 55 - "DatabaseHealthController"
Cohesion: 0.26
Nodes (6): DatabaseHealthController, DatabaseHealthResponse, HealthController, HealthResponse, javax.sql.DataSource, org.springframework.web.bind.annotation.RestController

### Community 90 - "analysis_category_pie_chart.dart"
Cohesion: 0.15
Nodes (13): List, AnalysisCategoryPieChart, _AnalysisCategoryPieChartState, build, centerLabel, createState, items, showCardBackground (+5 more)

### Community 91 - "app_theme.dart"
Cohesion: 0.03
Nodes (61): AppThemeData get, Brightness, ColorScheme get, accent, AppRadii, AppSpacing, AppThemeManager, background (+53 more)

### Community 96 - "help_support_screen.dart"
Cohesion: 0.13
Nodes (15): build, _buildAppBar, _buildDeveloperWebsiteCard, _buildEmailContactCard, _buildFaqItem, _buildFaqSection, _copyToClipboard, createState (+7 more)

### Community 97 - "home_today_spend_gauge.dart"
Cohesion: 0.10
Nodes (21): Color, dart:math, activeColor, build, _buildZoneIndicator, _computeTodaySpend, createState, _customLimit (+13 more)

### Community 98 - "org.springframework.http.ResponseEntity"
Cohesion: 0.14
Nodes (14): DeleteMapping, GetMapping, DeleteMapping, PostMapping, PutMapping, GetMapping, PostMapping, RequestMapping (+6 more)

### Community 99 - "user_repository.dart"
Cohesion: 0.15
Nodes (12): _apiClient, getCachedUserProfile, getUserProfile, _instance, _localDb, saveUserProfile, UserRepository, ApiClient (+4 more)

### Community 100 - "spending_heatmap.dart"
Cohesion: 0.08
Nodes (25): build, _buildFooter, _buildGrid, _buildHeader, cells, columns, _computePeriodTotal, createState (+17 more)

### Community 101 - "ErrorResponse"
Cohesion: 0.19
Nodes (12): ErrorResponse, GlobalExceptionHandler, com.fasterxml.jackson.annotation.JsonInclude, NoResourceFoundException, org.springframework.dao.DataIntegrityViolationException, org.springframework.security.access.AccessDeniedException, org.springframework.security.core.AuthenticationException, org.springframework.web.bind.annotation.ExceptionHandler (+4 more)

### Community 102 - "google_pay_service.dart"
Cohesion: 0.05
Nodes (37): amazonPayPackage, amount, approvalRefNo, _channel, errorMessage, fromNativeMap, fromQueryString, googlePayPackage (+29 more)

### Community 103 - "about_hulypay_screen.dart"
Cohesion: 0.15
Nodes (12): appVersion, build, _buildAppBar, _buildCreatorSection, _buildEnvironmentNoticeCard, _buildFeatureHighlights, _buildFeatureItem, _buildHeroBrandCard (+4 more)

### Community 104 - "org.springframework.transaction.annotation.Transactional"
Cohesion: 0.18
Nodes (8): CategoryService, BadRequestException, ResourceNotFoundException, ExpenseResponse, GetMapping, ExpenseService, org.springframework.transaction.annotation.Transactional, org.springframework.web.bind.annotation.ResponseStatus

### Community 105 - "payment_repository.dart"
Cohesion: 0.14
Nodes (13): _apiClient, cleanupStalePayments, createPayment, getCachedPayments, getPaymentById, getPayments, _instance, _localDb (+5 more)

### Community 106 - "org.junit.jupiter.api.Test"
Cohesion: 0.05
Nodes (35): Category, AllArgsConstructor, Builder, Entity, Getter, NoArgsConstructor, Setter, Table (+27 more)

### Community 107 - "api_service.dart"
Cohesion: 0.18
Nodes (10): api_client.dart, ApiService, baseUrl, client, fetchUserProfile, getCurrentUser, ../models/user_profile.dart, package:http/http.dart (+2 more)

### Community 108 - "CategoryResponse"
Cohesion: 0.39
Nodes (3): PostMapping, PutMapping, CategoryResponse

### Community 109 - "home_weekly_bar_chart.dart"
Cohesion: 0.11
Nodes (18): build, _buildBarChartData, _buildLegendItem, _calculateMax, _computeWeeklyData, createState, _defaultBarColor, _getBottomTitles (+10 more)

### Community 110 - "privacy_security_screen.dart"
Cohesion: 0.20
Nodes (9): build, _buildAppBar, _buildBulletPoint, _buildDataCollectionCard, _buildDevelopmentPrivacyNotice, _buildProtocolItem, _buildSecurityBanner, _buildSecurityProtocolsCard (+1 more)

### Community 112 - "User"
Cohesion: 0.17
Nodes (9): AllArgsConstructor, Builder, Entity, Getter, NoArgsConstructor, Setter, Table, User (+1 more)

### Community 114 - "package:flutter/foundation.dart"
Cohesion: 0.40
Nodes (4): main, package:flutter/foundation.dart, package:flutter/services.dart, package:mobile/services/google_pay_service.dart

### Community 115 - "transaction_tile.dart"
Cohesion: 0.25
Nodes (7): TransactionItem, PaymentModel, onTap, payment, transaction, ../models/payment_model.dart, ../screens/single_transaction_screen.dart

### Community 116 - "widget_test.dart"
Cohesion: 0.18
Nodes (11): dbService, main, emptyDashboard, main, package:mobile/main.dart, package:mobile/screens/analysis_screen.dart, package:mobile/screens/home_dashboard_screen.dart, package:mobile/screens/splash_screen.dart (+3 more)

### Community 117 - "fl_chart_widgets_test.dart"
Cohesion: 0.15
Nodes (12): BarChart, main, samplePayments, main, package:fl_chart/fl_chart.dart, package:mobile/screens/settings_screen.dart, package:mobile/theme/app_theme.dart, package:mobile/theme/chart_colors.dart (+4 more)

### Community 118 - "daily_limit_chart_test.dart"
Cohesion: 0.18
Nodes (11): LocalDatabaseService, UserPreferencesService, dbService, main, dbService, main, prefService, package:mobile/services/local_database_service.dart (+3 more)

### Community 119 - "auth_and_api_test.dart"
Cohesion: 0.25
Nodes (7): AuthException, main, package:mobile/models/user_profile.dart, package:mobile/screens/sign_in_screen.dart, package:mobile/services/api_client.dart, package:mobile/services/auth_service.dart, package:supabase_flutter/supabase_flutter.dart

### Community 120 - "package:flutter/material.dart"
Cohesion: 0.28
Nodes (7): main, main, package:flutter/material.dart, package:mobile/models/dashboard_data.dart, package:mobile/models/payment_model.dart, package:mobile/screens/single_transaction_screen.dart, package:mobile/widgets/transaction_tile.dart

### Community 121 - "package:flutter_test/flutter_test.dart"
Cohesion: 0.15
Nodes (11): main, main, main, package:flutter_test/flutter_test.dart, package:mobile/models/category_model.dart, package:mobile/models/expense_model.dart, package:mobile/screens/scan_and_pay_screen.dart, package:mobile/services/location_service.dart (+3 more)

### Community 122 - "StatelessWidget"
Cohesion: 0.25
Nodes (8): HulyPayApp, AboutHulyPayScreen, AnimatedHulyLogo, AnimatedWaveBackground, QuickActionButton, _HeatmapGridWidget, TransactionTile, StatelessWidget

### Community 123 - "ExpenseRepository"
Cohesion: 0.27
Nodes (3): AnalyticsService, ExpenseRepository, org.springframework.data.jpa.repository.Query

### Community 124 - "PaymentService.java"
Cohesion: 0.38
Nodes (7): PaymentService, SmsParserService, jakarta.annotation.PostConstruct, java.util.regex.Pattern, lombok.extern.slf4j.Slf4j, org.springframework.jdbc.core.JdbcTemplate, org.springframework.stereotype.Service

### Community 125 - "CustomPainter"
Cohesion: 0.40
Nodes (5): CustomPainter, ScannerFramePainter, _MapGridPainter, WaveSilkPainter, _SpeedometerGaugePainter

### Community 127 - "MaterialPageRoute"
Cohesion: 0.25
Nodes (8): MaterialPageRoute, _buildHeader, _startSmsVerificationWorkflow, _buildAccountSection, _buildPreferencesSection, _buildSupportSection, _openScanAndPay, build

### Community 128 - "_HomeDashboardScreenState"
Cohesion: 0.33
Nodes (6): HomeDashboardScreen, _HomeDashboardScreenState, SignInScreen, _SignInScreenState, TickerProviderStateMixin, WidgetsBindingObserver

## Knowledge Gaps
- **879 isolated node(s):** `com.hulypay:backend`, `INITIATED`, `PAYMENT_INITIATED`, `PENDING`, `CONFIRMED` (+874 more)
  These have ≤1 connection - possible missing edges or undocumented components. (Counts symbols only; 1086 node(s) total have ≤1 connection when file, concept and rationale nodes are included.)
- **48 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `LocalDatabaseService` connect `daily_limit_chart_test.dart` to `user_repository.dart`, `local_database_service.dart`, `payment_repository.dart`, `widget_test.dart`, `local_database_service_test.dart`?**
  _High betweenness centrality (0.008) - this node is a cross-community bridge._
- **Why does `User` connect `User` to `org.springframework.http.ResponseEntity`, `org.springframework.transaction.annotation.Transactional`, `org.junit.jupiter.api.Test`, `CategoryResponse`, `lombok.AllArgsConstructor`, `Expense`, `lombok.RequiredArgsConstructor`, `ExpenseRepository`, `PaymentService.java`?**
  _High betweenness centrality (0.007) - this node is a cross-community bridge._
- **Why does `PaymentStatus` connect `lombok.AllArgsConstructor` to `org.junit.jupiter.api.Test`, `Expense`?**
  _High betweenness centrality (0.005) - this node is a cross-community bridge._
- **What connects `com.hulypay:backend`, `INITIATED`, `PAYMENT_INITIATED` to the rest of the system?**
  _879 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `home_spend_trend_line_chart.dart` be split into smaller, more focused modules?**
  _Cohesion score 0.08695652173913043 - nodes in this community are weakly interconnected._
- **Should `location_service.dart` be split into smaller, more focused modules?**
  _Cohesion score 0.08695652173913043 - nodes in this community are weakly interconnected._
- **Should `upi_service.dart` be split into smaller, more focused modules?**
  _Cohesion score 0.10526315789473684 - nodes in this community are weakly interconnected._