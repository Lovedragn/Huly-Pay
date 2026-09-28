# Graph Report - Huly.pay  (2026-09-28)

## Corpus Check
- 181 files · ~132,728 words
- Verdict: corpus is large enough that graph structure adds value.

## Summary
- 1881 nodes · 3169 edges · 107 communities (78 shown, 20 thin omitted)
- Extraction: 97% EXTRACTED · 3% INFERRED · 0% AMBIGUOUS · INFERRED: 87 edges (avg confidence: 0.81)
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `665ea317`
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
- layout.js
- home_dashboard_screen.dart
- settings_screen.dart
- transactions_screen.dart
- payment_model.dart
- lombok.AllArgsConstructor
- analysis_screen.dart
- user_preferences_service.dart
- scan_and_pay_screen.dart
- ErrorResponse
- upload_qr_screen.dart
- SecurityConfig.java
- User
- single_transaction_screen.dart
- package.json
- DatabaseHealthController
- expense_model.dart
- api_client.dart
- MainActivity
- Docker Compose Configuration
- mvnw
- splash_screen.dart
- package:flutter/foundation.dart
- Application Configuration
- chart_colors.dart
- String?
- main.dart
- external_data.dart
- 💳 HulyPay — Next-Gen Intelligent Fintech App
- State
- user_profile.dart
- auth_service.dart
- AppThemeContextExtension
- sign_in_screen.dart
- scan_amount_screen.dart
- README.md
- compilerOptions
- next.config.mjs
- about_hulypay_screen.dart
- PaymentService.java
- AppThemeData
- payment_methods_screen.dart
- MaterialPageRoute
- action_button.dart
- transaction_detail_components.dart
- ExpenseRepository
- ../models/payment_model.dart
- dashboard/page.js
- hulypay/MainActivity.kt
- LaunchImage.imageset/README.md
- CustomPainter
- navBgIcons.js
- SingleTransactionScreen
- hulypay/README.md
- features/page.js
- design/page.js
- AnimatedSignature.js
- dependencies
- react
- UserResponse
- DashboardPage
- customization_bottom_sheet.dart
- devDependencies
- tools/page.js
- AGENTS.md
- eslint.config.mjs
- postcss.config.mjs
- _HomeDashboardScreenState
- chart.jsx
- BackendStatusBar.jsx
- analysis_category_pie_chart.dart
- com.hulypay:backend
- app_theme.dart
- rules/graphify.md
- workflows/graphify.md
- org.junit.jupiter.api.Test
- BackendApplication
- help_support_screen.dart
- home_today_spend_gauge.dart
- org.springframework.http.ResponseEntity
- user_repository.dart
- spending_heatmap.dart
- google_pay_service.dart
- package:flutter/material.dart
- payment_repository.dart
- AuthContext.js
- home_weekly_bar_chart.dart
- app/page.js
- bool?
- qr_share_service.dart
- setCustomClient

## God Nodes (most connected - your core abstractions)
1. `User` - 49 edges
2. `Payment` - 25 edges
3. `Category` - 24 edges
4. `Expense` - 22 edges
5. `react` - 22 edges
6. `PaymentStatus` - 21 edges
7. `PaymentResponse` - 19 edges
8. `ResourceNotFoundException` - 17 edges
9. `ExpenseResponse` - 17 edges
10. `UserService` - 17 edges

## Surprising Connections (you probably didn't know these)
- `loadData()` --calls--> `syncAllDashboardData()`  [EXTRACTED]
  frontend/src/app/dashboard/page.js → frontend/src/lib/api.js
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

## Communities (107 total, 20 thin omitted)

### Community 0 - "home_spend_trend_line_chart.dart"
Cohesion: 0.09
Nodes (23): amount, _bottomTitleWidgets, build, _buildCardFooter, _buildCardHeader, _buildCurvedGradientData, _buildDualZoneData, _calculateMaxY (+15 more)

### Community 1 - "location_service.dart"
Cohesion: 0.09
Nodes (22): bool get, accuracyMeters, errorMessage, failure, failureReason, getCurrentPaymentLocation, getPaymentLocationWithStatus, _instance (+14 more)

### Community 2 - "upi_service.dart"
Cohesion: 0.11
Nodes (17): amazonPayPackageName, amount, buildPaymentUri, currency, googlePayPackageName, isUpiUri, launchUpiPayment, merchantCode (+9 more)

### Community 3 - "dashboard_data.dart"
Cohesion: 0.06
Nodes (30): amount, avatarUrl, category, CategorySpendingItem, changePercent, changePeriodLabel, color, DashboardData (+22 more)

### Community 4 - "upi_payment_service.dart"
Cohesion: 0.05
Nodes (39): allApps, amazon, amazonPay, appNotInstalled, askEveryTime, bhim, bhimApp, buildSafeUpiUri (+31 more)

### Community 5 - "AppDelegate"
Cohesion: 0.11
Nodes (14): Any, Flutter, FlutterAppDelegate, FlutterImplicitEngineBridge, FlutterImplicitEngineDelegate, FlutterSceneDelegate, AppDelegate, Bool (+6 more)

### Community 6 - "local_database_service.dart"
Cohesion: 0.05
Nodes (41): Database?, cleanupStalePayments, clearAll, clearPayments, clearUserProfile, close, _db, dbName (+33 more)

### Community 7 - "layout.js"
Cohesion: 0.16
Nodes (14): dotoFont, geistMono, geistSans, metadata, pixelifySans, SmoothScroll(), emptySubscribe(), getServerSnapshot() (+6 more)

### Community 8 - "home_dashboard_screen.dart"
Cohesion: 0.06
Nodes (35): Animation, _applyData, build, _buildAvatarFallback, _buildBody, _buildDashboardContent, _buildQuickActions, _buildTotalSpentCard (+27 more)

### Community 9 - "settings_screen.dart"
Cohesion: 0.06
Nodes (30): about_hulypay_screen.dart, help_support_screen.dart, appVersion, _avatarUrl, build, _buildAppInfoFooter, _buildGroupCard, _buildLogoutCard (+22 more)

### Community 10 - "transactions_screen.dart"
Cohesion: 0.08
Nodes (23): analysis_screen.dart, _allGroups, build, _buildFilterChips, _buildSearchBar, createState, dispose, _filterActivePayments (+15 more)

### Community 11 - "payment_model.dart"
Cohesion: 0.07
Nodes (27): dashboard_data.dart, amount, copyWith, createdAt, CreatePaymentPayload, currency, expenseId, fromJson (+19 more)

### Community 12 - "lombok.AllArgsConstructor"
Cohesion: 0.13
Nodes (30): CategoryBreakdownResponse, DailySpendingResponse, MonthlySpendingResponse, SpendingSummaryResponse, CategoryRequest, CreateExpenseRequest, UpdateExpenseRequest, CreatePaymentRequest (+22 more)

### Community 13 - "analysis_screen.dart"
Cohesion: 0.06
Nodes (34): _allPayments, build, _buildCategoryList, _buildClassificationToggleButton, _buildHeader, _categories, _categoryOverrides, _classificationMode (+26 more)

### Community 14 - "user_preferences_service.dart"
Cohesion: 0.06
Nodes (35): double? get, local_database_service.dart, _cachedAnalysisPeriod, _cachedDailyLimit, _cachedDefaultPaymentApp, _cachedQuickConfirm, _cachedQuickScan, _client (+27 more)

### Community 15 - "scan_and_pay_screen.dart"
Cohesion: 0.05
Nodes (39): DateTime?, _amountController, build, cornerColor, cornerLength, cornerRadius, createState, cutoutRect (+31 more)

### Community 16 - "ErrorResponse"
Cohesion: 0.17
Nodes (13): ErrorResponse, GlobalExceptionHandler, com.fasterxml.jackson.annotation.JsonInclude, java.util.Map, NoResourceFoundException, org.springframework.dao.DataIntegrityViolationException, org.springframework.security.access.AccessDeniedException, org.springframework.security.core.AuthenticationException (+5 more)

### Community 17 - "upload_qr_screen.dart"
Cohesion: 0.10
Nodes (19): _amountController, _amountFocusNode, build, createState, dispose, _handleUploadButton, initialAmount, initState (+11 more)

### Community 18 - "SecurityConfig.java"
Cohesion: 0.21
Nodes (11): OpenApiConfig, SecurityConfig, io.swagger.v3.oas.models.OpenAPI, JwtDecoder, OpenAPI, org.springframework.context.annotation.Bean, org.springframework.context.annotation.Configuration, org.springframework.security.config.annotation.web.builders.HttpSecurity (+3 more)

### Community 19 - "User"
Cohesion: 0.10
Nodes (24): CategoryService, CategoryResponse, BadRequestException, ResourceNotFoundException, ExpenseResponse, Expense, AllArgsConstructor, Builder (+16 more)

### Community 20 - "single_transaction_screen.dart"
Cohesion: 0.04
Nodes (51): DraggableScrollableNotification, GoogleMapController?, _accuracy, build, _buildDarkMapFallbackCanvas, _buildDetailsCard, _buildGoogleMapContent, _buildGoogleMapOrStreetView (+43 more)

### Community 21 - "package.json"
Cohesion: 0.09
Nodes (21): name, private, scripts, build, dev, lint, start, version (+13 more)

### Community 22 - "DatabaseHealthController"
Cohesion: 0.26
Nodes (6): DatabaseHealthController, DatabaseHealthResponse, HealthController, HealthResponse, javax.sql.DataSource, org.springframework.web.bind.annotation.RestController

### Community 23 - "expense_model.dart"
Cohesion: 0.09
Nodes (21): category_model.dart, amount, category, categoryId, createdAt, CreateExpensePayload, currency, description (+13 more)

### Community 24 - "api_client.dart"
Cohesion: 0.06
Nodes (32): auth_service.dart, Dio, Exception, int?, ApiException, createCategory, createExpense, createPayment (+24 more)

### Community 25 - "MainActivity"
Cohesion: 0.20
Nodes (9): Context, FlutterEngine, IntArray, Intent, MethodChannel, FlutterActivity, MainActivity, BroadcastReceiver (+1 more)

### Community 27 - "mvnw"
Cohesion: 0.38
Nodes (8): mvnw script, clean(), die(), exec_maven(), hash_string(), set_java_home(), trim(), verbose()

### Community 28 - "splash_screen.dart"
Cohesion: 0.09
Nodes (21): AnimationController, Duration, build, _controller, createState, dispose, duration, _hasLocalUser (+13 more)

### Community 29 - "package:flutter/foundation.dart"
Cohesion: 0.22
Nodes (8): dart:convert, getEmail, getExpirationDate, getPayload, getSubject, isExpired, TokenValidator, package:flutter/foundation.dart

### Community 31 - "chart_colors.dart"
Cohesion: 0.06
Nodes (33): app_theme.dart, financialKeywords, isFinancialTransactionSms, SmsFilterService, allPalettes, amber, AppChartColors, barDefault (+25 more)

### Community 32 - "String?"
Cohesion: 0.20
Nodes (9): CategoryModel, color, fromJson, icon, id, isDefault, name, toJson (+1 more)

### Community 33 - "main.dart"
Cohesion: 0.15
Nodes (12): build, home, initializeAuth, isAuthenticated, main, nextScreen, showSplash, widgetsBinding (+4 more)

### Community 34 - "external_data.dart"
Cohesion: 0.02
Nodes (110): Acceptance of, Account, Changes to, Contact Regarding, Disclaimer of, Information We, aboutEnvironmentNoticeBody, aboutEnvironmentNoticeTitle (+102 more)

### Community 35 - "💳 HulyPay — Next-Gen Intelligent Fintech App"
Cohesion: 0.11
Nodes (17): 1. Prerequisites, 2. Clone Repository & Setup, 3. Environment Configuration, 4. Run on Android, 5. Run on iOS (macOS required), Core Features, 👨‍💻 Developer & Contributing, Folder Structure (+9 more)

### Community 36 - "State"
Cohesion: 0.12
Nodes (23): AnalysisScreen, _AnalysisScreenState, HelpSupportScreen, _HelpSupportScreenState, ScanAmountScreen, _ScanAmountScreenState, ScanAndPayScreen, _ScanAndPayScreenState (+15 more)

### Community 37 - "user_profile.dart"
Cohesion: 0.14
Nodes (13): active, authProvider, avatarUrl, copyWith, email, firstName, fromJson, fullName (+5 more)

### Community 38 - "auth_service.dart"
Cohesion: 0.07
Nodes (26): dart:async, AuthService, client, currentAccessToken, currentSession, currentUser, hasValidActiveToken, initialize (+18 more)

### Community 40 - "sign_in_screen.dart"
Cohesion: 0.09
Nodes (21): home_dashboard_screen.dart, _authSubscription, _authTimeoutTimer, build, createState, didChangeAppLifecycleState, dispose, _finishSignIn (+13 more)

### Community 41 - "scan_amount_screen.dart"
Cohesion: 0.13
Nodes (14): double?, FocusNode, _amountController, _amountFocusNode, build, createState, dispose, _handleScanButton (+6 more)

### Community 42 - "README.md"
Cohesion: 0.50
Nodes (3): Deploy on Vercel, Getting Started, Learn More

### Community 45 - "about_hulypay_screen.dart"
Cohesion: 0.20
Nodes (9): appVersion, build, _buildAppBar, _buildCreatorSection, _buildHeroBrandCard, _buildSpecRow, _buildSpecsCard, _launchUrl (+1 more)

### Community 47 - "PaymentService.java"
Cohesion: 0.38
Nodes (7): PaymentService, SmsParserService, jakarta.annotation.PostConstruct, java.util.regex.Pattern, lombok.extern.slf4j.Slf4j, org.springframework.jdbc.core.JdbcTemplate, org.springframework.stereotype.Service

### Community 51 - "payment_methods_screen.dart"
Cohesion: 0.12
Nodes (17): Map, build, _buildAppBar, _buildInstalledAppsList, _buildPaymentAppCard, _buildSectionTitle, createState, initState (+9 more)

### Community 53 - "MaterialPageRoute"
Cohesion: 0.20
Nodes (10): MaterialPageRoute, _buildHeader, _openUploadQr, _showPaymentConfirmationModal, _startSmsVerificationWorkflow, _buildAccountSection, _buildNotificationsSection, _buildSupportSection (+2 more)

### Community 54 - "action_button.dart"
Cohesion: 0.22
Nodes (8): IconData, build, icon, label, onTap, QuickActionButton, svgAsset, VoidCallback?

### Community 55 - "transaction_detail_components.dart"
Cohesion: 0.09
Nodes (23): Color?, HulyPayApp, AboutHulyPayScreen, PrivacySecurityScreen, _HeatmapGridWidget, backgroundColor, borderColor, build (+15 more)

### Community 56 - "ExpenseRepository"
Cohesion: 0.26
Nodes (3): AnalyticsService, ExpenseRepository, org.springframework.data.jpa.repository.Query

### Community 57 - "../models/payment_model.dart"
Cohesion: 0.20
Nodes (9): TransactionItem, PaymentModel, build, onTap, payment, transaction, ../models/dashboard_data.dart, ../models/payment_model.dart (+1 more)

### Community 58 - "dashboard/page.js"
Cohesion: 0.23
Nodes (15): TransactionsTable(), deleteTransaction(), getCategoryBreakdown(), getDailySpending(), getExpenses(), getMonthlySpending(), getSpendingSummary(), MOCK_CATEGORY_BREAKDOWN (+7 more)

### Community 61 - "CustomPainter"
Cohesion: 0.40
Nodes (5): CustomPainter, ScannerFramePainter, ScannerOverlayPainter, _MapGridPainter, _SpeedometerGaugePainter

### Community 69 - "features/page.js"
Cohesion: 0.25
Nodes (10): BellNotificationAnimation(), LockJwtAnimation(), PieChartAnimation(), EXTRA_PIXELS, MORPH_PIXELS, QrToTickAnimation(), WifiOfflineAnimation(), FEATURE_LIST (+2 more)

### Community 70 - "design/page.js"
Cohesion: 0.38
Nodes (7): DesignPage(), metadata, PALETTE, PRINCIPLES, Frame143Badge(), Frame144Badge(), Frame145Badge()

### Community 71 - "AnimatedSignature.js"
Cohesion: 0.16
Nodes (13): CIPHER_FLOW, PLAIN_FLOW, AnimatedSignature(), InitialLoader(), SIGNATURE_FILL_PATH, SIGNATURE_HEIGHT, SIGNATURE_MASK_PATH, SIGNATURE_STROKE_LENGTH (+5 more)

### Community 72 - "dependencies"
Cohesion: 0.17
Nodes (12): dependencies, clsx, gsap, @gsap/react, lenis, lucide-react, next, next-transition-router (+4 more)

### Community 73 - "react"
Cohesion: 0.27
Nodes (7): LoginContent(), DashboardButton(), Navbar(), ThemeToggle(), useAuth(), useTheme(), react

### Community 74 - "UserResponse"
Cohesion: 0.25
Nodes (6): UserResponse, GetMapping, PutMapping, RequestMapping, RestController, UserController

### Community 75 - "DashboardPage"
Cohesion: 0.31
Nodes (8): DashboardPage(), handleGlobalClick(), loadData(), DEFAULT_USER_PREFERENCES, getUserPreferences(), saveUserPreferences(), updateUserPreference(), USER_PREFERENCE_WEBSITE_KEY

### Community 76 - "customization_bottom_sheet.dart"
Cohesion: 0.22
Nodes (8): build, _buildChartPaletteOptionCard, _buildThemeOptionCard, createState, onThemeChanged, show, ../services/user_preferences_service.dart, ../theme/chart_colors.dart

### Community 77 - "devDependencies"
Cohesion: 0.33
Nodes (6): devDependencies, babel-plugin-react-compiler, eslint, eslint-config-next, tailwindcss, @tailwindcss/postcss

### Community 78 - "tools/page.js"
Cohesion: 0.16
Nodes (14): VeinTextFlow(), metadata, FAQ_DATA, QnaPage(), metadata, TECH_STACK_CATEGORIES, TOOLS, ToolsPage() (+6 more)

### Community 82 - "_HomeDashboardScreenState"
Cohesion: 0.33
Nodes (6): HomeDashboardScreen, _HomeDashboardScreenState, SignInScreen, _SignInScreenState, TickerProviderStateMixin, WidgetsBindingObserver

### Community 84 - "chart.jsx"
Cohesion: 0.18
Nodes (17): react, AreaChartSpending(), chartConfig, TIMEFRAMES, BarChartMonthly(), chartConfig, PieChartCategories(), chartConfig (+9 more)

### Community 85 - "BackendStatusBar.jsx"
Cohesion: 0.83
Nodes (3): BackendStatusBar(), verify(), checkBackendHealth()

### Community 88 - "analysis_category_pie_chart.dart"
Cohesion: 0.14
Nodes (14): List, AnalysisCategoryPieChart, _AnalysisCategoryPieChartState, bottomRightAction, build, centerLabel, createState, items (+6 more)

### Community 91 - "app_theme.dart"
Cohesion: 0.03
Nodes (62): AppThemeData get, Brightness, ColorScheme get, accent, AppRadii, AppSpacing, AppThemeManager, background (+54 more)

### Community 94 - "org.junit.jupiter.api.Test"
Cohesion: 0.06
Nodes (34): Category, AllArgsConstructor, Builder, Entity, Getter, NoArgsConstructor, Setter, Table (+26 more)

### Community 96 - "help_support_screen.dart"
Cohesion: 0.14
Nodes (13): build, _buildAppBar, _buildContactCard, _buildFaqItem, _buildFaqSection, _copyToClipboard, createState, _launchEmail (+5 more)

### Community 97 - "home_today_spend_gauge.dart"
Cohesion: 0.11
Nodes (18): dart:math, activeColor, build, _buildZoneIndicator, _computeTodaySpend, createState, _customLimit, dailyBudget (+10 more)

### Community 98 - "org.springframework.http.ResponseEntity"
Cohesion: 0.10
Nodes (28): AnalyticsController, CategoryController, DeleteMapping, GetMapping, PostMapping, PutMapping, RequestMapping, RestController (+20 more)

### Community 99 - "user_repository.dart"
Cohesion: 0.14
Nodes (13): _apiClient, getCachedUserProfile, getUserProfile, _instance, _localDb, saveUserProfile, UserRepository, LocalDatabaseService (+5 more)

### Community 100 - "spending_heatmap.dart"
Cohesion: 0.07
Nodes (27): build, _buildFooter, _buildGrid, _buildHeader, cells, columns, _computePeriodTotal, createState (+19 more)

### Community 102 - "google_pay_service.dart"
Cohesion: 0.05
Nodes (36): amazonPayPackage, amount, approvalRefNo, _channel, errorMessage, fromNativeMap, fromQueryString, googlePayPackage (+28 more)

### Community 103 - "package:flutter/material.dart"
Cohesion: 0.09
Nodes (22): ../data/external_data.dart, build, _buildAppBar, _buildCurrentlyInDevelopmentCard, NotificationsScreen, build, _buildAppBar, _buildSectionHeader (+14 more)

### Community 105 - "payment_repository.dart"
Cohesion: 0.12
Nodes (15): _apiClient, cleanupStalePayments, createPayment, deletePayment, getCachedPayments, getPaymentById, getPayments, _instance (+7 more)

### Community 108 - "AuthContext.js"
Cohesion: 0.21
Nodes (9): AuthContext, AuthProvider(), getInitialAuth(), getCurrentUserProfile(), signInWithGitHub(), signInWithGoogle(), signOut(), supabase (+1 more)

### Community 109 - "home_weekly_bar_chart.dart"
Cohesion: 0.12
Nodes (17): build, _buildBarChartData, _buildLegendItem, _calculateMax, _computeWeeklyData, createState, _defaultBarColor, _getBottomTitles (+9 more)

### Community 112 - "app/page.js"
Cohesion: 0.29
Nodes (4): Features(), Hero(), PARALLAX_CONFIG, Workflow()

### Community 114 - "qr_share_service.dart"
Cohesion: 0.15
Nodes (12): dart:io, _channel, googlePayPackage, pickAndShareQrImage, pickQrImage, QrShareService, shareQrImage, _showSnackBar (+4 more)

## Knowledge Gaps
- **1025 isolated node(s):** `com.hulypay:backend`, `INITIATED`, `PAYMENT_INITIATED`, `PENDING`, `CONFIRMED` (+1020 more)
  These have ≤1 connection - possible missing edges or undocumented components. (Counts symbols only; 1225 node(s) total have ≤1 connection when file, concept and rationale nodes are included.)
- **20 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `_SplashScreenState` connect `State` to `splash_screen.dart`?**
  _High betweenness centrality (0.007) - this node is a cross-community bridge._
- **Why does `User` connect `User` to `org.springframework.http.ResponseEntity`, `UserResponse`, `lombok.AllArgsConstructor`, `PaymentService.java`, `ExpenseRepository`, `org.junit.jupiter.api.Test`?**
  _High betweenness centrality (0.007) - this node is a cross-community bridge._
- **Why does `react` connect `react` to `features/page.js`, `design/page.js`, `AnimatedSignature.js`, `layout.js`, `AuthContext.js`, `tools/page.js`, `app/page.js`, `chart.jsx`, `package.json`, `BackendStatusBar.jsx`, `dashboard/page.js`?**
  _High betweenness centrality (0.006) - this node is a cross-community bridge._
- **What connects `com.hulypay:backend`, `INITIATED`, `PAYMENT_INITIATED` to the rest of the system?**
  _1025 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `home_spend_trend_line_chart.dart` be split into smaller, more focused modules?**
  _Cohesion score 0.08695652173913043 - nodes in this community are weakly interconnected._
- **Should `location_service.dart` be split into smaller, more focused modules?**
  _Cohesion score 0.08695652173913043 - nodes in this community are weakly interconnected._
- **Should `upi_service.dart` be split into smaller, more focused modules?**
  _Cohesion score 0.1111111111111111 - nodes in this community are weakly interconnected._