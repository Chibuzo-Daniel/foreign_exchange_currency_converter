import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foreign_exchange_currency_converter/screens/converter_screen.dart';
import 'bloc/currency_bloc.dart';
import 'bloc/currency_event.dart';
import 'injection_container.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Currency Converter',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      ),

      home: BlocProvider(
        // trigger the initial event to load currencies when the app starts
        create: (context) {
          final myBloc = serviceLocator<CurrencyBloc>();
          myBloc.add(LoadCurrencies());
          return myBloc;
        },
        // A temporary placeholder until we build the actual UI screen
        child: const CurrencyScreen(),
      ),
    );
  }
}
