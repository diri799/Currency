// lib/features/conversion/screens/conversion_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../state/conversion_providers.dart';
import 'currency_picker_screen.dart';

// History wiring
import '../../history/state/history_providers.dart';
import '../../history/models/conversion_record.dart';

/// NOTE:
/// This widget is designed to live inside the RootShell's Scaffold (with AppBar + BottomNav).
/// If you want to run it standalone, wrap it in a Scaffold where you use it.
class ConversionScreen extends ConsumerWidget {
  const ConversionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final base   = ref.watch(baseCurrencyProvider);
    final target = ref.watch(targetCurrencyProvider);
    final rate   = ref.watch(rateProvider);
    final value  = ref.watch(convertedValueProvider);
    final nf = NumberFormat("#,##0.####");

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(children: [
            Expanded(
              child: _CurrencyBox(
                label: 'From',
                code: base,
                onTap: () async {
                  final picked = await Navigator.of(context).push<String>(
                    MaterialPageRoute(
                      builder: (_) => const CurrencyPickerScreen(title: 'From currency'),
                    ),
                  );
                  if (picked != null && picked.isNotEmpty) {
                    ref.read(baseCurrencyProvider.notifier).state = picked;
                  }
                },
              ),
            ),
            const SizedBox(width: 12),
            IconButton(
              icon: const Icon(Icons.swap_horiz),
              tooltip: 'Swap',
              onPressed: () {
                final b = ref.read(baseCurrencyProvider);
                final t = ref.read(targetCurrencyProvider);
                ref.read(baseCurrencyProvider.notifier).state = t;
                ref.read(targetCurrencyProvider.notifier).state = b;
              },
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _CurrencyBox(
                label: 'To',
                code: target,
                onTap: () async {
                  final picked = await Navigator.of(context).push<String>(
                    MaterialPageRoute(
                      builder: (_) => const CurrencyPickerScreen(title: 'To currency'),
                    ),
                  );
                  if (picked != null && picked.isNotEmpty) {
                    ref.read(targetCurrencyProvider.notifier).state = picked;
                  }
                },
              ),
            ),
          ]),

          const SizedBox(height: 16),
          TextField(
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Amount',
              border: OutlineInputBorder(),
            ),
            onChanged: (s) =>
                ref.read(amountProvider.notifier).state = double.tryParse(s) ?? 0,
          ),

          const SizedBox(height: 24),
          rate.when(
            loading: () => const CircularProgressIndicator(),
            error: (e, _) => Text('Error fetching rate: $e'),
            data: (r) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Rate: 1 $base = ${nf.format(r)} $target',
                    style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 8),
                if (value != null)
                  Text('Converted: ${nf.format(value)} $target',
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
              ],
            ),
          ),

          const Spacer(),
          FilledButton(
            onPressed: () {
              final rateVal = ref.read(rateProvider).maybeWhen(
                data: (r) => r,
                orElse: () => null,
              );
              if (rateVal == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Rate not ready yet')),
                );
                return;
              }
              final amount = ref.read(amountProvider);
              final from = ref.read(baseCurrencyProvider);
              final to = ref.read(targetCurrencyProvider);

              final record = ConversionRecord(
                timestamp: DateTime.now(),
                from: from,
                to: to,
                amount: amount,
                rate: rateVal,
                result: amount * rateVal,
              );
              ref.read(historyProvider.notifier).addRecord(record);

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Saved to history')),
              );
            },
            child: const Text('Save to History'),
          ),
        ],
      ),
    );
  }
}

class _CurrencyBox extends StatelessWidget {
  final String label;
  final String code;
  final VoidCallback onTap;
  const _CurrencyBox({
    required this.label,
    required this.code,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
            const SizedBox(height: 4),
            Text(code, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}
