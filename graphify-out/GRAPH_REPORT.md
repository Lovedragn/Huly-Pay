# Graph Report - Huly.pay  (2026-09-13)

## Corpus Check
- 147 files · ~184,471 words
- Verdict: corpus is large enough that graph structure adds value.

## Summary
- 1378 nodes · 2235 edges · 113 communities (62 shown, 37 thin omitted)
- Extraction: 96% EXTRACTED · 4% INFERRED · 0% AMBIGUOUS · INFERRED: 87 edges (avg confidence: 0.82)
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `6af4a51b`
- Run `git rev-parse HEAD` and compare to check if the graph is stale.
- Run `graphify update .` after code changes (no API cost).

## Community Hubs (Navigation)
- home_spend_trend_line_chart.dart
- DatabaseHealthController
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
- List
- scan_and_pay_screen.dart
- Win32Window
- HulyPay_5_Phase_FullStack_Workload.md
- SecurityConfig.java
- wWinMain
- single_transaction_screen.dart
- widget_test.dart
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
- org.springframework.transaction.annotation.Transactional
- lombok.AllArgsConstructor
- rules/graphify.md
- workflows/graphify.md
- String?
- org.springframework.security.oauth2.jwt.Jwt
- org.springframework.http.ResponseEntity
- PaymentResponse
- home_weekly_bar_chart.dart
- lombok.RequiredArgsConstructor
- package:flutter/material.dart
- User
- ExpenseRepository
- home_today_spend_gauge.dart
- analysis_category_pie_chart.dart
- payment_repository.dart
- action_button.dart
- api_service.dart
- ../models/dashboard_data.dart
- StatelessWidget
- phase2_test.dart
- CustomPainter

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

## Communities (113 total, 37 thin omitted)

### Community 0 - "home_spend_trend_line_chart.dart"
Cohesion: 0.08
Nodes (24): amount, _bottomTitleWidgets, build, _buildAvgData, _buildCardFooter, _buildCardHeader, _buildCurvedGradientData, _buildDualZoneData (+16 more)

### Community 1 - "DatabaseHealthController"
Cohesion: 0.26
Nodes (6): DatabaseHealthController, DatabaseHealthResponse, HealthController, HealthResponse, javax.sql.DataSource, org.springframework.web.bind.annotation.RestController

### Community 2 - "Category"
Cohesion: 0.07
Nodes (32): Category, AllArgsConstructor, Builder, Entity, Getter, NoArgsConstructor, Setter, Table (+24 more)

### Community 3 - "dashboard_data.dart"
Cohesion: 0.06
Nodes (30): amount, avatarUrl, category, CategorySpendingItem, changePercent, changePeriodLabel, color, DashboardData (+22 more)

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
Cohesion: 0.07
Nodes (26): _applyData, build, _buildAvatarFallback, _buildBody, _buildDashboardContent, _buildHeader, _buildQuickActions, _buildTotalSpentCard (+18 more)

### Community 9 - "settings_screen.dart"
Cohesion: 0.08
Nodes (25): appVersion, _avatarUrl, build, _buildAccountSection, _buildGroupCard, _buildLogoutCard, _buildPreferencesSection, _buildProfileCard (+17 more)

### Community 10 - "transactions_screen.dart"
Cohesion: 0.09
Nodes (21): analysis_screen.dart, _allGroups, build, _buildFilterChips, _buildGroupedTransactions, _buildHeader, _buildSearchBar, createState (+13 more)

### Community 11 - "payment_model.dart"
Cohesion: 0.05
Nodes (42): dashboard_data.dart, double?, amount, createdAt, CreatePaymentPayload, currency, expenseId, fromJson (+34 more)

### Community 12 - "ErrorResponse"
Cohesion: 0.19
Nodes (12): ErrorResponse, GlobalExceptionHandler, com.fasterxml.jackson.annotation.JsonInclude, NoResourceFoundException, org.springframework.dao.DataIntegrityViolationException, org.springframework.security.access.AccessDeniedException, org.springframework.security.core.AuthenticationException, org.springframework.web.bind.annotation.ExceptionHandler (+4 more)

### Community 13 - "analysis_screen.dart"
Cohesion: 0.10
Nodes (20): ../data/mock_data.dart, build, _buildCategoryList, _buildHeader, _categories, createState, initialCategories, initState (+12 more)

### Community 14 - "List"
Cohesion: 0.18
Nodes (10): List, build, centerLabel, items, size, strokeWidth, totalAmount, build (+2 more)

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

### Community 21 - "widget_test.dart"
Cohesion: 0.10
Nodes (22): LocalDatabaseService, main, dbService, main, dbService, main, main, package:mobile/main.dart (+14 more)

### Community 22 - "auth_service.dart"
Cohesion: 0.07
Nodes (26): bool get, _allowDevMock, AuthService, currentSession, currentUser, _devToken, _devUser, enableMockForTesting (+18 more)

### Community 23 - "expense_model.dart"
Cohesion: 0.06
Nodes (29): category_model.dart, CategoryModel, color, fromJson, icon, id, isDefault, name (+21 more)

### Community 24 - "api_client.dart"
Cohesion: 0.07
Nodes (28): auth_service.dart, Dio, Exception, int?, ApiException, createCategory, createExpense, createPayment (+20 more)

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
Cohesion: 0.09
Nodes (23): dart:async, _authSubscription, build, createState, dispose, _finishSignIn, _handleBack, _handleGitHubSignIn (+15 more)

### Community 29 - "jakarta.annotation.PostConstruct"
Cohesion: 0.27
Nodes (3): BackendApplication, jakarta.annotation.PostConstruct, org.springframework.boot.autoconfigure.SpringBootApplication

### Community 30 - "Spring Boot API"
Cohesion: 0.25
Nodes (8): Flutter Mobile Application, Flutter Web Dashboard, Hero Diagram, Frontend Entry HTML, Google Maps Platform, Spring Boot API, Supabase PostgreSQL, UPI Intent Flow

### Community 31 - "custom_bottom_nav_bar.dart"
Cohesion: 0.22
Nodes (8): build, _buildNavItem, isQrActive, onItemSelected, onQrScanTap, selectedIndex, ValueChanged, VoidCallback?

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
Cohesion: 0.14
Nodes (13): active, authProvider, avatarUrl, copyWith, email, firstName, fromJson, fullName (+5 more)

### Community 36 - "State"
Cohesion: 0.18
Nodes (15): AnalysisScreen, _AnalysisScreenState, HomeDashboardScreen, _HomeDashboardScreenState, SingleTransactionScreen, _SingleTransactionScreenState, TransactionsScreen, _TransactionsScreenState (+7 more)

### Community 37 - "splash_screen.dart"
Cohesion: 0.08
Nodes (24): Animation, AnimationController, Duration, home_dashboard_screen.dart, build, _checkLocalStorage, _controller, createState (+16 more)

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

### Community 90 - "org.springframework.transaction.annotation.Transactional"
Cohesion: 0.20
Nodes (8): BadRequestException, ResourceNotFoundException, ExpenseResponse, PostMapping, PutMapping, ExpenseService, org.springframework.transaction.annotation.Transactional, org.springframework.web.bind.annotation.ResponseStatus

### Community 91 - "lombok.AllArgsConstructor"
Cohesion: 0.15
Nodes (26): CategoryBreakdownResponse, DailySpendingResponse, MonthlySpendingResponse, SpendingSummaryResponse, CategoryRequest, CreateExpenseRequest, UpdateExpenseRequest, CreatePaymentRequest (+18 more)

### Community 95 - "org.springframework.security.oauth2.jwt.Jwt"
Cohesion: 0.19
Nodes (10): CategoryController, DeleteMapping, GetMapping, PostMapping, PutMapping, RequestMapping, RestController, CategoryService (+2 more)

### Community 96 - "org.springframework.http.ResponseEntity"
Cohesion: 0.14
Nodes (11): ExpenseController, DeleteMapping, GetMapping, RequestMapping, RestController, GetMapping, PutMapping, RequestMapping (+3 more)

### Community 97 - "PaymentResponse"
Cohesion: 0.21
Nodes (9): PaymentResponse, GetMapping, PostMapping, PutMapping, RequestMapping, RestController, PaymentController, PaymentService (+1 more)

### Community 98 - "home_weekly_bar_chart.dart"
Cohesion: 0.12
Nodes (17): build, _buildBarChartData, _buildLegendItem, _calculateMax, _computeWeeklyData, createState, _defaultBarColor, _getBottomTitles (+9 more)

### Community 99 - "lombok.RequiredArgsConstructor"
Cohesion: 0.32
Nodes (8): AnalyticsController, AnalyticsService, UserService, java.util.List, lombok.extern.slf4j.Slf4j, lombok.RequiredArgsConstructor, org.springframework.stereotype.Service, org.springframework.web.bind.annotation.RequestMapping

### Community 100 - "package:flutter/material.dart"
Cohesion: 0.16
Nodes (14): main, main, samplePayments, main, package:flutter/material.dart, package:flutter_test/flutter_test.dart, package:mobile/models/dashboard_data.dart, package:mobile/models/payment_model.dart (+6 more)

### Community 101 - "User"
Cohesion: 0.12
Nodes (16): Expense, AllArgsConstructor, Builder, Entity, Getter, NoArgsConstructor, Setter, Table (+8 more)

### Community 102 - "ExpenseRepository"
Cohesion: 0.18
Nodes (3): ExpenseRepository, org.springframework.data.jpa.repository.Query, org.springframework.web.bind.annotation.GetMapping

### Community 103 - "home_today_spend_gauge.dart"
Cohesion: 0.15
Nodes (12): Color, dart:math, activeColor, build, _buildZoneIndicator, _computeTodaySpend, dailyBudget, maxValue (+4 more)

### Community 104 - "analysis_category_pie_chart.dart"
Cohesion: 0.22
Nodes (8): build, centerLabel, createState, items, _showingSections, showLegend, totalAmount, _touchedIndex

### Community 105 - "payment_repository.dart"
Cohesion: 0.09
Nodes (23): dart:io, _apiClient, createPayment, getCachedPayments, getPaymentById, getPayments, _instance, _localDb (+15 more)

### Community 106 - "action_button.dart"
Cohesion: 0.25
Nodes (7): IconData?, build, icon, label, onTap, svgAsset, package:flutter_svg/flutter_svg.dart

### Community 107 - "api_service.dart"
Cohesion: 0.18
Nodes (10): api_client.dart, ApiService, baseUrl, client, fetchUserProfile, getCurrentUser, ../models/user_profile.dart, package:http/http.dart (+2 more)

### Community 108 - "../models/dashboard_data.dart"
Cohesion: 0.25
Nodes (7): analysisCategoryItems, dashboardData, MockData, transactionScreenGroups, ../models/dashboard_data.dart, static const DashboardData, static const List

### Community 109 - "StatelessWidget"
Cohesion: 0.25
Nodes (8): HulyPayApp, QuickActionButton, CustomBottomNavBar, DonutChart, HomeTodaySpendGaugeChart, SpendingChart, TransactionTile, StatelessWidget

### Community 110 - "phase2_test.dart"
Cohesion: 0.29
Nodes (6): main, package:mobile/models/category_model.dart, package:mobile/models/expense_model.dart, package:mobile/screens/scan_and_pay_screen.dart, package:mobile/services/location_service.dart, package:mobile/services/upi_service.dart

### Community 111 - "CustomPainter"
Cohesion: 0.50
Nodes (4): CustomPainter, ScannerFramePainter, _MapGridPainter, _SpeedometerGaugePainter

## Knowledge Gaps
- **650 isolated node(s):** `name`, `private`, `version`, `type`, `dev` (+645 more)
  These have ≤1 connection - possible missing edges or undocumented components. (Counts symbols only; 832 node(s) total have ≤1 connection when file, concept and rationale nodes are included.)
- **37 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `User` connect `User` to `org.springframework.http.ResponseEntity`, `PaymentResponse`, `Category`, `lombok.RequiredArgsConstructor`, `ExpenseRepository`, `org.springframework.transaction.annotation.Transactional`, `lombok.AllArgsConstructor`, `org.springframework.security.oauth2.jwt.Jwt`?**
  _High betweenness centrality (0.014) - this node is a cross-community bridge._
- **Why does `PaymentModel` connect `transaction_tile.dart` to `payment_model.dart`, `dashboard_data.dart`, `single_transaction_screen.dart`?**
  _High betweenness centrality (0.007) - this node is a cross-community bridge._
- **Why does `Category` connect `Category` to `User`, `org.springframework.transaction.annotation.Transactional`, `lombok.AllArgsConstructor`, `jakarta.annotation.PostConstruct`, `org.springframework.security.oauth2.jwt.Jwt`?**
  _High betweenness centrality (0.006) - this node is a cross-community bridge._
- **What connects `name`, `private`, `version` to the rest of the system?**
  _650 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `home_spend_trend_line_chart.dart` be split into smaller, more focused modules?**
  _Cohesion score 0.08 - nodes in this community are weakly interconnected._
- **Should `Category` be split into smaller, more focused modules?**
  _Cohesion score 0.06648575305291723 - nodes in this community are weakly interconnected._
- **Should `dashboard_data.dart` be split into smaller, more focused modules?**
  _Cohesion score 0.06451612903225806 - nodes in this community are weakly interconnected._