// lib/core/supabase/supabase_config.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import 'demo_config.dart';

/// Supabase configuration for CurrenSee app
class SupabaseConfig {
  // Supabase project configuration
  static const String supabaseUrl = 'https://rwwtfqvhlictoaafdbae.supabase.co';
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InJ3d3RmcXZobGljdG9hYWZkYmFlIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTg5NDMyODUsImV4cCI6MjA3NDUxOTI4NX0.P5vall4tjJQF10M5Cr_3N3QZOChRHRubTqj9r0DzMaA';
  
  /// Check if we're using demo configuration
  static bool get isDemoMode => 
      supabaseUrl == 'https://your-project.supabase.co' || 
      supabaseAnonKey == 'your-anon-key';
  
  /// Initialize Supabase
  static Future<void> initialize() async {
    if (isDemoMode) {
      print('Running in demo mode - Supabase not initialized');
      return;
    }
    
    try {
      print('Initializing Supabase with URL: $supabaseUrl');
      await Supabase.initialize(
        url: supabaseUrl,
        anonKey: supabaseAnonKey,
        authOptions: const FlutterAuthClientOptions(
          authFlowType: AuthFlowType.pkce,
        ),
        realtimeClientOptions: const RealtimeClientOptions(
          logLevel: RealtimeLogLevel.info,
        ),
      );
      print('Supabase initialized successfully');
    } catch (e) {
      print('Failed to initialize Supabase: $e');
      rethrow;
    }
  }
  
  /// Get Supabase client instance
  static SupabaseClient get client {
    if (isDemoMode) {
      throw Exception('Supabase not initialized in demo mode');
    }
    return Supabase.instance.client;
  }
  
  /// Get Auth instance
  static GoTrueClient get auth {
    if (isDemoMode) {
      throw Exception('Supabase not initialized in demo mode');
    }
    return Supabase.instance.client.auth;
  }
  
  /// Get Database instance
  static SupabaseClient get database {
    if (isDemoMode) {
      throw Exception('Supabase not initialized in demo mode');
    }
    return Supabase.instance.client;
  }
  
  /// Get Storage instance
  static SupabaseStorageClient get storage {
    if (isDemoMode) {
      throw Exception('Supabase not initialized in demo mode');
    }
    return Supabase.instance.client.storage;
  }
  
  /// Get Realtime instance
  static RealtimeClient get realtime {
    if (isDemoMode) {
      throw Exception('Supabase not initialized in demo mode');
    }
    return Supabase.instance.client.realtime;
  }
}

/// Supabase table names
class SupabaseTables {
  static const String users = 'users';
  static const String conversionHistory = 'conversion_history';
  static const String rateAlerts = 'rate_alerts';
  static const String userPreferences = 'user_preferences';
  static const String exchangeRates = 'exchange_rates';
}

/// Supabase storage buckets
class SupabaseBuckets {
  static const String userAvatars = 'user-avatars';
  static const String exports = 'exports';
}
