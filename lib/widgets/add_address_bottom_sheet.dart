// lib/widgets/add_address_bottom_sheet.dart

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../services/address_service.dart';

class AddAddressBottomSheet extends StatefulWidget {
  final AddressService addressService;
  final AddressModel? editAddress;
  final Function(AddressModel) onAddressSaved;

  const AddAddressBottomSheet({
    super.key,
    required this.addressService,
    this.editAddress,
    required this.onAddressSaved,
  });

  @override
  State<AddAddressBottomSheet> createState() => _AddAddressBottomSheetState();
}

class _AddAddressBottomSheetState extends State<AddAddressBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  
  String _selectedType = 'other';
  bool _isLoading = false;
  bool _isLocating = false;
  double? _latitude;
  double? _longitude;

  final List<Map<String, dynamic>> _addressTypes = [
    {'value': 'home', 'label': 'المنزل', 'icon': Icons.home, 'color': Colors.green},
    {'value': 'work', 'label': 'العمل', 'icon': Icons.work, 'color': Colors.blue},
    {'value': 'other', 'label': 'أخرى', 'icon': Icons.location_on, 'color': Colors.orange},
  ];

  @override
  void initState() {
    super.initState();
    if (widget.editAddress != null) {
      _nameController.text = widget.editAddress!.name;
      _addressController.text = widget.editAddress!.fullAddress;
      _selectedType = widget.editAddress!.type;
      _latitude = widget.editAddress!.latitude;
      _longitude = widget.editAddress!.longitude;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
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
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Text(
                  widget.editAddress != null ? 'تعديل العنوان' : 'إضافة عنوان جديد',
                  style: const TextStyle(
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
          
          // Form
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Address name field
                    _buildSectionHeader('اسم العنوان'),
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        hintText: 'مثل: المنزل، العمل، منزل الأصدقاء',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: Icon(_getSelectedTypeIcon()),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'يرجى إدخال اسم العنوان';
                        }
                        return null;
                      },
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Address type selection
                    _buildSectionHeader('نوع العنوان'),
                    _buildAddressTypeSelector(),
                    
                    const SizedBox(height: 24),
                    
                    // Address field
                    _buildSectionHeader('العنوان التفصيلي'),
                    TextFormField(
                      controller: _addressController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: 'المحافظة، المدينة، الحي، رقم المنزل',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: const Icon(Icons.location_on),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'يرجى إدخال العنوان';
                        }
                        return null;
                      },
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Get current location button
                    _buildGetLocationButton(),
                    
                    const SizedBox(height: 24),
                    
                    // Location info
                    if (_latitude != null && _longitude != null)
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.green.withOpacity(0.3)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.check_circle, color: Colors.green),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'تم تحديد الموقع على الخريطة',
                                style: TextStyle(color: Colors.green[700]),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          
          // Save button
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _saveAddress,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00c1e8),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Text(
                        widget.editAddress != null ? 'حفظ التعديلات' : 'إضافة العنوان',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildAddressTypeSelector() {
    return Row(
      children: _addressTypes.map((type) {
        final isSelected = _selectedType == type['value'];
        return Expanded(
          child: GestureDetector(
            onTap: () {
              setState(() {
                _selectedType = type['value'];
              });
            },
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: isSelected 
                    ? type['color'].withOpacity(0.1)
                    : Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isSelected 
                      ? type['color']
                      : Colors.grey[300]!,
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    type['icon'],
                    color: isSelected ? type['color'] : Colors.grey,
                    size: 24,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    type['label'],
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      color: isSelected ? type['color'] : Colors.grey[700],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildGetLocationButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: _isLocating ? null : _getCurrentLocation,
        icon: _isLocating
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00c1e8)),
                ),
              )
            : const Icon(Icons.my_location),
        label: Text(_isLocating ? 'جاري تحديد الموقع...' : 'استخدم موقعي الحالي'),
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFF00c1e8),
          side: const BorderSide(color: Color(0xFF00c1e8)),
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }

  IconData _getSelectedTypeIcon() {
    final type = _addressTypes.firstWhere(
      (t) => t['value'] == _selectedType,
      orElse: () => _addressTypes.last,
    );
    return type['icon'];
  }

  Future<void> _getCurrentLocation() async {
    setState(() => _isLocating = true);

    try {
      // التحقق من الصلاحيات
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw 'تم رفض صلاحية الموقع';
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw 'تم رفض صلاحية الموقع نهائياً. يرجى تفعيلها من الإعدادات';
      }

      // التحقق من تفعيل خدمة الموقع
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw 'خدمة الموقع غير مفعلة. يرجى تفعيلها';
      }

      // الحصول على الموقع
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      // تحويل الإحداثيات إلى عنوان
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        String address = _buildFullAddress(place);
        
        if (mounted) {
          setState(() {
            _latitude = position.latitude;
            _longitude = position.longitude;
            _addressController.text = address;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تم تحديد الموقع بنجاح'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ في تحديد الموقع: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLocating = false);
      }
    }
  }

  String _buildFullAddress(Placemark place) {
    List<String> addressParts = [];
    
    if (place.administrativeArea?.isNotEmpty == true) {
      addressParts.add(place.administrativeArea!);
    }
    if (place.locality?.isNotEmpty == true) {
      addressParts.add(place.locality!);
    }
    if (place.subLocality?.isNotEmpty == true) {
      addressParts.add(place.subLocality!);
    }
    if (place.thoroughfare?.isNotEmpty == true) {
      addressParts.add(place.thoroughfare!);
    }
    
    return addressParts.join('، ');
  }

  Future<void> _saveAddress() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // إذا لم يتم تحديد الموقع، نحاول الحصول عليه من النص
      if (_latitude == null || _longitude == null) {
        await _getLocationFromAddress();
      }

      final address = AddressModel(
        id: widget.editAddress?.id ?? 'addr_${DateTime.now().millisecondsSinceEpoch}',
        name: _nameController.text.trim(),
        fullAddress: _addressController.text.trim(),
        latitude: _latitude ?? 33.3152, // إحداثيات بغداد الافتراضية
        longitude: _longitude ?? 44.3661,
        type: _selectedType,
      );

      widget.onAddressSaved(address);
      
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.editAddress != null 
                  ? 'تم تحديث العنوان بنجاح'
                  : 'تم إضافة العنوان بنجاح'
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ في حفظ العنوان: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _getLocationFromAddress() async {
    try {
      List<Location> locations = await locationFromAddress(_addressController.text);
      if (locations.isNotEmpty) {
        _latitude = locations.first.latitude;
        _longitude = locations.first.longitude;
      }
    } catch (e) {
      // إذا فشل، استخدم الإحداثيات الافتراضية
      debugPrint('فشل في تحديد الموقع من النص: $e');
    }
  }
}
