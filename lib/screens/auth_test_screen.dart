// lib/screens/auth_test_screen.dart
import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class AuthTestScreen extends StatefulWidget {
  const AuthTestScreen({super.key});

  @override
  State<AuthTestScreen> createState() => _AuthTestScreenState();
}

class _AuthTestScreenState extends State<AuthTestScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _loginIdentifierController = TextEditingController();
  final TextEditingController _loginPasswordController = TextEditingController();

  bool _isLoading = false;
  String _message = '';
  bool _isServerHealthy = false;

  @override
  void initState() {
    super.initState();
    _checkServerHealth();
  }

  Future<void> _checkServerHealth() async {
    final isHealthy = await AuthService.checkServerHealth();
    setState(() {
      _isServerHealthy = isHealthy;
      _message = isHealthy ? 'الخادم متاح ✅' : 'الخادم غير متاح ❌';
    });
  }

  Future<void> _testRegister() async {
    if (_nameController.text.isEmpty || _phoneController.text.isEmpty || _passwordController.text.isEmpty) {
      setState(() => _message = 'يرجى تعبئة الحقول المطلوبة');
      return;
    }

    setState(() => _isLoading = true);

    final result = await AuthService.register(
      name: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
      email: _emailController.text.trim().isEmpty ? null : _emailController.text.trim(),
      password: _passwordController.text.trim(),
    );

    setState(() {
      _isLoading = false;
      _message = result['success'] ? '✅ ${result['message']}' : '❌ ${result['message']}';
    });
  }

  Future<void> _testLogin() async {
    if (_loginIdentifierController.text.isEmpty || _loginPasswordController.text.isEmpty) {
      setState(() => _message = 'يرجى تعبئة بيانات تسجيل الدخول');
      return;
    }

    setState(() => _isLoading = true);

    final result = await AuthService.login(
      identifier: _loginIdentifierController.text.trim(),
      password: _loginPasswordController.text.trim(),
    );

    setState(() {
      _isLoading = false;
      if (result['success']) {
        final token = result['data']['access_token'];
        _message = '✅ تم تسجيل الدخول بنجاح\nالتوكن: ${token.substring(0, 20)}...';
      } else {
        _message = '❌ ${result['message']}';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('اختبار APIs'),
          backgroundColor: const Color(0xFF00c1e8),
          foregroundColor: Colors.white,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // حالة الخادم
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Text(
                        'حالة الخادم',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(_isServerHealthy ? 'متصل ✅' : 'غير متصل ❌'),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: _checkServerHealth,
                        child: const Text('فحص الاتصال'),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // تسجيل حساب جديد
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'تسجيل حساب جديد',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'الاسم *',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _phoneController,
                        decoration: const InputDecoration(
                          labelText: 'رقم الهاتف *',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                          labelText: 'البريد الإلكتروني (اختياري)',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: 'كلمة المرور *',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _isLoading ? null : _testRegister,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00c1e8),
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('اختبار التسجيل'),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // تسجيل الدخول
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'تسجيل الدخول',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _loginIdentifierController,
                        decoration: const InputDecoration(
                          labelText: 'البريد الإلكتروني أو رقم الهاتف',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _loginPasswordController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: 'كلمة المرور',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _isLoading ? null : _testLogin,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('اختبار تسجيل الدخول'),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // رسائل النتائج
              if (_message.isNotEmpty)
                Card(
                  color: _message.contains('✅') ? Colors.green[50] : Colors.red[50],
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'النتيجة:',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(_message),
                      ],
                    ),
                  ),
                ),

              if (_isLoading)
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _loginIdentifierController.dispose();
    _loginPasswordController.dispose();
    super.dispose();
  }
}
