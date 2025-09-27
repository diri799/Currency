// lib/features/auth/screens/signup_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/auth/auth_providers.dart';
import '../../../core/theme/app_theme.dart';

class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _agreeToTerms = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _signUpWithEmail() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_agreeToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please agree to the Terms and Conditions'),
          backgroundColor: CurrenSeeColors.error,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final authService = ref.read(authServiceProvider);
      final response = await authService.signUpWithEmail(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        fullName: _nameController.text.trim(),
      );
      
      if (response.user != null) {
        // Check if email confirmation is required
        if (response.session == null) {
          // Email confirmation required
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Please check your email to confirm your account before signing in.'),
                backgroundColor: CurrenSeeColors.primary,
                duration: Duration(seconds: 5),
              ),
            );
            Navigator.of(context).pop(); // Go back to login screen
          }
        } else {
          // User is automatically signed in
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Account created and signed in successfully!'),
                backgroundColor: CurrenSeeColors.success,
              ),
            );
            Navigator.of(context).pop(); // Go back to login screen
          }
        }
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
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _signInWithGoogle() async {
    setState(() => _isLoading = true);
    try {
      final authService = ref.read(authServiceProvider);
      await authService.signInWithGoogle();
      if (mounted) Navigator.of(context).pop();
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
      if (mounted) Navigator.of(context).pop();
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
      appBar: AppBar(
        title: const Text('Create Account'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),
                
                // Header
                _buildHeader(),
                
                const SizedBox(height: 32),
                
                // Name Field
                _buildNameField(),
                
                const SizedBox(height: 16),
                
                // Email Field
                _buildEmailField(),
                
                const SizedBox(height: 16),
                
                // Password Field
                _buildPasswordField(),
                
                const SizedBox(height: 16),
                
                // Confirm Password Field
                _buildConfirmPasswordField(),
                
                const SizedBox(height: 16),
                
                // Terms and Conditions
                _buildTermsCheckbox(),
                
                const SizedBox(height: 24),
                
                // Sign Up Button
                _buildSignUpButton(),
                
                const SizedBox(height: 24),
                
                // Divider
                _buildDivider(),
                
                const SizedBox(height: 24),
                
                // Social Sign Up
                _buildSocialSignUp(),
                
                const SizedBox(height: 32),
                
                // Sign In Link
                _buildSignInLink(),
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
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            gradient: CurrenSeeColors.primaryGradient,
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(
            Icons.currency_exchange,
            color: Colors.white,
            size: 30,
          ),
        ).animate().scale(duration: 600.ms, curve: Curves.elasticOut),
        
        const SizedBox(height: 16),
        
        // Title
        Text(
          'Create Account',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: CurrenSeeColors.primary,
          ),
        ).animate().fadeIn(delay: 200.ms, duration: 600.ms),
        
        const SizedBox(height: 8),
        
        // Subtitle
        Text(
          'Join CurrenSee and start converting currencies',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: CurrenSeeColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ).animate().fadeIn(delay: 400.ms, duration: 600.ms),
      ],
    );
  }

  Widget _buildNameField() {
    return TextFormField(
      controller: _nameController,
      textInputAction: TextInputAction.next,
      decoration: const InputDecoration(
        labelText: 'Full Name',
        hintText: 'Enter your full name',
        prefixIcon: Icon(Icons.person_outlined),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your full name';
        }
        if (value.length < 2) {
          return 'Name must be at least 2 characters';
        }
        return null;
      },
    ).animate().slideX(delay: 600.ms, duration: 600.ms);
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
    ).animate().slideX(delay: 800.ms, duration: 600.ms);
  }

  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordController,
      obscureText: _obscurePassword,
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        labelText: 'Password',
        hintText: 'Create a password',
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
          return 'Please enter a password';
        }
        if (value.length < 6) {
          return 'Password must be at least 6 characters';
        }
        return null;
      },
    ).animate().slideX(delay: 1000.ms, duration: 600.ms);
  }

  Widget _buildConfirmPasswordField() {
    return TextFormField(
      controller: _confirmPasswordController,
      obscureText: _obscureConfirmPassword,
      textInputAction: TextInputAction.done,
      onFieldSubmitted: (_) => _signUpWithEmail(),
      decoration: InputDecoration(
        labelText: 'Confirm Password',
        hintText: 'Confirm your password',
        prefixIcon: const Icon(Icons.lock_outlined),
        suffixIcon: IconButton(
          icon: Icon(
            _obscureConfirmPassword ? Icons.visibility : Icons.visibility_off,
          ),
          onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please confirm your password';
        }
        if (value != _passwordController.text) {
          return 'Passwords do not match';
        }
        return null;
      },
    ).animate().slideX(delay: 1200.ms, duration: 600.ms);
  }

  Widget _buildTermsCheckbox() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Checkbox(
          value: _agreeToTerms,
          onChanged: (value) => setState(() => _agreeToTerms = value ?? false),
          activeColor: CurrenSeeColors.primary,
        ),
        Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _agreeToTerms = !_agreeToTerms),
            child: RichText(
              text: TextSpan(
                style: Theme.of(context).textTheme.bodySmall,
                children: [
                  const TextSpan(text: 'I agree to the '),
                  TextSpan(
                    text: 'Terms and Conditions',
                    style: TextStyle(
                      color: CurrenSeeColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const TextSpan(text: ' and '),
                  TextSpan(
                    text: 'Privacy Policy',
                    style: TextStyle(
                      color: CurrenSeeColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    ).animate().fadeIn(delay: 1400.ms, duration: 600.ms);
  }

  Widget _buildSignUpButton() {
    return FilledButton(
      onPressed: _isLoading ? null : _signUpWithEmail,
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
              'Create Account',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
    ).animate().slideY(delay: 1600.ms, duration: 600.ms);
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
    ).animate().fadeIn(delay: 1800.ms, duration: 600.ms);
  }

  Widget _buildSocialSignUp() {
    return Column(
      children: [
        // Google Sign Up
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
        
        // Apple Sign Up
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
    ).animate().slideY(delay: 2000.ms, duration: 600.ms);
  }

  Widget _buildSignInLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Already have an account? ',
          style: TextStyle(color: CurrenSeeColors.textSecondary),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            'Sign In',
            style: TextStyle(
              color: CurrenSeeColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    ).animate().fadeIn(delay: 2200.ms, duration: 600.ms);
  }
}
