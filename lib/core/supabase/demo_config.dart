// lib/core/supabase/demo_config.dart
// Demo configuration for testing without actual Supabase setup

class DemoSupabaseConfig {
  // Demo Supabase project configuration
  // These are placeholder values for testing
  static const String supabaseUrl = 'https://demo-currensee.supabase.co';
  static const String supabaseAnonKey = 'demo-anon-key-for-testing';
  
  /// Check if we're in demo mode
  static bool get isDemoMode => 
      supabaseUrl.contains('demo') || 
      supabaseAnonKey.contains('demo');
  
  /// Get demo user profile
  static Map<String, dynamic> get demoUserProfile => {
    'uid': 'demo-user-123',
    'email': 'demo@currensee.com',
    'displayName': 'Demo User',
    'photoURL': null,
    'isEmailVerified': true,
    'createdAt': DateTime.now(),
  };
  
  /// Demo conversion history
  static List<Map<String, dynamic>> get demoConversionHistory => [
    {
      'id': '1',
      'from_currency': 'USD',
      'to_currency': 'NGN',
      'amount': 100.0,
      'rate': 850.0,
      'result': 85000.0,
      'timestamp': DateTime.now().subtract(const Duration(days: 1)),
    },
    {
      'id': '2',
      'from_currency': 'EUR',
      'to_currency': 'USD',
      'amount': 50.0,
      'rate': 1.08,
      'result': 54.0,
      'timestamp': DateTime.now().subtract(const Duration(hours: 5)),
    },
  ];
}
