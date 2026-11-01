import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
class ConversionResult extends StatelessWidget {
  final double amount;
  final String baseCurrencyCode;
  final String targetCurrencyCode;
  final double convertedAmount;
  final Color cardColor;
  final Color accentColor;

  const ConversionResult({
    super.key,
    required this.amount,
    required this.baseCurrencyCode,
    required this.targetCurrencyCode,
    required this.convertedAmount,
    required this.cardColor,
    required this.accentColor,
  });

 @override
  Widget build(BuildContext context) {
    // Create a formatter that forces 2 decimal places and adds commas
    final formatter = NumberFormat('#,##0.00');

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            // Format the small input amount at the top (e.g., "1.00 USD =")
            '${formatter.format(amount)} $baseCurrencyCode =',
            style: const TextStyle(color: Colors.grey, fontSize: 14),
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Text(
                  // Format the large converted amount (e.g., "1,369.49")
                  formatter.format(convertedAmount),
                  style: TextStyle(color: accentColor, fontSize: 32, fontWeight: FontWeight.bold),
                ),
              ),
              Text(
                targetCurrencyCode,
                style: const TextStyle(color: Colors.grey, fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }
}