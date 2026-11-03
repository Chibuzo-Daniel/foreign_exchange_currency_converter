import 'package:flutter/material.dart';

class AmountInput extends StatelessWidget {
  // callback function to handle changes in the text field
  final Function(String) onChanged;
  
  // background color for text fiel
  final Color cardColor;

  const AmountInput({
    super.key,
    required this.onChanged,
    required this.cardColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
                const Text('Amount', style: TextStyle(color: Colors.grey, fontSize: 12)),
        const SizedBox(height: 8),
        
        // tect input area
        TextField(
          
          keyboardType: TextInputType.number,
          style: const TextStyle(color: Colors.white, fontSize: 18),
          decoration: InputDecoration(
            filled: true,
            fillColor: cardColor,
            // Creates smooth, rounded corners without a harsh outer border
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
          // Triggers the callback function for every change
          onChanged: onChanged,
        ),
      ],
    );
  }
}