# Graph Report - Huly.pay  (2026-09-30)

## Corpus Check
- 165 files · ~132,101 words
- Verdict: corpus is large enough that graph structure adds value.

## Summary
- 1781 nodes · 2864 edges · 93 communities (72 shown, 16 thin omitted)
- Extraction: 97% EXTRACTED · 3% INFERRED · 0% AMBIGUOUS · INFERRED: 72 edges (avg confidence: 0.81)
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `cba4d0d0`
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
- org.springframework.http.ResponseEntity
- home_dashboard_screen.dart
- settings_screen.dart
- transactions_screen.dart
- payment_model.dart
- lombok.AllArgsConstructor
- analysis_screen.dart
- user_preferences_service.dart
- scan_and_pay_screen.dart
- ThemeContext.js
- upload_qr_screen.dart
- SecurityConfig.java
- SingleTransactionScreen
- single_transaction_screen.dart
- package.json
- DatabaseHealthController
- User
- api_client.dart
- MainActivity
- Docker Compose Configuration
- mvnw
- splash_screen.dart
- package:flutter/foundation.dart
- Transaction
- chart_colors.dart
- dashboard/page.js
- main.dart
- external_data.dart
- 💳 HulyPay — Next-Gen Intelligent Fintech Platform
- State
- user_profile.dart
- auth_service.dart
- AppThemeContextExtension
- sign_in_screen.dart
- scan_amount_screen.dart
- README.md
- compilerOptions
- next.config.mjs
- customization_bottom_sheet.dart
- about_hulypay_screen.dart
- TransactionRepository
- AppThemeData
- action_button.dart
- AnimatedSignature.js
- payment_methods_screen.dart
- StatelessWidget
- MaterialPageRoute
- EnvelopeEncryptionService
- transaction_detail_components.dart
- .updateCurrentUser
- ../models/payment_model.dart
- api.js
- hulypay/MainActivity.kt
- LaunchImage.imageset/README.md
- CustomPainter
- EncryptedStringConverter
- hulypay/README.md
- layout.js
- package:flutter/material.dart
- features/page.js
- AGENTS.md
- eslint.config.mjs
- postcss.config.mjs
- react
- analysis_category_pie_chart.dart
- com.hulypay:backend
- app_theme.dart
- rules/graphify.md
- workflows/graphify.md
- org.junit.jupiter.api.Test
- help_support_screen.dart
- home_today_spend_gauge.dart
- org.springframework.security.oauth2.jwt.Jwt
- spending_heatmap.dart
- google_pay_service.dart
- ../theme/app_theme.dart
- payment_repository.dart
- AuthContext.js
- home_weekly_bar_chart.dart
- bool?
- qr_share_service.dart

## God Nodes (most connected - your core abstractions)
1. `User` - 35 edges
2. `Transaction` - 26 edges
3. `react` - 22 edges
4. `TransactionResponse` - 18 edges
5. `ErrorResponse` - 16 edges
6. `TransactionRepository` - 16 edges
7. `TransactionService` - 15 edges
8. `MainActivity` - 15 edges
9. `EnvelopeEncryptionService` - 14 edges
10. `UserService` - 14 edges

## Surprising Connections (you probably didn't know these)
- `AnalyticsController` --references--> `AnalyticsService`  [EXTRACTED]
  backend/src/main/java/com/hulypay/backend/Controllers/AnalyticsController.java → backend/src/main/java/com/hulypay/backend/Services/AnalyticsService.java
- `AnalyticsController` --references--> `UserService`  [EXTRACTED]
  backend/src/main/java/com/hulypay/backend/Controllers/AnalyticsController.java → backend/src/main/java/com/hulypay/backend/Services/UserService.java
- `TransactionController` --references--> `TransactionService`  [EXTRACTED]
  backend/src/main/java/com/hulypay/backend/Controllers/TransactionController.java → backend/src/main/java/com/hulypay/backend/Services/TransactionService.java
- `TransactionController` --references--> `UserService`  [EXTRACTED]
  backend/src/main/java/com/hulypay/backend/Controllers/TransactionController.java → backend/src/main/java/com/hulypay/backend/Services/UserService.java
- `UserController` --references--> `UserService`  [EXTRACTED]
  backend/src/main/java/com/hulypay/backend/Controllers/UserController.java → backend/src/main/java/com/hulypay/backend/Services/UserService.java

## Import Cycles
- None detected.

## Communities (93 total, 16 thin omitted)

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
Nodes (40): Database?, cleanupStalePayments, clearAll, clearPayments, clearUserProfile, close, _db, dbName (+32 more)

### Community 7 - "org.springframework.http.ResponseEntity"
Cohesion: 0.23
Nodes (12): ErrorResponse, GlobalExceptionHandler, NoResourceFoundException, org.springframework.dao.DataIntegrityViolationException, org.springframework.http.ResponseEntity, org.springframework.security.access.AccessDeniedException, org.springframework.security.core.AuthenticationException, org.springframework.web.bind.annotation.ExceptionHandler (+4 more)

### Community 8 - "home_dashboard_screen.dart"
Cohesion: 0.06
Nodes (35): Animation, _applyData, build, _buildAvatarFallback, _buildBody, _buildDashboardContent, _buildQuickActions, _buildTotalSpentCard (+27 more)

### Community 9 - "settings_screen.dart"
Cohesion: 0.06
Nodes (32): about_hulypay_screen.dart, help_support_screen.dart, appVersion, _avatarUrl, build, _buildAppInfoFooter, _buildGroupCard, _buildLogoutCard (+24 more)

### Community 10 - "transactions_screen.dart"
Cohesion: 0.08
Nodes (23): analysis_screen.dart, _allGroups, build, _buildFilterChips, _buildSearchBar, createState, dispose, _filterActivePayments (+15 more)

### Community 11 - "payment_model.dart"
Cohesion: 0.07
Nodes (28): dashboard_data.dart, amount, category, copyWith, createdAt, CreatePaymentPayload, currency, expenseId (+20 more)

### Community 12 - "lombok.AllArgsConstructor"
Cohesion: 0.24
Nodes (17): CreateTransactionRequest, TransactionReconcileRequest, TransactionSmsVerificationRequest, UpdateTransactionRequest, UpdateUserRequest, CategoryBreakdownResponse, DailySpendingResponse, MonthlySpendingResponse (+9 more)

### Community 13 - "analysis_screen.dart"
Cohesion: 0.06
Nodes (35): _allPayments, build, _buildCategoryList, _buildClassificationToggleButton, _buildHeader, _categories, _categoryOverrides, _classificationMode (+27 more)

### Community 14 - "user_preferences_service.dart"
Cohesion: 0.06
Nodes (31): double? get, local_database_service.dart, _cachedAnalysisPeriod, _cachedDailyLimit, _cachedDefaultPaymentApp, _cachedQuickConfirm, _cachedQuickScan, getAnalysisPeriod (+23 more)

### Community 15 - "scan_and_pay_screen.dart"
Cohesion: 0.05
Nodes (39): DateTime?, _amountController, build, cornerColor, cornerLength, cornerRadius, createState, cutoutRect (+31 more)

### Community 16 - "ThemeContext.js"
Cohesion: 0.27
Nodes (10): ThemeToggle(), emptySubscribe(), getServerSnapshot(), getSnapshot(), listeners, notifyListeners(), subscribe(), ThemeContext (+2 more)

### Community 17 - "upload_qr_screen.dart"
Cohesion: 0.10
Nodes (21): _amountController, _amountFocusNode, build, createState, dispose, _handleUploadButton, initialAmount, initState (+13 more)

### Community 18 - "SecurityConfig.java"
Cohesion: 0.12
Nodes (16): BackendApplication, DataSource, OpenApiConfig, SecurityConfig, CommandLineRunner, io.swagger.v3.oas.models.OpenAPI, jakarta.annotation.PostConstruct, JwtDecoder (+8 more)

### Community 20 - "single_transaction_screen.dart"
Cohesion: 0.04
Nodes (51): DraggableScrollableNotification, GoogleMapController?, _accuracy, build, _buildDarkMapFallbackCanvas, _buildDetailsCard, _buildGoogleMapContent, _buildGoogleMapOrStreetView (+43 more)

### Community 21 - "package.json"
Cohesion: 0.05
Nodes (39): dependencies, clsx, gsap, @gsap/react, lenis, lucide-react, next, next-transition-router (+31 more)

### Community 22 - "DatabaseHealthController"
Cohesion: 0.23
Nodes (7): DatabaseHealthController, DatabaseHealthResponse, HealthController, HealthResponse, java.util.Map, javax.sql.DataSource, org.springframework.web.bind.annotation.RestController

### Community 23 - "User"
Cohesion: 0.12
Nodes (19): BadRequestException, ResourceNotFoundException, AllArgsConstructor, Builder, Entity, Getter, NoArgsConstructor, Setter (+11 more)

### Community 24 - "api_client.dart"
Cohesion: 0.08
Nodes (25): auth_service.dart, Dio, Exception, int?, ApiException, createPayment, data, defaultAndroidHost (+17 more)

### Community 25 - "MainActivity"
Cohesion: 0.20
Nodes (9): Context, FlutterEngine, IntArray, Intent, MethodChannel, FlutterActivity, MainActivity, BroadcastReceiver (+1 more)

### Community 27 - "mvnw"
Cohesion: 0.38
Nodes (8): mvnw script, clean(), die(), exec_maven(), hash_string(), set_java_home(), trim(), verbose()

### Community 28 - "splash_screen.dart"
Cohesion: 0.08
Nodes (24): AnimationController, Duration, build, _controller, createState, dispose, duration, _hasLocalUser (+16 more)

### Community 29 - "package:flutter/foundation.dart"
Cohesion: 0.22
Nodes (8): dart:convert, getEmail, getExpirationDate, getPayload, getSubject, isExpired, TokenValidator, package:flutter/foundation.dart

### Community 30 - "Transaction"
Cohesion: 0.15
Nodes (12): AllArgsConstructor, Builder, Entity, Getter, NoArgsConstructor, Setter, Table, Transaction (+4 more)

### Community 31 - "chart_colors.dart"
Cohesion: 0.06
Nodes (33): app_theme.dart, financialKeywords, isFinancialTransactionSms, SmsFilterService, allPalettes, amber, AppChartColors, barDefault (+25 more)

### Community 32 - "dashboard/page.js"
Cohesion: 0.29
Nodes (8): DashboardPage(), handleGlobalClick(), TransactionsTable(), DEFAULT_USER_PREFERENCES, getUserPreferences(), saveUserPreferences(), updateUserPreference(), USER_PREFERENCE_WEBSITE_KEY

### Community 33 - "main.dart"
Cohesion: 0.15
Nodes (12): build, home, initializeAuth, isAuthenticated, main, nextScreen, showSplash, widgetsBinding (+4 more)

### Community 34 - "external_data.dart"
Cohesion: 0.02
Nodes (110): Acceptance of, Account, Changes to, Contact Regarding, Disclaimer of, Information We, aboutEnvironmentNoticeBody, aboutEnvironmentNoticeTitle (+102 more)

### Community 35 - "💳 HulyPay — Next-Gen Intelligent Fintech Platform"
Cohesion: 0.07
Nodes (28): 1. Prerequisites, 2. Clone Repository & Setup, 3. Environment Configuration, 4. Run on Android, 5. Run on iOS (macOS required), ⚙️ Backend (Spring Boot), Build for Production, Core Features (+20 more)

### Community 36 - "State"
Cohesion: 0.13
Nodes (22): AnalysisScreen, _AnalysisScreenState, HelpSupportScreen, _HelpSupportScreenState, HomeDashboardScreen, _HomeDashboardScreenState, ScanAmountScreen, _ScanAmountScreenState (+14 more)

### Community 37 - "user_profile.dart"
Cohesion: 0.13
Nodes (14): active, authProvider, avatarUrl, copyWith, email, firstName, fromJson, fullName (+6 more)

### Community 38 - "auth_service.dart"
Cohesion: 0.08
Nodes (25): AuthService, client, currentAccessToken, currentSession, currentUser, hasValidActiveToken, initialize, _initialized (+17 more)

### Community 40 - "sign_in_screen.dart"
Cohesion: 0.09
Nodes (22): dart:async, home_dashboard_screen.dart, _authSubscription, _authTimeoutTimer, build, createState, didChangeAppLifecycleState, dispose (+14 more)

### Community 41 - "scan_amount_screen.dart"
Cohesion: 0.13
Nodes (14): double?, FocusNode, _amountController, _amountFocusNode, build, createState, dispose, _handleScanButton (+6 more)

### Community 42 - "README.md"
Cohesion: 0.50
Nodes (3): Deploy on Vercel, Getting Started, Learn More

### Community 45 - "customization_bottom_sheet.dart"
Cohesion: 0.22
Nodes (8): build, _buildChartPaletteOptionCard, _buildThemeOptionCard, createState, onThemeChanged, show, ../services/user_preferences_service.dart, ../theme/chart_colors.dart

### Community 46 - "about_hulypay_screen.dart"
Cohesion: 0.20
Nodes (9): appVersion, build, _buildAppBar, _buildCreatorSection, _buildHeroBrandCard, _buildSpecRow, _buildSpecsCard, _launchUrl (+1 more)

### Community 47 - "TransactionRepository"
Cohesion: 0.22
Nodes (5): TransactionRepository, UserRepository, org.springframework.data.jpa.repository.JpaRepository, org.springframework.data.jpa.repository.Query, org.springframework.stereotype.Repository

### Community 49 - "action_button.dart"
Cohesion: 0.22
Nodes (8): IconData, build, icon, label, onTap, QuickActionButton, svgAsset, VoidCallback?

### Community 50 - "AnimatedSignature.js"
Cohesion: 0.46
Nodes (6): SIGNATURE_FILL_PATH, SIGNATURE_HEIGHT, SIGNATURE_MASK_PATH, SIGNATURE_STROKE_LENGTH, SIGNATURE_VIEWBOX, SIGNATURE_WIDTH

### Community 51 - "payment_methods_screen.dart"
Cohesion: 0.12
Nodes (17): Map, build, _buildAppBar, _buildInstalledAppsList, _buildPaymentAppCard, _buildSectionTitle, createState, initState (+9 more)

### Community 52 - "StatelessWidget"
Cohesion: 0.25
Nodes (8): HulyPayApp, AboutHulyPayScreen, CategoryPickerSheet, _HeatmapGridWidget, TransactionActionButton, TransactionDetailRow, TransactionTile, StatelessWidget

### Community 53 - "MaterialPageRoute"
Cohesion: 0.20
Nodes (10): MaterialPageRoute, _buildHeader, _openUploadQr, _showPaymentConfirmationModal, _startSmsVerificationWorkflow, _buildAccountSection, _buildNotificationsSection, _buildSupportSection (+2 more)

### Community 54 - "EnvelopeEncryptionService"
Cohesion: 0.27
Nodes (4): EnvelopeEncryptionService, EnvelopeEncryptionServiceTests, java.security.SecureRandom, javax.crypto.SecretKey

### Community 55 - "transaction_detail_components.dart"
Cohesion: 0.12
Nodes (15): Color?, backgroundColor, borderColor, build, canCopy, icon, iconColor, isPrimary (+7 more)

### Community 56 - ".updateCurrentUser"
Cohesion: 0.27
Nodes (6): GetMapping, PutMapping, RequestMapping, RestController, UserController, UserResponse

### Community 57 - "../models/payment_model.dart"
Cohesion: 0.20
Nodes (9): TransactionItem, PaymentModel, build, onTap, payment, transaction, ../models/dashboard_data.dart, ../models/payment_model.dart (+1 more)

### Community 58 - "api.js"
Cohesion: 0.18
Nodes (18): loadData(), BackendStatusBar(), verify(), checkBackendHealth(), deleteTransaction(), getCategoryBreakdown(), getDailySpending(), getExpenses() (+10 more)

### Community 61 - "CustomPainter"
Cohesion: 0.40
Nodes (5): CustomPainter, ScannerFramePainter, ScannerOverlayPainter, _MapGridPainter, _SpeedometerGaugePainter

### Community 66 - "EncryptedStringConverter"
Cohesion: 0.36
Nodes (5): EncryptedStringConverter, jakarta.persistence.AttributeConverter, jakarta.persistence.Converter, org.springframework.stereotype.Component, Override

### Community 71 - "layout.js"
Cohesion: 0.16
Nodes (10): dotoFont, geistMono, geistSans, metadata, pixelifySans, SmoothScroll(), AnimatedSignature(), InitialLoader() (+2 more)

### Community 72 - "package:flutter/material.dart"
Cohesion: 0.15
Nodes (12): activeCategory, build, onSelectCategory, show, build, _buildNavItem, CustomBottomNavBar, onItemSelected (+4 more)

### Community 78 - "features/page.js"
Cohesion: 0.05
Nodes (41): CIPHER_FLOW, PLAIN_FLOW, VeinTextFlow(), BellNotificationAnimation(), LockJwtAnimation(), PieChartAnimation(), EXTRA_PIXELS, MORPH_PIXELS (+33 more)

### Community 84 - "react"
Cohesion: 0.19
Nodes (18): react, AreaChartSpending(), chartConfig, TIMEFRAMES, BarChartMonthly(), chartConfig, PieChartCategories(), chartConfig (+10 more)

### Community 88 - "analysis_category_pie_chart.dart"
Cohesion: 0.14
Nodes (14): List, AnalysisCategoryPieChart, _AnalysisCategoryPieChartState, bottomRightAction, build, centerLabel, createState, items (+6 more)

### Community 91 - "app_theme.dart"
Cohesion: 0.03
Nodes (62): AppThemeData get, Brightness, ColorScheme get, accent, AppRadii, AppSpacing, AppThemeManager, background (+54 more)

### Community 94 - "org.junit.jupiter.api.Test"
Cohesion: 0.15
Nodes (11): AnalyticsControllerTests, BackendApplicationTests, ExpenseControllerTests, HealthControllerTests, PaymentControllerTests, SecurityAndUserTests, org.junit.jupiter.api.Test, org.springframework.beans.factory.annotation.Autowired (+3 more)

### Community 96 - "help_support_screen.dart"
Cohesion: 0.14
Nodes (13): build, _buildAppBar, _buildContactCard, _buildFaqItem, _buildFaqSection, _copyToClipboard, createState, _launchEmail (+5 more)

### Community 97 - "home_today_spend_gauge.dart"
Cohesion: 0.11
Nodes (18): dart:math, activeColor, build, _buildZoneIndicator, _computeTodaySpend, createState, _customLimit, dailyBudget (+10 more)

### Community 98 - "org.springframework.security.oauth2.jwt.Jwt"
Cohesion: 0.19
Nodes (12): AnalyticsController, GetMapping, PutMapping, RequestMapping, RestController, TransactionController, TransactionResponse, DeleteMapping (+4 more)

### Community 100 - "spending_heatmap.dart"
Cohesion: 0.07
Nodes (27): build, _buildFooter, _buildGrid, _buildHeader, cells, columns, _computePeriodTotal, createState (+19 more)

### Community 102 - "google_pay_service.dart"
Cohesion: 0.05
Nodes (36): amazonPayPackage, amount, approvalRefNo, _channel, errorMessage, fromNativeMap, fromQueryString, googlePayPackage (+28 more)

### Community 103 - "../theme/app_theme.dart"
Cohesion: 0.18
Nodes (10): ../data/external_data.dart, build, _buildAppBar, _buildCurrentlyInDevelopmentCard, NotificationsScreen, build, _buildAppBar, _buildSectionHeader (+2 more)

### Community 105 - "payment_repository.dart"
Cohesion: 0.08
Nodes (28): _apiClient, cleanupStalePayments, createPayment, deletePayment, getCachedPayments, getPaymentById, getPayments, _instance (+20 more)

### Community 108 - "AuthContext.js"
Cohesion: 0.15
Nodes (12): LoginContent(), DashboardButton(), AuthContext, AuthProvider(), getInitialAuth(), useAuth(), getCurrentUserProfile(), signInWithGitHub() (+4 more)

### Community 109 - "home_weekly_bar_chart.dart"
Cohesion: 0.12
Nodes (17): build, _buildBarChartData, _buildLegendItem, _calculateMax, _computeWeeklyData, createState, _defaultBarColor, _getBottomTitles (+9 more)

### Community 114 - "qr_share_service.dart"
Cohesion: 0.15
Nodes (12): dart:io, _channel, googlePayPackage, pickAndShareQrImage, pickQrImage, QrShareService, shareQrImage, _showSnackBar (+4 more)

## Knowledge Gaps
- **987 isolated node(s):** `com.hulypay:backend`, `eslintConfig`, `paths`, `nextConfig`, `name` (+982 more)
  These have ≤1 connection - possible missing edges or undocumented components. (Counts symbols only; 1158 node(s) total have ≤1 connection when file, concept and rationale nodes are included.)
- **16 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `User` connect `User` to `org.springframework.security.oauth2.jwt.Jwt`, `TransactionRepository`, `Transaction`, `.updateCurrentUser`, `org.junit.jupiter.api.Test`?**
  _High betweenness centrality (0.007) - this node is a cross-community bridge._
- **Why does `react` connect `react` to `dashboard/page.js`, `layout.js`, `AuthContext.js`, `features/page.js`, `ThemeContext.js`, `AnimatedSignature.js`, `package.json`, `api.js`?**
  _High betweenness centrality (0.006) - this node is a cross-community bridge._
- **Why does `Transaction` connect `Transaction` to `EncryptedStringConverter`, `lombok.AllArgsConstructor`, `TransactionRepository`, `User`?**
  _High betweenness centrality (0.005) - this node is a cross-community bridge._
- **What connects `com.hulypay:backend`, `eslintConfig`, `paths` to the rest of the system?**
  _987 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `home_spend_trend_line_chart.dart` be split into smaller, more focused modules?**
  _Cohesion score 0.08695652173913043 - nodes in this community are weakly interconnected._
- **Should `location_service.dart` be split into smaller, more focused modules?**
  _Cohesion score 0.08695652173913043 - nodes in this community are weakly interconnected._
- **Should `upi_service.dart` be split into smaller, more focused modules?**
  _Cohesion score 0.1111111111111111 - nodes in this community are weakly interconnected._