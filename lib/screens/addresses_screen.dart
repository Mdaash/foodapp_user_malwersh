// lib/screens/addresses_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/address_model.dart';
import '../services/address_service.dart';
import '../widgets/loading_widget.dart';
import '../widgets/error_widget.dart';
import 'add_address_screen.dart';
import 'edit_address_screen.dart';

class AddressesScreen extends StatefulWidget {
  const AddressesScreen({super.key});

  @override
  State<AddressesScreen> createState() => _AddressesScreenState();
}

class _AddressesScreenState extends State<AddressesScreen> {
  late EnhancedAddressService _addressService;

  @override
  void initState() {
    super.initState();
    _addressService = context.read<EnhancedAddressService>();
    _loadAddresses();
  }

  Future<void> _loadAddresses() async {
    await _addressService.fetchAddresses();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'عناويني',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.orange[600],
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            onPressed: _loadAddresses,
            icon: const Icon(Icons.refresh),
            tooltip: 'تحديث',
          ),
        ],
      ),
      body: Consumer<EnhancedAddressService>(
        builder: (context, addressService, child) {
          if (addressService.isLoading && addressService.addresses.isEmpty) {
            return const Center(child: LoadingWidget());
          }

          if (addressService.error != null && addressService.detailedAddresses.isEmpty) {
            return Center(
              child: ErrorDisplayWidget(
                error: addressService.error!,
                onRetry: _loadAddresses,
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _loadAddresses,
            child: Column(
              children: [
                // زر الموقع الحالي
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.all(16),
                  child: _buildCurrentLocationCard(),
                ),
                
                // قائمة العناوين المحفوظة
                Expanded(
                  child: addressService.detailedAddresses.isEmpty
                      ? _buildEmptyState()
                      : _buildAddressesList(addressService.detailedAddresses),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateToAddAddress(),
        backgroundColor: Colors.orange[600],
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_location),
        label: const Text('إضافة عنوان'),
      ),
    );
  }

  Widget _buildCurrentLocationCard() {
    return Consumer<EnhancedAddressService>(
      builder: (context, addressService, child) {
        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: InkWell(
            onTap: addressService.isLoadingLocation ? null : () => _getCurrentLocation(),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue[100],
                      shape: BoxShape.circle,
                    ),
                    child: addressService.isLoadingLocation
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(
                            Icons.my_location,
                            color: Colors.blue,
                            size: 20,
                          ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'استخدام الموقع الحالي',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          addressService.currentLocationAddress?.fullAddress ??
                              'اضغط للحصول على موقعك الحالي',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                        if (addressService.locationError != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              addressService.locationError!,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.red,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Colors.grey,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAddressesList(List<DetailedAddress> addresses) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: addresses.length,
      itemBuilder: (context, index) {
        final address = addresses[index];
        return _buildAddressCard(address);
      },
    );
  }

  Widget _buildAddressCard(DetailedAddress address) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _showAddressOptions(address),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // رأس البطاقة
              Row(
                children: [
                  // أيقونة ونوع العنوان
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _getAddressTypeColor(address.addressType),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      address.typeIcon,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              address.name,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (address.isDefault) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.green,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Text(
                                  'افتراضي',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        Text(
                          address.typeDisplayName,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => _showAddressOptions(address),
                    icon: const Icon(Icons.more_vert),
                    color: Colors.grey[600],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              
              // العنوان الكامل
              Text(
                address.fullAddress,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                  height: 1.4,
                ),
              ),
              
              // معلومات إضافية
              if (address.phoneNumber != null || 
                  address.buildingNumber != null ||
                  address.apartmentNumber != null) ...[
                const SizedBox(height: 8),
                const Divider(height: 1),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 16,
                  children: [
                    if (address.buildingNumber != null)
                      _buildInfoChip('المبنى', address.buildingNumber!),
                    if (address.apartmentNumber != null)
                      _buildInfoChip('الشقة', address.apartmentNumber!),
                    if (address.phoneNumber != null)
                      _buildInfoChip('الهاتف', address.phoneNumber!),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(String label, String value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Color _getAddressTypeColor(String type) {
    switch (type) {
      case AddressType.home:
        return Colors.blue[100]!;
      case AddressType.work:
        return Colors.orange[100]!;
      case AddressType.current:
        return Colors.green[100]!;
      default:
        return Colors.grey[100]!;
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.location_off,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'لا توجد عناوين محفوظة',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'اضغط على الزر أدناه لإضافة عنوان جديد',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _showAddressOptions(DetailedAddress address) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _buildAddressOptionsSheet(address),
    );
  }

  Widget _buildAddressOptionsSheet(DetailedAddress address) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // عنوان البطاقة
          Row(
            children: [
              Text(
                address.typeIcon,
                style: const TextStyle(fontSize: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      address.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      address.shortAddress,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Divider(),
          
          // الخيارات
          ListTile(
            leading: const Icon(Icons.edit, color: Colors.blue),
            title: const Text('تعديل العنوان'),
            onTap: () {
              Navigator.pop(context);
              _navigateToEditAddress(address);
            },
          ),
          
          if (!address.isDefault)
            ListTile(
              leading: const Icon(Icons.star, color: Colors.amber),
              title: const Text('جعل افتراضي'),
              onTap: () {
                Navigator.pop(context);
                _setAsDefault(address);
              },
            ),
          
          ListTile(
            leading: const Icon(Icons.delete, color: Colors.red),
            title: const Text('حذف العنوان'),
            onTap: () {
              Navigator.pop(context);
              _confirmDelete(address);
            },
          ),
        ],
      ),
    );
  }

  Future<void> _getCurrentLocation() async {
    await _addressService.getCurrentLocationAddress();
  }

  void _navigateToAddAddress() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddAddressScreen(),
      ),
    ).then((_) => _loadAddresses());
  }

  void _navigateToEditAddress(DetailedAddress address) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditAddressScreen(address: address),
      ),
    ).then((_) => _loadAddresses());
  }

  Future<void> _setAsDefault(DetailedAddress address) async {
    final success = await _addressService.setDefaultAddress(address.id);
    
    if (!mounted) return;
    
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تم تعيين "${address.name}" كعنوان افتراضي'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_addressService.error ?? 'فشل في تعيين العنوان الافتراضي'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _confirmDelete(DetailedAddress address) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: Text('هل أنت متأكد من حذف عنوان "${address.name}"؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteAddress(address);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('حذف'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteAddress(DetailedAddress address) async {
    final success = await _addressService.deleteAddress(address.id);
    
    if (!mounted) return;
    
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تم حذف عنوان "${address.name}"'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_addressService.error ?? 'فشل في حذف العنوان'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
