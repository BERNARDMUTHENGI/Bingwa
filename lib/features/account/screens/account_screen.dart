import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/themes/app_theme.dart';
import '../../auth/providers/auth_provider.dart';
import '../../auth/screens/login_screen.dart';
import 'change_password_screen.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  Future<void> _logout(BuildContext context, {bool all = false}) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = all ? await authProvider.logoutAll() : await authProvider.logout();
    if (success && context.mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    } else if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(authProvider.error ?? 'Logout failed')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;
    return Scaffold(
      appBar: AppBar(title: const Text('Account')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // User info card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Name: ${user?.fullName ?? 'N/A'}', style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 8),
                  Text('Email: ${user?.email ?? 'N/A'}', style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 8),
                  Text('Phone: ${user?.phone ?? 'N/A'}', style: const TextStyle(fontSize: 16)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Actions
          ListTile(
            leading: const Icon(Icons.lock, color: AppTheme.primaryBlue),
            title: const Text('Change Password'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ChangePasswordScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout, color: AppTheme.primaryBlue),
            title: const Text('Logout'),
            onTap: () => _logout(context),
          ),
          ListTile(
            leading: const Icon(Icons.logout, color: AppTheme.primaryBlue),
            title: const Text('Logout All Devices'),
            onTap: () => _logout(context, all: true),
          ),
          // Forgot Password
          ListTile(
            leading: const Icon(Icons.password, color: AppTheme.primaryBlue),
            title: const Text('Forgot Password'),
            onTap: () {
              // Navigate to forgot password screen – you can create a simple screen with email input
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Forgot password flow coming soon')),
              );
            },
          ),
          // Resend verification – currently disabled because emailVerified is not in the User model
          // If your backend returns an 'email_verified' field, you can add it to the User model and uncomment
          /*
          if (user?.emailVerified == false)
            ListTile(
              leading: const Icon(Icons.verified, color: AppTheme.primaryBlue),
              title: const Text('Resend Verification Email'),
              onTap: () async {
                final success = await authProvider.resendVerification();
                if (success && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Verification email sent')),
                  );
                }
              },
            ),
          */
        ],
      ),
    );
  }
}