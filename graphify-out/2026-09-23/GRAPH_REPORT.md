# Graph Report - Huly.pay  (2026-09-22)

## Corpus Check
- 161 files · ~154,751 words
- Verdict: corpus is large enough that graph structure adds value.

## Summary
- 1682 nodes · 2780 edges · 117 communities (71 shown, 36 thin omitted)
- Extraction: 97% EXTRACTED · 3% INFERRED · 0% AMBIGUOUS · INFERRED: 74 edges (avg confidence: 0.8)
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `0da28cd2`
- Run `git rev-parse HEAD` and compare to check if the graph is stale.
- Run `graphify update .` after code changes (no API cost).

## Community Hubs (Navigation)
- home_spend_trend_line_chart.dart
- location_service.dart
- upi_service.dart
- dashboard_data.dart
- upi_payment_service.dart
- AppDelegate
- local_database_service.dart
- app/page.js
- home_dashboard_screen.dart
- settings_screen.dart
- transactions_screen.dart
- payment_model.dart
- lombok.AllArgsConstructor
- analysis_screen.dart
- user_preferences_service.dart
- scan_and_pay_screen.dart
- ErrorResponse
- ExpenseRepository
- SecurityConfig.java
- org.springframework.web.bind.annotation.GetMapping
- single_transaction_screen.dart
- package.json
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
- String?
- main.dart
- PaymentStatus
- user_profile.dart
- State
- Flutter Pubspec
- auth_service.dart
- AppThemeContextExtension
- transaction_tile.dart
- layout.js
- README.md
- compilerOptions
- next.config.mjs
- iOS Launch Image
- CategoryResponse
- AppThemeData
- payment_methods_screen.dart
- notifications_screen.dart
- ../theme/app_theme.dart
- MaterialPageRoute
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
- AGENTS.md
- eslint.config.mjs
- postcss.config.mjs
- AnimatedSignature.js
- Mobile App Documentation
- StatelessWidget
- dependencies
- devDependencies
- com.hulypay:backend
- scripts
- app_theme.dart
- rules/graphify.md
- workflows/graphify.md
- BackendApplication
- help_support_screen.dart
- home_today_spend_gauge.dart
- org.springframework.http.ResponseEntity
- user_repository.dart
- spending_heatmap.dart
- real_data_and_sqlite_sync_test.dart
- google_pay_service.dart
- about_hulypay_screen.dart
- payment_repository.dart
- org.junit.jupiter.api.Test
- home_weekly_bar_chart.dart
- privacy_security_screen.dart
- bool?
- package:flutter/foundation.dart
- package:flutter/material.dart
- fl_chart_widgets_test.dart
- quick_scan_feature_test.dart
- widget_test.dart
- categorize_single_transaction_test.dart
- package:flutter_test/flutter_test.dart
- User
- CustomPainter
- setCustomClient

## God Nodes (most connected - your core abstractions)
1. `User` - 49 edges
2. `Payment` - 25 edges
3. `Category` - 24 edges
4. `Expense` - 22 edges
5. `PaymentStatus` - 21 edges
6. `PaymentResponse` - 19 edges
7. `ResourceNotFoundException` - 17 edges
8. `ExpenseResponse` - 17 edges
9. `UserService` - 17 edges
10. `CategoryResponse` - 16 edges

## Surprising Connections (you probably didn't know these)
- `Launch Screen Assets README` --references--> `iOS Launch Image`  [INFERRED]
  mobile/ios/Runner/Assets.xcassets/LaunchImage.imageset/README.md → mobile/ios/Runner/Assets.xcassets/LaunchImage.imageset/LaunchImage.png
- `AnalyticsController` --references--> `AnalyticsService`  [EXTRACTED]
  backend/src/main/java/com/hulypay/backend/analytics/AnalyticsController.java → backend/src/main/java/com/hulypay/backend/analytics/AnalyticsService.java
- `Category` --references--> `User`  [EXTRACTED]
  backend/src/main/java/com/hulypay/backend/categories/Category.java → backend/src/main/java/com/hulypay/backend/users/User.java
- `Expense` --references--> `Category`  [EXTRACTED]
  backend/src/main/java/com/hulypay/backend/expenses/Expense.java → backend/src/main/java/com/hulypay/backend/categories/Category.java
- `CategoryController` --references--> `CategoryService`  [EXTRACTED]
  backend/src/main/java/com/hulypay/backend/categories/CategoryController.java → backend/src/main/java/com/hulypay/backend/categories/CategoryService.java

## Import Cycles
- None detected.

## Communities (117 total, 36 thin omitted)

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
Cohesion: 0.05
Nodes (43): List, amount, avatarUrl, category, CategorySpendingItem, changePercent, changePeriodLabel, color (+35 more)

### Community 4 - "upi_payment_service.dart"
Cohesion: 0.05
Nodes (39): allApps, amazon, amazonPay, appNotInstalled, askEveryTime, bhim, bhimApp, buildSafeUpiUri (+31 more)

### Community 5 - "AppDelegate"
Cohesion: 0.11
Nodes (14): Any, Flutter, FlutterAppDelegate, FlutterImplicitEngineBridge, FlutterImplicitEngineDelegate, FlutterSceneDelegate, AppDelegate, Bool (+6 more)

### Community 6 - "local_database_service.dart"
Cohesion: 0.05
Nodes (40): Database?, cleanupStalePayments, clearAll, clearPayments, clearUserProfile, close, _db, dbName (+32 more)

### Community 7 - "app/page.js"
Cohesion: 0.15
Nodes (9): CardDownload(), Features(), Footer(), Hero(), PARALLAX_CONFIG, Navbar(), Workflow(), gsap (+1 more)

### Community 8 - "home_dashboard_screen.dart"
Cohesion: 0.05
Nodes (36): Animation, AnimationController, _applyData, build, _buildAvatarFallback, _buildBody, _buildDashboardContent, _buildQuickActions (+28 more)

### Community 9 - "settings_screen.dart"
Cohesion: 0.06
Nodes (31): about_hulypay_screen.dart, help_support_screen.dart, appVersion, _avatarUrl, build, _buildChartPaletteOptionCard, _buildGroupCard, _buildLogoutCard (+23 more)

### Community 10 - "transactions_screen.dart"
Cohesion: 0.08
Nodes (24): analysis_screen.dart, home_dashboard_screen.dart, _allGroups, build, _buildFilterChips, _buildHeader, _buildSearchBar, createState (+16 more)

### Community 11 - "payment_model.dart"
Cohesion: 0.07
Nodes (27): dashboard_data.dart, amount, copyWith, createdAt, CreatePaymentPayload, currency, expenseId, fromJson (+19 more)

### Community 12 - "lombok.AllArgsConstructor"
Cohesion: 0.24
Nodes (16): CategoryBreakdownResponse, DailySpendingResponse, SpendingSummaryResponse, CreateExpenseRequest, UpdateExpenseRequest, CreatePaymentRequest, ReconcilePaymentRequest, SmsVerificationRequest (+8 more)

### Community 13 - "analysis_screen.dart"
Cohesion: 0.06
Nodes (32): _allPayments, build, _buildCategoryList, _buildClassificationToggleButton, _buildHeader, _categories, _categoryOverrides, _classificationMode (+24 more)

### Community 14 - "user_preferences_service.dart"
Cohesion: 0.06
Nodes (34): double? get, local_database_service.dart, _cachedAnalysisPeriod, _cachedDailyLimit, _cachedDefaultPaymentApp, _cachedQuickConfirm, _cachedQuickScan, _client (+26 more)

### Community 15 - "scan_and_pay_screen.dart"
Cohesion: 0.05
Nodes (38): DateTime?, build, cornerColor, cornerLength, cornerRadius, createState, cutoutRect, dispose (+30 more)

### Community 16 - "ErrorResponse"
Cohesion: 0.19
Nodes (12): ErrorResponse, GlobalExceptionHandler, com.fasterxml.jackson.annotation.JsonInclude, NoResourceFoundException, org.springframework.dao.DataIntegrityViolationException, org.springframework.security.access.AccessDeniedException, org.springframework.security.core.AuthenticationException, org.springframework.web.bind.annotation.ExceptionHandler (+4 more)

### Community 17 - "ExpenseRepository"
Cohesion: 0.23
Nodes (4): AnalyticsService, MonthlySpendingResponse, ExpenseRepository, org.springframework.data.jpa.repository.Query

### Community 18 - "SecurityConfig.java"
Cohesion: 0.21
Nodes (11): OpenApiConfig, SecurityConfig, io.swagger.v3.oas.models.OpenAPI, JwtDecoder, OpenAPI, org.springframework.context.annotation.Bean, org.springframework.context.annotation.Configuration, org.springframework.security.config.annotation.web.builders.HttpSecurity (+3 more)

### Community 19 - "org.springframework.web.bind.annotation.GetMapping"
Cohesion: 0.25
Nodes (8): DatabaseHealthController, DatabaseHealthResponse, HealthController, HealthResponse, java.util.Map, javax.sql.DataSource, org.springframework.web.bind.annotation.GetMapping, org.springframework.web.bind.annotation.RestController

### Community 20 - "single_transaction_screen.dart"
Cohesion: 0.04
Nodes (53): DraggableScrollableNotification, GoogleMapController?, MapType, _accuracy, build, _buildActionButton, _buildDarkMapFallbackCanvas, _buildDetailRow (+45 more)

### Community 21 - "package.json"
Cohesion: 0.14
Nodes (13): name, private, version, babel-plugin-react-compiler, eslint, eslint-config-next, @gsap/react, lenis (+5 more)

### Community 22 - "splash_screen.dart"
Cohesion: 0.04
Nodes (51): , dart:ui, Duration, animation, build, _controller, createState, dispose (+43 more)

### Community 23 - "expense_model.dart"
Cohesion: 0.09
Nodes (21): category_model.dart, amount, category, categoryId, createdAt, CreateExpensePayload, currency, description (+13 more)

### Community 24 - "api_client.dart"
Cohesion: 0.06
Nodes (33): auth_service.dart, Dio, Exception, int?, ApiException, createCategory, createExpense, createPayment (+25 more)

### Community 25 - "MainActivity"
Cohesion: 0.22
Nodes (8): Context, FlutterActivity, FlutterEngine, IntArray, Intent, MethodChannel, MainActivity, BroadcastReceiver

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

### Community 32 - "String?"
Cohesion: 0.20
Nodes (9): CategoryModel, color, fromJson, icon, id, isDefault, name, toJson (+1 more)

### Community 33 - "main.dart"
Cohesion: 0.14
Nodes (13): build, home, initializeAuth, isAuthenticated, main, nextScreen, showSplash, widgetsBinding (+5 more)

### Community 34 - "PaymentStatus"
Cohesion: 0.14
Nodes (12): PaymentStatus, CANCELLED, CONFIRMED, FAILED, INITIATED, PAYMENT_INITIATED, PENDING, SUCCESS (+4 more)

### Community 35 - "user_profile.dart"
Cohesion: 0.14
Nodes (13): active, authProvider, avatarUrl, copyWith, email, firstName, fromJson, fullName (+5 more)

### Community 36 - "State"
Cohesion: 0.13
Nodes (23): AnalysisScreen, _AnalysisScreenState, HelpSupportScreen, _HelpSupportScreenState, HomeDashboardScreen, _HomeDashboardScreenState, NotificationsScreen, _NotificationsScreenState (+15 more)

### Community 38 - "auth_service.dart"
Cohesion: 0.07
Nodes (26): dart:async, AuthService, client, currentAccessToken, currentSession, currentUser, hasValidActiveToken, initialize (+18 more)

### Community 40 - "transaction_tile.dart"
Cohesion: 0.22
Nodes (8): TransactionItem, PaymentModel, onTap, payment, transaction, ../models/dashboard_data.dart, ../models/payment_model.dart, ../screens/single_transaction_screen.dart

### Community 41 - "layout.js"
Cohesion: 0.25
Nodes (6): dotoFont, geistMono, geistSans, metadata, pixelifySans, SmoothScroll()

### Community 42 - "README.md"
Cohesion: 0.50
Nodes (3): Deploy on Vercel, Getting Started, Learn More

### Community 47 - "CategoryResponse"
Cohesion: 0.28
Nodes (7): CategoryController, PostMapping, PutMapping, RequestMapping, RestController, CategoryRequest, CategoryResponse

### Community 51 - "payment_methods_screen.dart"
Cohesion: 0.12
Nodes (17): Map, build, _buildAppBar, _buildInstalledAppsList, _buildPaymentAppCard, _buildSectionTitle, createState, initState (+9 more)

### Community 53 - "notifications_screen.dart"
Cohesion: 0.10
Nodes (19): _budgetExceededWarnings, build, _buildAppBar, _buildDevNoticeBanner, _buildInboxTab, _buildNotificationCard, _buildPreferencesTab, _buildSwitchTile (+11 more)

### Community 54 - "../theme/app_theme.dart"
Cohesion: 0.13
Nodes (14): IconData?, build, icon, label, onTap, svgAsset, build, _buildNavItem (+6 more)

### Community 55 - "MaterialPageRoute"
Cohesion: 0.22
Nodes (9): MaterialPageRoute, _buildHeader, _showPaymentConfirmationModal, _startSmsVerificationWorkflow, _buildAccountSection, _buildPreferencesSection, _buildSupportSection, _buildGroupedTransactions (+1 more)

### Community 82 - "AnimatedSignature.js"
Cohesion: 0.25
Nodes (10): AnimatedSignature(), InitialLoader(), SIGNATURE_FILL_PATH, SIGNATURE_HEIGHT, SIGNATURE_MASK_PATH, SIGNATURE_STROKE_LENGTH, SIGNATURE_VIEWBOX, SIGNATURE_WIDTH (+2 more)

### Community 86 - "StatelessWidget"
Cohesion: 0.22
Nodes (9): HulyPayApp, AboutHulyPayScreen, AnimatedHulyLogo, AnimatedWaveBackground, QuickActionButton, CustomBottomNavBar, _HeatmapGridWidget, TransactionTile (+1 more)

### Community 87 - "dependencies"
Cohesion: 0.25
Nodes (8): dependencies, gsap, @gsap/react, lenis, next, next-transition-router, react, react-dom

### Community 88 - "devDependencies"
Cohesion: 0.33
Nodes (6): devDependencies, babel-plugin-react-compiler, eslint, eslint-config-next, tailwindcss, @tailwindcss/postcss

### Community 90 - "scripts"
Cohesion: 0.40
Nodes (5): scripts, build, dev, lint, start

### Community 91 - "app_theme.dart"
Cohesion: 0.03
Nodes (61): AppThemeData get, Brightness, ColorScheme get, accent, AppRadii, AppSpacing, AppThemeManager, background (+53 more)

### Community 96 - "help_support_screen.dart"
Cohesion: 0.14
Nodes (13): build, _buildAppBar, _buildDeveloperWebsiteCard, _buildEmailContactCard, _buildFaqItem, _buildFaqSection, _copyToClipboard, createState (+5 more)

### Community 97 - "home_today_spend_gauge.dart"
Cohesion: 0.10
Nodes (21): Color, dart:math, activeColor, build, _buildZoneIndicator, _computeTodaySpend, createState, _customLimit (+13 more)

### Community 98 - "org.springframework.http.ResponseEntity"
Cohesion: 0.10
Nodes (26): AnalyticsController, DeleteMapping, GetMapping, ExpenseController, DeleteMapping, GetMapping, PostMapping, PutMapping (+18 more)

### Community 99 - "user_repository.dart"
Cohesion: 0.15
Nodes (12): _apiClient, getCachedUserProfile, getUserProfile, _instance, _localDb, saveUserProfile, UserRepository, ../models/user_profile.dart (+4 more)

### Community 100 - "spending_heatmap.dart"
Cohesion: 0.08
Nodes (25): build, _buildFooter, _buildGrid, _buildHeader, cells, columns, _computePeriodTotal, createState (+17 more)

### Community 101 - "real_data_and_sqlite_sync_test.dart"
Cohesion: 0.25
Nodes (7): dbService, main, dbService, main, package:mobile/repositories/payment_repository.dart, package:mobile/repositories/user_repository.dart, package:mobile/screens/home_dashboard_screen.dart

### Community 102 - "google_pay_service.dart"
Cohesion: 0.05
Nodes (37): amazonPayPackage, amount, approvalRefNo, _channel, errorMessage, fromNativeMap, fromQueryString, googlePayPackage (+29 more)

### Community 103 - "about_hulypay_screen.dart"
Cohesion: 0.15
Nodes (12): appVersion, build, _buildAppBar, _buildCreatorSection, _buildEnvironmentNoticeCard, _buildFeatureHighlights, _buildFeatureItem, _buildHeroBrandCard (+4 more)

### Community 105 - "payment_repository.dart"
Cohesion: 0.13
Nodes (14): _apiClient, cleanupStalePayments, createPayment, getCachedPayments, getPaymentById, getPayments, _instance, _localDb (+6 more)

### Community 106 - "org.junit.jupiter.api.Test"
Cohesion: 0.05
Nodes (38): Category, AllArgsConstructor, Builder, Entity, Getter, NoArgsConstructor, Setter, Table (+30 more)

### Community 109 - "home_weekly_bar_chart.dart"
Cohesion: 0.11
Nodes (18): build, _buildBarChartData, _buildLegendItem, _calculateMax, _computeWeeklyData, createState, _defaultBarColor, _getBottomTitles (+10 more)

### Community 110 - "privacy_security_screen.dart"
Cohesion: 0.20
Nodes (9): build, _buildAppBar, _buildBulletPoint, _buildDataCollectionCard, _buildDevelopmentPrivacyNotice, _buildProtocolItem, _buildSecurityBanner, _buildSecurityProtocolsCard (+1 more)

### Community 114 - "package:flutter/foundation.dart"
Cohesion: 0.40
Nodes (4): main, package:flutter/foundation.dart, package:flutter/services.dart, package:mobile/services/google_pay_service.dart

### Community 116 - "package:flutter/material.dart"
Cohesion: 0.33
Nodes (5): dart:io, main, main, package:flutter/material.dart, package:mobile/screens/splash_screen.dart

### Community 117 - "fl_chart_widgets_test.dart"
Cohesion: 0.14
Nodes (13): BarChart, main, samplePayments, main, package:fl_chart/fl_chart.dart, package:mobile/screens/settings_screen.dart, package:mobile/theme/app_theme.dart, package:mobile/theme/chart_colors.dart (+5 more)

### Community 118 - "quick_scan_feature_test.dart"
Cohesion: 0.13
Nodes (18): LocalDatabaseService, UserPreferencesService, dbService, main, dbService, main, prefService, dbService (+10 more)

### Community 119 - "widget_test.dart"
Cohesion: 0.15
Nodes (12): AuthException, main, emptyDashboard, main, package:mobile/main.dart, package:mobile/models/user_profile.dart, package:mobile/screens/sign_in_screen.dart, package:mobile/services/api_client.dart (+4 more)

### Community 120 - "categorize_single_transaction_test.dart"
Cohesion: 0.19
Nodes (10): main, sampleTx, main, main, package:mobile/models/dashboard_data.dart, package:mobile/models/payment_model.dart, package:mobile/screens/analysis_screen.dart, package:mobile/screens/single_transaction_screen.dart (+2 more)

### Community 121 - "package:flutter_test/flutter_test.dart"
Cohesion: 0.15
Nodes (11): main, main, main, package:flutter_test/flutter_test.dart, package:mobile/models/category_model.dart, package:mobile/models/expense_model.dart, package:mobile/screens/scan_and_pay_screen.dart, package:mobile/services/location_service.dart (+3 more)

### Community 123 - "User"
Cohesion: 0.10
Nodes (28): CategoryService, BadRequestException, ResourceNotFoundException, ExpenseResponse, Expense, AllArgsConstructor, Builder, Entity (+20 more)

### Community 125 - "CustomPainter"
Cohesion: 0.29
Nodes (7): CustomPainter, ScannerFramePainter, ScannerOverlayPainter, _MapGridPainter, LogoStrokePainter, WaveSilkPainter, _SpeedometerGaugePainter

## Knowledge Gaps
- **925 isolated node(s):** `com.hulypay:backend`, `INITIATED`, `PAYMENT_INITIATED`, `PENDING`, `CONFIRMED` (+920 more)
  These have ≤1 connection - possible missing edges or undocumented components. (Counts symbols only; 1122 node(s) total have ≤1 connection when file, concept and rationale nodes are included.)
- **36 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `User` connect `User` to `org.springframework.http.ResponseEntity`, `org.junit.jupiter.api.Test`, `lombok.AllArgsConstructor`, `CategoryResponse`, `ExpenseRepository`?**
  _High betweenness centrality (0.009) - this node is a cross-community bridge._
- **Why does `LocalDatabaseService` connect `quick_scan_feature_test.dart` to `payment_repository.dart`, `user_repository.dart`, `real_data_and_sqlite_sync_test.dart`, `local_database_service.dart`?**
  _High betweenness centrality (0.005) - this node is a cross-community bridge._
- **Why does `PaymentStatus` connect `PaymentStatus` to `org.junit.jupiter.api.Test`, `User`, `lombok.AllArgsConstructor`?**
  _High betweenness centrality (0.005) - this node is a cross-community bridge._
- **What connects `com.hulypay:backend`, `INITIATED`, `PAYMENT_INITIATED` to the rest of the system?**
  _925 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `home_spend_trend_line_chart.dart` be split into smaller, more focused modules?**
  _Cohesion score 0.08695652173913043 - nodes in this community are weakly interconnected._
- **Should `location_service.dart` be split into smaller, more focused modules?**
  _Cohesion score 0.08695652173913043 - nodes in this community are weakly interconnected._
- **Should `upi_service.dart` be split into smaller, more focused modules?**
  _Cohesion score 0.10526315789473684 - nodes in this community are weakly interconnected._