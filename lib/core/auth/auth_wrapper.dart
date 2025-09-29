// lib/core/auth/auth_wrapper.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';

import '../theme/app_theme.dart';
import '../widgets/currensee_logo.dart';
import 'auth_providers.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/shell/root_shell.dart';

/// Auth wrapper that handles authentication state
/// Shows login screen if not authenticated, main app if authenticated
class AuthWrapper extends ConsumerWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    switch (authState) {
      case AuthState.loading:
        return const _LoadingScreen();
      case AuthState.authenticated:
        return const RootShell();
      case AuthState.unauthenticated:
        return const LoginScreen();
      case AuthState.error:
        return const _ErrorScreen();
    }
  }
}

/// Loading screen with shimmer effect
class _LoadingScreen extends StatelessWidget {
  const _LoadingScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CurrenSeeColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 60),
              
              // Logo with shimmer
              Shimmer.fromColors(
                baseColor: CurrenSeeColors.divider,
                highlightColor: AppTheme.primaryLime.withOpacity(0.3),
                child: const CurrenSeeLogo(
                  size: 80,
                  showText: false,
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Title with shimmer
              Shimmer.fromColors(
                baseColor: CurrenSeeColors.divider,
                highlightColor: AppTheme.primaryLime.withOpacity(0.3),
                child: Container(
                  width: 200,
                  height: 32,
                  decoration: BoxDecoration(
                    color: CurrenSeeColors.divider,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Subtitle with shimmer
              Shimmer.fromColors(
                baseColor: CurrenSeeColors.divider,
                highlightColor: AppTheme.primaryLime.withOpacity(0.3),
                child: Container(
                  width: 150,
                  height: 20,
                  decoration: BoxDecoration(
                    color: CurrenSeeColors.divider,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              
              const Spacer(),
              
              // Loading indicator
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(CurrenSeeColors.primary),
              ),
              
              const SizedBox(height: 16),
              
              Text(
                'Loading CurrenSee...',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: CurrenSeeColors.textSecondary,
                ),
              ),
              
              const SizedBox(height: 60),
            ],
          ),
        ),
      ),
    );
  }
}

/// Error screen for authentication errors
class _ErrorScreen extends StatelessWidget {
  const _ErrorScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CurrenSeeColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Error icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: CurrenSeeColors.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  Icons.error_outline,
                  size: 40,
                  color: CurrenSeeColors.error,
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Error title
              Text(
                'Authentication Error',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: CurrenSeeColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 16),
              
              // Error message
              Text(
                'Something went wrong with authentication. Please try again.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: CurrenSeeColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 32),
              
              // Retry button
              FilledButton.icon(
                onPressed: () {
                  // Restart the app or refresh auth state
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => const AuthWrapper()),
                  );
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Try Again'),
                style: FilledButton.styleFrom(
                  backgroundColor: CurrenSeeColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
