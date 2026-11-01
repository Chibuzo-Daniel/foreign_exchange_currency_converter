//define a currency model class
class Currency {
  final String code;
  final String name;
  final String symbol;

  const Currency({
    required this.code,
    required this.name,
     this.symbol = '',
  });

//factory method to create a Currency object from a JSON map
factory Currency.fromJson(Map<String, dynamic> json) {
    return Currency(
     code: json['code']?.toString() ?? json['base']?.toString() ?? json['quote']?.toString() ?? 'Unknown',
    
    // Safely check for 'name', fallback to a default string if missing
    name: json['name']?.toString() ?? 'Unknown Currency',
    
    // Safely check for 'symbol'
    symbol: json['symbol']?.toString() ?? '',
    );
  }
}
