// lib/widgets/address_dropdown.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/address_service.dart';
import '../models/address_model.dart';

class AddressDropdown extends StatefulWidget {
  final Function(DetailedAddress)? onAddressChanged;
  final Color? iconColor;
  final Color? textColor;
  final double? fontSize;
  final int? maxLines;

  const AddressDropdown({
    super.key,
    this.onAddressChanged,
    this.iconColor,
    this.textColor,
    this.fontSize,
    this.maxLines,
  });

  @override
  State<AddressDropdown> createState() => _AddressDropdownState();
}

class _AddressDropdownState extends State<AddressDropdown> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EnhancedAddressService>().fetchAddresses();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<EnhancedAddressService>(
      builder: (context, addressService, child) {
        return GestureDetector(
          onTap: () => _showAddressBottomSheet(addressService),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.location_on,
                  color: widget.iconColor ?? const Color(0xFF00c1e8),
                  size: 24,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'توصيل إلى',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        addressService.defaultAddress?.fullAddress ?? 'اختر عنوان التوصيل',
                        style: TextStyle(
                          fontSize: widget.fontSize ?? 14,
                          fontWeight: FontWeight.w500,
                          color: widget.textColor ?? Colors.black87,
                        ),
                        maxLines: widget.maxLines ?? 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.keyboard_arrow_down,
                  color: widget.textColor ?? Colors.black87,
                  size: 20,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showAddressBottomSheet(EnhancedAddressService addressService) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddressBottomSheet(
        addressService: addressService,
        onAddressSelected: (address) {
          widget.onAddressChanged?.call(address);
          Navigator.pop(context);
        },
      ),
    );
  }
}

class AddressBottomSheet extends StatelessWidget {
  final EnhancedAddressService addressService;
  final Function(DetailedAddress) onAddressSelected;

  const AddressBottomSheet({
    super.key,
    required this.addressService,
    required this.onAddressSelected,
  });

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.3,
      maxChildSize: 0.9,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle indicator
              Container(
                margin: const EdgeInsets.symmetric(vertical: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              
              // Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Colors.grey.shade200),
                  ),
                ),
                child: Row(
                  children: [
                    const Text(
                      'اختر العنوان',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),
              
              // Content
              Expanded(
                child: Consumer<EnhancedAddressService>(
                  builder: (context, addressService, child) {
                    if (addressService.isLoading) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    if (addressService.error != null) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.error_outline,
                              size: 48,
                              color: Colors.red,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              addressService.error!,
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: Colors.red),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () => addressService.fetchAddresses(),
                              child: const Text('إعادة المحاولة'),
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView(
                      controller: scrollController,
                      children: [
                        // Current Location Button
                        _buildCurrentLocationButton(context, addressService),
                        
                        const Divider(),
                        
                        // Saved Addresses
                        if (addressService.detailedAddresses.isNotEmpty)
                          ...addressService.detailedAddresses.map(
                            (address) => _buildAddressItem(context, address),
                          ),
                        
                        // Add New Address Button
                        _buildAddAddressButton(context),
                        
                        const SizedBox(height: 20),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCurrentLocationButton(BuildContext context, EnhancedAddressService addressService) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: addressService.isLoadingLocation ? null : () async {
          await addressService.getCurrentLocationAddress();
          if (addressService.currentLocationAddress != null && 
              addressService.locationError == null) {
            onAddressSelected(addressService.currentLocationAddress!);
          }
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.blue.shade200),
            borderRadius: BorderRadius.circular(12),
            color: Colors.blue.shade50,
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.my_location,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'استخدام الموقع الحالي',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (addressService.isLoadingLocation)
                      const Text(
                        'جاري تحديد الموقع...',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      )
                    else if (addressService.locationError != null)
                      Text(
                        addressService.locationError!,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.red,
                        ),
                      )
                    else if (addressService.currentLocationAddress != null)
                      Text(
                        addressService.currentLocationAddress!.fullAddress,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      )
                    else
                      const Text(
                        'اضغط لتحديد موقعك',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                  ],
                ),
              ),
              if (addressService.isLoadingLocation)
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAddressItem(BuildContext context, DetailedAddress address) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: InkWell(
        onTap: () => onAddressSelected(address),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(
              color: address.isDefault ? Colors.green.shade300 : Colors.grey.shade300,
            ),
            borderRadius: BorderRadius.circular(12),
            color: address.isDefault ? Colors.green.shade50 : Colors.white,
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _getAddressTypeColor(address.addressType),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getAddressTypeIcon(address.addressType),
                  color: Colors.white,
                  size: 20,
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
                            fontWeight: FontWeight.w600,
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
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              'افتراضي',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      address.fullAddress,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                onSelected: (value) => _handleAddressAction(context, value, address),
                itemBuilder: (context) => [
                  if (!address.isDefault)
                    const PopupMenuItem(
                      value: 'set_default',
                      child: Row(
                        children: [
                          Icon(Icons.star, size: 20),
                          SizedBox(width: 8),
                          Text('تعيين كافتراضي'),
                        ],
                      ),
                    ),
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit, size: 20),
                        SizedBox(width: 8),
                        Text('تعديل'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, size: 20, color: Colors.red),
                        SizedBox(width: 8),
                        Text('حذف', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
                icon: const Icon(Icons.more_vert),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAddAddressButton(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      child: InkWell(
        onTap: () => _showAddAddressScreen(context),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.blue.shade300),
            borderRadius: BorderRadius.circular(12),
            color: Colors.blue.shade50,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.add,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'إضافة عنوان جديد',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.blue,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleAddressAction(BuildContext context, String action, DetailedAddress address) {
    switch (action) {
      case 'set_default':
        addressService.setDefaultAddress(address.id);
        break;
      case 'edit':
        _showEditAddressScreen(context, address);
        break;
      case 'delete':
        _showDeleteConfirmation(context, address);
        break;
    }
  }

  void _showDeleteConfirmation(BuildContext context, DetailedAddress address) {
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
            onPressed: () async {
              Navigator.pop(context);
              await addressService.deleteAddress(address.id);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('حذف'),
          ),
        ],
      ),
    );
  }

  void _showAddAddressScreen(BuildContext context) {
    Navigator.pop(context);
    Navigator.pushNamed(context, '/add-address');
  }

  void _showEditAddressScreen(BuildContext context, DetailedAddress address) {
    Navigator.pop(context);
    Navigator.pushNamed(
      context, 
      '/edit-address',
      arguments: address,
    );
  }

  Color _getAddressTypeColor(String type) {
    switch (type) {
      case 'home':
        return Colors.green;
      case 'work':
        return Colors.blue;
      case 'other':
        return Colors.orange;
      case 'current':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  IconData _getAddressTypeIcon(String type) {
    switch (type) {
      case 'home':
        return Icons.home;
      case 'work':
        return Icons.work;
      case 'other':
        return Icons.location_on;
      case 'current':
        return Icons.my_location;
      default:
        return Icons.location_on;
    }
  }
}
