import 'package:flutter/material.dart';

class AccountScreen extends StatelessWidget {
  final VoidCallback? onBack;
  const AccountScreen({super.key, this.onBack});

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF00c1e8);
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          title: const Text('الحساب', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          iconTheme: const IconThemeData(color: Colors.black),
          automaticallyImplyLeading: false,
        ),
        body: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          children: [
            // User card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text('محمد علي', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                        SizedBox(height: 4),
                        Text('07800868280', style: TextStyle(color: Colors.grey, fontSize: 14)),
                      ],
                    ),
                  ),
                  const CircleAvatar(
                    radius: 28,
                    backgroundColor: Color(0xFFE0E0E0),
                    child: Icon(Icons.person, size: 36, color: Colors.white),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Language
            _AccountTile(
              icon: Icons.language,
              title: 'اللغة',
              subtitle: 'العربية',
              color: primaryColor,
              trailing: const Icon(Icons.chevron_right),
            ),
            _AccountTile(
              icon: Icons.map,
              title: 'العناوين المحفوظة',
              color: primaryColor,
              trailing: const Icon(Icons.chevron_right),
            ),
            _AccountTile(
              icon: Icons.edit,
              title: 'تغيير الهاتف',
              subtitle: 'تغيير رقم الهاتف الخاص بحسابك',
              color: primaryColor,
              trailing: const Icon(Icons.chevron_right),
            ),
            _AccountTile(
              icon: Icons.notifications,
              title: 'اعدادات الاشعارات',
              subtitle: 'تخصيص الاشعارات الخاصة بك',
              color: primaryColor,
              trailing: const Icon(Icons.chevron_right),
            ),
            _AccountTile(
              icon: Icons.mail_outline,
              title: 'الشكاوى والاقتراحات',
              color: primaryColor,
              trailing: const Icon(Icons.chevron_right),
            ),
            _AccountTile(
              icon: Icons.list_alt,
              title: 'الاستبيانات',
              color: primaryColor,
              trailing: const Icon(Icons.chevron_right),
            ),
            _AccountTile(
              icon: Icons.apps,
              title: 'ايقونة التطبيق',
              color: primaryColor,
              trailing: const Icon(Icons.chevron_right),
            ),
            _AccountTile(
              icon: Icons.share,
              title: 'مشاركة التطبيق',
              color: primaryColor,
              trailing: const Icon(Icons.chevron_right),
            ),
            _AccountTile(
              icon: Icons.info_outline,
              title: 'عن طلباتي',
              color: primaryColor,
              trailing: const Icon(Icons.chevron_right),
            ),
            const SizedBox(height: 16),
            // Logout
            _AccountTile(
              icon: Icons.logout,
              title: 'تسجيل خروج',
              color: Colors.red,
              trailing: const Icon(Icons.chevron_right, color: Colors.red),
            ),
            // Delete account
            _AccountTile(
              icon: Icons.delete_forever,
              title: 'حذف الحساب',
              color: Colors.red,
              trailing: const Icon(Icons.chevron_right, color: Colors.red),
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
  final String? subtitle;
  final Color color;
  final Widget? trailing;
  const _AccountTile({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.color,
    this.trailing,
  });
  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 2, horizontal: 0),
      leading: CircleAvatar(
        backgroundColor: Color.fromRGBO(color.r.toInt(), color.g.toInt(), color.b.toInt(), 0.08),
        child: Icon(icon, color: color),
      ),
      title: Text(title, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
      subtitle: subtitle != null ? Text(subtitle!, style: const TextStyle(fontSize: 12)) : null,
      trailing: trailing,
      onTap: () {},
      shape: const Border(bottom: BorderSide(color: Color(0xFFF2F2F2))),
    );
  }
}
