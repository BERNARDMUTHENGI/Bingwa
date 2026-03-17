import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/schedule_provider.dart';

class SchedulesScreen extends StatefulWidget {
  const SchedulesScreen({super.key});

  @override
  State<SchedulesScreen> createState() => _SchedulesScreenState();
}

class _SchedulesScreenState extends State<SchedulesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ScheduleProvider>(context, listen: false).loadSchedules();
      Provider.of<ScheduleProvider>(context, listen: false).loadStats();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ScheduleProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Schedules'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to create schedule screen (to be implemented)
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Create schedule not implemented yet')),
          );
        },
        child: const Icon(Icons.add),
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: provider.schedules.length,
              itemBuilder: (context, index) {
                final schedule = provider.schedules[index];
                return Card(
                  child: ListTile(
                    title: Text('Offer ID: ${schedule.offerId}'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Customer: ${schedule.customerPhone}'),
                        Text('Scheduled: ${schedule.scheduledTime.toLocal()}'),
                        Text('Status: ${schedule.status}'),
                      ],
                    ),
                    trailing: PopupMenuButton<String>(
                      onSelected: (value) async {
                        // Implement actions (pause, resume, cancel)
                        if (value == 'pause') {
                          await provider.pauseSchedule(schedule.id);
                        } else if (value == 'resume') {
                          await provider.resumeSchedule(schedule.id);
                        } else if (value == 'cancel') {
                          await provider.cancelSchedule(schedule.id);
                        }
                      },
                      itemBuilder: (ctx) => [
                        if (schedule.status == 'active')
                          const PopupMenuItem(value: 'pause', child: Text('Pause')),
                        if (schedule.status == 'paused')
                          const PopupMenuItem(value: 'resume', child: Text('Resume')),
                        if (schedule.status != 'cancelled')
                          const PopupMenuItem(value: 'cancel', child: Text('Cancel')),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}