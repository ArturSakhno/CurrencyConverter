# CurrencyConverter

A USDc ⇄ other-currency exchange calculator for the DolarApp iOS take-home: SwiftUI, iOS 17+, iPhone only, Swift 6.

## Deliberate simplifications

- **Rates aren't persisted.** A converter's rates only mean something live, so a cold start without a network connection shows the blocking "No connection" screen instead of rates saved earlier. If a refresh fails after rates have loaded, they stay on screen, marked stale. A production app could cache the last rates for display only, labelled with the date they were fetched.
- **The tickers response format is trusted.** The app handles only the API's documented quirks: `null` entries for unsupported codes, lowercase `book` values, and HTTP 500 when the currency list contains a bad code. It doesn't validate prices or `book` beyond that. A production client would reject non-positive prices and never let a response with no usable rates replace the ones on screen.
- **Rates refresh on a fixed 30-second loop.** The next request goes out 30 seconds after the previous response arrives, whether it succeeded or failed. The API's per-quote timestamp is ignored, so refreshes aren't aligned with when the server issued its quotes.
