import 'dart:convert';
import 'package:riverpod/riverpod.dart' as rp;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/conversion_record.dart';

const _prefsKey = 'conversion_history_v1';

final historyProvider =
    rp.StateNotifierProvider<HistoryNotifier, List<ConversionRecord>>(
  (ref) => HistoryNotifier(),
);

class HistoryNotifier extends rp.StateNotifier<List<ConversionRecord>> {
  HistoryNotifier() : super([]) {
    _load();
  }

  Future<void> _load() async {
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
    final updated = [record, ...state];
    state = updated;
    await _save();
  }

  Future<void> clear() async {
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
