import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/themes/app_theme.dart';
import '../providers/auth_provider.dart';
import 'login_screen.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final fullName = '${_firstNameController.text.trim()} ${_lastNameController.text.trim()}';
    print('📱 Registration started');
    final success = await authProvider.register(
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
      password: _passwordController.text,
      fullName: fullName,
      device: 'mobile-app',
    );
    print('📱 Registration success: $success, mounted: $mounted');

    if (success && mounted) {
      print('📱 Navigating to Login');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Registration successful! Please login.')),
      );
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(authProvider.error ?? 'Registration failed')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create an Account With Us')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Consumer<AuthProvider>(
              builder: (context, authProvider, child) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _firstNameController,
                            decoration: const InputDecoration(
                              labelText: 'First Name',
                              hintText: 'Enter first name',
                            ),
                            validator: (value) =>
                                value == null || value.isEmpty ? 'Please enter first name' : null,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _lastNameController,
                            decoration: const InputDecoration(
                              labelText: 'Last Name',
                              hintText: 'Enter last name',
                            ),
                            validator: (value) =>
                                value == null || value.isEmpty ? 'Please enter last name' : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: 'Phone Number',
                        hintText: 'Enter phone number',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Please enter phone number';
                        if (value.length < 10) return 'Enter a valid phone number';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        hintText: 'Enter email address',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Please enter email';
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
                        hintText: 'Enter password (min 8 chars, include number & special char)',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Please enter password';
                        if (value.length < 8) return 'Password must be at least 8 characters';
                        // Require at least one number
                        if (!value.contains(RegExp(r'[0-9]'))) {
                          return 'Password must contain at least one number';
                        }
                        // Require at least one special character
                        if (!value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
                          return 'Password must contain at least one special character';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _confirmPasswordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Confirm Password',
                        hintText: 'Re-enter password',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Please confirm password';
                        if (value != _passwordController.text) return 'Passwords do not match';
                        return null;
                      },
                    ),
                    const SizedBox(height: 32),
                    if (authProvider.isLoading)
                      const Center(child: CircularProgressIndicator())
                    else
                      ElevatedButton(
                        onPressed: _register,
                        child: const Text('Create Account'),
                      ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Already have an account? "),
                        TextButton(
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (context) => const LoginScreen()),
                            );
                          },
                          child: const Text(
                            'Login',
                            style: TextStyle(
                              color: AppTheme.primaryBlue,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}