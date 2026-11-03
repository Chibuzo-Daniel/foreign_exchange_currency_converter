// lib/injection_container.dart
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'bloc/currency_bloc.dart';
import 'data/datasources/local_data_source.dart';
import 'data/datasources/remote_data_source.dart';
import 'data/repositories/currency_repository.dart';
import 'data/repositories/currency_repository_impl.dart';

//  global service locator for dependency injection
final serviceLocator = GetIt.instance;

// Initializes and registers all required classes when the app starts.
Future<void> init() async {
  
  // registerFactory creates a fresh instance of CurrencyBloc every time the UI requests it.
  serviceLocator.registerFactory<CurrencyBloc>(
    () => CurrencyBloc(repository: serviceLocator()),
  );

  
  // a store that decides if data should come rom either remote or local store
  serviceLocator.registerLazySingleton<CurrencyRepository>(
    () => CurrencyRepositoryImpl(
      remoteDataSource: serviceLocator(),
      localDataSource: serviceLocator(),
    ),
  );


  // handles data fetch from the api
  serviceLocator.registerLazySingleton<RemoteDataSource>(
    () => RemoteDataSourceImpl(client: serviceLocator()),
  );

  // handles saving and retrieving offline data and favorites
  serviceLocator.registerLazySingleton<LocalDataSource>(
    () => LocalDataSourceImpl(prefs: serviceLocator()),
  );

  
  //  Dio client for HTTP requests
  serviceLocator.registerLazySingleton<Dio>(() => Dio());

  // sharedPreferences instance used by LocalDataSource to save to the phone's memory
  final sharedPreferences = await SharedPreferences.getInstance();
  serviceLocator.registerLazySingleton(() => sharedPreferences);
}