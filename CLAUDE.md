# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

Senior iOS take-home for ARQ/DolarApp: a USDc ⇄ other-currency exchange calculator (SwiftUI, iOS 17+, iPhone-only, portrait-only, Swift 6 language mode). The living roadmap and every locked design decision are in `~/.claude/plans/buzzing-foraging-hearth.md`. Read it before starting a roadmap step, and update its status markers when a step lands. Project-specific subagents (`plan-reviewer`, `developer`, `code-reviewer`, `qa`) are defined in `.claude/agents/`.

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

SwiftLint (`.swiftlint.yml`) runs as an Xcode build phase over the app, the tests and `Packages/`. The pre-commit hook in `.githooks/pre-commit` formats staged Swift files with SwiftFormat (`.swiftformat`) and re-stages them, and blocks a partially staged file that needs formatting. It then runs `swiftlint lint --strict` on the staged files, so any SwiftLint warning blocks the commit. Enable it once per clone with `git config core.hooksPath .githooks`. Trust `xcodebuild` output over SourceKit's live diagnostics. Right after you create a file, "cannot find type" errors from SourceKit are usually a stale index.

New files under `CurrencyConverter/` and `CurrencyConverterTests/` are picked up automatically (file-system-synchronized groups). Never edit `project.pbxproj` to add a file.

## Architecture

The app uses Clean Architecture plus MVVM and a Coordinator, organized by feature. Each feature under `CurrencyConverter/Features/` is a vertical slice: `Presentation/` → `Domain/` (use cases, repository protocols, entities) → `Data/` (repository implementations → network or local storage). Dependencies point inward: Domain depends on nothing, and both Data and Presentation depend on Domain.

- **Features/Converter/**: `ConverterScreen` routes between the loading, converter, error and no-connection states; `ConverterView` owns the calculator UI, with the reusable `Shared/Presentation/Components/StatusScreenView` for failure states. `ConverterViewModel` (`@Observable`) owns presentation state, plus `AmountInputSanitizer` and `AmountDisplayFormatter`. `ConvertCurrencyUseCase` owns conversion: it looks up the quote's rate, picks the bid or ask for the `TradeDirection` and does the math. The view model only parses and formats. `LoadExchangeRatesUseCase` returns the snapshot or throws `ExchangeRatesError`. `DefaultTickersAPIClient` builds `GET https://api.dolarapp.dev/v1/tickers?currencies=…` with `RequestBuilder`, sends it through `NetworkClient` and decodes into `TickerDTO`; `RemoteExchangeRateRepository` maps that to the Domain entity and maps any `NetworkError` to `ExchangeRatesError.unavailable`. DTOs and `NetworkError` never leak into Domain. Rates aren't persisted. Errors are typed at every layer (`throws(NetworkError)` → `throws(ExchangeRatesError)` → the view model's private `loadContent() throws(LoadError)`). `ConverterViewModel.state` is `.loading`, `.converter(Content)` or `.failed(LoadError)`. `Content` holds the selected quote currency, the currency list and the rates snapshot, so none of them is optional; `baseCurrency` is a fixed `let`. `keepRatesUpdated()` runs from `.task` on a container that survives state changes. The first load fetches the currency list, then the rates for those codes; if the list is empty or the rates fail, it asks `NetworkMonitor` and shows `.failed(.noConnection)` when the device is offline or `.failed(.unavailable)` when it's online. The loop retries both states every 30 s, Retry retries at once, and `retryWhenBackOnline()` (a second `.task`) retries `.noConnection` as soon as the network path is satisfied again. After that, rates refresh every 30 s and a failed refresh keeps the converter. While loading, `ConverterScreen` shows `ConverterView` with a placeholder currency under `.skeleton(_:)` from DesignSystem.
- **Features/Converter/Presentation/CurrencyPicker/**: the "Choose currency" sheet. It belongs to the Converter feature because the converter owns the currency list (it loads the list before the rates and hands it to the picker). `CurrencyPickerView` reports `onSelect`/`onClose` and knows nothing about navigation. The list comes from `CurrencyCatalogUseCase` → `CurrencyCatalogRepository` → `FallbackCurrencyCatalogRepository` in Converter's Domain and Data, which serves the hardcoded catalog because the currencies endpoint returns 403.
- **Currency types**: `Currency` and `CurrencyCatalog` live in `Converter/Domain/Entities/`, and `CurrencyDisplayInfo` (code → label, subtitle, symbol, flag) in `Converter/Presentation/`. Generic status UI lives in `Shared/Presentation/Components/`; currency types stay in Converter because only this feature uses them. If another feature needs currency types, move those types to `Shared/`, and keep features independent of one another.
- **Shared/Domain** and **Shared/Data**: the `NetworkMonitor` port (`isConnected`, `connectivityUpdates()`) and `NWPathNetworkMonitor`, which starts a fresh `NWPathMonitor` for each stream and answers `isConnected` from the first path it reports. The app never checks connectivity before a request; the monitor only explains a failure and signals when to retry.
- **App/**: `CurrencyConverterApp`, `RootView` (hosts the `NavigationStack` and the sheet switch), `AppCoordinator` (`@Observable`, sheet routing only, no push destinations), and `DependencyContainer`, which is the only place that wires Data types to Domain protocols and builds view models.
- **Packages/DesignSystem**: a local Swift package with the color (`DS.Color`), typography (`.textStyle(_:)`) and spacing tokens and the generic icons (`DS.Icon`). Test it with `xcodebuild test -scheme DesignSystem` from `Packages/DesignSystem`.
- **Packages/Networking**: a local, app-agnostic Swift package. `RequestBuilder` is a value-type fluent builder that produces a `URLRequest`; `NetworkClient` / `URLSessionNetworkClient` treat only HTTP 200 as success; everything throws `NetworkError` as a typed error (`throws(NetworkError)`), wrapping transport and decoding failures. The package has no default MainActor isolation, so it needs no `nonisolated`. It declares macOS 14 next to iOS 17 so that `swift test` from `Packages/Networking` can build it for the Mac; without it SwiftPM targets macOS 12, where `URL.appending(path:)` doesn't exist.
- **Resources/**: `Localizable.xcstrings` holds English and Spanish strings under `common.*` and `converter.*` keys. `Localized.swift` exposes them as `Localized.Common` and `Localized.Converter` resources for both SwiftUI views and `String(localized:)`.

Tests in `CurrencyConverterTests/` mirror the same `Features/` layout.

## Concurrency gotcha (has broken the build repeatedly)

The app target sets `SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor`, so everything is implicitly `@MainActor`. Every Domain/Data type needs an explicit `nonisolated`, and so does each of its methods, including methods declared in separate `extension` blocks, where isolation doesn't cascade. Protocol requirements need `nonisolated` too. The test targets do *not* have this default, so a missing `nonisolated` often shows up only as an error from test code.

Other project settings that matter:
- `SWIFT_APPROACHABLE_CONCURRENCY = YES`
- `MemberImportVisibility` is enabled, so every file that uses `Decimal` or `Date` needs its own `import Foundation`. This applies to test files too; `@testable import` doesn't bring it in transitively.

## Code organization

SwiftFormat's `organizeDeclarations` orders every type and extension body: nested types, static properties, property wrappers, stored properties, computed properties, `init`, `body`, then methods, with public before private inside each group and no MARK comments. It keeps the relative order of the stored properties behind a struct's memberwise init, so call sites don't change. Within each access level, stored `let`s come before stored `var`s. SwiftFormat can't sort that, so SwiftLint's `let_before_var` rule checks it for top-level types; check nested types by hand. In a struct with a memberwise init, prefer `let` for an input that never changes over reordering its properties.

Private methods and computed properties go in a `private extension` right after the type, never in its body; SwiftLint's `private_member_outside_private_extension` rule flags any that don't. Members of that extension drop the `private` keyword, and in an extension of a `nonisolated` type each one needs its own `nonisolated`.

Never force unwrap, not even `URL(string:)` with a literal: SwiftLint's `force_unwrapping` rule runs with no exceptions. In tests, unwrap with `try #require(…)` and set a suite's stored fixtures in a throwing `init()`.

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
- **Design tokens** live in `Packages/DesignSystem` and are named after the Figma variables. Views use `DS.Color` tokens (`.foregroundStyle(DS.Color.textPrimary)`), `.textStyle(.h3)`, and `DS.Spacing`/`DS.Radius`/`DS.Size`, never raw colors or `.system(size:)`. Each `DS.Color` token is a plain `Color` that holds its light and dark hex and follows the system appearance. There are no swappable themes; to add a color, add one `static let` to `DS.Color`.
- **Scope**: Dark Mode is in scope (Figma is light-only, so it's self-designed). i18n uses a String Catalog and ships English and Spanish.

## Live API quirks the code must respect

- An unknown or lowercase code, or a space in the `currencies` list, makes the **whole batch** return HTTP 500. Join codes with `","` and no space.
- A code like `EUR` returns a `null` array element. Decode `[TickerDTO?]` and filter out the nulls.
- Match tickers back to a currency by content (the `book` field, e.g. `usdc_mxn`), never by array index, because filtering nulls shifts the indices.
- `ask` and `bid` arrive as strings with 10 decimal places. `date` has nanosecond precision and no timezone; the app doesn't use it.
- A non-200 response throws `NetworkError.unexpectedStatus(HTTPURLResponse)`, so the `x-correlation-id` header stays readable from the error.

## Tests

Tests use Swift Testing (`import Testing`, `@Test`, `#expect`), never XCTest. Add unit tests for new pure logic (use cases, decoding, mapping) together with that logic.

## Submission

The deliverable is a zip that must build and run with no changes. The `CurrencyConverter` scheme is not shared yet (there's no `xcshareddata/`); it has to be marked Shared before packaging.
