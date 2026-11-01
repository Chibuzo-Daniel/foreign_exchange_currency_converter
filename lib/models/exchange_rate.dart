import 'package:intl/intl.dart';

class ExchangeRate {
  final String base;
  final Map<String, double> rates; // Updated to match the rubric exactly
  final DateTime lastUpdated;

  const ExchangeRate({
    required this.base,
    required this.rates,
    required this.lastUpdated,
  });

  factory ExchangeRate.fromJson(Map<String, dynamic> json) {
    // Safely extract the map of rates from the JSON
    final Map<String, dynamic> rawRates = json['rates'] as Map<String, dynamic>? ?? {};
    final Map<String, double> parsedRates = {};
    
    rawRates.forEach((key, value) {
      parsedRates[key] = (value as num).toDouble();
    });

    return ExchangeRate(
      base: json['base']?.toString() ?? 'Unknown',
      rates: parsedRates,
      lastUpdated: DateTime.tryParse(json['date']?.toString() ?? '') ?? DateTime.now(),
    );
  }

  // convert base to taget currency using the rate from  the API
  double convert(double amount, String targetRate) {
    final rate = rates[targetRate] ?? 0.0;
    return amount * rate;
  }

  // generate a label for every pair selected
  String rateLabel(String targetRate) {
    final rate = rates[targetRate] ?? 0.0;
    final formatter = NumberFormat('#,##0.00');
    return '1 $base = ${formatter.format(rate)} $targetRate';
  }
}