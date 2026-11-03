import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foreign_exchange_currency_converter/widgets/rate_history_chart.dart';
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

  // favourite bottom sheet method
  void _showFavoritesSheet(BuildContext context) {
    final currencyBloc = context.read<CurrencyBloc>(); 

    showModalBottomSheet(
      context: context,
      backgroundColor: cardColor, 
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return BlocBuilder<CurrencyBloc, CurrencyState>(
          bloc: currencyBloc,
          builder: (context, state) {
            if (state.favorites.isEmpty) {
              return const SizedBox(
                height: 200,
                child: Center(
                  child: Text(
                    'No favorite pairs saved yet.',
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                ),
              );
            }

            return ListView.builder(
              shrinkWrap: true,
              itemCount: state.favorites.length,
              itemBuilder: (context, index) {
                final pair = state.favorites[index];
                final parts = pair.split('-');
                final base = parts[0];
                final target = parts[1];

                return ListTile(
                  leading: const Icon(Icons.star, color: Color(0xFF7B88FF)),
                  title: Text(
                    '$base to $target',
                    style: const TextStyle(
                      color: Colors.white, 
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                    onPressed: () {
                      currencyBloc.add(ToggleFavoritePair(pair));
                    },
                  ),
                  onTap: () {
                    // Update dropdowns and fetch rates when tapped
                    currencyBloc.add(SelectBaseCurrency(base));
                    currencyBloc.add(SelectTargetCurrency(target));
                    currencyBloc.add(FetchRates());
                    Navigator.pop(context);
                  },
                );
              },
            );
          },
        );
      },
    );
  }

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
          //  Favorites list trigger
          IconButton(
            icon: const Icon(Icons.bookmarks, color: Colors.white),
            onPressed: () => _showFavoritesSheet(context),
          ),
          // EXISTING: Refresh button
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () => context.read<CurrencyBloc>().add(LoadCurrencies()),
          ),
        ],
      ),
      body: BlocConsumer<CurrencyBloc, CurrencyState>(
        listener: (context, state) {
          if (state.status == RateStatus.error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                backgroundColor: const Color(0xFF161B22),
                content: Text(state.errorMessage ?? 'An error occurred'),
                behavior: SnackBarBehavior.floating, 
                margin: EdgeInsets.only(
                  bottom: MediaQuery.of(context).size.height - 95, 
                  left: 16,
                  right: 16,
                ),
                dismissDirection: DismissDirection.horizontal,
              ),
            );
          }
        },
        builder: (context, state) {
          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
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
                        title: 'From', 
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
                          onPressed: () => context.read<CurrencyBloc>().add(
                            SwapCurrencies(),
                          ),
                        ),
                      ),

                      // the favourite toggle icon
                      BlocBuilder<CurrencyBloc, CurrencyState>(
                        builder: (context, state) {
                          final currentPair = '${state.baseCurrencyCode}-${state.targetCurrencyCode}';
                          final isFavorite = state.favorites.contains(currentPair);

                          return IconButton(
                            icon: Icon(
                              isFavorite ? Icons.favorite : Icons.favorite_border,
                              color: isFavorite ? const Color(0xFF7B88FF) : Colors.grey,
                            ),
                            onPressed: () {
                              context.read<CurrencyBloc>().add(ToggleFavoritePair(currentPair));
                            },
                          );
                        },
                      ),

                      CurrencyDropdown(
                        title: 'To', 
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
                      const RateHistoryChart(),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16.0),
                color: bgColor, 
                child: RateInfo(rateLabel: state.rateLabel ?? ''),
              ),
            ],
          );
        },
      ),
    );
  }
}