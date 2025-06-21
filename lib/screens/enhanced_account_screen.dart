// lib/screens/enhanced_account_screen.dart
import 'package:flutter/material.dart';
import '../services/enhanced_session_service.dart';
import 'login_screen.dart';
import 'signup_screen.dart';
import 'intro_screen.dart';
import 'addresses_screen.dart';
import 'home_screen.dart';

class EnhancedAccountScreen extends StatefulWidget {
  final VoidCallback? onBack;

  const EnhancedAccountScreen({super.key, this.onBack});

  @override
  State<EnhancedAccountScreen> createState() => _EnhancedAccountScreenState();
}

class _EnhancedAccountScreenState extends State<EnhancedAccountScreen> {
  Map<String, dynamic>? sessionData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSessionData();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _loadSessionData() async {
    final data = await EnhancedSessionService.getSessionData();
    setState(() {
      sessionData = data;
      isLoading = false;
    });
  }

  Future<void> _handleLogout() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('تسجيل الخروج'),
          content: const Text('هل أنت متأكد من رغبتك في تسجيل الخروج؟'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await EnhancedSessionService.logout();
                if (mounted) {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const IntroScreen()),
                    (route) => false,
                  );
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('تسجيل الخروج', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final isLoggedIn = sessionData?['isLoggedIn'] ?? false;
    final isGuest = sessionData?['isGuest'] ?? false;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'حسابي',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
            fontSize: 18,
          ),
        ),
        backgroundColor: Colors.grey[50], // أوف وايت
        foregroundColor: Colors.black87,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.black87,
          ),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const HomeScreen()),
            );
          },
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _loadSessionData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              // Header Section
              _buildHeaderSection(isLoggedIn, isGuest),
              
              const SizedBox(height: 20),
              
              // Menu Section
              _buildMenuSection(isLoggedIn, isGuest),
              
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderSection(bool isLoggedIn, bool isGuest) {
    if (isLoggedIn) {
      return _buildLoggedInHeader();
    } else if (isGuest) {
      return _buildGuestHeader();
    } else {
      return _buildNotLoggedInHeader();
    }
  }

  Widget _buildLoggedInHeader() {
    final userName = sessionData?['userName'] ?? 'المستخدم';
    final userEmail = sessionData?['userEmail'];
    final userPhone = sessionData?['userPhone'];
    
    // طباعة للتشخيص
    print('🔍 بيانات الجلسة في بطاقة المستخدم: $sessionData');
    print('👤 اسم المستخدم: $userName');
    print('📱 رقم الهاتف: $userPhone');
    print('📧 الإيميل: $userEmail');
    
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.15),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
        border: Border.all(color: Colors.grey[100]!, width: 1),
      ),
      child: Column(
        children: [
          // صورة المستخدم والمعلومات الأساسية
          Row(
            children: [
              // Avatar محسن
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF00c1e8).withValues(alpha: 0.2),
                      const Color(0xFF00c1e8).withValues(alpha: 0.1),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFF00c1e8).withValues(alpha: 0.3),
                    width: 3,
                  ),
                ),
                child: const Icon(
                  Icons.person_rounded,
                  color: Color(0xFF00c1e8),
                  size: 35,
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // اسم المستخدم
                    Text(
                      userName,
                      style: const TextStyle(
                        color: Colors.black87,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // معلومات الاتصال مع تحسين التصميم
                    if (userPhone != null && userPhone.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey[200]!, width: 1),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.phone_rounded,
                              color: const Color(0xFF00c1e8),
                              size: 16,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              userPhone,
                              style: TextStyle(
                                color: Colors.grey[700],
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      )
                    else if (userEmail != null && userEmail.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey[200]!, width: 1),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.email_rounded,
                              color: const Color(0xFF00c1e8),
                              size: 16,
                            ),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                userEmail,
                                style: TextStyle(
                                  color: Colors.grey[700],
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              // نقطة إشارة للحالة
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.green.withValues(alpha: 0.3),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          // خط فاصل إضافي إذا كان هناك بيانات إضافية
          if (userPhone != null && userPhone.isNotEmpty && userEmail != null && userEmail.isNotEmpty) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF00c1e8).withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFF00c1e8).withValues(alpha: 0.1),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.email_rounded,
                    color: const Color(0xFF00c1e8),
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      userEmail,
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildGuestHeader() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF00c1e8).withValues(alpha: 0.1), // لون التطبيق الأساسي بشفافية عالية
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF00c1e8).withValues(alpha: 0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00c1e8).withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Avatar محسن بلون التطبيق
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF00c1e8).withValues(alpha: 0.3),
                      const Color(0xFF00c1e8).withValues(alpha: 0.15),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFF00c1e8).withValues(alpha: 0.4),
                    width: 3,
                  ),
                ),
                child: const Icon(
                  Icons.person_outline_rounded,
                  color: Color(0xFF00c1e8),
                  size: 35,
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // النص الجديد
                    const Text(
                      'مرحباً بك',
                      style: TextStyle(
                        color: Color(0xFF00c1e8),
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // النص التوضيحي
                    Text(
                      'قم بتسجيل الدخول او انشاء حساب لتتمتع بتجربة لا مثيل لها',
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // زر تسجيل الدخول فقط
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00c1e8),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
                shadowColor: const Color(0xFF00c1e8).withValues(alpha: 0.3),
              ),
              child: const Text(
                'تسجيل الدخول',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotLoggedInHeader() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[300]!, width: 1),
      ),
      child: Column(
        children: [
          Icon(
            Icons.account_circle_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'مرحباً بك!',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'سجل الدخول أو أنشئ حساباً جديداً للاستفادة من جميع الميزات',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00c1e8),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text('تسجيل الدخول'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SignUpScreen()),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF00c1e8),
                    side: const BorderSide(color: Color(0xFF00c1e8)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text('إنشاء حساب'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMenuSection(bool isLoggedIn, bool isGuest) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          if (isLoggedIn) ...[
            _buildMenuItem(
              icon: Icons.person_outline,
              title: 'الملف الشخصي',
              subtitle: 'عرض وتعديل البيانات الشخصية',
              color: Colors.blue,
              onTap: () => _showComingSoon('الملف الشخصي'),
            ),
            _buildDivider(),
            _buildMenuItem(
              icon: Icons.location_on_outlined,
              title: 'عناويني',
              subtitle: 'إدارة عناوين التوصيل',
              color: Colors.green,
              onTap: () async {
                final userData = await EnhancedSessionService.getUserData();
                if (userData != null && mounted) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddressesScreen(),
                    ),
                  );
                }
              },
            ),
            _buildDivider(),
            _buildMenuItem(
              icon: Icons.shopping_bag_outlined,
              title: 'طلباتي',
              subtitle: 'عرض تاريخ الطلبات',
              color: Colors.orange,
              onTap: () => _showComingSoon('طلباتي'),
            ),
            _buildDivider(),
            _buildMenuItem(
              icon: Icons.payment_outlined,
              title: 'طرق الدفع',
              subtitle: 'إدارة البطاقات والمحافظ',
              color: Colors.purple,
              onTap: () => _showComingSoon('طرق الدفع'),
            ),
            _buildDivider(),
            _buildMenuItem(
              icon: Icons.favorite_outline,
              title: 'المفضلة',
              subtitle: 'المطاعم والأطباق المفضلة',
              color: Colors.red,
              onTap: () => _showComingSoon('المفضلة'),
            ),
            _buildDivider(),
          ],
          
          // General Menu Items (for all users)
          _buildMenuItem(
            icon: Icons.notifications_outlined,
            title: 'الإشعارات',
            subtitle: 'إعدادات التنبيهات',
            color: const Color(0xFF00c1e8),
            onTap: () => _showComingSoon('الإشعارات'),
          ),
          _buildDivider(),
          _buildMenuItem(
            icon: Icons.language_outlined,
            title: 'اللغة',
            subtitle: 'العربية',
            color: Colors.indigo,
            onTap: () => _showComingSoon('اللغة'),
          ),
          _buildDivider(),
          _buildMenuItem(
            icon: Icons.help_outline,
            title: 'المساعدة والدعم',
            subtitle: 'الأسئلة الشائعة وخدمة العملاء',
            color: Colors.teal,
            onTap: () => _showComingSoon('المساعدة والدعم'),
          ),
          _buildDivider(),
          _buildMenuItem(
            icon: Icons.info_outline,
            title: 'حول التطبيق',
            subtitle: 'معلومات النسخة والشروط',
            color: Colors.grey,
            onTap: () => _showComingSoon('حول التطبيق'),
          ),
          
          if (isLoggedIn) ...[
            _buildDivider(),
            _buildMenuItem(
              icon: Icons.logout,
              title: 'تسجيل الخروج',
              subtitle: 'إنهاء الجلسة الحالية',
              color: Colors.red,
              onTap: _handleLogout,
              isDestructive: true,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      leading: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: isDestructive ? Colors.red.withValues(alpha: 0.1) : color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          icon,
          color: isDestructive ? Colors.red : color,
          size: 24,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: isDestructive ? Colors.red : Colors.black87,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 13,
          color: Colors.grey[600],
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: Colors.grey[400],
      ),
      onTap: onTap,
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      color: Colors.grey[200],
      indent: 68,
    );
  }

  void _showComingSoon(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature - قريباً...'),
        backgroundColor: const Color(0xFF00c1e8),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
