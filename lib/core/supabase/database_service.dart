// lib/core/supabase/database_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import '../supabase/supabase_config.dart';
import '../../features/history/models/conversion_record.dart';

/// Supabase Database Service for CurrenSee
class SupabaseDatabaseService {
  static final SupabaseDatabaseService _instance = SupabaseDatabaseService._internal();
  factory SupabaseDatabaseService() => _instance;
  SupabaseDatabaseService._internal();

  /// Get current user ID
  String? get _currentUserId => SupabaseConfig.auth.currentUser?.id;

  /// Add conversion record to history
  Future<void> addConversionRecord(ConversionRecord record) async {
    if (_currentUserId == null) throw Exception('User not authenticated');

    try {
      await SupabaseConfig.database.from(SupabaseTables.conversionHistory).insert({
        'user_id': _currentUserId,
        'from_currency': record.from,
        'to_currency': record.to,
        'amount': record.amount,
        'rate': record.rate,
        'result': record.result,
        'timestamp': record.timestamp.toIso8601String(),
      });
    } catch (e) {
      throw Exception('Failed to save conversion record: $e');
    }
  }

  /// Get user's conversion history
  Future<List<ConversionRecord>> getConversionHistory({
    int limit = 50,
    int offset = 0,
  }) async {
    if (_currentUserId == null) throw Exception('User not authenticated');

    try {
      final response = await SupabaseConfig.database.from(SupabaseTables.conversionHistory)
          .select()
          .eq('user_id', _currentUserId!)
          .order('timestamp', ascending: false)
          .range(offset, offset + limit - 1);

      return response.map((data) => ConversionRecord.fromSupabaseJson(data)).toList();
    } catch (e) {
      throw Exception('Failed to fetch conversion history: $e');
    }
  }

  /// Delete conversion record
  Future<void> deleteConversionRecord(String recordId) async {
    if (_currentUserId == null) throw Exception('User not authenticated');

    try {
      await SupabaseConfig.database.from(SupabaseTables.conversionHistory)
          .delete()
          .eq('id', recordId)
          .eq('user_id', _currentUserId!);
    } catch (e) {
      throw Exception('Failed to delete conversion record: $e');
    }
  }

  /// Clear all conversion history
  Future<void> clearConversionHistory() async {
    if (_currentUserId == null) throw Exception('User not authenticated');

    try {
      await SupabaseConfig.database.from(SupabaseTables.conversionHistory)
          .delete()
          .eq('user_id', _currentUserId!);
    } catch (e) {
      throw Exception('Failed to clear conversion history: $e');
    }
  }

  /// Get user preferences
  Future<Map<String, dynamic>?> getUserPreferences() async {
    if (_currentUserId == null) throw Exception('User not authenticated');

    try {
      final response = await SupabaseConfig.database.from(SupabaseTables.userPreferences)
          .select()
          .eq('user_id', _currentUserId!)
          .single();

      return response;
    } catch (e) {
      if (e.toString().contains('No rows')) {
        return null; // No preferences found
      }
      throw Exception('Failed to fetch user preferences: $e');
    }
  }

  /// Update user preferences
  Future<void> updateUserPreferences(Map<String, dynamic> preferences) async {
    if (_currentUserId == null) throw Exception('User not authenticated');

    try {
      await SupabaseConfig.database.from(SupabaseTables.userPreferences)
          .upsert({
            'user_id': _currentUserId,
            ...preferences,
          });
    } catch (e) {
      throw Exception('Failed to update user preferences: $e');
    }
  }

  /// Add rate alert
  Future<String> addRateAlert({
    required String fromCurrency,
    required String toCurrency,
    required double targetRate,
    required String alertType,
  }) async {
    if (_currentUserId == null) throw Exception('User not authenticated');

    try {
      final response = await SupabaseConfig.database.from(SupabaseTables.rateAlerts)
          .insert({
            'user_id': _currentUserId,
            'from_currency': fromCurrency,
            'to_currency': toCurrency,
            'target_rate': targetRate,
            'alert_type': alertType,
          })
          .select()
          .single();

      return response['id'] as String;
    } catch (e) {
      throw Exception('Failed to add rate alert: $e');
    }
  }

  /// Get user's rate alerts
  Future<List<Map<String, dynamic>>> getRateAlerts() async {
    if (_currentUserId == null) throw Exception('User not authenticated');

    try {
      final response = await SupabaseConfig.database.from(SupabaseTables.rateAlerts)
          .select()
          .eq('user_id', _currentUserId!)
          .eq('is_active', true)
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Failed to fetch rate alerts: $e');
    }
  }

  /// Update rate alert
  Future<void> updateRateAlert(String alertId, Map<String, dynamic> updates) async {
    if (_currentUserId == null) throw Exception('User not authenticated');

    try {
      await SupabaseConfig.database.from(SupabaseTables.rateAlerts)
          .update(updates)
          .eq('id', alertId)
          .eq('user_id', _currentUserId!);
    } catch (e) {
      throw Exception('Failed to update rate alert: $e');
    }
  }

  /// Delete rate alert
  Future<void> deleteRateAlert(String alertId) async {
    if (_currentUserId == null) throw Exception('User not authenticated');

    try {
      await SupabaseConfig.database.from(SupabaseTables.rateAlerts)
          .delete()
          .eq('id', alertId)
          .eq('user_id', _currentUserId!);
    } catch (e) {
      throw Exception('Failed to delete rate alert: $e');
    }
  }

  /// Cache exchange rate
  Future<void> cacheExchangeRate({
    required String fromCurrency,
    required String toCurrency,
    required double rate,
    String source = 'api',
  }) async {
    try {
      await SupabaseConfig.database.from(SupabaseTables.exchangeRates)
          .insert({
            'from_currency': fromCurrency,
            'to_currency': toCurrency,
            'rate': rate,
            'source': source,
          });
    } catch (e) {
      // Ignore errors for caching - not critical
      print('Failed to cache exchange rate: $e');
    }
  }

  /// Get cached exchange rate
  Future<double?> getCachedExchangeRate({
    required String fromCurrency,
    required String toCurrency,
    Duration maxAge = const Duration(minutes: 5),
  }) async {
    try {
      final cutoffTime = DateTime.now().subtract(maxAge);
      
      final response = await SupabaseConfig.database.from(SupabaseTables.exchangeRates)
          .select('rate')
          .eq('from_currency', fromCurrency)
          .eq('to_currency', toCurrency)
          .gte('timestamp', cutoffTime.toIso8601String())
          .order('timestamp', ascending: false)
          .limit(1)
          .maybeSingle();

      if (response != null) {
        return (response['rate'] as num).toDouble();
      }
      return null;
    } catch (e) {
      return null; // Return null on error - not critical
    }
  }

  /// Get realtime conversion history stream
  Stream<List<ConversionRecord>> getConversionHistoryStream() {
    if (_currentUserId == null) {
      return Stream.value([]);
    }

    // Subscribe to realtime changes
    SupabaseConfig.realtime
        .channel('conversion_history_$_currentUserId')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: SupabaseTables.conversionHistory,
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'user_id',
            value: _currentUserId!,
          ),
          callback: (payload) async {
            // This will trigger a refetch of the data
          },
        )
        .subscribe();
        
    // Return a stream that periodically fetches the latest data
    return Stream.periodic(const Duration(seconds: 30))
        .asyncMap((_) => getConversionHistory());
  }
}
