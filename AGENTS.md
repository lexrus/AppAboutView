# Repository Guidelines

## Project Structure & Module Organization

- `Sources/` — Swift library code. Resources live in `Sources/Resources/` (Assets, `*.lproj/Localizable.strings`, `apps.json`).
- `Tests/AppAboutViewTests/` — unit and service tests (swift-testing).
- `Tests/AppAboutViewUITests/` — macOS-only screenshot tests; outputs PNGs to `screenshots/` at repo root.
- Platforms: iOS 17+, macOS 14+ (see `Package.swift`). Keep platform code behind `#if` guards.

## Build, Test, and Development Commands

- `swift package resolve` — resolve dependencies.
- `swift build` — build the package.
- `swift test` — run all tests locally.
- `swift test --filter AppAboutViewTests` — run non-UI tests (CI default).
- `swift test --filter AppAboutViewUITests` — run screenshot tests on macOS; images land in `./screenshots/`.
- `swiftlint` — lint using `.swiftlint.yml` (optional but recommended).

## Coding Style & Naming Conventions

- Swift 6, 4-space indent; soft line length 120 (150 hard). Trailing commas enabled.
- Follow `.swiftlint.yml` (e.g., avoid force unwraps, align collections, enforce operator spacing).
- Localization: prefer `String(localized:bundle: .module)` over hardcoded `Text("...")`.
- Naming: `PascalCase` types, `camelCase` members; files match primary type (e.g., `AppShowcaseService.swift`). Tests end with `...Tests.swift`.

## Testing Guidelines

- Framework: [swift-testing] with `@Test` functions. Group tests by feature and keep deterministic (no network calls).
- Snapshot/screenshot tests run only on macOS and are filtered in CI. If UI changes, update baseline screenshots and include samples in PR.
- Run `swift test` before pushing; add tests for new behavior and edge cases (localization, JSON parsing, platform branches).

## Commit & Pull Request Guidelines

- Use Conventional Commits: `feat:`, `fix:`, `refactor:`, `docs:`, `chore:` (see git history).
- PRs must include: concise summary, linked issues, test coverage notes, and screenshots/GIFs for UI changes. Update `README.md` and `Screenshots.md` when behavior or visuals change.

## Localization & Resources

- Add languages under `Sources/Resources/<lang>.lproj/Localizable.strings`.
- Keep `apps.json` schema consistent with README. Access resources via `Bundle.module`.

## Security & Configuration Tips

- Do not commit secrets. Keep network-dependent logic injectable/testable; avoid live network in tests.

## MCP Servers

Always use context7 when I need code generation, setup or configuration steps, or library/API documentation. This means you should automatically use the Context7 MCP tools to resolve library id and get library docs without me having to explicitly ask.

Skip the `resolve-library-id` for Swift, and all Apple frameworks since we know the _library ID_ is `/websites/developer_apple`.
