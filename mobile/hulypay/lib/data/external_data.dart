import 'package:flutter/material.dart';

/// Data models for external content, legal documents, and page informational text.

class FeatureHighlightItem {
  final IconData icon;
  final String title;
  final String subtitle;

  const FeatureHighlightItem({
    required this.icon,
    required this.title,
    required this.subtitle,
  });
}

class TechSpecItem {
  final String label;
  final String value;

  const TechSpecItem({required this.label, required this.value});
}

class ScopeBulletItem {
  final String highlight;
  final String description;

  const ScopeBulletItem({required this.highlight, required this.description});
}

class SecurityProtocolItem {
  final IconData icon;
  final String title;
  final String description;

  const SecurityProtocolItem({
    required this.icon,
    required this.title,
    required this.description,
  });
}

class FaqItem {
  final String question;
  final String answer;

  const FaqItem({required this.question, required this.answer});
}

class AppNotificationItem {
  final String title;
  final String body;
  final String time;
  final IconData icon;
  final Color color;
  final bool isRead;
  final bool isDevAlert;
  final bool isFeatureRelease;
  final bool isSecurity;
  final String? badgeText;

  const AppNotificationItem({
    required this.title,
    required this.body,
    required this.time,
    required this.icon,
    required this.color,
    this.isRead = false,
    this.isDevAlert = false,
    this.isFeatureRelease = false,
    this.isSecurity = false,
    this.badgeText,
  });

  AppNotificationItem copyWith({
    String? title,
    String? body,
    String? time,
    IconData? icon,
    Color? color,
    bool? isRead,
    bool? isDevAlert,
    bool? isFeatureRelease,
    bool? isSecurity,
    String? badgeText,
  }) {
    return AppNotificationItem(
      title: title ?? this.title,
      body: body ?? this.body,
      time: time ?? this.time,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      isRead: isRead ?? this.isRead,
      isDevAlert: isDevAlert ?? this.isDevAlert,
      isFeatureRelease: isFeatureRelease ?? this.isFeatureRelease,
      isSecurity: isSecurity ?? this.isSecurity,
      badgeText: badgeText ?? this.badgeText,
    );
  }

  Map<String, dynamic> toMap() => {
    'title': title,
    'body': body,
    'time': time,
    'icon': icon,
    'color': color,
    'isRead': isRead,
    'isDevAlert': isDevAlert,
    'isFeatureRelease': isFeatureRelease,
    'isSecurity': isSecurity,
    'badgeText': badgeText,
  };
}

/// Central repository of external static and legal information for HulyPay.
/// Provides rich, centralized content for About, Privacy & Security, Help & Support,
/// Terms of Service, and related app screens.
class ExternalData {
  ExternalData._();

  // ---------------------------------------------------------------------------
  // App Branding & General Metadata
  // ---------------------------------------------------------------------------
  static const String appName = 'HulyPay';
  static const String appTagline =
      'Next-Generation Intelligent Fintech Experience';
  static const String defaultAppVersion = 'v2.8.0';
  static const String apkDownloadUrl =
      'https://github.com/Lovedragn/Huly-Pay/releases/download/$defaultAppVersion/hulypay_$defaultAppVersion.apk';
  static const String apkFilename = 'hulypay_$defaultAppVersion.apk';
  static const String appDescription =
      'Next-generation intelligent fintech application crafted for frictionless '
      'transactions, analytical intelligence, and secure offline-first financial '
      'ledger logging.';

  // ---------------------------------------------------------------------------
  // Developer & Creator Information
  // ---------------------------------------------------------------------------
  static const String creatorName = 'Sujith Sappani';
  static const String creatorRole = 'Creator & Lead Software Engineer';
  static const String creatorWebsiteUrl = 'https://sujithsappani.vercel.app';
  static const String creatorWebsiteDisplay = 'sujithsappani.vercel.app';
  static const String creatorBio =
      'HulyPay is designed and developed with precision by Sujith Sappani. '
      'Learn more about the developer and explore other engineering projects below:';

  static const String supportEmail = 'sujith.sappani@gmail.com';
  static const String supportSubject = 'HulyPay Support & Feedback';

  // ---------------------------------------------------------------------------
  // About Page Data
  // ---------------------------------------------------------------------------
  static const String aboutEnvironmentNoticeTitle =
      'Test & Development Release';
  static const String aboutEnvironmentNoticeBody =
      'This version of HulyPay is an active preview and development environment build. '
      'All payment gateways, scanner decoders, heatmaps, and simulated transfers are '
      'intended for testing, demonstration, and architectural prototyping.';

  static const List<FeatureHighlightItem> aboutFeatures = [
    FeatureHighlightItem(
      icon: Icons.qr_code_scanner_rounded,
      title: 'Scan & Pay Scanner',
      subtitle: 'Ultra-fast QR decoding with simulated camera testing and flashlight assistance.',
    ),
    FeatureHighlightItem(
      icon: Icons.insights_rounded,
      title: 'Analyze & Spending Heatmap',
      subtitle: 'Multi-theme visual analytics with category donut charts and temporal activity matrices.',
    ),
    FeatureHighlightItem(
      icon: Icons.sync_rounded,
      title: 'Offline-First Local Sync',
      subtitle: 'Robust offline transaction storage backed by cloud sync engines.',
    ),
    FeatureHighlightItem(
      icon: Icons.security_rounded,
      title: 'Sandboxed Client Security',
      subtitle: 'Local hardware biometric locking and isolated session authorization.',
    ),
  ];

  static const List<TechSpecItem> aboutSpecs = [
    TechSpecItem(label: 'Application', value: 'HulyPay'),
    TechSpecItem(label: 'Category', value: 'Personal Finance & Analytics'),
    TechSpecItem(label: 'Platform', value: 'Android & iOS'),
    TechSpecItem(label: 'Data Protection', value: 'Encrypted Device Storage'),
  ];

  // ---------------------------------------------------------------------------
  // Privacy & Security Data (Data Storage, Retrieval & Databases)
  // ---------------------------------------------------------------------------
  static const String privacySecurityTitle = 'Privacy & Security';
  static const String privacyScreenSubtitle =
      'Transparent disclosure of what information is collected, how it is retrieved, and where it is stored.';

  static const String dataWeStoreTitle = 'What Data We Store';
  static const List<ScopeBulletItem> dataStoredItems = [
    ScopeBulletItem(
      highlight: 'Transaction Records:',
      description: 'Payment amount, merchant name, UPI ID, note, timestamp, transaction reference (UTR), status, and assigned spending category.',
    ),
    ScopeBulletItem(
      highlight: 'User Profile & Preferences:',
      description: 'Display name, email address, avatar initials, default UPI app preference, quick confirm setting, and custom UI themes.',
    ),
    ScopeBulletItem(
      highlight: 'Optional Geo-Location:',
      description: 'Latitude and longitude coordinates only when a transaction is explicitly authorized with location permission enabled.',
    ),
    ScopeBulletItem(
      highlight: 'What We NEVER Store:',
      description: 'We do not store UPI PINs, banking passwords, debit/credit card CVVs, or full bank account numbers.',
    ),
  ];

  static const String databasesUsedTitle = 'Databases & Storage Engines';
  static const List<ScopeBulletItem> databasesUsedItems = [
    ScopeBulletItem(
      highlight: 'Local SQLite Engine (sqflite):',
      description: 'Transactions and metadata are saved locally on your device in an offline-first SQLite database (`hulypay.db`). This allows full ledger functionality even without internet connectivity.',
    ),
    ScopeBulletItem(
      highlight: 'Encrypted Device Preferences (SharedPreferences):',
      description: 'Local user settings, app biometric flags, selected chart themes, and cached quick-confirm toggles are preserved in private app storage sandbox.',
    ),
    ScopeBulletItem(
      highlight: 'Supabase Cloud Database (PostgreSQL):',
      description: 'When signed in, transactions and profile records sync with a secure remote PostgreSQL database on Supabase using encrypted Row Level Security (RLS) policies.',
    ),
  ];

  static const String dataRetrievalTitle =
      'How Data is Retrieved & Synchronized';
  static const List<ScopeBulletItem> dataRetrievalItems = [
    ScopeBulletItem(
      highlight: 'Offline-First Fetching:',
      description: 'The application immediately reads cached ledger entries from local SQLite upon opening for 0ms lag.',
    ),
    ScopeBulletItem(
      highlight: 'Real-Time Remote Sync:',
      description: 'When online and authenticated, background synchronization fetches updated records from Supabase and reconciles pending offline entries.',
    ),
    ScopeBulletItem(
      highlight: 'SMS & Sensor Decoding:',
      description: 'The QR scanner accesses camera frames strictly in transient memory. Bank SMS verification parses incoming transaction SMS locally without uploading personal messages.',
    ),
    ScopeBulletItem(
      highlight: 'Complete Data Eradication:',
      description: 'You can reset or wipe all local SQLite tables and stored preferences at any time by signing out or clearing application data.',
    ),
  ];

  static const String dataTransparencyTitle = 'User Rights & Data Control';
  static const String dataTransparencyBody =
      'You retain full control over your financial data. All transaction records and category tags can be purged or exported directly from your device.';

  // Retained for backward-compatibility if referenced elsewhere
  static const String securityBannerTitle = 'End-to-End Encrypted Guard';
  static const String securityBannerDescription =
      'Client-side security policies and sandboxed credential vaulting are enabled for testing.';
  static const String devPrivacyNoticeTitle =
      'Test & Development Environment Scope';
  static const String devPrivacyNoticeIntro =
      'HulyPay is actively undergoing rapid engineering cycles, feature experiments, and prototype iterations.';
  static const List<ScopeBulletItem> devPrivacyScopeBullets = [];
  static const List<SecurityProtocolItem> securityProtocols = [];

  // ---------------------------------------------------------------------------
  // Full Legal Documents: Terms of Service & Privacy Policy
  // ---------------------------------------------------------------------------
  static const String termsSummary =
      'By accessing or using HulyPay, you agree to comply with our user agreement and transaction terms.';

  static const String termsOfServiceFull = '''
1. Acceptance of Terms
By creating an account, downloading, or using the HulyPay application, you acknowledge and agree to be bound by these Terms of Service. If you do not agree to these terms, please discontinue using the application immediately.

2. Scope of Application & Development Mode
HulyPay is currently delivered as a development preview and testing suite. Simulated transactions, merchant mock payloads, and heatmaps are designed for evaluation, user experience demonstration, and architectural testing. No real banking accounts are debited.

3. Sandbox Integrity & Acceptable Use
You agree not to utilize this software for any fraudulent, unauthorized, or unlawful purposes. You agree not to attempt to reverse engineer backend services or tamper with local ledger tables.

4. Account Security
You are solely responsible for maintaining the confidentiality of your device access passcodes and authentication credentials. HulyPay will not be held liable for any loss resulting from compromised device custody.

5. Disclaimer of Warranties
HulyPay is provided on an "AS IS" and "AS AVAILABLE" basis without warranties of any kind, whether express or implied. The developers disclaim all warranties including fitness for a particular purpose and merchantability.

6. Changes to Terms
We reserve the right to revise or update these Terms of Service at any time. Continued usage of the application after modifications signifies acceptance of the amended terms.
''';

  static const String privacySummary =
      'HulyPay protects your financial data using end-to-end encryption and strict zero-knowledge protocols.';

  static const String privacyPolicyFull =
      '''
1. Information We Collect
In this development build, HulyPay stores user profile handles, simulated transaction histories, and local preferences on your device using encrypted SQLite storage. No actual payment card numbers, CVVs, or bank secrets are ever requested or stored.

2. Camera & Sensor Permissions
The camera permission is requested strictly to decode QR barcodes in real time. Frame buffers are processed instantaneously in volatile memory on your device and are never streamed, stored, or transmitted to any third-party server.

3. Offline-First Ledger
All transaction logs and category aggregations are stored locally first. Cloud synchronizations occur only when explicitly authorized by the signed-in account.

4. Telemetry & Analytics
Anonymous diagnostic telemetry and crash logs may be collected during beta releases to identify performance bottlenecks and eliminate rendering hiccups. No identifiable personal banking information is included.

5. Data Deletion & Privacy Rights
You have the right to reset or purge your local database at any time through the application settings or by signing out. Upon clearing local storage, all cached transactions are permanently eradicated from the device.

6. Contact Regarding Privacy
If you have any questions, concerns, or requests regarding this Privacy Policy, please reach out to:
Email: $supportEmail
Website: $creatorWebsiteUrl
''';

  // ---------------------------------------------------------------------------
  // Help & Support Page Data
  // ---------------------------------------------------------------------------
  static const String supportDirectTitle = 'Direct Support & Queries';
  static const String supportDirectSubtitle =
      'Reach out for bugs, inquiries, or feedback';

  static const String developerWebsiteTitle = 'Official Developer Site';
  static const String developerWebsiteDescription =
      'Visit the developer\'s portfolio to check out changelogs, full-stack case studies, and engineering contact channels.';

  static const List<FaqItem> helpFaqs = [
    FaqItem(
      question: 'Are these live money transactions?',
      answer: 'No. HulyPay operates in demonstration and simulation mode. No genuine bank accounts or real funds are debited.',
    ),
    FaqItem(
      question: 'Why does the QR code scanner fail in some environments?',
      answer: 'The QR scanner utilizes device camera sensors and hardware decoding. In emulator or restricted environments, you can use the test QR trigger to simulate incoming payment payloads.',
    ),
    FaqItem(
      question: 'How can I reset my offline database?',
      answer: 'You can clear your local database session by signing out and logging back in.',
    ),
    FaqItem(
      question: 'Where is my transaction data stored?',
      answer: 'Transaction records are persisted securely on your device and automatically synced with your cloud profile when online.',
    ),
    FaqItem(
      question: 'Can I customize the application theme and chart colors?',
      answer: 'Yes! Visit the Settings screen and tap Customization to choose between multiple dark themes (Onyx, Carbon, Emerald, Violet, Midnight Blue) and dynamic chart color palettes.',
    ),
  ];

  // ---------------------------------------------------------------------------
  // Notification Service & Release Announcements
  // ---------------------------------------------------------------------------
  /// Flag indicating whether the notification system is in development sandbox
  /// or live production mode.
  static const bool isNotificationServiceInDev = true;

  static const String notificationEnvironmentBadgeDev =
      'Preview / Dev Prototype';
  static const String notificationEnvironmentBadgeLive = 'Live Dispatch Active';

  static const String notificationDevNoticeTitle =
      'Notification Service In Development';
  static const String notificationDevNoticeBody =
      'Push notification dispatchers and WebSocket real-time triggers are currently being '
      'integrated with our cloud backends. Sample alerts shown below illustrate upcoming '
      'ledger events, new feature releases, and developer broadcasts.';

  static const String notificationLiveNoticeTitle =
      'Notification Center Active';
  static const String notificationLiveNoticeBody =
      'Real-time push delivery and security activity logging are operational. '
      'Review your recent payment receipts, security audits, and new feature updates below.';

  static const String notificationWipFooter =
      'Cloud push notification channels and real-time ledger webhooks will be activated in the upcoming production sprint.';

  static const List<AppNotificationItem> defaultNotifications = [
    AppNotificationItem(
      title: 'Development Sandbox Active',
      body: 'You are operating in the test and developer preview build. Payment simulations are enabled.',
      time: 'Just now',
      icon: Icons.science_outlined,
      color: Color(0xFFFF9500),
      isRead: false,
      isDevAlert: true,
      badgeText: 'DEV SANDBOX',
    ),
    AppNotificationItem(
      title: 'New Feature: Heatmap Analytics',
      body: 'Visual spending matrices and dynamic multi-theme donut charts are now live in your Insights tab.',
      time: '10m ago',
      icon: Icons.insights_rounded,
      color: Color(0xFFBF5AF2),
      isRead: false,
      isFeatureRelease: true,
      badgeText: 'NEW FEATURE',
    ),
    AppNotificationItem(
      title: 'Feature Update: Quick Scan & Pay',
      body: 'Ultra-fast QR scanning with simulated flash control and rapid merchant resolution is ready for testing.',
      time: '25m ago',
      icon: Icons.qr_code_scanner_rounded,
      color: Color(0xFF5E5CE6),
      isRead: false,
      isFeatureRelease: true,
      badgeText: 'UPDATE',
    ),
    AppNotificationItem(
      title: 'Security Biometric Guard',
      body: 'Hardware enclave authentication protocol verified and enabled for fast payment approval.',
      time: '15m ago',
      icon: Icons.fingerprint_rounded,
      color: Color(0xFF30D158),
      isRead: false,
      isSecurity: true,
      badgeText: 'SECURITY & AUTH',
    ),
    AppNotificationItem(
      title: 'Session Vault Token Verified',
      body: 'Client-side encrypted session credentials synchronized with zero-knowledge protocol.',
      time: '1h ago',
      icon: Icons.shield_outlined,
      color: Color(0xFF0A84FF),
      isRead: false,
      isSecurity: true,
      badgeText: 'AUTH NOTICE',
    ),
    AppNotificationItem(
      title: 'Daily Spending Limit Synced',
      body: 'Your local database budget threshold was updated and cached offline successfully.',
      time: '2h ago',
      icon: Icons.track_changes_rounded,
      color: Color(0xFF0A84FF),
      isRead: true,
      isDevAlert: false,
    ),
    AppNotificationItem(
      title: 'Offline SQLite Cache Ready',
      body: 'Local storage engine initialized with zero uncommitted transactions.',
      time: '3h ago',
      icon: Icons.sync_rounded,
      color: Color(0xFF34C759),
      isRead: true,
      isDevAlert: false,
    ),
  ];

  /// Default categories available for assigning to transactions
  static const List<TransactionCategoryItem> defaultCategories = [
    TransactionCategoryItem(
      name: 'Food & Dining',
      icon: Icons.restaurant_rounded,
      color: Color(0xFFFF9500),
      description: 'Restaurants, cafes, food delivery & groceries',
    ),
    TransactionCategoryItem(
      name: 'Shopping',
      icon: Icons.shopping_bag_rounded,
      color: Color(0xFF007AFF),
      description: 'E-commerce, apparel, electronics & retail',
    ),
    TransactionCategoryItem(
      name: 'Bills & Utilities',
      icon: Icons.receipt_long_rounded,
      color: Color(0xFFAF52DE),
      description: 'Electricity, water, mobile recharge & broadband',
    ),
    TransactionCategoryItem(
      name: 'Transportation',
      icon: Icons.directions_car_rounded,
      color: Color(0xFF30D158),
      description: 'Cabs, fuel, tolls, train & metro tickets',
    ),
    TransactionCategoryItem(
      name: 'Entertainment',
      icon: Icons.movie_outlined,
      color: Color(0xFFFF2D55),
      description: 'Movies, streaming subscriptions & events',
    ),
    TransactionCategoryItem(
      name: 'Groceries',
      icon: Icons.local_grocery_store_rounded,
      color: Color(0xFF34C759),
      description: 'Supermarkets, daily essentials & produce',
    ),
    TransactionCategoryItem(
      name: 'Health & Fitness',
      icon: Icons.favorite_rounded,
      color: Color(0xFF5AC8FA),
      description: 'Pharmacies, clinics, doctors & gym',
    ),
    TransactionCategoryItem(
      name: 'Travel',
      icon: Icons.flight_takeoff_rounded,
      color: Color(0xFFFFCC00),
      description: 'Hotels, flights & vacations',
    ),
    TransactionCategoryItem(
      name: 'Personal Care',
      icon: Icons.spa_rounded,
      color: Color(0xFFFF6482),
      description: 'Salons, grooming & self-care',
    ),
    TransactionCategoryItem(
      name: 'Education',
      icon: Icons.school_rounded,
      color: Color(0xFF5856D6),
      description: 'Courses, books & tuition fees',
    ),
    TransactionCategoryItem(
      name: 'Other',
      icon: Icons.category_rounded,
      color: Color(0xFF8E8E93),
      description: 'General transactions & miscellaneous',
    ),
  ];

  /// App Theme presets available for Customization
  static const List<Map<String, String>> themePresets = [
    {
      'id': 'Oled black',
      'name': 'Oled black',
      'label': 'OLED',
      'description': 'Pure black for AMOLED displays with neon accents (Default)',
    },
    {
      'id': 'Milk white',
      'name': 'Milk white',
      'label': 'Milk',
      'description': 'Clean ivory daytime theme with high clarity and royal accents',
    },
    {
      'id': 'Red velvet',
      'name': 'Red velvet',
      'label': 'Red',
      'description': 'White background, signature red big amount, red bottom nav & red accents',
    },
  ];

  /// Descriptions for unified theme chart color palettes
  static const Map<String, String> chartPaletteDescriptions = {
    'Oled black': 'Electric Blue, vibrant Cyan, Mint, Amber & Rose',
    'Milk white': 'Royal Blue, Ocean Cyan, Fresh Mint, Warm Gold & Rose',
    'Red velvet': 'Bright Yellow, Golden Amber, Radiant Orange & Crimson Red',
    'OnePlus red': 'Bright Yellow, Golden Amber, Radiant Orange & Crimson Red',
  };

  /// Dark theme style json for embedded Google Maps
  static const String darkMapStyle = '''[
  {"elementType": "geometry", "stylers": [{"color": "#181a20"}]},
  {"elementType": "labels.icon", "stylers": [{"visibility": "off"}]},
  {"elementType": "labels.text.fill", "stylers": [{"color": "#8c93a0"}]},
  {"elementType": "labels.text.stroke", "stylers": [{"color": "#141416"}]},
  {"featureType": "administrative", "elementType": "geometry", "stylers": [{"color": "#383c48"}]},
  {"featureType": "administrative.country", "elementType": "labels.text.fill", "stylers": [{"color": "#9ca3af"}]},
  {"featureType": "poi", "elementType": "labels.text.fill", "stylers": [{"color": "#6b7280"}]},
  {"featureType": "poi.park", "elementType": "geometry", "stylers": [{"color": "#16221c"}]},
  {"featureType": "road", "elementType": "geometry.fill", "stylers": [{"color": "#232630"}]},
  {"featureType": "road", "elementType": "labels.text.fill", "stylers": [{"color": "#8a919e"}]},
  {"featureType": "road.arterial", "elementType": "geometry", "stylers": [{"color": "#2c313d"}]},
  {"featureType": "road.highway", "elementType": "geometry.fill", "stylers": [{"color": "#343b49"}]},
  {"featureType": "road.highway", "elementType": "geometry.stroke", "stylers": [{"color": "#222731"}]},
  {"featureType": "water", "elementType": "geometry", "stylers": [{"color": "#101622"}]},
  {"featureType": "water", "elementType": "labels.text.fill", "stylers": [{"color": "#4b5563"}]}
]''';

  /// Scan & Pay Screen static copy and configuration messages
  static const String scanQrTitle = 'Scan & Pay';
  static const String invalidQrMessage = 'This is not a valid UPI payment QR.';
  static const String openingGPayMessage =
      'Opening Google Pay with scanned QR image...';
  static const String gPayShareTitle = 'Pay with Google Pay';
  static const String quickConfirmActiveTitle = 'Quick Confirm is active';
  static const String switchedToFrontCamera = 'Switched to Front Camera';
  static const String switchedToRearCamera = 'Switched to Rear Camera';
  static const String smsPermissionRequiredTitle = 'SMS Permission Required';
  static const String smsPermissionRequiredContent =
      'SMS permission is required to verify this development payment. Payment verification through SMS cannot proceed without it.';
  static const String paymentVerificationTimeoutMsg =
      'Payment verification timed out after 5 minutes.';
  static const String verifyingSmsStatus =
      'Analyzing incoming bank transaction SMS...';
  static const String paymentVerifiedSuccess = 'Payment verified successfully';
  static const String paymentFailedBankSms =
      'Payment failed according to bank SMS';
  static const String quickConfirmSuccessBody =
      'Payment has been marked as successful and recorded in your ledger without SMS verification.';
  static const String smsVerifiedSuccessBody =
      'Payment has been confirmed via bank transaction SMS and recorded in your ledger.';
  static const String listeningForSmsBody =
      'Complete the payment in Google Pay. Huly.Pay is actively listening for your bank transaction SMS.';
  static const String paymentTimeoutBody =
      'Payment verification timed out. If money was debited from your account, it will reflect upon refresh.';
}

class TransactionCategoryItem {
  final String name;
  final IconData icon;
  final Color color;
  final String description;

  const TransactionCategoryItem({
    required this.name,
    required this.icon,
    required this.color,
    required this.description,
  });
}
