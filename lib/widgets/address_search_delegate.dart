// lib/widgets/address_search_delegate.dart

import 'package:flutter/material.dart';
import '../services/address_service.dart';

class AddressSearchDelegate extends SearchDelegate<AddressModel?> {
  final AddressService addressService;
  final Function(AddressModel) onAddressSelected;

  AddressSearchDelegate({
    required this.addressService,
    required this.onAddressSelected,
  });

  @override
  String get searchFieldLabel => 'ابحث عن عنوان...';

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        onPressed: () {
          query = '';
        },
        icon: const Icon(Icons.clear),
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      onPressed: () {
        close(context, null);
      },
      icon: const Icon(Icons.arrow_back),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSearchResults(context);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.isEmpty) {
      return _buildRecentAddresses(context);
    }
    return _buildSearchResults(context);
  }

  Widget _buildSearchResults(BuildContext context) {
    if (query.trim().isEmpty) {
      return const Center(
        child: Text('ادخل اسم المدينة أو المنطقة للبحث'),
      );
    }

    return FutureBuilder<List<AddressModel>>(
      future: addressService.searchAddresses(query),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00c1e8)),
            ),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                Text(
                  'خطأ في البحث: ${snapshot.error}',
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
          );
        }

        final results = snapshot.data ?? [];

        if (results.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.location_off, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'لم يتم العثور على نتائج',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(
                  'جرب البحث بكلمات مختلفة',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          itemCount: results.length,
          itemBuilder: (context, index) {
            final address = results[index];
            return _buildAddressListItem(context, address);
          },
        );
      },
    );
  }

  Widget _buildRecentAddresses(BuildContext context) {
    final savedAddresses = addressService.addresses
        .where((addr) => !addr.isCurrent)
        .take(5)
        .toList();

    if (savedAddresses.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.location_on, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'لا توجد عناوين محفوظة',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'ابحث عن عنوان لإضافته',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            'العناوين المحفوظة',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: savedAddresses.length,
            itemBuilder: (context, index) {
              final address = savedAddresses[index];
              return _buildAddressListItem(context, address);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAddressListItem(BuildContext context, AddressModel address) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: _getAddressTypeColor(address.type).withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(
          _getAddressTypeIcon(address.type),
          color: _getAddressTypeColor(address.type),
          size: 20,
        ),
      ),
      title: Text(
        address.name,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        address.fullAddress,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(color: Colors.grey),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () {
        onAddressSelected(address);
        close(context, address);
      },
    );
  }

  IconData _getAddressTypeIcon(String type) {
    switch (type) {
      case 'home':
        return Icons.home;
      case 'work':
        return Icons.work;
      case 'current':
        return Icons.my_location;
      default:
        return Icons.location_on;
    }
  }

  Color _getAddressTypeColor(String type) {
    switch (type) {
      case 'home':
        return Colors.green;
      case 'work':
        return Colors.blue;
      case 'current':
        return const Color(0xFF00c1e8);
      default:
        return Colors.orange;
    }
  }
}
