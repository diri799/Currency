// lib/core/auth/auth_providers.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:riverpod/riverpod.dart';
import 'supabase_auth_service.dart';

/// Auth service provider
final authServiceProvider = Provider<SupabaseAuthService>((ref) => SupabaseAuthService());

/// Current user provider
final currentUserProvider = StreamProvider<User?>((ref) {
  final authService = ref.watch(authServiceProvider);
  return authService.authStateChanges.map((authState) {
    // In demo mode, return the demo user when signed in
    if (authService.isSignedIn) {
      return authService.currentUser;
    }
    return authState.session?.user;
  });
});

/// Authentication state provider
final authStateProvider = Provider<AuthState>((ref) {
  final userAsync = ref.watch(currentUserProvider);
  return userAsync.when(
    data: (user) => user != null ? AuthState.authenticated : AuthState.unauthenticated,
    loading: () => AuthState.loading,
    error: (_, __) => AuthState.error,
  );
});

/// User profile provider
final userProfileProvider = Provider<UserProfile?>((ref) {
  final userAsync = ref.watch(currentUserProvider);
  return userAsync.when(
    data: (user) => user != null ? UserProfile.fromSupabaseUser(user) : null,
    loading: () => null,
    error: (_, __) => null,
  );
});

/// Authentication state enum
enum AuthState {
  loading,
  authenticated,
  unauthenticated,
  error,
}

/// User profile model
class UserProfile {
  final String uid;
  final String? email;
  final String? displayName;
  final String? photoURL;
  final bool isEmailVerified;
  final DateTime? createdAt;

  UserProfile({
    required this.uid,
    this.email,
    this.displayName,
    this.photoURL,
    required this.isEmailVerified,
    this.createdAt,
  });

  factory UserProfile.fromSupabaseUser(User user) {
    return UserProfile(
      uid: user.id,
      email: user.email,
      displayName: user.userMetadata?['full_name'] as String?,
      photoURL: user.userMetadata?['avatar_url'] as String?,
      isEmailVerified: user.emailConfirmedAt != null,
      createdAt: user.createdAt != null ? DateTime.parse(user.createdAt) : null,
    );
  }

  /// Get user initials for avatar
  String get initials {
    if (displayName != null && displayName!.isNotEmpty) {
      final names = displayName!.split(' ');
      if (names.length >= 2) {
        return '${names[0][0]}${names[1][0]}'.toUpperCase();
      }
      return names[0][0].toUpperCase();
    }
    if (email != null && email!.isNotEmpty) {
      return email![0].toUpperCase();
    }
    return 'U';
  }

  /// Get display name or email fallback
  String get displayNameOrEmail {
    return displayName ?? email ?? 'User';
  }
}
