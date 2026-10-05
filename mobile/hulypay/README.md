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
├── data/                  # Static seed data, constants, and initial configs
├── models/                # Dart data models (Transaction, User, PaymentMethod, VersionCheck)
├── repositories/          # Data access layer abstracting remote and local sources
├── screens/               # Application UI pages/views
│   ├── splash_screen.dart             # Splash loading & auto version/update check
│   ├── sign_in_screen.dart            # User authentication (Supabase)
│   ├── home_dashboard_screen.dart     # Main dashboard, quick actions, balance summary
│   ├── scan_and_pay_screen.dart       # Live camera QR scanner & UPI payment flow
│   ├── scan_amount_screen.dart        # Amount entry & UPI app selection
│   ├── upload_qr_screen.dart          # QR image picker & parser
│   ├── transactions_screen.dart       # List of transactions with filters
│   ├── single_transaction_screen.dart # Detailed receipt, map view, share receipt
│   ├── analysis_screen.dart           # Spending analytics & visual charts
│   ├── payment_methods_screen.dart    # Bank accounts & UPI IDs management
│   ├── notifications_screen.dart      # In-app alerts and notifications
│   ├── privacy_security_screen.dart   # Security preferences & privacy controls
│   ├── settings_screen.dart           # User profile & general preferences
│   ├── help_support_screen.dart       # Support FAQs & ticket submission
│   └── about_hulypay_screen.dart      # Version info, changelog, credits
├── services/              # Core business services & integrations
│   ├── api_client.dart                # Dio HTTP client for backend REST API
│   ├── app_update_service.dart        # Remote app version checking & update banners
│   ├── auth_service.dart              # Supabase authentication service
│   ├── local_database_service.dart    # SQLite DB initialization & CRUD operations
│   ├── location_service.dart          # GPS location retrieval for transactions
│   ├── upi_payment_service.dart       # UPI intent generation & launcher
│   ├── upi_service.dart               # UPI string parser & validation
│   ├── transaction_pdf_service.dart   # PDF invoice/receipt generation
│   ├── qr_share_service.dart          # QR generation and sharing
│   └── user_preferences_service.dart # Local settings & user preferences
├── theme/                 # App design system, color palettes, and typography
├── widgets/               # Reusable modular UI widgets (buttons, cards, banners, dialogs)
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
