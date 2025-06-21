// lib/services/address_service.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/address_model.dart';
import 'package:foodapp_user/services/api_service.dart';
import 'package:foodapp_user/services/enhanced_session_service.dart';

class EnhancedAddressService extends ChangeNotifier {
  static const String _storageKey = 'saved_addresses';
  static const String _defaultAddressKey = 'default_address_id';
  
  // Local models for compatibility
  List<AddressModel> _addresses = [];
  AddressModel? _currentAddress;
  AddressModel? _selectedAddress;
  
  // API-based models
  List<DetailedAddress> _detailedAddresses = [];
  DetailedAddress? _currentLocationAddress;
  
  bool _isLoadingLocation = false;
  bool _isLoading = false;
  String? _locationError;
  String? _error;
  bool _disposed = false;

  // Getters for compatibility
  List<AddressModel> get addresses => _addresses;  
  List<DetailedAddress> get detailedAddresses => _detailedAddresses;
  AddressModel? get currentAddress => _currentAddress;
  AddressModel? get selectedAddress => _selectedAddress ?? _currentAddress;
  DetailedAddress? get currentLocationAddress => _currentLocationAddress;
  bool get isLoadingLocation => _isLoadingLocation;
  bool get isLoading => _isLoading;
  String? get locationError => _locationError;
  String? get error => _error;
  
  // Additional getters for UI compatibility
  DetailedAddress? get defaultAddress {
    try {
      return _detailedAddresses.where((addr) => addr.isDefault).isNotEmpty 
          ? _detailedAddresses.where((addr) => addr.isDefault).first 
          : null;
    } catch (e) {
      return null;
    }
  }

  // الحصول على العنوان المحفوظ أو الحالي
  String get displayAddress {
    if (_selectedAddress != null) {
      return _selectedAddress!.fullAddress;
    }
    if (_currentAddress != null) {
      return _currentAddress!.fullAddress;
    }
    return 'بغداد، العراق';
  }

  // البحث عن موقع المستخدم الحالي
  Future<void> getCurrentLocation() async {
    if (_disposed) return;
    
    _isLoadingLocation = true;
    _locationError = null;
    if (!_disposed) notifyListeners();

    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (_disposed) return;
      
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

      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (_disposed) return;
      
      if (!serviceEnabled) {
        throw 'خدمة الموقع غير مفعلة. يرجى تفعيلها';
      }

      Position position;
      try {
        position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
          timeLimit: const Duration(seconds: 15),
        );
      } catch (e) {
        try {
          position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.medium,
            timeLimit: const Duration(seconds: 10),
          );
        } catch (e2) {
          throw 'فشل في تحديد الموقع. تأكد من تفعيل GPS وإعطاء التطبيق الصلاحية اللازمة';
        }
      }
      
      if (_disposed) return;

      List<Placemark>? placemarks;
      try {
        placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        ).timeout(const Duration(seconds: 10));
        
        // التحقق من أن placemarks ليس فارغ وأن العناصر ليست null
        if (placemarks.isEmpty) {
          placemarks = null;
        }
      } catch (e) {
        debugPrint('خطأ في تحويل الإحداثيات إلى عنوان: $e');
        placemarks = null;
      }
      
      if (_disposed) return;

      String fullAddress;
      if (placemarks != null && placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        fullAddress = _buildFullAddress(place);
      } else {
        fullAddress = 'الموقع الحالي (${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)})';
      }
      
      _currentAddress = AddressModel(
        id: 'current_location',
        name: 'موقعي الحالي',
        fullAddress: fullAddress,
        latitude: position.latitude,
        longitude: position.longitude,
        isCurrent: true,
        type: 'current',
      );

      _addresses.removeWhere((addr) => addr.isCurrent);
      _addresses.insert(0, _currentAddress!);
      
      if (!_disposed) notifyListeners();
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

  String _buildFullAddress(Placemark place) {
    List<String> addressParts = [];
    
    try {
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
      
      if (place.subThoroughfare?.isNotEmpty == true) {
        addressParts.add(place.subThoroughfare!);
      }
    } catch (e) {
      debugPrint('خطأ في معالجة بيانات العنوان: $e');
    }
    
    if (addressParts.isEmpty) {
      try {
        if (place.country?.isNotEmpty == true) {
          addressParts.add(place.country!);
        } else {
          addressParts.add('العراق، بغداد');
        }
      } catch (e) {
        addressParts.add('العراق، بغداد');
      }
    }
    
    return addressParts.join('، ');
  }

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
        
        if (defaultAddressId != null) {
          int defaultIndex = _addresses.indexWhere((addr) => addr.id == defaultAddressId);
          if (defaultIndex != -1) {
            _selectedAddress = _addresses[defaultIndex];
          }
        }
      }
      
      if (_addresses.isEmpty) {
        _addDefaultAddresses();
      }
      
      notifyListeners();
    } catch (e) {
      debugPrint('خطأ في تحميل العناوين: $e');
    }
  }

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

  void selectAddress(AddressModel address) {
    _selectedAddress = address;
    notifyListeners();
    _saveAddresses();
  }

  Future<void> addAddress(AddressModel address) async {
    _addresses.add(address);
    notifyListeners();
    await _saveAddresses();
  }

  Future<List<AddressModel>> searchAddresses(String query) async {
    if (query.trim().isEmpty) return [];
    
    try {
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

  // جلب العناوين من الخادم
  Future<void> fetchAddresses() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final token = await EnhancedSessionService.getToken();
      if (token == null) {
        _error = 'لم يتم العثور على token المصادقة';
        return;
      }
      final result = await ApiService.getUserAddresses(token);
      
      if (result['success'] == true && result['data'] != null) {
        // تعديل هنا: جلب قائمة العناوين من داخل data['addresses']
        final addressesData = (result['data']['addresses'] ?? []) as List;
        _detailedAddresses = addressesData
            .map((data) => DetailedAddress.fromJson(data))
            .toList();
        
        _addresses = _detailedAddresses
            .map((addr) => AddressModel(
                  id: addr.id,
                  name: addr.name,
                  fullAddress: addr.fullAddress,
                  latitude: addr.latitude ?? 0.0,
                  longitude: addr.longitude ?? 0.0,
                  isDefault: addr.isDefault,
                  type: addr.addressType,
                ))
            .toList();
      } else {
        _error = result['message'] ?? 'فشل في جلب العناوين';
      }
    } catch (e) {
      _error = 'خطأ في الاتصال بالخادم: $e';
      debugPrint('خطأ في جلب العناوين: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // إنشاء عنوان جديد
  Future<DetailedAddress?> createAddress(AddressCreateRequest request) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final token = await EnhancedSessionService.getToken();
      if (token == null) {
        _error = 'لم يتم العثور على token المصادقة';
        return null;
      }
      final result = await ApiService.addUserAddress(
        token: token,
        name: request.name,
        province: request.province,
        district: request.district,
        neighborhood: request.neighborhood,
        landmark: request.landmark,
        isDefault: request.isDefault,
      );

      if (result['success'] == true) {
        await fetchAddresses(); // إعادة جلب العناوين من الخادم
        final newAddressData = result['data'];
        if (newAddressData != null) {
          return DetailedAddress.fromJson(newAddressData);
        }
        return null;
      } else {
        _error = result['message'] ?? 'فشل في إضافة العنوان';
        return null;
      }
    } catch (e) {
      _error = 'خطأ في إنشاء العنوان: $e';
      debugPrint('خطأ في إنشاء العنوان: $e');
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // تحديث عنوان موجود
  Future<DetailedAddress?> updateDetailedAddress(String id, AddressUpdateRequest request) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final token = await EnhancedSessionService.getToken();
      if (token == null) {
        _error = 'لم يتم العثور على token المصادقة';
        return null;
      }
      final result = await ApiService.updateUserAddress(
        token: token,
        addressId: id,
        name: request.name ?? '',
        province: request.province ?? '',
        district: request.district ?? '',
        neighborhood: request.neighborhood ?? '',
        landmark: request.landmark ?? '',
        isDefault: request.isDefault ?? false,
      );

      if (result['success'] == true) {
        await fetchAddresses(); // إعادة جلب العناوين من الخادم
        final updatedAddressData = result['data'];
        if (updatedAddressData != null) {
          return DetailedAddress.fromJson(updatedAddressData);
        }
        return null;
      } else {
        _error = result['message'] ?? 'فشل في تحديث العنوان';
        return null;
      }
    } catch (e) {
      _error = 'خطأ في تحديث العنوان: $e';
      debugPrint('خطأ في تحديث العنوان: $e');
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Alias method for backward compatibility
  Future<DetailedAddress?> updateAddress(String id, AddressUpdateRequest request) async {
    return await updateDetailedAddress(id, request);
  }

  // حذف عنوان
  Future<bool> deleteAddress(String addressId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final token = await EnhancedSessionService.getToken();
      if (token == null) {
        _error = 'لم يتم العثور على token المصادقة';
        return false;
      }
      final result = await ApiService.deleteUserAddress(
        token: token,
        addressId: addressId,
      );

      if (result['success'] == true) {
        await fetchAddresses(); // إعادة جلب العناوين من الخادم
        return true;
      } else {
        _error = result['message'] ?? 'فشل في حذف العنوان';
        return false;
      }
    } catch (e) {
      _error = 'خطأ في حذف العنوان: $e';
      debugPrint('خطأ في حذف العنوان: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // تعيين عنوان افتراضي
  Future<bool> setDefaultAddress(String addressId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final token = await EnhancedSessionService.getToken();
      if (token == null) {
        _error = 'لم يتم العثور على token المصادقة';
        return false;
      }
      final result = await ApiService.setDefaultAddress(
        token: token,
        addressId: addressId,
      );

      if (result['success'] == true) {
        await fetchAddresses(); // إعادة جلب العناوين من الخادم
        return true;
      } else {
        _error = result['message'] ?? 'فشل في تعيين العنوان الافتراضي';
        return false;
      }
    } catch (e) {
      _error = 'خطأ في تعيين العنوان الافتراضي: $e';
      debugPrint('خطأ في تعيين العنوان الافتراضي: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // الحصول على العنوان الحالي من GPS
  Future<void> getCurrentLocationAddress() async {
    _isLoadingLocation = true;
    _locationError = null;
    notifyListeners();

    try {
      await getCurrentLocation();
      
      if (_currentAddress != null) {
        _currentLocationAddress = DetailedAddress(
          id: 'current_location',
          userId: '',
          name: _currentAddress!.name,
          province: 'بغداد',
          district: 'المنطقة الحالية',
          neighborhood: 'الحي الحالي',
          landmark: 'الموقع الحالي',
          fullAddress: _currentAddress!.fullAddress,
          latitude: _currentAddress!.latitude,
          longitude: _currentAddress!.longitude,
          addressType: AddressType.current,
          isDefault: false,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
      }
    } catch (e) {
      _locationError = e.toString();
      debugPrint('خطأ في الحصول على الموقع الحالي: $e');
    } finally {
      _isLoadingLocation = false;
      notifyListeners();
    }
  }

  // تهيئة الخدمة
  Future<void> initialize() async {
    await loadSavedAddresses();
    await fetchAddresses();
  }

  // Test method to verify ApiService access
  Future<void> testApiService() async {
    print("Testing ApiService access");
    print("Base URL: ${ApiService.currentBaseUrl}");
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
