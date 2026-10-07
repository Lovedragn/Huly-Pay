# Graph Report - Huly.pay  (2026-10-07)

## Corpus Check
- 196 files · ~145,679 words
- Verdict: corpus is large enough that graph structure adds value.

## Summary
- 2244 nodes · 3567 edges · 111 communities (88 shown, 18 thin omitted)
- Extraction: 98% EXTRACTED · 2% INFERRED · 0% AMBIGUOUS · INFERRED: 84 edges (avg confidence: 0.81)
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `78614d29`
- Run `git rev-parse HEAD` and compare to check if the graph is stale.
- Run `graphify update .` after code changes (no API cost).

## Community Hubs (Navigation)
- spend_trend_line_chart.dart
- location_service.dart
- google_pay_service.dart
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
- round_button.dart
- Transaction
- api_client.dart
- MainActivity
- Docker Compose Configuration
- mvnw
- splash_screen.dart
- package:flutter/foundation.dart
- edit_amount_sheet.dart
- sms_filter_service.dart
- app_update_service.dart
- main.dart
- external_data.dart
- 💳 HulyPay — Next-Gen Intelligent Fintech Platform
- about_hulypay_screen.dart
- payment_details_page.dart
- auth_service.dart
- AppThemeContextExtension
- sign_in_screen.dart
- State
- README.md
- compilerOptions
- next.config.mjs
- dependencies
- TransactionSmsParserService
- User
- AppThemeData
- dashboard/page.js
- user_repository.dart
- payment_methods_screen.dart
- upi_service.dart
- MaterialPageRoute
- dialog.dart
- Theme/app_theme.dart
- scan_payment_service.dart
- transaction_detail_components.dart
- api.js
- hulypay/MainActivity.kt
- LaunchImage.imageset/README.md
- sms_verification_dialog.dart
- org.springframework.stereotype.Service
- package:flutter_svg/flutter_svg.dart
- 📱 Huly Pay — Mobile Client Setup & Development Guide
- transaction_map_section.dart
- transaction_pdf_service.dart
- weekly_bar_chart.dart
- qr_service.dart
- scan_amount_screen.dart
- transaction_details_card.dart
- encrypt_csv.py
- org.springframework.security.oauth2.jwt.Jwt
- TransactionRepository
- features/page.js
- AGENTS.md
- eslint.config.mjs
- postcss.config.mjs
- navbar_switch_button.dart
- react
- String?
- help_support_screen.dart
- AppVersionControllerTests
- category_pie_chart.dart
- com.hulypay:backend
- .decrypt
- app_theme.dart
- rules/graphify.md
- workflows/graphify.md
- org.junit.jupiter.api.Test
- Service/user_preferences_service.dart
- org.springframework.web.bind.annotation.GetMapping
- today_spend_gauge.dart
- EncryptedStringConverter
- layout.js
- spending_heatmap.dart
- ../Model/transaction_model.dart
- devDependencies
- StatelessWidget
- ApiException
- payment_dialogs.dart
- PaymentModel
- package:flutter/material.dart
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
- `AppVersionController` --references--> `VersionComparisonService`  [EXTRACTED]
  backend/src/main/java/com/hulypay/backend/Controllers/AppVersionController.java → backend/src/main/java/com/hulypay/backend/Services/VersionComparisonService.java
- `TransactionController` --references--> `UserService`  [EXTRACTED]
  backend/src/main/java/com/hulypay/backend/Controllers/TransactionController.java → backend/src/main/java/com/hulypay/backend/Services/UserService.java
- `Transaction` --references--> `User`  [EXTRACTED]
  backend/src/main/java/com/hulypay/backend/Models/Transaction.java → backend/src/main/java/com/hulypay/backend/Models/User.java
- `AnalyticsService` --references--> `TransactionRepository`  [EXTRACTED]
  backend/src/main/java/com/hulypay/backend/Services/AnalyticsService.java → backend/src/main/java/com/hulypay/backend/Repositories/TransactionRepository.java

## Import Cycles
- None detected.

## Communities (111 total, 18 thin omitted)

### Community 0 - "spend_trend_line_chart.dart"
Cohesion: 0.09
Nodes (23): amount, _bottomTitleWidgets, build, _buildCardFooter, _buildCardHeader, _buildCurvedGradientData, _buildDualZoneData, _calculateMaxY (+15 more)

### Community 1 - "location_service.dart"
Cohesion: 0.09
Nodes (22): bool get, accuracyMeters, errorMessage, failure, failureReason, getCurrentPaymentLocation, getPaymentLocationWithStatus, _instance (+14 more)

### Community 2 - "google_pay_service.dart"
Cohesion: 0.06
Nodes (35): amazonPayPackage, amount, approvalRefNo, _channel, errorMessage, fromNativeMap, fromQueryString, googlePayPackage (+27 more)

### Community 3 - "dashboard_data.dart"
Cohesion: 0.06
Nodes (30): amount, avatarUrl, category, CategorySpendingItem, changePercent, changePeriodLabel, color, DashboardData (+22 more)

### Community 4 - "upi_payment_service.dart"
Cohesion: 0.05
Nodes (38): allApps, amazon, amazonPay, appNotInstalled, askEveryTime, bhim, bhimApp, buildSafeUpiUri (+30 more)

### Community 5 - "AppDelegate"
Cohesion: 0.11
Nodes (14): Any, Flutter, FlutterAppDelegate, FlutterImplicitEngineBridge, FlutterImplicitEngineDelegate, FlutterSceneDelegate, AppDelegate, Bool (+6 more)

### Community 6 - "local_database_service.dart"
Cohesion: 0.05
Nodes (39): Database?, cleanupStalePayments, clearAll, clearPayments, clearUserProfile, close, _db, dbName (+31 more)

### Community 7 - "org.springframework.http.ResponseEntity"
Cohesion: 0.20
Nodes (14): ErrorResponse, GlobalExceptionHandler, com.fasterxml.jackson.annotation.JsonInclude, java.util.Map, NoResourceFoundException, org.springframework.dao.DataIntegrityViolationException, org.springframework.http.ResponseEntity, org.springframework.security.access.AccessDeniedException (+6 more)

### Community 8 - "home_dashboard_screen.dart"
Cohesion: 0.05
Nodes (38): Animation, _applyData, build, _buildAvatarFallback, _buildBody, _buildDashboardContent, _buildQuickActions, _buildTotalSpentCard (+30 more)

### Community 9 - "settings_screen.dart"
Cohesion: 0.06
Nodes (32): about_hulypay_screen.dart, help_support_screen.dart, appVersion, _avatarUrl, build, _buildGroupCard, _buildLogoutCard, _buildPreferencesSection (+24 more)

### Community 10 - "transactions_screen.dart"
Cohesion: 0.09
Nodes (22): ../Analyze/analysis_screen.dart, _allGroups, build, _buildFilterChips, _buildHeader, _buildSearchBar, createState, dispose (+14 more)

### Community 11 - "transaction_model.dart"
Cohesion: 0.06
Nodes (33): dashboard_data.dart, amount, category, copyWith, createdAt, CreatePaymentPayload, CreateTransactionPayload, currency (+25 more)

### Community 12 - "lombok.Data"
Cohesion: 0.25
Nodes (17): CreateTransactionRequest, TransactionReconcileRequest, TransactionSmsVerificationRequest, UpdateTransactionRequest, UpdateUserRequest, AppVersionResponse, CategoryBreakdownResponse, DailySpendingResponse (+9 more)

### Community 13 - "analysis_screen.dart"
Cohesion: 0.06
Nodes (35): _allPayments, build, _buildCategoryList, _buildClassificationToggleButton, _buildHeader, _categories, _categoryOverrides, _classificationMode (+27 more)

### Community 14 - "user_preferences_service.dart"
Cohesion: 0.06
Nodes (31): double? get, local_database_service.dart, _cachedAnalysisPeriod, _cachedDailyLimit, _cachedDefaultPaymentApp, _cachedQuickConfirm, _cachedQuickScan, getAnalysisPeriod (+23 more)

### Community 15 - "scan_and_pay_screen.dart"
Cohesion: 0.04
Nodes (52): DateTime?, amount, build, buttonBg, buttonBorder, buttonIcon, cornerRadius, createState (+44 more)

### Community 16 - "ThemeContext.js"
Cohesion: 0.27
Nodes (10): ThemeToggle(), emptySubscribe(), getServerSnapshot(), getSnapshot(), listeners, notifyListeners(), subscribe(), ThemeContext (+2 more)

### Community 17 - "upload_qr_screen.dart"
Cohesion: 0.08
Nodes (24): _amountController, _amountFocusNode, build, _buildAppBar, createState, dispose, _handlePayButton, initialAmount (+16 more)

### Community 18 - "SecurityConfig.java"
Cohesion: 0.12
Nodes (15): BackendApplication, DataSource, OpenApiConfig, SecurityConfig, CommandLineRunner, io.swagger.v3.oas.models.OpenAPI, jakarta.annotation.PostConstruct, JwtDecoder (+7 more)

### Community 19 - "transaction_repository.dart"
Cohesion: 0.08
Nodes (24): _apiClient, cleanupStalePayments, cleanupStaleTransactions, createPayment, createTransaction, deletePayment, deleteTransaction, getCachedPayments (+16 more)

### Community 20 - "single_transaction_screen.dart"
Cohesion: 0.04
Nodes (47): DraggableScrollableNotification, GoogleMapController?, _accuracy, build, _buildQuickActionButtons, _buildSectionHeader, _copyToClipboard, createState (+39 more)

### Community 21 - "package.json"
Cohesion: 0.09
Nodes (21): name, private, scripts, build, dev, lint, start, version (+13 more)

### Community 22 - "round_button.dart"
Cohesion: 0.10
Nodes (19): activeBackgroundColor, back, backgroundColor, badgeColor, borderColor, build, child, close (+11 more)

### Community 23 - "Transaction"
Cohesion: 0.10
Nodes (11): AllArgsConstructor, Builder, Entity, Getter, NoArgsConstructor, Setter, Table, Transaction (+3 more)

### Community 24 - "api_client.dart"
Cohesion: 0.08
Nodes (25): auth_service.dart, Dio, int?, checkAppVersion, createPayment, data, defaultAndroidHost, dio (+17 more)

### Community 25 - "MainActivity"
Cohesion: 0.19
Nodes (9): Context, FlutterEngine, IntArray, Intent, MethodChannel, FlutterActivity, MainActivity, BroadcastReceiver (+1 more)

### Community 27 - "mvnw"
Cohesion: 0.38
Nodes (8): mvnw script, clean(), die(), exec_maven(), hash_string(), set_java_home(), trim(), verbose()

### Community 28 - "splash_screen.dart"
Cohesion: 0.11
Nodes (18): AnimationController, Duration, build, _controller, createState, dispose, duration, _hasLocalUser (+10 more)

### Community 29 - "package:flutter/foundation.dart"
Cohesion: 0.22
Nodes (8): dart:convert, getEmail, getExpirationDate, getPayload, getSubject, isExpired, TokenValidator, package:flutter/foundation.dart

### Community 30 - "edit_amount_sheet.dart"
Cohesion: 0.14
Nodes (14): build, _controller, createState, currentAmount, dispose, EditAmountSheet, _EditAmountSheetState, _errorMessage (+6 more)

### Community 31 - "sms_filter_service.dart"
Cohesion: 0.40
Nodes (4): financialKeywords, isFinancialTransactionSms, SmsFilterService, static const List

### Community 32 - "app_update_service.dart"
Cohesion: 0.08
Nodes (23): api_client.dart, AppUpdateService, checkAppVersion, currentVersion, dismissBanner, downloadUrl, forceUpdate, fromJson (+15 more)

### Community 33 - "main.dart"
Cohesion: 0.13
Nodes (14): build, home, HulyPayApp, initializeAuth, isAuthenticated, main, nextScreen, showSplash (+6 more)

### Community 34 - "external_data.dart"
Cohesion: 0.02
Nodes (113): Acceptance of, Account, Changes to, Contact Regarding, Disclaimer of, Information We, aboutEnvironmentNoticeBody, aboutEnvironmentNoticeTitle (+105 more)

### Community 35 - "💳 HulyPay — Next-Gen Intelligent Fintech Platform"
Cohesion: 0.07
Nodes (29): 1. Prerequisites, 2. Clone Repository & Setup, 3. Environment Configuration, 4. Run on Android, 5. Run on iOS (macOS required), ⚙️ Backend (Spring Boot), Build for Production, Core Features (+21 more)

### Community 36 - "about_hulypay_screen.dart"
Cohesion: 0.15
Nodes (12): appVersion, build, _buildAppBar, _buildCreatorSection, _buildHeroBrandCard, _buildSpecRow, _buildSpecsCard, _checkForUpdates (+4 more)

### Community 37 - "payment_details_page.dart"
Cohesion: 0.08
Nodes (25): amount, _amountController, _amountFocusNode, build, _buildAmountBox, _buildAppBar, _buildAvatar, _buildNoteField (+17 more)

### Community 38 - "auth_service.dart"
Cohesion: 0.07
Nodes (26): AuthService, client, currentAccessToken, currentSession, currentUser, hasValidActiveToken, initialize, _initialized (+18 more)

### Community 40 - "sign_in_screen.dart"
Cohesion: 0.09
Nodes (21): Home/home_dashboard_screen.dart, _authSubscription, _authTimeoutTimer, build, createState, didChangeAppLifecycleState, dispose, _finishSignIn (+13 more)

### Community 41 - "State"
Cohesion: 0.09
Nodes (33): AnalysisScreen, _AnalysisScreenState, HomeDashboardScreen, _HomeDashboardScreenState, ScanAmountScreen, _ScanAmountScreenState, ScanAndPayScreen, _ScanAndPayScreenState (+25 more)

### Community 42 - "README.md"
Cohesion: 0.50
Nodes (3): Deploy on Vercel, Getting Started, Learn More

### Community 45 - "dependencies"
Cohesion: 0.17
Nodes (12): dependencies, clsx, gsap, @gsap/react, lenis, lucide-react, next, next-transition-router (+4 more)

### Community 46 - "TransactionSmsParserService"
Cohesion: 0.23
Nodes (4): TransactionSmsParserService, VerificationMatchResult, SmsParserServiceTests, java.util.regex.Pattern

### Community 47 - "User"
Cohesion: 0.11
Nodes (23): AnalyticsController, GetMapping, PutMapping, RequestMapping, RestController, UserController, AllArgsConstructor, Builder (+15 more)

### Community 49 - "dashboard/page.js"
Cohesion: 0.23
Nodes (10): DashboardPage(), handleGlobalClick(), loadData(), TransactionsTable(), deleteTransaction(), DEFAULT_USER_PREFERENCES, getUserPreferences(), saveUserPreferences() (+2 more)

### Community 50 - "user_repository.dart"
Cohesion: 0.13
Nodes (14): _apiClient, getCachedUserProfile, getUserProfile, _instance, _localDb, saveUserProfile, UserRepository, ApiClient (+6 more)

### Community 51 - "payment_methods_screen.dart"
Cohesion: 0.12
Nodes (16): Map, build, _buildAppBar, _buildInstalledAppsGrid, _buildSectionTitle, createState, initState, _installedStatus (+8 more)

### Community 52 - "upi_service.dart"
Cohesion: 0.11
Nodes (17): amazonPayPackageName, amount, buildPaymentUri, currency, googlePayPackageName, isUpiUri, launchUpiPayment, merchantCode (+9 more)

### Community 53 - "MaterialPageRoute"
Cohesion: 0.22
Nodes (9): MaterialPageRoute, _buildHeader, _openUploadQr, _openUploadFromScanner, _startSmsVerificationWorkflow, _buildAccountSection, _buildNotificationsSection, _buildSupportSection (+1 more)

### Community 54 - "dialog.dart"
Cohesion: 0.04
Nodes (46): Color? barrierColor,
  String, EdgeInsets, EdgeInsetsGeometry, accentColor, actions, _animController, backgroundColor, barrierDismissible (+38 more)

### Community 55 - "Theme/app_theme.dart"
Cohesion: 0.14
Nodes (15): ../Data/external_data.dart, build, _buildAppBar, _buildCurrentlyInDevelopmentCard, NotificationsScreen, build, _buildAppBar, _buildCurrentlyInDevelopmentCard (+7 more)

### Community 56 - "scan_payment_service.dart"
Cohesion: 0.06
Nodes (32): google_pay_service.dart, location_service.dart, app, appName, checkPreferredAppReadiness, createPendingPayment, ensureSmsPermission, generateAmountQr (+24 more)

### Community 57 - "transaction_detail_components.dart"
Cohesion: 0.12
Nodes (16): Color, backgroundColor, borderColor, build, canCopy, customIcon, icon, iconColor (+8 more)

### Community 58 - "api.js"
Cohesion: 0.20
Nodes (16): BackendStatusBar(), verify(), checkBackendHealth(), getCategoryBreakdown(), getDailySpending(), getExpenses(), getMonthlySpending(), getSpendingSummary() (+8 more)

### Community 61 - "sms_verification_dialog.dart"
Cohesion: 0.07
Nodes (30): _badgeText, _bodyText, build, _cancel, _close, createState, dispose, icon (+22 more)

### Community 66 - "org.springframework.stereotype.Service"
Cohesion: 0.21
Nodes (7): EncryptionService, EnvelopeEncryptionService, EnvelopeEncryptionServiceTests, java.security.SecureRandom, javax.crypto.SecretKey, lombok.extern.slf4j.Slf4j, org.springframework.stereotype.Service

### Community 67 - "package:flutter_svg/flutter_svg.dart"
Cohesion: 0.14
Nodes (12): activeCategory, build, CategoryPickerSheet, onSelectCategory, show, build, _buildNavItem, CustomBottomNavBar (+4 more)

### Community 68 - "📱 Huly Pay — Mobile Client Setup & Development Guide"
Cohesion: 0.07
Nodes (26): Build optimized release APK:, ⚙️ Configuration & Environment, 📦 Core Dependencies & Tech Stack, 💳 Huly Pay Mobile Application, 🌟 Key Features, Output:, 📁 Project Architecture & Directory Layout, Run locally on an Android device or emulator: (+18 more)

### Community 69 - "transaction_map_section.dart"
Cohesion: 0.08
Nodes (24): accuracy, build, _buildGoogleMapContent, _buildMapFallbackCanvas, _buildStreetViewContent, _buildTab, createState, gridColor (+16 more)

### Community 70 - "transaction_pdf_service.dart"
Cohesion: 0.18
Nodes (10): dart:io, _buildDetailRow, _buildDivider, _formatProvider, generateReceipt, TransactionPdfService, package:flutter/services.dart, package:path_provider/path_provider.dart (+2 more)

### Community 71 - "weekly_bar_chart.dart"
Cohesion: 0.12
Nodes (17): build, _buildBarChartData, _buildLegendItem, _calculateMax, _computeWeeklyData, createState, _defaultBarColor, _getBottomTitles (+9 more)

### Community 72 - "qr_service.dart"
Cohesion: 0.11
Nodes (17): dart:async, dart:ui, _cacheKey, clearCache, _debounceTimer, _fileCache, _generateInternal, getOrGenerateQrFile (+9 more)

### Community 73 - "scan_amount_screen.dart"
Cohesion: 0.13
Nodes (14): FocusNode, _amountController, _amountFocusNode, build, _buildAppBar, createState, dispose, _handleScanButton (+6 more)

### Community 74 - "transaction_details_card.dart"
Cohesion: 0.14
Nodes (13): double?, accuracy, build, category, latitude, longitude, onCategoryTap, paymentMethod (+5 more)

### Community 75 - "encrypt_csv.py"
Cohesion: 0.25
Nodes (10): decrypt_value_gcm(), derive_key(), encrypt_value_gcm(), main(), process_csv(), Read CSV, process selected columns, write to output CSV., HulyPay - Selective Column CSV Encryptor / Decryptor…, Derive a 256-bit (32 bytes) key using PBKDF2 HMAC-SHA256. (+2 more)

### Community 76 - "org.springframework.security.oauth2.jwt.Jwt"
Cohesion: 0.14
Nodes (14): GetMapping, PutMapping, RequestMapping, RestController, TransactionController, BadRequestException, ResourceNotFoundException, TransactionResponse (+6 more)

### Community 78 - "features/page.js"
Cohesion: 0.05
Nodes (43): CIPHER_FLOW, PLAIN_FLOW, VeinTextFlow(), BellNotificationAnimation(), LockJwtAnimation(), PieChartAnimation(), EXTRA_PIXELS, MORPH_PIXELS (+35 more)

### Community 82 - "navbar_switch_button.dart"
Cohesion: 0.12
Nodes (15): IconData, build, _buildThemeOptionCard, createState, onThemeChanged, show, build, icon (+7 more)

### Community 84 - "react"
Cohesion: 0.19
Nodes (18): react, AreaChartSpending(), chartConfig, TIMEFRAMES, BarChartMonthly(), chartConfig, PieChartCategories(), chartConfig (+10 more)

### Community 85 - "String?"
Cohesion: 0.13
Nodes (14): active, authProvider, avatarUrl, copyWith, email, firstName, fromJson, fullName (+6 more)

### Community 86 - "help_support_screen.dart"
Cohesion: 0.15
Nodes (12): build, _buildAppBar, _buildContactCard, _buildFaqItem, _buildFaqSection, _copyToClipboard, createState, _launchEmail (+4 more)

### Community 87 - "AppVersionControllerTests"
Cohesion: 0.23
Nodes (4): VersionComparisonService, AppVersionControllerTests, org.junit.jupiter.api.DisplayName, org.springframework.test.context.TestPropertySource

### Community 88 - "category_pie_chart.dart"
Cohesion: 0.14
Nodes (14): List, AnalysisCategoryPieChart, _AnalysisCategoryPieChartState, bottomRightAction, build, centerLabel, createState, items (+6 more)

### Community 91 - "app_theme.dart"
Cohesion: 0.02
Nodes (98): AppThemeData get, Brightness, Color get, ColorScheme get, LinearGradient get, accent, allPalettes, amber (+90 more)

### Community 94 - "org.junit.jupiter.api.Test"
Cohesion: 0.15
Nodes (11): AnalyticsControllerTests, BackendApplicationTests, ExpenseControllerTests, HealthControllerTests, PaymentControllerTests, SecurityAndUserTests, org.junit.jupiter.api.Test, org.springframework.beans.factory.annotation.Autowired (+3 more)

### Community 95 - "Service/user_preferences_service.dart"
Cohesion: 0.22
Nodes (8): Components/round_button.dart, AppUpdateInfo, AppUpdateBanner, AppUpdateFloatingBanner, build, updateInfo, Service/app_update_service.dart, Service/user_preferences_service.dart

### Community 96 - "org.springframework.web.bind.annotation.GetMapping"
Cohesion: 0.16
Nodes (14): MobileAppProperties, PlatformConfig, AppVersionController, DatabaseHealthController, DatabaseHealthResponse, HealthController, HealthResponse, io.swagger.v3.oas.annotations.Operation (+6 more)

### Community 97 - "today_spend_gauge.dart"
Cohesion: 0.08
Nodes (24): CustomPainter, dart:math, ScannerOverlayPainter, activeColor, build, _buildZoneIndicator, _computeTodaySpend, createState (+16 more)

### Community 98 - "EncryptedStringConverter"
Cohesion: 0.31
Nodes (5): EncryptedStringConverter, jakarta.persistence.AttributeConverter, jakarta.persistence.Converter, org.springframework.stereotype.Component, Override

### Community 99 - "layout.js"
Cohesion: 0.13
Nodes (17): dotoFont, geistMono, geistSans, metadata, pixelifySans, SmoothScroll(), AnimatedSignature(), InitialLoader() (+9 more)

### Community 100 - "spending_heatmap.dart"
Cohesion: 0.07
Nodes (27): build, _buildFooter, _buildGrid, _buildHeader, cells, columns, _computePeriodTotal, createState (+19 more)

### Community 101 - "../Model/transaction_model.dart"
Cohesion: 0.22
Nodes (8): TransactionItem, build, onTap, payment, transaction, ../../Model/dashboard_data.dart, ../Model/transaction_model.dart, ../../Screen/Transaction/single_transaction_screen.dart

### Community 102 - "devDependencies"
Cohesion: 0.33
Nodes (6): devDependencies, babel-plugin-react-compiler, eslint, eslint-config-next, tailwindcss, @tailwindcss/postcss

### Community 103 - "StatelessWidget"
Cohesion: 0.11
Nodes (18): _AmountBadge, _HeatmapGridWidget, RoundButton, CardDialog, CardDialogTitleIcon, TransactionActionButton, TransactionDetailRow, TransactionDetailsCard (+10 more)

### Community 105 - "payment_dialogs.dart"
Cohesion: 0.14
Nodes (13): dialog.dart, build, colors, false, filledDialogButton, MissingAppAction, payment, PaymentSummaryLines (+5 more)

### Community 107 - "package:flutter/material.dart"
Cohesion: 0.09
Nodes (23): Container, main, main, main, main, main, main, main (+15 more)

### Community 108 - "AuthContext.js"
Cohesion: 0.21
Nodes (9): AuthContext, AuthProvider(), getInitialAuth(), getCurrentUserProfile(), signInWithGitHub(), signInWithGoogle(), signOut(), supabase (+1 more)

### Community 114 - "qr_share_service.dart"
Cohesion: 0.14
Nodes (13): _channel, googlePayPackage, pickAndShareQrImage, pickQrImage, QrShareService, shareQrImage, _showSnackBar, _supportedImageExtensions (+5 more)

## Knowledge Gaps
- **1281 isolated node(s):** `com.hulypay:backend`, `eslintConfig`, `paths`, `nextConfig`, `name` (+1276 more)
  These have ≤1 connection - possible missing edges or undocumented components. (Counts symbols only; 1497 node(s) total have ≤1 connection when file, concept and rationale nodes are included.)
- **18 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `PaymentRepository` connect `Transaction` to `transaction_repository.dart`?**
  _High betweenness centrality (0.191) - this node is a cross-community bridge._
- **Why does `Transaction` connect `Transaction` to `EncryptedStringConverter`, `org.springframework.security.oauth2.jwt.Jwt`, `lombok.Data`, `TransactionSmsParserService`, `User`?**
  _High betweenness centrality (0.062) - this node is a cross-community bridge._
- **Why does `TransactionRepository` connect `Transaction` to `org.springframework.security.oauth2.jwt.Jwt`, `User`?**
  _High betweenness centrality (0.019) - this node is a cross-community bridge._
- **What connects `com.hulypay:backend`, `eslintConfig`, `paths` to the rest of the system?**
  _1281 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `spend_trend_line_chart.dart` be split into smaller, more focused modules?**
  _Cohesion score 0.08695652173913043 - nodes in this community are weakly interconnected._
- **Should `location_service.dart` be split into smaller, more focused modules?**
  _Cohesion score 0.08695652173913043 - nodes in this community are weakly interconnected._
- **Should `google_pay_service.dart` be split into smaller, more focused modules?**
  _Cohesion score 0.05555555555555555 - nodes in this community are weakly interconnected._