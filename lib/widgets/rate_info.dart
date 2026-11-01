import 'package:flutter/material.dart';

class RateInfo extends StatelessWidget {
  final String rateLabel;

  const RateInfo({
    super.key,
    required this.rateLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      rateLabel,
      style: const TextStyle(color: Colors.grey, fontSize: 12),
    );
  }
}