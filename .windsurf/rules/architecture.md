---
trigger: always_on
---

# Architecture Guidelines

## Core Components

### 1. AppAboutView (Sources/AppAboutView.swift)
- Main SwiftUI view component with platform-specific styling
- Handles coffee tip purchases via StoreKit
- Provides convenience initializer `fromMainBundle()` for automatic bundle info extraction
- Platform-specific UI adaptations using `#if os()` compiler directives

### 2. AppShowcaseView (Sources/AppShowcaseView.swift)
- Displays a list of developer's other apps
- Handles App Store navigation (in-app on iOS, external on macOS)
- Uses local bundle icons with fallback to system icons

### 3. AppShowcaseService (Sources/AppShowcaseService.swift)
- `@MainActor` service class managing app data loading
- Loads from local bundle, cached data, and remote URLs
- Filters out current app from showcase list
- Implements caching with 1-hour refresh interval (disabled in DEBUG)

### 4. MyAppInfo (Sources/MyAppInfo.swift)
- Data models for app information and platform definitions
- Supports localized descriptions with fallback logic
- Platform enum with system image mappings

## Key Patterns
- **Multi-platform support**: Extensive use of `#if os()` compiler directives for platform-specific code
- **Localization**: Bundle-based localization with `.module` bundle references
- **Resource management**: Icons loaded from bundle with fallback handling
- **Service architecture**: Separate service layer for data management with `@StateObject` binding
- **Caching**: UserDefaults-based caching with time-based refresh logic