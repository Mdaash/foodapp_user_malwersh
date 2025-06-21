// lib/screens/forgot_password_screen.dart
import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _identifierController = TextEditingController();
  bool _isLoading = false;
  String? _message;
  bool _isSuccess = false;

  @override
  void dispose() {
    _identifierController.dispose();
    super.dispose();
  }

  void _handlePasswordReset() async {
    final identifier = _identifierController.text.trim();

    if (identifier.isEmpty) {
      setState(() {
        _message = "يرجى إدخال رقم الهاتف أو البريد الإلكتروني";
        _isSuccess = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _message = null;
    });

    try {
      // طلب إعادة تعيين كلمة المرور
      final result = await AuthService.requestPasswordReset(
        identifier: identifier,
      );

      setState(() {
        _isLoading = false;
        _message = result['message'];
        _isSuccess = result['success'];
      });

      if (result['success']) {
        // إظهار رسالة نجاح وإمكانية العودة بعد 3 ثوان
        Future.delayed(const Duration(seconds: 3), () {
          if (mounted) {
            Navigator.pop(context);
          }
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _message = 'حدث خطأ في الاتصال: ${e.toString()}';
        _isSuccess = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('استعادة كلمة المرور'),
          backgroundColor: const Color(0xFF00c1e8),
          foregroundColor: Colors.white,
        ),
        backgroundColor: Colors.white,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                
                // أيقونة وعنوان
                Center(
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: const Color(0xFF00c1e8).withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.lock_reset,
                          size: 50,
                          color: Color(0xFF00c1e8),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'استعادة كلمة المرور',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF333333),
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'أدخل رقم الهاتف أو البريد الإلكتروني المرتبط بحسابك\nوسنرسل لك رابط إعادة تعيين كلمة المرور',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF666666),
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 40),
                
                // حقل الإدخال
                TextField(
                  controller: _identifierController,
                  keyboardType: TextInputType.text,
                  decoration: const InputDecoration(
                    labelText: 'رقم الهاتف أو البريد الإلكتروني',
                    hintText: 'example@email.com أو 07XXXXXXXX',
                    prefixIcon: Icon(Icons.person_outline),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                      borderSide: BorderSide(color: Color(0xFF00c1e8), width: 2),
                    ),
                  ),
                ),
                
                const SizedBox(height: 30),
                
                // زر الإرسال
                SizedBox(
                  width: double.infinity,
                  child: _isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFF00c1e8),
                          ),
                        )
                      : ElevatedButton(
                          onPressed: _handlePasswordReset,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF00c1e8),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 2,
                          ),
                          child: const Text(
                            'إرسال رابط الاستعادة',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                          ),
                        ),
                ),
                
                // رسالة الحالة
                if (_message != null) ...[
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: _isSuccess 
                          ? Colors.green.withOpacity(0.1)
                          : Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _isSuccess 
                            ? Colors.green.withOpacity(0.3)
                            : Colors.red.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _isSuccess ? Icons.check_circle_outline : Icons.error_outline,
                          color: _isSuccess ? Colors.green : Colors.red,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _message!,
                            style: TextStyle(
                              color: _isSuccess ? Colors.green : Colors.red,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                
                const SizedBox(height: 30),
                
                // رابط العودة لتسجيل الدخول
                Center(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      'العودة إلى تسجيل الدخول',
                      style: TextStyle(
                        color: Color(0xFF00c1e8),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
