import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:bingwa_hybrid/core/themes/app_theme.dart';
import 'package:bingwa_hybrid/core/widgets/app_drawer.dart';
import 'package:bingwa_hybrid/features/auth/providers/auth_provider.dart';
import 'package:bingwa_hybrid/features/balance/providers/balance_provider.dart';
import 'package:bingwa_hybrid/features/offers/providers/offer_provider.dart'; // new import
import 'package:bingwa_hybrid/features/sms_listener/services/sms_listener_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedTabIndex = 0;
  final List<double> _weeklyCommission = [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0];
  final List<String> _weekDays = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
  SmsListenerService? _smsListener;

  @override
  void initState() {
    super.initState();
    debugPrint('🏠 Dashboard: initState');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      debugPrint('🏠 Dashboard: Post-frame callback');
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (authProvider.currentUser == null) {
        debugPrint('🏠 Dashboard: Fetching user profile');
        authProvider.fetchUserProfile();
      } else {
        debugPrint('🏠 Dashboard: User already loaded');
      }
      _initSmsListener();
    });
  }

  Future<void> _initSmsListener() async {
    // Ensure offers are loaded before starting the listener
    final offerProvider = Provider.of<OfferProvider>(context, listen: false);
    if (offerProvider.offers.isEmpty) {
      debugPrint('🏠 Dashboard: Offers not loaded, syncing now...');
      await offerProvider.syncOffers();
      debugPrint('🏠 Dashboard: Offers synced, count: ${offerProvider.offers.length}');
    } else {
      debugPrint('🏠 Dashboard: Offers already loaded, count: ${offerProvider.offers.length}');
    }

    _smsListener = SmsListenerService(context);
    final granted = await _smsListener!.requestPermissions();
    if (granted) {
      debugPrint('🏠 Dashboard: Permissions granted, starting listener');
      _smsListener!.startListening();
    } else {
      debugPrint('🏠 Dashboard: Permissions denied');
      _showPermissionDialog();
    }
  }

  @override
  void dispose() {
    debugPrint('🏠 Dashboard: Disposing, stopping SMS listener');
    _smsListener?.dispose();
    super.dispose();
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('SMS Permission Required'),
        content: const Text(
          'To automatically detect M-PESA payments, please grant SMS permission in settings.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              debugPrint('🏠 Dashboard: Opening app settings');
              Navigator.pop(ctx);
              await openAppSettings();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final balanceProvider = Provider.of<BalanceProvider>(context);
    final userName = authProvider.currentUser?.fullName.split(' ').first ?? 'User';

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${_getGreeting()}, $userName',
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTabs(),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Airtime Used Today',
                    'Ksh ${balanceProvider.airtimeUsedToday.toStringAsFixed(2)}',
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(
                    'Airtime Balance',
                    'Ksh ${balanceProvider.airtimeBalance.toStringAsFixed(2)}',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildChartSection(),
            const SizedBox(height: 24),
            _buildRecentTransactions(),
          ],
        ),
      ),
    );
  }

  Widget _buildTabs() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: [
          _buildTab('Successful', 0),
          _buildTab('Failed', 1),
          _buildTab('Expired Tokens', 2),
        ],
      ),
    );
  }

  Widget _buildTab(String label, int index) {
    final isSelected = _selectedTabIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedTabIndex = index;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.primaryBlue : Colors.transparent,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.black54,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildChartSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "This week's commission",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 4),
        Text(
          'Ksh. 0.00',
          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(7, (index) {
            return Column(
              children: [
                Container(
                  height: 80,
                  width: 20,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryBlue.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 8),
                Text(_weekDays[index], style: const TextStyle(fontSize: 12)),
              ],
            );
          }),
        ),
      ],
    );
  }

  Widget _buildRecentTransactions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Recent Transactions',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                children: [
                  Text('All'),
                  Icon(Icons.arrow_drop_down, size: 18),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Center(
            child: Text(
              'Your most recent transactions will appear here',
              style: TextStyle(color: Colors.grey),
            ),
          ),
        ),
      ],
    );
  }
}