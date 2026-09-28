# Graph Report - Huly.pay  (2026-09-28)

## Corpus Check
- 178 files · ~133,363 words
- Verdict: corpus is large enough that graph structure adds value.

## Summary
- 1830 nodes · 3099 edges · 99 communities (72 shown, 18 thin omitted)
- Extraction: 97% EXTRACTED · 3% INFERRED · 0% AMBIGUOUS · INFERRED: 87 edges (avg confidence: 0.81)
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `e501479f`
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
- package:flutter/material.dart
- StatelessWidget
- ExpenseRepository
- ../models/payment_model.dart
- ThemeContext.js
- hulypay/MainActivity.kt
- LaunchImage.imageset/README.md
- CustomPainter
- Navbar.js
- SingleTransactionScreen
- hulypay/README.md
- features/page.js
- design/page.js
- AnimatedSignature.js
- tools/page.js
- AGENTS.md
- eslint.config.mjs
- postcss.config.mjs
- dashboard/page.js
- analysis_category_pie_chart.dart
- com.hulypay:backend
- app_theme.dart
- rules/graphify.md
- workflows/graphify.md
- org.junit.jupiter.api.Test
- jakarta.annotation.PostConstruct
- help_support_screen.dart
- home_today_spend_gauge.dart
- org.springframework.http.ResponseEntity
- user_repository.dart
- spending_heatmap.dart
- google_pay_service.dart
- ../theme/app_theme.dart
- payment_repository.dart
- AuthContext.js
- home_weekly_bar_chart.dart
- react
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
- `AnalyticsService` --references--> `ExpenseRepository`  [EXTRACTED]
  backend/src/main/java/com/hulypay/backend/analytics/AnalyticsService.java → backend/src/main/java/com/hulypay/backend/expenses/ExpenseRepository.java
- `Category` --references--> `User`  [EXTRACTED]
  backend/src/main/java/com/hulypay/backend/categories/Category.java → backend/src/main/java/com/hulypay/backend/users/User.java
- `Expense` --references--> `Category`  [EXTRACTED]
  backend/src/main/java/com/hulypay/backend/expenses/Expense.java → backend/src/main/java/com/hulypay/backend/categories/Category.java
- `CategoryController` --references--> `CategoryService`  [EXTRACTED]
  backend/src/main/java/com/hulypay/backend/categories/CategoryController.java → backend/src/main/java/com/hulypay/backend/categories/CategoryService.java
- `CategoryService` --references--> `CategoryRepository`  [EXTRACTED]
  backend/src/main/java/com/hulypay/backend/categories/CategoryService.java → backend/src/main/java/com/hulypay/backend/categories/CategoryRepository.java

## Import Cycles
- None detected.

## Communities (99 total, 18 thin omitted)

### Community 0 - "home_spend_trend_line_chart.dart"
Cohesion: 0.09
Nodes (21): amount, _bottomTitleWidgets, build, _buildCardFooter, _buildCardHeader, _buildCurvedGradientData, _buildDualZoneData, _calculateMaxY (+13 more)

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
Nodes (10): dotoFont, geistMono, geistSans, metadata, pixelifySans, SmoothScroll(), AnimatedSignature(), InitialLoader() (+2 more)

### Community 8 - "home_dashboard_screen.dart"
Cohesion: 0.06
Nodes (35): Animation, _applyData, build, _buildAvatarFallback, _buildBody, _buildDashboardContent, _buildQuickActions, _buildTotalSpentCard (+27 more)

### Community 9 - "settings_screen.dart"
Cohesion: 0.06
Nodes (32): about_hulypay_screen.dart, help_support_screen.dart, appVersion, _avatarUrl, build, _buildChartPaletteOptionCard, _buildGroupCard, _buildLogoutCard (+24 more)

### Community 10 - "transactions_screen.dart"
Cohesion: 0.08
Nodes (25): analysis_screen.dart, _allGroups, build, _buildFilterChips, _buildSearchBar, createState, dispose, _filterActivePayments (+17 more)

### Community 11 - "payment_model.dart"
Cohesion: 0.07
Nodes (27): dashboard_data.dart, amount, copyWith, createdAt, CreatePaymentPayload, currency, expenseId, fromJson (+19 more)

### Community 12 - "lombok.AllArgsConstructor"
Cohesion: 0.10
Nodes (34): CategoryBreakdownResponse, DailySpendingResponse, MonthlySpendingResponse, SpendingSummaryResponse, CategoryRequest, CreateExpenseRequest, UpdateExpenseRequest, CreatePaymentRequest (+26 more)

### Community 13 - "analysis_screen.dart"
Cohesion: 0.06
Nodes (34): _allPayments, build, _buildCategoryList, _buildClassificationToggleButton, _buildHeader, _categories, _categoryOverrides, _classificationMode (+26 more)

### Community 14 - "user_preferences_service.dart"
Cohesion: 0.06
Nodes (35): double? get, local_database_service.dart, _cachedAnalysisPeriod, _cachedDailyLimit, _cachedDefaultPaymentApp, _cachedQuickConfirm, _cachedQuickScan, _client (+27 more)

### Community 15 - "scan_and_pay_screen.dart"
Cohesion: 0.05
Nodes (41): DateTime?, _amountController, build, cornerColor, cornerLength, cornerRadius, createState, cutoutRect (+33 more)

### Community 16 - "ErrorResponse"
Cohesion: 0.20
Nodes (11): ErrorResponse, GlobalExceptionHandler, NoResourceFoundException, org.springframework.dao.DataIntegrityViolationException, org.springframework.security.access.AccessDeniedException, org.springframework.security.core.AuthenticationException, org.springframework.web.bind.annotation.ExceptionHandler, org.springframework.web.bind.annotation.RestControllerAdvice (+3 more)

### Community 17 - "upload_qr_screen.dart"
Cohesion: 0.10
Nodes (21): _amountController, _amountFocusNode, build, createState, dispose, _handleUploadButton, initialAmount, initState (+13 more)

### Community 18 - "SecurityConfig.java"
Cohesion: 0.21
Nodes (11): OpenApiConfig, SecurityConfig, io.swagger.v3.oas.models.OpenAPI, JwtDecoder, OpenAPI, org.springframework.context.annotation.Bean, org.springframework.context.annotation.Configuration, org.springframework.security.config.annotation.web.builders.HttpSecurity (+3 more)

### Community 19 - "User"
Cohesion: 0.09
Nodes (25): GetMapping, CategoryService, CategoryResponse, BadRequestException, ResourceNotFoundException, ExpenseResponse, Expense, AllArgsConstructor (+17 more)

### Community 20 - "single_transaction_screen.dart"
Cohesion: 0.04
Nodes (52): DraggableScrollableNotification, GoogleMapController?, _accuracy, build, _buildActionButton, _buildDarkMapFallbackCanvas, _buildDetailRow, _buildDetailsCard (+44 more)

### Community 21 - "package.json"
Cohesion: 0.05
Nodes (39): dependencies, clsx, gsap, @gsap/react, lenis, lucide-react, next, next-transition-router (+31 more)

### Community 22 - "DatabaseHealthController"
Cohesion: 0.23
Nodes (7): DatabaseHealthController, DatabaseHealthResponse, HealthController, HealthResponse, java.util.Map, javax.sql.DataSource, org.springframework.web.bind.annotation.RestController

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
Nodes (23): AnimationController, Duration, build, _controller, createState, dispose, duration, _hasLocalUser (+15 more)

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
Cohesion: 0.14
Nodes (13): build, home, initializeAuth, isAuthenticated, main, nextScreen, showSplash, widgetsBinding (+5 more)

### Community 34 - "external_data.dart"
Cohesion: 0.02
Nodes (80): Acceptance of, Account, Changes to, Contact Regarding, Disclaimer of, Information We, aboutEnvironmentNoticeBody, aboutEnvironmentNoticeTitle (+72 more)

### Community 35 - "💳 HulyPay — Next-Gen Intelligent Fintech App"
Cohesion: 0.11
Nodes (17): 1. Prerequisites, 2. Clone Repository & Setup, 3. Environment Configuration, 4. Run on Android, 5. Run on iOS (macOS required), Core Features, 👨‍💻 Developer & Contributing, Folder Structure (+9 more)

### Community 36 - "State"
Cohesion: 0.13
Nodes (22): AnalysisScreen, _AnalysisScreenState, HelpSupportScreen, _HelpSupportScreenState, HomeDashboardScreen, _HomeDashboardScreenState, SignInScreen, _SignInScreenState (+14 more)

### Community 37 - "user_profile.dart"
Cohesion: 0.14
Nodes (13): active, authProvider, avatarUrl, copyWith, email, firstName, fromJson, fullName (+5 more)

### Community 38 - "auth_service.dart"
Cohesion: 0.07
Nodes (26): AuthService, client, currentAccessToken, currentSession, currentUser, hasValidActiveToken, initialize, _initialized (+18 more)

### Community 40 - "sign_in_screen.dart"
Cohesion: 0.09
Nodes (22): dart:async, home_dashboard_screen.dart, _authSubscription, _authTimeoutTimer, build, createState, didChangeAppLifecycleState, dispose (+14 more)

### Community 41 - "scan_amount_screen.dart"
Cohesion: 0.12
Nodes (16): double?, FocusNode, _amountController, _amountFocusNode, build, createState, dispose, _handleScanButton (+8 more)

### Community 42 - "README.md"
Cohesion: 0.50
Nodes (3): Deploy on Vercel, Getting Started, Learn More

### Community 45 - "about_hulypay_screen.dart"
Cohesion: 0.15
Nodes (12): appVersion, build, _buildAppBar, _buildCreatorSection, _buildEnvironmentNoticeCard, _buildFeatureHighlights, _buildFeatureItem, _buildHeroBrandCard (+4 more)

### Community 47 - "PaymentService.java"
Cohesion: 0.16
Nodes (21): AnalyticsController, AnalyticsService, CategoryController, RequestMapping, RestController, RequestMapping, RestController, PaymentController (+13 more)

### Community 51 - "payment_methods_screen.dart"
Cohesion: 0.12
Nodes (17): Map, build, _buildAppBar, _buildInstalledAppsList, _buildPaymentAppCard, _buildSectionTitle, createState, initState (+9 more)

### Community 53 - "MaterialPageRoute"
Cohesion: 0.18
Nodes (11): MaterialPageRoute, _buildHeader, _openUploadQr, _showPaymentConfirmationModal, _startSmsVerificationWorkflow, _buildAccountSection, _buildNotificationsSection, _buildSupportSection (+3 more)

### Community 54 - "package:flutter/material.dart"
Cohesion: 0.13
Nodes (14): IconData?, build, icon, label, onTap, svgAsset, build, _buildNavItem (+6 more)

### Community 55 - "StatelessWidget"
Cohesion: 0.22
Nodes (9): HulyPayApp, AboutHulyPayScreen, NotificationsScreen, PrivacySecurityScreen, QuickActionButton, CustomBottomNavBar, _HeatmapGridWidget, TransactionTile (+1 more)

### Community 56 - "ExpenseRepository"
Cohesion: 0.20
Nodes (6): ExpenseRepository, PaymentRepository, UserRepository, org.springframework.data.jpa.repository.JpaRepository, org.springframework.data.jpa.repository.Query, org.springframework.stereotype.Repository

### Community 57 - "../models/payment_model.dart"
Cohesion: 0.22
Nodes (8): TransactionItem, PaymentModel, onTap, payment, transaction, ../models/dashboard_data.dart, ../models/payment_model.dart, ../screens/single_transaction_screen.dart

### Community 58 - "ThemeContext.js"
Cohesion: 0.36
Nodes (8): emptySubscribe(), getServerSnapshot(), getSnapshot(), listeners, notifyListeners(), subscribe(), ThemeContext, ThemeProvider()

### Community 61 - "CustomPainter"
Cohesion: 0.40
Nodes (5): CustomPainter, ScannerFramePainter, ScannerOverlayPainter, _MapGridPainter, _SpeedometerGaugePainter

### Community 66 - "Navbar.js"
Cohesion: 0.13
Nodes (6): LoginContent(), NAV_BG_ASSETS, NAV_BG_SVGS, DashboardButton(), Navbar(), useAuth()

### Community 69 - "features/page.js"
Cohesion: 0.25
Nodes (10): BellNotificationAnimation(), LockJwtAnimation(), PieChartAnimation(), EXTRA_PIXELS, MORPH_PIXELS, QrToTickAnimation(), WifiOfflineAnimation(), FEATURE_LIST (+2 more)

### Community 70 - "design/page.js"
Cohesion: 0.38
Nodes (7): DesignPage(), metadata, PALETTE, PRINCIPLES, Frame143Badge(), Frame144Badge(), Frame145Badge()

### Community 71 - "AnimatedSignature.js"
Cohesion: 0.46
Nodes (6): SIGNATURE_FILL_PATH, SIGNATURE_HEIGHT, SIGNATURE_MASK_PATH, SIGNATURE_STROKE_LENGTH, SIGNATURE_VIEWBOX, SIGNATURE_WIDTH

### Community 78 - "tools/page.js"
Cohesion: 0.16
Nodes (14): VeinTextFlow(), metadata, FAQ_DATA, QnaPage(), metadata, TECH_STACK_CATEGORIES, TOOLS, ToolsPage() (+6 more)

### Community 84 - "dashboard/page.js"
Cohesion: 0.08
Nodes (45): react, DashboardPage(), handleGlobalClick(), loadData(), AreaChartSpending(), chartConfig, TIMEFRAMES, BackendStatusBar() (+37 more)

### Community 88 - "analysis_category_pie_chart.dart"
Cohesion: 0.15
Nodes (12): List, bottomRightAction, build, centerLabel, createState, items, showCardBackground, _showingSections (+4 more)

### Community 91 - "app_theme.dart"
Cohesion: 0.03
Nodes (62): AppThemeData get, Brightness, ColorScheme get, accent, AppRadii, AppSpacing, AppThemeManager, background (+54 more)

### Community 94 - "org.junit.jupiter.api.Test"
Cohesion: 0.06
Nodes (30): Category, AllArgsConstructor, Builder, Entity, Getter, NoArgsConstructor, Setter, Table (+22 more)

### Community 95 - "jakarta.annotation.PostConstruct"
Cohesion: 0.36
Nodes (3): BackendApplication, jakarta.annotation.PostConstruct, org.springframework.boot.autoconfigure.SpringBootApplication

### Community 96 - "help_support_screen.dart"
Cohesion: 0.14
Nodes (13): build, _buildAppBar, _buildDeveloperWebsiteCard, _buildEmailContactCard, _buildFaqItem, _buildFaqSection, _copyToClipboard, createState (+5 more)

### Community 97 - "home_today_spend_gauge.dart"
Cohesion: 0.10
Nodes (19): Color, dart:math, activeColor, build, _buildZoneIndicator, _computeTodaySpend, createState, _customLimit (+11 more)

### Community 98 - "org.springframework.http.ResponseEntity"
Cohesion: 0.13
Nodes (16): DeleteMapping, PostMapping, PutMapping, ExpenseController, DeleteMapping, GetMapping, PostMapping, PutMapping (+8 more)

### Community 99 - "user_repository.dart"
Cohesion: 0.14
Nodes (13): _apiClient, getCachedUserProfile, getUserProfile, _instance, _localDb, saveUserProfile, UserRepository, ApiClient (+5 more)

### Community 100 - "spending_heatmap.dart"
Cohesion: 0.08
Nodes (25): build, _buildFooter, _buildGrid, _buildHeader, cells, columns, _computePeriodTotal, createState (+17 more)

### Community 102 - "google_pay_service.dart"
Cohesion: 0.05
Nodes (36): amazonPayPackage, amount, approvalRefNo, _channel, errorMessage, fromNativeMap, fromQueryString, googlePayPackage (+28 more)

### Community 103 - "../theme/app_theme.dart"
Cohesion: 0.12
Nodes (15): ../data/external_data.dart, build, _buildAppBar, _buildCurrentlyInDevelopmentCard, build, _buildAppBar, _buildBulletPoint, _buildDataCollectionCard (+7 more)

### Community 105 - "payment_repository.dart"
Cohesion: 0.13
Nodes (14): _apiClient, cleanupStalePayments, createPayment, getCachedPayments, getPaymentById, getPayments, _instance, _localDb (+6 more)

### Community 108 - "AuthContext.js"
Cohesion: 0.21
Nodes (9): AuthContext, AuthProvider(), getInitialAuth(), getCurrentUserProfile(), signInWithGitHub(), signInWithGoogle(), signOut(), supabase (+1 more)

### Community 109 - "home_weekly_bar_chart.dart"
Cohesion: 0.12
Nodes (16): build, _buildBarChartData, _buildLegendItem, _calculateMax, _computeWeeklyData, createState, _defaultBarColor, _getBottomTitles (+8 more)

### Community 112 - "react"
Cohesion: 0.18
Nodes (8): CIPHER_FLOW, PLAIN_FLOW, Features(), Hero(), PARALLAX_CONFIG, Workflow(), gsap, react

### Community 114 - "qr_share_service.dart"
Cohesion: 0.14
Nodes (13): dart:io, _channel, googlePayPackage, pickAndShareQrImage, pickQrImage, QrShareService, shareQrImage, _showSnackBar (+5 more)

## Knowledge Gaps
- **985 isolated node(s):** `com.hulypay:backend`, `INITIATED`, `PAYMENT_INITIATED`, `PENDING`, `CONFIRMED` (+980 more)
  These have ≤1 connection - possible missing edges or undocumented components. (Counts symbols only; 1182 node(s) total have ≤1 connection when file, concept and rationale nodes are included.)
- **18 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `User` connect `User` to `org.springframework.http.ResponseEntity`, `lombok.AllArgsConstructor`, `PaymentService.java`, `ExpenseRepository`, `org.junit.jupiter.api.Test`?**
  _High betweenness centrality (0.008) - this node is a cross-community bridge._
- **Why does `react` connect `react` to `Navbar.js`, `features/page.js`, `design/page.js`, `AnimatedSignature.js`, `layout.js`, `AuthContext.js`, `tools/page.js`, `dashboard/page.js`, `package.json`, `ThemeContext.js`?**
  _High betweenness centrality (0.006) - this node is a cross-community bridge._
- **Why does `PaymentStatus` connect `lombok.AllArgsConstructor` to `org.junit.jupiter.api.Test`?**
  _High betweenness centrality (0.005) - this node is a cross-community bridge._
- **What connects `com.hulypay:backend`, `INITIATED`, `PAYMENT_INITIATED` to the rest of the system?**
  _985 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `home_spend_trend_line_chart.dart` be split into smaller, more focused modules?**
  _Cohesion score 0.09090909090909091 - nodes in this community are weakly interconnected._
- **Should `location_service.dart` be split into smaller, more focused modules?**
  _Cohesion score 0.08695652173913043 - nodes in this community are weakly interconnected._
- **Should `upi_service.dart` be split into smaller, more focused modules?**
  _Cohesion score 0.1111111111111111 - nodes in this community are weakly interconnected._