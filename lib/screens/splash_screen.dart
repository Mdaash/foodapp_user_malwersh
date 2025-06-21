// lib/screens/splash_screen.dart
import 'package:flutter/material.dart';
import 'package:foodapp_user/services/enhanced_session_service.dart';
import 'package:foodapp_user/screens/welcome_screen.dart';
import 'package:foodapp_user/screens/home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkUserSession();
  }

  Future<void> _checkUserSession() async {
    // انتظار لمدة ثانيتين لعرض شاشة التحميل
    await Future.delayed(const Duration(seconds: 2));
    
    if (!mounted) return;
    
    // التحقق من حالة الجلسة وتوجيه المستخدم
    final hasSession = await EnhancedSessionService.hasActiveSession();
    final isLoggedIn = await EnhancedSessionService.isLoggedIn();
    
    if (hasSession && isLoggedIn) {
      // المستخدم مسجل الدخول - التحقق من صحة التوكن
      final isValid = await EnhancedSessionService.isTokenValid();
      if (isValid) {
        // المستخدم مسجل الدخول بتوكن صالح - الانتقال للشاشة الرئيسية
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      } else {
        // التوكن منتهي الصلاحية - تسجيل الخروج والانتقال لشاشة الترحيب
        await EnhancedSessionService.logout();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const WelcomeScreen()),
        );
      }
    } else if (hasSession) {
      // مستخدم ضيف - الانتقال للشاشة الرئيسية
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } else {
      // لا توجد جلسة - الانتقال لشاشة الترحيب
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const WelcomeScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // شعار التطبيق
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: const Color(0xFF00c1e8),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.restaurant,
                color: Colors.white,
                size: 50,
              ),
            ),
            const SizedBox(height: 30),
            
            // اسم التطبيق
            const Text(
              'تطبيق الطعام',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF00c1e8),
                fontFamily: 'Cairo',
              ),
            ),
            const SizedBox(height: 10),
            
            // نص فرعي
            const Text(
              'أفضل وجبة بين يديك',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
                fontFamily: 'Cairo',
              ),
            ),
            const SizedBox(height: 50),
            
            // مؤشر التحميل
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00c1e8)),
            ),
          ],
        ),
      ),
    );
  }
}
