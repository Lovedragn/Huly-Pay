# Graph Report - Huly.pay  (2026-10-06)

## Corpus Check
- 197 files · ~244,128 words
- Verdict: corpus is large enough that graph structure adds value.

## Summary
- 2246 nodes · 3565 edges · 117 communities (93 shown, 19 thin omitted)
- Extraction: 98% EXTRACTED · 2% INFERRED · 0% AMBIGUOUS · INFERRED: 84 edges (avg confidence: 0.81)
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `a997302c`
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
- ErrorResponse
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
- org.springframework.http.ResponseEntity
- User
- api_client.dart
- MainActivity
- Docker Compose Configuration
- mvnw
- splash_screen.dart
- package:flutter/foundation.dart
- scan_amount_screen.dart
- sms_filter_service.dart
- app_update_service.dart
- main.dart
- external_data.dart
- 💳 HulyPay — Next-Gen Intelligent Fintech Platform
- AnalyticsController.java
- user_profile.dart
- auth_service.dart
- AppThemeContextExtension
- sign_in_screen.dart
- State
- README.md
- compilerOptions
- next.config.mjs
- transaction_detail_components.dart
- .parse
- TransactionResponse
- AppThemeData
- dashboard/page.js
- user_repository.dart
- payment_methods_screen.dart
- VoidCallback?
- MaterialPageRoute
- card_dialog.dart
- round_button.dart
- scan_payment_service.dart
- ../models/transaction_model.dart
- api.js
- hulypay/MainActivity.kt
- LaunchImage.imageset/README.md
- sms_verification_dialog.dart
- org.springframework.stereotype.Service
- EncryptedStringConverter
- 📱 Huly Pay — Mobile Client Setup & Development Guide
- transaction_map_section.dart
- transaction_pdf_service.dart
- home_weekly_bar_chart.dart
- qr_service.dart
- edit_amount_sheet.dart
- transaction_details_card.dart
- encrypt_csv.py
- StatelessWidget
- TransactionRepository
- features/page.js
- AGENTS.md
- eslint.config.mjs
- postcss.config.mjs
- scanner_circle_button.dart
- react
- payment_details_page.dart
- ApiException
- AppVersionControllerTests
- analysis_category_pie_chart.dart
- com.hulypay:backend
- help_support_screen.dart
- app_theme.dart
- rules/graphify.md
- workflows/graphify.md
- org.junit.jupiter.api.Test
- EnvelopeEncryptionServiceTests
- org.springframework.web.bind.annotation.GetMapping
- home_today_spend_gauge.dart
- .decrypt
- layout.js
- spending_heatmap.dart
- customization_bottom_sheet.dart
- google_pay_service.dart
- package:flutter_svg/flutter_svg.dart
- about_hulypay_screen.dart
- payment_dialogs.dart
- ../theme/app_theme.dart
- package:flutter/material.dart
- AuthContext.js
- app_update_dialog.dart
- transaction_receipt_card.dart
- Color
- String?
- bool?
- qr_share_service.dart
- dependencies
- CustomPainter

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
- `AppVersionController` --references--> `MobileAppProperties`  [EXTRACTED]
  backend/src/main/java/com/hulypay/backend/Controllers/AppVersionController.java → backend/src/main/java/com/hulypay/backend/config/MobileAppProperties.java
- `AppVersionController` --references--> `VersionComparisonService`  [EXTRACTED]
  backend/src/main/java/com/hulypay/backend/Controllers/AppVersionController.java → backend/src/main/java/com/hulypay/backend/Services/VersionComparisonService.java
- `TransactionController` --references--> `TransactionService`  [EXTRACTED]
  backend/src/main/java/com/hulypay/backend/Controllers/TransactionController.java → backend/src/main/java/com/hulypay/backend/Services/TransactionService.java
- `TransactionController` --references--> `UserService`  [EXTRACTED]
  backend/src/main/java/com/hulypay/backend/Controllers/TransactionController.java → backend/src/main/java/com/hulypay/backend/Services/UserService.java
- `AnalyticsService` --references--> `TransactionRepository`  [EXTRACTED]
  backend/src/main/java/com/hulypay/backend/Services/AnalyticsService.java → backend/src/main/java/com/hulypay/backend/Repositories/TransactionRepository.java

## Import Cycles
- None detected.

## Communities (117 total, 19 thin omitted)

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
Nodes (38): allApps, amazon, amazonPay, appNotInstalled, askEveryTime, bhim, bhimApp, buildSafeUpiUri (+30 more)

### Community 5 - "AppDelegate"
Cohesion: 0.11
Nodes (14): Any, Flutter, FlutterAppDelegate, FlutterImplicitEngineBridge, FlutterImplicitEngineDelegate, FlutterSceneDelegate, AppDelegate, Bool (+6 more)

### Community 6 - "local_database_service.dart"
Cohesion: 0.05
Nodes (39): Database?, cleanupStalePayments, clearAll, clearPayments, clearUserProfile, close, _db, dbName (+31 more)

### Community 7 - "ErrorResponse"
Cohesion: 0.19
Nodes (12): ErrorResponse, GlobalExceptionHandler, com.fasterxml.jackson.annotation.JsonInclude, NoResourceFoundException, org.springframework.dao.DataIntegrityViolationException, org.springframework.security.access.AccessDeniedException, org.springframework.security.core.AuthenticationException, org.springframework.web.bind.annotation.ExceptionHandler (+4 more)

### Community 8 - "home_dashboard_screen.dart"
Cohesion: 0.05
Nodes (39): Animation, _applyData, build, _buildAvatarFallback, _buildBody, _buildDashboardContent, _buildQuickActions, _buildTotalSpentCard (+31 more)

### Community 9 - "settings_screen.dart"
Cohesion: 0.06
Nodes (32): about_hulypay_screen.dart, help_support_screen.dart, appVersion, _avatarUrl, build, _buildGroupCard, _buildLogoutCard, _buildPreferencesSection (+24 more)

### Community 10 - "transactions_screen.dart"
Cohesion: 0.09
Nodes (22): analysis_screen.dart, _allGroups, build, _buildFilterChips, _buildHeader, _buildSearchBar, createState, dispose (+14 more)

### Community 11 - "transaction_model.dart"
Cohesion: 0.06
Nodes (35): dashboard_data.dart, amount, category, copyWith, createdAt, CreatePaymentPayload, CreateTransactionPayload, currency (+27 more)

### Community 12 - "lombok.Data"
Cohesion: 0.23
Nodes (18): CreateTransactionRequest, TransactionReconcileRequest, TransactionSmsVerificationRequest, UpdateTransactionRequest, UpdateUserRequest, AppVersionResponse, CategoryBreakdownResponse, DailySpendingResponse (+10 more)

### Community 13 - "analysis_screen.dart"
Cohesion: 0.06
Nodes (35): _allPayments, build, _buildCategoryList, _buildClassificationToggleButton, _buildHeader, _categories, _categoryOverrides, _classificationMode (+27 more)

### Community 14 - "user_preferences_service.dart"
Cohesion: 0.06
Nodes (31): double? get, local_database_service.dart, _cachedAnalysisPeriod, _cachedDailyLimit, _cachedDefaultPaymentApp, _cachedQuickConfirm, _cachedQuickScan, getAnalysisPeriod (+23 more)

### Community 15 - "scan_and_pay_screen.dart"
Cohesion: 0.04
Nodes (47): DateTime?, amount, build, buttonBg, buttonBorder, buttonIcon, createState, dispose (+39 more)

### Community 16 - "ThemeContext.js"
Cohesion: 0.27
Nodes (10): ThemeToggle(), emptySubscribe(), getServerSnapshot(), getSnapshot(), listeners, notifyListeners(), subscribe(), ThemeContext (+2 more)

### Community 17 - "upload_qr_screen.dart"
Cohesion: 0.08
Nodes (23): _amountController, _amountFocusNode, build, _buildAppBar, createState, dispose, _handlePayButton, initialAmount (+15 more)

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
Cohesion: 0.07
Nodes (27): devDependencies, babel-plugin-react-compiler, eslint, eslint-config-next, tailwindcss, @tailwindcss/postcss, name, private (+19 more)

### Community 22 - "org.springframework.http.ResponseEntity"
Cohesion: 0.17
Nodes (11): GetMapping, PutMapping, RequestMapping, RestController, TransactionController, GetMapping, PutMapping, DeleteMapping (+3 more)

### Community 23 - "User"
Cohesion: 0.08
Nodes (23): AllArgsConstructor, Builder, Entity, Getter, NoArgsConstructor, Setter, Table, Transaction (+15 more)

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
Cohesion: 0.10
Nodes (19): AnimationController, Duration, build, _controller, createState, dispose, duration, _hasLocalUser (+11 more)

### Community 29 - "package:flutter/foundation.dart"
Cohesion: 0.22
Nodes (8): dart:convert, getEmail, getExpirationDate, getPayload, getSubject, isExpired, TokenValidator, package:flutter/foundation.dart

### Community 30 - "scan_amount_screen.dart"
Cohesion: 0.13
Nodes (15): FocusNode, _amountController, _amountFocusNode, build, _buildAppBar, createState, dispose, _handleScanButton (+7 more)

### Community 31 - "sms_filter_service.dart"
Cohesion: 0.40
Nodes (4): financialKeywords, isFinancialTransactionSms, SmsFilterService, static const List

### Community 32 - "app_update_service.dart"
Cohesion: 0.10
Nodes (20): api_client.dart, AppUpdateService, checkAppVersion, currentVersion, dismissBanner, downloadUrl, forceUpdate, fromJson (+12 more)

### Community 33 - "main.dart"
Cohesion: 0.15
Nodes (12): build, home, HulyPayApp, initializeAuth, isAuthenticated, main, nextScreen, showSplash (+4 more)

### Community 34 - "external_data.dart"
Cohesion: 0.02
Nodes (113): Acceptance of, Account, Changes to, Contact Regarding, Disclaimer of, Information We, aboutEnvironmentNoticeBody, aboutEnvironmentNoticeTitle (+105 more)

### Community 35 - "💳 HulyPay — Next-Gen Intelligent Fintech Platform"
Cohesion: 0.07
Nodes (29): 1. Prerequisites, 2. Clone Repository & Setup, 3. Environment Configuration, 4. Run on Android, 5. Run on iOS (macOS required), ⚙️ Backend (Spring Boot), Build for Production, Core Features (+21 more)

### Community 36 - "AnalyticsController.java"
Cohesion: 0.27
Nodes (9): AnalyticsController, RequestMapping, RestController, UserController, AnalyticsService, UserService, java.util.Map, lombok.RequiredArgsConstructor (+1 more)

### Community 37 - "user_profile.dart"
Cohesion: 0.14
Nodes (13): active, authProvider, avatarUrl, copyWith, email, firstName, fromJson, fullName (+5 more)

### Community 38 - "auth_service.dart"
Cohesion: 0.07
Nodes (26): AuthService, client, currentAccessToken, currentSession, currentUser, hasValidActiveToken, initialize, _initialized (+18 more)

### Community 40 - "sign_in_screen.dart"
Cohesion: 0.10
Nodes (20): home_dashboard_screen.dart, _authSubscription, _authTimeoutTimer, build, createState, didChangeAppLifecycleState, dispose, _finishSignIn (+12 more)

### Community 41 - "State"
Cohesion: 0.11
Nodes (27): AboutHulyPayScreen, _AboutHulyPayScreenState, AnalysisScreen, _AnalysisScreenState, HelpSupportScreen, _HelpSupportScreenState, HomeDashboardScreen, _HomeDashboardScreenState (+19 more)

### Community 42 - "README.md"
Cohesion: 0.50
Nodes (3): Deploy on Vercel, Getting Started, Learn More

### Community 45 - "transaction_detail_components.dart"
Cohesion: 0.12
Nodes (15): backgroundColor, borderColor, build, canCopy, customIcon, icon, iconColor, isPrimary (+7 more)

### Community 47 - "TransactionResponse"
Cohesion: 0.24
Nodes (6): BadRequestException, ResourceNotFoundException, TransactionResponse, TransactionService, org.springframework.transaction.annotation.Transactional, org.springframework.web.bind.annotation.ResponseStatus

### Community 49 - "dashboard/page.js"
Cohesion: 0.25
Nodes (9): DashboardPage(), handleGlobalClick(), TransactionsTable(), deleteTransaction(), DEFAULT_USER_PREFERENCES, getUserPreferences(), saveUserPreferences(), updateUserPreference() (+1 more)

### Community 50 - "user_repository.dart"
Cohesion: 0.13
Nodes (14): _apiClient, getCachedUserProfile, getUserProfile, _instance, _localDb, saveUserProfile, UserRepository, ApiClient (+6 more)

### Community 51 - "payment_methods_screen.dart"
Cohesion: 0.12
Nodes (16): Map, build, _buildAppBar, _buildInstalledAppsGrid, _buildSectionTitle, createState, initState, _installedStatus (+8 more)

### Community 52 - "VoidCallback?"
Cohesion: 0.18
Nodes (10): AppBackButton, backgroundColor, borderColor, build, iconColor, iconSize, onPressed, tooltip (+2 more)

### Community 53 - "MaterialPageRoute"
Cohesion: 0.22
Nodes (9): MaterialPageRoute, _buildHeader, _openUploadQr, _openUploadFromScanner, _startSmsVerificationWorkflow, _buildAccountSection, _buildNotificationsSection, _buildSupportSection (+1 more)

### Community 54 - "card_dialog.dart"
Cohesion: 0.04
Nodes (46): Color? barrierColor,
  String, EdgeInsets, EdgeInsetsGeometry, accentColor, actions, _animController, backgroundColor, barrierDismissible (+38 more)

### Community 55 - "round_button.dart"
Cohesion: 0.11
Nodes (18): activeBackgroundColor, back, backgroundColor, badgeColor, borderColor, build, child, icon (+10 more)

### Community 56 - "scan_payment_service.dart"
Cohesion: 0.06
Nodes (32): google_pay_service.dart, location_service.dart, app, appName, checkPreferredAppReadiness, createPendingPayment, ensureSmsPermission, generateAmountQr (+24 more)

### Community 57 - "../models/transaction_model.dart"
Cohesion: 0.22
Nodes (8): TransactionItem, build, onTap, payment, transaction, ../models/dashboard_data.dart, ../models/transaction_model.dart, ../screens/single_transaction_screen.dart

### Community 58 - "api.js"
Cohesion: 0.19
Nodes (17): loadData(), BackendStatusBar(), verify(), checkBackendHealth(), getCategoryBreakdown(), getDailySpending(), getExpenses(), getMonthlySpending() (+9 more)

### Community 61 - "sms_verification_dialog.dart"
Cohesion: 0.07
Nodes (30): _badgeText, _bodyText, build, _cancel, _close, createState, dispose, icon (+22 more)

### Community 66 - "org.springframework.stereotype.Service"
Cohesion: 0.27
Nodes (8): EncryptionService, EnvelopeEncryptionService, TransactionSmsParserService, java.security.SecureRandom, java.util.regex.Pattern, javax.crypto.SecretKey, lombok.extern.slf4j.Slf4j, org.springframework.stereotype.Service

### Community 67 - "EncryptedStringConverter"
Cohesion: 0.60
Nodes (4): EncryptedStringConverter, jakarta.persistence.AttributeConverter, jakarta.persistence.Converter, org.springframework.stereotype.Component

### Community 68 - "📱 Huly Pay — Mobile Client Setup & Development Guide"
Cohesion: 0.07
Nodes (26): Build optimized release APK:, ⚙️ Configuration & Environment, 📦 Core Dependencies & Tech Stack, 💳 Huly Pay Mobile Application, 🌟 Key Features, Output:, 📁 Project Architecture & Directory Layout, Run locally on an Android device or emulator: (+18 more)

### Community 69 - "transaction_map_section.dart"
Cohesion: 0.08
Nodes (24): accuracy, build, _buildGoogleMapContent, _buildMapFallbackCanvas, _buildStreetViewContent, _buildTab, createState, gridColor (+16 more)

### Community 70 - "transaction_pdf_service.dart"
Cohesion: 0.18
Nodes (10): dart:io, _buildDetailRow, _buildDivider, _formatProvider, generateReceipt, TransactionPdfService, package:flutter/services.dart, package:path_provider/path_provider.dart (+2 more)

### Community 71 - "home_weekly_bar_chart.dart"
Cohesion: 0.12
Nodes (17): build, _buildBarChartData, _buildLegendItem, _calculateMax, _computeWeeklyData, createState, _defaultBarColor, _getBottomTitles (+9 more)

### Community 72 - "qr_service.dart"
Cohesion: 0.11
Nodes (17): dart:async, dart:ui, _cacheKey, clearCache, _debounceTimer, _fileCache, _generateInternal, getOrGenerateQrFile (+9 more)

### Community 73 - "edit_amount_sheet.dart"
Cohesion: 0.12
Nodes (17): _addAmount, build, _buildQuickChip, _controller, createState, currentAmount, dispose, EditAmountSheet (+9 more)

### Community 74 - "transaction_details_card.dart"
Cohesion: 0.13
Nodes (14): double?, accuracy, build, category, latitude, longitude, onCategoryTap, paymentMethod (+6 more)

### Community 75 - "encrypt_csv.py"
Cohesion: 0.25
Nodes (10): decrypt_value_gcm(), derive_key(), encrypt_value_gcm(), main(), process_csv(), Read CSV, process selected columns, write to output CSV., HulyPay - Selective Column CSV Encryptor / Decryptor…, Derive a 256-bit (32 bytes) key using PBKDF2 HMAC-SHA256. (+2 more)

### Community 76 - "StatelessWidget"
Cohesion: 0.18
Nodes (11): NotificationsScreen, _AmountBadge, CardDialog, CardDialogTitleIcon, RoundButton, _HeatmapGridWidget, TransactionActionButton, TransactionDetailRow (+3 more)

### Community 78 - "features/page.js"
Cohesion: 0.05
Nodes (41): CIPHER_FLOW, PLAIN_FLOW, VeinTextFlow(), BellNotificationAnimation(), LockJwtAnimation(), PieChartAnimation(), EXTRA_PIXELS, MORPH_PIXELS (+33 more)

### Community 82 - "scanner_circle_button.dart"
Cohesion: 0.22
Nodes (8): background, borderColor, build, child, onTap, ScannerCircleButton, tooltip, Widget?

### Community 84 - "react"
Cohesion: 0.19
Nodes (18): react, AreaChartSpending(), chartConfig, TIMEFRAMES, BarChartMonthly(), chartConfig, PieChartCategories(), chartConfig (+10 more)

### Community 85 - "payment_details_page.dart"
Cohesion: 0.08
Nodes (23): amount, _amountController, build, _buildAmountBox, _buildAppBar, _buildAvatar, _buildNoteField, _buildPayButton (+15 more)

### Community 87 - "AppVersionControllerTests"
Cohesion: 0.23
Nodes (4): VersionComparisonService, AppVersionControllerTests, org.junit.jupiter.api.DisplayName, org.springframework.test.context.TestPropertySource

### Community 88 - "analysis_category_pie_chart.dart"
Cohesion: 0.14
Nodes (14): List, AnalysisCategoryPieChart, _AnalysisCategoryPieChartState, bottomRightAction, build, centerLabel, createState, items (+6 more)

### Community 90 - "help_support_screen.dart"
Cohesion: 0.15
Nodes (12): build, _buildAppBar, _buildContactCard, _buildFaqItem, _buildFaqSection, _copyToClipboard, createState, _launchEmail (+4 more)

### Community 91 - "app_theme.dart"
Cohesion: 0.02
Nodes (97): AppThemeData get, Brightness, Color get, ColorScheme get, LinearGradient get, accent, allPalettes, amber (+89 more)

### Community 94 - "org.junit.jupiter.api.Test"
Cohesion: 0.14
Nodes (11): AnalyticsControllerTests, BackendApplicationTests, ExpenseControllerTests, HealthControllerTests, PaymentControllerTests, SecurityAndUserTests, org.junit.jupiter.api.Test, org.springframework.beans.factory.annotation.Autowired (+3 more)

### Community 96 - "org.springframework.web.bind.annotation.GetMapping"
Cohesion: 0.21
Nodes (10): AppVersionController, DatabaseHealthController, DatabaseHealthResponse, HealthController, HealthResponse, io.swagger.v3.oas.annotations.Operation, io.swagger.v3.oas.annotations.tags.Tag, javax.sql.DataSource (+2 more)

### Community 97 - "home_today_spend_gauge.dart"
Cohesion: 0.10
Nodes (20): dart:math, activeColor, build, _buildZoneIndicator, _computeTodaySpend, createState, _customLimit, dailyBudget (+12 more)

### Community 99 - "layout.js"
Cohesion: 0.13
Nodes (16): dotoFont, geistMono, geistSans, metadata, pixelifySans, SmoothScroll(), AnimatedSignature(), InitialLoader() (+8 more)

### Community 100 - "spending_heatmap.dart"
Cohesion: 0.07
Nodes (27): build, _buildFooter, _buildGrid, _buildHeader, cells, columns, _computePeriodTotal, createState (+19 more)

### Community 101 - "customization_bottom_sheet.dart"
Cohesion: 0.25
Nodes (8): build, _buildThemeOptionCard, createState, CustomizationBottomSheet, _CustomizationBottomSheetState, onThemeChanged, show, ../services/user_preferences_service.dart

### Community 102 - "google_pay_service.dart"
Cohesion: 0.06
Nodes (35): amazonPayPackage, amount, approvalRefNo, _channel, errorMessage, fromNativeMap, fromQueryString, googlePayPackage (+27 more)

### Community 103 - "package:flutter_svg/flutter_svg.dart"
Cohesion: 0.25
Nodes (7): build, _buildNavItem, CustomBottomNavBar, onItemSelected, selectedIndex, package:flutter_svg/flutter_svg.dart, ValueChanged

### Community 104 - "about_hulypay_screen.dart"
Cohesion: 0.14
Nodes (13): appVersion, build, _buildAppBar, _buildCreatorSection, _buildHeroBrandCard, _buildSpecRow, _buildSpecsCard, _checkForUpdates (+5 more)

### Community 105 - "payment_dialogs.dart"
Cohesion: 0.15
Nodes (12): build, colors, false, filledDialogButton, MissingAppAction, payment, PaymentSummaryLines, result (+4 more)

### Community 106 - "../theme/app_theme.dart"
Cohesion: 0.12
Nodes (15): ../data/external_data.dart, build, _buildAppBar, _buildCurrentlyInDevelopmentCard, build, _buildAppBar, _buildSectionHeader, PrivacySecurityScreen (+7 more)

### Community 107 - "package:flutter/material.dart"
Cohesion: 0.11
Nodes (17): Container, main, main, main, main, main, main, package:flutter/material.dart (+9 more)

### Community 108 - "AuthContext.js"
Cohesion: 0.15
Nodes (12): LoginContent(), DashboardButton(), AuthContext, AuthProvider(), getInitialAuth(), useAuth(), getCurrentUserProfile(), signInWithGitHub() (+4 more)

### Community 109 - "app_update_dialog.dart"
Cohesion: 0.18
Nodes (10): card_dialog.dart, AppUpdateInfo, AppUpdateBanner, build, updateInfo, AppUpdateDialog, build, show (+2 more)

### Community 110 - "transaction_receipt_card.dart"
Cohesion: 0.25
Nodes (7): build, displayAmount, isIncome, merchantTitle, status, time, TransactionReceiptCard

### Community 111 - "Color"
Cohesion: 0.25
Nodes (7): Color, cornerRadius, cutoutRect, overlayColor, paint, shouldRepaint, Rect

### Community 112 - "String?"
Cohesion: 0.22
Nodes (8): IconData?, build, icon, label, onTap, QuickActionButton, svgAsset, String?

### Community 114 - "qr_share_service.dart"
Cohesion: 0.14
Nodes (13): _channel, googlePayPackage, pickAndShareQrImage, pickQrImage, QrShareService, shareQrImage, _showSnackBar, _supportedImageExtensions (+5 more)

### Community 115 - "dependencies"
Cohesion: 0.17
Nodes (12): dependencies, clsx, gsap, @gsap/react, lenis, lucide-react, next, next-transition-router (+4 more)

### Community 116 - "CustomPainter"
Cohesion: 0.50
Nodes (4): CustomPainter, _SpeedometerGaugePainter, ScannerOverlayPainter, MapGridPainter

## Knowledge Gaps
- **1286 isolated node(s):** `com.hulypay:backend`, `eslintConfig`, `paths`, `nextConfig`, `name` (+1281 more)
  These have ≤1 connection - possible missing edges or undocumented components. (Counts symbols only; 1493 node(s) total have ≤1 connection when file, concept and rationale nodes are included.)
- **19 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `PaymentRepository` connect `User` to `transaction_repository.dart`?**
  _High betweenness centrality (0.191) - this node is a cross-community bridge._
- **Why does `Transaction` connect `User` to `org.springframework.stereotype.Service`, `EncryptedStringConverter`, `lombok.Data`, `.parse`, `TransactionResponse`?**
  _High betweenness centrality (0.084) - this node is a cross-community bridge._
- **Why does `TransactionRepository` connect `User` to `lombok.Data`, `AnalyticsController.java`, `TransactionResponse`?**
  _High betweenness centrality (0.027) - this node is a cross-community bridge._
- **What connects `com.hulypay:backend`, `eslintConfig`, `paths` to the rest of the system?**
  _1286 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `home_spend_trend_line_chart.dart` be split into smaller, more focused modules?**
  _Cohesion score 0.08695652173913043 - nodes in this community are weakly interconnected._
- **Should `location_service.dart` be split into smaller, more focused modules?**
  _Cohesion score 0.08695652173913043 - nodes in this community are weakly interconnected._
- **Should `upi_service.dart` be split into smaller, more focused modules?**
  _Cohesion score 0.1111111111111111 - nodes in this community are weakly interconnected._