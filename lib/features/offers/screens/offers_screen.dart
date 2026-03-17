import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bingwa_hybrid/core/themes/app_theme.dart';
import 'package:bingwa_hybrid/core/widgets/app_drawer.dart';
import 'package:bingwa_hybrid/features/offers/providers/offer_provider.dart';
import 'package:bingwa_hybrid/features/offers/models/offer.dart';
import 'package:bingwa_hybrid/features/quick_dial/screens/quick_dial_screen.dart';
import 'package:bingwa_hybrid/features/offers/screens/create_offer_screen.dart';
import 'package:bingwa_hybrid/features/offers/ussd_codes/screens/ussd_codes_screen.dart'; // new import

class OffersScreen extends StatefulWidget {
  const OffersScreen({super.key});

  @override
  State<OffersScreen> createState() => _OffersScreenState();
}

class _OffersScreenState extends State<OffersScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _tabs = ['All', 'Data', 'Minutes', 'SMS'];

  // Search related
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<OfferProvider>(context, listen: false);
      if (provider.offers.isEmpty) {
        provider.syncOffers();
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  // Filter offers by search query and category
  List<Offer> _filteredOffers(OfferProvider provider, String category) {
    final allOffers = provider.getOffersByCategory(category);
    if (_searchQuery.isEmpty) return allOffers;
    return allOffers.where((offer) {
      return offer.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
             (offer.description?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false);
    }).toList();
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<bool> _confirmDelete(String offerName) async {
    return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Delete Offer'),
            content: Text('Are you sure you want to delete "$offerName"?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Delete', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        ) ??
        false;
  }

  Future<void> _deleteOffer(OfferProvider provider, Offer offer) async {
    final confirmed = await _confirmDelete(offer.name);
    if (!confirmed) return;
    final success = await provider.deleteOffer(offer.id);
    if (success && mounted) {
      _showSnackbar('Offer deleted');
    } else if (mounted) {
      _showSnackbar(provider.error ?? 'Delete failed');
    }
  }

  Future<void> _changeStatus(
      OfferProvider provider, Offer offer, String action, Future<bool> Function(int) method) async {
    final success = await method(offer.id);
    if (success && mounted) {
      _showSnackbar('Offer $action successfully');
      await provider.syncOffers();
    } else if (mounted) {
      _showSnackbar(provider.error ?? '$action failed');
    }
  }

  Future<void> _cloneOffer(OfferProvider provider, Offer offer) async {
    final newNameController = TextEditingController(text: '${offer.name} (Copy)');
    final newName = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clone Offer'),
        content: TextField(
          controller: newNameController,
          decoration: const InputDecoration(labelText: 'New Offer Name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, newNameController.text.trim()),
            child: const Text('Clone'),
          ),
        ],
      ),
    );
    if (newName == null || newName.isEmpty) return;
    final cloned = await provider.cloneOffer(offer.id, newName);
    if (cloned != null && mounted) {
      _showSnackbar('Offer cloned');
    } else if (mounted) {
      _showSnackbar(provider.error ?? 'Clone failed');
    }
  }

  void _editOffer(Offer offer) {
    _showSnackbar('Edit not implemented yet');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Search offers...',
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: Colors.white70),
                ),
                style: const TextStyle(color: Colors.white),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
              )
            : const Text('My Offers'),
        bottom: _isSearching
            ? null
            : TabBar(
                controller: _tabController,
                labelColor: AppTheme.primaryBlue,
                unselectedLabelColor: Colors.grey,
                indicatorColor: AppTheme.primaryBlue,
                tabs: _tabs.map((tab) => Tab(text: tab)).toList(),
              ),
        actions: [
          if (!_isSearching)
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {
                setState(() {
                  _isSearching = true;
                });
              },
            ),
          if (_isSearching)
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                setState(() {
                  _isSearching = false;
                  _searchQuery = '';
                  _searchController.clear();
                });
              },
            ),
        ],
      ),
      drawer: const AppDrawer(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CreateOfferScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
      body: Consumer<OfferProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.offers.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if (provider.error != null) {
            return Center(child: Text('Error: ${provider.error}'));
          }
          // If searching, we show a single list of filtered offers across all categories
          if (_isSearching) {
            final filtered = _filteredOffers(provider, 'All');
            if (filtered.isEmpty) {
              return const Center(child: Text('No matching offers'));
            }
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: filtered.length,
              itemBuilder: (context, index) {
                return _buildOfferCard(context, provider, filtered[index]);
              },
            );
          }
          // Normal tab view
          return TabBarView(
            controller: _tabController,
            children: _tabs.map((category) {
              final offers = _filteredOffers(provider, category);
              if (offers.isEmpty) {
                return const Center(child: Text('No offers in this category'));
              }
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: offers.length,
                itemBuilder: (context, index) {
                  return _buildOfferCard(context, provider, offers[index]);
                },
              );
            }).toList(),
          );
        },
      ),
    );
  }

  Widget _buildOfferCard(BuildContext context, OfferProvider provider, Offer offer) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        title: Text(offer.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${offer.currency} ${offer.price.toStringAsFixed(0)}'),
            Text(offer.ussdCodeTemplate, style: const TextStyle(fontFamily: 'monospace', fontSize: 12)),
            if (offer.status != 'active')
              Container(
                margin: const EdgeInsets.only(top: 4),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: offer.status == 'paused' ? Colors.orange.shade100 : Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  offer.status,
                  style: TextStyle(
                    fontSize: 10,
                    color: offer.status == 'paused' ? Colors.orange.shade900 : Colors.black54,
                  ),
                ),
              ),
          ],
        ),
        isThreeLine: true,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => QuickDialScreen(initialOffer: offer),
            ),
          );
        },
        trailing: PopupMenuButton<String>(
          onSelected: (value) async {
            switch (value) {
              case 'ussd':
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => UssdCodesScreen(
                      offerId: offer.id,
                      offerName: offer.name,
                    ),
                  ),
                );
                break;
              case 'edit':
                _editOffer(offer);
                break;
              case 'clone':
                await _cloneOffer(provider, offer);
                break;
              case 'activate':
                await _changeStatus(provider, offer, 'activated', provider.activateOffer);
                break;
              case 'deactivate':
                await _changeStatus(provider, offer, 'deactivated', provider.deactivateOffer);
                break;
              case 'pause':
                await _changeStatus(provider, offer, 'paused', provider.pauseOffer);
                break;
              case 'delete':
                await _deleteOffer(provider, offer);
                break;
            }
          },
          itemBuilder: (ctx) {
            final List<PopupMenuEntry<String>> items = [
              const PopupMenuItem(value: 'ussd', child: Text('Manage USSD Codes')), // new
              const PopupMenuItem(value: 'edit', child: Text('Edit')),
              const PopupMenuItem(value: 'clone', child: Text('Clone')),
            ];
            if (offer.status == 'active') {
              items.add(const PopupMenuItem(value: 'deactivate', child: Text('Deactivate')));
              items.add(const PopupMenuItem(value: 'pause', child: Text('Pause')));
            } else if (offer.status == 'paused') {
              items.add(const PopupMenuItem(value: 'activate', child: Text('Activate')));
              items.add(const PopupMenuItem(value: 'deactivate', child: Text('Deactivate')));
            } else {
              items.add(const PopupMenuItem(value: 'activate', child: Text('Activate')));
            }
            items.add(const PopupMenuItem(value: 'delete', child: Text('Delete')));
            return items;
          },
          icon: const Icon(Icons.more_vert),
        ),
      ),
    );
  }
}