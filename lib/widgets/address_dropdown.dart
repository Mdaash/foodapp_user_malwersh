// lib/widgets/address_dropdown.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/address_service.dart';
import 'address_search_delegate.dart';
import 'add_address_bottom_sheet.dart';

class AddressDropdown extends StatefulWidget {
  final Function(AddressModel)? onAddressChanged;
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
  Widget build(BuildContext context) {
    return Consumer<AddressService>(
      builder: (context, addressService, child) {
        return GestureDetector(
          onTap: () => _showAddressBottomSheet(addressService),
          child: Row(
            children: [
              Icon(
                Icons.location_on,
                color: widget.iconColor ?? const Color(0xFF00c1e8),
                size: 28,
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
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            addressService.displayAddress,
                            style: TextStyle(
                              fontSize: widget.fontSize ?? 14,
                              fontWeight: FontWeight.bold,
                              color: widget.textColor ?? Colors.black87,
                            ),
                            maxLines: widget.maxLines ?? 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Icon(
                          Icons.keyboard_arrow_down,
                          color: widget.textColor ?? Colors.black87,
                          size: 20,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showAddressBottomSheet(AddressService addressService) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddressBottomSheet(
        addressService: addressService,
        onAddressSelected: (address) {
          addressService.selectAddress(address);
          widget.onAddressChanged?.call(address);
          Navigator.pop(context);
        },
      ),
    );
  }
}

class AddressBottomSheet extends StatefulWidget {
  final AddressService addressService;
  final Function(AddressModel) onAddressSelected;

  const AddressBottomSheet({
    super.key,
    required this.addressService,
    required this.onAddressSelected,
  });

  @override
  State<AddressBottomSheet> createState() => _AddressBottomSheetState();
}

class _AddressBottomSheetState extends State<AddressBottomSheet> {
  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.75,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
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
          Padding(
            padding: const EdgeInsets.all(16),
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
                  icon: const Icon(Icons.close, color: Colors.grey),
                ),
              ],
            ),
          ),
          
          // Current location button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _buildCurrentLocationButton(),
          ),
          
          const Divider(height: 1),
          
          // Search button
          Padding(
            padding: const EdgeInsets.all(16),
            child: _buildSearchButton(),
          ),
          
          // Saved addresses
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: widget.addressService.addresses.where((addr) => !addr.isCurrent).length,
              itemBuilder: (context, index) {
                final addresses = widget.addressService.addresses.where((addr) => !addr.isCurrent).toList();
                final address = addresses[index];
                return _buildAddressItem(address);
              },
            ),
          ),
          
          // Add new address button
          Padding(
            padding: const EdgeInsets.all(16),
            child: _buildAddAddressButton(),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentLocationButton() {
    return Consumer<AddressService>(
      builder: (context, addressService, child) {
        return InkWell(
          onTap: addressService.isLoadingLocation ? null : () async {
            await addressService.getCurrentLocation();
            // التحقق من أن الـ widget ما زال mounted قبل استخدام context
            if (mounted && addressService.currentAddress != null && addressService.locationError == null) {
              widget.onAddressSelected(addressService.currentAddress!);
            }
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00c1e8).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: addressService.isLoadingLocation
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00c1e8)),
                          ),
                        )
                      : const Icon(
                          Icons.my_location,
                          color: Color(0xFF00c1e8),
                          size: 20,
                        ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        addressService.isLoadingLocation 
                            ? 'جاري تحديد الموقع...'
                            : 'استخدم موقعي الحالي',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (addressService.locationError != null)
                        Text(
                          addressService.locationError!,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.red,
                          ),
                        )
                      else if (addressService.currentAddress != null)
                        Text(
                          addressService.currentAddress!.fullAddress,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: Colors.grey),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSearchButton() {
    return InkWell(
      onTap: () => _showSearchDelegate(),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(Icons.search, color: Colors.grey[600]),
            const SizedBox(width: 12),
            Text(
              'البحث عن عنوان...',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddressItem(AddressModel address) {
    final isSelected = widget.addressService.selectedAddress?.id == address.id;
    
    return InkWell(
      onTap: () => widget.onAddressSelected(address),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Row(
          children: [
            Container(
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
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          address.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      if (isSelected)
                        const Icon(
                          Icons.check_circle,
                          color: Color(0xFF00c1e8),
                          size: 20,
                        ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    address.fullAddress,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.grey,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            PopupMenuButton<String>(
              onSelected: (value) => _handleAddressAction(value, address),
              itemBuilder: (context) => [
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
              icon: Icon(Icons.more_vert, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddAddressButton() {
    return InkWell(
      onTap: () => _showAddAddressSheet(),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF00c1e8).withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF00c1e8).withOpacity(0.3)),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add, color: Color(0xFF00c1e8)),
            SizedBox(width: 8),
            Text(
              'إضافة عنوان جديد',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF00c1e8),
              ),
            ),
          ],
        ),
      ),
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

  void _handleAddressAction(String action, AddressModel address) {
    switch (action) {
      case 'edit':
        _showAddAddressSheet(editAddress: address);
        break;
      case 'delete':
        _showDeleteConfirmation(address);
        break;
    }
  }

  void _showDeleteConfirmation(AddressModel address) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حذف العنوان'),
        content: Text('هل تريد حذف "${address.name}"؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              widget.addressService.deleteAddress(address.id);
              Navigator.pop(context);
            },
            child: const Text('حذف', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showSearchDelegate() {
    showSearch(
      context: context,
      delegate: AddressSearchDelegate(
        addressService: widget.addressService,
        onAddressSelected: widget.onAddressSelected,
      ),
    );
  }

  void _showAddAddressSheet({AddressModel? editAddress}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddAddressBottomSheet(
        addressService: widget.addressService,
        editAddress: editAddress,
        onAddressSaved: (address) {
          if (editAddress != null) {
            widget.addressService.updateAddress(editAddress.id, address);
          } else {
            widget.addressService.addAddress(address);
          }
          Navigator.pop(context);
        },
      ),
    );
  }
}
