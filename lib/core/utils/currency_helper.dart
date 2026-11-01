// lib/core/utils/currency_helper.dart

class CurrencyHelper {
  static String getFlagEmoji(String currencyCode) {
    // Fallback if the code is invalid
    if (currencyCode.length < 2) return '🏳️';

    // Handle common exceptions where the first two letters don't match the country
    if (currencyCode == 'EUR') return '🇪🇺'; 
    if (currencyCode == 'BTC') return '₿';

    // Extract the first two letters (e.g., 'US' from 'USD')
    final countryCode = currencyCode.substring(0, 2).toUpperCase();

    // Convert the letters into regional indicator emojis using Unicode math
    final int firstLetter = countryCode.codeUnitAt(0) - 65 + 127462;
    final int secondLetter = countryCode.codeUnitAt(1) - 65 + 127462;

    return String.fromCharCode(firstLetter) + String.fromCharCode(secondLetter);
  }
}