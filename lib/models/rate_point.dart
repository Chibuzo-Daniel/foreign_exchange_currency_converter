class RatePoint {
  final DateTime date;
  final double rate;

  const RatePoint({
    required this.date,
    required this.rate,
  });

  // Parses the inner rate map for a specific date
  factory RatePoint.fromJson(String dateString, Map<String, dynamic> json, String targetCode) {
    return RatePoint(
      date: DateTime.parse(dateString),
      // Safely extract the rate for the target currency, default to 0.0 if missing
      rate: (json[targetCode] as num?)?.toDouble() ?? 0.0,
    );
  }
}