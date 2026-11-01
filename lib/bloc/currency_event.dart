//  parent class for all events.
sealed class CurrencyEvent {}

// triggered once when the app opens to download the currency list.
class LoadCurrencies extends CurrencyEvent {}

// triggered for new exchange rate from the internet.
class FetchRates extends CurrencyEvent {}

// triggered when the user picks a new currency from the dropdown.
class SelectBaseCurrency extends CurrencyEvent {
  final String code;
  SelectBaseCurrency(this.code);
}

// triggered when the user picks a new currency from the dropdown.
class SelectTargetCurrency extends CurrencyEvent {
  final String code;
  SelectTargetCurrency(this.code);
}

// triggered on ever keypress when the user types a number.
class SetAmount extends CurrencyEvent {
  final double amount;
  SetAmount(this.amount);
}

// triggered when the user taps the swap icon button.
class SwapCurrencies extends CurrencyEvent {}