# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

AppAboutView is a SwiftUI package that provides a reusable "About" view component for macOS and iOS apps. It displays app information, handles user interactions (feedback, ratings, coffee tips), and showcases other apps by the developer.

## Common Commands

### Building and Testing

- Build: `swift build`
- Test: `swift test`
- Clean: `swift package clean`

### Package Management

- Resolve dependencies: `swift package resolve`
- Generate Xcode project: `swift package generate-xcodeproj`

## Architecture

### Core Components

1. **AppAboutView** (`Sources/AppAboutView.swift`)
   - Main SwiftUI view component with platform-specific styling
   - Handles coffee tip purchases via StoreKit
   - Provides convenience initializer `fromMainBundle()` for automatic bundle info extraction
   - Platform-specific UI adaptations using `#if os()` compiler directives

2. **AppShowcaseView** (`Sources/AppShowcaseView.swift`)
   - Displays a list of developer's other apps
   - Handles App Store navigation (in-app on iOS, external on macOS)
   - Uses local bundle icons with fallback to system icons

3. **AppShowcaseService** (`Sources/AppShowcaseService.swift`)
   - `@MainActor` service class managing app data loading
   - Loads from local bundle, cached data, and remote URLs
   - Filters out current app from showcase list
   - Implements caching with 1-hour refresh interval (disabled in DEBUG)

4. **MyAppInfo** (`Sources/MyAppInfo.swift`)
   - Data models for app information and platform definitions
   - Supports localized descriptions with fallback logic
   - Platform enum with system image mappings

### Key Patterns

- **Multi-platform support**: Extensive use of `#if os()` compiler directives for platform-specific code
- **Localization**: Bundle-based localization with `.module` bundle references
- **Resource management**: Icons loaded from bundle with fallback handling
- **Service architecture**: Separate service layer for data management with `@StateObject` binding
- **Caching**: UserDefaults-based caching with time-based refresh logic

### Localization Structure

- Supports 10 languages: English (base), German, Spanish, French, Italian, Japanese, Korean, Russian, Simplified Chinese, Traditional Chinese
- Localized strings use bundle-specific lookup: `String(localized: "key", bundle: .module)`
- App data supports runtime locale-based string selection

### Testing

- Uses Swift Testing framework (not XCTest)
- Tests focus on component initialization and data integrity
- Run tests with `swift test`

## Resource Files

- `Sources/Resources/apps.json`: JSON data containing showcase app information
- `Sources/Resources/Assets.xcassets/`: App icons for showcase apps
- Language-specific `.lproj/` folders: Localized strings
- Please ignore files in .windsurf folder since they're made for Windsurf

## MCP Servers

Always use context7 when I need code generation, setup or configuration steps, or library/API documentation. This means you should automatically use the Context7 MCP tools to resolve library id and get library docs without me having to explicitly ask.

Skip the `resolve-library-id` for Swift, and all Apple frameworks since we know the _library ID_ is `/websites/developer_apple`.
