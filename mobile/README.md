# 📱 Huly Pay — Mobile Client Setup & Development Guide

Welcome to the **Huly Pay Mobile** repository. This directory houses the Flutter-based cross-platform mobile application for **Huly Pay (Smart UPI Payment Manager)**.

---

## 📋 Table of Contents
1. [Prerequisites](#-prerequisites)
2. [Quickstart: Local Manual Setup](#-quickstart-local-manual-setup)
3. [Environment Configuration](#-environment-configuration)
4. [Dockerized Development / CI Build](#-dockerized-development--ci-build)
5. [Useful Commands](#-useful-commands)
6. [Troubleshooting](#-troubleshooting)

---

## 🛠️ Prerequisites

Before building or running the mobile application, make sure you have:

- **Flutter SDK**: `>= 3.13.3` ([Installation Guide](https://docs.flutter.dev/get-started/install))
- **Dart SDK**: Included with Flutter
- **Java Development Kit (JDK)**: JDK 17 or 21 (recommended for Android Gradle builds)
- **Android Studio / Android SDK**: Command-line tools, Android SDK Platform 34+, and platform-tools
- **Docker** *(Optional)*: If you prefer compiling/building via a containerized environment

Verify your setup:
```bash
flutter doctor
```

---

## ⚡ Quickstart: Local Manual Setup

### 1. Navigate to the App Directory
```bash
cd mobile/hulypay
```

### 2. Configure Environment Variables
Create a `.env` file in `mobile/hulypay/`:
```bash
cp .env.example .env
```
*(Or create a new `.env` file manually with your backend API URL and Supabase credentials).*

### 3. Fetch Dependencies
```bash
flutter pub get
```

### 4. Run the Application
Make sure you have an Android device or emulator running:
```bash
# List connected devices
flutter devices

# Run in debug mode
flutter run
```

### 5. Build Release APK
```bash
flutter build apk --release
```
The compiled APK will be output to:
```
mobile/hulypay/build/app/outputs/flutter-apk/app-release.apk
```

---

## 🐳 Dockerized Development / CI Build

If you wish to build the Android APK without setting up local Flutter and Android SDKs, you can use Docker.

### 1. Dockerfile for Flutter Android
Create a `Dockerfile` inside `mobile/` or run directly with a pre-configured Flutter Docker image:

```dockerfile
# mobile/Dockerfile
FROM ghcr.io/cirruslabs/flutter:3.24.0

WORKDIR /app

# Copy dependency configs first for caching
COPY hulypay/pubspec.yaml hulypay/pubspec.lock ./hulypay/
WORKDIR /app/hulypay
RUN flutter pub get

# Copy project files
COPY hulypay /app/hulypay

# Build the release APK
RUN flutter build apk --release
```

### 2. Build via Docker
From the `mobile/` directory:
```bash
docker build -t hulypay-mobile .
```

### 3. Extract the APK from the Container
```bash
docker create --name temp-hulypay-container hulypay-mobile
docker cp temp-hulypay-container:/app/hulypay/build/app/outputs/flutter-apk/app-release.apk ./app-release.apk
docker rm temp-hulypay-container
```

---

## ⚙️ Environment Configuration (`.env`)

The app uses `flutter_dotenv` to load environment variables at runtime. Example keys:

```env
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-supabase-anon-key
BACKEND_BASE_URL=http://10.0.2.2:8080/api/v1 # Android emulator localhost
GOOGLE_MAPS_API_KEY=your_google_maps_key
```

> **Note for Android Emulators:** `localhost` on your host PC is accessible via `10.0.2.2` inside the Android emulator.

---

## 🔧 Useful Commands

| Task | Command |
|---|---|
| Run code analysis | `flutter analyze` |
| Run unit & widget tests | `flutter test` |
| Clean build cache | `flutter clean && flutter pub get` |
| Re-generate launcher icons | `dart run flutter_launcher_icons` |
| Build release App Bundle (AAB) | `flutter build appbundle --release` |
| Build release APK | `flutter build apk --release` |

---

## 📖 In-Depth App Documentation

For architecture details, screens, state management, database schema, and project layout, see:
👉 [**hulypay/README.md**](./hulypay/README.md)
