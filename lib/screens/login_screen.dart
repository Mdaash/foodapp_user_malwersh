// lib/screens/login_screen.dart
import 'package:flutter/material.dart';
import 'package:foodapp_user/services/api_service.dart';
import 'package:foodapp_user/services/user_session.dart';
import 'package:foodapp_user/screens/home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController    = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _loginError;

  // دالة لاختبار الاتصال
  Future<void> _testConnection() async {
    setState(() => _isLoading = true);
    final result = await ApiService.testConnection();
    setState(() => _isLoading = false);
    
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(result["message"]),
        backgroundColor: result["success"] ? Colors.green : Colors.red,
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final input    = _emailController.text.trim(); // يمكن أن يكون بريد إلكتروني أو رقم هاتف
    final password = _passwordController.text.trim();

    if (input.isEmpty || password.isEmpty) {
      setState(() => _loginError = "يرجى تعبئة جميع الحقول");
      return;
    }

    setState(() {
      _isLoading   = true;
      _loginError = null;
    });

    Map<String, dynamic> result;
    
    // استخدام دالة login الموحدة التي تقبل البريد الإلكتروني أو رقم الهاتف
    print("محاولة الدخول بالمعرف: $input");
    result = await ApiService.login(input, password);
    
    print("نتيجة تسجيل الدخول: $result"); // للتشخيص
    
    // تأكّد أن الـ State ما زال موجودًا قبل استخدام context أو setState
    if (!mounted) return;

    setState(() => _isLoading = false);

    if (result["success"] == true) {
      print("تسجيل الدخول نجح!"); // للتشخيص
      
      // حفظ بيانات المستخدم في الجلسة
      final userData = result["data"];
      await UserSession.instance.login(
        token: userData["user_id"], // استخدام user_id كـ token مؤقتاً
        userId: userData["user_id"],
        userName: userData["user"]["name"],
        userEmail: userData["user"]["email"],
        userPhone: userData["user"]["phone"],
      );
      
      // مرّر هنا أيضًا mounted لوضع Snackbar أو Navigator
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم تسجيل الدخول بنجاح ✅')),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } else {
      print("تسجيل الدخول فشل: ${result["message"]}"); // للتشخيص
      // معالجة رسالة الخطأ بشكل صحيح
      String errorMessage = "فشل تسجيل الدخول";
      if (result["message"] != null) {
        if (result["message"] is String) {
          errorMessage = result["message"];
        } else if (result["message"] is List) {
          // إذا كانت رسالة الخطأ عبارة عن قائمة (من FastAPI)
          errorMessage = "خطأ في البيانات المدخلة";
        }
      }
      setState(() => _loginError = errorMessage);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        extendBodyBehindAppBar: true,
        backgroundColor: Colors.white,
        body: SafeArea(
          top: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const SizedBox(height: 60),
                const Text(
                  'مرحباً بعودتك 👋',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF00c1e8),
                  ),
                ),
                const SizedBox(height: 40),
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.text, // تغيير لقبول النص العام
                  decoration: const InputDecoration(
                    labelText: 'البريد الإلكتروني أو رقم الهاتف',
                    hintText: 'example@email.com أو 07XXXXXXXX',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'كلمة المرور',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : ElevatedButton(
                          onPressed: _handleLogin,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF00c1e8),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: const Text(
                            'تسجيل الدخول',
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                        ),
                ),
                const SizedBox(height: 12),
                // زر اختبار الاتصال للتشخيص
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: _isLoading ? null : _testConnection,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF00c1e8),
                      side: const BorderSide(color: Color(0xFF00c1e8)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text(
                      'اختبار الاتصال بالخادم',
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // زر الدخول كضيف
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: _isLoading ? null : () async {
                      // حفظ حالة الضيف
                      await UserSession.instance.loginAsGuest();
                      
                      // الانتقال مباشرة للشاشة الرئيسية كضيف
                      if (!mounted) return;
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const HomeScreen()),
                      );
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.grey[600],
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text(
                      'الدخول كضيف',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                if (_loginError != null) ...[
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.red.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.error_outline,
                          color: Colors.red,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _loginError!,
                            style: const TextStyle(
                              color: Colors.red,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
