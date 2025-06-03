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
  final TextEditingController _nameController    = TextEditingController();
  final TextEditingController _emailController   = TextEditingController();
  final TextEditingController _passwordController= TextEditingController();
  final TextEditingController _phoneController   = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading    = true;
      _errorMessage = null;
    });

    final result = await ApiService.register(
      name:    _nameController.text.trim(),
      email:   _emailController.text.trim(),
      password:_passwordController.text.trim(),
      phone:   _phoneController.text.trim(),
      address: _addressController.text.trim(),
    );
    // بعد الـ await، تأكد أن الـ State ما زال mounted قبل أي تفاعل مع context
    if (!mounted) return;

    setState(() => _isLoading = false);

    if (result["success"] == true) {
      // قبل استخدام ScaffoldMessenger أو Navigator تأكد مجدداً من mounted
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("تم إنشاء الحساب بنجاح ✅")),
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
        appBar: AppBar(
          title: const Text("إنشاء حساب جديد"),
          backgroundColor: const Color(0xFF00c1e8),
          foregroundColor: Colors.white,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 20),
                _buildTextField(_nameController, "الاسم الكامل"),
                const SizedBox(height: 16),
                _buildTextField(_emailController, "البريد الإلكتروني",
                    type: TextInputType.emailAddress),
                const SizedBox(height: 16),
                _buildTextField(_passwordController, "كلمة المرور",
                    isPassword: true),
                const SizedBox(height: 16),
                _buildTextField(_phoneController, "رقم الهاتف",
                    type: TextInputType.phone),
                const SizedBox(height: 16),
                _buildTextField(_addressController, "العنوان"),
                const SizedBox(height: 24),
                if (_errorMessage != null)
                  Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.red),
                  ),
                const SizedBox(height: 12),
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
    }) {
    return TextFormField(
      controller: controller,
      keyboardType: type,
      obscureText: isPassword,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'يرجى إدخال $label';
        }
        return null;
      },
    );
  }
}
