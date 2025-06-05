import 'package:flutter/material.dart';

class CouponsScreen extends StatefulWidget {
  const CouponsScreen({super.key});

  @override
  State<CouponsScreen> createState() => _CouponsScreenState();
}

class _CouponsScreenState extends State<CouponsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _couponController = TextEditingController();

  // بيانات وهمية للقسائم
  final List<Map<String, dynamic>> _validCoupons = [
    {
      'code': 'SAVE20',
      'title': 'خصم 20%',
      'description': 'خصم 20% على جميع الطلبات',
      'discount': '20%',
      'expiry': '2025-12-31',
      'minOrder': 50.0,
    },
    {
      'code': 'WELCOME10',
      'title': 'خصم ترحيبي',
      'description': 'خصم 10% للمستخدمين الجدد',
      'discount': '10%',
      'expiry': '2025-06-30',
      'minOrder': 25.0,
    },
  ];

  final List<Map<String, dynamic>> _usedCoupons = [];
  final List<Map<String, dynamic>> _expiredCoupons = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _couponController.dispose();
    super.dispose();
  }

  void _showAddCouponDialog() {
    showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          backgroundColor: Colors.white,
          title: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF00c1e8), Color(0xFF0099d4)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Row(
              children: [
                Icon(Icons.local_offer_rounded, color: Colors.white, size: 24),
                SizedBox(width: 12),
                Text(
                  'إضافة قسيمة جديدة', 
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold, 
                    fontSize: 18
                  )
                ),
              ],
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF00c1e8).withValues(alpha: 0.1),
                      const Color(0xFF00c1e8).withValues(alpha: 0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF00c1e8).withValues(alpha: 0.2)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: const Color(0xFF00c1e8), size: 20),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'لديك قسيمة خصم؟ أدخل الكود واستمتع بالتوفير',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _couponController,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 2),
                decoration: InputDecoration(
                  hintText: 'أدخل رمز القسيمة',
                  hintStyle: TextStyle(color: Colors.grey[500], letterSpacing: 1),
                  filled: true,
                  fillColor: const Color(0xFF00c1e8).withValues(alpha: 0.05),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: const Color(0xFF00c1e8).withValues(alpha: 0.2)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: Color(0xFF00c1e8), width: 2),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: const Color(0xFF00c1e8).withValues(alpha: 0.2)),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.amber[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.lightbulb_outline, color: Colors.amber[700], size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'نصيحة: يمكنك الحصول على قسائم من قسم المكافآت',
                        style: TextStyle(color: Colors.amber[700], fontSize: 12, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('إلغاء', style: TextStyle(color: Colors.grey[600])),
            ),
            ElevatedButton(
              onPressed: () {
                if (_couponController.text.isNotEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('تم إضافة القسيمة بنجاح!'),
                      backgroundColor: const Color(0xFF00c1e8),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  );
                  _couponController.clear();
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00c1e8),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: const Text('إضافة', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCouponCard(Map<String, dynamic> coupon, {bool isExpired = false, bool isUsed = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: isExpired || isUsed 
                ? Colors.grey.withValues(alpha: 0.15)
                : const Color(0xFF00c1e8).withValues(alpha: 0.25),
            blurRadius: 12,
            offset: const Offset(0, 4),
            spreadRadius: 1,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isExpired || isUsed
                  ? [
                      Colors.grey[100]!,
                      Colors.grey[200]!,
                    ]
                  : [
                      const Color(0xFF00c1e8),
                      const Color(0xFF0099d4),
                    ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.white.withValues(alpha: 0.1),
                  Colors.white.withValues(alpha: 0.05),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                // أيقونة القسيمة
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.white.withValues(alpha: 0.25),
                        Colors.white.withValues(alpha: 0.15),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.4),
                      width: 1.5,
                    ),
                  ),
                  child: Icon(
                    Icons.local_offer_rounded,
                    color: isExpired || isUsed ? Colors.grey[600] : Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                // تفاصيل القسيمة
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        coupon['title'] ?? '',
                        style: TextStyle(
                          color: isExpired || isUsed ? Colors.grey[600] : Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        coupon['description'] ?? '',
                        style: TextStyle(
                          color: isExpired || isUsed 
                              ? Colors.grey[500] 
                              : Colors.white.withValues(alpha: 0.9),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: isExpired || isUsed 
                              ? Colors.grey.withValues(alpha: 0.2) 
                              : Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isExpired || isUsed 
                                ? Colors.grey.withValues(alpha: 0.3) 
                                : Colors.white.withValues(alpha: 0.3),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.access_time,
                              color: isExpired || isUsed 
                                  ? Colors.grey[500] 
                                  : Colors.white,
                              size: 16,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'صالحة حتى ${coupon['expiry'] ?? 'غير محدد'}',
                              style: TextStyle(
                                color: isExpired || isUsed 
                                    ? Colors.grey[500] 
                                    : Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // خصم أو حالة القسيمة
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    color: isExpired || isUsed 
                        ? Colors.grey.withValues(alpha: 0.2) 
                        : Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isExpired || isUsed 
                          ? Colors.grey.withValues(alpha: 0.3) 
                          : Colors.white.withValues(alpha: 0.3),
                      width: 2,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        coupon['discount'] ?? '0%',
                        style: TextStyle(
                          color: isExpired || isUsed ? Colors.grey[600] : Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        isExpired 
                            ? 'منتهية' 
                            : isUsed 
                                ? 'مستخدمة' 
                                : 'خصم',
                        style: TextStyle(
                          color: isExpired || isUsed 
                              ? Colors.grey[500] 
                              : Colors.white.withValues(alpha: 0.9),
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
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

  Widget _buildEmptyState(String title, String subtitle, IconData icon) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF00c1e8).withValues(alpha: 0.1),
                    const Color(0xFF00c1e8).withValues(alpha: 0.05),
                  ],
                ),
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFF00c1e8).withValues(alpha: 0.2),
                  width: 2,
                ),
              ),
              child: Icon(icon, size: 64, color: const Color(0xFF00c1e8)),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D3436),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            'قسائم الخصم',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          centerTitle: true,
        ),
        body: Column(
          children: [
            // شريط الإضافة العلوي
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF00c1e8), Color(0xFF0099d4)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF00c1e8).withValues(alpha: 0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.local_offer_rounded, color: Colors.white, size: 24),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'لديك قسيمة خصم؟',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'أضفها واستمتع بالتوفير',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _showAddCouponDialog,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF00c1e8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    ),
                    child: const Text('إضافة'),
                  ),
                ],
              ),
            ),
            // Tabs
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TabBar(
                controller: _tabController,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.grey[600],
                indicator: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF00c1e8), Color(0xFF0099d4)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                tabs: const [
                  Tab(text: 'صالحة'),
                  Tab(text: 'مستخدمة'),
                  Tab(text: 'منتهية'),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Tab content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Valid coupons
                  _validCoupons.isEmpty
                      ? _buildEmptyState(
                          'لا يوجد قسائم',
                          'يمكنك الحصول على قسائم عن طريق استخدام النقاط في برنامج المكافآت',
                          Icons.local_offer,
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _validCoupons.length,
                          itemBuilder: (context, index) {
                            return _buildCouponCard(_validCoupons[index]);
                          },
                        ),
                  // Used coupons
                  _usedCoupons.isEmpty
                      ? _buildEmptyState(
                          'لا يوجد قسائم مستخدمة',
                          'ستظهر هنا القسائم التي استخدمتها',
                          Icons.history,
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _usedCoupons.length,
                          itemBuilder: (context, index) {
                            return _buildCouponCard(_usedCoupons[index], isUsed: true);
                          },
                        ),
                  // Expired coupons
                  _expiredCoupons.isEmpty
                      ? _buildEmptyState(
                          'لا يوجد قسائم منتهية',
                          'ستظهر هنا القسائم المنتهية الصلاحية',
                          Icons.access_time,
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _expiredCoupons.length,
                          itemBuilder: (context, index) {
                            return _buildCouponCard(_expiredCoupons[index], isExpired: true);
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
