import 'package:flutter/material.dart';
import 'address_management_screen.dart';
import '../services/user_session.dart';
import 'login_screen.dart';

class AccountScreen extends StatefulWidget {
  final VoidCallback? onBack;

  const AccountScreen({super.key, this.onBack});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  @override
  void initState() {
    super.initState();
    // تحميل بيانات المستخدم
    UserSession.instance.loadFromPrefs();
  }

  @override
  Widget build(BuildContext context) {
    final userSession = UserSession.instance;
    final isLoggedIn = userSession.isLoggedIn;
    final userName = userSession.userName ?? 'ضيف';
    final userEmail = userSession.userEmail ?? (userSession.isGuest ? 'مستخدم ضيف' : 'غير محدد');
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight + MediaQuery.of(context).padding.top + 4),
        child: Container(
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top + 4,
            left: 16,
            right: 16,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
          ),
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: const Text(
              'الحساب',
              style: TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            centerTitle: true,
            automaticallyImplyLeading: false,
          ),
        ),
      ),
      body: Container(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            // Profile Section
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Color(0xFF00c1e8),
                    child: Icon(
                      Icons.person,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          userName,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          userEmail,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            
            // Menu Items
            Expanded(
              child: ListView(
                children: [
                  _AccountTile(
                    icon: Icons.person_outline,
                    title: 'الملف الشخصي',
                    color: Colors.blue,
                  ),
                  _AccountTile(
                    icon: Icons.location_on_outlined,
                    title: 'العناوين',
                    color: Colors.green,
                    onTap: () {
                      if (userSession.isLoggedIn && userSession.token != null && userSession.userId != null) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AddressManagementScreen(
                              token: userSession.token!,
                              userId: userSession.userId!,
                            ),
                          ), 
                        );
                      } else {
                        // إظهار رسالة للمستخدمين الضيوف
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('يجب تسجيل الدخول أولاً لإدارة العناوين'),
                            backgroundColor: Colors.orange,
                          ),
                        );
                      }
                    },
                  ),
                  _AccountTile(
                    icon: Icons.payment_outlined,
                    title: 'طرق الدفع',
                    color: Colors.purple,
                  ),
                  _AccountTile(
                    icon: Icons.notifications_outlined,
                    title: 'الإشعارات',
                    color: Color(0xFF00c1e8),
                  ),
                  _AccountTile(
                    icon: Icons.help_outline,
                    title: 'المساعدة',
                    color: Colors.teal,
                  ),
                  _AccountTile(
                    icon: Icons.settings_outlined,
                    title: 'الإعدادات',
                    color: Colors.grey,
                  ),
                  SizedBox(height: 20),
                  _AccountTile(
                    icon: Icons.logout,
                    title: 'تسجيل الخروج',
                    color: Colors.red,
                    onTap: () async {
                      // إظهار تأكيد تسجيل الخروج
                      final shouldLogout = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('تسجيل الخروج'),
                          content: const Text('هل أنت متأكد من تسجيل الخروج؟'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(false),
                              child: const Text('إلغاء'),
                            ),
                            ElevatedButton(
                              onPressed: () => Navigator.of(context).pop(true),
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                              child: const Text('تسجيل الخروج'),
                            ),
                          ],
                        ),
                      );

                      if (shouldLogout == true) {
                        await UserSession.instance.logout();
                        if (!mounted) return;
                        
                        // العودة لشاشة تسجيل الدخول
                        Navigator.of(context).pushNamedAndRemoveUntil(
                          '/', 
                          (route) => false,
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AccountTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback? onTap;

  const _AccountTile({
    required this.icon,
    required this.title,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 8),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: color,
            size: 22,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: Colors.grey[400],
        ),
        onTap: onTap ?? () {
          // Handle default tap
        },
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        tileColor: Colors.grey[50],
      ),
    );
  }
}