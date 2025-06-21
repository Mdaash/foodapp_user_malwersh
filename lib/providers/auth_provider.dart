// lib/providers/auth_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/enhanced_session_service.dart';

// حالة المصادقة
class AuthState {
  final bool isLoggedIn;
  final bool isGuest;
  final Map<String, dynamic>? userData;
  final bool isLoading;

  const AuthState({
    this.isLoggedIn = false,
    this.isGuest = false,
    this.userData,
    this.isLoading = false,
  });

  AuthState copyWith({
    bool? isLoggedIn,
    bool? isGuest,
    Map<String, dynamic>? userData,
    bool? isLoading,
  }) {
    return AuthState(
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      isGuest: isGuest ?? this.isGuest,
      userData: userData ?? this.userData,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

// مُعدِّل حالة المصادقة
class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(const AuthState()) {
    _checkAuthStatus();
  }

  // فحص حالة المصادقة عند بدء التطبيق
  Future<void> _checkAuthStatus() async {
    state = state.copyWith(isLoading: true);
    
    try {
      final isLoggedIn = await EnhancedSessionService.isLoggedIn();
      final isGuest = await EnhancedSessionService.isGuest();
      final userData = await EnhancedSessionService.getSessionData();
      
      state = state.copyWith(
        isLoggedIn: isLoggedIn,
        isGuest: isGuest,
        userData: userData,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false);
    }
  }

  // تسجيل الدخول
  Future<bool> login(String identifier, String password) async {
    state = state.copyWith(isLoading: true);
    
    try {
      // استخدام خدمة المصادقة الموجودة
      final userData = await EnhancedSessionService.getSessionData();
      
      state = state.copyWith(
        isLoggedIn: true,
        isGuest: false,
        userData: userData,
        isLoading: false,
      );
      
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false);
      return false;
    }
  }

  // تسجيل الخروج
  Future<void> logout() async {
    state = state.copyWith(isLoading: true);
    
    await EnhancedSessionService.logout();
    
    state = const AuthState();
  }

  // الدخول كضيف
  Future<void> enterAsGuest() async {
    await EnhancedSessionService.setGuestMode();
    
    state = state.copyWith(
      isLoggedIn: false,
      isGuest: true,
      userData: null,
    );
  }

  // تحديث بيانات المستخدم
  void updateUserData(Map<String, dynamic> userData) {
    state = state.copyWith(userData: userData);
  }
}

// مزود حالة المصادقة
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});

// مزودات مساعدة للوصول السريع
final isLoggedInProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).isLoggedIn;
});

final isGuestProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).isGuest;
});

final userDataProvider = Provider<Map<String, dynamic>?>((ref) {
  return ref.watch(authProvider).userData;
});

final authLoadingProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).isLoading;
});
