# Graph Report - Huly.pay  (2026-09-13)

## Corpus Check
- 149 files · ~189,420 words
- Verdict: corpus is large enough that graph structure adds value.

## Summary
- 1461 nodes · 2353 edges · 110 communities (59 shown, 37 thin omitted)
- Extraction: 96% EXTRACTED · 4% INFERRED · 0% AMBIGUOUS · INFERRED: 90 edges (avg confidence: 0.82)
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `92d0bcbf`
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
- analysis_category_pie_chart.dart
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
- spending_heatmap.dart
- Spring Boot API
- chart_colors.dart
- Huly Pay — Final UI + Real Connection Verification.md
- main.dart
- org.springframework.transaction.annotation.Transactional
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
- lombok.AllArgsConstructor
- org.springframework.http.ResponseEntity
- rules/graphify.md
- workflows/graphify.md
- String?
- BackendApplication
- PaymentResponse
- lombok.RequiredArgsConstructor
- home_weekly_bar_chart.dart
- custom_bottom_nav_bar.dart
- PaymentRepository
- User
- StatelessWidget
- ../models/payment_model.dart
- home_today_spend_gauge.dart
- payment_repository.dart
- MaterialPageRoute
- api_service.dart
- mock_data.dart

## God Nodes (most connected - your core abstractions)
1. `User` - 48 edges
2. `Category` - 24 edges
3. `Win32Window` - 24 edges
4. `Expense` - 20 edges
5. `Payment` - 18 edges
6. `PaymentResponse` - 18 edges
7. `ExpenseResponse` - 17 edges
8. `PaymentService` - 17 edges
9. `UserService` - 17 edges
10. `CategoryResponse` - 16 edges

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

## Communities (110 total, 37 thin omitted)

### Community 0 - "home_spend_trend_line_chart.dart"
Cohesion: 0.08
Nodes (26): amount, _bottomTitleWidgets, build, _buildAvgData, _buildCardFooter, _buildCardHeader, _buildCurvedGradientData, _buildDualZoneData (+18 more)

### Community 1 - "DatabaseHealthController"
Cohesion: 0.26
Nodes (6): DatabaseHealthController, DatabaseHealthResponse, HealthController, HealthResponse, javax.sql.DataSource, org.springframework.web.bind.annotation.RestController

### Community 2 - "Category"
Cohesion: 0.10
Nodes (21): Category, AllArgsConstructor, Builder, Entity, Getter, NoArgsConstructor, Setter, Table (+13 more)

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
Nodes (34): Database?, cleanupStalePayments, clearAll, clearPayments, clearUserProfile, close, _db, dbName (+26 more)

### Community 7 - "my_application.cc"
Cohesion: 0.09
Nodes (22): FlPluginRegistry, FlView, GApplication, gboolean, gchar, GObject, GtkApplication, fl_register_plugins() (+14 more)

### Community 8 - "home_dashboard_screen.dart"
Cohesion: 0.07
Nodes (26): _applyData, build, _buildAvatarFallback, _buildBody, _buildDashboardContent, _buildHeader, _buildQuickActions, _buildTotalSpentCard (+18 more)

### Community 9 - "settings_screen.dart"
Cohesion: 0.08
Nodes (24): appVersion, _avatarUrl, build, _buildAccountSection, _buildGroupCard, _buildLogoutCard, _buildPreferencesSection, _buildProfileCard (+16 more)

### Community 10 - "transactions_screen.dart"
Cohesion: 0.08
Nodes (23): analysis_screen.dart, ../data/mock_data.dart, _allGroups, build, _buildFilterChips, _buildGroupedTransactions, _buildHeader, _buildSearchBar (+15 more)

### Community 11 - "payment_model.dart"
Cohesion: 0.04
Nodes (44): dashboard_data.dart, double?, amount, copyWith, createdAt, CreatePaymentPayload, currency, expenseId (+36 more)

### Community 12 - "ErrorResponse"
Cohesion: 0.19
Nodes (12): ErrorResponse, GlobalExceptionHandler, com.fasterxml.jackson.annotation.JsonInclude, NoResourceFoundException, org.springframework.dao.DataIntegrityViolationException, org.springframework.security.access.AccessDeniedException, org.springframework.security.core.AuthenticationException, org.springframework.web.bind.annotation.ExceptionHandler (+4 more)

### Community 13 - "analysis_screen.dart"
Cohesion: 0.08
Nodes (25): _allPayments, AnalysisScreen, _AnalysisScreenState, build, _buildCategoryList, _buildHeader, _categories, createState (+17 more)

### Community 14 - "analysis_category_pie_chart.dart"
Cohesion: 0.10
Nodes (21): List, AnalysisCategoryPieChart, _AnalysisCategoryPieChartState, build, centerLabel, createState, items, _showingSections (+13 more)

### Community 15 - "scan_and_pay_screen.dart"
Cohesion: 0.07
Nodes (29): DateTime?, build, cornerColor, cornerLength, cornerRadius, createState, dispose, _handleBack (+21 more)

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
Cohesion: 0.06
Nodes (44): LocalDatabaseService, main, main, main, samplePayments, dbService, main, main (+36 more)

### Community 22 - "auth_service.dart"
Cohesion: 0.08
Nodes (25): _allowDevMock, AuthService, currentSession, currentUser, _devToken, _devUser, enableMockForTesting, initialize (+17 more)

### Community 23 - "expense_model.dart"
Cohesion: 0.06
Nodes (29): category_model.dart, CategoryModel, color, fromJson, icon, id, isDefault, name (+21 more)

### Community 24 - "api_client.dart"
Cohesion: 0.06
Nodes (31): auth_service.dart, Dio, Exception, int?, ApiException, createCategory, createExpense, createPayment (+23 more)

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
Nodes (21): _authSubscription, build, createState, dispose, _finishSignIn, _handleBack, _handleGitHubSignIn, _handleGoogleSignIn (+13 more)

### Community 29 - "spending_heatmap.dart"
Cohesion: 0.11
Nodes (18): HeatmapItem?, build, _buildFooter, _buildHeader, _buildHeatmapData, _computePeriodTotal, createState, HeatmapPeriod (+10 more)

### Community 30 - "Spring Boot API"
Cohesion: 0.25
Nodes (8): Flutter Mobile Application, Flutter Web Dashboard, Hero Diagram, Frontend Entry HTML, Google Maps Platform, Spring Boot API, Supabase PostgreSQL, UPI Intent Flow

### Community 31 - "chart_colors.dart"
Cohesion: 0.08
Nodes (24): amber, AppChartColors, barDefault, barToday, barTouched, barTrack, blue, cyan (+16 more)

### Community 32 - "Huly Pay — Final UI + Real Connection Verification.md"
Cohesion: 0.04
Nodes (45): 10. Map / Street View Toggle, 11. QR Scanner Workflow, 12. Payment Workflow, 13. Payment Method, 14. Backend Architecture, 15. Android Emulator + Local Backend, 16. Database, 17. Profile & Settings (+37 more)

### Community 33 - "main.dart"
Cohesion: 0.12
Nodes (16): appFontFallback, appFontFamily, build, home, initialize, main, showSplash, supabaseAnonKey (+8 more)

### Community 34 - "org.springframework.transaction.annotation.Transactional"
Cohesion: 0.18
Nodes (10): CategoryService, CategoryResponse, BadRequestException, ResourceNotFoundException, ExpenseResponse, ExpenseService, jakarta.annotation.PostConstruct, org.springframework.stereotype.Service (+2 more)

### Community 35 - "user_profile.dart"
Cohesion: 0.14
Nodes (13): active, authProvider, avatarUrl, copyWith, email, firstName, fromJson, fullName (+5 more)

### Community 36 - "State"
Cohesion: 0.14
Nodes (20): HomeDashboardScreen, _HomeDashboardScreenState, ScanAndPayScreen, _ScanAndPayScreenState, SettingsScreen, _SettingsScreenState, SignInScreen, _SignInScreenState (+12 more)

### Community 37 - "splash_screen.dart"
Cohesion: 0.09
Nodes (21): Animation, AnimationController, dart:async, Duration, home_dashboard_screen.dart, build, _checkLocalStorage, _controller (+13 more)

### Community 38 - "location_service.dart"
Cohesion: 0.09
Nodes (22): bool get, accuracyMeters, errorMessage, failure, failureReason, getCurrentPaymentLocation, getPaymentLocationWithStatus, _instance (+14 more)

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

### Community 90 - "lombok.AllArgsConstructor"
Cohesion: 0.15
Nodes (26): CategoryBreakdownResponse, DailySpendingResponse, MonthlySpendingResponse, SpendingSummaryResponse, CategoryRequest, CreateExpenseRequest, UpdateExpenseRequest, CreatePaymentRequest (+18 more)

### Community 91 - "org.springframework.http.ResponseEntity"
Cohesion: 0.10
Nodes (21): DeleteMapping, GetMapping, PostMapping, PutMapping, ExpenseController, DeleteMapping, GetMapping, PostMapping (+13 more)

### Community 95 - "BackendApplication"
Cohesion: 0.43
Nodes (3): BackendApplication, org.springframework.boot.autoconfigure.SpringBootApplication, org.springframework.scheduling.annotation.EnableScheduling

### Community 96 - "PaymentResponse"
Cohesion: 0.12
Nodes (13): PaymentResponse, AllArgsConstructor, Builder, Entity, Getter, NoArgsConstructor, Setter, Table (+5 more)

### Community 97 - "lombok.RequiredArgsConstructor"
Cohesion: 0.24
Nodes (12): AnalyticsController, CategoryController, RequestMapping, RestController, RequestMapping, RestController, PaymentController, UserService (+4 more)

### Community 98 - "home_weekly_bar_chart.dart"
Cohesion: 0.12
Nodes (15): build, _buildBarChartData, _buildLegendItem, _calculateMax, _computeWeeklyData, createState, _defaultBarColor, _getBottomTitles (+7 more)

### Community 99 - "custom_bottom_nav_bar.dart"
Cohesion: 0.12
Nodes (15): IconData?, build, icon, label, onTap, svgAsset, build, _buildNavItem (+7 more)

### Community 100 - "PaymentRepository"
Cohesion: 0.29
Nodes (6): PaymentRepository, UserRepository, org.springframework.data.jpa.repository.JpaRepository, org.springframework.data.jpa.repository.Modifying, org.springframework.data.jpa.repository.Query, org.springframework.stereotype.Repository

### Community 101 - "User"
Cohesion: 0.09
Nodes (19): AnalyticsService, Expense, AllArgsConstructor, Builder, Entity, Getter, NoArgsConstructor, Setter (+11 more)

### Community 102 - "StatelessWidget"
Cohesion: 0.25
Nodes (8): HulyPayApp, QuickActionButton, CustomBottomNavBar, DonutChart, HomeTodaySpendGaugeChart, SpendingChart, TransactionTile, StatelessWidget

### Community 103 - "../models/payment_model.dart"
Cohesion: 0.25
Nodes (7): TransactionItem, PaymentModel, onTap, payment, transaction, ../models/payment_model.dart, ../screens/single_transaction_screen.dart

### Community 104 - "home_today_spend_gauge.dart"
Cohesion: 0.12
Nodes (16): Color, CustomPainter, dart:math, ScannerFramePainter, _MapGridPainter, activeColor, build, _buildZoneIndicator (+8 more)

### Community 105 - "payment_repository.dart"
Cohesion: 0.09
Nodes (24): dart:io, _apiClient, cleanupStalePayments, createPayment, getCachedPayments, getPaymentById, getPayments, _instance (+16 more)

### Community 106 - "MaterialPageRoute"
Cohesion: 0.40
Nodes (5): MaterialPageRoute, _openScanAndPay, _openScanAndPay, _openScanAndPay, build

### Community 107 - "api_service.dart"
Cohesion: 0.18
Nodes (10): api_client.dart, ApiService, baseUrl, client, fetchUserProfile, getCurrentUser, ../models/user_profile.dart, package:http/http.dart (+2 more)

### Community 108 - "mock_data.dart"
Cohesion: 0.25
Nodes (7): analysisCategoryItems, dashboardData, MockData, transactionScreenGroups, static const DashboardData, static const List, ../theme/chart_colors.dart

## Knowledge Gaps
- **710 isolated node(s):** `name`, `private`, `version`, `type`, `dev` (+705 more)
  These have ≤1 connection - possible missing edges or undocumented components. (Counts symbols only; 902 node(s) total have ≤1 connection when file, concept and rationale nodes are included.)
- **37 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `User` connect `User` to `PaymentResponse`, `lombok.RequiredArgsConstructor`, `Category`, `org.springframework.transaction.annotation.Transactional`, `PaymentRepository`, `lombok.AllArgsConstructor`, `org.springframework.http.ResponseEntity`?**
  _High betweenness centrality (0.010) - this node is a cross-community bridge._
- **Why does `PaymentModel` connect `../models/payment_model.dart` to `payment_model.dart`, `dashboard_data.dart`, `single_transaction_screen.dart`?**
  _High betweenness centrality (0.006) - this node is a cross-community bridge._
- **What connects `name`, `private`, `version` to the rest of the system?**
  _710 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `home_spend_trend_line_chart.dart` be split into smaller, more focused modules?**
  _Cohesion score 0.07692307692307693 - nodes in this community are weakly interconnected._
- **Should `Category` be split into smaller, more focused modules?**
  _Cohesion score 0.09948979591836735 - nodes in this community are weakly interconnected._
- **Should `dashboard_data.dart` be split into smaller, more focused modules?**
  _Cohesion score 0.06451612903225806 - nodes in this community are weakly interconnected._
- **Should `package.json` be split into smaller, more focused modules?**
  _Cohesion score 0.051515151515151514 - nodes in this community are weakly interconnected._