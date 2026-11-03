import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

// Defines the contract for local storage operations (offline caching and favorites)
abstract class LocalDataSource {
  Future<void> cacheRateRawJson(
    String base,
    String target,
    Map<String, dynamic> jsonResponse,
  );
  Future<Map<String, dynamic>?> getCachedRateRawJson(String base, String target);
  Future<DateTime?> getRateTimestamp(String base, String target);
  List<String> getFavorites();
  Future<void> toggleFavorite(String pair);
}

// Implementation of the local data source using SharedPreferences for on-device storage
class LocalDataSourceImpl implements LocalDataSource {
  final SharedPreferences prefs;

  LocalDataSourceImpl({required this.prefs});

  @override
  Future<void> cacheRateRawJson(
    String base,
    String target,
    Map<String, dynamic> jsonResponse,
  ) async {
    // Generates unique storage keys based on the specific currency pair
    final key = 'rate_${base}_$target';
    final timeKey = 'time_${base}_$target';

    // Saves the API response as a string and records the exact time it was cached
    await prefs.setString(key, jsonEncode(jsonResponse));
    await prefs.setString(timeKey, DateTime.now().toIso8601String());
  }

  @override
  Future<Map<String, dynamic>?> getCachedRateRawJson(
    String base,
    String target,
  ) async {
    final key = 'rate_${base}_$target';
    final jsonString = prefs.getString(key);
    // Returns the decoded JSON map if found in the cache, allowing offline fallback
    if (jsonString != null) {
      return jsonDecode(jsonString) as Map<String, dynamic>;
    }
    return null;
  }

  @override
  Future<DateTime?> getRateTimestamp(String base, String target) async {
    final timeKey = 'time_${base}_$target';
    final timeString = prefs.getString(timeKey);
    // Retrieves the saved timestamp so the repository can check if the cached rate is stale
    if (timeString != null) {
      return DateTime.parse(timeString);
    }
    return null;
  }

  @override
  List<String> getFavorites() {
    // Fetches the saved list of favorite pairs, defaulting to an empty list if none exist
    return prefs.getStringList('favorites') ?? [];
  }

  @override
  Future<void> toggleFavorite(String pair) async {
    final favorites = getFavorites();
    // Adds the currency pair to favorites if it's missing, or removes it if it's already save
    if (favorites.contains(pair)) {
      favorites.remove(pair);
    } else {
      favorites.add(pair);
    }
    // Saves the updated list back to device storage
    await prefs.setStringList('favorites', favorites);
  }
}