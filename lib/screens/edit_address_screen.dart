// lib/screens/edit_address_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

import '../models/address_model.dart';
import '../widgets/loading_widget.dart';
import '../services/address_service.dart';

class EditAddressScreen extends StatefulWidget {
  final DetailedAddress address;

  const EditAddressScreen({
    super.key,
    required this.address,
  });

  @override
  State<EditAddressScreen> createState() => _EditAddressScreenState();
}

class _EditAddressScreenState extends State<EditAddressScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _provinceController = TextEditingController();
  final _districtController = TextEditingController();
  final _neighborhoodController = TextEditingController();
  final _landmarkController = TextEditingController();
  final _detailedAddressController = TextEditingController();
  final _buildingNumberController = TextEditingController();
  final _floorNumberController = TextEditingController();
  final _apartmentNumberController = TextEditingController();
  final _phoneNumberController = TextEditingController();

  String _selectedType = AddressType.home;
  bool _isDefault = false;
  bool _isLoading = false;
  bool _isLocating = false;
  double? _latitude;
  double? _longitude;

  @override
  void initState() {
    super.initState();
    _initializeFields();
  }

  void _initializeFields() {
    _nameController.text = widget.address.name;
    _provinceController.text = widget.address.province;
    _districtController.text = widget.address.district;
    _neighborhoodController.text = widget.address.neighborhood;
    _landmarkController.text = widget.address.landmark;
    _detailedAddressController.text = widget.address.detailedAddress ?? '';
    _buildingNumberController.text = widget.address.buildingNumber ?? '';
    _floorNumberController.text = widget.address.floorNumber ?? '';
    _apartmentNumberController.text = widget.address.apartmentNumber ?? '';
    _phoneNumberController.text = widget.address.phoneNumber ?? '';
    _selectedType = widget.address.addressType;
    _isDefault = widget.address.isDefault;
    _latitude = widget.address.latitude;
    _longitude = widget.address.longitude;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _provinceController.dispose();
    _districtController.dispose();
    _neighborhoodController.dispose();
    _landmarkController.dispose();
    _detailedAddressController.dispose();
    _buildingNumberController.dispose();
    _floorNumberController.dispose();
    _apartmentNumberController.dispose();
    _phoneNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'تعديل العنوان',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF00c1e8),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _showDeleteConfirmation,
            icon: const Icon(Icons.delete),
            tooltip: 'حذف العنوان',
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionCard(
                title: 'معلومات العنوان الأساسية',
                icon: Icons.info_outline,
                children: [
                  _buildTextField(
                    controller: _nameController,
                    label: 'اسم العنوان',
                    hint: 'مثل: المنزل، العمل، منزل الأصدقاء',
                    icon: Icons.label,
                    isRequired: true,
                  ),
                  const SizedBox(height: 16),
                  _buildAddressTypeSelector(),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Checkbox(
                        value: _isDefault,
                        onChanged: (value) {
                          setState(() {
                            _isDefault = value ?? false;
                          });
                        },
                        activeColor: const Color(0xFF00c1e8),
                      ),
                      const Text(
                        'جعل هذا العنوان افتراضي',
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              _buildSectionCard(
                title: 'تفاصيل العنوان',
                icon: Icons.location_on,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          controller: _provinceController,
                          label: 'المحافظة',
                          hint: 'مثل: بغداد، البصرة',
                          icon: Icons.location_city,
                          isRequired: true,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildTextField(
                          controller: _districtController,
                          label: 'القضاء/الناحية',
                          hint: 'مثل: الكرادة، الجادرية',
                          icon: Icons.business,
                          isRequired: true,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _neighborhoodController,
                    label: 'الحي',
                    hint: 'مثل: حي الأطباء، حي الجامعة',
                    icon: Icons.home_work,
                    isRequired: true,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _landmarkController,
                    label: 'أقرب نقطة دالة',
                    hint: 'مثل: بجانب الجامعة، مقابل المستشفى',
                    icon: Icons.place,
                    isRequired: true,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _detailedAddressController,
                    label: 'تفاصيل إضافية (اختياري)',
                    hint: 'أي تفاصيل إضافية تساعد في الوصول',
                    icon: Icons.description,
                    maxLines: 3,
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              _buildSectionCard(
                title: 'تفاصيل المبنى (اختياري)',
                icon: Icons.apartment,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          controller: _buildingNumberController,
                          label: 'رقم المبنى',
                          hint: '123',
                          icon: Icons.business,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildTextField(
                          controller: _floorNumberController,
                          label: 'رقم الطابق',
                          hint: '2',
                          icon: Icons.layers,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          controller: _apartmentNumberController,
                          label: 'رقم الشقة',
                          hint: '4B',
                          icon: Icons.door_front_door,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildTextField(
                          controller: _phoneNumberController,
                          label: 'رقم الهاتف',
                          hint: '+964 770 123 4567',
                          icon: Icons.phone,
                          keyboardType: TextInputType.phone,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              _buildLocationCard(),
              
              const SizedBox(height: 24),
              
              _buildActionButtons(),
              
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00c1e8).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: const Color(0xFF00c1e8),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    IconData? icon,
    bool isRequired = false,
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label + (isRequired ? ' *' : ''),
        hintText: hint,
        prefixIcon: icon != null ? Icon(icon) : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF00c1e8), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
      ),
      validator: isRequired
          ? (value) {
              if (value == null || value.trim().isEmpty) {
                return 'هذا الحقل مطلوب';
              }
              return null;
            }
          : null,
    );
  }

  Widget _buildAddressTypeSelector() {
    final types = [
      {'type': AddressType.home, 'name': 'المنزل', 'icon': Icons.home, 'color': Colors.green},
      {'type': AddressType.work, 'name': 'العمل', 'icon': Icons.work, 'color': Colors.blue},
      {'type': AddressType.other, 'name': 'أخرى', 'icon': Icons.location_on, 'color': Colors.orange},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'نوع العنوان',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: types.map((type) {
            final isSelected = _selectedType == type['type'];
            return Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedType = type['type'] as String;
                  });
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? (type['color'] as Color).withOpacity(0.1)
                        : Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected
                          ? (type['color'] as Color)
                          : Colors.grey[300]!,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        type['icon'] as IconData,
                        color: isSelected
                            ? (type['color'] as Color)
                            : Colors.grey[600],
                        size: 24,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        type['name'] as String,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected
                              ? (type['color'] as Color)
                              : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildLocationCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.my_location,
                    color: Colors.green,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'الموقع الجغرافي',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
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
                        'الموقع المحفوظ: ${_latitude!.toStringAsFixed(4)}, ${_longitude!.toStringAsFixed(4)}',
                        style: TextStyle(color: Colors.green[700]),
                      ),
                    ),
                  ],
                ),
              )
            else
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info, color: Colors.orange),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'لا يوجد موقع محفوظ. يمكنك تحديث الموقع باستخدام الزر أدناه.',
                        style: TextStyle(color: Colors.orange),
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isLocating ? null : _getCurrentLocation,
                icon: _isLocating
                    ? const SmallLoadingWidget(color: Colors.white)
                    : const Icon(Icons.my_location),
                label: Text(_isLocating ? 'جاري تحديد الموقع...' : 'تحديث الموقع الحالي'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _saveChanges,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00c1e8),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
            ),
            child: _isLoading
                ? const SmallLoadingWidget(color: Colors.white)
                : const Text(
                    'حفظ التعديلات',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _showDeleteConfirmation,
            icon: const Icon(Icons.delete, color: Colors.red),
            label: const Text(
              'حذف العنوان',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.red),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _getCurrentLocation() async {
    setState(() => _isLocating = true);

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw 'خدمة الموقع غير مفعلة. يرجى تفعيلها من الإعدادات.';
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw 'تم رفض إذن الوصول للموقع.';
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw 'تم رفض إذن الوصول للموقع نهائياً. يرجى تفعيله من الإعدادات.';
      }

      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );

      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty && mounted) {
        Placemark place = placemarks.first;
        setState(() {
          _latitude = position.latitude;
          _longitude = position.longitude;
          
          // تحديث الحقول بناءً على الموقع الجديد إذا كان المستخدم يريد ذلك
          if (place.administrativeArea != null && place.administrativeArea!.isNotEmpty) {
            _provinceController.text = place.administrativeArea!;
          }
          if (place.locality != null && place.locality!.isNotEmpty) {
            _districtController.text = place.locality!;
          }
          if (place.subLocality != null && place.subLocality!.isNotEmpty) {
            _neighborhoodController.text = place.subLocality!;
          }
          if (place.thoroughfare != null && place.thoroughfare!.isNotEmpty) {
            _landmarkController.text = place.thoroughfare!;
          }
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم تحديث الموقع بنجاح'),
            backgroundColor: Colors.green,
          ),
        );
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

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final addressService = context.read<EnhancedAddressService>();
      
      final request = AddressUpdateRequest(
        name: _nameController.text.trim(),
        province: _provinceController.text.trim(),
        district: _districtController.text.trim(),
        neighborhood: _neighborhoodController.text.trim(),
        landmark: _landmarkController.text.trim(),
        detailedAddress: _detailedAddressController.text.trim().isEmpty 
            ? null 
            : _detailedAddressController.text.trim(),
        latitude: _latitude,
        longitude: _longitude,
        addressType: _selectedType,
        isDefault: _isDefault,
        buildingNumber: _buildingNumberController.text.trim().isEmpty 
            ? null 
            : _buildingNumberController.text.trim(),
        floorNumber: _floorNumberController.text.trim().isEmpty 
            ? null 
            : _floorNumberController.text.trim(),
        apartmentNumber: _apartmentNumberController.text.trim().isEmpty 
            ? null 
            : _apartmentNumberController.text.trim(),
        phoneNumber: _phoneNumberController.text.trim().isEmpty 
            ? null 
            : _phoneNumberController.text.trim(),
      );

      final updatedAddress = await addressService.updateAddress(widget.address.id, request);
      
      if (updatedAddress != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم تحديث العنوان بنجاح'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(addressService.error ?? 'فشل في تحديث العنوان'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ في حفظ التعديلات: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: Text('هل أنت متأكد من حذف عنوان "${widget.address.name}"؟\n\nلا يمكن التراجع عن هذا الإجراء.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteAddress();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('حذف'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteAddress() async {
    setState(() => _isLoading = true);

    try {
      final addressService = context.read<EnhancedAddressService>();
      final success = await addressService.deleteAddress(widget.address.id);
      
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم حذف العنوان بنجاح'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(addressService.error ?? 'فشل في حذف العنوان'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ في حذف العنوان: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
