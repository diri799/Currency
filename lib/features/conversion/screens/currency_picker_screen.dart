import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../state/conversion_providers.dart';

class CurrencyPickerScreen extends ConsumerStatefulWidget {
  const CurrencyPickerScreen({super.key, this.title = 'Select currency'});
  final String title;

  @override
  ConsumerState<CurrencyPickerScreen> createState() => _CurrencyPickerScreenState();
}

class _CurrencyPickerScreenState extends ConsumerState<CurrencyPickerScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final asyncSymbols = ref.watch(symbolsProvider);

    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: asyncSymbols.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Failed to load currencies: $e')),
        data: (symbols) {
          final entries = symbols.entries
              .where((e) {
                final q = _query.trim().toLowerCase();
                if (q.isEmpty) return true;
                return e.key.toLowerCase().contains(q) ||
                    (e.value.toLowerCase().contains(q));
              })
              .toList()
            ..sort((a, b) => a.key.compareTo(b.key));

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: TextField(
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                    labelText: 'Search code or name',
                  ),
                  onChanged: (v) => setState(() => _query = v),
                ),
              ),
              Expanded(
                child: ListView.separated(
                  itemCount: entries.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, i) {
                    final code = entries[i].key;
                    final name = entries[i].value;
                    return ListTile(
                      title: Text(code, style: const TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: Text(name),
                      onTap: () => Navigator.of(context).pop(code),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
