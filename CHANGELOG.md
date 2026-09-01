# Changelog

All notable changes to the **Speed Math** project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [0.1.3] - 2026-08-28

### 🚀 Summary
Integrated Firebase support across Web & Android, added Google Sign-In authentication with Guest mode separation, implemented an in-app auto & manual update checking system linked to GitHub Releases, optimized production APK build size with ABI splitting, and purged legacy reference artifacts.

### ✨ Added & Improved
- **Firebase & Google Authentication**:
  - Configured Firebase Core & Auth for Web and Android.
  - Implemented cross-platform Google Sign-In with real-time session tracking (`AuthService` and `AppAuthProvider`).
  - Seamless Guest mode: all learning modules and solo speed drills remain accessible without login.
  - Protected real-time 1v1 arena matchmaking and cloud stats with dynamic `LoginPromptDialog`.
  - Dynamic user profile and login/logout state in `AppDrawer` and `ProfileScreen`.
- **In-App Update System**:
  - GitHub Releases API integration checking for new APK versions.
  - `UpdateDialog` modal with release notes, direct APK download, and skip version preferences.
  - `_UpToDateDialog` verifying installed app status.
  - Manual update check button in the navigation drawer and settings screen.
  - Throttled background startup check on `HomeScreen`.
- **Build Optimization & Artifact Cleanup**:
  - Reduced release APK size from ~60.7 MB to ~22.5 MB (63% reduction) via split-per-ABI compilation and Dart symbol stripping.
  - Enhanced GitHub Actions CI/CD release workflow to produce both split ABI APKs and universal artifacts.
  - Completely purged reference folder `lib/self/` and legacy binary artifacts.
- **Android Configuration**:
  - Registered `google-services.json` and applied `com.google.gms.google-services` plugin.
  - Synced `applicationId` and namespace to `com.rajan.speedmath`.

---

## [0.1.2] - 2026-08-27

### 🚀 Summary
Enhancements to the revision experience with structured interactive math grids and cheat-sheets, quiz drill flow improvements, Android release signing configuration, and responsive layout polish.

### ✨ Added & Improved
- **Enhanced Revision Module**:
  - Grid-based layout for multiplication, squares, cubes, factorials, and prime numbers with chunked section headers and range filter chips.
  - Interactive fraction families grouped systematically by denominator.
  - Cheat-sheet percentage quick lookup and detailed zoom view for complex cards.
- **Drill & Quiz Experience**:
  - Deliberate finish workflow for long drills and persistent completion states.
  - Keypad auto-submit option and UI layout optimizations.
- **Android Build & Tooling**:
  - Release signing configuration via `key.properties`.
  - Updated build ignore rules for gradle artifacts in `.gitignore`.
- **Quality & Stability**:
  - Fixed horizontal challenge card overflow on smaller screen dimensions.
  - Updated widget test suite with mocked providers and resolved timer teardowns.
  - Cleaned up unused imports and analyzer lints across services and UI.

---

## [0.1.1] - 2026-08-27

### 🚀 Summary
Initial stable alpha release establishing the complete core architecture for mental arithmetic training, timed challenges, revision system, performance tracking, and live multiplayer battles.

### ✨ Added
- **Core Quiz Engine & Formats**:
  - Interactive arithmetic generation for addition, subtraction, multiplication, division, fractions, square roots, cube roots, trigonometry, algebra, and geometry.
  - Multi-tiered complexity levels (Basic, Intermediate, Advanced, Mix Advanced).
  - Custom Keypad and Multiple Choice Question (MCQ) interactive modes.
- **Revision & Error Practice Engine**:
  - Spaced revision workflow allowing review of missed and flagged questions.
  - Detailed answer explanations with step-by-step breakdown.
- **Performance & Analytics**:
  - Speed, accuracy, and streak tracking using `fl_chart`.
  - Historical test breakdowns and performance dashboards.
- **Interactive Battle Mode**:
  - Live 1v1 match layout and player matchmaking mock/sync mechanism.
  - Winner animations and competitive scoring system.
- **Audio & Visual Enhancements**:
  - Sound effects for countdowns, correct/wrong answers, bonuses, victory, and defeat (`just_audio`).
  - Smooth Lottie animations for loaders, rank celebrations, and live indicators.
  - Custom SVG asset rendering and Roboto typography styling.
- **State Management & Navigation**:
  - Declarative routing using `go_router`.
  - Reactive application state powered by `provider`.
  - Local persistence via `shared_preferences`.

### 🔧 Configuration & Tooling
- Bumped version code to `0.1.1+1`.
- Configured launcher icon generation via `flutter_launcher_icons`.
- Setup automated code linting with `flutter_lints` rules.

---

## [0.1.0] - 2026-08-20

### 🚀 Summary
- Initial repository setup and proof-of-concept prototype for basic arithmetic drills.
- Project skeleton with Flutter 3.x and Dart SDK compatibility.
