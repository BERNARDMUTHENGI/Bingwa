import 'package:flutter/material.dart';
import 'package:bingwa_hybrid/core/widgets/app_drawer.dart';

class RescheduleOfferScreen extends StatefulWidget {
  const RescheduleOfferScreen({super.key});

  @override
  State<RescheduleOfferScreen> createState() => _RescheduleOfferScreenState();
}

class _RescheduleOfferScreenState extends State<RescheduleOfferScreen> {
  DateTime selectedDate = DateTime.now();
  bool autoRenew = false;
  int renewDays = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reschedule Offer'),
      ),
      drawer: const AppDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              decoration: const InputDecoration(
                labelText: 'Customer Phone',
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 20),
            const Text('Select Offer', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Expanded(
              child: ListView(
                children: [
                  _buildOfferItem('1.5 GB - 3 Hrs', '5:13 Hrs'),
                  _buildOfferItem('350 MBS - 7 Days', null),
                  _buildOfferItem('2.5GB - 7 Days', '___ Day(s)'),
                  _buildOfferItem('6GB - 7 Days', null),
                  _buildOfferItem('1GB - 1Hr', 'ule'),
                  _buildOfferItem('250MBS - 24 Hrs', null),
                  _buildOfferItem('1GB - 24 Hrs', null),
                  _buildOfferItem('1.25GB - Until Midnight', null),
                ],
              ),
            ),
            const Divider(),
            // Date and time selection (simplified)
            ListTile(
              title: Text('Select Date & Time'),
              subtitle: Text('${selectedDate.toLocal()}'.split(' ')[0]),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: selectedDate,
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (picked != null) {
                  setState(() => selectedDate = picked);
                }
              },
            ),
            Row(
              children: [
                Checkbox(
                  value: autoRenew,
                  onChanged: (val) => setState(() => autoRenew = val!),
                ),
                const Text('Auto-Renew'),
              ],
            ),
            if (autoRenew)
              Padding(
                padding: const EdgeInsets.only(left: 16),
                child: Row(
                  children: [
                    const Text('Renew daily for the next'),
                    const SizedBox(width: 8),
                    DropdownButton<int>(
                      value: renewDays,
                      items: List.generate(30, (i) => i + 1).map((e) {
                        return DropdownMenuItem(value: e, child: Text('$e'));
                      }).toList(),
                      onChanged: (val) => setState(() => renewDays = val!),
                    ),
                    const Text('Day(s)'),
                  ],
                ),
              ),
            const SizedBox(height: 16),
            Center(
              child: ElevatedButton(
                onPressed: () {},
                child: const Text('Schedule'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOfferItem(String title, String? trailing) {
    return ListTile(
      title: Text(title),
      trailing: trailing != null ? Text(trailing, style: const TextStyle(color: Colors.grey)) : null,
      onTap: () {
        // Select offer
      },
    );
  }
}