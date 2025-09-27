import 'dart:convert';
import 'package:riverpod/riverpod.dart' as rp;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/conversion_record.dart';
import '../../../core/supabase/database_service.dart';
import '../../../core/auth/auth_providers.dart';

const _prefsKey = 'conversion_history_v1';

final historyProvider =
    rp.StateNotifierProvider<HistoryNotifier, List<ConversionRecord>>(
  (ref) => HistoryNotifier(ref),
);

final databaseServiceProvider = rp.Provider<SupabaseDatabaseService>((ref) => SupabaseDatabaseService());

class HistoryNotifier extends rp.StateNotifier<List<ConversionRecord>> {
  final rp.Ref _ref;
  late final SupabaseDatabaseService _databaseService;

  HistoryNotifier(this._ref) : super([]) {
    _databaseService = _ref.read(databaseServiceProvider);
    _load();
  }

  Future<void> _load() async {
    try {
      // Try to load from Supabase first (if user is authenticated)
      final authState = _ref.read(authStateProvider);
      if (authState == AuthState.authenticated) {
        final records = await _databaseService.getConversionHistory();
        state = records;
        return;
      }
    } catch (e) {
      print('Failed to load from Supabase: $e');
    }

    // Fallback to local storage
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefsKey);
    if (raw == null || raw.isEmpty) {
      state = [];
      return;
    }
    final list = (jsonDecode(raw) as List)
        .whereType<Map<String, dynamic>>()
        .map(ConversionRecord.fromJson)
        .toList();
    // newest first
    list.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    state = list;
  }

  Future<void> addRecord(ConversionRecord record) async {
    try {
      // Try to save to Supabase first (if user is authenticated)
      final authState = _ref.read(authStateProvider);
      if (authState == AuthState.authenticated) {
        await _databaseService.addConversionRecord(record);
      }
    } catch (e) {
      print('Failed to save to Supabase: $e');
    }

    // Always save locally as backup
    final updated = [record, ...state];
    state = updated;
    await _save();
  }

  Future<void> clear() async {
    try {
      // Try to clear from Supabase first (if user is authenticated)
      final authState = _ref.read(authStateProvider);
      if (authState == AuthState.authenticated) {
        await _databaseService.clearConversionHistory();
      }
    } catch (e) {
      print('Failed to clear from Supabase: $e');
    }

    // Clear local storage
    state = [];
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefsKey);
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = jsonEncode(state.map((e) => e.toJson()).toList());
    await prefs.setString(_prefsKey, raw);
  }
}
