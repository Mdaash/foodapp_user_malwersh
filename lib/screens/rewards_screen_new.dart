import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:foodapp_user/screens/coupons_screen.dart';

class RewardsScreen extends StatefulWidget {
  const RewardsScreen({super.key});

  @override
  State<RewardsScreen> createState() => _RewardsScreenState();
}

class _RewardsScreenState extends State<RewardsScreen> {
  // الألوان الموحدة للتطبيق
  static const Color _primaryColor = Color(0xFF00c1e8);
  static const Color _primaryDark = Color(0xFF0099B8);
  
  // بيانات تجريبية للمكافآت المتاحة للاستبدال
  int _currentPoints = 1250; // نقاط تجريبية للاختبار
  final List<Map<String, dynamic>> _availableRewards = [
    {
      'title': 'خصم 500 د.ع من أي مطعم',
      'subtitle': 'خصم فوري على جميع المطاعم',
      'points': 100,
      'image': 'assets/images/banner1.png',
      'restaurant': 'جميع المطاعم',
      'description': 'احصل على خصم 500 د.ع على أي طلب من أي مطعم في التطبيق. العرض صالح لمدة 30 يوماً من تاريخ الاستبدال.',
      'minOrder': 3000.0,
      'maxUse': 'مرتين شهرياً',
    },
    {
      'title': 'خصم 1500 د.ع من تشيلي هاوس',
      'subtitle': 'وليز وباي بيتزاريا',
      'points': 300,
      'image': 'assets/images/banner2.png',
      'restaurant': 'عالم البرجر',
      'description': 'وفر 1500 د.ع على طلبك من تشيلي هاوس ولیز وباي بيتزاريا. الخصم ينطبق على الطلبات التي قيمتها أكبر من 8000 د.ع.',
      'minOrder': 8000.0,
      'maxUse': 'مرتين شهرياً',
    },
    {
      'title': 'خصم 2000 د.ع من مطعم الفاخر',
      'subtitle': 'برجر وبيتزا وسندويشات',
      'points': 450,
      'image': 'assets/images/banner3.png',
      'restaurant': 'مطعم الفاخر',
      'description': 'احصل على خصم 2000 د.ع من مطعم الفاخر على جميع أصناف البرجر والبيتزا والسندويشات.',
      'minOrder': 10000.0,
      'maxUse': 'مرة واحدة شهرياً',
    },
    {
      'title': 'خصم 1000 د.ع من مقهى الرياض',
      'subtitle': 'قهوة ومشروبات وحلويات',
      'points': 200,
      'image': 'assets/images/banner4.png',
      'restaurant': 'مقهى الرياض',
      'description': 'خصم 1000 د.ع على جميع المشروبات والحلويات من مقهى الرياض. يشمل القهوة والعصائر والحلويات الشرقية.',
      'minOrder': 5000.0,
      'maxUse': 'ثلاث مرات شهرياً',
    },
    {
      'title': 'وجبة مجانية من KFC',
      'subtitle': 'دجاج مقلي مع المشروب',
      'points': 600,
      'image': 'assets/images/banner1.png',
      'restaurant': 'KFC',
      'description': 'احصل على وجبة دجاج مقلي كاملة مع المشروب والبطاطس مجاناً. العرض صالح في جميع فروع KFC.',
      'minOrder': 0.0,
      'maxUse': 'مرة واحدة شهرياً',
    },
    {
      'title': 'خصم 25% على الطلبات الكبيرة',
      'subtitle': 'للطلبات أكبر من 20000 د.ع',
      'points': 800,
      'image': 'assets/images/banner2.png',
      'restaurant': 'جميع المطاعم',
      'description': 'خصم 25% على أي طلب قيمته أكبر من 20000 د.ع من أي مطعم في التطبيق. العرض مثالي للطلبات الجماعية.',
      'minOrder': 20000.0,
      'maxUse': 'مرة واحدة كل شهرين',
    },
    {
      'title': 'توصيل مجاني لمدة شهر',
      'subtitle': 'لجميع الطلبات',
      'points': 1200,
      'image': 'assets/images/banner3.png',
      'restaurant': 'جميع المطاعم',
      'description': 'احصل على توصيل مجاني لجميع طلباتك لمدة شهر كامل بغض النظر عن قيمة الطلب أو المسافة.',
      'minOrder': 0.0,
      'maxUse': 'مرة واحدة كل 3 شهور',
    },
    {
      'title': 'خصم 3000 د.ع للطلبات الفاخرة',
      'subtitle': 'مطاعم مختارة فقط',
      'points': 900,
      'image': 'assets/images/banner4.png',
      'restaurant': 'المطاعم الفاخرة',
      'description': 'خصم 3000 د.ع على طلبك من المطاعم الفاخرة المختارة. يشمل المطاعم العالمية والمحلية الراقية.',
      'minOrder': 15000.0,
      'maxUse': 'مرة واحدة شهرياً',
    },
  ];

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Widget _buildPointsHeader() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _primaryColor.withValues(alpha: 0.15),
            _primaryDark.withValues(alpha: 0.12),
            _primaryDark.withValues(alpha: 0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          stops: [0.0, 0.6, 1.0],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: _primaryColor.withValues(alpha: 0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: _primaryColor.withValues(alpha: 0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: [
              Colors.white.withValues(alpha: 0.4),
              Colors.white.withValues(alpha: 0.2),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        padding: const EdgeInsets.all(4),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        _primaryColor.withValues(alpha: 0.15),
                        _primaryColor.withValues(alpha: 0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: _primaryColor.withValues(alpha: 0.3),
                      width: 1.5,
                    ),
                  ),
                  child: const Icon(
                    Icons.stars_rounded,
                    color: _primaryColor,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'مصطفى محمد أهلاً بك',
                        style: TextStyle(
                          color: _primaryColor,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'في مكافآتك',
                        style: TextStyle(
                          color: _primaryColor.withValues(alpha: 0.7),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: _primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _primaryColor.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: _showCouponsBottomSheet,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                        decoration: BoxDecoration(
                          color: _primaryColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _primaryColor.withValues(alpha: 0.3),
                            width: 1,
                          ),
                        ),
                        child: Column(
                          children: [
                            const Icon(Icons.local_offer_rounded, color: _primaryColor, size: 24),
                            const SizedBox(height: 8),
                            const Text(
                              'القسائم',
                              style: TextStyle(
                                color: _primaryColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),                                Text(
                                  '$_currentPoints',
                                  style: TextStyle(
                                    color: _primaryColor.withValues(alpha: 0.8),
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      decoration: BoxDecoration(
                        color: _primaryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _primaryColor.withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          const Icon(Icons.stars_rounded, color: _primaryColor, size: 24),
                          const SizedBox(height: 8),
                          const Text(
                            'النقاط',
                            style: TextStyle(
                              color: _primaryColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            '$_currentPoints',
                            style: TextStyle(
                              color: _primaryColor.withValues(alpha: 0.8),
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),                            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.amber.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning, color: Colors.amber[700], size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'كل ما طلبت أكثر، كل ما حصلت على نقاط أكثر',
                      style: TextStyle(
                        color: Colors.amber[700],
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            // زر إضافة نقاط تجريبية
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _currentPoints += 500;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('تم إضافة 500 نقطة تجريبية! إجمالي النقاط: $_currentPoints'),
                    backgroundColor: Colors.green,
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
              icon: const Icon(Icons.add_circle, color: Colors.white),
              label: const Text(
                'إضافة 500 نقطة تجريبية',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCouponsBottomSheet() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CouponsScreen()),
    );
  }

  void _showRewardDetails(Map<String, dynamic> reward) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.75,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: Colors.grey, width: 0.5)),
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'تفاصيل العرض',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // صورة العرض
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.asset(
                          reward['image'] as String,
                          width: double.infinity,
                          height: 200,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // عنوان العرض
                      Text(
                        reward['title'] as String,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: _primaryColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      
                      // المطعم
                      Text(
                        reward['subtitle'] as String,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // النقاط المطلوبة
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: _primaryColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _primaryColor.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.stars_rounded,
                              color: _primaryColor,
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'النقاط المطلوبة',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: _primaryColor,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Text(
                                    '${reward['points']} نقطة',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: _primaryColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // وصف العرض
                      const Text(
                        'تفاصيل العرض',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        reward['description'] as String,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // معلومات إضافية
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.info_outline, size: 16, color: Colors.grey),
                                const SizedBox(width: 8),
                                const Text(
                                  'معلومات إضافية',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text('عدد النقاط حالياً: $_currentPoints'),
                            const SizedBox(height: 4),
                            Text('تحتاج إلى ${reward['points']} من النقاط لتستمتع بهذا العرض'),
                            const SizedBox(height: 4),
                            Text('أقل حد للطلب: ${reward['minOrder']} د.ع'),
                            const SizedBox(height: 4),
                            Text('الحد الأقصى للاستخدام: ${reward['maxUse']}'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              // زر الاستبدال
              Container(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _currentPoints >= (reward['points'] as int)
                        ? () {
                            // تنفيذ عملية الاستبدال
                            _redeemReward(reward);
                            Navigator.pop(context);
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      _currentPoints >= (reward['points'] as int)
                          ? 'استخدم في مقابل ${reward['points']} نقطة'
                          : 'تحتاج ${(reward['points'] as int) - _currentPoints} نقطة إضافية',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _redeemReward(Map<String, dynamic> reward) {
    setState(() {
      _currentPoints -= reward['points'] as int;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('تم استبدال ${reward['points']} نقطة بنجاح!'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Widget _buildRewardCard(Map<String, dynamic> reward) {
    final bool canRedeem = _currentPoints >= (reward['points'] as int);
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _primaryColor.withValues(alpha: 0.1),
            _primaryColor.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _primaryColor.withValues(alpha: 0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: _primaryColor.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [
              Colors.white.withValues(alpha: 0.3),
              Colors.white.withValues(alpha: 0.1),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () {
              HapticFeedback.lightImpact();
              _showRewardDetails(reward);
            },
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(
                      reward['image'] as String,
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          reward['title'] as String,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: _primaryColor,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          reward['subtitle'] as String,
                          style: TextStyle(
                            fontSize: 14,
                            color: _primaryColor.withValues(alpha: 0.7),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: canRedeem 
                                ? Colors.green.withValues(alpha: 0.1)
                                : Colors.orange.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: canRedeem 
                                  ? Colors.green.withValues(alpha: 0.3)
                                  : Colors.orange.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.stars_rounded,
                                size: 16,
                                color: canRedeem ? Colors.green : Colors.orange,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${reward['points']} نقطة',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: canRedeem ? Colors.green : Colors.orange,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.arrow_forward_ios,
                    color: _primaryColor.withValues(alpha: 0.5),
                    size: 16,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        extendBodyBehindAppBar: true,
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: _primaryColor),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            'مكافآتي',
            style: TextStyle(
              color: _primaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
        ),
        body: Column(
          children: [
            _buildPointsHeader(),
            const SizedBox(height: 8),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Align(
                alignment: Alignment.centerRight,
                child: Text(
                  'العروض المتاحة للاستبدال',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: _primaryColor,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: _availableRewards.isNotEmpty
                  ? ListView.builder(
                      itemCount: _availableRewards.length,
                      itemBuilder: (context, index) {
                        return _buildRewardCard(_availableRewards[index]);
                      },
                    )
                  : const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.stars_outlined,
                            size: 64,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'لا توجد مكافآت متاحة حالياً',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
