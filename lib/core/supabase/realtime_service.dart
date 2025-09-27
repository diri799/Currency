// lib/core/supabase/realtime_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:async';
import 'supabase_config.dart';

/// Realtime service for exchange rates and other live data
class RealtimeService {
  static final RealtimeService _instance = RealtimeService._internal();
  factory RealtimeService() => _instance;
  RealtimeService._internal();

  final Map<String, dynamic> _subscriptions = {};
  final Map<String, StreamController<Map<String, dynamic>>> _controllers = {};

  /// Subscribe to exchange rate updates for a currency pair
  Stream<Map<String, dynamic>> subscribeToExchangeRate({
    required String fromCurrency,
    required String toCurrency,
  }) {
    final key = 'exchange_rate_${fromCurrency}_$toCurrency';
    
    if (_controllers.containsKey(key)) {
      return _controllers[key]!.stream;
    }

    final controller = StreamController<Map<String, dynamic>>.broadcast();
    _controllers[key] = controller;

    // Subscribe to realtime changes
    SupabaseConfig.realtime
        .channel('exchange_rates_$key')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: SupabaseTables.exchangeRates,
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'from_currency',
            value: fromCurrency,
          ),
          callback: (payload) {
            final data = payload.newRecord;
            if (data != null) {
              controller.add({
                'from_currency': data['from_currency'],
                'to_currency': data['to_currency'],
                'rate': data['rate'],
                'timestamp': data['timestamp'],
                'source': data['source'],
              });
            }
          },
        )
        .subscribe();

    // Store subscription reference
    _subscriptions[key] = 'active'; // Simplified for now

    return controller.stream;
  }

  /// Subscribe to user's rate alerts
  Stream<List<Map<String, dynamic>>> subscribeToRateAlerts(String userId) {
    final key = 'rate_alerts_$userId';
    
    if (_controllers.containsKey(key)) {
      return _controllers[key]!.stream.map((data) => [data]);
    }

    final controller = StreamController<Map<String, dynamic>>.broadcast();
    _controllers[key] = controller;

    // Subscribe to realtime changes
    SupabaseConfig.realtime
        .channel('rate_alerts_$userId')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: SupabaseTables.rateAlerts,
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'user_id',
            value: userId,
          ),
          callback: (payload) {
            final data = payload.newRecord ?? payload.oldRecord;
            if (data != null) {
              controller.add({
                'id': data['id'],
                'from_currency': data['from_currency'],
                'to_currency': data['to_currency'],
                'target_rate': data['target_rate'],
                'alert_type': data['alert_type'],
                'is_active': data['is_active'],
                'last_triggered': data['last_triggered'],
                'created_at': data['created_at'],
                'updated_at': data['updated_at'],
              });
            }
          },
        )
        .subscribe();

    // Store subscription reference
    _subscriptions[key] = 'active'; // Simplified for now

    return controller.stream.map((data) => [data]);
  }

  /// Subscribe to user's conversion history
  Stream<List<Map<String, dynamic>>> subscribeToConversionHistory(String userId) {
    final key = 'conversion_history_$userId';
    
    if (_controllers.containsKey(key)) {
      return _controllers[key]!.stream.map((data) => [data]);
    }

    final controller = StreamController<Map<String, dynamic>>.broadcast();
    _controllers[key] = controller;

    // Subscribe to realtime changes
    SupabaseConfig.realtime
        .channel('conversion_history_$userId')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: SupabaseTables.conversionHistory,
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'user_id',
            value: userId,
          ),
          callback: (payload) {
            final data = payload.newRecord ?? payload.oldRecord;
            if (data != null) {
              controller.add({
                'id': data['id'],
                'from_currency': data['from_currency'],
                'to_currency': data['to_currency'],
                'amount': data['amount'],
                'rate': data['rate'],
                'result': data['result'],
                'timestamp': data['timestamp'],
                'created_at': data['created_at'],
              });
            }
          },
        )
        .subscribe();

    // Store subscription reference
    _subscriptions[key] = 'active'; // Simplified for now

    return controller.stream.map((data) => [data]);
  }

  /// Subscribe to market news and updates
  Stream<Map<String, dynamic>> subscribeToMarketNews() {
    const key = 'market_news';
    
    if (_controllers.containsKey(key)) {
      return _controllers[key]!.stream;
    }

    final controller = StreamController<Map<String, dynamic>>.broadcast();
    _controllers[key] = controller;

    // This would typically connect to a news API or webhook
    // For now, we'll simulate with periodic updates
    Timer.periodic(const Duration(minutes: 5), (timer) {
      controller.add({
        'type': 'market_update',
        'message': 'Market rates updated',
        'timestamp': DateTime.now().toIso8601String(),
      });
    });

    _controllers[key] = controller;

    return controller.stream;
  }

  /// Unsubscribe from a specific stream
  void unsubscribe(String key) {
    _subscriptions.remove(key);
    
    _controllers[key]?.close();
    _controllers.remove(key);
  }

  /// Unsubscribe from all streams
  void unsubscribeAll() {
    _subscriptions.clear();

    for (final controller in _controllers.values) {
      controller.close();
    }
    _controllers.clear();
  }

  /// Check if a subscription is active
  bool isSubscribed(String key) {
    return _subscriptions.containsKey(key);
  }

  /// Get all active subscription keys
  List<String> getActiveSubscriptions() {
    return _subscriptions.keys.toList();
  }
}
