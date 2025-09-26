// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ⬇️ If you want top AppBar + bottom nav tabs, use the RootShell:
import 'features/shell/root_shell.dart';

// ⬇️ If you prefer to land directly on the conversion page, keep this import
// and set home: const ConversionScreen() instead of RootShell.
// import 'features/conversion/screens/conversion_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: CurrenSeeApp()));
}

class CurrenSeeApp extends StatelessWidget {
  const CurrenSeeApp({super.key});

  @override
  Widget build(BuildContext context) {
    const seed = Color(0xFF2A7BE4);

    return MaterialApp(
      title: 'App-CurrenSee',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: seed,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: seed,
        brightness: Brightness.dark,
      ),
      themeMode: ThemeMode.system,

      // ✅ Choose one:
      home: const RootShell(),           // AppBar + Bottom Navigation
      // home: const ConversionScreen(), // Direct to conversion page
    );
  }
}
