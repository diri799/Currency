// lib/features/shell/root_shell.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/auth/auth_providers.dart';
import '../conversion/screens/conversion_screen.dart';
import '../history/screens/history_screen.dart';
import 'state/nav_providers.dart';

/// Modern Settings Page with user profile and preferences
class _SettingsPage extends ConsumerWidget {
  const _SettingsPage();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userProfile = ref.watch(userProfileProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 20),
          
          // User Profile Section
          _buildUserProfile(context, ref, userProfile),
          
          const SizedBox(height: 32),
          
          // Settings Sections
          _buildSettingsSection(context, ref),
          
          const SizedBox(height: 32),
          
          // App Info Section
          _buildAppInfoSection(context),
          
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildUserProfile(BuildContext context, WidgetRef ref, UserProfile? userProfile) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: CurrenSeeColors.primaryGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: CurrenSeeColors.primary.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: userProfile != null
          ? _buildProfileContent(context, ref, userProfile)
          : _buildNoProfile(context),
    ).animate().scale(duration: 600.ms, curve: Curves.elasticOut);
  }

  Widget _buildProfileContent(BuildContext context, WidgetRef ref, UserProfile profile) {
    return Row(
      children: [
        // Avatar
        CircleAvatar(
          radius: 30,
          backgroundColor: Colors.white.withOpacity(0.2),
          child: profile.photoURL != null
              ? ClipOval(
                  child: Image.network(
                    profile.photoURL!,
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Text(
                      profile.initials,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                )
              : Text(
                  profile.initials,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
        ),
        
        const SizedBox(width: 16),
        
        // User Info
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                profile.displayNameOrEmail,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                profile.email ?? 'No email',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
            ],
          ),
        ),
        
        // Sign Out Button
        IconButton(
          onPressed: () => _showSignOutDialog(context, ref),
          icon: const Icon(Icons.logout, color: Colors.white),
          tooltip: 'Sign Out',
        ),
      ],
    );
  }

  Widget _buildNoProfile(BuildContext context) {
    return const Center(
      child: Text(
        'No user profile',
        style: TextStyle(color: Colors.white),
      ),
    );
  }

  Widget _buildLoadingProfile(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
      ),
    );
  }

  Widget _buildErrorProfile(BuildContext context) {
    return const Center(
      child: Text(
        'Error loading profile',
        style: TextStyle(color: Colors.white),
      ),
    );
  }

  Widget _buildSettingsSection(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Settings',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: CurrenSeeColors.primary,
          ),
        ),
        const SizedBox(height: 16),
        
        _SettingsCard(
          icon: Icons.notifications,
          title: 'Notifications',
          subtitle: 'Manage your notification preferences',
          onTap: () => _showNotificationsSettings(context),
        ),
        
        const SizedBox(height: 12),
        
        _SettingsCard(
          icon: Icons.palette,
          title: 'Theme',
          subtitle: 'Choose your preferred theme',
          onTap: () => _showThemeSettings(context),
        ),
        
        const SizedBox(height: 12),
        
        _SettingsCard(
          icon: Icons.language,
          title: 'Language',
          subtitle: 'Select your preferred language',
          onTap: () => _showLanguageSettings(context),
        ),
        
        const SizedBox(height: 12),
        
        _SettingsCard(
          icon: Icons.help,
          title: 'Help & Support',
          subtitle: 'Get help and contact support',
          onTap: () => _showHelpSupport(context),
        ),
      ],
    ).animate().slideY(delay: 200.ms, duration: 600.ms);
  }

  Widget _buildAppInfoSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'About',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: CurrenSeeColors.primary,
          ),
        ),
        const SizedBox(height: 16),
        
        _SettingsCard(
          icon: Icons.info,
          title: 'App Version',
          subtitle: '1.0.0',
          onTap: () {},
        ),
        
        const SizedBox(height: 12),
        
        _SettingsCard(
          icon: Icons.privacy_tip,
          title: 'Privacy Policy',
          subtitle: 'Read our privacy policy',
          onTap: () => _showPrivacyPolicy(context),
        ),
        
        const SizedBox(height: 12),
        
        _SettingsCard(
          icon: Icons.description,
          title: 'Terms of Service',
          subtitle: 'Read our terms of service',
          onTap: () => _showTermsOfService(context),
        ),
      ],
    ).animate().slideY(delay: 400.ms, duration: 600.ms);
  }

  void _showSignOutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await _performSignOut(context, ref);
            },
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }

  Future<void> _performSignOut(BuildContext context, WidgetRef ref) async {
    try {
      final authService = ref.read(authServiceProvider);
      await authService.signOut();
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Signed out successfully'),
            backgroundColor: CurrenSeeColors.success,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sign out failed: ${e.toString()}'),
            backgroundColor: CurrenSeeColors.error,
          ),
        );
      }
    }
  }

  void _showNotificationsSettings(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Notifications settings coming soon!')),
    );
  }

  void _showThemeSettings(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Theme settings coming soon!')),
    );
  }

  void _showLanguageSettings(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Language settings coming soon!')),
    );
  }

  void _showHelpSupport(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Help & Support coming soon!')),
    );
  }

  void _showPrivacyPolicy(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Privacy Policy coming soon!')),
    );
  }

  void _showTermsOfService(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Terms of Service coming soon!')),
    );
  }
}

/// Settings Card Widget
class _SettingsCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _SettingsCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: CurrenSeeColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: CurrenSeeColors.divider),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: CurrenSeeColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: CurrenSeeColors.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: CurrenSeeColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: CurrenSeeColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: CurrenSeeColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}

/// Modern Root Shell with enhanced navigation
class RootShell extends ConsumerWidget {
  const RootShell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final idx = ref.watch(navIndexProvider);
    final userProfile = ref.watch(userProfileProvider);

    final pages = const [
      ConversionScreen(),
      HistoryScreen(),
      _SettingsPage(),
    ];

    final titles = const [
      'Currency Converter',
      'Conversion History',
      'Settings',
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(titles[idx]),
        centerTitle: false,
        actions: [
          // User Avatar in AppBar
          userProfile != null
              ? Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: CircleAvatar(
                    radius: 16,
                    backgroundColor: CurrenSeeColors.primary.withOpacity(0.1),
                    child: userProfile.photoURL != null
                        ? ClipOval(
                            child: Image.network(
                              userProfile.photoURL!,
                              width: 32,
                              height: 32,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Text(
                                userProfile.initials,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: CurrenSeeColors.primary,
                                ),
                              ),
                            ),
                          )
                        : Text(
                            userProfile.initials,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: CurrenSeeColors.primary,
                            ),
                          ),
                  ),
                )
              : const SizedBox.shrink(),
        ],
      ),
      body: SafeArea(child: pages[idx]),
      bottomNavigationBar: NavigationBar(
        selectedIndex: idx,
        onDestinationSelected: (i) =>
            ref.read(navIndexProvider.notifier).state = i,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.swap_horiz),
            selectedIcon: Icon(Icons.swap_horiz),
            label: 'Convert',
          ),
          NavigationDestination(
            icon: Icon(Icons.history),
            selectedIcon: Icon(Icons.history),
            label: 'History',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings),
            selectedIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
