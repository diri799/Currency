// lib/features/auth/screens/login_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter/foundation.dart';

import '../../../core/auth/auth_providers.dart';
import '../../../core/theme/app_theme.dart';
import 'signup_screen.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signInWithEmail() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final authService = ref.read(authServiceProvider);
      await authService.signInWithEmail(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      // Navigation will be handled by auth state listener
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: CurrenSeeColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _signInWithGoogle() async {
    setState(() => _isLoading = true);
    try {
      final authService = ref.read(authServiceProvider);
      await authService.signInWithGoogle();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: CurrenSeeColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _signInWithApple() async {
    setState(() => _isLoading = true);
    try {
      final authService = ref.read(authServiceProvider);
      await authService.signInWithApple();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: CurrenSeeColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),
                
                // Logo and Title
                _buildHeader(),
                
                const SizedBox(height: 48),
                
                // Email Field
                _buildEmailField(),
                
                const SizedBox(height: 16),
                
                // Password Field
                _buildPasswordField(),
                
                const SizedBox(height: 8),
                
                // Forgot Password
                _buildForgotPassword(),
                
                const SizedBox(height: 24),
                
                // Sign In Button
                _buildSignInButton(),
                
                const SizedBox(height: 12),
                
                // Sign Up Button
                _buildSignUpButton(),
                
                const SizedBox(height: 24),
                
                // Divider
                _buildDivider(),
                
                const SizedBox(height: 24),
                
                // Social Sign In
                _buildSocialSignIn(),
                
                const SizedBox(height: 32),
                
                // Sign Up Link
                _buildSignUpLink(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        // App Logo
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            gradient: CurrenSeeColors.primaryGradient,
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Icon(
            Icons.currency_exchange,
            color: Colors.white,
            size: 40,
          ),
        ).animate().scale(duration: 600.ms, curve: Curves.elasticOut),
        
        const SizedBox(height: 24),
        
        // Title
        Text(
          'Welcome Back',
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: CurrenSeeColors.primary,
          ),
        ).animate().fadeIn(delay: 200.ms, duration: 600.ms),
        
        const SizedBox(height: 8),
        
        // Subtitle
        Text(
          'Sign in to continue with CurrenSee',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: CurrenSeeColors.textSecondary,
          ),
        ).animate().fadeIn(delay: 400.ms, duration: 600.ms),
      ],
    );
  }

  Widget _buildEmailField() {
    return TextFormField(
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
      decoration: const InputDecoration(
        labelText: 'Email',
        hintText: 'Enter your email',
        prefixIcon: Icon(Icons.email_outlined),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your email';
        }
        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
          return 'Please enter a valid email';
        }
        return null;
      },
    ).animate().slideX(delay: 600.ms, duration: 600.ms);
  }

  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordController,
      obscureText: _obscurePassword,
      textInputAction: TextInputAction.done,
      onFieldSubmitted: (_) => _signInWithEmail(),
      decoration: InputDecoration(
        labelText: 'Password',
        hintText: 'Enter your password',
        prefixIcon: const Icon(Icons.lock_outlined),
        suffixIcon: IconButton(
          icon: Icon(
            _obscurePassword ? Icons.visibility : Icons.visibility_off,
          ),
          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your password';
        }
        if (value.length < 6) {
          return 'Password must be at least 6 characters';
        }
        return null;
      },
    ).animate().slideX(delay: 800.ms, duration: 600.ms);
  }

  Widget _buildForgotPassword() {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: () => _showForgotPasswordDialog(),
        child: Text(
          'Forgot Password?',
          style: TextStyle(
            color: CurrenSeeColors.primary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    ).animate().fadeIn(delay: 1000.ms, duration: 600.ms);
  }

  Widget _buildSignInButton() {
    return FilledButton(
      onPressed: _isLoading ? null : _signInWithEmail,
      style: FilledButton.styleFrom(
        backgroundColor: CurrenSeeColors.primary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
      child: _isLoading
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : const Text(
              'Sign In',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
    ).animate().slideY(delay: 1200.ms, duration: 600.ms);
  }

  Widget _buildSignUpButton() {
    return OutlinedButton(
      onPressed: _isLoading ? null : () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const SignUpScreen()),
      ),
      style: OutlinedButton.styleFrom(
        foregroundColor: CurrenSeeColors.primary,
        side: const BorderSide(color: CurrenSeeColors.primary),
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
      child: Text(
        'Create Account',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          inherit: false,
        ),
      ),
    ).animate().fadeIn(delay: 1300.ms, duration: 600.ms);
  }

  Widget _buildDivider() {
    return Row(
      children: [
        const Expanded(child: Divider()),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'or',
            style: TextStyle(
              color: CurrenSeeColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const Expanded(child: Divider()),
      ],
    ).animate().fadeIn(delay: 1400.ms, duration: 600.ms);
  }

  Widget _buildSocialSignIn() {
    return Column(
      children: [
        // Google Sign In
        OutlinedButton.icon(
          onPressed: _isLoading ? null : _signInWithGoogle,
          icon: const Icon(Icons.g_mobiledata, size: 24),
          label: const Text('Continue with Google'),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            side: const BorderSide(color: CurrenSeeColors.divider),
          ),
        ),
        
        const SizedBox(height: 12),
        
        // Apple Sign In (only show on non-web platforms)
        if (!kIsWeb)
          OutlinedButton.icon(
            onPressed: _isLoading ? null : _signInWithApple,
            icon: const Icon(Icons.apple, size: 24),
            label: const Text('Continue with Apple'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              side: const BorderSide(color: CurrenSeeColors.divider),
            ),
          ),
      ],
    ).animate().slideY(delay: 1600.ms, duration: 600.ms);
  }

  Widget _buildSignUpLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Don't have an account? ",
          style: TextStyle(color: CurrenSeeColors.textSecondary),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const SignUpScreen()),
          ),
          child: Text(
            'Sign Up',
            style: TextStyle(
              color: CurrenSeeColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    ).animate().fadeIn(delay: 1800.ms, duration: 600.ms);
  }

  void _showForgotPasswordDialog() {
    final emailController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Enter your email address to receive a password reset link.'),
            const SizedBox(height: 16),
            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              if (emailController.text.isNotEmpty) {
                try {
                  final authService = ref.read(authServiceProvider);
                  await authService.sendPasswordResetEmail(emailController.text.trim());
                  if (mounted) {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Password reset email sent!'),
                        backgroundColor: CurrenSeeColors.success,
                      ),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(e.toString()),
                        backgroundColor: CurrenSeeColors.error,
                      ),
                    );
                  }
                }
              }
            },
            child: const Text('Send'),
          ),
        ],
      ),
    );
  }
}
