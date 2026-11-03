import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

import '../../bloc/currency_bloc.dart';
import '../../bloc/currency_state.dart';

class RateHistoryChart extends StatelessWidget {
  const RateHistoryChart({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CurrencyBloc, CurrencyState>(
      // Only rebuild the chart when the history status or data changes
      buildWhen: (previous, current) => previous.historyStatus != current.historyStatus,
      builder: (context, state) {

        //loading spinner while chart data is fetching
        if (state.historyStatus == RateStatus.loading) {
          return const SizedBox(
            height: 200,
            child: Center(child: CircularProgressIndicator()),
          );

          //error message if chart data fails to load
        } else if (state.historyStatus == RateStatus.error) {
          return SizedBox(
            height: 200,
            width: 500,
            child: Center(
              child: Text(
                state.historyErrorMessage ?? 'Failed to load chart',
                style: const TextStyle(color: Colors.white),
              ),
            ),
          );

          // hides chart if no data is available
        } else if (state.historyRates.isEmpty) {
          return const SizedBox.shrink();
        }
return Container(
          width: double.infinity, // Forces chart to align with other cards
          height: 250,
          padding: const EdgeInsets.only(right: 20, left: 10, top: 20, bottom: 10),
          child: LineChart(
            LineChartData(
              gridData: const FlGridData(show: true, drawVerticalLine: false),
              titlesData: FlTitlesData(
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 30,
                    getTitlesWidget: (value, meta) {
                      final index = value.toInt();
                      if (index >= 0 && index < state.historyRates.length) {
                        final date = state.historyRates[index].date;
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            DateFormat('MMM d').format(date),
                            // Added color to make it visible
                            style: const TextStyle(fontSize: 10, color: Colors.grey), 
                          ),
                        );
                      }
                      return const Text('');
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 60, // Increased from 45 to fit large NGN numbers
                    getTitlesWidget: (value, meta) {
                      return Text(
                        value.toStringAsFixed(1), // Reduced decimal places for cleaner look
                        style: const TextStyle(fontSize: 10, color: Colors.grey),
                      );
                    },
                  ),
                ),
              ),
              borderData: FlBorderData(
                show: true,
                border: Border.all(color: Colors.grey),
              ),
              lineBarsData: [
                LineChartBarData(
                  spots: state.chartSpots,
                  isCurved: true,
                  color: Color(0xFF7B88FF),
                  barWidth: 3,
                  isStrokeCapRound: true,
                  dotData: const FlDotData(show: true),
                  belowBarData: BarAreaData(
                    show: true,
                    color: Colors.transparent, // Set to transparent to avoid clutter
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}