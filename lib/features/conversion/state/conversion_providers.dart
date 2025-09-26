// lib/features/conversion/state/conversion_providers.dart

// Riverpod v3: use the core package for providers (not flutter_riverpod here).
import 'package:riverpod/riverpod.dart' as rp;

import '../../../../services/currency_api.dart';

/// Service provider
final currencyApiProvider = rp.Provider<CurrencyApi>((_) => CurrencyApi());

/// All currency symbols (code -> description), cached by Riverpod.
final symbolsProvider = rp.FutureProvider<Map<String, String>>((ref) async {
  final api = ref.watch(currencyApiProvider);
  return api.symbols();
});

/// UI state
final baseCurrencyProvider   = rp.StateProvider<String>((_) => 'USD');
final targetCurrencyProvider = rp.StateProvider<String>((_) => 'NGN');
final amountProvider         = rp.StateProvider<double>((_) => 1.0);

/// Async rate based on current base/target
final rateProvider = rp.FutureProvider<double>((ref) async {
  final api  = ref.watch(currencyApiProvider);
  final from = ref.watch(baseCurrencyProvider);
  final to   = ref.watch(targetCurrencyProvider);
  return api.convert(from: from, to: to);
});

/// Derived converted value (amount * rate) or null while loading/error
final convertedValueProvider = rp.Provider<double?>((ref) {
  final rateAsync = ref.watch(rateProvider);
  return rateAsync.maybeWhen(
    data: (rate) => ref.watch(amountProvider) * rate,
    orElse: () => null,
  );
});
