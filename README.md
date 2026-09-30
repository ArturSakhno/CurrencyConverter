# CurrencyConverter

A USDc ⇄ other-currency exchange calculator for the DolarApp iOS take-home: SwiftUI, iOS 17+, iPhone only, Swift 6.

## Deliberate simplifications

- **Rates aren't persisted.** A converter's rates only mean something live, so a cold start without a network connection shows the blocking "No connection" screen instead of rates saved earlier. If a refresh fails after rates have loaded, they stay on screen, and "Rates as of" shows when they were fetched. A production app could cache the last rates for display only, labelled with the date they were fetched.
- **The tickers response format is trusted.** The app handles only the API's documented quirks: `null` entries for unsupported codes, lowercase `book` values, and HTTP 500 when the currency list contains a bad code. It doesn't validate prices or `book` beyond that. A production client would reject non-positive prices and never let a response with no usable rates replace the ones on screen.
- **Rates refresh on a fixed 30-second loop.** The next request goes out 30 seconds after the previous response arrives, whether it succeeded or failed. The API's per-quote timestamp is ignored, so refreshes aren't aligned with when the server issued its quotes.
- **The currency list is hardcoded.** `/v1/tickers-currencies` returns HTTP 403, so the five currencies come from a bundled list behind `CurrencyCatalogRepository`. If the endpoint worked and returned names and flag images too, the plan is:
  - Already in place: the converter loads the list when it appears, then the rates for those codes, since the tickers request needs them, and the picker receives the loaded list, so it opens instantly. Until the list and the first rates arrive, the screen shows a skeleton; if either request fails, it shows No connection with a Retry button. With a live endpoint, only the repository changes. This is also why the picker is part of the Converter feature.
  - Flag images are prefetched as soon as the list arrives and cached in memory, with a grey placeholder until each one loads.
  - If the list request fails, the bundled list is used instead: today's `FallbackCurrencyCatalogRepository`.
  - Codes are checked before they're joined into the tickers request, because one unexpected code makes the whole batch fail with HTTP 500. If it still fails, the selected currency is fetched on its own.
