---
trigger: manual
---

# Coding Standards and Best Practices

## SwiftUI Guidelines
- Use SwiftUI-first approach for all UI components
- Implement platform-specific adaptations using `#if os()` compiler directives
- Use `@StateObject` for service binding
- Implement `@MainActor` for UI-related services

## Platform Support
- Support both macOS and iOS
- Use conditional compilation for platform-specific code
- Test behavior on both platforms
- Handle platform-specific navigation patterns

## Service Architecture
- Separate service layer for data management
- Use `@MainActor` for services that update UI
- Implement proper caching mechanisms
- Handle network requests asynchronously

## Code Quality
- Use meaningful variable and function names
- Implement proper error handling
- Add documentation for public APIs

## Resource Management
- Use bundle-based resource loading
- Implement fallback mechanisms for missing resources
- Handle localization properly with `.module` bundle references