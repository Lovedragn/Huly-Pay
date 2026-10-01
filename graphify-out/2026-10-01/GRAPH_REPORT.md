# Graph Report - Huly.pay  (2026-10-01)

## Corpus Check
- 167 files · ~132,765 words
- Verdict: corpus is large enough that graph structure adds value.

## Summary
- 1796 nodes · 2904 edges · 93 communities (70 shown, 18 thin omitted)
- Extraction: 97% EXTRACTED · 3% INFERRED · 0% AMBIGUOUS · INFERRED: 81 edges (avg confidence: 0.81)
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `cfbd3599`
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
- SecurityAndUserTests.java
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
- TransactionResponse
- AppThemeData
- action_button.dart
- user_repository.dart
- payment_methods_screen.dart
- StatelessWidget
- MaterialPageRoute
- EncryptionService
- transaction_detail_components.dart
- .decrypt
- ../models/payment_model.dart
- api.js
- hulypay/MainActivity.kt
- LaunchImage.imageset/README.md
- CustomPainter
- EncryptedStringConverter
- package:flutter/material.dart
- hulypay/README.md
- EnvelopeEncryptionServiceTests
- layout.js
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
9. `UserService` - 14 edges
10. `TransactionController` - 13 edges

## Surprising Connections (you probably didn't know these)
- `loadData()` --calls--> `syncAllDashboardData()`  [EXTRACTED]
  frontend/src/app/dashboard/page.js → frontend/src/lib/api.js
- `TransactionController` --references--> `TransactionService`  [EXTRACTED]
  backend/src/main/java/com/hulypay/backend/Controllers/TransactionController.java → backend/src/main/java/com/hulypay/backend/Services/TransactionService.java
- `TransactionController` --references--> `UserService`  [EXTRACTED]
  backend/src/main/java/com/hulypay/backend/Controllers/TransactionController.java → backend/src/main/java/com/hulypay/backend/Services/UserService.java
- `Transaction` --references--> `User`  [EXTRACTED]
  backend/src/main/java/com/hulypay/backend/Models/Transaction.java → backend/src/main/java/com/hulypay/backend/Models/User.java
- `TransactionRepository` --references--> `Transaction`  [EXTRACTED]
  backend/src/main/java/com/hulypay/backend/Repositories/TransactionRepository.java → backend/src/main/java/com/hulypay/backend/Models/Transaction.java

## Import Cycles
- None detected.

## Communities (93 total, 18 thin omitted)

### Community 0 - "home_spend_trend_line_chart.dart"
Cohesion: 0.05
Nodes (41): amount, _bottomTitleWidgets, build, _buildCardFooter, _buildCardHeader, _buildCurvedGradientData, _buildDualZoneData, _calculateMaxY (+33 more)

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
Cohesion: 0.21
Nodes (13): ErrorResponse, GlobalExceptionHandler, com.fasterxml.jackson.annotation.JsonInclude, NoResourceFoundException, org.springframework.dao.DataIntegrityViolationException, org.springframework.http.ResponseEntity, org.springframework.security.access.AccessDeniedException, org.springframework.security.core.AuthenticationException (+5 more)

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
Cohesion: 0.25
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
Nodes (19): _amountController, _amountFocusNode, build, createState, dispose, _handleUploadButton, initialAmount, initState (+11 more)

### Community 18 - "SecurityConfig.java"
Cohesion: 0.12
Nodes (16): BackendApplication, DataSource, OpenApiConfig, SecurityConfig, CommandLineRunner, io.swagger.v3.oas.models.OpenAPI, jakarta.annotation.PostConstruct, JwtDecoder (+8 more)

### Community 20 - "single_transaction_screen.dart"
Cohesion: 0.04
Nodes (51): DraggableScrollableNotification, GoogleMapController?, _accuracy, build, _buildDarkMapFallbackCanvas, _buildDetailsCard, _buildGoogleMapContent, _buildGoogleMapOrStreetView (+43 more)

### Community 21 - "package.json"
Cohesion: 0.05
Nodes (39): dependencies, clsx, gsap, @gsap/react, lenis, lucide-react, next, next-transition-router (+31 more)

### Community 22 - "SecurityAndUserTests.java"
Cohesion: 0.21
Nodes (7): DatabaseHealthController, DatabaseHealthResponse, HealthController, HealthResponse, java.util.Map, javax.sql.DataSource, org.springframework.web.bind.annotation.RestController

### Community 23 - "User"
Cohesion: 0.10
Nodes (22): AnalyticsController, RequestMapping, RestController, UserController, AllArgsConstructor, Builder, Entity, Getter (+14 more)

### Community 24 - "api_client.dart"
Cohesion: 0.07
Nodes (26): auth_service.dart, Dio, Exception, int?, ApiException, createPayment, data, defaultAndroidHost (+18 more)

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

### Community 30 - "Transaction"
Cohesion: 0.17
Nodes (9): AllArgsConstructor, Builder, Entity, Getter, NoArgsConstructor, Setter, Table, Transaction (+1 more)

### Community 31 - "chart_colors.dart"
Cohesion: 0.06
Nodes (33): app_theme.dart, financialKeywords, isFinancialTransactionSms, SmsFilterService, allPalettes, amber, AppChartColors, barDefault (+25 more)

### Community 32 - "dashboard/page.js"
Cohesion: 0.24
Nodes (10): DashboardPage(), handleGlobalClick(), loadData(), TransactionsTable(), MOCK_RADAR_METRICS, DEFAULT_USER_PREFERENCES, getUserPreferences(), saveUserPreferences() (+2 more)

### Community 33 - "main.dart"
Cohesion: 0.15
Nodes (12): build, home, initializeAuth, isAuthenticated, main, nextScreen, showSplash, widgetsBinding (+4 more)

### Community 34 - "external_data.dart"
Cohesion: 0.02
Nodes (112): Acceptance of, Account, Changes to, Contact Regarding, Disclaimer of, Information We, aboutEnvironmentNoticeBody, aboutEnvironmentNoticeTitle (+104 more)

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

### Community 45 - "customization_bottom_sheet.dart"
Cohesion: 0.20
Nodes (10): build, _buildChartPaletteOptionCard, _buildThemeOptionCard, createState, CustomizationBottomSheet, _CustomizationBottomSheetState, onThemeChanged, show (+2 more)

### Community 46 - "about_hulypay_screen.dart"
Cohesion: 0.20
Nodes (9): appVersion, build, _buildAppBar, _buildCreatorSection, _buildHeroBrandCard, _buildSpecRow, _buildSpecsCard, _launchUrl (+1 more)

### Community 47 - "TransactionResponse"
Cohesion: 0.24
Nodes (6): BadRequestException, ResourceNotFoundException, TransactionResponse, TransactionService, org.springframework.transaction.annotation.Transactional, org.springframework.web.bind.annotation.ResponseStatus

### Community 49 - "action_button.dart"
Cohesion: 0.22
Nodes (8): IconData, build, icon, label, onTap, QuickActionButton, svgAsset, VoidCallback?

### Community 50 - "user_repository.dart"
Cohesion: 0.14
Nodes (13): _apiClient, getCachedUserProfile, getUserProfile, _instance, _localDb, saveUserProfile, UserRepository, ApiClient (+5 more)

### Community 51 - "payment_methods_screen.dart"
Cohesion: 0.12
Nodes (17): Map, build, _buildAppBar, _buildInstalledAppsList, _buildPaymentAppCard, _buildSectionTitle, createState, initState (+9 more)

### Community 52 - "StatelessWidget"
Cohesion: 0.25
Nodes (8): HulyPayApp, AboutHulyPayScreen, CategoryPickerSheet, _HeatmapGridWidget, TransactionActionButton, TransactionDetailRow, TransactionTile, StatelessWidget

### Community 53 - "MaterialPageRoute"
Cohesion: 0.20
Nodes (10): MaterialPageRoute, _buildHeader, _openUploadQr, _showPaymentConfirmationModal, _startSmsVerificationWorkflow, _buildAccountSection, _buildNotificationsSection, _buildSupportSection (+2 more)

### Community 54 - "EncryptionService"
Cohesion: 0.26
Nodes (9): EncryptionService, EnvelopeEncryptionService, TransactionSmsParserService, VerificationMatchResult, java.security.SecureRandom, java.util.regex.Pattern, javax.crypto.SecretKey, lombok.extern.slf4j.Slf4j (+1 more)

### Community 55 - "transaction_detail_components.dart"
Cohesion: 0.12
Nodes (15): Color?, backgroundColor, borderColor, build, canCopy, icon, iconColor, isPrimary (+7 more)

### Community 57 - "../models/payment_model.dart"
Cohesion: 0.20
Nodes (9): TransactionItem, PaymentModel, build, onTap, payment, transaction, ../models/dashboard_data.dart, ../models/payment_model.dart (+1 more)

### Community 58 - "api.js"
Cohesion: 0.21
Nodes (16): BackendStatusBar(), verify(), checkBackendHealth(), deleteTransaction(), getCategoryBreakdown(), getDailySpending(), getExpenses(), getMonthlySpending() (+8 more)

### Community 61 - "CustomPainter"
Cohesion: 0.40
Nodes (5): CustomPainter, ScannerFramePainter, ScannerOverlayPainter, _MapGridPainter, _SpeedometerGaugePainter

### Community 66 - "EncryptedStringConverter"
Cohesion: 0.36
Nodes (5): EncryptedStringConverter, jakarta.persistence.AttributeConverter, jakarta.persistence.Converter, org.springframework.stereotype.Component, Override

### Community 67 - "package:flutter/material.dart"
Cohesion: 0.15
Nodes (12): activeCategory, build, onSelectCategory, show, build, _buildNavItem, CustomBottomNavBar, onItemSelected (+4 more)

### Community 71 - "layout.js"
Cohesion: 0.13
Nodes (17): dotoFont, geistMono, geistSans, metadata, pixelifySans, SmoothScroll(), AnimatedSignature(), InitialLoader() (+9 more)

### Community 78 - "features/page.js"
Cohesion: 0.05
Nodes (43): CIPHER_FLOW, PLAIN_FLOW, VeinTextFlow(), BellNotificationAnimation(), LockJwtAnimation(), PieChartAnimation(), EXTRA_PIXELS, MORPH_PIXELS (+35 more)

### Community 84 - "react"
Cohesion: 0.19
Nodes (18): react, AreaChartSpending(), chartConfig, TIMEFRAMES, BarChartMonthly(), chartConfig, PieChartCategories(), chartConfig (+10 more)

### Community 88 - "analysis_category_pie_chart.dart"
Cohesion: 0.17
Nodes (11): List, bottomRightAction, build, centerLabel, createState, items, showCardBackground, _showingSections (+3 more)

### Community 91 - "app_theme.dart"
Cohesion: 0.03
Nodes (62): AppThemeData get, Brightness, ColorScheme get, accent, AppRadii, AppSpacing, AppThemeManager, background (+54 more)

### Community 94 - "org.junit.jupiter.api.Test"
Cohesion: 0.14
Nodes (11): AnalyticsControllerTests, BackendApplicationTests, ExpenseControllerTests, HealthControllerTests, PaymentControllerTests, SecurityAndUserTests, org.junit.jupiter.api.Test, org.springframework.beans.factory.annotation.Autowired (+3 more)

### Community 96 - "help_support_screen.dart"
Cohesion: 0.15
Nodes (12): build, _buildAppBar, _buildContactCard, _buildFaqItem, _buildFaqSection, _copyToClipboard, createState, _launchEmail (+4 more)

### Community 97 - "home_today_spend_gauge.dart"
Cohesion: 0.10
Nodes (20): dart:math, activeColor, build, _buildZoneIndicator, _computeTodaySpend, createState, _customLimit, dailyBudget (+12 more)

### Community 98 - "org.springframework.security.oauth2.jwt.Jwt"
Cohesion: 0.14
Nodes (11): GetMapping, PutMapping, RequestMapping, RestController, TransactionController, GetMapping, PutMapping, DeleteMapping (+3 more)

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
Cohesion: 0.12
Nodes (15): _apiClient, cleanupStalePayments, createPayment, deletePayment, getCachedPayments, getPaymentById, getPayments, _instance (+7 more)

### Community 108 - "AuthContext.js"
Cohesion: 0.21
Nodes (9): AuthContext, AuthProvider(), getInitialAuth(), getCurrentUserProfile(), signInWithGitHub(), signInWithGoogle(), signOut(), supabase (+1 more)

### Community 114 - "qr_share_service.dart"
Cohesion: 0.14
Nodes (13): dart:io, _channel, googlePayPackage, pickAndShareQrImage, pickQrImage, QrShareService, shareQrImage, _showSnackBar (+5 more)

## Knowledge Gaps
- **989 isolated node(s):** `com.hulypay:backend`, `eslintConfig`, `paths`, `nextConfig`, `name` (+984 more)
  These have ≤1 connection - possible missing edges or undocumented components. (Counts symbols only; 1160 node(s) total have ≤1 connection when file, concept and rationale nodes are included.)
- **18 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `react` connect `react` to `dashboard/page.js`, `layout.js`, `AuthContext.js`, `features/page.js`, `ThemeContext.js`, `package.json`, `api.js`?**
  _High betweenness centrality (0.007) - this node is a cross-community bridge._
- **Why does `User` connect `User` to `org.springframework.security.oauth2.jwt.Jwt`, `lombok.AllArgsConstructor`, `TransactionResponse`, `SecurityAndUserTests.java`, `Transaction`?**
  _High betweenness centrality (0.006) - this node is a cross-community bridge._
- **Why does `Transaction` connect `Transaction` to `EncryptedStringConverter`, `lombok.AllArgsConstructor`, `TransactionResponse`, `EncryptionService`, `User`?**
  _High betweenness centrality (0.004) - this node is a cross-community bridge._
- **What connects `com.hulypay:backend`, `eslintConfig`, `paths` to the rest of the system?**
  _989 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `home_spend_trend_line_chart.dart` be split into smaller, more focused modules?**
  _Cohesion score 0.04983388704318937 - nodes in this community are weakly interconnected._
- **Should `location_service.dart` be split into smaller, more focused modules?**
  _Cohesion score 0.08695652173913043 - nodes in this community are weakly interconnected._
- **Should `upi_service.dart` be split into smaller, more focused modules?**
  _Cohesion score 0.1111111111111111 - nodes in this community are weakly interconnected._