import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/ussd_code_provider.dart';
import '../models/ussd_code.dart';
import 'add_edit_ussd_code_screen.dart';

class UssdCodesScreen extends StatefulWidget {
  final int offerId;
  final String offerName;

  const UssdCodesScreen({super.key, required this.offerId, required this.offerName});

  @override
  State<UssdCodesScreen> createState() => _UssdCodesScreenState();
}

class _UssdCodesScreenState extends State<UssdCodesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<UssdCodeProvider>(context, listen: false);
      provider.loadUssdCodes(widget.offerId);
      provider.loadPrimaryCode(widget.offerId);
      provider.loadStats(widget.offerId);
    });
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _confirmAndDelete(UssdCode code) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete USSD Code'),
        content: Text('Delete code "${code.ussdCode}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    final provider = Provider.of<UssdCodeProvider>(context, listen: false);
    final success = await provider.deleteUssdCode(widget.offerId, code.id);
    if (success) {
      _showSnackbar('Deleted');
    } else {
      _showSnackbar(provider.error ?? 'Delete failed');
    }
  }

  Future<void> _toggleStatus(UssdCode code) async {
    final provider = Provider.of<UssdCodeProvider>(context, listen: false);
    final success = await provider.toggleStatus(widget.offerId, code.id, !code.isActive);
    if (success) {
      _showSnackbar('Status updated');
    } else {
      _showSnackbar(provider.error ?? 'Failed');
    }
  }

  Future<void> _setPrimary(UssdCode code) async {
    final provider = Provider.of<UssdCodeProvider>(context, listen: false);
    final success = await provider.setPrimary(widget.offerId, code.id);
    if (success) {
      _showSnackbar('Primary code updated');
    } else {
      _showSnackbar(provider.error ?? 'Failed');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('USSD Codes - ${widget.offerName}'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddEditUssdCodeScreen(offerId: widget.offerId),
            ),
          );
          if (result == true) {
            Provider.of<UssdCodeProvider>(context, listen: false).loadUssdCodes(widget.offerId);
          }
        },
        child: const Icon(Icons.add),
      ),
      body: Consumer<UssdCodeProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.ussdCodes.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if (provider.error != null) {
            return Center(child: Text('Error: ${provider.error}'));
          }
          if (provider.ussdCodes.isEmpty) {
            return const Center(child: Text('No USSD codes for this offer.'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: provider.ussdCodes.length,
            itemBuilder: (context, index) {
              final code = provider.ussdCodes[index];
              final isPrimary = provider.primaryCode?.id == code.id;
              return Card(
                child: ListTile(
                  title: Text(code.ussdCode, style: const TextStyle(fontFamily: 'monospace')),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Priority: ${code.priority} | Active: ${code.isActive ? 'Yes' : 'No'}'),
                      if (isPrimary) const Text('⭐ Primary', style: TextStyle(color: Colors.amber)),
                    ],
                  ),
                  trailing: PopupMenuButton<String>(
                    onSelected: (value) async {
                      if (value == 'edit') {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AddEditUssdCodeScreen(
                              offerId: widget.offerId,
                              ussdCode: code,
                            ),
                          ),
                        );
                        if (result == true) {
                          provider.loadUssdCodes(widget.offerId);
                          provider.loadPrimaryCode(widget.offerId);
                        }
                      } else if (value == 'delete') {
                        await _confirmAndDelete(code);
                      } else if (value == 'toggle') {
                        await _toggleStatus(code);
                      } else if (value == 'set-primary') {
                        await _setPrimary(code);
                      } else if (value == 'record') {
                        final result = await provider.recordResult(
                          widget.offerId,
                          ussdCodeId: code.id,
                          success: true,
                          response: 'Test success',
                        );
                        if (result) _showSnackbar('Result recorded');
                      }
                    },
                    itemBuilder: (ctx) => [
                      const PopupMenuItem(value: 'edit', child: Text('Edit')),
                      if (!code.isActive)
                        const PopupMenuItem(value: 'toggle', child: Text('Activate'))
                      else
                        const PopupMenuItem(value: 'toggle', child: Text('Deactivate')),
                      if (!isPrimary && code.isActive)
                        const PopupMenuItem(value: 'set-primary', child: Text('Set as Primary')),
                      const PopupMenuItem(value: 'record', child: Text('Record Test Result')),
                      const PopupMenuItem(value: 'delete', child: Text('Delete')),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}