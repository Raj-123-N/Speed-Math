# Speed Math

**Speed Math** is a beautiful, highly optimized Flutter application designed to help users practice and master mental mathematics through targeted exercises, quick recalls, and comprehensive revision modules.

## Features

- **Practice Modules**: Practice basic arithmetic, advanced operations (squares, cubes, roots), and miscellaneous equations.
- **Revision Engine**: Review math concepts seamlessly in an optimized interface.
- **Customizable Experience**: Supports Light and Dark mode, toggleable sounds, push notifications, and haptic vibration feedback.
- **Beautiful UI**: Modern aesthetics featuring dynamic colors, smooth curves, and micro-animations to keep the user engaged.
- **Highly Optimized**: Assets are highly compressed (WebP) and the app footprint is remarkably small, delivering a lightning-fast experience without unnecessary bloat.

## Tech Stack

- **Framework**: Flutter (Dart)
- **State Management**: Provider
- **Local Storage**: SharedPreferences
- **Navigation**: GoRouter
- **Design**: Material 3 / Custom UI System

## Project Setup

1. **Install Dependencies**:
   ```bash
   flutter pub get
   ```
2. **Run the App**:
   ```bash
   flutter run
   ```
3. **Build APK**:
   ```bash
   flutter build apk --release --split-per-abi
   ```

## Architecture & Codebase

This project has been heavily refactored to remove unused features, deprecated dependencies, and dead code, resulting in a lean and highly performant architecture. It now starts as a completely fresh v0.1.0 codebase focused strictly on **Learn/Revision**, **Practice UI**, and **Settings**.

## Versioning

Current Version: **v0.1.0**
