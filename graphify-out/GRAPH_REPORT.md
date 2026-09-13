# Graph Report - Huly.pay  (2026-09-13)

## Corpus Check
- 140 files · ~178,451 words
- Verdict: corpus is large enough that graph structure adds value.

## Summary
- 1276 nodes · 2076 edges · 110 communities (58 shown, 39 thin omitted)
- Extraction: 96% EXTRACTED · 4% INFERRED · 0% AMBIGUOUS · INFERRED: 87 edges (avg confidence: 0.82)
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `4292ea43`
- Run `git rev-parse HEAD` and compare to check if the graph is stale.
- Run `graphify update .` after code changes (no API cost).

## Community Hubs (Navigation)
- lombok.AllArgsConstructor
- Expense
- Category
- dashboard_data.dart
- package.json
- GeneratedPluginRegistrant.swift
- local_database_service.dart
- my_application.cc
- home_dashboard_screen.dart
- settings_screen.dart
- transactions_screen.dart
- payment_model.dart
- ErrorResponse
- analysis_screen.dart
- donut_chart.dart
- scan_and_pay_screen.dart
- Win32Window
- HulyPay_5_Phase_FullStack_Workload.md
- SecurityConfig.java
- wWinMain
- single_transaction_screen.dart
- package:flutter/material.dart
- auth_service.dart
- expense_model.dart
- api_client.dart
- manifest.json
- HulyPay Backend Implementation Specification
- mvnw
- sign_in_screen.dart
- jakarta.annotation.PostConstruct
- Spring Boot API
- custom_bottom_nav_bar.dart
- Huly Pay — Final UI + Real Connection Verification.md
- main.dart
- transaction_tile.dart
- user_profile.dart
- State
- splash_screen.dart
- location_service.dart
- FlutterActivity
- Transactions List UI Screenshot
- Linux Project CMakeLists
- Web Index HTML
- Windows Project CMakeLists
- Analytics Module
- iOS Launch Image
- Huly.Pay Frontend Documentation
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
- DatabaseHealthController
- org.springframework.http.ResponseEntity
- rules/graphify.md
- workflows/graphify.md
- String?
- widget_test.dart
- mock_data.dart
- CustomPainter
- User
- lombok.RequiredArgsConstructor
- ExpenseResponse
- org.springframework.transaction.annotation.Transactional
- local_database_service_test.dart
- CategoryResponse
- ExpenseRepository
- payment_repository.dart
- user_repository.dart
- api_service.dart
- ApiException
- SingleTransactionScreen

## God Nodes (most connected - your core abstractions)
1. `User` - 48 edges
2. `Category` - 24 edges
3. `Win32Window` - 24 edges
4. `Expense` - 20 edges
5. `Payment` - 18 edges
6. `PaymentResponse` - 18 edges
7. `ExpenseResponse` - 17 edges
8. `UserService` - 17 edges
9. `CategoryResponse` - 16 edges
10. `ErrorResponse` - 16 edges

## Surprising Connections (you probably didn't know these)
- `Home Dashboard UI` --references--> `Expense Module`  [INFERRED]
  mobile/design/home-dashboard.png → backend/HulyPay_Backend_README.md
- `Scan and Pay UI` --references--> `Payment Module`  [INFERRED]
  mobile/design/scan-and-pay.png → backend/HulyPay_Backend_README.md
- `Spending Analysis UI` --references--> `Analytics Module`  [INFERRED]
  mobile/design/analysis.png → backend/HulyPay_Backend_README.md
- `Flutter Pubspec` --conceptually_related_to--> `HulyPay Backend Implementation Specification`  [INFERRED]
  mobile/pubspec.yaml → backend/HulyPay_Backend_README.md
- `Hero Diagram` --conceptually_related_to--> `Flutter Mobile Application`  [INFERRED]
  Frontend/src/assets/hero.png → Frontend/README.md

## Import Cycles
- None detected.

## Hyperedges (group relationships)
- **Merchant Resolution Pipeline** — upi_intent_flow, google_maps_platform, spring_boot_api, supabase_postgresql [EXTRACTED 0.90]
- **JWT Authentication Flow** — supabase_auth, backend_src_main_resources_application, com_hulypay_backend_users [EXTRACTED 1.00]
- **Core Domain Entities** — com_hulypay_backend_users, com_hulypay_backend_expenses, com_hulypay_backend_payments, com_hulypay_backend_analytics [EXTRACTED 1.00]
- **Hulypay App Branding Assets** — mobile_ios_runner_assets_appicon_1024, mobile_macos_runner_assets_appicon_256, mobile_ios_runner_assets_appicon_60_3x [EXTRACTED 1.00]
- **Hulypay Mobile UI Design** — mobile_design_setting, mobile_design_single_transaction, mobile_design_transactions [EXTRACTED 1.00]
- **Linux Build Configuration** — mobile_linux_cmakelists, mobile_linux_flutter_cmakelists, mobile_linux_runner_cmakelists [EXTRACTED 1.00]
- **Payment Verification & Reconciliation Flow** — flutter_mobile_app, upi_intent_flow, spring_boot_api, supabase_postgresql [EXTRACTED 1.00]
- **Windows Build Configuration** — mobile_windows_cmakelists, mobile_windows_flutter_cmakelists, mobile_windows_runner_cmakelists [EXTRACTED 1.00]

## Communities (110 total, 39 thin omitted)

### Community 0 - "lombok.AllArgsConstructor"
Cohesion: 0.15
Nodes (27): CategoryBreakdownResponse, DailySpendingResponse, MonthlySpendingResponse, SpendingSummaryResponse, CategoryRequest, CreateExpenseRequest, UpdateExpenseRequest, CreatePaymentRequest (+19 more)

### Community 1 - "Expense"
Cohesion: 0.20
Nodes (8): Expense, AllArgsConstructor, Builder, Entity, Getter, NoArgsConstructor, Setter, Table

### Community 2 - "Category"
Cohesion: 0.06
Nodes (32): Category, AllArgsConstructor, Builder, Entity, Getter, NoArgsConstructor, Setter, Table (+24 more)

### Community 3 - "dashboard_data.dart"
Cohesion: 0.07
Nodes (29): amount, avatarUrl, category, CategorySpendingItem, changePercent, changePeriodLabel, color, day (+21 more)

### Community 4 - "package.json"
Cohesion: 0.05
Nodes (40): dependencies, react, react-dom, devDependencies, @babel/core, babel-plugin-react-compiler, eslint, @eslint/js (+32 more)

### Community 5 - "GeneratedPluginRegistrant.swift"
Cohesion: 0.05
Nodes (32): Any, app_links, Cocoa, Flutter, FlutterAppDelegate, FlutterImplicitEngineBridge, FlutterImplicitEngineDelegate, FlutterMacOS (+24 more)

### Community 6 - "local_database_service.dart"
Cohesion: 0.06
Nodes (33): Database?, clearAll, clearPayments, clearUserProfile, close, _db, dbName, dbVersion (+25 more)

### Community 7 - "my_application.cc"
Cohesion: 0.09
Nodes (22): FlPluginRegistry, FlView, GApplication, gboolean, gchar, GObject, GtkApplication, fl_register_plugins() (+14 more)

### Community 8 - "home_dashboard_screen.dart"
Cohesion: 0.09
Nodes (21): analysis_screen.dart, DashboardData, _applyData, build, _buildBody, _buildDashboardContent, _buildHeader, _buildQuickActions (+13 more)

### Community 9 - "settings_screen.dart"
Cohesion: 0.08
Nodes (24): appVersion, build, _buildAccountSection, _buildGroupCard, _buildLogoutCard, _buildPreferencesSection, _buildProfileCard, _buildSettingRow (+16 more)

### Community 10 - "transactions_screen.dart"
Cohesion: 0.09
Nodes (21): _allGroups, build, _buildFilterChips, _buildGroupedTransactions, _buildHeader, _buildSearchBar, createState, dispose (+13 more)

### Community 11 - "payment_model.dart"
Cohesion: 0.05
Nodes (42): dashboard_data.dart, double?, amount, createdAt, CreatePaymentPayload, currency, expenseId, fromJson (+34 more)

### Community 12 - "ErrorResponse"
Cohesion: 0.19
Nodes (12): ErrorResponse, GlobalExceptionHandler, com.fasterxml.jackson.annotation.JsonInclude, NoResourceFoundException, org.springframework.dao.DataIntegrityViolationException, org.springframework.security.access.AccessDeniedException, org.springframework.security.core.AuthenticationException, org.springframework.web.bind.annotation.ExceptionHandler (+4 more)

### Community 13 - "analysis_screen.dart"
Cohesion: 0.10
Nodes (20): ../data/mock_data.dart, AnalysisScreen, _AnalysisScreenState, build, _buildCategoryList, _buildHeader, _categories, createState (+12 more)

### Community 14 - "donut_chart.dart"
Cohesion: 0.12
Nodes (17): List, HulyPayApp, QuickActionButton, CustomBottomNavBar, build, centerLabel, DonutChart, items (+9 more)

### Community 15 - "scan_and_pay_screen.dart"
Cohesion: 0.07
Nodes (28): build, cornerColor, cornerLength, cornerRadius, createState, dispose, _handleBack, _handleBarcodeDetected (+20 more)

### Community 16 - "Win32Window"
Cohesion: 0.05
Nodes (57): RegisterPlugins(), DartProject, HWND, LPARAM, LRESULT, UINT, WPARAM, FlutterWindow (+49 more)

### Community 17 - "HulyPay_5_Phase_FullStack_Workload.md"
Cohesion: 0.04
Nodes (45): Acceptance criteria, Acceptance criteria, Acceptance criteria, Acceptance criteria, APIs, Backend, Backend, Backend analytics (+37 more)

### Community 18 - "SecurityConfig.java"
Cohesion: 0.21
Nodes (11): OpenApiConfig, SecurityConfig, io.swagger.v3.oas.models.OpenAPI, JwtDecoder, OpenAPI, org.springframework.context.annotation.Bean, org.springframework.context.annotation.Configuration, org.springframework.security.config.annotation.web.builders.HttpSecurity (+3 more)

### Community 19 - "wWinMain"
Cohesion: 0.24
Nodes (9): _In_, _In_opt_, wWinMain(), string, wchar_t, CreateAndAttachConsole(), GetCommandLineArguments(), Utf8FromUtf16() (+1 more)

### Community 20 - "single_transaction_screen.dart"
Cohesion: 0.06
Nodes (34): double get, _accuracy, build, _buildActionButton, _buildDarkMapFallbackCanvas, _buildDetailRow, _buildDetailsCard, _buildGoogleMapContent (+26 more)

### Community 21 - "package:flutter/material.dart"
Cohesion: 0.17
Nodes (12): main, main, main, package:flutter/material.dart, package:flutter_test/flutter_test.dart, package:mobile/models/dashboard_data.dart, package:mobile/models/user_profile.dart, package:mobile/screens/sign_in_screen.dart (+4 more)

### Community 22 - "auth_service.dart"
Cohesion: 0.08
Nodes (24): bool get, AuthService, currentSession, currentUser, _devToken, _devUser, initialize, _initialized (+16 more)

### Community 23 - "expense_model.dart"
Cohesion: 0.06
Nodes (29): category_model.dart, CategoryModel, color, fromJson, icon, id, isDefault, name (+21 more)

### Community 24 - "api_client.dart"
Cohesion: 0.07
Nodes (26): auth_service.dart, Dio, int?, createCategory, createExpense, createPayment, data, dio (+18 more)

### Community 25 - "manifest.json"
Cohesion: 0.18
Nodes (10): background_color, description, display, icons, name, orientation, prefer_related_applications, short_name (+2 more)

### Community 26 - "HulyPay Backend Implementation Specification"
Cohesion: 0.20
Nodes (10): Docker Compose Configuration, HulyPay Backend Implementation Specification, Application Configuration, Expense Module, Payment Module, User Module, Home Dashboard UI, Scan and Pay UI (+2 more)

### Community 27 - "mvnw"
Cohesion: 0.38
Nodes (8): mvnw script, clean(), die(), exec_maven(), hash_string(), set_java_home(), trim(), verbose()

### Community 28 - "sign_in_screen.dart"
Cohesion: 0.11
Nodes (17): Color, home_dashboard_screen.dart, build, createState, _finishSignIn, _handleBack, _handleGitHubSignIn, _handleGoogleSignIn (+9 more)

### Community 29 - "jakarta.annotation.PostConstruct"
Cohesion: 0.36
Nodes (3): BackendApplication, jakarta.annotation.PostConstruct, org.springframework.boot.autoconfigure.SpringBootApplication

### Community 30 - "Spring Boot API"
Cohesion: 0.25
Nodes (8): Flutter Mobile Application, Flutter Web Dashboard, Hero Diagram, Frontend Entry HTML, Google Maps Platform, Spring Boot API, Supabase PostgreSQL, UPI Intent Flow

### Community 31 - "custom_bottom_nav_bar.dart"
Cohesion: 0.12
Nodes (15): IconData?, build, icon, label, onTap, svgAsset, build, _buildNavItem (+7 more)

### Community 32 - "Huly Pay — Final UI + Real Connection Verification.md"
Cohesion: 0.04
Nodes (45): 10. Map / Street View Toggle, 11. QR Scanner Workflow, 12. Payment Workflow, 13. Payment Method, 14. Backend Architecture, 15. Android Emulator + Local Backend, 16. Database, 17. Profile & Settings (+37 more)

### Community 33 - "main.dart"
Cohesion: 0.12
Nodes (16): appFontFallback, appFontFamily, build, home, initialize, main, showSplash, supabaseAnonKey (+8 more)

### Community 34 - "transaction_tile.dart"
Cohesion: 0.15
Nodes (12): MaterialPageRoute, TransactionItem, PaymentModel, _openScanAndPay, _openScanAndPay, _openScanAndPay, build, onTap (+4 more)

### Community 35 - "user_profile.dart"
Cohesion: 0.15
Nodes (12): active, authProvider, avatarUrl, email, firstName, fromJson, fullName, id (+4 more)

### Community 36 - "State"
Cohesion: 0.21
Nodes (13): HomeDashboardScreen, _HomeDashboardScreenState, SettingsScreen, _SettingsScreenState, SignInScreen, _SignInScreenState, SplashScreen, _SplashScreenState (+5 more)

### Community 37 - "splash_screen.dart"
Cohesion: 0.11
Nodes (17): Animation, AnimationController, dart:async, Duration, build, _controller, createState, dispose (+9 more)

### Community 38 - "location_service.dart"
Cohesion: 0.18
Nodes (10): accuracyMeters, getCurrentPaymentLocation, _instance, latitude, LocationService, longitude, PaymentLocation, toString (+2 more)

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

### Community 90 - "DatabaseHealthController"
Cohesion: 0.26
Nodes (6): DatabaseHealthController, DatabaseHealthResponse, HealthController, HealthResponse, javax.sql.DataSource, org.springframework.web.bind.annotation.RestController

### Community 91 - "org.springframework.http.ResponseEntity"
Cohesion: 0.21
Nodes (10): AnalyticsController, DeleteMapping, DeleteMapping, GetMapping, PostMapping, PutMapping, org.springframework.http.ResponseEntity, org.springframework.security.oauth2.jwt.Jwt (+2 more)

### Community 95 - "widget_test.dart"
Cohesion: 0.20
Nodes (9): main, package:mobile/main.dart, package:mobile/screens/analysis_screen.dart, package:mobile/screens/home_dashboard_screen.dart, package:mobile/screens/settings_screen.dart, package:mobile/screens/splash_screen.dart, package:mobile/screens/transactions_screen.dart, package:mobile/widgets/action_button.dart (+1 more)

### Community 96 - "mock_data.dart"
Cohesion: 0.25
Nodes (7): analysisCategoryItems, dashboardData, MockData, transactionScreenGroups, ../models/dashboard_data.dart, static const DashboardData, static const List

### Community 97 - "CustomPainter"
Cohesion: 0.67
Nodes (3): CustomPainter, ScannerFramePainter, _MapGridPainter

### Community 98 - "User"
Cohesion: 0.12
Nodes (13): AllArgsConstructor, Builder, Entity, Getter, NoArgsConstructor, Setter, Table, User (+5 more)

### Community 99 - "lombok.RequiredArgsConstructor"
Cohesion: 0.27
Nodes (11): CategoryService, RequestMapping, RestController, PaymentController, PaymentService, UserService, java.util.List, lombok.extern.slf4j.Slf4j (+3 more)

### Community 100 - "ExpenseResponse"
Cohesion: 0.20
Nodes (8): ExpenseResponse, ExpenseController, GetMapping, PostMapping, PutMapping, RequestMapping, RestController, ExpenseService

### Community 101 - "org.springframework.transaction.annotation.Transactional"
Cohesion: 0.21
Nodes (4): BadRequestException, ResourceNotFoundException, org.springframework.transaction.annotation.Transactional, org.springframework.web.bind.annotation.ResponseStatus

### Community 102 - "local_database_service_test.dart"
Cohesion: 0.14
Nodes (13): LocalDatabaseService, dbService, main, main, package:mobile/models/category_model.dart, package:mobile/models/expense_model.dart, package:mobile/models/payment_model.dart, package:mobile/repositories/payment_repository.dart (+5 more)

### Community 103 - "CategoryResponse"
Cohesion: 0.22
Nodes (7): CategoryController, GetMapping, PostMapping, PutMapping, RequestMapping, RestController, CategoryResponse

### Community 104 - "ExpenseRepository"
Cohesion: 0.29
Nodes (3): AnalyticsService, ExpenseRepository, org.springframework.data.jpa.repository.Query

### Community 105 - "payment_repository.dart"
Cohesion: 0.17
Nodes (11): dart:io, _apiClient, createPayment, getCachedPayments, getPaymentById, getPayments, _instance, _localDb (+3 more)

### Community 106 - "user_repository.dart"
Cohesion: 0.17
Nodes (11): _apiClient, getCachedUserProfile, getUserProfile, _instance, _localDb, saveUserProfile, UserRepository, ApiClient (+3 more)

### Community 107 - "api_service.dart"
Cohesion: 0.18
Nodes (10): api_client.dart, ApiService, baseUrl, client, fetchUserProfile, getCurrentUser, ../models/user_profile.dart, package:http/http.dart (+2 more)

## Knowledge Gaps
- **573 isolated node(s):** `name`, `private`, `version`, `type`, `dev` (+568 more)
  These have ≤1 connection - possible missing edges or undocumented components. (Counts symbols only; 754 node(s) total have ≤1 connection when file, concept and rationale nodes are included.)
- **39 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `User` connect `User` to `lombok.AllArgsConstructor`, `Expense`, `Category`, `lombok.RequiredArgsConstructor`, `ExpenseResponse`, `org.springframework.transaction.annotation.Transactional`, `CategoryResponse`, `ExpenseRepository`, `org.springframework.http.ResponseEntity`?**
  _High betweenness centrality (0.016) - this node is a cross-community bridge._
- **Why does `PaymentModel` connect `transaction_tile.dart` to `payment_model.dart`, `dashboard_data.dart`, `single_transaction_screen.dart`?**
  _High betweenness centrality (0.008) - this node is a cross-community bridge._
- **Why does `Category` connect `Category` to `lombok.AllArgsConstructor`, `Expense`, `User`, `lombok.RequiredArgsConstructor`, `org.springframework.transaction.annotation.Transactional`, `CategoryResponse`?**
  _High betweenness centrality (0.007) - this node is a cross-community bridge._
- **What connects `name`, `private`, `version` to the rest of the system?**
  _573 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `lombok.AllArgsConstructor` be split into smaller, more focused modules?**
  _Cohesion score 0.14747474747474748 - nodes in this community are weakly interconnected._
- **Should `Category` be split into smaller, more focused modules?**
  _Cohesion score 0.06467661691542288 - nodes in this community are weakly interconnected._
- **Should `dashboard_data.dart` be split into smaller, more focused modules?**
  _Cohesion score 0.06666666666666667 - nodes in this community are weakly interconnected._