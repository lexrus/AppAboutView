---
trigger: manual
---

# Build and Development Commands

## Building and Testing
- Build: `swift build`
- Test: `swift test` (uses Swift Testing framework, not XCTest)
- Clean: `swift package clean`

## Package Management
- Resolve dependencies: `swift package resolve`
- Generate Xcode project: `swift package generate-xcodeproj`

## Verification Steps
ALWAYS run linting and testing commands after making changes:
1. `swift test` - to ensure tests pass
2. `swiftlint` - to ensure code style compliance
3. `swift build` - to ensure project builds successfully