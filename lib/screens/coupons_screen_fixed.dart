import 'package:flutter/material.dart';
import '../services/user_service.dart';

class CouponsScreen extends StatefulWidget {
  const CouponsScreen({super.key});

  @override
  State<CouponsScreen> createState() => _CouponsScreenState();
}

class _CouponsScreenState extends State<CouponsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _couponController = TextEditingController();
  final UserService _userService = UserService();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _userService.addListener(_onUserServiceUpdate);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _couponController.dispose();
    _userService.removeListener(_onUserServiceUpdate);
    super.dispose();
  }

  void _onUserServiceUpdate() {
    if (mounted) {
      setState(() {});
    }
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
                      const Color(0xFF00c1e8).withValues(alpha: 0.15),
                      const Color(0xFF00c1e8).withValues(alpha: 0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF00c1e8).withValues(alpha: 0.3)),
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
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
                decoration: InputDecoration(
                  hintText: 'أدخل كود القسيمة',
                  hintStyle: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 16,
                    fontWeight: FontWeight.normal,
                    letterSpacing: 0.5,
                  ),
                  prefixIcon: const Icon(
                    Icons.local_offer,
                    color: Color(0xFF00c1e8),
                  ),
                  filled: true,
                  fillColor: const Color(0xFF00c1e8).withValues(alpha: 0.05),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      color: const Color(0xFF00c1e8).withValues(alpha: 0.3),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      color: const Color(0xFF00c1e8).withValues(alpha: 0.3),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(
                      color: Color(0xFF00c1e8),
                      width: 2,
                    ),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'إلغاء',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF00c1e8), Color(0xFF0099d4)],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: ElevatedButton(
                onPressed: () {
                  final code = _couponController.text.trim();
                  if (code.isNotEmpty) {
                    try {
                      _userService.addCoupon(code);
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('تم إضافة القسيمة بنجاح: $code'),
                          backgroundColor: const Color(0xFF4CAF50),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                      _couponController.clear();
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('خطأ في إضافة القسيمة: ${e.toString()}'),
                          backgroundColor: Colors.red,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'إضافة',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCouponDetails(Map<String, dynamic> coupon) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: Container(
          height: MediaQuery.of(context).size.height * 0.7,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFF8FAFF), Color(0xFFFFFFFF)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          ),
          child: Column(
            children: [
              Container(
                width: 50,
                height: 5,
                margin: const EdgeInsets.symmetric(vertical: 15),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF00c1e8).withValues(alpha: 0.1),
                      const Color(0xFF7C4DFF).withValues(alpha: 0.05),
                    ],
                  ),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF00c1e8), Color(0xFF7C4DFF)],
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(
                        Icons.local_offer_rounded,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'تفاصيل القسيمة',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF222B45),
                            ),
                          ),
                          Text(
                            'كود: ${coupon['code']}',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      _buildDetailItem(
                        'نوع الخصم',
                        coupon['discountType'] == 'percentage' 
                            ? '${coupon['discountValue'] ?? coupon['discount']}% خصم' 
                            : '${coupon['discountValue'] ?? coupon['discount']} ريال خصم',
                        Icons.percent,
                        const Color(0xFF00c1e8),
                      ),
                      const SizedBox(height: 16),
                      _buildDetailItem(
                        'الحد الأدنى للطلب',
                        '${coupon['minOrder'] ?? 0} ريال',
                        Icons.shopping_cart,
                        const Color(0xFF7C4DFF),
                      ),
                      const SizedBox(height: 16),
                      _buildDetailItem(
                        'تاريخ الانتهاء',
                        coupon['expiry'] ?? coupon['expiryDate'] ?? 'غير محدد',
                        Icons.calendar_today,
                        const Color(0xFFFF6B35),
                      ),
                      const SizedBox(height: 16),
                      _buildDetailItem(
                        'الوصف',
                        coupon['description'] ?? 'لا يوجد وصف',
                        Icons.description,
                        const Color(0xFF4CAF50),
                      ),
                      const Spacer(),
                      if (coupon['status'] == 'valid')
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF00c1e8), Color(0xFF7C4DFF)],
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: ElevatedButton(
                            onPressed: () async {
                              final messenger = ScaffoldMessenger.of(context);
                              final navigator = Navigator.of(context);
                              try {
                                await _userService.useCoupon(coupon['code']);
                                navigator.pop();
                                if (mounted) {
                                  messenger.showSnackBar(
                                    SnackBar(
                                      content: Text('تم تطبيق القسيمة: ${coupon['code']}'),
                                      backgroundColor: const Color(0xFF4CAF50),
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  );
                                }
                              } catch (e) {
                                if (mounted) {
                                  messenger.showSnackBar(
                                    SnackBar(
                                      content: Text('خطأ في استخدام القسيمة: ${e.toString()}'),
                                      backgroundColor: Colors.red,
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  );
                                }
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              foregroundColor: Colors.white,
                              shadowColor: Colors.transparent,
                              padding: const EdgeInsets.symmetric(vertical: 18),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              elevation: 0,
                            ),
                            child: const Text(
                              'استخدم القسيمة',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailItem(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withValues(alpha: 0.1),
            color.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: const Color(0xFF222B45).withValues(alpha: 0.7),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    color: Color(0xFF222B45),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCouponCard(Map<String, dynamic> coupon, {bool isUsed = false, bool isExpired = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () => _showCouponDetails(coupon),
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: isExpired
                ? LinearGradient(
                    colors: [
                      Colors.grey.withValues(alpha: 0.3),
                      Colors.grey.withValues(alpha: 0.1),
                    ],
                  )
                : isUsed
                    ? LinearGradient(
                        colors: [
                          const Color(0xFF4CAF50).withValues(alpha: 0.15),
                          const Color(0xFF4CAF50).withValues(alpha: 0.05),
                        ],
                      )
                    : LinearGradient(
                        colors: [
                          const Color(0xFF00c1e8).withValues(alpha: 0.15),
                          const Color(0xFF7C4DFF).withValues(alpha: 0.1),
                        ],
                      ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isExpired
                  ? Colors.grey.withValues(alpha: 0.3)
                  : isUsed
                      ? const Color(0xFF4CAF50).withValues(alpha: 0.3)
                      : const Color(0xFF00c1e8).withValues(alpha: 0.3),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: isExpired
                    ? Colors.grey.withValues(alpha: 0.1)
                    : isUsed
                        ? const Color(0xFF4CAF50).withValues(alpha: 0.15)
                        : const Color(0xFF00c1e8).withValues(alpha: 0.15),
                blurRadius: 12,
                offset: const Offset(0, 4),
                spreadRadius: -2,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: isExpired
                          ? LinearGradient(
                              colors: [Colors.grey, Colors.grey.shade700],
                            )
                          : isUsed
                              ? const LinearGradient(
                                  colors: [Color(0xFF4CAF50), Color(0xFF388E3C)],
                                )
                              : const LinearGradient(
                                  colors: [Color(0xFF00c1e8), Color(0xFF7C4DFF)],
                                ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      isExpired
                          ? Icons.access_time_filled
                          : isUsed
                              ? Icons.check_circle
                              : Icons.local_offer,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          coupon['code'],
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF222B45),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          coupon['title'] ?? coupon['description'] ?? 'قسيمة خصم',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: isExpired
                          ? Colors.grey.withValues(alpha: 0.2)
                          : isUsed
                              ? const Color(0xFF4CAF50).withValues(alpha: 0.2)
                              : const Color(0xFF00c1e8).withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      isExpired
                          ? 'منتهية'
                          : isUsed
                              ? 'مستخدمة'
                              : 'صالحة',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isExpired
                            ? Colors.grey[700]
                            : isUsed
                                ? const Color(0xFF4CAF50)
                                : const Color(0xFF00c1e8),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'قيمة الخصم',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                          Text(
                            coupon['discountType'] == 'percentage' 
                                ? '${coupon['discountValue'] ?? coupon['discount']}%' 
                                : '${coupon['discountValue'] ?? coupon['discount']} ريال',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF222B45),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 40,
                      color: Colors.grey[300],
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'الحد الأدنى',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                          Text(
                            '${coupon['minOrder'] ?? 0} ريال',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF222B45),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 40,
                      color: Colors.grey[300],
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'ينتهي في',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                          Text(
                            coupon['expiry'] ?? coupon['expiryDate'] ?? 'غير محدد',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF222B45),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(String title, String subtitle, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF00c1e8).withValues(alpha: 0.15),
                  const Color(0xFF00c1e8).withValues(alpha: 0.05),
                ],
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 64,
              color: const Color(0xFF00c1e8),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF222B45),
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFF),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF00c1e8), Color(0xFF7C4DFF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          title: const Text(
            'قسائم الخصم',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          centerTitle: true,
          actions: [
            IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.add,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              onPressed: _showAddCouponDialog,
            ),
          ],
        ),
        body: Column(
          children: [
            // Header with gradient background for tabs
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF00c1e8), Color(0xFF7C4DFF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Column(
                children: [
                  // Tab bar with glassmorphism effect
                  Container(
                    margin: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.3),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                          spreadRadius: -5,
                        ),
                      ],
                    ),
                    child: TabBar(
                      controller: _tabController,
                      labelColor: Colors.white,
                      unselectedLabelColor: Colors.white.withValues(alpha: 0.7),
                      labelStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      unselectedLabelStyle: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                      indicator: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFF00c1e8).withValues(alpha: 0.95),
                            const Color(0xFF7C4DFF).withValues(alpha: 0.85),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.3),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF00c1e8).withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                            spreadRadius: -1,
                          ),
                          BoxShadow(
                            color: Colors.white.withValues(alpha: 0.7),
                            blurRadius: 2,
                            offset: const Offset(0, -1),
                          ),
                        ],
                      ),
                      indicatorSize: TabBarIndicatorSize.tab,
                      indicatorPadding: const EdgeInsets.all(6),
                      tabs: const [
                        Tab(text: 'صالحة'),
                        Tab(text: 'مستخدمة'),
                        Tab(text: 'منتهية'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Tab content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // القسائم الصالحة
                  _userService.validCoupons.isEmpty
                      ? _buildEmptyState(
                          'لا يوجد قسائم',
                          'يمكنك الحصول على قسائم عن طريق استخدام النقاط في برنامج المكافآت',
                          Icons.local_offer,
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _userService.validCoupons.length,
                          itemBuilder: (context, index) {
                            return _buildCouponCard(_userService.validCoupons[index]);
                          },
                        ),
                  // القسائم المستخدمة
                  _userService.usedCoupons.isEmpty
                      ? _buildEmptyState(
                          'لا يوجد قسائم مستخدمة',
                          'ستظهر هنا القسائم التي تم استخدامها سابقاً',
                          Icons.check_circle_outline,
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _userService.usedCoupons.length,
                          itemBuilder: (context, index) {
                            return _buildCouponCard(_userService.usedCoupons[index], isUsed: true);
                          },
                        ),
                  // القسائم المنتهية
                  _userService.expiredCoupons.isEmpty
                      ? _buildEmptyState(
                          'لا يوجد قسائم منتهية',
                          'ستظهر هنا القسائم التي انتهت صلاحيتها',
                          Icons.access_time_filled,
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _userService.expiredCoupons.length,
                          itemBuilder: (context, index) {
                            return _buildCouponCard(_userService.expiredCoupons[index], isExpired: true);
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
