import 'package:flutter/material.dart';
import '../services/api_service.dart';

class AddressManagementScreen extends StatefulWidget {
  final String token;
  final String userId;

  const AddressManagementScreen({
    Key? key,
    required this.token,
    required this.userId,
  }) : super(key: key);

  @override
  _AddressManagementScreenState createState() => _AddressManagementScreenState();
}

class _AddressManagementScreenState extends State<AddressManagementScreen> {
  List<Map<String, dynamic>> userAddresses = []; // قائمة العناوين المتعددة
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAddresses();
  }

  Future<void> _loadAddresses() async {
    setState(() {
      isLoading = true;
    });

    try {
      final result = await ApiService.getUserAddresses(widget.userId);
      if (result['success']) {
        setState(() {
          userAddresses = List<Map<String, dynamic>>.from(result['data'] ?? []);
        });
      } else {
        setState(() {
          userAddresses = [];
        });
      }
    } catch (e) {
      _showErrorMessage('خطأ في تحميل العناوين');
      setState(() {
        userAddresses = [];
      });
    }

    setState(() {
      isLoading = false;
    });
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showAddressDialog({Map<String, dynamic>? existingAddress}) {
    final TextEditingController nameController = TextEditingController(
      text: existingAddress?['name'] ?? ''
    );
    final TextEditingController governorateController = TextEditingController(
      text: existingAddress?['governorate'] ?? ''
    );
    final TextEditingController districtController = TextEditingController(
      text: existingAddress?['district'] ?? ''
    );
    final TextEditingController neighborhoodController = TextEditingController(
      text: existingAddress?['neighborhood'] ?? ''
    );
    final TextEditingController landmarkController = TextEditingController(
      text: existingAddress?['landmark'] ?? ''
    );
    
    bool isDefault = existingAddress?['is_default'] ?? false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(
                existingAddress != null ? 'تعديل العنوان' : 'إضافة عنوان جديد',
                style: const TextStyle(fontFamily: 'Cairo'),
                textAlign: TextAlign.right,
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'اسم العنوان (مثل: المنزل، العمل)',
                        labelStyle: TextStyle(fontFamily: 'Cairo'),
                      ),
                      textAlign: TextAlign.right,
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: governorateController,
                      decoration: const InputDecoration(
                        labelText: 'المحافظة',
                        labelStyle: TextStyle(fontFamily: 'Cairo'),
                      ),
                      textAlign: TextAlign.right,
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: districtController,
                      decoration: const InputDecoration(
                        labelText: 'القضاء',
                        labelStyle: TextStyle(fontFamily: 'Cairo'),
                      ),
                      textAlign: TextAlign.right,
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: neighborhoodController,
                      decoration: const InputDecoration(
                        labelText: 'الحي',
                        labelStyle: TextStyle(fontFamily: 'Cairo'),
                      ),
                      textAlign: TextAlign.right,
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: landmarkController,
                      decoration: const InputDecoration(
                        labelText: 'المعلم',
                        labelStyle: TextStyle(fontFamily: 'Cairo'),
                      ),
                      textAlign: TextAlign.right,
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        const Text(
                          'العنوان الافتراضي',
                          style: TextStyle(fontFamily: 'Cairo'),
                        ),
                        const SizedBox(width: 8),
                        Checkbox(
                          value: isDefault,
                          onChanged: (value) {
                            setState(() {
                              isDefault = value ?? false;
                            });
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text(
                    'إلغاء',
                    style: TextStyle(fontFamily: 'Cairo'),
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (nameController.text.trim().isEmpty ||
                        governorateController.text.trim().isEmpty ||
                        districtController.text.trim().isEmpty ||
                        neighborhoodController.text.trim().isEmpty ||
                        landmarkController.text.trim().isEmpty) {
                      _showErrorMessage('يرجى ملء جميع الحقول');
                      return;
                    }

                    Navigator.of(context).pop();

                    Map<String, dynamic> result;
                    
                    if (existingAddress != null) {
                      // تحديث عنوان موجود
                      result = await ApiService.updateUserAddress(
                        token: widget.token,
                        addressId: existingAddress['address_id'],
                        name: nameController.text.trim(),
                        governorate: governorateController.text.trim(),
                        district: districtController.text.trim(),
                        neighborhood: neighborhoodController.text.trim(),
                        landmark: landmarkController.text.trim(),
                        isDefault: isDefault,
                      );
                    } else {
                      // إضافة عنوان جديد
                      result = await ApiService.addUserAddress(
                        token: widget.token,
                        userId: widget.userId,
                        name: nameController.text.trim(),
                        governorate: governorateController.text.trim(),
                        district: districtController.text.trim(),
                        neighborhood: neighborhoodController.text.trim(),
                        landmark: landmarkController.text.trim(),
                        isDefault: isDefault,
                      );
                    }

                    if (result['success']) {
                      _showSuccessMessage(existingAddress != null ? 'تم تحديث العنوان بنجاح' : 'تم إضافة العنوان بنجاح');
                      _loadAddresses(); // إعادة تحميل العناوين
                    } else {
                      _showErrorMessage(result['message']);
                    }
                  },
                  child: Text(
                    existingAddress != null ? 'تحديث' : 'إضافة',
                    style: const TextStyle(fontFamily: 'Cairo'),
                  ),
                ),
              ],
            );
          }
        );
      },
    );
  }

  void _confirmDeleteAddress(Map<String, dynamic> address) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'تأكيد الحذف',
            style: TextStyle(fontFamily: 'Cairo'),
            textAlign: TextAlign.right,
          ),
          content: Text(
            'هل أنت متأكد من حذف عنوان "${address['name']}"؟',
            style: const TextStyle(fontFamily: 'Cairo'),
            textAlign: TextAlign.right,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                'إلغاء',
                style: TextStyle(fontFamily: 'Cairo'),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                
                final result = await ApiService.deleteUserAddress(
                  token: widget.token,
                  addressId: address['address_id'],
                );

                if (result['success']) {
                  _showSuccessMessage('تم حذف العنوان بنجاح');
                  _loadAddresses();
                } else {
                  _showErrorMessage(result['message']);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text(
                'حذف',
                style: TextStyle(fontFamily: 'Cairo'),
              ),
            ),
          ],
        );
      },
    );
  }

  void _setDefaultAddress(Map<String, dynamic> address) async {
    final result = await ApiService.setDefaultAddress(
      token: widget.token,
      addressId: address['address_id'],
    );

    if (result['success']) {
      _showSuccessMessage('تم تحديد العنوان كافتراضي');
      _loadAddresses();
    } else {
      _showErrorMessage(result['message']);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'إدارة العناوين',
          style: TextStyle(fontFamily: 'Cairo'),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () => _showAddressDialog(),
            icon: const Icon(Icons.add),
            tooltip: 'إضافة عنوان جديد',
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : userAddresses.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.location_off,
                        size: 80,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'لا توجد عناوين مسجلة',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[600],
                          fontFamily: 'Cairo',
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'أضف عناوينك لتسهيل عملية التوصيل',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                          fontFamily: 'Cairo',
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 30),
                      ElevatedButton.icon(
                        onPressed: () => _showAddressDialog(),
                        icon: const Icon(Icons.add_location),
                        label: const Text(
                          'إضافة عنوان',
                          style: TextStyle(fontFamily: 'Cairo'),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: userAddresses.length,
                  itemBuilder: (context, index) {
                    final address = userAddresses[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  address['is_default'] ? Icons.home : Icons.location_on,
                                  color: address['is_default'] ? Colors.green : Colors.orange,
                                  size: 24,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    address['name'],
                                    style: const TextStyle(
                                      fontFamily: 'Cairo',
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                                if (address['is_default'])
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.green,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Text(
                                      'افتراضي',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontFamily: 'Cairo',
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${address['governorate']} - ${address['district']}',
                              style: const TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 14,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${address['neighborhood']} - ${address['landmark']}',
                              style: const TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                if (!address['is_default'])
                                  TextButton.icon(
                                    onPressed: () => _setDefaultAddress(address),
                                    icon: const Icon(Icons.home, size: 16),
                                    label: const Text(
                                      'تعيين كافتراضي',
                                      style: TextStyle(fontFamily: 'Cairo', fontSize: 12),
                                    ),
                                    style: TextButton.styleFrom(
                                      foregroundColor: Colors.green,
                                    ),
                                  ),
                                TextButton.icon(
                                  onPressed: () => _showAddressDialog(existingAddress: address),
                                  icon: const Icon(Icons.edit, size: 16),
                                  label: const Text(
                                    'تعديل',
                                    style: TextStyle(fontFamily: 'Cairo', fontSize: 12),
                                  ),
                                  style: TextButton.styleFrom(
                                    foregroundColor: Colors.blue,
                                  ),
                                ),
                                TextButton.icon(
                                  onPressed: () => _confirmDeleteAddress(address),
                                  icon: const Icon(Icons.delete, size: 16),
                                  label: const Text(
                                    'حذف',
                                    style: TextStyle(fontFamily: 'Cairo', fontSize: 12),
                                  ),
                                  style: TextButton.styleFrom(
                                    foregroundColor: Colors.red,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddressDialog(),
        backgroundColor: Colors.orange,
        child: const Icon(Icons.add),
        tooltip: 'إضافة عنوان جديد',
      ),
    );
  }
}
