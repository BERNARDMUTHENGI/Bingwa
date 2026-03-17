import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bingwa_hybrid/core/themes/app_theme.dart';
import 'package:bingwa_hybrid/core/widgets/app_drawer.dart';
import 'package:bingwa_hybrid/features/plans/providers/plan_provider.dart';
import 'package:bingwa_hybrid/features/plans/models/plan.dart';
import 'package:bingwa_hybrid/features/subscriptions/providers/subscription_provider.dart';

class SubscriptionsScreen extends StatefulWidget {
  const SubscriptionsScreen({super.key});

  @override
  State<SubscriptionsScreen> createState() => _SubscriptionsScreenState();
}

class _SubscriptionsScreenState extends State<SubscriptionsScreen> {
  Plan? _selectedPlan;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<PlanProvider>(context, listen: false).loadPublicPlans();
      Provider.of<SubscriptionProvider>(context, listen: false).checkAccess();
      Provider.of<SubscriptionProvider>(context, listen: false).loadUsage();
    });
  }

  void _subscribe(Plan plan) {
    // For now, just show a dialog with confirmation
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Subscribe to ${plan.name}'),
        content: Text('Price: ${plan.currency} ${plan.price}\n\nProceed with payment?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              // Simulate payment – in real app you'd collect payment details
              final provider = Provider.of<SubscriptionProvider>(context, listen: false);
              final success = await provider.createSubscription(
                planId: plan.id,
                autoRenew: true,
                amountPaid: plan.price,
                currency: plan.currency,
                paymentRef: 'MPESA${DateTime.now().millisecondsSinceEpoch}',
                paymentMethod: 'mpesa',
                metadata: {
                  'source': 'mobile_app',
                  'customer_phone': '0712345678', // should come from user
                },
              );
              if (success && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Subscription activated!')),
                );
              } else if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(provider.error ?? 'Subscription failed')),
                );
              }
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final planProvider = Provider.of<PlanProvider>(context);
    final subProvider = Provider.of<SubscriptionProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Subscriptions'),
      ),
      drawer: const AppDrawer(),
      body: planProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        subProvider.hasAccess ? 'Active Subscription' : 'No Active Subscription',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryBlue,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Usage: ${subProvider.usage['used'] ?? 0}/${subProvider.usage['limit'] ?? '∞'}',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Available Plans',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView.builder(
                      itemCount: planProvider.publicPlans.length,
                      itemBuilder: (context, index) {
                        final plan = planProvider.publicPlans[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            title: Text(plan.name),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('${plan.currency} ${plan.price}'),
                                if (plan.description != null)
                                  Text(plan.description!, style: const TextStyle(fontSize: 12)),
                              ],
                            ),
                            trailing: ElevatedButton(
                              onPressed: () => _subscribe(plan),
                              child: const Text('Subscribe'),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}