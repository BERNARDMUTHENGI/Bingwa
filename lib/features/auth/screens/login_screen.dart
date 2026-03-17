import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/themes/app_theme.dart';
import '../providers/auth_provider.dart';
import '../providers/admin_auth_provider.dart'; // new
import '../../dashboard/dashboard_screen.dart';
import 'registration_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isAdmin = false; // new

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    if (_isAdmin) {
      // Admin login
      final adminAuthProvider = Provider.of<AdminAuthProvider>(context, listen: false);
      print('📱 Admin login started');
      final success = await adminAuthProvider.adminLogin(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        device: 'mobile-app',
      );
      print('📱 Admin login success: $success, mounted: $mounted');

      if (success && mounted) {
        print('📱 Navigating to Dashboard (admin)');
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const DashboardScreen()),
          (route) => false,
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(adminAuthProvider.error ?? 'Admin login failed')),
        );
      }
    } else {
      // Agent login
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      print('📱 Login started');
      final success = await authProvider.login(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        device: 'mobile-app',
      );
      print('📱 Login success: $success, mounted: $mounted');

      if (success && mounted) {
        print('📱 Navigating to Dashboard');
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const DashboardScreen()),
          (route) => false,
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(authProvider.error ?? 'Login failed')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final adminAuthProvider = Provider.of<AdminAuthProvider>(context);

    // Determine which provider's loading state to show
    final isLoading = _isAdmin ? adminAuthProvider.isLoading : authProvider.isLoading;

    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),
                const Text(
                  'Welcome Back!',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Enter your Email',
                    hintText: 'example@email.com',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Please enter your email';
                    if (!value.contains('@') || !value.contains('.')) {
                      return 'Enter a valid email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    hintText: 'Enter your password',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Please enter your password';
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                // Admin toggle
                Row(
                  children: [
                        Switch(
                          value: _isAdmin,
                          onChanged: (value) {
                            setState(() {
                              _isAdmin = value;
                            });
                          },
                        ),
                        const Text('Login as Admin'),
                  ],
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Forgot password coming soon')),
                      );
                    },
                    child: const Text(
                      'Forgot Password?',
                      style: TextStyle(color: AppTheme.primaryBlue),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                if (isLoading)
                  const Center(child: CircularProgressIndicator())
                else
                  ElevatedButton(
                    onPressed: _login,
                    child: const Text('Login'),
                  ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Don't have an account? "),
                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => const RegistrationScreen()),
                        );
                      },
                      child: const Text(
                        'Register',
                        style: TextStyle(
                          color: AppTheme.primaryBlue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}