import 'package:flutter/material.dart';
import 'package:bingwa_hybrid/core/widgets/app_drawer.dart';

class AutoReplyMessagesScreen extends StatelessWidget {
  const AutoReplyMessagesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AutoReply Messages'),
      ),
      drawer: const AppDrawer(),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          _MessageCard(
            title: 'Successful Response',
            content: 'Hi <firstName>, Thank you for purchasing from Bingwa Hybrid',
          ),
          _MessageCard(
            title: 'Offer Already Recommended',
            content: 'Hello <firstName>, you have already purchased this offer today. Please try a...',
          ),
          _MessageCard(
            title: 'Failed Request',
            content: 'Hello <firstName>, Your request failed. Please hold as we look into the issue',
          ),
          _MessageCard(
            title: 'Unavailable Offer',
            content: 'Hi <firstName>, there is no offer matching the amount you have paid. Pl...',
          ),
          _MessageCard(
            title: 'App Paused',
            content: 'Hi <firstName>, there is an issue affecting our systems. You will however...',
          ),
          _MessageCard(
            title: 'Customer Blacklisted',
            content: 'Hi <firstName>, there is an issue affecting your account. Please reach o...',
          ),
        ],
      ),
    );
  }
}

class _MessageCard extends StatelessWidget {
  final String title;
  final String content;
  const _MessageCard({required this.title, required this.content});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(content, style: const TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}