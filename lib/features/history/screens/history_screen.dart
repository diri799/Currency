import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../state/history_providers.dart';
import '../models/conversion_record.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final records = ref.watch(historyProvider);
    final dateFmt = DateFormat('yyyy-MM-dd HH:mm');

    return Scaffold(
      appBar: AppBar(
        title: const Text('History'),
        actions: [
          if (records.isNotEmpty)
            IconButton(
              tooltip: 'Clear all',
              icon: const Icon(Icons.delete_outline),
              onPressed: () async {
                final ok = await showDialog<bool>(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text('Clear history?'),
                    content: const Text('This removes all saved conversions.'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                      FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Clear')),
                    ],
                  ),
                );
                if (ok == true) {
                  await ref.read(historyProvider.notifier).clear();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('History cleared')));
                  }
                }
              },
            ),
        ],
      ),
      body: records.isEmpty
          ? const Center(child: Text('No conversions yet.'))
          : ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: records.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (_, i) => _HistoryTile(record: records[i], dateFmt: dateFmt),
            ),
    );
  }
}

class _HistoryTile extends StatelessWidget {
  final ConversionRecord record;
  final DateFormat dateFmt;
  const _HistoryTile({required this.record, required this.dateFmt});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.receipt_long),
      title: Text('${record.amount} ${record.from} → ${record.result} ${record.to}',
          style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(
        '${dateFmt.format(record.timestamp)} · 1 ${record.from} = ${record.rate} ${record.to}',
      ),
    );
  }
}
