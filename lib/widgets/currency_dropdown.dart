import 'package:flutter/material.dart';
import '../../core/utils/currency_helper.dart';

class CurrencyDropdown extends StatelessWidget {
  final String title;
  final String selectedCode;
  final List<dynamic> currencies;
  final Function(String) onCurrencySelected;
  final Color cardColor;
  final Color bgColor;

  const CurrencyDropdown({
    super.key,
    required this.title,
    required this.selectedCode,
    required this.currencies,
    required this.onCurrencySelected,
    required this.cardColor,
    required this.bgColor,
  });

@override
  Widget build(BuildContext context) {
    //  Find the full name matching the currently selected code
    String selectedName = '';
    for (var currency in currencies) {
      if (currency.code == selectedCode) {
        selectedName = currency.name;
        break;
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () => _showBottomSheet(context),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Text(CurrencyHelper.getFlagEmoji(selectedCode), style: const TextStyle(fontSize: 24)),
                const SizedBox(width: 12),
                Text(selectedCode, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(width: 8),
                
                //  Display the full currency name in grey
                Expanded(
                  child: Text(
                    selectedName,
                    style: TextStyle(color: Colors.grey[400], fontSize: 14),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                
                const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
              ],
            ),
          ),
        ),
      ],
    );
  }

 void _showBottomSheet(BuildContext context) {
    // MUST be declared outside the builder so the search filter doesn't reset
    List<dynamic> filteredCurrencies = List.from(currencies);

    showModalBottomSheet(
      context: context,
      backgroundColor: cardColor,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return FractionallySizedBox(
              heightFactor: 0.8,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(color: Colors.grey[600], borderRadius: BorderRadius.circular(2)),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Search currency...',
                        hintStyle: const TextStyle(color: Colors.grey),
                        prefixIcon: const Icon(Icons.search, color: Colors.grey),
                        filled: true,
                        fillColor: bgColor,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      ),
                      onChanged: (query) {
                        setModalState(() {
                          if (query.isEmpty) {
                            filteredCurrencies = List.from(currencies);
                          } else {
                            filteredCurrencies = currencies.where((c) {
                              return c.code.toLowerCase().contains(query.toLowerCase());
                            }).toList();
                          }
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: ListView.builder(
                        itemCount: filteredCurrencies.length,
                        itemBuilder: (context, index) {
                          final currency = filteredCurrencies[index];
                         return ListTile(
  leading: Text(
    CurrencyHelper.getFlagEmoji(currency.code), 
    style: const TextStyle(fontSize: 24)
  ),
  title: Text(
    currency.code, 
    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)
  ),
  // Add this subtitle line to display the extracted currency name
  subtitle: Text(
    currency.name, 
    style: TextStyle(color: Colors.grey[400], fontSize: 13)
  ),
  onTap: () {
    onCurrencySelected(currency.code);
    Navigator.pop(context);
  },
);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}