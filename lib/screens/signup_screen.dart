// lib/screens/signup_screen.dart
import 'package:flutter/material.dart';
import '../services/api_service.dart';

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

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading    = true;
      _errorMessage = null;
    });

    // تسجيل المعلومات الأساسية للمستخدم فقط
    // العناوين سيتم إدارتها في جدول منفصل لاحقاً
    final result = await ApiService.register(
      name:    _nameController.text.trim(),
      email:   _emailController.text.trim().isEmpty ? "" : _emailController.text.trim(),
      password:_passwordController.text.trim(),
      phone:   _phoneController.text.trim(),
    );
    // بعد الـ await، تأكد أن الـ State ما زال mounted قبل أي تفاعل مع context
    if (!mounted) return;

    setState(() => _isLoading = false);

    if (result["success"] == true) {
      // قبل استخدام ScaffoldMessenger أو Navigator تأكد مجدداً من mounted
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("تم إنشاء الحساب بنجاح ✅ يمكنك إضافة العناوين لاحقاً عند الطلب"),
          duration: Duration(seconds: 4),
        ),
      );
      Navigator.pop(context);
    } else {
      setState(() => _errorMessage = result["message"] as String?);
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
                // ملاحظة للمستخدم
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue[200]!),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.blue, size: 20),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'المعلومات الأساسية فقط مطلوبة للتسجيل ⭐ البريد الإلكتروني اختياري. العناوين ستتم إضافتها عند الحاجة.',
                          style: TextStyle(fontSize: 14, color: Colors.blue),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
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
      obscureText: isPassword,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        filled: true,
        fillColor: Colors.grey[50],
        suffixIcon: isRequired 
          ? const Icon(Icons.star, color: Colors.red, size: 12)
          : const Icon(Icons.star_border, color: Colors.grey, size: 12),
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
