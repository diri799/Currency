// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:device_preview/device_preview.dart';
// Core
import 'core/theme/app_theme.dart';
import 'core/auth/auth_wrapper.dart';
import 'core/supabase/supabase_config.dart';
import 'core/notifications/notification_service.dart';

// ⬇️ If you prefer to land directly on the conversion page, keep this import
// and set home: const ConversionScreen() instead of RootShell.
// import 'features/conversion/screens/conversion_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    // Initialize Supabase
    print('Initializing Supabase...');
    await SupabaseConfig.initialize();
    print('Supabase initialized successfully');
    
    // Initialize notifications
    print('Initializing notifications...');
    await NotificationService().initialize();
    print('Notifications initialized successfully');
  } catch (e) {
    print('Error during initialization: $e');
    // Continue with app launch even if initialization fails
  }
  
  runApp(
    DevicePreview(
      enabled: true, // Set to false to disable device preview
      builder: (context) => const ProviderScope(child: CurrenSeeApp()),
    ),
  );
}

class CurrenSeeApp extends StatelessWidget {
  const CurrenSeeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CurrenSee',
      debugShowCheckedModeBanner: false,
      locale: DevicePreview.locale(context),
      builder: DevicePreview.appBuilder,
      
      // Modern Fintech Theme
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,

      // Auth Wrapper - handles login/main app
      home: const AuthWrapper(),
    );
  }
}
