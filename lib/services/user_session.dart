import 'package:shared_preferences/shared_preferences.dart';

class UserSession {
  static UserSession? _instance;
  static UserSession get instance => _instance ??= UserSession._();
  
  UserSession._();

  // دالة callback لمسح السلة عند تغيير الجلسة
  static Function()? _onSessionChange;

  // تسجيل callback لمسح السلة
  static void setSessionChangeCallback(Function() callback) {
    _onSessionChange = callback;
  }

  // استدعاء callback عند تغيير الجلسة
  void _notifySessionChange() {
    if (_onSessionChange != null) {
      _onSessionChange!();
    }
  }

  // استدعاء callback - دالة عامة
  static void notifySessionChange() {
    if (_onSessionChange != null) {
      _onSessionChange!();
    }
  }

  // بيانات المستخدم
  String? _token;
  String? _userId;
  String? _userName;
  String? _userEmail;
  String? _userPhone;
  bool _isLoggedIn = false;
  bool _isGuest = false;

  // Getters
  String? get token => _token;
  String? get userId => _userId;
  String? get userName => _userName;
  String? get userEmail => _userEmail;
  String? get userPhone => _userPhone;
  bool get isLoggedIn => _isLoggedIn;
  bool get isGuest => _isGuest;

  // تسجيل الدخول
  Future<void> login({
    required String token,
    required String userId,
    required String userName,
    String? userEmail,
    String? userPhone,
  }) async {
    _token = token;
    _userId = userId;
    _userName = userName;
    _userEmail = userEmail;
    _userPhone = userPhone;
    _isLoggedIn = true;
    _isGuest = false;

    // حفظ البيانات محلياً
    await _saveToPrefs();
  }

  // الدخول كضيف
  Future<void> loginAsGuest() async {
    // مسح جميع البيانات أولاً
    await logout();
    
    // تعيين الحالة كضيف
    _token = null;
    _userId = null;
    _userName = 'ضيف';
    _userEmail = null;
    _userPhone = null;
    _isLoggedIn = false;
    _isGuest = true;

    await _saveToPrefs();
    
    print('تم تسجيل الدخول كضيف وتم مسح جميع البيانات السابقة');
    
    // مسح السلة عند الدخول كضيف
    _notifySessionChange();
  }

  // تسجيل الخروج
  Future<void> logout() async {
    _token = null;
    _userId = null;
    _userName = null;
    _userEmail = null;
    _userPhone = null;
    _isLoggedIn = false;
    _isGuest = false;

    await _clearPrefs();
    
    // مسح السلة عند تسجيل الخروج
    _notifySessionChange();
  }

  // تحميل البيانات من التخزين المحلي
  Future<void> loadFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      _token = prefs.getString('user_token');
      _userId = prefs.getString('user_id');
      _userName = prefs.getString('user_name');
      _userEmail = prefs.getString('user_email');
      _userPhone = prefs.getString('user_phone');
      _isLoggedIn = prefs.getBool('is_logged_in') ?? false;
      _isGuest = prefs.getBool('is_guest') ?? false;
    } catch (e) {
      print('خطأ في تحميل بيانات المستخدم: $e');
    }
  }

  // حفظ البيانات في التخزين المحلي
  Future<void> _saveToPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      if (_token != null) await prefs.setString('user_token', _token!);
      if (_userId != null) await prefs.setString('user_id', _userId!);
      if (_userName != null) await prefs.setString('user_name', _userName!);
      if (_userEmail != null) await prefs.setString('user_email', _userEmail!);
      if (_userPhone != null) await prefs.setString('user_phone', _userPhone!);
      
      await prefs.setBool('is_logged_in', _isLoggedIn);
      await prefs.setBool('is_guest', _isGuest);
    } catch (e) {
      print('خطأ في حفظ بيانات المستخدم: $e');
    }
  }

  // مسح البيانات من التخزين المحلي
  Future<void> _clearPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      await prefs.remove('user_token');
      await prefs.remove('user_id');
      await prefs.remove('user_name');
      await prefs.remove('user_email');
      await prefs.remove('user_phone');
      await prefs.remove('is_logged_in');
      await prefs.remove('is_guest');
    } catch (e) {
      print('خطأ في مسح بيانات المستخدم: $e');
    }
  }

  // التحقق من صحة الجلسة
  bool isValidSession() {
    return _isLoggedIn && _token != null && _userId != null;
  }

  // طباعة معلومات الجلسة للتشخيص
  void printSessionInfo() {
    print('=== معلومات الجلسة ===');
    print('مسجل الدخول: $_isLoggedIn');
    print('ضيف: $_isGuest');
    print('الاسم: $_userName');
    print('البريد: $_userEmail');
    print('الهاتف: $_userPhone');
    print('رمز الدخول: ${_token != null ? 'موجود' : 'غير موجود'}');
    print('معرف المستخدم: $_userId');
    print('====================');
  }
}
