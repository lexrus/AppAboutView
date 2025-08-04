---
trigger: always_on
---

# Testing Guidelines

## Testing Framework
- Uses Swift Testing framework (NOT XCTest)
- Test files located in `Tests/` directory
- Main test file: `Tests/AppAboutViewTests.swift`

## Testing Focus Areas
- Component initialization and data integrity
- Service layer functionality (AppShowcaseService)
- Localization support
- Platform-specific behavior
- Data model validation (MyAppInfo)

## Testing Commands
- Run tests: `swift test`
- Always run tests after making changes
- Ensure tests pass before committing code

## Testing Best Practices
- Test both success and failure scenarios
- Mock external dependencies when necessary
- Test platform-specific code paths
- Validate localization behavior
- Test caching mechanisms