import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foreign_exchange_currency_converter/screens/converter_screen.dart';
import 'package:shared_preferences/shared_preferences.dart'; 
import 'bloc/currency_bloc.dart';
import 'bloc/currency_event.dart';
import 'data/datasources/remote_data_source.dart';
import 'data/datasources/local_data_source.dart'; 
import 'data/repositories/currency_repository_impl.dart';
import 'package:dio/dio.dart';


void main() async {
  // Ensure Flutter bindings are initialized before calling async code
  WidgetsFlutterBinding.ensureInitialized(); 
  
  // Initialize SharedPreferences
  final prefs = await SharedPreferences.getInstance();

  // Wire up the clean architecture layers
  final remoteDataSource = RemoteDataSourceImpl(client: Dio());
  final localDataSource = LocalDataSourceImpl(prefs: prefs); 
  
  //pass local and remote data into the repository
  final repository = CurrencyRepositoryImpl(
    remoteDataSource: remoteDataSource,
    localDataSource: localDataSource, 
  );

  runApp(MyApp(repository: repository));
}

class MyApp extends StatelessWidget {
  final CurrencyRepositoryImpl repository;

  const MyApp({super.key, required this.repository});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: BlocProvider(
        create: (context) => CurrencyBloc(repository: repository)
        //fetch full currency list and favorites on app startup
          ..add(LoadCurrencies())
          ..add(LoadFavorites()), 
        child: const CurrencyScreen(),
      ),
    );
  }
}