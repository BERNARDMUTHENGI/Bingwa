import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/transaction_provider.dart';
import 'request_detail_screen.dart';

class RequestsScreen extends StatefulWidget {
  const RequestsScreen({super.key});

  @override
  State<RequestsScreen> createState() => _RequestsScreenState();
}

class _RequestsScreenState extends State<RequestsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _tabs = ['All', 'Pending', 'Processing', 'Completed', 'Failed'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _tabController.addListener(_onTabChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCurrentTab();
      Provider.of<TransactionProvider>(context, listen: false).loadStats();
    });
  }

  void _onTabChanged() {
    if (!_tabController.indexIsChanging) {
      _loadCurrentTab();
    }
  }

  void _loadCurrentTab() {
    final provider = Provider.of<TransactionProvider>(context, listen: false);
    switch (_tabController.index) {
      case 0:
        provider.loadRequests();
        break;
      case 1:
        provider.loadPendingRequests();
        break;
      case 2:
        provider.loadProcessingRequests();
        break;
      case 3:
        provider.loadRequestsByStatus('completed');
        break;
      case 4:
        provider.loadFailedRequests();
        break;
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange.shade100;
      case 'processing':
        return Colors.blue.shade100;
      case 'completed':
        return Colors.green.shade100;
      case 'failed':
        return Colors.red.shade100;
      default:
        return Colors.grey.shade100;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaction Requests'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: Theme.of(context).primaryColor,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Theme.of(context).primaryColor,
          tabs: _tabs.map((tab) => Tab(text: tab)).toList(),
        ),
      ),
      body: Consumer<TransactionProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.requests.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if (provider.error != null) {
            return Center(child: Text('Error: ${provider.error}'));
          }
          if (provider.requests.isEmpty) {
            return const Center(child: Text('No requests'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: provider.requests.length,
            itemBuilder: (context, index) {
              final req = provider.requests[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  title: Text('${req.customerPhone} - ${req.currency} ${req.amountPaid}'),
                  subtitle: Text('Status: ${req.status}'),
                  trailing: Chip(
                    label: Text(req.status),
                    backgroundColor: _statusColor(req.status),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RequestDetailScreen(requestId: req.id),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}