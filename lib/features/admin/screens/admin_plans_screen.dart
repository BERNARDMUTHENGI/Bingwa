import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../plans/providers/plan_provider.dart';
import '../providers/admin_plan_provider.dart';

class AdminPlansScreen extends StatefulWidget {
  const AdminPlansScreen({super.key});

  @override
  State<AdminPlansScreen> createState() => _AdminPlansScreenState();
}

class _AdminPlansScreenState extends State<AdminPlansScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<PlanProvider>(context, listen: false).loadAllPlans(); // using agent provider to list all plans
      Provider.of<AdminPlanProvider>(context, listen: false).loadStats();
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
              // Refresh the list
              Provider.of<PlanProvider>(context, listen: false).loadAllPlans();
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
    final adminPlanProvider = Provider.of<AdminPlanProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Plans'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to create plan screen (to be implemented)
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Create plan not implemented yet')),
          );
        },
        child: const Icon(Icons.add),
      ),
      body: planProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                if (adminPlanProvider.stats.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text('Total Plans: ${adminPlanProvider.stats['total'] ?? 0}'),
                      ),
                    ),
                  ),
                Expanded(
                  child: ListView.builder(
                    itemCount: planProvider.allPlans.length,
                    itemBuilder: (context, index) {
                      final plan = planProvider.allPlans[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        child: ListTile(
                          title: Text('${plan.name} (${plan.planCode})'),
                          subtitle: Text('${plan.currency} ${plan.price} - ${plan.status}'),
                          trailing: PopupMenuButton<String>(
                            onSelected: (value) async {
                              switch (value) {
                                case 'activate':
                                  _showActionDialog(
                                    'Activate Plan',
                                    'Activate plan ${plan.name}?',
                                    () => adminPlanProvider.activatePlan(plan.id),
                                  );
                                  break;
                                case 'deactivate':
                                  _showActionDialog(
                                    'Deactivate Plan',
                                    'Deactivate plan ${plan.name}?',
                                    () => adminPlanProvider.deactivatePlan(plan.id),
                                  );
                                  break;
                                case 'delete':
                                  _showActionDialog(
                                    'Delete Plan',
                                    'Delete plan ${plan.name}?',
                                    () => adminPlanProvider.deletePlan(plan.id),
                                  );
                                  break;
                              }
                            },
                            itemBuilder: (ctx) => [
                              const PopupMenuItem(value: 'activate', child: Text('Activate')),
                              const PopupMenuItem(value: 'deactivate', child: Text('Deactivate')),
                              const PopupMenuItem(value: 'delete', child: Text('Delete')),
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