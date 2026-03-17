import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bingwa_hybrid/core/themes/app_theme.dart';
import 'package:bingwa_hybrid/core/widgets/app_drawer.dart';
import 'package:bingwa_hybrid/features/configs/providers/config_provider.dart';
import 'package:bingwa_hybrid/features/configs/screens/business_config_screen.dart';
import 'package:bingwa_hybrid/features/configs/screens/display_config_screen.dart';
import 'package:bingwa_hybrid/features/configs/screens/security_config_screen.dart';
import 'package:bingwa_hybrid/features/configs/screens/ussd_config_screen.dart';
import 'package:bingwa_hybrid/features/configs/screens/notification_config_screen.dart';
import 'package:bingwa_hybrid/features/settings/screens/sim_settings_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<ConfigProvider>(context, listen: false);
      provider.loadBusinessConfig();
      provider.loadDisplayConfig();
      provider.loadSecurityConfig();
      provider.loadUssdConfig();
      provider.loadNotificationConfig();
      // You might also load device-specific config with device ID
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      drawer: const AppDrawer(),
      body: Consumer<ConfigProvider>(
        builder: (context, provider, child) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // User name from AuthProvider? We'll keep dummy for now
              const Text('Bernard', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),

              _buildSection('SIM Setup'),
              _buildOption(
                'SIM to receive payments',
                'SIM 1', // This should come from config
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SimSettingsScreen()),
                ),
              ),
              _buildOption(
                'Bingwa SIM (To run USSDs)',
                'SIM 2', // This should come from config
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SimSettingsScreen()),
                ),
              ),
              _buildOption(
                'Send Auto-Replies Using',
                'SIM 1', // This should come from config
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SimSettingsScreen()),
                ),
              ),

              const Divider(height: 32),

              _buildSection('Business Settings'),
              _buildOption(
                'Business Info',
                provider.businessConfig['business_name'] ?? 'Not set',
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const BusinessConfigScreen()),
                ),
              ),

              const Divider(height: 32),

              _buildSection('Display Settings'),
              _buildOption(
                'Theme / Language',
                '${provider.displayConfig['theme'] ?? 'light'}, ${provider.displayConfig['language'] ?? 'en'}',
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const DisplayConfigScreen()),
                ),
              ),

              const Divider(height: 32),

              _buildSection('Security'),
              _buildOption(
                'Security Settings',
                'PIN: ${provider.securityConfig['require_pin'] == true ? 'Required' : 'Not required'}',
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SecurityConfigScreen()),
                ),
              ),

              const Divider(height: 32),

              _buildSection('USSD Settings'),
              _buildOption(
                'USSD Configuration',
                'Timeout: ${provider.ussdConfig['timeout_seconds'] ?? 30}s',
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const UssdConfigScreen()),
                ),
              ),

              const Divider(height: 32),

              _buildSection('Notifications'),
              _buildOption(
                'Notification Settings',
                provider.notificationConfig['enabled'] == true ? 'Enabled' : 'Disabled',
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const NotificationConfigScreen()),
                ),
              ),
            ],
          );
        },
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