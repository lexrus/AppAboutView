---
trigger: always_on
---

# Resource Management Rules

## Resource Files Location
All resources are located in `Sources/Resources/`

## Key Resource Files

### App Data
- `apps.json`: JSON data containing showcase app information
- Contains app metadata, descriptions, and platform information

### Assets
- `Assets.xcassets/`: App icons for showcase apps
- Individual `.imageset/` folders for each app icon
- Icons include: liveextractor, regexplus, sharptooth, swiftymenu

### Localization Files
- Language-specific `.lproj/` folders
- Each contains `Localizable.strings` file
- 7 supported languages total

## Resource Guidelines
- Icons should be properly sized and optimized
- JSON data must be valid and properly structured
- Localization files must be consistent across languages
- Resource loading should include fallback mechanisms
- Bundle references use `.module` for proper package context