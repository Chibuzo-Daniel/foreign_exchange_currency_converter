// lib/injection_container.dart
import 'package:dio/dio.dart';
import 'package:foreign_exchange_currency_converter/data/repositories/currency_repository_impl.dart';
import 'package:get_it/get_it.dart';

import 'bloc/currency_bloc.dart';
import 'data/datasources/remote_data_source.dart';
import 'data/repositories/currency_repository.dart';

final serviceLocator = GetIt.instance;

void init() {
   serviceLocator.registerFactory<CurrencyBloc>(
    () => CurrencyBloc(repository: serviceLocator()),
  );

  // repository (the middle man between the BLoC and the data source)
  serviceLocator.registerLazySingleton<CurrencyRepository>(
    () => CurrencyRepositoryImpl(remoteDataSource: serviceLocator()),
  );

  // data source (where the data comes from)
  serviceLocator.registerLazySingleton<RemoteDataSource>(
    () => RemoteDataSourceImpl(client: serviceLocator()),
  );

  // Dio client for making HTTP requests
  serviceLocator.registerLazySingleton<Dio>(() => Dio());
}