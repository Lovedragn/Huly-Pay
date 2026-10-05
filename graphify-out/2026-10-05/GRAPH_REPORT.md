# Graph Report - Huly.pay  (2026-10-05)

## Corpus Check
- 185 files · ~142,009 words
- Verdict: corpus is large enough that graph structure adds value.

## Summary
- 2024 nodes · 3264 edges · 107 communities (82 shown, 20 thin omitted)
- Extraction: 97% EXTRACTED · 3% INFERRED · 0% AMBIGUOUS · INFERRED: 84 edges (avg confidence: 0.81)
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `8c86cdb4`
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
- transaction_model.dart
- lombok.Data
- analysis_screen.dart
- user_preferences_service.dart
- scan_and_pay_screen.dart
- ThemeContext.js
- upload_qr_screen.dart
- SecurityConfig.java
- transaction_repository.dart
- single_transaction_screen.dart
- package.json
- org.springframework.web.bind.annotation.GetMapping
- Transaction
- api_client.dart
- MainActivity
- Docker Compose Configuration
- mvnw
- splash_screen.dart
- package:flutter/foundation.dart
- User
- sms_filter_service.dart
- app_update_service.dart
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
- String?
- .parse
- org.springframework.security.oauth2.jwt.Jwt
- AppThemeData
- dashboard/page.js
- user_repository.dart
- payment_methods_screen.dart
- package:flutter/material.dart
- MaterialPageRoute
- QrCodeController
- transaction_detail_components.dart
- ApiException
- ../models/transaction_model.dart
- api.js
- hulypay/MainActivity.kt
- LaunchImage.imageset/README.md
- CustomPainter
- org.springframework.stereotype.Service
- EncryptedStringConverter
- 📱 Huly Pay — Mobile Client Setup & Development Guide
- transaction_map_section.dart
- transaction_pdf_service.dart
- layout.js
- home_weekly_bar_chart.dart
- edit_amount_sheet.dart
- transaction_details_card.dart
- encrypt_csv.py
- app_back_button.dart
- TransactionRepository
- features/page.js
- AGENTS.md
- eslint.config.mjs
- postcss.config.mjs
- SingleTransactionScreen
- react
- EnvelopeEncryptionServiceTests
- customization_bottom_sheet.dart
- AppVersionControllerTests
- analysis_category_pie_chart.dart
- com.hulypay:backend
- ../theme/app_theme.dart
- app_theme.dart
- rules/graphify.md
- workflows/graphify.md
- org.junit.jupiter.api.Test
- about_hulypay_screen.dart
- help_support_screen.dart
- home_today_spend_gauge.dart
- .decrypt
- AnimatedSignature.js
- spending_heatmap.dart
- StatelessWidget
- google_pay_service.dart
- custom_bottom_nav_bar.dart
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
7. `MainActivity` - 16 edges
8. `TransactionService` - 15 edges
9. `UserService` - 14 edges
10. `TransactionController` - 13 edges

## Surprising Connections (you probably didn't know these)
- `loadData()` --calls--> `syncAllDashboardData()`  [EXTRACTED]
  frontend/src/app/dashboard/page.js → frontend/src/lib/api.js
- `AppVersionController` --references--> `MobileAppProperties`  [EXTRACTED]
  backend/src/main/java/com/hulypay/backend/Controllers/AppVersionController.java → backend/src/main/java/com/hulypay/backend/config/MobileAppProperties.java
- `AppVersionController` --references--> `VersionComparisonService`  [EXTRACTED]
  backend/src/main/java/com/hulypay/backend/Controllers/AppVersionController.java → backend/src/main/java/com/hulypay/backend/Services/VersionComparisonService.java
- `TransactionController` --references--> `UserService`  [EXTRACTED]
  backend/src/main/java/com/hulypay/backend/Controllers/TransactionController.java → backend/src/main/java/com/hulypay/backend/Services/UserService.java
- `Transaction` --references--> `User`  [EXTRACTED]
  backend/src/main/java/com/hulypay/backend/Models/Transaction.java → backend/src/main/java/com/hulypay/backend/Models/User.java

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
Nodes (39): Database?, cleanupStalePayments, clearAll, clearPayments, clearUserProfile, close, _db, dbName (+31 more)

### Community 7 - "org.springframework.http.ResponseEntity"
Cohesion: 0.21
Nodes (13): ErrorResponse, GlobalExceptionHandler, com.fasterxml.jackson.annotation.JsonInclude, NoResourceFoundException, org.springframework.dao.DataIntegrityViolationException, org.springframework.http.ResponseEntity, org.springframework.security.access.AccessDeniedException, org.springframework.security.core.AuthenticationException (+5 more)

### Community 8 - "home_dashboard_screen.dart"
Cohesion: 0.05
Nodes (36): Animation, _applyData, build, _buildAvatarFallback, _buildBody, _buildDashboardContent, _buildQuickActions, _buildTotalSpentCard (+28 more)

### Community 9 - "settings_screen.dart"
Cohesion: 0.06
Nodes (31): about_hulypay_screen.dart, help_support_screen.dart, appVersion, _avatarUrl, build, _buildAppInfoFooter, _buildGroupCard, _buildLogoutCard (+23 more)

### Community 10 - "transactions_screen.dart"
Cohesion: 0.09
Nodes (22): analysis_screen.dart, _allGroups, build, _buildFilterChips, _buildSearchBar, createState, dispose, _filterActivePayments (+14 more)

### Community 11 - "transaction_model.dart"
Cohesion: 0.06
Nodes (35): dashboard_data.dart, amount, category, copyWith, createdAt, CreatePaymentPayload, CreateTransactionPayload, currency (+27 more)

### Community 12 - "lombok.Data"
Cohesion: 0.25
Nodes (16): CreateTransactionRequest, TransactionReconcileRequest, TransactionSmsVerificationRequest, UpdateTransactionRequest, UpdateUserRequest, AppVersionResponse, DailySpendingResponse, SpendingSummaryResponse (+8 more)

### Community 13 - "analysis_screen.dart"
Cohesion: 0.05
Nodes (36): _allPayments, build, _buildCategoryList, _buildClassificationToggleButton, _buildHeader, _categories, _categoryOverrides, _classificationMode (+28 more)

### Community 14 - "user_preferences_service.dart"
Cohesion: 0.06
Nodes (31): double? get, local_database_service.dart, _cachedAnalysisPeriod, _cachedDailyLimit, _cachedDefaultPaymentApp, _cachedQuickConfirm, _cachedQuickScan, getAnalysisPeriod (+23 more)

### Community 15 - "scan_and_pay_screen.dart"
Cohesion: 0.05
Nodes (40): DateTime?, _amountController, build, cornerColor, cornerLength, cornerRadius, createState, cutoutRect (+32 more)

### Community 16 - "ThemeContext.js"
Cohesion: 0.27
Nodes (10): ThemeToggle(), emptySubscribe(), getServerSnapshot(), getSnapshot(), listeners, notifyListeners(), subscribe(), ThemeContext (+2 more)

### Community 17 - "upload_qr_screen.dart"
Cohesion: 0.09
Nodes (23): _amountController, _amountFocusNode, build, createState, dispose, _handlePayButton, initialAmount, initState (+15 more)

### Community 18 - "SecurityConfig.java"
Cohesion: 0.10
Nodes (19): BackendApplication, DataSource, MobileAppProperties, PlatformConfig, OpenApiConfig, SecurityConfig, CommandLineRunner, io.swagger.v3.oas.models.OpenAPI (+11 more)

### Community 19 - "transaction_repository.dart"
Cohesion: 0.08
Nodes (25): _apiClient, cleanupStalePayments, cleanupStaleTransactions, createPayment, createTransaction, deletePayment, deleteTransaction, getCachedPayments (+17 more)

### Community 20 - "single_transaction_screen.dart"
Cohesion: 0.04
Nodes (47): DraggableScrollableNotification, GoogleMapController?, _accuracy, build, _buildQuickActionButtons, _buildSectionHeader, _copyToClipboard, createState (+39 more)

### Community 21 - "package.json"
Cohesion: 0.05
Nodes (39): dependencies, clsx, gsap, @gsap/react, lenis, lucide-react, next, next-transition-router (+31 more)

### Community 22 - "org.springframework.web.bind.annotation.GetMapping"
Cohesion: 0.19
Nodes (10): AppVersionController, DatabaseHealthController, DatabaseHealthResponse, HealthController, HealthResponse, io.swagger.v3.oas.annotations.Operation, io.swagger.v3.oas.annotations.tags.Tag, javax.sql.DataSource (+2 more)

### Community 23 - "Transaction"
Cohesion: 0.10
Nodes (14): AllArgsConstructor, Builder, Entity, Getter, NoArgsConstructor, Setter, Table, Transaction (+6 more)

### Community 24 - "api_client.dart"
Cohesion: 0.07
Nodes (26): auth_service.dart, Dio, int?, checkAppVersion, createPayment, data, defaultAndroidHost, dio (+18 more)

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

### Community 30 - "User"
Cohesion: 0.12
Nodes (20): AnalyticsController, PutMapping, RequestMapping, RestController, UserController, AllArgsConstructor, Builder, Entity (+12 more)

### Community 31 - "sms_filter_service.dart"
Cohesion: 0.40
Nodes (4): financialKeywords, isFinancialTransactionSms, SmsFilterService, static const List

### Community 32 - "app_update_service.dart"
Cohesion: 0.10
Nodes (20): api_client.dart, AppUpdateService, checkAppVersion, currentVersion, dismissBanner, downloadUrl, forceUpdate, fromJson (+12 more)

### Community 33 - "main.dart"
Cohesion: 0.14
Nodes (13): build, home, HulyPayApp, initializeAuth, isAuthenticated, main, nextScreen, showSplash (+5 more)

### Community 34 - "external_data.dart"
Cohesion: 0.02
Nodes (112): Acceptance of, Account, Changes to, Contact Regarding, Disclaimer of, Information We, aboutEnvironmentNoticeBody, aboutEnvironmentNoticeTitle (+104 more)

### Community 35 - "💳 HulyPay — Next-Gen Intelligent Fintech Platform"
Cohesion: 0.05
Nodes (38): 1. Prerequisites, 2. Clone Repository & Setup, 3. Environment Configuration, 4. Run on Android, 5. Run on iOS (macOS required), ⚙️ Backend (Spring Boot), Build for Production, Core Features (+30 more)

### Community 36 - "State"
Cohesion: 0.16
Nodes (18): AnalysisScreen, _AnalysisScreenState, HomeDashboardScreen, _HomeDashboardScreenState, SettingsScreen, _SettingsScreenState, SignInScreen, _SignInScreenState (+10 more)

### Community 37 - "user_profile.dart"
Cohesion: 0.14
Nodes (13): active, authProvider, avatarUrl, copyWith, email, firstName, fromJson, fullName (+5 more)

### Community 38 - "auth_service.dart"
Cohesion: 0.07
Nodes (27): dart:async, AuthService, client, currentAccessToken, currentSession, currentUser, hasValidActiveToken, initialize (+19 more)

### Community 40 - "sign_in_screen.dart"
Cohesion: 0.09
Nodes (21): home_dashboard_screen.dart, _authSubscription, _authTimeoutTimer, build, createState, didChangeAppLifecycleState, dispose, _finishSignIn (+13 more)

### Community 41 - "scan_amount_screen.dart"
Cohesion: 0.13
Nodes (15): FocusNode, _amountController, _amountFocusNode, build, createState, dispose, _handleScanButton, initialAmount (+7 more)

### Community 42 - "README.md"
Cohesion: 0.50
Nodes (3): Deploy on Vercel, Getting Started, Learn More

### Community 45 - "String?"
Cohesion: 0.22
Nodes (8): IconData?, build, icon, label, onTap, svgAsset, String?, VoidCallback?

### Community 47 - "org.springframework.security.oauth2.jwt.Jwt"
Cohesion: 0.13
Nodes (15): GetMapping, PostMapping, PutMapping, RequestMapping, RestController, TransactionController, GetMapping, BadRequestException (+7 more)

### Community 49 - "dashboard/page.js"
Cohesion: 0.19
Nodes (12): DashboardPage(), handleGlobalClick(), loadData(), TransactionsTable(), deleteTransaction(), MOCK_EXPENSES, MOCK_RADAR_METRICS, DEFAULT_USER_PREFERENCES (+4 more)

### Community 50 - "user_repository.dart"
Cohesion: 0.13
Nodes (14): _apiClient, getCachedUserProfile, getUserProfile, _instance, _localDb, saveUserProfile, UserRepository, ApiClient (+6 more)

### Community 51 - "payment_methods_screen.dart"
Cohesion: 0.12
Nodes (17): Map, build, _buildAppBar, _buildInstalledAppsList, _buildPaymentAppCard, _buildSectionTitle, createState, initState (+9 more)

### Community 52 - "package:flutter/material.dart"
Cohesion: 0.13
Nodes (13): build, displayAmount, isIncome, merchantTitle, status, time, TransactionReceiptCard, main (+5 more)

### Community 53 - "MaterialPageRoute"
Cohesion: 0.18
Nodes (11): MaterialPageRoute, _buildHeader, _openUploadQr, _openUploadFromScanner, _showPaymentConfirmationModal, _startSmsVerificationWorkflow, _buildAccountSection, _buildNotificationsSection (+3 more)

### Community 54 - "QrCodeController"
Cohesion: 0.24
Nodes (6): GetMapping, PostMapping, RequestMapping, ResponseEntity, RestController, QrCodeController

### Community 55 - "transaction_detail_components.dart"
Cohesion: 0.12
Nodes (15): backgroundColor, borderColor, build, canCopy, customIcon, icon, iconColor, isPrimary (+7 more)

### Community 57 - "../models/transaction_model.dart"
Cohesion: 0.22
Nodes (8): TransactionItem, build, onTap, payment, transaction, ../models/dashboard_data.dart, ../models/transaction_model.dart, ../screens/single_transaction_screen.dart

### Community 58 - "api.js"
Cohesion: 0.24
Nodes (14): BackendStatusBar(), verify(), checkBackendHealth(), getCategoryBreakdown(), getDailySpending(), getExpenses(), getMonthlySpending(), getSpendingSummary() (+6 more)

### Community 61 - "CustomPainter"
Cohesion: 0.40
Nodes (5): CustomPainter, ScannerFramePainter, ScannerOverlayPainter, _SpeedometerGaugePainter, MapGridPainter

### Community 66 - "org.springframework.stereotype.Service"
Cohesion: 0.26
Nodes (8): EncryptionService, EnvelopeEncryptionService, TransactionSmsParserService, java.security.SecureRandom, java.util.regex.Pattern, javax.crypto.SecretKey, lombok.extern.slf4j.Slf4j, org.springframework.stereotype.Service

### Community 67 - "EncryptedStringConverter"
Cohesion: 0.36
Nodes (5): EncryptedStringConverter, jakarta.persistence.AttributeConverter, jakarta.persistence.Converter, org.springframework.stereotype.Component, Override

### Community 68 - "📱 Huly Pay — Mobile Client Setup & Development Guide"
Cohesion: 0.07
Nodes (26): Build optimized release APK:, ⚙️ Configuration & Environment, 📦 Core Dependencies & Tech Stack, 💳 Huly Pay Mobile Application, 🌟 Key Features, Output:, 📁 Project Architecture & Directory Layout, Run locally on an Android device or emulator: (+18 more)

### Community 69 - "transaction_map_section.dart"
Cohesion: 0.09
Nodes (21): accuracy, build, _buildDarkMapFallbackCanvas, _buildGoogleMapContent, _buildStreetViewContent, _buildTab, createState, _handleOpenStreetViewExternal (+13 more)

### Community 70 - "transaction_pdf_service.dart"
Cohesion: 0.18
Nodes (10): dart:io, _buildDetailRow, _buildDivider, _formatProvider, generateReceipt, TransactionPdfService, package:flutter/services.dart, package:path_provider/path_provider.dart (+2 more)

### Community 71 - "layout.js"
Cohesion: 0.16
Nodes (10): dotoFont, geistMono, geistSans, metadata, pixelifySans, SmoothScroll(), AnimatedSignature(), InitialLoader() (+2 more)

### Community 72 - "home_weekly_bar_chart.dart"
Cohesion: 0.12
Nodes (17): build, _buildBarChartData, _buildLegendItem, _calculateMax, _computeWeeklyData, createState, _defaultBarColor, _getBottomTitles (+9 more)

### Community 73 - "edit_amount_sheet.dart"
Cohesion: 0.12
Nodes (16): _addAmount, build, _buildQuickChip, _controller, createState, currentAmount, dispose, EditAmountSheet (+8 more)

### Community 74 - "transaction_details_card.dart"
Cohesion: 0.14
Nodes (13): double?, accuracy, build, category, latitude, longitude, onCategoryTap, paymentMethod (+5 more)

### Community 75 - "encrypt_csv.py"
Cohesion: 0.25
Nodes (10): decrypt_value_gcm(), derive_key(), encrypt_value_gcm(), main(), process_csv(), Read CSV, process selected columns, write to output CSV., HulyPay - Selective Column CSV Encryptor / Decryptor…, Derive a 256-bit (32 bytes) key using PBKDF2 HMAC-SHA256. (+2 more)

### Community 76 - "app_back_button.dart"
Cohesion: 0.20
Nodes (9): Color?, AppBackButton, backgroundColor, borderColor, build, iconColor, iconSize, onPressed (+1 more)

### Community 78 - "features/page.js"
Cohesion: 0.05
Nodes (44): CIPHER_FLOW, PLAIN_FLOW, VeinTextFlow(), BellNotificationAnimation(), LockJwtAnimation(), PieChartAnimation(), EXTRA_PIXELS, MORPH_PIXELS (+36 more)

### Community 84 - "react"
Cohesion: 0.19
Nodes (18): react, AreaChartSpending(), chartConfig, TIMEFRAMES, BarChartMonthly(), chartConfig, PieChartCategories(), chartConfig (+10 more)

### Community 86 - "customization_bottom_sheet.dart"
Cohesion: 0.25
Nodes (8): build, _buildThemeOptionCard, createState, CustomizationBottomSheet, _CustomizationBottomSheetState, onThemeChanged, show, ../services/user_preferences_service.dart

### Community 87 - "AppVersionControllerTests"
Cohesion: 0.23
Nodes (4): VersionComparisonService, AppVersionControllerTests, org.junit.jupiter.api.DisplayName, org.springframework.test.context.TestPropertySource

### Community 88 - "analysis_category_pie_chart.dart"
Cohesion: 0.14
Nodes (14): List, AnalysisCategoryPieChart, _AnalysisCategoryPieChartState, bottomRightAction, build, centerLabel, createState, items (+6 more)

### Community 90 - "../theme/app_theme.dart"
Cohesion: 0.20
Nodes (10): AppUpdateInfo, AppUpdateBanner, build, updateInfo, AppUpdateDialog, build, show, updateInfo (+2 more)

### Community 91 - "app_theme.dart"
Cohesion: 0.02
Nodes (90): AppThemeData get, Brightness, ColorScheme get, accent, allPalettes, amber, AppChartColors, AppRadii (+82 more)

### Community 94 - "org.junit.jupiter.api.Test"
Cohesion: 0.14
Nodes (12): AnalyticsControllerTests, BackendApplicationTests, ExpenseControllerTests, HealthControllerTests, PaymentControllerTests, SecurityAndUserTests, java.util.Map, org.junit.jupiter.api.Test (+4 more)

### Community 95 - "about_hulypay_screen.dart"
Cohesion: 0.09
Nodes (20): ../data/external_data.dart, AboutHulyPayScreen, appVersion, build, _buildAppBar, _buildCreatorSection, _buildHeroBrandCard, _buildSpecRow (+12 more)

### Community 96 - "help_support_screen.dart"
Cohesion: 0.14
Nodes (14): build, _buildAppBar, _buildContactCard, _buildFaqItem, _buildFaqSection, _copyToClipboard, createState, HelpSupportScreen (+6 more)

### Community 97 - "home_today_spend_gauge.dart"
Cohesion: 0.11
Nodes (18): dart:math, activeColor, build, _buildZoneIndicator, _computeTodaySpend, createState, _customLimit, dailyBudget (+10 more)

### Community 99 - "AnimatedSignature.js"
Cohesion: 0.46
Nodes (6): SIGNATURE_FILL_PATH, SIGNATURE_HEIGHT, SIGNATURE_MASK_PATH, SIGNATURE_STROKE_LENGTH, SIGNATURE_VIEWBOX, SIGNATURE_WIDTH

### Community 100 - "spending_heatmap.dart"
Cohesion: 0.07
Nodes (27): build, _buildFooter, _buildGrid, _buildHeader, cells, columns, _computePeriodTotal, createState (+19 more)

### Community 101 - "StatelessWidget"
Cohesion: 0.25
Nodes (8): QuickActionButton, _HeatmapGridWidget, TransactionActionButton, TransactionDetailRow, TransactionDetailsCard, TransactionMapControlBar, TransactionTile, StatelessWidget

### Community 102 - "google_pay_service.dart"
Cohesion: 0.05
Nodes (36): amazonPayPackage, amount, approvalRefNo, _channel, errorMessage, fromNativeMap, fromQueryString, googlePayPackage (+28 more)

### Community 103 - "custom_bottom_nav_bar.dart"
Cohesion: 0.14
Nodes (12): activeCategory, build, CategoryPickerSheet, onSelectCategory, show, build, _buildNavItem, CustomBottomNavBar (+4 more)

### Community 108 - "AuthContext.js"
Cohesion: 0.21
Nodes (9): AuthContext, AuthProvider(), getInitialAuth(), getCurrentUserProfile(), signInWithGitHub(), signInWithGoogle(), signOut(), supabase (+1 more)

### Community 114 - "qr_share_service.dart"
Cohesion: 0.17
Nodes (11): _channel, googlePayPackage, pickAndShareQrImage, pickQrImage, QrShareService, shareQrImage, _showSnackBar, _supportedImageExtensions (+3 more)

## Knowledge Gaps
- **1109 isolated node(s):** `com.hulypay:backend`, `eslintConfig`, `paths`, `nextConfig`, `name` (+1104 more)
  These have ≤1 connection - possible missing edges or undocumented components. (Counts symbols only; 1300 node(s) total have ≤1 connection when file, concept and rationale nodes are included.)
- **20 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `PaymentRepository` connect `Transaction` to `transaction_repository.dart`?**
  _High betweenness centrality (0.227) - this node is a cross-community bridge._
- **Why does `Transaction` connect `Transaction` to `org.springframework.stereotype.Service`, `EncryptedStringConverter`, `lombok.Data`, `.parse`, `org.springframework.security.oauth2.jwt.Jwt`, `User`?**
  _High betweenness centrality (0.105) - this node is a cross-community bridge._
- **Why does `TransactionRepository` connect `Transaction` to `User`, `org.springframework.security.oauth2.jwt.Jwt`?**
  _High betweenness centrality (0.041) - this node is a cross-community bridge._
- **What connects `com.hulypay:backend`, `eslintConfig`, `paths` to the rest of the system?**
  _1109 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `home_spend_trend_line_chart.dart` be split into smaller, more focused modules?**
  _Cohesion score 0.08695652173913043 - nodes in this community are weakly interconnected._
- **Should `location_service.dart` be split into smaller, more focused modules?**
  _Cohesion score 0.08695652173913043 - nodes in this community are weakly interconnected._
- **Should `upi_service.dart` be split into smaller, more focused modules?**
  _Cohesion score 0.1111111111111111 - nodes in this community are weakly interconnected._