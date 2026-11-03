import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/repositories/currency_repository.dart';
import 'currency_event.dart';
import 'currency_state.dart';

class CurrencyBloc extends Bloc<CurrencyEvent, CurrencyState> {
  final CurrencyRepository repository;

  // the constructor requires the repository and sets the initial state.
  CurrencyBloc({required this.repository}) : super(const CurrencyState()) {
    // We register a listener for every single event using 'on<Event>'
    on<LoadCurrencies>(_onLoadCurrencies);
    on<FetchRates>(_onFetchRates);
    on<SelectBaseCurrency>(_onSelectBaseCurrency);
    on<SelectTargetCurrency>(_onSelectTargetCurrency);
    on<SetAmount>(_onSetAmount);
    on<SwapCurrencies>(_onSwapCurrencies);
    on<LoadFavorites>(_onLoadFavorites);
    on<ToggleFavoritePair>(_onToggleFavoritePair);
  }

  // triggered once when the app opens.
  Future<void> _onLoadCurrencies(
    LoadCurrencies event,
    Emitter<CurrencyState> emit,
  ) async {
    emit(state.copyWith(status: RateStatus.loading));
    try {
      final currencies = await repository.getCurrencies();
      // emit the content of the list.
      emit(state.copyWith(status: RateStatus.loaded, currencies: currencies));

      // fetch the exchange rate for the default USD to EUR pair
      add(FetchRates());
    } catch (e) {
      String message = e.toString();
      if (message.contains('Failed host lookup') ||
          message.contains('SocketException')) {
        message = 'No internet connection. Please check your network.';
      }
      emit(state.copyWith(status: RateStatus.error, errorMessage: message));
    }
  }

  // triggered to get the actual rates and history.
  Future<void> _onFetchRates(
    FetchRates event,
    Emitter<CurrencyState> emit,
  ) async {
    // trigger loading states for BOTH live rate and history independently
    emit(
      state.copyWith(
        status: RateStatus.loading,
        historyStatus: RateStatus.loading,
      ),
    );

    // fetch live rate
    try {
      final rate = await repository.getRate(
        state.baseCurrencyCode,
        state.targetCurrencyCode,
      );
      final isStale = await repository.isRateStale(
        state.baseCurrencyCode,
        state.targetCurrencyCode,
      );
      emit(
        state.copyWith(
          status: RateStatus.loaded,
          exchangeRate: rate,
          isStale: isStale,
        ),
      );
    } catch (e) {
      String message = e.toString();
      if (message.contains('Failed host lookup') ||
          message.contains('SocketException')) {
        message = 'No internet connection. Please check your network.';
      }
      emit(state.copyWith(status: RateStatus.error, errorMessage: message));
    }

    // fetch history data
    try {
      // history for 7 days
      final history = await repository.getHistory(
        state.baseCurrencyCode,
        state.targetCurrencyCode,
        7,
      );
      emit(
        state.copyWith(historyStatus: RateStatus.loaded, historyRates: history),
      );
      emit(
        state.copyWith(historyStatus: RateStatus.loaded, historyRates: history),
      );
    } catch (e) {
      // error message for failed history fetch
      emit(
        state.copyWith(
          historyStatus: RateStatus.error,
          historyErrorMessage: 'Failed to load chart data',
        ),
      );
    }
  }

  //Handle favorites
  void _onLoadFavorites(LoadFavorites event, Emitter<CurrencyState> emit) {
    emit(state.copyWith(favorites: repository.getFavorites()));
  }

  Future<void> _onToggleFavoritePair(
    ToggleFavoritePair event,
    Emitter<CurrencyState> emit,
  ) async {
    await repository.toggleFavorite(event.pair);
    emit(state.copyWith(favorites: repository.getFavorites()));
  }

  // if user picks a new "From" currency
  void _onSelectBaseCurrency(
    SelectBaseCurrency event,
    Emitter<CurrencyState> emit,
  ) {
    emit(state.copyWith(baseCurrencyCode: event.code));
    add(FetchRates()); // fetch new rate for the new pair
  }

  // if user picks a new "To" currency
  void _onSelectTargetCurrency(
    SelectTargetCurrency event,
    Emitter<CurrencyState> emit,
  ) {
    emit(state.copyWith(targetCurrencyCode: event.code));
    add(FetchRates()); // fetch new rate for the new pair
  }

  // if user taps the swap button
  void _onSwapCurrencies(SwapCurrencies event, Emitter<CurrencyState> emit) {
    final oldBase = state.baseCurrencyCode;
    final oldTarget = state.targetCurrencyCode;

    emit(
      state.copyWith(baseCurrencyCode: oldTarget, targetCurrencyCode: oldBase),
    );
    add(FetchRates()); // fetch new rate since they are swapped
  }

  // if user types a number in the text field
  void _onSetAmount(SetAmount event, Emitter<CurrencyState> emit) {
    emit(state.copyWith(amount: event.amount));
  }
}
