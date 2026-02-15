import 'package:flutter/material.dart';
import 'package:bingwa_hybrid/core/themes/app_theme.dart';

// Import all screens
import 'package:bingwa_hybrid/features/dashboard/dashboard_screen.dart';
import 'package:bingwa_hybrid/features/offers/offers_screen.dart';
import 'package:bingwa_hybrid/features/quick_dial/quick_dial_screen.dart';
import 'package:bingwa_hybrid/features/autorenewals/auto_renewals_screen.dart';
import 'package:bingwa_hybrid/features/site_link/site_link_screen.dart';
import 'package:bingwa_hybrid/features/subscriptions/subscriptions_screen.dart';
import 'package:bingwa_hybrid/features/autoreplies/autoreply_messages_screen.dart';
import 'package:bingwa_hybrid/features/hybridconnect/hybrid_connect_screen.dart';
import 'package:bingwa_hybrid/features/settings/settings_screen.dart';
import 'package:bingwa_hybrid/features/updates/check_updates_screen.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              color: AppTheme.primaryBlue,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: const [
                Text(
                  'Bingwa Hybrid',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Balance: sh. 0.00',
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                ),
              ],
            ),
          ),
          _buildDrawerItem(
            icon: Icons.home,
            label: 'Home',
            onTap: () => _navigateTo(context, const DashboardScreen()),
          ),
          _buildDrawerItem(
            icon: Icons.local_offer,
            label: 'Offers',
            onTap: () => _navigateTo(context, const OffersScreen()),
          ),
          _buildDrawerItem(
            icon: Icons.speed,
            label: 'Quick Dial',
            onTap: () => _navigateTo(context, const QuickDialScreen()),
          ),
          _buildDrawerItem(
            icon: Icons.autorenew,
            label: 'Auto Renewals',
            onTap: () => _navigateTo(context, const AutoRenewalsScreen()),
          ),
          _buildDrawerItem(
            icon: Icons.link,
            label: 'Site Link',
            onTap: () => _navigateTo(context, const SiteLinkScreen()),
          ),
          _buildDrawerItem(
            icon: Icons.subscriptions,
            label: 'Subscriptions',
            onTap: () => _navigateTo(context, const SubscriptionsScreen()),
          ),
          _buildDrawerItem(
            icon: Icons.message,
            label: 'AutoReplies',
            onTap: () => _navigateTo(context, const AutoReplyMessagesScreen()),
          ),
          _buildDrawerItem(
            icon: Icons.sync_alt,
            label: 'Hybrid Connect',
            onTap: () => _navigateTo(context, const HybridConnectScreen()),
          ),
          _buildDrawerItem(
            icon: Icons.settings,
            label: 'Settings',
            onTap: () => _navigateTo(context, const SettingsScreen()),
          ),
          _buildDrawerItem(
            icon: Icons.update,
            label: 'Check For Updates',
            onTap: () => _navigateTo(context, const CheckUpdatesScreen()),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.primaryBlue),
      title: Text(label),
      onTap: onTap,
    );
  }

  void _navigateTo(BuildContext context, Widget screen) {
    Navigator.pop(context); // Close drawer
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => screen),
    );
  }
}