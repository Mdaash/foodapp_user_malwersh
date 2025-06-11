// lib/services/address_service.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddressModel {
  final String id;
  final String name;
  final String fullAddress;
  final double latitude;
  final double longitude;
  final bool isDefault;
  final bool isCurrent;
  final String type; // 'home', 'work', 'other', 'current'

  AddressModel({
    required this.id,
    required this.name,
    required this.fullAddress,
    required this.latitude,
    required this.longitude,
    this.isDefault = false,
    this.isCurrent = false,
    this.type = 'other',
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'fullAddress': fullAddress,
      'latitude': latitude,
      'longitude': longitude,
      'isDefault': isDefault,
      'isCurrent': isCurrent,
      'type': type,
    };
  }

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      id: json['id'],
      name: json['name'],
      fullAddress: json['fullAddress'],
      latitude: json['latitude'],
      longitude: json['longitude'],
      isDefault: json['isDefault'] ?? false,
      isCurrent: json['isCurrent'] ?? false,
      type: json['type'] ?? 'other',
    );
  }

  AddressModel copyWith({
    String? id,
    String? name,
    String? fullAddress,
    double? latitude,
    double? longitude,
    bool? isDefault,
    bool? isCurrent,
    String? type,
  }) {
    return AddressModel(
      id: id ?? this.id,
      name: name ?? this.name,
      fullAddress: fullAddress ?? this.fullAddress,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      isDefault: isDefault ?? this.isDefault,
      isCurrent: isCurrent ?? this.isCurrent,
      type: type ?? this.type,
    );
  }
}

class AddressService extends ChangeNotifier {
  static const String _storageKey = 'saved_addresses';
  static const String _defaultAddressKey = 'default_address_id';
  
  List<AddressModel> _addresses = [];
  AddressModel? _currentAddress;
  AddressModel? _selectedAddress;
  bool _isLoadingLocation = false;
  String? _locationError;
  bool _disposed = false; // للتحقق من إغلاق الخدمة

  List<AddressModel> get addresses => _addresses;
  AddressModel? get currentAddress => _currentAddress;
  AddressModel? get selectedAddress => _selectedAddress ?? _currentAddress;
  bool get isLoadingLocation => _isLoadingLocation;
  String? get locationError => _locationError;

  // الحصول على العنوان المحفوظ أو الحالي
  String get displayAddress {
    if (_selectedAddress != null) {
      return _selectedAddress!.fullAddress;
    }
    if (_currentAddress != null) {
      return _currentAddress!.fullAddress;
    }
    return 'بغداد، العراق'; // عنوان افتراضي
  }

  // البحث عن موقع المستخدم الحالي
  Future<void> getCurrentLocation() async {
    if (_disposed) return; // لا نفعل شيء إذا تم إغلاق الخدمة
    
    _isLoadingLocation = true;
    _locationError = null;
    if (!_disposed) notifyListeners();

    try {
      // التحقق من الصلاحيات
      LocationPermission permission = await Geolocator.checkPermission();
      if (_disposed) return; // التحقق بعد العملية async
      
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (_disposed) return;
        
        if (permission == LocationPermission.denied) {
          throw 'تم رفض صلاحية الموقع';
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw 'تم رفض صلاحية الموقع نهائياً. يرجى تفعيلها من الإعدادات';
      }

      // التحقق من إمكانية الوصول للموقع
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (_disposed) return;
      
      if (!serviceEnabled) {
        throw 'خدمة الموقع غير مفعلة. يرجى تفعيلها';
      }

      // الحصول على الموقع الحالي
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );
      
      if (_disposed) return; // التحقق بعد الحصول على الموقع

      // تحويل الإحداثيات إلى عنوان
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      
      if (_disposed) return; // التحقق بعد geocoding

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        String fullAddress = _buildFullAddress(place);
        
        _currentAddress = AddressModel(
          id: 'current_location',
          name: 'موقعي الحالي',
          fullAddress: fullAddress,
          latitude: position.latitude,
          longitude: position.longitude,
          isCurrent: true,
          type: 'current',
        );

        // تحديث الموقع الحالي في القائمة
        _addresses.removeWhere((addr) => addr.isCurrent);
        _addresses.insert(0, _currentAddress!);
        
        if (!_disposed) notifyListeners();
      }
    } catch (e) {
      if (!_disposed) {
        _locationError = e.toString();
        debugPrint('خطأ في الحصول على الموقع: $e');
      }
    } finally {
      if (!_disposed) {
        _isLoadingLocation = false;
        notifyListeners();
      }
    }
  }

  // بناء العنوان الكامل من Placemark
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
    
    if (addressParts.isEmpty) {
      return 'العراق، بغداد';
    }
    
    return addressParts.join('، ');
  }

  // تحميل العناوين المحفوظة
  Future<void> loadSavedAddresses() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? addressesJson = prefs.getString(_storageKey);
      String? defaultAddressId = prefs.getString(_defaultAddressKey);
      
      if (addressesJson != null) {
        List<dynamic> addressesList = json.decode(addressesJson);
        _addresses = addressesList
            .map((json) => AddressModel.fromJson(json))
            .toList();
        
        // تعيين العنوان الافتراضي
        if (defaultAddressId != null) {
          int defaultIndex = _addresses.indexWhere((addr) => addr.id == defaultAddressId);
          if (defaultIndex != -1) {
            _selectedAddress = _addresses[defaultIndex];
          }
        }
      }
      
      // إضافة عناوين افتراضية إذا كانت القائمة فارغة
      if (_addresses.isEmpty) {
        _addDefaultAddresses();
      }
      
      notifyListeners();
    } catch (e) {
      debugPrint('خطأ في تحميل العناوين: $e');
    }
  }

  // إضافة عناوين افتراضية
  void _addDefaultAddresses() {
    _addresses = [
      AddressModel(
        id: 'default_1',
        name: 'المنزل',
        fullAddress: 'بغداد، الكرادة، حي 123، قرب الجامعة',
        latitude: 33.3152,
        longitude: 44.3661,
        isDefault: true,
        type: 'home',
      ),
      AddressModel(
        id: 'default_2',
        name: 'العمل',
        fullAddress: 'بغداد، الجادرية، شارع الجامعة',
        latitude: 33.2778,
        longitude: 44.3661,
        type: 'work',
      ),
      AddressModel(
        id: 'default_3',
        name: 'وسط البلد',
        fullAddress: 'بغداد، الرصافة، ساحة التحرير',
        latitude: 33.3406,
        longitude: 44.4009,
        type: 'other',
      ),
    ];
    _selectedAddress = _addresses.first;
  }

  // حفظ العناوين
  Future<void> _saveAddresses() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String addressesJson = json.encode(
        _addresses.map((addr) => addr.toJson()).toList(),
      );
      await prefs.setString(_storageKey, addressesJson);
      
      if (_selectedAddress != null) {
        await prefs.setString(_defaultAddressKey, _selectedAddress!.id);
      }
    } catch (e) {
      debugPrint('خطأ في حفظ العناوين: $e');
    }
  }

  // تحديد عنوان محدد
  void selectAddress(AddressModel address) {
    _selectedAddress = address;
    notifyListeners();
    _saveAddresses();
  }

  // إضافة عنوان جديد
  Future<void> addAddress(AddressModel address) async {
    _addresses.add(address);
    notifyListeners();
    await _saveAddresses();
  }

  // تحديث عنوان موجود
  Future<void> updateAddress(String id, AddressModel updatedAddress) async {
    int index = _addresses.indexWhere((addr) => addr.id == id);
    if (index != -1) {
      _addresses[index] = updatedAddress;
      if (_selectedAddress?.id == id) {
        _selectedAddress = updatedAddress;
      }
      notifyListeners();
      await _saveAddresses();
    }
  }

  // حذف عنوان
  Future<void> deleteAddress(String id) async {
    _addresses.removeWhere((addr) => addr.id == id);
    if (_selectedAddress?.id == id) {
      _selectedAddress = _addresses.isNotEmpty ? _addresses.first : null;
    }
    notifyListeners();
    await _saveAddresses();
  }

  // البحث عن عنوان بالنص
  Future<List<AddressModel>> searchAddresses(String query) async {
    if (query.trim().isEmpty) return [];
    
    try {
      // البحث باستخدام geocoding
      List<Location> locations = await locationFromAddress(query);
      List<AddressModel> results = [];
      
      for (Location location in locations.take(5)) {
        List<Placemark> placemarks = await placemarkFromCoordinates(
          location.latitude,
          location.longitude,
        );
        
        if (placemarks.isNotEmpty) {
          Placemark place = placemarks.first;
          String fullAddress = _buildFullAddress(place);
          
          results.add(AddressModel(
            id: 'search_${DateTime.now().millisecondsSinceEpoch}',
            name: query,
            fullAddress: fullAddress,
            latitude: location.latitude,
            longitude: location.longitude,
            type: 'other',
          ));
        }
      }
      
      return results;
    } catch (e) {
      debugPrint('خطأ في البحث عن العنوان: $e');
      return [];
    }
  }

  // تهيئة الخدمة
  Future<void> initialize() async {
    await loadSavedAddresses();
    // لا نحتاج للحصول على الموقع الحالي تلقائياً
    // await getCurrentLocation();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
