// lib/features/shell/root_shell.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../conversion/screens/conversion_screen.dart';
import '../history/screens/history_screen.dart';
import 'state/nav_providers.dart';

class _SettingsPage extends StatelessWidget {
  const _SettingsPage({super.key});
  @override
  Widget build(BuildContext context) =>
      const Center(child: Text('Settings (coming soon)'));
}

class RootShell extends ConsumerWidget {
  const RootShell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final idx = ref.watch(navIndexProvider);

    final pages = const [
      ConversionScreen(),
      HistoryScreen(),  // ← real history screen
      _SettingsPage(),
    ];

    final titles = const ['CurrenSee — Convert', 'CurrenSee — History', 'CurrenSee — Settings'];

    return Scaffold(
      appBar: AppBar(
        title: Text(titles[idx]),
        centerTitle: false,
      ),
      body: SafeArea(child: pages[idx]),
      bottomNavigationBar: NavigationBar(
        selectedIndex: idx,
        onDestinationSelected: (i) =>
            ref.read(navIndexProvider.notifier).state = i,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.swap_horiz), label: 'Convert'),
          NavigationDestination(icon: Icon(Icons.history), label: 'History'),
          NavigationDestination(icon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
    );
  }
}
