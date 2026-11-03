# Foreign Exchange Currency Converter

A robust, cross-platform mobile application built with Flutter that provides real-time currency exchange rates, historical rate charts, and offline conversion capabilities.

## Tier Attempted
Tier 1 and Tier 2 - Includes Currency convertion, full local caching for offline use and a persistent Favorites system.

## API Used
* Primary API: Frankfurter API
* Network Client: Dio



## How to Run the Project

1. Clone the repository:
   ```bash
   git clone https://github.com/Chibuzo-Daniel/foreign_exchange_currency_converter.git
   cd your-repo-name

2. Insall dependencies:
   flutter pub get

3. Run the App:
   flutter run

Known Limitations:
   1. While the current exchange rate is cached for offline conversions, the 7-day historical chart requires an active internet connection to render.

   2. If the user remains offline for an extended period, the cached conversion rates will not reflect real-time market fluctuations until the connection is restored.

Appetize link for testing the app:
https://appetize.io/app/b_vkqe2gz6wv46krgwx4mahh5wky
https://appetize.io/embed/b_vkqe2gz6wv46krgwx4mahh5wky