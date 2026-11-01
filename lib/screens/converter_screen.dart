import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/currency_bloc.dart';
import '../../bloc/currency_event.dart';
import '../../bloc/currency_state.dart';
import '../widgets/amount_input.dart';
import '../widgets/conversion_result.dart';
import '../widgets/currency_dropdown.dart';
import '../widgets/rate_info.dart';

class CurrencyScreen extends StatelessWidget {
  const CurrencyScreen({super.key});

  final Color bgColor = const Color(0xFF0D1117);
  final Color cardColor = const Color(0xFF161B22);
  final Color accentColor = const Color(0xFF7B88FF);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        title: const Text(
          'FX Converter',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () => context.read<CurrencyBloc>().add(LoadCurrencies()),
          ),
        ],
      ),
      body: BlocConsumer<CurrencyBloc, CurrencyState>(
        // listen to trigger SnackBar and also dismiss it
        listener: (context, state) {
          if (state.status == RateStatus.error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                backgroundColor: Color(0xFF161B22),
                content: Text(state.errorMessage ?? 'An error occurred'),
                behavior: SnackBarBehavior.floating, // Makes it look modern
                margin: EdgeInsets.only(
                  bottom:
                      MediaQuery.of(context).size.height -
                      95, // Position it above the bottom
                  left: 16,
                  right: 16,
                ),
                dismissDirection: DismissDirection.horizontal,
              ),
            );
          }
        },
        //Draw the UI
        builder: (context, state) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AmountInput(
                  cardColor: cardColor,
                  onChanged: (value) {
                    final amount = double.tryParse(value) ?? 0.0;
                    context.read<CurrencyBloc>().add(SetAmount(amount));
                  },
                ),

                const SizedBox(height: 24),

                CurrencyDropdown(
                  title: 'From', // Updated from 'title'
                  selectedCode: state.baseCurrencyCode,
                  currencies: state.currencies,
                  cardColor: cardColor,
                  bgColor: bgColor,
                  onCurrencySelected: (code) => context
                      .read<CurrencyBloc>()
                      .add(SelectBaseCurrency(code)),
                ),

                Center(
                  child: IconButton(
                    icon: CircleAvatar(
                      backgroundColor: cardColor,
                      child: Icon(Icons.swap_vert, color: accentColor),
                    ),
                    onPressed: () =>
                        context.read<CurrencyBloc>().add(SwapCurrencies()),
                  ),
                ),

                CurrencyDropdown(
                  title: 'To', // Updated from 'title'
                  selectedCode: state.targetCurrencyCode,
                  currencies: state.currencies,
                  cardColor: cardColor,
                  bgColor: bgColor,
                  onCurrencySelected: (code) => context
                      .read<CurrencyBloc>()
                      .add(SelectTargetCurrency(code)),
                ),

                const SizedBox(height: 32),

                ConversionResult(
                  amount: state.amount,
                  baseCurrencyCode: state.baseCurrencyCode,
                  targetCurrencyCode: state.targetCurrencyCode,
                  convertedAmount: state.convertedAmount ?? 0.0,
                  cardColor: cardColor,
                  accentColor: accentColor,
                ),

                const SizedBox(height: 16),

                RateInfo(rateLabel: state.rateLabel ?? ''),
              ],
            ),
          );
        },
      ),
    );
  }
}
