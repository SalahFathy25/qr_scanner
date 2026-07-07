<div align="center">
  <img src="assets/lottie/qr_scanner.json" alt="QR Studio" width="120" />
  <h1 align="center">
    QR Studio
    <br />
    <sub align="center">توليد، مسح، وإدارة أكواد QR بأناقة</sub>
  </h1>
  <p align="center">
    <strong>QR Studio</strong> — A modern, feature-packed Flutter application for generating,
    scanning, customizing, and managing QR codes. Designed for Android,
    built with ❤️ by <a href="https://github.com/salah">Salah</a>.
    <br />
    <br />
    <a href="#features"><strong>Explore Features »</strong></a>
    ·
    <a href="#-project-structure">Project Structure</a>
    ·
    <a href="#-architecture">Architecture</a>
    ·
    <a href="#-git-branches">Git Branches</a>
    ·
    <a href="#-what-we-built">What We Built</a>
    ·
    <a href="#-screenshots">Screenshots</a>
    ·
    <a href="#-getting-started">Getting Started</a>
    ·
    <a href="#-contributing">Contributing</a>
  </p>
</div>

<br />

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-3.7+-02569B?logo=flutter&logoColor=white" alt="Flutter" />
  <img src="https://img.shields.io/badge/Dart-3.7+-0175C2?logo=dart&logoColor=white" alt="Dart" />
  <img src="https://img.shields.io/badge/Android_only-3DDC84?logo=android&logoColor=white" alt="Android" />
  <img src="https://img.shields.io/badge/license-MIT-green" alt="License" />
  <img src="https://img.shields.io/badge/state_management-Cubit_/_BLoC-29B6F6" alt="BLoC" />
  <img src="https://img.shields.io/badge/tests-10__passing-success" alt="Tests" />
  <img src="https://img.shields.io/badge/analysis-0__errors-0ea5e9" alt="Analysis" />
</p>

---

## 📋 Project Overview

> QR Studio was built from the ground up by refactoring a simple QR code app into a full-featured,
> store-ready open-source project. Every screen, cubit, model, and test was redesigned or rewritten.
>
> **Original app**: 4 platform-specific cubits (WhatsApp, Facebook, Instagram, LinkedIn),
> 4 separate category screens, basic QR generation, no customization.
>
> **QR Studio**: 1 generic cubit, 11 QR types, gradients + logo support, gallery QR decoding,
> export/import, favorites, search, scan history, onboarding, Material 3 redesign,
> CI/CD, 10 tests, and professional git history — all in one cohesive Android app.

---

## ✨ Features

### 📱 QR Code Generation — 11 Types

| Category | Format | Description |
|----------|--------|-------------|
| **WhatsApp** | `wa.me` link | Phone with country code prefix |
| **Facebook** | URL / text | Profile or page link |
| **Instagram** | URL / text | Profile or post link |
| **LinkedIn** | URL / text | Profile or company link |
| **WiFi** | `WIFI:` config | SSID + Password + Encryption (WPA/WEP/None) |
| **Email** | `mailto:` link | To + Subject + Body |
| **vCard** | `BEGIN:VCARD` | Name, Phone, Email, Organization |
| **URL** | Plain link | Any web address |
| **Text** | Plain text | Any text content |
| **Calendar** | `BEGIN:VEVENT` | Title + Date + Time + Location |
| **Location** | `geo:` URI | Latitude + Longitude |
| **SMS** | `sms:` / `SMSTO:` | Phone number + Message body |
| **Custom** | User-defined | Custom categories with icon + color |

### 🎨 QR Customization

- **16 solid colors** — pick from a curated palette
- High-resolution rendering via `qr_flutter`
- Preview before saving

### 📸 QR Scanning

- **Real-time camera scan** — auto-detect URLs, open in browser
- **Gallery QR decoding** — pick an image from your photo library; uses `zxing2` to decode
- **Category auto-detection** — WiFi, vCard, Email, Calendar, Location, SMS, URL, Text
- **Scan history** — last 50 scans, persisted locally
- **Clipboard copy** — one-tap copy scanned data
- **Permission handling** — camera denied / permanently denied UI with settings redirect
- **Gallery fallback** — when camera permission is denied, offer "Pick from Gallery"

### ❤️ Favorites & Search

- **Favorite QR codes** — star your most-used QR codes
- **Favorites carousel** — horizontal scroll on the home screen
- **Full-text search** — search across all QR code titles
- **Sort options** — by newest, oldest, name (A-Z), category
- **Category filter** — filter search results by category

### 💾 Export & Import

- **Export** — all QR codes → indented JSON file → system share sheet
- **Import** — pick a `.json` backup file → preview → confirm to add all
- **App signature** — backup files validated with `app: "QR Studio"` header

### 🧭 Onboarding

- **3-page intro** shown on first launch
- Explains key features: generate, scan, customize
- Stored in `SharedPreferences` — only shown once
- Smooth Lottie animations + page indicator

### 🎛️ Settings Screen

| Section | Options |
|---------|---------|
| **Appearance** | Theme (System/Light/Dark), Default QR Color |
| **Scanning** | Auto-open Scanner, Vibrate on Scan |
| **Data** | Clear All QR Codes, Clear Scan History, Reset Onboarding |
| **Backup** | Export All, Import |
| **About** | App name, Version |
| **Links** | Rate, Share, Send Feedback, Privacy Policy, Open Source Licenses |

### 🌙 Material 3 Design

- **Purple theme** — primary `#6C63FF`, secondary `#00BFA6`
- **Google Fonts** — Poppins throughout
- **Responsive grid** — 4 cols (<600px) / 5 cols (<900px) / 6 cols (900px+)
- **Dark mode** — automatic system theme switching
- **Rounded cards** — 20px border radius, elevation shadows
- **Swipe-to-delete** — dismiss QR cards from the grid

### 🔐 Permissions

- `CAMERA` — for QR scanning
- Runtime permission request with `permission_handler`
- **Denied UI** — "Grant Permission" button with app settings redirect
- **Gallery fallback** — pick from gallery when camera is unavailable

---

## 🧩 What We Built

A complete transformation from a basic QR app to **QR Studio**.

### Core Infrastructure

| Component | What Changed |
|-----------|-------------|
| **App name** | `qr_code` → **QR Studio** |
| **Package name** | `com.example.qr_code` → `com.salah.qrstudio` |
| **Dart package** | `qr_code` → `qr_studio` |
| **Android manifest** | Added `CAMERA` + `INTERNET` permissions, `android:label="QR Studio"` |
| **App icon** | Flutter Launcher Icons — all Android densities |
| **Native splash** | Flutter Native Splash — light + dark mode |
| **Font** | Poppins via Google Fonts |

### Architecture

| Component | What Changed |
|-----------|-------------|
| **State management** | 4 platform-specific cubits → 1 **generic `QrCubit`** |
| **Models** | `QrCodeModel` extended with `id`, `isFavorite`, `colorValue`, `gradientStart`, `gradientEnd`, `hasLogo`, `createdAt` |
| **Categories** | Hardcoded → `CategoryModel` with `IconData`, color, image path |
| **Storage** | Separate keys per category → single `all_qr_codes` key with v1 auto-migration |

### Screens (9 total)

| Screen | Description |
|--------|-------------|
| **home.dart** | SliverAppBar, favorites carousel, social row, utility grid, responsive layout |
| **category_screen.dart** | Generic — handles any category via model |
| **all_qr_screen.dart** | Search + sort + category filter + export |
| **scan_qr_code.dart** | Camera scan + gallery decode + permission handling + history |
| **settings_screen.dart** | Theme control, data management, about, links |
| **onboarding_screen.dart** | 3-page intro with Lottie |
| **qr_view.dart** | QR display with gradient/logo, Share/Save/Open |
| **qr_bottom_sheet.dart** | All 11 type form fields + gradient + logo toggle |

### Data Layer (Cubits)

| Cubit | Responsibility |
|-------|---------------|
| **QrCubit** | CRUD, favorites, search, filter by category, sort, v1 migration |
| **ThemeCubit** | System/Light/Dark theme with SharedPreferences persistence |
| **ScanHistoryCubit** | Last 50 scans, capped storage, clear history |
| **CustomCategoryCubit** | User-defined categories CRUD |
| **ExportImportCubit** | Export JSON via share sheet, import via file_picker |

---

## 🏗 Architecture

### File Structure

```
lib/
├── app/
│   ├── data/                      # State management (Cubits)
│   │   ├── qr_cubit.dart
│   │   ├── qr_state.dart
│   │   ├── scan_history_cubit.dart
│   │   ├── custom_category_cubit.dart
│   │   └── export_import_cubit.dart
│   ├── models/
│   │   ├── qr_code_model.dart
│   │   └── category_model.dart
│   ├── screens/                   # 9 screens
│   │   ├── home.dart
│   │   ├── settings_screen.dart
│   │   ├── category_screen.dart
│   │   ├── all_qr_screen.dart
│   │   ├── scan_qr_code.dart
│   │   ├── onboarding_screen.dart
│   │   ├── qr_view.dart
│   │   └── custom_category_screen.dart
│   └── widgets/
│       ├── qr_card.dart
│       ├── qr_view.dart
│       ├── qr_bottom_sheet.dart
│       ├── gradient_qr.dart
│       └── no_qr.dart
├── core/
│   ├── constants/
│   │   └── app_constants.dart
│   └── utils/
│       ├── permission_handler.dart
│       └── theme/
│           ├── theme.dart
│           ├── theme_cubit.dart
│           └── custom_themes/
├── main.dart
```

### Data Flow

```
User Action → Screen Widget → Cubit.addQrCode() → QrCubit
    → Update in-memory list → SharedPreferences.save() → Emit QrSuccess
    → UI rebuilds via BlocBuilder
```

### State Management

- **Cubit + `bloc` library** — lightweight, no events boilerplate
- **Sealed state classes** — `QrInitial`, `QrLoading`, `QrSuccess`, `QrError`
- **`BlocProvider`** at root — single QrCubit instance shared across screens
- **`BlocBuilder` / `context.watch`** — reactive UI updates

### Dependencies

| Package | Version | Purpose |
|---------|---------|---------|
| `qr_flutter` | 4.1.0 | QR code widget rendering |
| `qr_code_scanner_plus` | 2.1.2 | Camera-based QR scanning |
| `bloc` / `flutter_bloc` | 9.x | State management (Cubit) |
| `shared_preferences` | 2.5.2 | Local data persistence |
| `url_launcher` | 6.3.1 | Open detected URLs |
| `lottie` | 3.3.1 | Onboarding animations |
| `share_plus` | 10.1.4 | Share/Save QR images |
| `path_provider` | 2.1.5 | Temporary file for export |
| `permission_handler` | 11.3.1 | Runtime camera permission |
| `image_picker` | 1.1.2 | Pick QR from gallery |
| `google_fonts` | 6.2.1 | Poppins font |
| `flutter_native_splash` | 2.4.4 | Native splash screen |
| `file_picker` | 8.3.7 | Pick JSON import files |
| `image` | 4.6.0 | Decode gallery images for QR |
| `zxing2` | 0.2.4 | Decode QR from static images |
| `package_info_plus` | 9.0.1 | App version info |
| `flutter_launcher_icons` | 0.14.3 | App icon generation (dev) |
| `bloc_test` | 10.0.0 | Cubit testing (dev) |
| `mocktail` | 1.0.4 | Mocking in tests (dev) |

---

## 🌿 Git Branches

```
main (production-ready)
 └── develop (integration branch)
      ├── feature/studio-overhaul  ← all features
      ├── refactor/architecture     ← generic cubit
      ├── feature/category-expansion ← more QR types
      ├── redesign/ui               ← Material 3
      └── docs/readme               ← documentation
      └── original                  ← original app reference
```

### Commit History (Conventional Commits)

```
feat:       complete QR Studio overhaul
feat:       add Settings screen with theme control
feat:       gallery QR decoding + JSON import
redesign:   modern Material 3 UI overhaul
refactor:   implement generic QrCubit architecture
docs:       comprehensive project README
chore:      generate launcher icons and native splash
```

---

## 🧪 Tests

**10 tests — all passing.**

| Suite | Type | Count | What It Tests |
|-------|------|-------|---------------|
| `qr_cubit_test.dart` | Bloc tests | 7 | Init, add, delete, toggle favorite, search, filter, update |
| `qr_card_test.dart` | Widget tests | 3 | Display title/data, toggle favorite, favorited state |

```bash
flutter test
```

### CI/CD (GitHub Actions)

The workflow at `.github/workflows/flutter_ci.yml` runs on every push:

1. **`flutter analyze`** — lint + static analysis (0 errors, 0 warnings)
2. **`flutter test`** — run all 10 tests
3. **`flutter build apk --release`** — build release APK artifact

---

## 🚀 Getting Started

### Prerequisites

- Flutter SDK `^3.7.0`
- Dart SDK `^3.7.0`
- Android SDK

### Installation

```bash
git clone https://github.com/salah/qr_code.git
cd qr_code
flutter pub get
flutter run
```

### Generate App Icons

```bash
# Replace assets/icons/app_icon.png with your design first
dart run flutter_launcher_icons
```

### Generate Splash Screens

```bash
dart run flutter_native_splash:create
```

### Build Release APK

```bash
flutter build apk --release
```

---

## 📸 Screenshots

<p align="center">
  <img src="assets/screenshots/home_screen.jpg" width="200" alt="Home Screen" />
  <img src="assets/screenshots/scan_qr_screen.jpg" width="200" alt="Scan QR" />
  <img src="assets/screenshots/facebook_screen.jpg" width="200" alt="Category" />
  <img src="assets/screenshots/facebook_qr_display.jpg" width="200" alt="QR Display" />
</p>

---

## 🤝 Contributing

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/amazing-feature`)
3. Commit your Changes (`git commit -m 'feat: add amazing feature'`)
4. Push to the Branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### Commit Convention

This project follows [Conventional Commits](https://www.conventionalcommits.org/):

| Prefix | Usage |
|--------|-------|
| `feat:` | A new feature |
| `fix:` | A bug fix |
| `refactor:` | Code restructuring |
| `redesign:` | UI/UX changes |
| `docs:` | Documentation only |
| `chore:` | Maintenance tasks |

---

## 📄 License

Distributed under the MIT License. See `LICENSE` for more information.

---

## 🙏 Acknowledgements

- **Salah** — Creator and maintainer
- [qr_flutter](https://pub.dev/packages/qr_flutter) — QR code rendering
- [qr_code_scanner_plus](https://pub.dev/packages/qr_code_scanner_plus) — Camera scanning
- [zxing2](https://pub.dev/packages/zxing2) — Static QR code decoding
- [Flutter BLoC](https://bloclibrary.dev/) — State management
- [Google Fonts](https://fonts.google.com/specimen/Poppins) — Poppins typeface

---

<p align="center">
  Built with ❤️ by <a href="https://github.com/salah">Salah</a>
  <br />
  <sub>Made in Egypt 🇪🇬</sub>
</p>
