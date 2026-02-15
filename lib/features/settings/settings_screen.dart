import 'package:flutter/material.dart';
import 'package:bingwa_hybrid/core/themes/app_theme.dart';
import 'package:bingwa_hybrid/core/widgets/app_drawer.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      drawer: const AppDrawer(),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Bernard', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          _buildSection('SIM Setup'),
          _buildOption('SIM to receive payments', 'SIM 1', () {}),
          _buildOption('Bingwa SIM (To run USSDs)', 'SIM 2', () {}),
          _buildOption('Send Auto-Replies Using', 'SIM 1', () {}),
        ],
      ),
    );
  }

  Widget _buildSection(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
    );
  }

  Widget _buildOption(String label, String value, VoidCallback onTap) {
    return ListTile(
      title: Text(label),
      trailing: Text(value, style: const TextStyle(color: AppTheme.primaryBlue)),
      onTap: onTap,
    );
  }
}