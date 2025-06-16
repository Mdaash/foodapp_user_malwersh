import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class UserService extends ChangeNotifier {
  static final UserService _instance = UserService._internal();
  factory UserService() => _instance;
  UserService._internal();

  // إعدادات الاتصال
  static const String baseUrl = "http://127.0.0.1:8003";

  // بيانات المستخدم الفعلية
  bool _isLoggedIn = false;
  String _userName = '';
  String _userEmail = '';
  String _userPhone = '';
  String _userToken = '';
  Map<String, String> _userAddress = {};
  int _currentPoints = 0;
  
  // قوائم الكوبونات
  final List<Map<String, dynamic>> _validCoupons = [];
  final List<Map<String, dynamic>> _usedCoupons = [];
  final List<Map<String, dynamic>> _expiredCoupons = [];

  // Getters
  bool get isLoggedIn => _isLoggedIn;
  String get userName => _userName;
  String get userEmail => _userEmail;
  String get userPhone => _userPhone;
  String get userToken => _userToken;
  Map<String, String> get userAddress => _userAddress;
  int get currentPoints => _currentPoints;
  List<Map<String, dynamic>> get validCoupons => _validCoupons;
  List<Map<String, dynamic>> get usedCoupons => _usedCoupons;
  List<Map<String, dynamic>> get expiredCoupons => _expiredCoupons;
  List<Map<String, dynamic>> get availableRewards => _availableRewards;

  // قائمة المكافآت المتاحة
  final List<Map<String, dynamic>> _availableRewards = [
    {
      'id': 'discount_10',
      'title': 'خصم 10%',
      'description': 'خصم 10% على طلبك القادم',
      'points_required': 500,
      'type': 'discount',
      'value': 10,
    },
    {
      'id': 'discount_15',
      'title': 'خصم 15%',
      'description': 'خصم 15% على طلبك القادم',
      'points_required': 750,
      'type': 'discount',
      'value': 15,
    },
    {
      'id': 'free_delivery',
      'title': 'توصيل مجاني',
      'description': 'توصيل مجاني لطلبك القادم',
      'points_required': 300,
      'type': 'free_delivery',
      'value': 0,
    },
  ];

  // تهيئة الخدمة
  Future<void> initialize() async {
    await _loadUserData();
    notifyListeners();
  }

  // تحميل بيانات المستخدم من SharedPreferences
  Future<void> _loadUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      _isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
      _userName = prefs.getString('userName') ?? '';
      _userEmail = prefs.getString('userEmail') ?? '';
      _userPhone = prefs.getString('userPhone') ?? '';
      _userToken = prefs.getString('userToken') ?? '';
      _currentPoints = prefs.getInt('currentPoints') ?? 0;
      
      // تحميل العنوان
      final addressJson = prefs.getString('userAddress');
      if (addressJson != null) {
        final Map<String, dynamic> addressMap = json.decode(addressJson);
        _userAddress = addressMap.cast<String, String>();
      }
      
      // تحميل الكوبونات
      final validCouponsJson = prefs.getString('validCoupons');
      if (validCouponsJson != null) {
        final List<dynamic> validCouponsList = json.decode(validCouponsJson);
        _validCoupons.clear();
        _validCoupons.addAll(validCouponsList.cast<Map<String, dynamic>>());
      }
      
    } catch (e) {
      if (kDebugMode) {
      }
    }
  }

  // حفظ بيانات المستخدم
  Future<void> _saveUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      await prefs.setBool('isLoggedIn', _isLoggedIn);
      await prefs.setString('userName', _userName);
      await prefs.setString('userEmail', _userEmail);
      await prefs.setString('userPhone', _userPhone);
      await prefs.setString('userToken', _userToken);
      await prefs.setInt('currentPoints', _currentPoints);
      await prefs.setString('userAddress', json.encode(_userAddress));
      await prefs.setString('validCoupons', json.encode(_validCoupons));
      
    } catch (e) {
      if (kDebugMode) {
      }
    }
  }

  // تسجيل الدخول
  Future<bool> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        _isLoggedIn = true;
        _userName = data['user']['name'] ?? '';
        _userEmail = data['user']['email'] ?? '';
        _userPhone = data['user']['phone'] ?? '';
        _userToken = data['token'] ?? '';
        _currentPoints = data['user']['points'] ?? 0;
        
        // حتى لو لم يكن هناك عنوان محفوظ، نحتاج لتهيئة العنوان
        if (data['user']['address'] != null) {
          _userAddress = Map<String, String>.from(data['user']['address']);
        } else {
          _userAddress = {};
        }
        
        await _saveUserData();
        notifyListeners();
        return true;
      }
      
      return false;
    } catch (e) {
      if (kDebugMode) {
      }
      return false;
    }
  }

  // إنشاء حساب جديد
  Future<bool> register(String name, String email, String password, String phone) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/register'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'name': name,
          'email': email,
          'password': password,
          'phone': phone,
        }),
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        
        _isLoggedIn = true;
        _userName = data['user']['name'] ?? name;
        _userEmail = data['user']['email'] ?? email;
        _userPhone = data['user']['phone'] ?? phone;
        _userToken = data['token'] ?? '';
        _currentPoints = data['user']['points'] ?? 0;
        _userAddress = {};
        
        await _saveUserData();
        notifyListeners();
        return true;
      }
      
      return false;
    } catch (e) {
      if (kDebugMode) {
      }
      return false;
    }
  }

  // تسجيل الخروج
  Future<void> logout() async {
    try {
      _isLoggedIn = false;
      _userName = '';
      _userEmail = '';
      _userPhone = '';
      _userToken = '';
      _userAddress.clear();
      _currentPoints = 0;
      _validCoupons.clear();
      _usedCoupons.clear();
      _expiredCoupons.clear();
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
      }
    }
  }

  // إضافة كوبون
  Future<bool> addCoupon(String code) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/coupons/add'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_userToken',
        },
        body: json.encode({'code': code}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _validCoupons.add(data['coupon']);
        await _saveUserData();
        notifyListeners();
        return true;
      }
      
      return false;
    } catch (e) {
      if (kDebugMode) {
      }
      return false;
    }
  }

  // استبدال مكافأة
  Future<Map<String, dynamic>?> redeemReward(String rewardId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/rewards/redeem'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_userToken',
        },
        body: json.encode({'reward_id': rewardId}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _currentPoints = data['remaining_points'] ?? _currentPoints;
        final newCoupon = data['coupon'];
        if (newCoupon != null) {
          _validCoupons.add(newCoupon);
        }
        await _saveUserData();
        notifyListeners();
        return newCoupon;
      }
      
      return null;
    } catch (e) {
      if (kDebugMode) {
      }
      return null;
    }
  }
}
