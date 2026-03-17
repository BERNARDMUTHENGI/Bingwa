import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../auth/providers/auth_provider.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _currentController = TextEditingController();
  final _newController = TextEditingController();
  final _confirmController = TextEditingController();

  @override
  void dispose() {
    _currentController.dispose();
    _newController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _changePassword() async {
    if (!_formKey.currentState!.validate()) return;
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.changePassword(
      currentPassword: _currentController.text,
      newPassword: _newController.text,
    );
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password changed successfully')),
      );
      Navigator.pop(context);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(authProvider.error ?? 'Change failed')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Change Password')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _currentController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Current Password',
                  hintText: 'Enter current password',
                ),
                validator: (value) => value == null || value.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _newController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'New Password',
                  hintText: 'Enter new password (min 8 chars)',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Required';
                  if (value.length < 8) return 'At least 8 characters';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _confirmController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Confirm New Password',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Required';
                  if (value != _newController.text) return 'Passwords do not match';
                  return null;
                },
              ),
              const SizedBox(height: 32),
              if (authProvider.isLoading)
                const CircularProgressIndicator()
              else
                ElevatedButton(
                  onPressed: _changePassword,
                  child: const Text('Change Password'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}