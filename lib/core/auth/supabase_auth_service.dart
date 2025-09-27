// lib/core/auth/supabase_auth_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:flutter/foundation.dart';

import '../supabase/supabase_config.dart';
import '../supabase/demo_config.dart';

/// Supabase Authentication Service for CurrenSee
/// Handles email/password, Google, and Apple sign-in
class SupabaseAuthService {
  static final SupabaseAuthService _instance = SupabaseAuthService._internal();
  factory SupabaseAuthService() => _instance;
  SupabaseAuthService._internal();

  GoogleSignIn? _googleSignIn;
  
  GoogleSignIn get googleSignIn {
    _googleSignIn ??= GoogleSignIn();
    return _googleSignIn!;
  }

  /// Current user stream
  Stream<AuthState> get authStateChanges {
    if (SupabaseConfig.isDemoMode) {
      // Return a demo stream
      return Stream.value(AuthState(
        AuthChangeEvent.signedIn,
        null, // Demo mode doesn't use real sessions
      ));
    }
    return SupabaseConfig.auth.onAuthStateChange;
  }

  /// Current user
  User? get currentUser {
    if (SupabaseConfig.isDemoMode) {
      // Return demo user
      return User(
        id: DemoSupabaseConfig.demoUserProfile['uid'],
        appMetadata: {},
        userMetadata: {
          'full_name': DemoSupabaseConfig.demoUserProfile['displayName'],
        },
        aud: 'authenticated',
        createdAt: DateTime.now().toIso8601String(),
      );
    }
    return SupabaseConfig.auth.currentUser;
  }

  /// Check if user is signed in
  bool get isSignedIn => SupabaseConfig.isDemoMode ? true : currentUser != null;

  /// Sign up with email and password
  Future<AuthResponse> signUpWithEmail({
    required String email,
    required String password,
    String? fullName,
  }) async {
    if (SupabaseConfig.isDemoMode) {
      // Demo mode - simulate successful sign-up
      await Future.delayed(const Duration(seconds: 1));
      return AuthResponse(
        user: currentUser!,
        session: null,
      );
    }
    
    try {
      final response = await SupabaseConfig.auth.signUp(
        email: email,
        password: password,
        data: fullName != null ? {'full_name': fullName} : null,
      );
      
      // Log the response for debugging
      print('Sign up response: user=${response.user?.id}, session=${response.session?.accessToken != null ? "present" : "null"}');
      
      return response;
    } on AuthException catch (e) {
      print('Auth error during sign up: ${e.message}');
      throw _handleAuthException(e);
    } catch (e) {
      print('General error during sign up: $e');
      rethrow;
    }
  }

  /// Sign in with email and password
  Future<AuthResponse> signInWithEmail({
    required String email,
    required String password,
  }) async {
    if (SupabaseConfig.isDemoMode) {
      // Demo mode - simulate successful login
      await Future.delayed(const Duration(seconds: 1));
      return AuthResponse(
        user: currentUser!,
        session: null,
      );
    }
    
    try {
      final response = await SupabaseConfig.auth.signInWithPassword(
        email: email,
        password: password,
      );
      return response;
    } on AuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  /// Sign in with Google
  Future<AuthResponse> signInWithGoogle() async {
    if (SupabaseConfig.isDemoMode) {
      // Demo mode - simulate successful Google login
      await Future.delayed(const Duration(seconds: 1));
      return AuthResponse(
        user: currentUser!,
        session: null,
      );
    }
    
    try {
      // Configure Google Sign-In for web
      await googleSignIn.signOut(); // Clear any existing sessions
      
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        throw Exception('Google sign-in was cancelled');
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      if (googleAuth.idToken == null) {
        throw Exception('Failed to get Google ID token');
      }

      // Sign in to Supabase with the Google credential
      final response = await SupabaseConfig.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: googleAuth.idToken!,
        accessToken: googleAuth.accessToken,
      );

      return response;
    } catch (e) {
      throw Exception('Google sign-in failed: $e');
    }
  }

  /// Sign in with Apple
  Future<AuthResponse> signInWithApple() async {
    if (SupabaseConfig.isDemoMode) {
      // Demo mode - simulate successful Apple login
      await Future.delayed(const Duration(seconds: 1));
      return AuthResponse(
        user: currentUser!,
        session: null,
      );
    }
    
    try {
      // Check if Apple Sign-In is available (not available on web)
      if (kIsWeb) {
        throw Exception('Apple Sign-In is not available on web platform');
      }

      // Request Apple ID credential
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      if (appleCredential.identityToken == null) {
        throw Exception('Failed to get Apple ID token');
      }

      // Sign in to Supabase with Apple credential
      final response = await SupabaseConfig.auth.signInWithIdToken(
        provider: OAuthProvider.apple,
        idToken: appleCredential.identityToken!,
        accessToken: appleCredential.authorizationCode,
      );

      return response;
    } catch (e) {
      throw Exception('Apple sign-in failed: $e');
    }
  }

  /// Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await SupabaseConfig.auth.resetPasswordForEmail(email);
    } on AuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  /// Update user profile
  Future<void> updateProfile({
    String? fullName,
    String? avatarUrl,
  }) async {
    if (SupabaseConfig.isDemoMode) {
      // Demo mode - simulate successful profile update
      await Future.delayed(const Duration(milliseconds: 500));
      return;
    }
    
    try {
      final updates = <String, dynamic>{};
      if (fullName != null) updates['full_name'] = fullName;
      if (avatarUrl != null) updates['avatar_url'] = avatarUrl;

      await SupabaseConfig.auth.updateUser(
        UserAttributes(data: updates),
      );
    } on AuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  /// Sign out
  Future<void> signOut() async {
    if (SupabaseConfig.isDemoMode) {
      // Demo mode - simulate sign out
      await Future.delayed(const Duration(milliseconds: 500));
      return;
    }
    
    try {
      await Future.wait([
        SupabaseConfig.auth.signOut(),
        googleSignIn.signOut(),
      ]);
    } catch (e) {
      throw Exception('Sign out failed: $e');
    }
  }

  /// Delete user account
  Future<void> deleteAccount() async {
    try {
      // Delete user data from custom tables first
      await _deleteUserData();
      
      // Delete the auth user
      await SupabaseConfig.auth.admin.deleteUser(currentUser!.id);
    } catch (e) {
      throw Exception('Failed to delete account: $e');
    }
  }

  /// Delete user data from custom tables
  Future<void> _deleteUserData() async {
    if (currentUser == null) return;

    try {
      // Delete user data from all custom tables
      await Future.wait([
        SupabaseConfig.database.from(SupabaseTables.conversionHistory)
            .delete()
            .eq('user_id', currentUser!.id),
        SupabaseConfig.database.from(SupabaseTables.rateAlerts)
            .delete()
            .eq('user_id', currentUser!.id),
        SupabaseConfig.database.from(SupabaseTables.userPreferences)
            .delete()
            .eq('user_id', currentUser!.id),
        SupabaseConfig.database.from(SupabaseTables.users)
            .delete()
            .eq('id', currentUser!.id),
      ]);
    } catch (e) {
      // Log error but don't throw - user should still be able to delete account
      print('Error deleting user data: $e');
    }
  }

  /// Handle Supabase Auth exceptions
  String _handleAuthException(AuthException e) {
    switch (e.message) {
      case 'Invalid login credentials':
        return 'Invalid email or password.';
      case 'Email not confirmed':
        return 'Please check your email and confirm your account.';
      case 'User already registered':
        return 'An account with this email already exists.';
      case 'Password should be at least 6 characters':
        return 'Password must be at least 6 characters long.';
      case 'Invalid email':
        return 'Please enter a valid email address.';
      case 'Signup is disabled':
        return 'Account creation is currently disabled.';
      case 'Email rate limit exceeded':
        return 'Too many requests. Please try again later.';
      default:
        return 'Authentication failed: ${e.message}';
    }
  }
}
