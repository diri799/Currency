// lib/services/currency_api.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class CurrencyApi {
  static const _host = 'https://api.exchangerate.host';
  static const _frank = 'https://api.frankfurter.app';
  static const _erapi = 'https://open.er-api.com/v6';

  // Public: get latest FX rate FROM -> TO. Tries multiple providers.
  Future<double> convert({required String from, required String to}) async {
    // 1) exchangerate.host /convert
    final r1 = await _exchangerateHostConvert(from, to);
    if (r1 != null) return r1;

    // 2) exchangerate.host /latest?base=FROM&symbols=TO
    final r2 = await _exchangerateHostLatest(from, to);
    if (r2 != null) return r2;

    // 3) frankfurter.app /latest?from=FROM&to=TO (great CORS support)
    final r3 = await _frankfurterLatest(from, to);
    if (r3 != null) return r3;

    // 4) open.er-api.com /v6/latest/FROM
    final r4 = await _openErApiLatest(from, to);
    if (r4 != null) return r4;

    throw Exception('Unable to fetch rate for $from → $to from any provider.');
  }

  // Public: map<code, description>
  Future<Map<String, String>> symbols() async {
    // exchangerate.host
    try {
      final res = await http
          .get(Uri.parse('$_host/symbols'))
          .timeout(const Duration(seconds: 12));
      if (res.statusCode == 200) {
        final body = jsonDecode(res.body) as Map<String, dynamic>;
        final ok = body['success'] == true || body['symbols'] != null;
        if (ok && body['symbols'] is Map<String, dynamic>) {
          final m = (body['symbols'] as Map<String, dynamic>);
          return m.map((k, v) => MapEntry(k, (v['description'] as String? ?? k)));
        }
      }
    } catch (_) {/* fall through */}

    // frankfurter.app
    try {
      final res = await http
          .get(Uri.parse('$_frank/currencies'))
          .timeout(const Duration(seconds: 12));
      if (res.statusCode == 200) {
        final body = jsonDecode(res.body) as Map<String, dynamic>;
        // { "USD": "United States Dollar", ... }
        return body.map((k, v) => MapEntry(k, (v as String)));
      }
    } catch (_) {/* fall through */}

    // minimal fallback to keep UI usable
    return {
      'USD': 'United States Dollar',
      'EUR': 'Euro',
      'GBP': 'British Pound',
      'NGN': 'Nigerian Naira',
      'JPY': 'Japanese Yen',
    };
  }

  // ========== Providers (private) ==========

  Future<double?> _exchangerateHostConvert(String from, String to) async {
    try {
      final uri = Uri.parse('$_host/convert?from=$from&to=$to');
      final res =
          await http.get(uri).timeout(const Duration(seconds: 12));
      if (res.statusCode != 200) return null;
      final body = jsonDecode(res.body) as Map<String, dynamic>;
      // success flag can be false even with 200
      if (body['success'] == false) return null;

      // Preferred: info.rate
      final info = body['info'] as Map<String, dynamic>?;
      final rate = info?['rate'];
      if (rate is num) return rate.toDouble();

      // Some proxies return only "result" (amount) for amount=1
      final result = body['result'];
      if (result is num) return result.toDouble();

      return null;
    } catch (_) {
      return null;
    }
  }

  Future<double?> _exchangerateHostLatest(String from, String to) async {
    try {
      final uri =
          Uri.parse('$_host/latest?base=$from&symbols=$to');
      final res =
          await http.get(uri).timeout(const Duration(seconds: 12));
      if (res.statusCode != 200) return null;
      final body = jsonDecode(res.body) as Map<String, dynamic>;
      final rates = body['rates'];
      if (rates is Map && rates[to] is num) {
        return (rates[to] as num).toDouble();
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<double?> _frankfurterLatest(String from, String to) async {
    try {
      final uri =
          Uri.parse('$_frank/latest?from=$from&to=$to');
      final res =
          await http.get(uri).timeout(const Duration(seconds: 12));
      if (res.statusCode != 200) return null;
      final body = jsonDecode(res.body) as Map<String, dynamic>;
      final rates = body['rates'];
      if (rates is Map && rates[to] is num) {
        return (rates[to] as num).toDouble();
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<double?> _openErApiLatest(String from, String to) async {
    try {
      final uri = Uri.parse('$_erapi/latest/$from');
      final res =
          await http.get(uri).timeout(const Duration(seconds: 12));
      if (res.statusCode != 200) return null;
      final body = jsonDecode(res.body) as Map<String, dynamic>;
      if (body['result'] == 'success' &&
          body['rates'] is Map &&
          (body['rates'] as Map)[to] is num) {
        return ((body['rates'] as Map)[to] as num).toDouble();
      }
      return null;
    } catch (_) {
      return null;
    }
  }
}
