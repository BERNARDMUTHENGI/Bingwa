import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/admin_subscription_provider.dart';

class AdminSubscriptionsScreen extends StatefulWidget {
  const AdminSubscriptionsScreen({super.key});

  @override
  State<AdminSubscriptionsScreen> createState() => _AdminSubscriptionsScreenState();
}

class _AdminSubscriptionsScreenState extends State<AdminSubscriptionsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AdminSubscriptionProvider>(context, listen: false).loadAllSubscriptions();
      Provider.of<AdminSubscriptionProvider>(context, listen: false).loadStats();
    });
  }

  void _showActionDialog(String title, String content, Future<void> Function() action) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await action();
              setState(() {}); // refresh UI
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AdminSubscriptionProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Subscriptions'),
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                if (provider.stats.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Text('Total: ${provider.stats['total'] ?? 0}'),
                            Text('Active: ${provider.stats['active'] ?? 0}'),
                            Text('Expired: ${provider.stats['expired'] ?? 0}'),
                          ],
                        ),
                      ),
                    ),
                  ),
                Expanded(
                  child: ListView.builder(
                    itemCount: provider.subscriptions.length,
                    itemBuilder: (context, index) {
                      final sub = provider.subscriptions[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        child: ListTile(
                          title: Text('${sub.planName} - ${sub.status}'),
                          subtitle: Text('User: ${sub.metadata?['customer_phone'] ?? 'N/A'}'),
                          trailing: PopupMenuButton<String>(
                            onSelected: (value) {
                              switch (value) {
                                case 'deactivate':
                                  _showActionDialog(
                                    'Deactivate Subscription',
                                    'Deactivate subscription #${sub.id}?',
                                    () => provider.deactivateSubscription(sub.id),
                                  );
                                  break;
                                case 'suspend':
                                  _showActionDialog(
                                    'Suspend Subscription',
                                    'Suspend subscription #${sub.id}?',
                                    () => provider.suspendSubscription(sub.id),
                                  );
                                  break;
                                case 'reactivate':
                                  _showActionDialog(
                                    'Reactivate Subscription',
                                    'Reactivate subscription #${sub.id}?',
                                    () => provider.reactivateSubscription(sub.id),
                                  );
                                  break;
                                case 'cancel':
                                  _showActionDialog(
                                    'Cancel Subscription',
                                    'Cancel subscription #${sub.id}?',
                                    () => provider.cancelSubscription(sub.id),
                                  );
                                  break;
                              }
                            },
                            itemBuilder: (ctx) => [
                              const PopupMenuItem(value: 'deactivate', child: Text('Deactivate')),
                              const PopupMenuItem(value: 'suspend', child: Text('Suspend')),
                              const PopupMenuItem(value: 'reactivate', child: Text('Reactivate')),
                              const PopupMenuItem(value: 'cancel', child: Text('Cancel')),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}