import 'package:flutter/material.dart';
import 'package:bingwa_hybrid/core/widgets/app_drawer.dart';

class AutoRenewalsScreen extends StatelessWidget {
  const AutoRenewalsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Auto Renewals'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              // Navigate to add auto-renewal (maybe reschedule screen)
            },
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.autorenew, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Looks like you don’t have any auto-renewals yet. Tap the + button to set one up',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }
}