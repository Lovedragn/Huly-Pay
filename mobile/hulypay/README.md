# 💳 Huly Pay Mobile Application

> **Huly Pay** is a modern, high-performance Flutter application built for smart UPI payment management, transaction tracking, merchant QR scanning, financial analytics, and offline-first data synchronization.

---

## 🌟 Key Features

- **📷 Smart QR Scanner & Payment Routing**:
  - Live camera QR scanning (`mobile_scanner`) and QR code gallery uploads.
  - Deep-link intent resolution for all major UPI apps (Google Pay, PhonePe, Paytm, BHIM, etc.).
- **📊 Real-time Financial Analytics**:
  - Spending trends, monthly breakdowns, category distribution charts (`fl_chart`).
  - Transaction history filtering, search, and export to PDF (`pdf`, `share_plus`).
- **📍 Geolocation Tagging**:
  - Record payment locations and view transaction locations on Google Maps (`geolocator`, `google_maps_flutter`).
- **🔒 Security & Authentication**:
  - Supabase Auth integration, JWT token verification, and privacy settings.
- **🔄 In-App Version & Update Notification Banner**:
  - Built-in dynamic app update banner notifying users of new releases, mandatory upgrades, and feature highlights (`AppUpdateService`).
- **💾 Offline-First Architecture**:
  - High-performance local SQLite database (`sqflite`) for caching transactions and payment methods.
- **🎨 Sleek Dark Modern Design**:
  - High-contrast, minimal aesthetic with custom typography, splash animations, and tailored UI components.

---

## 📁 Project Architecture & Directory Layout

```
lib/
├── Data/                  # Static seed data, constants, external resources
│   └── external_data.dart
├── Model/                 # Dart data models
│   ├── dashboard_data.dart
│   ├── transaction_model.dart
│   └── user_profile.dart
├── Repository/            # Data access layer abstracting remote and local sources
│   ├── transaction_repository.dart
│   └── user_repository.dart
├── Screen/                # Application UI pages/views
│   ├── Analyze/
│   │   └── analysis_screen.dart           # Spending analytics & visual charts
│   ├── Home/
│   │   ├── home_dashboard_screen.dart     # Main dashboard, quick actions, balance summary
│   │   ├── Notification/
│   │   │   └── notifications_screen.dart  # In-app alerts and notifications
│   │   ├── Payment/
│   │   │   ├── scan_amount_screen.dart    # Amount entry & UPI app selection
│   │   │   ├── scan_and_pay_screen.dart   # Live camera QR scanner & UPI payment flow
│   │   │   └── upload_qr_screen.dart      # QR image picker & parser
│   │   └── Settings/
│   │       ├── about_hulypay_screen.dart  # Version info, changelog, credits
│   │       ├── help_support_screen.dart   # Support FAQs & ticket submission
│   │       ├── payment_methods_screen.dart# Bank accounts & UPI IDs management
│   │       ├── privacy_security_screen.dart# Security preferences & privacy controls
│   │       └── settings_screen.dart       # User profile & general preferences
│   ├── Security/
│   │   └── sign_in_screen.dart            # User authentication (Supabase)
│   ├── Transaction/
│   │   ├── single_transaction_screen.dart # Detailed receipt, map view, share receipt
│   │   └── transactions_screen.dart       # List of transactions with filters
│   └── splash_screen.dart                 # Splash loading & auto version/update check
├── Service/               # Core business services & integrations
│   ├── api_client.dart                    # Dio HTTP client for backend REST API
│   ├── app_update_service.dart            # Remote app version checking & update banners
│   ├── auth_service.dart                  # Supabase authentication service
│   ├── google_pay_service.dart            # Google Pay direct integration
│   ├── local_database_service.dart        # SQLite DB initialization & CRUD operations
│   ├── location_service.dart              # GPS location retrieval for transactions
│   ├── qr_service.dart                    # QR code decoding and image analysis
│   ├── qr_share_service.dart              # QR generation and sharing
│   ├── scan_payment_service.dart          # Payment workflow orchestration
│   ├── sms_filter_service.dart            # Automatic SMS transaction reading
│   ├── token_validator.dart               # JWT token validation
│   ├── transaction_pdf_service.dart       # PDF invoice/receipt generation
│   ├── upi_payment_service.dart           # UPI intent generation & launcher
│   ├── upi_service.dart                   # UPI string parser & validation
│   └── user_preferences_service.dart     # Local settings & user preferences
├── Theme/                 # App design system, color palettes (Oled black, Milk white, Red velvet)
│   └── app_theme.dart
├── Widget/                # Reusable modular UI widgets
│   ├── Bottom_Sheet/                      # Modal bottom sheets
│   │   ├── bottom_sheet.dart              # Theme & style customization modal
│   │   ├── category_picker_sheet.dart     # Transaction category picker
│   │   └── edit_amount_sheet.dart         # Amount modification sheet
│   ├── Chart/                             # Visualization charts
│   │   ├── category_pie_chart.dart        # Donut/pie category breakdown
│   │   ├── spend_trend_line_chart.dart    # Spending trend line chart
│   │   ├── spending_heatmap.dart          # Daily spending heatmap
│   │   ├── today_spend_gauge.dart         # Circular spending target gauge
│   │   └── weekly_bar_chart.dart          # Weekly spending bar chart
│   ├── Components/                        # Generic reusable UI primitives
│   │   ├── Navbar/
│   │   │   ├── bottom_navbar.dart         # Floating curved bottom navigation bar
│   │   │   └── navbar_switch_button.dart  # Navbar mode toggle
│   │   └── round_button.dart              # Rounded icon action buttons
│   ├── Transaction/                       # Transaction cards & receipt widgets
│   │   ├── payment_details_page.dart      # Payment details review screen
│   │   ├── payment_dialogs.dart           # Payment confirmation and warning dialogs
│   │   ├── transaction_detail_components.dart
│   │   ├── transaction_details_card.dart  # Transaction metadata card
│   │   ├── transaction_map_section.dart   # Interactive Google Maps section
│   │   ├── transaction_receipt_card.dart  # Downloadable/shareable receipt card
│   │   └── transaction_tile.dart          # List item transaction row
│   ├── dialog.dart                        # Card-like modal dialog & toast notifications
│   ├── sms_verification_dialog.dart       # Live SMS confirmation dialog
│   └── update_banner.dart                 # Dynamic release update banner
└── main.dart              # Application entrypoint & initialization
```

---

## 📦 Core Dependencies & Tech Stack

| Category | Package | Purpose |
|---|---|---|
| **Framework** | Flutter (Dart SDK `^3.13.3`) | Cross-platform UI toolkit |
| **Networking** | `dio: ^5.7.0` | Robust HTTP client for Spring Boot backend |
| **Authentication** | `supabase_flutter: ^2.8.3` | User auth and session management |
| **Local Database** | `sqflite: ^2.4.2` | Local SQLite database for offline storage |
| **QR Code Engine** | `mobile_scanner: ^6.0.4` | High-speed camera barcode/QR scanner |
| **Maps & Location** | `geolocator: ^13.0.2`, `google_maps_flutter: ^2.10.0` | Transaction location logging |
| **Charts & Visuals** | `fl_chart: ^1.2.0`, `flutter_svg: ^2.3.0` | Interactive spending reports & SVG icons |
| **Export & Sharing**| `pdf: ^3.13.1`, `share_plus: ^13.3.0` | Transaction statement export & sharing |
| **App Management** | `package_info_plus: ^10.2.2`, `flutter_native_splash` | Package metadata & native splash screen |

---

## ⚙️ Configuration & Environment

The app expects a `.env` file at the root of `mobile/hulypay/`:

```env
SUPABASE_URL=https://your-supabase-id.supabase.co
SUPABASE_ANON_KEY=eyJhbGciOi...
BACKEND_BASE_URL=https://api.yourdomain.com/api/v1
GOOGLE_MAPS_API_KEY=AIzaSy...
```

Make sure the `.env` asset is declared under `flutter.assets` in `pubspec.yaml` (already configured).

---

## 🚀 Running & Building

### Run locally on an Android device or emulator:
```bash
flutter pub get
flutter run
```

### Build optimized release APK:
```bash
flutter build apk --release
```

### Output:
```
build/app/outputs/flutter-apk/app-release.apk
```

---

## 🧪 Testing & Linting

```bash
# Run static analysis
flutter analyze

# Run unit tests
flutter test
```
