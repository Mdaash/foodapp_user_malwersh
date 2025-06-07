import 'package:flutter/material.dart';

class RewardsScreen extends StatefulWidget {
  const RewardsScreen({super.key});

  @override
  State<RewardsScreen> createState() => _RewardsScreenState();
}

class _RewardsScreenState extends State<RewardsScreen> {
  // ألوان التطبيق - اللون الأساسي الموحد (نفس ألوان شاشة القسائم)
  static const Color _primaryColor = Color(0xFF00c1e8);
  static const Color _primaryLight = Color(0xFFE6F9FC);

  int _selectedPointsFilter = 0; // 0: الكل، 1: المكتسبة، 2: المنفقة
  
  // نقاط تجريبية للاختبار
  final int _totalPoints = 1250;
  final int _earnedPoints = 1850;
  final int _spentPoints = 600;

  // قائمة المكافآت المتاحة
  final List<Map<String, dynamic>> _rewards = [
    {
      'title': 'خصم 10% على الطلب القادم',
      'points': 100,
      'icon': Icons.percent,
      'color': Colors.green,
      'description': 'خصم 10% على أي طلب بقيمة 50 ريال أو أكثر',
    },
    {
      'title': 'وجبة مجانية صغيرة',
      'points': 250,
      'icon': Icons.fastfood,
      'color': Colors.orange,
      'description': 'احصل على وجبة مجانية من قائمة الوجبات الصغيرة',
    },
    {
      'title': 'مشروب مجاني',
      'points': 150,
      'icon': Icons.local_drink,
      'color': Colors.blue,
      'description': 'مشروب مجاني من أي حجم مع طلبك القادم',
    },
    {
      'title': 'خصم 20% خاص',
      'points': 300,
      'icon': Icons.local_offer,
      'color': Colors.red,
      'description': 'خصم 20% على الطلب القادم بحد أقصى 30 ريال',
    },
    {
      'title': 'توصيل مجاني لمدة شهر',
      'points': 500,
      'icon': Icons.delivery_dining,
      'color': Colors.purple,
      'description': 'توصيل مجاني لجميع طلباتك لمدة شهر كامل',
    },
    {
      'title': 'وجبة عائلية مجانية',
      'points': 800,
      'icon': Icons.family_restroom,
      'color': Colors.indigo,
      'description': 'وجبة عائلية كاملة مجانية تكفي ل4 أشخاص',
    },
  ];

  // دالة لحساب النقاط المعروضة حسب الفلتر
  int get _displayedPoints {
    switch (_selectedPointsFilter) {
      case 1:
        return _earnedPoints; // المكتسبة
      case 2:
        return _spentPoints; // المنفقة
      default:
        return _totalPoints; // الكل (النقاط الحالية)
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        extendBodyBehindAppBar: true,
        backgroundColor: Colors.grey[50],
        body: SafeArea(
          top: false,
          child: Column(
            children: [
            // Header Section - مطابق لتصميم شاشة القسائم
            _buildHeader(),
            Expanded(
              child: _buildContent(),
            ),
          ],
        ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            _primaryColor,
            _primaryColor.withValues(alpha: 0.8),
          ],
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // App Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                  ),
                  const Expanded(
                    child: Text(
                      'مكافآتي',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 48), // To balance the back button
                ],
              ),
            ),
            // Points Display Section
            _buildPointsSection(),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildPointsSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.stars_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'نقاطك الحالية',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$_displayedPoints',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          Shadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            offset: const Offset(0, 2),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Points Filter Buttons
          Row(
            children: [
              Expanded(
                child: _buildFilterButton('الكل', 0),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildFilterButton('المكتسبة', 1),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildFilterButton('المنفقة', 2),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterButton(String title, int index) {
    final isSelected = _selectedPointsFilter == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPointsFilter = index;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected 
              ? Colors.white.withValues(alpha: 0.9)
              : Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected 
                ? Colors.white
                : Colors.white.withValues(alpha: 0.3),
          ),
        ),
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isSelected ? _primaryColor : Colors.white,
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: _primaryColor.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          children: [
            // Header with gradient
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    _primaryLight,
                    _primaryLight.withValues(alpha: 0.5),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.card_giftcard_rounded,
                    color: _primaryColor,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'المكافآت المتاحة',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2C3E50),
                    ),
                  ),
                ],
              ),
            ),
            // Rewards List
            Expanded(
              child: _buildRewardsList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRewardsList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _rewards.length,
      itemBuilder: (context, index) {
        final reward = _rewards[index];
        final canRedeem = _totalPoints >= reward['points'];
        
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: canRedeem 
                  ? _primaryColor.withValues(alpha: 0.2)
                  : Colors.grey.withValues(alpha: 0.2),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: (canRedeem ? _primaryColor : Colors.grey).withValues(alpha: 0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Reward Icon
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: canRedeem 
                        ? reward['color'].withValues(alpha: 0.1)
                        : Colors.grey.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    reward['icon'],
                    color: canRedeem ? reward['color'] : Colors.grey,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                // Reward Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        reward['title'],
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: canRedeem ? const Color(0xFF2C3E50) : Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        reward['description'],
                        style: TextStyle(
                          fontSize: 12,
                          color: canRedeem 
                              ? Colors.grey[600] 
                              : Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.stars,
                            color: canRedeem ? _primaryColor : Colors.grey,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${reward['points']} نقطة',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: canRedeem ? _primaryColor : Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Redeem Button
                GestureDetector(
                  onTap: canRedeem ? () => _redeemReward(reward) : null,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: canRedeem 
                          ? _primaryColor 
                          : Colors.grey.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      canRedeem ? 'استبدل' : 'غير متاح',
                      style: TextStyle(
                        color: canRedeem ? Colors.white : Colors.grey[600],
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _redeemReward(Map<String, dynamic> reward) {
    showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(
                Icons.stars,
                color: _primaryColor,
                size: 24,
              ),
              const SizedBox(width: 8),
              const Text(
                'استبدال المكافأة',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'هل تريد استبدال ${reward['points']} نقطة للحصول على:',
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _primaryLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  reward['title'],
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: _primaryColor,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'إلغاء',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'تم استبدال ${reward['title']} بنجاح!',
                      textAlign: TextAlign.center,
                    ),
                    backgroundColor: _primaryColor,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('تأكيد الاستبدال'),
            ),
          ],
        ),
      ),
    );
  }
}
