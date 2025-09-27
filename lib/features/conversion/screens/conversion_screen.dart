// lib/features/conversion/screens/conversion_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shimmer/shimmer.dart';

import '../../../core/theme/app_theme.dart';
import '../state/conversion_providers.dart';
import 'currency_picker_screen.dart';

// History wiring
import '../../history/state/history_providers.dart';
import '../../history/models/conversion_record.dart';

/// Modern Currency Conversion Screen
/// Hero feature with beautiful UI and real-time updates
class ConversionScreen extends ConsumerWidget {
  const ConversionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final base = ref.watch(baseCurrencyProvider);
    final target = ref.watch(targetCurrencyProvider);
    final rate = ref.watch(rateProvider);
    final value = ref.watch(convertedValueProvider);
    final amount = ref.watch(amountProvider);
    final nf = NumberFormat("#,##0.####");

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 20),
          
          // Header Section
          _buildHeader(context),
          
          const SizedBox(height: 32),
          
          // Currency Selection Cards
          _buildCurrencySelection(context, ref, base, target),
          
          const SizedBox(height: 24),
          
          // Amount Input
          _buildAmountInput(context, ref, amount),
          
          const SizedBox(height: 32),
          
          // Conversion Result
          _buildConversionResult(context, rate, value, base, target, nf),
          
          const SizedBox(height: 32),
          
          // Action Buttons
          _buildActionButtons(context, ref, rate, amount, base, target),
          
          const SizedBox(height: 24),
          
          // Quick Actions
          _buildQuickActions(context, ref),
          
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Currency Converter',
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: CurrenSeeColors.primary,
          ),
        ).animate().fadeIn(duration: 600.ms),
        
        const SizedBox(height: 8),
        
        Text(
          'Convert currencies with real-time exchange rates',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: CurrenSeeColors.textSecondary,
          ),
        ).animate().fadeIn(delay: 200.ms, duration: 600.ms),
      ],
    );
  }

  Widget _buildCurrencySelection(BuildContext context, WidgetRef ref, String base, String target) {
    return Row(
      children: [
        // From Currency
        Expanded(
          child: _ModernCurrencyCard(
            label: 'From',
            code: base,
            onTap: () async {
              final picked = await Navigator.of(context).push<String>(
                MaterialPageRoute(
                  builder: (_) => const CurrencyPickerScreen(title: 'Select Base Currency'),
                ),
              );
              if (picked != null && picked.isNotEmpty) {
                ref.read(baseCurrencyProvider.notifier).state = picked;
              }
            },
          ),
        ),
        
        const SizedBox(width: 16),
        
        // Swap Button
        Container(
          decoration: BoxDecoration(
            color: CurrenSeeColors.primary,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: CurrenSeeColors.primary.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: IconButton(
            icon: const Icon(Icons.swap_horiz, color: Colors.white),
            onPressed: () {
              final b = ref.read(baseCurrencyProvider);
              final t = ref.read(targetCurrencyProvider);
              ref.read(baseCurrencyProvider.notifier).state = t;
              ref.read(targetCurrencyProvider.notifier).state = b;
            },
          ),
        ).animate().scale(delay: 400.ms, duration: 600.ms),
        
        const SizedBox(width: 16),
        
        // To Currency
        Expanded(
          child: _ModernCurrencyCard(
            label: 'To',
            code: target,
            onTap: () async {
              final picked = await Navigator.of(context).push<String>(
                MaterialPageRoute(
                  builder: (_) => const CurrencyPickerScreen(title: 'Select Target Currency'),
                ),
              );
              if (picked != null && picked.isNotEmpty) {
                ref.read(targetCurrencyProvider.notifier).state = picked;
              }
            },
          ),
        ),
      ],
    ).animate().slideY(delay: 600.ms, duration: 600.ms);
  }

  Widget _buildAmountInput(BuildContext context, WidgetRef ref, double amount) {
    return Container(
      decoration: BoxDecoration(
        color: CurrenSeeColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
          fontWeight: FontWeight.w600,
          color: CurrenSeeColors.primary,
        ),
        decoration: InputDecoration(
          labelText: 'Amount',
          hintText: 'Enter amount to convert',
          prefixIcon: const Icon(Icons.attach_money, color: CurrenSeeColors.primary),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(20),
        ),
        onChanged: (s) => ref.read(amountProvider.notifier).state = double.tryParse(s) ?? 0,
      ),
    ).animate().slideY(delay: 800.ms, duration: 600.ms);
  }

  Widget _buildConversionResult(BuildContext context, AsyncValue<double> rate, double? value, String base, String target, NumberFormat nf) {
    return Container(
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
      child: rate.when(
        loading: () => _buildLoadingResult(context),
        error: (e, _) => _buildErrorResult(context, e.toString()),
        data: (r) => _buildSuccessResult(context, r, value, base, target, nf),
      ),
    ).animate().scale(delay: 1000.ms, duration: 600.ms, curve: Curves.elasticOut);
  }

  Widget _buildLoadingResult(BuildContext context) {
    return Column(
      children: [
        Shimmer.fromColors(
          baseColor: Colors.white.withOpacity(0.3),
          highlightColor: Colors.white.withOpacity(0.6),
          child: Container(
            height: 24,
            width: 200,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Shimmer.fromColors(
          baseColor: Colors.white.withOpacity(0.3),
          highlightColor: Colors.white.withOpacity(0.6),
          child: Container(
            height: 32,
            width: 150,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorResult(BuildContext context, String error) {
    return Column(
      children: [
        const Icon(Icons.error_outline, color: Colors.white, size: 32),
        const SizedBox(height: 12),
        Text(
          'Unable to fetch rate',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          error,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Colors.white.withOpacity(0.8),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildSuccessResult(BuildContext context, double rate, double? value, String base, String target, NumberFormat nf) {
    return Column(
      children: [
        Text(
          'Exchange Rate',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: Colors.white.withOpacity(0.9),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '1 $base = ${nf.format(rate)} $target',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        if (value != null) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${nf.format(value)} $target',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context, WidgetRef ref, AsyncValue<double> rate, double amount, String base, String target) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => _saveToHistory(context, ref, rate, amount, base, target),
            icon: const Icon(Icons.history),
            label: const Text('Save to History'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              side: const BorderSide(color: CurrenSeeColors.primary),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: FilledButton.icon(
            onPressed: () => _shareConversion(context, rate, amount, base, target),
            icon: const Icon(Icons.share),
            label: const Text('Share'),
            style: FilledButton.styleFrom(
              backgroundColor: CurrenSeeColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
      ],
    ).animate().slideY(delay: 1200.ms, duration: 600.ms);
  }

  Widget _buildQuickActions(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: CurrenSeeColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _QuickActionCard(
                icon: Icons.trending_up,
                title: 'Rate Alert',
                subtitle: 'Set price alerts',
                onTap: () => _showRateAlertDialog(context, ref),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _QuickActionCard(
                icon: Icons.analytics,
                title: 'Charts',
                subtitle: 'View trends',
                onTap: () => _showChartsDialog(context, ref),
              ),
            ),
          ],
        ),
      ],
    ).animate().slideY(delay: 1400.ms, duration: 600.ms);
  }

  void _saveToHistory(BuildContext context, WidgetRef ref, AsyncValue<double> rate, double amount, String base, String target) {
    final rateVal = rate.maybeWhen(data: (r) => r, orElse: () => null);
    if (rateVal == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Rate not ready yet'),
          backgroundColor: CurrenSeeColors.error,
        ),
      );
      return;
    }

    final record = ConversionRecord(
      timestamp: DateTime.now(),
      from: base,
      to: target,
      amount: amount,
      rate: rateVal,
      result: amount * rateVal,
    );
    ref.read(historyProvider.notifier).addRecord(record);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Saved to history'),
        backgroundColor: CurrenSeeColors.success,
      ),
    );
  }

  void _shareConversion(BuildContext context, AsyncValue<double> rate, double amount, String base, String target) {
    final rateVal = rate.maybeWhen(data: (r) => r, orElse: () => null);
    if (rateVal == null) return;

    final convertedValue = amount * rateVal;
    final nf = NumberFormat("#,##0.####");
    
    // TODO: Implement sharing functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${nf.format(amount)} $base = ${nf.format(convertedValue)} $target'),
        backgroundColor: CurrenSeeColors.info,
      ),
    );
  }

  void _showRateAlertDialog(BuildContext context, WidgetRef ref) {
    // TODO: Implement rate alert dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Rate alerts coming soon!'),
        backgroundColor: CurrenSeeColors.info,
      ),
    );
  }

  void _showChartsDialog(BuildContext context, WidgetRef ref) {
    // TODO: Implement charts dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Charts coming soon!'),
        backgroundColor: CurrenSeeColors.info,
      ),
    );
  }
}

/// Modern Currency Card with beautiful design
class _ModernCurrencyCard extends StatelessWidget {
  final String label;
  final String code;
  final VoidCallback onTap;

  const _ModernCurrencyCard({
    required this.label,
    required this.code,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: CurrenSeeColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: CurrenSeeColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.currency_exchange,
                    color: CurrenSeeColors.primary,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    code,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: CurrenSeeColors.primary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.keyboard_arrow_down,
                  color: CurrenSeeColors.textSecondary,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Quick Action Card for additional features
class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: CurrenSeeColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: CurrenSeeColors.divider),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: CurrenSeeColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: CurrenSeeColors.primary,
                size: 20,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: CurrenSeeColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: CurrenSeeColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
