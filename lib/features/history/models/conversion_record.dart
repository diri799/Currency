class ConversionRecord {
  final DateTime timestamp;
  final String from;
  final String to;
  final double amount;
  final double rate;   // 1 FROM = rate TO
  final double result; // amount * rate

  ConversionRecord({
    required this.timestamp,
    required this.from,
    required this.to,
    required this.amount,
    required this.rate,
    required this.result,
  });

  Map<String, dynamic> toJson() => {
    'ts': timestamp.toIso8601String(),
    'from': from,
    'to': to,
    'amount': amount,
    'rate': rate,
    'result': result,
  };

  factory ConversionRecord.fromJson(Map<String, dynamic> json) {
    return ConversionRecord(
      timestamp: DateTime.tryParse(json['ts'] as String? ?? '') ?? DateTime.now(),
      from: (json['from'] as String?) ?? 'USD',
      to: (json['to'] as String?) ?? 'NGN',
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      rate: (json['rate'] as num?)?.toDouble() ?? 0,
      result: (json['result'] as num?)?.toDouble() ?? 0,
    );
  }
}
