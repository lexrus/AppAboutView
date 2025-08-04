---
trigger: always_on
---

# Localization Rules

## Supported Languages
- English (base)
- German (de)
- Spanish (es)
- French (fr)
- Italian (it)
- Japanese (ja)
- Korean (ko)
- Russian (ru)
- Simplified Chinese (zh-Hans)
- Traditional Chinese (zh-Hant)

## Localization Structure
- Language-specific `.lproj/` folders in `Sources/Resources/`
- Each folder contains `Localizable.strings` file
- Localized strings use bundle-specific lookup: `String(localized: "key", bundle: .module)`
- App data supports runtime locale-based string selection

## Implementation Guidelines
- Always use `String(localized: "key", bundle: .module)` for localized strings
- Maintain consistency across all language files
- Test localization with different system languages
- Ensure fallback logic works properly for missing translations