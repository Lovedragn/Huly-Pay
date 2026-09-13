# Graph Report - Huly.pay  (2026-09-13)

## Corpus Check
- cluster-only mode — file stats not available

## Summary
- 856 nodes · 1566 edges · 90 communities (43 shown, 34 thin omitted)
- Extraction: 95% EXTRACTED · 5% INFERRED · 0% AMBIGUOUS · INFERRED: 84 edges (avg confidence: 0.82)
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `7740ee66`
- Run `git rev-parse HEAD` and compare to check if the graph is stale.
- Run `graphify update .` after code changes (no API cost).

## Community Hubs (Navigation)
- User
- Expense
- Category
- dashboard_data.dart
- package.json
- AppDelegate
- lombok.AllArgsConstructor
- my_application.cc
- home_dashboard_screen.dart
- settings_screen.dart
- transactions_screen.dart
- splash_screen.dart
- GlobalExceptionHandler
- analysis_screen.dart
- package:flutter/material.dart
- scan_and_pay_screen.dart
- win32_window.cpp
- FlutterWindow
- SecurityConfig.java
- string
- single_transaction_screen.dart
- widget_test.dart
- Win32Window
- DatabaseHealthController
- main.dart
- manifest.json
- HulyPay Backend Implementation Specification
- mvnw
- MessageHandler
- BackendApplication
- Spring Boot API
- action_button.dart
- custom_bottom_nav_bar.dart
- StatelessWidget
- transaction_tile.dart
- api_service.dart
- MaterialPageRoute
- Point
- Size
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

## God Nodes (most connected - your core abstractions)
1. `User` - 47 edges
2. `Win32Window` - 24 edges
3. `Category` - 22 edges
4. `Expense` - 18 edges
5. `ExpenseResponse` - 17 edges
6. `UserService` - 17 edges
7. `Payment` - 17 edges
8. `CategoryResponse` - 16 edges
9. `ErrorResponse` - 16 edges
10. `ResourceNotFoundException` - 15 edges

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

## Communities (90 total, 34 thin omitted)

### Community 0 - "User"
Cohesion: 0.06
Nodes (51): AnalyticsController, CategoryController, DeleteMapping, GetMapping, PostMapping, PutMapping, RequestMapping, RestController (+43 more)

### Community 1 - "Expense"
Cohesion: 0.06
Nodes (30): AnalyticsService, Expense, AllArgsConstructor, Builder, Entity, Getter, NoArgsConstructor, Setter (+22 more)

### Community 2 - "Category"
Cohesion: 0.11
Nodes (20): Category, AllArgsConstructor, Builder, Entity, Getter, NoArgsConstructor, Setter, Table (+12 more)

### Community 3 - "dashboard_data.dart"
Cohesion: 0.05
Nodes (43): bool get, Color, home_dashboard_screen.dart, amount, avatarUrl, category, CategorySpendingItem, changePercent (+35 more)

### Community 4 - "package.json"
Cohesion: 0.05
Nodes (40): dependencies, react, react-dom, devDependencies, @babel/core, babel-plugin-react-compiler, eslint, @eslint/js (+32 more)

### Community 5 - "AppDelegate"
Cohesion: 0.06
Nodes (26): Any, Cocoa, Flutter, FlutterAppDelegate, FlutterImplicitEngineBridge, FlutterImplicitEngineDelegate, FlutterMacOS, FlutterPluginRegistry (+18 more)

### Community 6 - "lombok.AllArgsConstructor"
Cohesion: 0.25
Nodes (17): CategoryBreakdownResponse, DailySpendingResponse, MonthlySpendingResponse, SpendingSummaryResponse, CategoryRequest, ErrorResponse, CreateExpenseRequest, UpdateExpenseRequest (+9 more)

### Community 7 - "my_application.cc"
Cohesion: 0.09
Nodes (22): FlPluginRegistry, FlView, GApplication, gboolean, gchar, GObject, GtkApplication, fl_register_plugins() (+14 more)

### Community 8 - "home_dashboard_screen.dart"
Cohesion: 0.09
Nodes (22): analysis_screen.dart, DashboardData, build, _buildBody, _buildDashboardContent, _buildHeader, _buildQuickActions, _buildRecentTransactionsSection (+14 more)

### Community 9 - "settings_screen.dart"
Cohesion: 0.10
Nodes (21): appVersion, build, _buildAccountSection, _buildGroupCard, _buildLogoutCard, _buildPreferencesSection, _buildProfileCard, _buildSettingRow (+13 more)

### Community 10 - "transactions_screen.dart"
Cohesion: 0.10
Nodes (21): _allGroups, build, _buildFilterChips, _buildGroupedTransactions, _buildHeader, _buildSearchBar, createState, dispose (+13 more)

### Community 11 - "splash_screen.dart"
Cohesion: 0.10
Nodes (20): Animation, AnimationController, dart:async, Duration, build, _controller, createState, dispose (+12 more)

### Community 12 - "GlobalExceptionHandler"
Cohesion: 0.17
Nodes (10): GlobalExceptionHandler, NoResourceFoundException, org.springframework.dao.DataIntegrityViolationException, org.springframework.security.access.AccessDeniedException, org.springframework.security.core.AuthenticationException, org.springframework.web.bind.annotation.ExceptionHandler, org.springframework.web.bind.annotation.RestControllerAdvice, org.springframework.web.bind.MethodArgumentNotValidException (+2 more)

### Community 13 - "analysis_screen.dart"
Cohesion: 0.10
Nodes (20): ../data/mock_data.dart, AnalysisScreen, _AnalysisScreenState, build, _buildCategoryList, _buildHeader, _categories, createState (+12 more)

### Community 14 - "package:flutter/material.dart"
Cohesion: 0.11
Nodes (18): List, analysisCategoryItems, dashboardData, MockData, transactionScreenGroups, build, centerLabel, items (+10 more)

### Community 15 - "scan_and_pay_screen.dart"
Cohesion: 0.12
Nodes (17): CustomPainter, build, cornerColor, cornerLength, cornerRadius, createState, _handleBack, _isFlashOn (+9 more)

### Community 16 - "win32_window.cpp"
Cohesion: 0.18
Nodes (14): wchar_t, Scale(), Create, Destroy, SetQuitOnClose, Show, UpdateTheme, Win32Window::Win32Window() (+6 more)

### Community 17 - "FlutterWindow"
Cohesion: 0.13
Nodes (15): DartProject, HWND, LPARAM, LRESULT, UINT, WPARAM, FlutterWindow, flutter_controller_ (+7 more)

### Community 18 - "SecurityConfig.java"
Cohesion: 0.25
Nodes (10): OpenApiConfig, SecurityConfig, io.swagger.v3.oas.models.OpenAPI, OpenAPI, org.springframework.context.annotation.Bean, org.springframework.context.annotation.Configuration, org.springframework.security.config.annotation.web.builders.HttpSecurity, org.springframework.security.config.annotation.web.configuration.EnableWebSecurity (+2 more)

### Community 19 - "string"
Cohesion: 0.22
Nodes (9): _In_, _In_opt_, wWinMain(), wchar_t, CreateAndAttachConsole(), GetCommandLineArguments(), Utf8FromUtf16(), string (+1 more)

### Community 20 - "single_transaction_screen.dart"
Cohesion: 0.14
Nodes (13): build, _buildActionButton, _buildDetailRow, _buildDetailsCard, _buildHeroReceiptCard, _buildQuickActionButtons, _buildSectionHeader, _buildShopBanner (+5 more)

### Community 21 - "widget_test.dart"
Cohesion: 0.14
Nodes (13): main, package:flutter_test/flutter_test.dart, package:mobile/main.dart, package:mobile/screens/analysis_screen.dart, package:mobile/screens/home_dashboard_screen.dart, package:mobile/screens/scan_and_pay_screen.dart, package:mobile/screens/settings_screen.dart, package:mobile/screens/sign_in_screen.dart (+5 more)

### Community 22 - "Win32Window"
Cohesion: 0.19
Nodes (12): RegisterPlugins(), OnCreate, HWND, Win32Window, child_content_, GetClientArea, OnCreate, quit_on_close_ (+4 more)

### Community 23 - "DatabaseHealthController"
Cohesion: 0.26
Nodes (6): DatabaseHealthController, DatabaseHealthResponse, HealthController, HealthResponse, javax.sql.DataSource, org.springframework.web.bind.annotation.RestController

### Community 24 - "main.dart"
Cohesion: 0.18
Nodes (10): appFontFallback, appFontFamily, build, home, main, showSplash, package:flutter/services.dart, screens/home_dashboard_screen.dart (+2 more)

### Community 25 - "manifest.json"
Cohesion: 0.18
Nodes (10): background_color, description, display, icons, name, orientation, prefer_related_applications, short_name (+2 more)

### Community 26 - "HulyPay Backend Implementation Specification"
Cohesion: 0.20
Nodes (10): Docker Compose Configuration, HulyPay Backend Implementation Specification, Application Configuration, Expense Module, Payment Module, User Module, Home Dashboard UI, Scan and Pay UI (+2 more)

### Community 27 - "mvnw"
Cohesion: 0.38
Nodes (8): mvnw script, clean(), die(), exec_maven(), hash_string(), set_java_home(), trim(), verbose()

### Community 28 - "MessageHandler"
Cohesion: 0.36
Nodes (10): HWND, LPARAM, LRESULT, UINT, WPARAM, EnableFullDpiSupportIfAvailable(), GetHandle, GetThisFromHandle (+2 more)

### Community 29 - "BackendApplication"
Cohesion: 0.31
Nodes (3): BackendApplication, jakarta.annotation.PostConstruct, org.springframework.boot.autoconfigure.SpringBootApplication

### Community 30 - "Spring Boot API"
Cohesion: 0.25
Nodes (8): Flutter Mobile Application, Flutter Web Dashboard, Hero Diagram, Frontend Entry HTML, Google Maps Platform, Spring Boot API, Supabase PostgreSQL, UPI Intent Flow

### Community 31 - "action_button.dart"
Cohesion: 0.25
Nodes (7): IconData, build, icon, label, onTap, svgAsset, package:flutter_svg/flutter_svg.dart

### Community 32 - "custom_bottom_nav_bar.dart"
Cohesion: 0.25
Nodes (7): build, _buildNavItem, isQrActive, onItemSelected, onQrScanTap, selectedIndex, ValueChanged

### Community 33 - "StatelessWidget"
Cohesion: 0.29
Nodes (7): HulyPayApp, SingleTransactionScreen, QuickActionButton, CustomBottomNavBar, DonutChart, SpendingChart, StatelessWidget

### Community 34 - "transaction_tile.dart"
Cohesion: 0.29
Nodes (6): TransactionItem, onTap, transaction, TransactionTile, ../screens/single_transaction_screen.dart, VoidCallback?

### Community 35 - "api_service.dart"
Cohesion: 0.33
Nodes (5): ApiService, baseUrl, getCurrentUser, package:http/http.dart, static const String

### Community 36 - "MaterialPageRoute"
Cohesion: 0.40
Nodes (5): MaterialPageRoute, _openScanAndPay, _openScanAndPay, _openScanAndPay, build

### Community 37 - "Point"
Cohesion: 0.50
Nodes (3): Point, x, y

### Community 38 - "Size"
Cohesion: 0.50
Nodes (3): Size, height, width

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

## Knowledge Gaps
- **278 isolated node(s):** `CANCELLED`, `FAILED`, `INITIATED`, `PENDING`, `SUCCESS` (+273 more)
  These have ≤1 connection - possible missing edges or undocumented components. (Counts symbols only; 416 node(s) total have ≤1 connection when file, concept and rationale nodes are included.)
- **34 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `Win32Window` connect `Win32Window` to `Point`, `Size`, `win32_window.cpp`, `FlutterWindow`, `string`, `MessageHandler`?**
  _High betweenness centrality (0.051) - this node is a cross-community bridge._
- **Why does `FlutterWindow` connect `FlutterWindow` to `string`, `AppDelegate`, `Win32Window`?**
  _High betweenness centrality (0.043) - this node is a cross-community bridge._
- **Why does `User` connect `User` to `Expense`, `Category`, `lombok.AllArgsConstructor`?**
  _High betweenness centrality (0.034) - this node is a cross-community bridge._
- **What connects `CANCELLED`, `FAILED`, `INITIATED` to the rest of the system?**
  _278 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `User` be split into smaller, more focused modules?**
  _Cohesion score 0.06173558532323821 - nodes in this community are weakly interconnected._
- **Should `Expense` be split into smaller, more focused modules?**
  _Cohesion score 0.05656108597285068 - nodes in this community are weakly interconnected._
- **Should `Category` be split into smaller, more focused modules?**
  _Cohesion score 0.1072463768115942 - nodes in this community are weakly interconnected._