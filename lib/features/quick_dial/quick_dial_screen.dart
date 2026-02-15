import 'package:flutter/material.dart';
import 'package:bingwa_hybrid/core/widgets/app_drawer.dart';

class QuickDialScreen extends StatelessWidget {
  const QuickDialScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quick Dial'),
      ),
      drawer: const AppDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              decoration: const InputDecoration(
                labelText: 'Customer Phone',
                hintText: 'Enter phone number',
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 20),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                children: const [
                  _OfferCard('1.5 GB - 3 Hrs'),
                  _OfferCard('350 MBS - 7 Days'),
                  _OfferCard('2.5GB - 7 Days'),
                  _OfferCard('6GB - 7 Days'),
                  _OfferCard('1GB - 1Hr'),
                  _OfferCard('250MBS - 24 Hrs'),
                  _OfferCard('1GB - 24 Hrs'),
                  _OfferCard('1.25GB - Until Midnight'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OfferCard extends StatelessWidget {
  final String title;
  const _OfferCard(this.title);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: () {
          // TODO: Trigger quick dial action
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Dial $title')),
          );
        },
        child: Center(child: Text(title, textAlign: TextAlign.center)),
      ),
    );
  }
}