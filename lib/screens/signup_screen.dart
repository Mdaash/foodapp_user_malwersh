// lib/screens/signup_screen.dart
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/enhanced_session_service.dart';
import 'home_screen.dart';
import 'login_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController     = TextEditingController();
  final TextEditingController _emailController    = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _phoneController    = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // محاولة التسجيل
      final result = await AuthService.register(
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        email: _emailController.text.trim().isEmpty ? null : _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      setState(() => _isLoading = false);

      if (!mounted) return;

      if (result['success']) {
        // تسجيل دخول آلي بعد إنشاء الحساب
        setState(() {
          _isLoading = true;
          _errorMessage = null;
        });

        // محاولة تسجيل الدخول آلياً
        final loginResult = await AuthService.login(
          identifier: _phoneController.text.trim(),
          password: _passwordController.text.trim(),
        );

        if (loginResult['success']) {
          // حفظ بيانات الجلسة
          final data = loginResult['data'];
          final userData = data['user'] ?? {};
          
          await EnhancedSessionService.saveSession(
            token: data['access_token'] ?? 'temp_token',
            userId: data['user_id']?.toString() ?? userData['user_id']?.toString() ?? 'temp_user_id',
            userName: userData['name'] ?? _nameController.text.trim(),
            userPhone: userData['phone'] ?? _phoneController.text.trim(),
            userEmail: userData['email'] ?? (_emailController.text.trim().isEmpty ? null : _emailController.text.trim()),
          );

          // عرض رسالة نجاح
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? 'تم إنشاء الحساب وتسجيل الدخول بنجاح'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 3),
            ),
          );

          // الانتقال للشاشة الرئيسية
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const HomeScreen()),
          );
        } else {
          // إذا فشل تسجيل الدخول الآلي، اعرض رسالة نجاح التسجيل واطلب تسجيل الدخول
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? 'تم إنشاء الحساب بنجاح. يرجى تسجيل الدخول الآن.'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 3),
            ),
          );
          
          // الانتقال لشاشة تسجيل الدخول
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const LoginScreen()),
          );
        }
      } else {
        // عرض رسالة الخطأ
        setState(() {
          _errorMessage = result['message'] ?? 'حدث خطأ غير متوقع';
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'حدث خطأ في الاتصال: ${e.toString()}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          title: const Row(
            children: [
              Icon(Icons.person_add, size: 24),
              SizedBox(width: 8),
              Text("إنشاء حساب جديد"),
            ],
          ),
          backgroundColor: const Color(0xFF00c1e8),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24.0, 100.0, 24.0, 24.0), // مساحة أكبر من الأعلى
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 20),
                _buildTextField(_nameController, "الاسم الكامل", isRequired: true),
                const SizedBox(height: 16),
                _buildTextField(_emailController, "البريد الإلكتروني (اختياري)",
                    type: TextInputType.emailAddress, isRequired: false),
                const SizedBox(height: 16),
                _buildTextField(_passwordController, "كلمة المرور",
                    isPassword: true, isRequired: true),
                const SizedBox(height: 16),
                _buildTextField(_phoneController, "رقم الهاتف",
                    type: TextInputType.phone, isRequired: true),
                const SizedBox(height: 24),
                if (_errorMessage != null) ...[
                  Container(
                    margin: const EdgeInsets.only(bottom: 16),
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
                            _errorMessage!,
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
                SizedBox(
                  width: double.infinity,
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : ElevatedButton(
                          onPressed: _handleRegister,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF00c1e8),
                            padding:
                                const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: const Text(
                            'إنشاء الحساب',
                            style: TextStyle(
                                fontSize: 16, color: Colors.white),
                          ),
                        ),
                ),
                
                // فاصل "أو"
                const SizedBox(height: 30),
                Row(
                  children: [
                    const Expanded(child: Divider()),
                    const SizedBox(width: 16),
                    Text(
                      'أو',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(child: Divider()),
                  ],
                ),
                
                // رابط تسجيل الدخول
                const SizedBox(height: 20),
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'لديك حساب بالفعل؟ ',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (_) => const LoginScreen()),
                          );
                        },
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero,
                        ),
                        child: const Text(
                          'سجل دخول',
                          style: TextStyle(
                            color: Color(0xFF00c1e8),
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
      TextEditingController controller,
      String label, {
      TextInputType type = TextInputType.text,
      bool isPassword = false,
      bool isRequired = true,
    }) {
    return TextFormField(
      controller: controller,
      keyboardType: type,
      obscureText: isPassword ? _obscurePassword : false,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        filled: true,
        fillColor: Colors.grey[50],
        suffixIcon: isPassword 
          ? IconButton(
              icon: Icon(
                _obscurePassword ? Icons.visibility : Icons.visibility_off,
              ),
              onPressed: () {
                setState(() {
                  _obscurePassword = !_obscurePassword;
                });
              },
            )
          : (isRequired 
              ? const Icon(Icons.star, color: Colors.red, size: 12)
              : const Icon(Icons.star_border, color: Colors.grey, size: 12)),
      ),
      validator: (value) {
        // إذا كان الحقل غير مطلوب وفارغ، فلا مشكلة
        if (!isRequired && (value == null || value.trim().isEmpty)) {
          return null;
        }
        
        // إذا كان الحقل مطلوب أو غير فارغ، قم بالتحقق
        if (isRequired && (value == null || value.trim().isEmpty)) {
          return 'يرجى إدخال $label';
        }
        
        // تحقق إضافي للبريد الإلكتروني (فقط إذا تم إدخال قيمة)
        if (type == TextInputType.emailAddress && value != null && value.trim().isNotEmpty) {
          if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
            return 'يرجى إدخال بريد إلكتروني صحيح';
          }
        }
        
        // تحقق إضافي لكلمة المرور
        if (isPassword && value != null && value.length < 6) {
          return 'يجب أن تكون كلمة المرور 6 أحرف على الأقل';
        }
        
        // تحقق إضافي لرقم الهاتف
        if (type == TextInputType.phone && value != null && value.trim().isNotEmpty) {
          if (!RegExp(r'^[0-9+\-\s]+$').hasMatch(value)) {
            return 'يرجى إدخال رقم هاتف صحيح';
          }
        }
        
        return null;
      },
    );
  }
}
