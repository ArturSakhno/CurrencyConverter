# AGENTS.md

This file provides guidance to Codex (Codex.ai/code) when working with code in this repository.

## Project

Senior iOS take-home for ARQ/DolarApp: a USDc ⇄ other-currency exchange calculator (SwiftUI, iOS 17+, iPhone-only, portrait-only, Swift 6 language mode). The living roadmap and every locked design decision are in `~/.Codex/plans/buzzing-foraging-hearth.md`. Read it before starting a roadmap step, and update its status markers when a step lands. Project-specific subagents (`plan-reviewer`, `developer`, `code-reviewer`, `qa`) are defined in `.Codex/agents/`.

Always ask before running `git commit`, even for routine commits.

## Commands

```sh
# Build
xcodebuild build -scheme CurrencyConverter -destination 'platform=iOS Simulator,name=iPhone 17'

# All tests
xcodebuild test -scheme CurrencyConverter -destination 'platform=iOS Simulator,name=iPhone 17'

# One suite / one test (Swift Testing identifiers take a trailing "()" for functions)
xcodebuild test -scheme CurrencyConverter -destination 'platform=iOS Simulator,name=iPhone 17' \
  -only-testing:CurrencyConverterTests/ConvertCurrencyUseCaseTests
xcodebuild test -scheme CurrencyConverter -destination 'platform=iOS Simulator,name=iPhone 17' \
  -only-testing:'CurrencyConverterTests/ConvertCurrencyUseCaseTests/quoteAmountConvertsToBaseByDividing()'
```

SwiftLint is configured in `.swiftlint.yml`. SwiftFormat (`.swiftformat`) runs as a pre-commit hook from `.githooks/pre-commit`: it formats staged Swift files and re-stages them, and blocks a partially staged file that needs formatting. Enable it once per clone with `git config core.hooksPath .githooks`. Trust `xcodebuild` output over SourceKit's live diagnostics. Right after you create a file, "cannot find type" errors from SourceKit are usually a stale index.

New files under `CurrencyConverter/` and `CurrencyConverterTests/` are picked up automatically (file-system-synchronized groups). Never edit `project.pbxproj` to add a file.

## Architecture

The app uses Clean Architecture plus MVVM and a Coordinator, organized by feature. Each feature under `CurrencyConverter/Features/` is a vertical slice: `Presentation/` → `Domain/` (use cases, repository protocols, entities) → `Data/` (repository implementations → network or local storage). Dependencies point inward: Domain depends on nothing, and both Data and Presentation depend on Domain.

- **Features/Converter/**: `ConverterView` and `ConverterViewModel` (`@Observable`) with `Components/`, plus `AmountInputSanitizer` and `AmountDisplayFormatter`. `ConvertCurrencyUseCase` owns conversion: it looks up the quote's rate, picks the bid or ask for the `TradeDirection` and does the math. The view model only parses and formats. `LoadExchangeRatesUseCase` returns `.loaded(snapshot)` or `.unavailable`. `TickersAPIClient` calls `GET https://api.dolarapp.dev/v1/tickers?currencies=…` and decodes into `TickerDTO`, which maps to the Domain entity. DTOs never leak into Domain. Rates aren't persisted. `ConverterViewModel.keepRatesUpdated()` runs the refresh loop from `.task`. A failed load keeps the rates already on screen.
- **Features/CurrencyPicker/**: `CurrencyPickerView` reports `onSelect`/`onClose` and knows nothing about navigation. `CurrencyCatalogUseCase` → `CurrencyCatalogRepository` → `FallbackCurrencyCatalogRepository`, which serves the hardcoded catalog because the currencies endpoint returns 403.
- **Shared/**: code both features use. `Currency` and `CurrencyCatalog` live in `Domain/`, `CurrencyDisplayInfo` (code → label, subtitle, symbol, flag) in `Presentation/`, and small helpers in `Utils/`. Features must not import from each other; anything both need goes here.
- **App/**: `CurrencyConverterApp`, `RootView` (hosts the `NavigationStack` and the sheet switch), `AppCoordinator` (`@Observable`, sheet routing only, no push destinations), and `DependencyContainer`, which is the only place that wires Data types to Domain protocols and builds view models.
- **Packages/DesignSystem**: a local Swift package with the color, typography and spacing tokens and the generic icons (`DS.Icon`). Test it with `xcodebuild test -scheme DesignSystem` from `Packages/DesignSystem`.

Tests in `CurrencyConverterTests/` mirror the same `Features/` and `Shared/` layout.

## Concurrency gotcha (has broken the build repeatedly)

The app target sets `SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor`, so everything is implicitly `@MainActor`. Every Domain/Data type needs an explicit `nonisolated`, and so does each of its methods, including methods declared in separate `extension` blocks, where isolation doesn't cascade. Protocol requirements need `nonisolated` too. The test targets do *not* have this default, so a missing `nonisolated` often shows up only as an error from test code.

Other project settings that matter:
- `SWIFT_APPROACHABLE_CONCURRENCY = YES`
- `MemberImportVisibility` is enabled, so every file that uses `Decimal` or `Date` needs its own `import Foundation`. This applies to test files too; `@testable import` doesn't bring it in transitively.

## Locked decisions (don't re-derive)

- **Base vs quote currency**: the base is `CurrencyCatalog.base` (`USDC`), and the user picks the quote from `CurrencyCatalog.availableQuoteCurrencies` (MXN, EURC, ARS, COP, BRL). No logic may branch on a currency code string outside `Currency.swift`. The app never calls the currencies-list endpoint (it always returns 403), so the catalog is hardcoded on purpose.
- **Domain has no display strings.** The mappings from a code to its label ("EURC" → "EURc") and to its subtitle ("Colombian pesos") live in Presentation.
- **Bid/ask comes from row position (`isBaseOnTop`, which only swap toggles), never from which field has focus.** When USDc is on top (selling), use `bid`; when it's on the bottom (buying), use `ask`. The view model maps row position to `TradeDirection`; the bid/ask choice itself is `ExchangeRate.price(for:)` in Domain. On swap, the amount and focus stay with USDc.
- **Money is `Decimal`, never `Double`.** Conversion math keeps full precision. Formatting to a fixed 2 decimals, for every currency including COP, happens only at display time.
- **Amount entry is a plain `TextField` with `.keyboardType(.decimalPad)`.** There is no custom keypad, which is a documented deviation from Figma.
- **Offline behavior:**
  - Rates aren't persisted, because a converter's rates only mean something live. When no rates have loaded in this session (e.g. a cold start offline), show a blocking full-screen "No connection" state with a Retry button. The amount fields must not be in the view hierarchy at all, not just hidden.
  - If a refresh fails after rates have loaded, stay non-blocking: keep the rates on screen. "Rates as of" shows when they were fetched; there's no separate stale marker.
  - While the converter is on screen, rates refresh 30 s after the previous response arrived, whether it succeeded or failed. The API's per-quote `date` is ignored. Returning from the background resumes the loop, so an overdue refresh happens right away. There's no debounce, because conversion is local math. A "rates as of" timestamp is always visible, using client capture time.
- **Design tokens** live in `Presentation/DesignSystem/` and are named after the Figma variables. Views use `.foregroundStyle(.textPrimary)`-style `ThemeColor` tokens, `.textStyle(\.h3)`, and `DS.Spacing`/`DS.Radius`, never raw `Color(hex:)` or `.system(size:)`. The theme follows the system Light/Dark; add a theme as another `Theme` `static let` and inject it with `.theme(_:)`. The `theme` environment key is hand-written and `nonisolated`, not `@Entry`, because `ThemeColor.resolve` is nonisolated.
- **Scope**: Dark Mode is in scope (Figma is light-only, so it's self-designed). i18n uses a String Catalog and ships English and Spanish.

## Live API quirks the code must respect

- An unknown or lowercase code, or a space in the `currencies` list, makes the **whole batch** return HTTP 500. Join codes with `","` and no space.
- A code like `EUR` returns a `null` array element. Decode `[TickerDTO?]` and filter out the nulls.
- Match tickers back to a currency by content (the `book` field, e.g. `usdc_mxn`), never by array index, because filtering nulls shifts the indices.
- `ask` and `bid` arrive as strings with 10 decimal places. `date` has nanosecond precision and no timezone; the app doesn't use it.
- The `x-correlation-id` response header is attached to `APIError`.

## Tests

Tests use Swift Testing (`import Testing`, `@Test`, `#expect`), never XCTest. Add unit tests for new pure logic (use cases, decoding, mapping) together with that logic.

## Submission

The deliverable is a zip that must build and run with no changes. The `CurrencyConverter` scheme is not shared yet (there's no `xcshareddata/`); it has to be marked Shared before packaging.
