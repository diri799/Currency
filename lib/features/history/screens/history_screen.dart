import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/theme/app_theme.dart';
import '../state/history_providers.dart';
import '../models/conversion_record.dart';

/// Modern History Screen with beautiful UI and export functionality
class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final records = ref.watch(historyProvider);
    final dateFmt = DateFormat('MMM dd, yyyy');
    final timeFmt = DateFormat('HH:mm');

    return Scaffold(
      body: records.isEmpty
          ? _buildEmptyState(context)
          : _buildHistoryList(context, ref, records, dateFmt, timeFmt),
      floatingActionButton: records.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: () => _showExportDialog(context, records),
              icon: const Icon(Icons.download),
              label: const Text('Export'),
              backgroundColor: CurrenSeeColors.primary,
              foregroundColor: Colors.white,
            ).animate().scale(delay: 200.ms, duration: 600.ms)
          : null,
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Empty State Icon
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: CurrenSeeColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(60),
              ),
              child: Icon(
                Icons.history,
                size: 60,
                color: CurrenSeeColors.primary.withOpacity(0.6),
              ),
            ).animate().scale(duration: 600.ms, curve: Curves.elasticOut),
            
            const SizedBox(height: 32),
            
            // Empty State Title
            Text(
              'No Conversion History',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: CurrenSeeColors.textPrimary,
              ),
            ).animate().fadeIn(delay: 200.ms, duration: 600.ms),
            
            const SizedBox(height: 16),
            
            // Empty State Description
            Text(
              'Your currency conversion history will appear here. Start converting currencies to see your past conversions.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: CurrenSeeColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ).animate().fadeIn(delay: 400.ms, duration: 600.ms),
            
            const SizedBox(height: 32),
            
            // Call to Action
            FilledButton.icon(
              onPressed: () {
                // Navigate to conversion screen
                // This would be handled by the parent navigation
              },
              icon: const Icon(Icons.swap_horiz),
              label: const Text('Start Converting'),
              style: FilledButton.styleFrom(
                backgroundColor: CurrenSeeColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
            ).animate().slideY(delay: 600.ms, duration: 600.ms),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryList(BuildContext context, WidgetRef ref, List<ConversionRecord> records, DateFormat dateFmt, DateFormat timeFmt) {
    return CustomScrollView(
      slivers: [
        // Header with Stats
        SliverToBoxAdapter(
          child: _buildHeader(context, records),
        ),
        
        // History List
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final record = records[index];
                final isFirstOfDate = index == 0 || 
                    !_isSameDate(record.timestamp, records[index - 1].timestamp);
                
                return Column(
                  children: [
                    if (isFirstOfDate) ...[
                      const SizedBox(height: 20),
                      _buildDateHeader(context, record.timestamp, dateFmt),
                      const SizedBox(height: 12),
                    ],
                    _ModernHistoryCard(
                      record: record,
                      timeFmt: timeFmt,
                      onTap: () => _showRecordDetails(context, record),
                      onDelete: () => _deleteRecord(context, ref, record),
                    ),
                    const SizedBox(height: 12),
                  ],
                );
              },
              childCount: records.length,
            ),
          ),
        ),
        
        // Bottom padding
        const SliverToBoxAdapter(
          child: SizedBox(height: 100),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context, List<ConversionRecord> records) {
    final totalConversions = records.length;
    final totalAmount = records.fold<double>(0, (sum, record) => sum + record.amount);
    final uniqueCurrencies = records.expand((r) => [r.from, r.to]).toSet().length;

    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: CurrenSeeColors.primaryGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: CurrenSeeColors.primary.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Conversion History',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ).animate().fadeIn(duration: 600.ms),
          
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  icon: Icons.swap_horiz,
                  value: totalConversions.toString(),
                  label: 'Conversions',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _StatCard(
                  icon: Icons.attach_money,
                  value: NumberFormat("#,##0").format(totalAmount),
                  label: 'Total Amount',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _StatCard(
                  icon: Icons.currency_exchange,
                  value: uniqueCurrencies.toString(),
                  label: 'Currencies',
                ),
              ),
            ],
          ).animate().slideY(delay: 200.ms, duration: 600.ms),
        ],
      ),
    );
  }

  Widget _buildDateHeader(BuildContext context, DateTime date, DateFormat dateFmt) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: CurrenSeeColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        dateFmt.format(date),
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
          color: CurrenSeeColors.primary,
        ),
      ),
    );
  }

  bool _isSameDate(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
           date1.month == date2.month &&
           date1.day == date2.day;
  }

  void _showRecordDetails(BuildContext context, ConversionRecord record) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _RecordDetailsSheet(record: record),
    );
  }

  void _deleteRecord(BuildContext context, WidgetRef ref, ConversionRecord record) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Conversion'),
        content: const Text('Are you sure you want to delete this conversion?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              // TODO: Implement delete functionality
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Delete functionality coming soon!'),
                  backgroundColor: CurrenSeeColors.info,
                ),
              );
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showExportDialog(BuildContext context, List<ConversionRecord> records) {
    showDialog(
                  context: context,
      builder: (context) => AlertDialog(
        title: const Text('Export History'),
        content: const Text('Choose export format:'),
                    actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _exportToCSV(context, records);
            },
            child: const Text('CSV'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              _exportToPDF(context, records);
            },
            child: const Text('PDF'),
          ),
        ],
      ),
    );
  }

  void _exportToCSV(BuildContext context, List<ConversionRecord> records) {
    // TODO: Implement CSV export
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('CSV export coming soon!'),
        backgroundColor: CurrenSeeColors.info,
      ),
    );
  }

  void _exportToPDF(BuildContext context, List<ConversionRecord> records) {
    // TODO: Implement PDF export
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('PDF export coming soon!'),
        backgroundColor: CurrenSeeColors.info,
      ),
    );
  }
}

/// Modern History Card with beautiful design
class _ModernHistoryCard extends StatelessWidget {
  final ConversionRecord record;
  final DateFormat timeFmt;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _ModernHistoryCard({
    required this.record,
    required this.timeFmt,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final nf = NumberFormat("#,##0.####");
    
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: CurrenSeeColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: CurrenSeeColors.divider),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Currency Exchange Icon
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: CurrenSeeColors.accentGradient,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.swap_horiz,
                color: Colors.white,
                size: 24,
              ),
            ),
            
            const SizedBox(width: 16),
            
            // Conversion Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Conversion Pair
                  Text(
                    '${record.from} → ${record.to}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: CurrenSeeColors.textPrimary,
                    ),
                  ),
                  
                  const SizedBox(height: 4),
                  
                  // Amount and Result
                  Text(
                    '${nf.format(record.amount)} ${record.from} = ${nf.format(record.result)} ${record.to}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: CurrenSeeColors.textSecondary,
                    ),
                  ),
                  
                  const SizedBox(height: 4),
                  
                  // Rate and Time
                  Row(
                    children: [
                      Text(
                        'Rate: ${nf.format(record.rate)}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: CurrenSeeColors.textSecondary,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        timeFmt.format(record.timestamp),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: CurrenSeeColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Delete Button
            IconButton(
              onPressed: onDelete,
              icon: Icon(
                Icons.delete_outline,
                color: CurrenSeeColors.textSecondary,
              ),
              tooltip: 'Delete',
            ),
          ],
        ),
      ),
    );
  }
}

/// Stat Card for displaying statistics
class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: Colors.white,
            size: 24,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.white.withOpacity(0.8),
            ),
            textAlign: TextAlign.center,
          ),
        ],
            ),
    );
  }
}

/// Record Details Bottom Sheet
class _RecordDetailsSheet extends StatelessWidget {
  final ConversionRecord record;

  const _RecordDetailsSheet({required this.record});

  @override
  Widget build(BuildContext context) {
    final nf = NumberFormat("#,##0.####");
    final dateFmt = DateFormat('MMM dd, yyyy');
    final timeFmt = DateFormat('HH:mm:ss');
    
    return Container(
      decoration: const BoxDecoration(
        color: CurrenSeeColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: CurrenSeeColors.divider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Title
            Text(
              'Conversion Details',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: CurrenSeeColors.primary,
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Details
            _DetailRow(
              label: 'From',
              value: '${nf.format(record.amount)} ${record.from}',
            ),
            
            _DetailRow(
              label: 'To',
              value: '${nf.format(record.result)} ${record.to}',
            ),
            
            _DetailRow(
              label: 'Exchange Rate',
              value: '1 ${record.from} = ${nf.format(record.rate)} ${record.to}',
            ),
            
            _DetailRow(
              label: 'Date',
              value: dateFmt.format(record.timestamp),
            ),
            
            _DetailRow(
              label: 'Time',
              value: timeFmt.format(record.timestamp),
            ),
            
            const SizedBox(height: 32),
            
            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.of(context).pop();
                      // TODO: Implement share functionality
                    },
                    icon: const Icon(Icons.share),
                    label: const Text('Share'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () {
                      Navigator.of(context).pop();
                      // TODO: Implement convert again functionality
                    },
                    icon: const Icon(Icons.swap_horiz),
                    label: const Text('Convert Again'),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

/// Detail Row Widget
class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: CurrenSeeColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: CurrenSeeColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
