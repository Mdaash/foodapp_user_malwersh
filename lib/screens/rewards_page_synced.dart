import 'package:flutter/material.dart';
import '../services/user_service.dart';

class RewardsPageSynced extends StatefulWidget {
  const RewardsPageSynced({super.key});

  @override
  State<RewardsPageSynced> createState() => _RewardsPageSyncedState();
}

class _RewardsPageSyncedState extends State<RewardsPageSynced>
    with TickerProviderStateMixin {
  // Services
  final UserService _userService = UserService();
  
  // Animation Controllers
  late AnimationController _mainAnimationController;
  late AnimationController _pointsAnimationController;
  late AnimationController _progressAnimationController;
  late TabController _tabController;
  
  // Animations
  late Animation<int> _pointsCountAnimation;
  late Animation<double> _progressAnimation;
  
  // State Variables
  int _selectedTab = 0;
  final int _targetPoints = 500;

  // ألوان التطبيق - اللون الأساسي الموحد مثل شاشة القسائم
  static const Color _primaryColor = Color(0xFF00c1e8);
  static const Color _successColor = Color(0xFF40E0B0);
  static const Color _warningColor = Color(0xFFFFDB80);
  static const Color _dangerColor = Color(0xFFF26B8A);
  static const Color _textPrimary = Color(0xFF2d3436);
  static const Color _textSecondary = Color(0xFF636e72);

  // بيانات المعاملات النموذجية (سيتم ربطها بالـ UserService لاحقاً)
  final List<Map<String, dynamic>> _allTransactions = [
    {
      'type': 'earned',
      'amount': 120,
      'description': 'عن الطلب #2345',
      'date': 'اليوم',
      'time': '14:30',
      'icon': Icons.fastfood_outlined,
    },
    {
      'type': 'redeemed',
      'amount': 100,
      'description': 'استبدال قسيمة خصم',
      'date': 'أمس',
      'time': '19:45',
      'icon': Icons.card_giftcard_outlined,
    },
    {
      'type': 'earned',
      'amount': 75,
      'description': 'عن الطلب #2344',
      'date': '٢ يونيو',
      'time': '12:15',
      'icon': Icons.restaurant_outlined,
    },
    {
      'type': 'bonus',
      'amount': 200,
      'description': 'مكافأة التسجيل',
      'date': '١ يونيو',
      'time': '10:00',
      'icon': Icons.celebration_outlined,
    },
  ];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimations();
    _userService.addListener(_onUserDataChanged);
  }

  void _onUserDataChanged() {
    if (mounted) {
      setState(() {
        // إعادة تحديث الرسوم المتحركة عند تغيير النقاط
        _updatePointsAnimation();
      });
    }
  }

  void _initializeAnimations() {
    // Tab controller
    _tabController = TabController(length: 3, vsync: this);
    
    // Main animation controller
    _mainAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    // Points animation
    _pointsAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    // Progress animation
    _progressAnimationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    // Initialize animations
    _updatePointsAnimation();
  }

  void _updatePointsAnimation() {
    final currentPoints = _userService.currentPoints;
    
    _pointsCountAnimation = IntTween(
      begin: 0,
      end: currentPoints,
    ).animate(CurvedAnimation(
      parent: _pointsAnimationController,
      curve: Curves.bounceOut,
    ));

    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: currentPoints / _targetPoints,
    ).animate(CurvedAnimation(
      parent: _progressAnimationController,
      curve: Curves.easeInOutCubic,
    ));
  }

  void _startAnimations() {
    _mainAnimationController.forward();
    _pointsAnimationController.forward();
    
    Future.delayed(const Duration(milliseconds: 500), () {
      _progressAnimationController.forward();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _mainAnimationController.dispose();
    _pointsAnimationController.dispose();
    _progressAnimationController.dispose();
    _userService.removeListener(_onUserDataChanged);
    super.dispose();
  }

  List<Map<String, dynamic>> get _filteredTransactions {
    switch (_selectedTab) {
      case 1:
        return _allTransactions.where((t) => t['type'] == 'earned').toList();
      case 2:
        return _allTransactions.where((t) => t['type'] == 'redeemed').toList();
      default:
        return _allTransactions;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        extendBodyBehindAppBar: true,
        backgroundColor: Colors.grey[50],
        body: Column(
          children: [
            // Header Section - مثل شاشة القسائم
            _buildHeader(),
            // Content Section with TabBar and TabBarView
            Expanded(
              child: _buildContent(),
            ),
          ],
        ),
        // زر الاستبدال العائم
        floatingActionButton: _buildFloatingActionButton(),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      ),
    );
  }

  // Header Section - مثل شاشة القسائم
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
            // Points Section
            _buildPointsSection(),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  // قسم النقاط في الهيدر
  Widget _buildPointsSection() {
    final currentPoints = _userService.currentPoints;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          // أيقونة النقاط
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.stars_rounded,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(height: 16),
          
          const Text(
            'رصيد النقاط',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          
          // عدد النقاط مع رسم متحرك
          AnimatedBuilder(
            animation: _pointsCountAnimation,
            builder: (context, child) {
              return Text(
                '${_pointsCountAnimation.value}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                ),
              );
            },
          ),
          
          const Text(
            'نقطة',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          
          const SizedBox(height: 20),
          
          // شريط التقدم
          _buildProgressBar(),
          
          const SizedBox(height: 12),
          
          // نص التقدم
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'المطلوب للمكافأة التالية',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                ),
              ),
              Text(
                '${_targetPoints - currentPoints} نقطة',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // شريط التقدم البسيط
  Widget _buildProgressBar() {
    return AnimatedBuilder(
      animation: _progressAnimation,
      builder: (context, child) {
        return Column(
          children: [
            Stack(
              children: [
                // خلفية شريط التقدم
                Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                // شريط التقدم الفعلي
                FractionallySizedBox(
                  widthFactor: _progressAnimation.value,
                  child: Container(
                    height: 8,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  // Content Section
  Widget _buildContent() {
    return Column(
      children: [
        // Tab Bar
        Container(
          color: Colors.white,
          child: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'الكل'),
              Tab(text: 'مكتسبة'),
              Tab(text: 'مستبدلة'),
            ],
            labelColor: _primaryColor,
            unselectedLabelColor: _textSecondary,
            indicatorColor: _primaryColor,
            indicatorWeight: 3,
            onTap: (index) {
              setState(() {
                _selectedTab = index;
              });
            },
          ),
        ),
        // Tab Bar View Content
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildTransactionsList(),
              _buildTransactionsList(),
              _buildTransactionsList(),
            ],
          ),
        ),
      ],
    );
  }

  // قائمة المعاملات موحدة
  Widget _buildTransactionsList() {
    final transactions = _filteredTransactions;
    
    if (transactions.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: transactions.length,
      itemBuilder: (context, index) {
        final transaction = transactions[index];
        return _buildTransactionCard(transaction);
      },
    );
  }

  // بطاقة المعاملة موحدة
  Widget _buildTransactionCard(Map<String, dynamic> transaction) {
    Color typeColor;
    IconData typeIcon;
    String prefix;

    switch (transaction['type']) {
      case 'earned':
        typeColor = _successColor;
        typeIcon = Icons.add_circle_outline;
        prefix = '+';
        break;
      case 'redeemed':
        typeColor = _dangerColor;
        typeIcon = Icons.remove_circle_outline;
        prefix = '-';
        break;
      case 'bonus':
        typeColor = _warningColor;
        typeIcon = Icons.star_outline;
        prefix = '+';
        break;
      default:
        typeColor = _textSecondary;
        typeIcon = Icons.circle_outlined;
        prefix = '';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // أيقونة المعاملة
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: typeColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              transaction['icon'],
              color: typeColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          
          // تفاصيل المعاملة
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction['description'],
                  style: TextStyle(
                    color: _textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      transaction['date'],
                      style: TextStyle(
                        color: _textSecondary,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      transaction['time'],
                      style: TextStyle(
                        color: _textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // مبلغ النقاط
          Row(
            children: [
              Icon(
                typeIcon,
                color: typeColor,
                size: 16,
              ),
              const SizedBox(width: 4),
              Text(
                '$prefix${transaction['amount']}',
                style: TextStyle(
                  color: typeColor,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // حالة فارغة
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.stars_outlined,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'لا توجد معاملات',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'ابدأ بكسب النقاط من خلال الطلبات',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // زر الاستبدال العائم
  Widget _buildFloatingActionButton() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: ElevatedButton(
        onPressed: _showRewardsBottomSheet,
        style: ElevatedButton.styleFrom(
          backgroundColor: _primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 4,
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.redeem, size: 24),
            SizedBox(width: 8),
            Text(
              'استبدال النقاط',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // عرض القائمة السفلية للمكافآت المتاحة
  void _showRewardsBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildRewardsBottomSheet(),
    );
  }

  Widget _buildRewardsBottomSheet() {
    final availableRewards = _userService.availableRewards;
    final currentPoints = _userService.currentPoints;

    return Container(
      margin: const EdgeInsets.only(top: 50),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.redeem,
                    color: _primaryColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'استبدال النقاط',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'رصيدك الحالي: $currentPoints نقطة',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),
          
          const Divider(height: 1),
          
          // Rewards List
          Flexible(
            child: availableRewards.isEmpty
                ? _buildEmptyRewardsState()
                : ListView.builder(
                    shrinkWrap: true,
                    padding: const EdgeInsets.all(16),
                    itemCount: availableRewards.length,
                    itemBuilder: (context, index) {
                      final reward = availableRewards[index];
                      return _buildRewardCard(reward, currentPoints);
                    },
                  ),
          ),
          
          // Safe area padding
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildRewardCard(Map<String, dynamic> reward, int currentPoints) {
    final requiredPoints = reward['points'] as int;
    final canRedeem = currentPoints >= requiredPoints;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: canRedeem ? _primaryColor.withValues(alpha: 0.3) : Colors.grey.withValues(alpha: 0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: canRedeem ? () => _redeemReward(reward) : null,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Icon
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: canRedeem 
                        ? _primaryColor.withValues(alpha: 0.1) 
                        : Colors.grey.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    _getRewardIcon(reward['category']),
                    color: canRedeem ? _primaryColor : Colors.grey,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                
                // Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        reward['title'] ?? '',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: canRedeem ? _textPrimary : Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        reward['description'] ?? '',
                        style: TextStyle(
                          fontSize: 12,
                          color: canRedeem ? _textSecondary : Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 8),
                      
                      // Discount and Points
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: canRedeem 
                                  ? _successColor.withValues(alpha: 0.1) 
                                  : Colors.grey.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              reward['discount'] ?? '',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: canRedeem ? _successColor : Colors.grey,
                              ),
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: canRedeem 
                                  ? _primaryColor.withValues(alpha: 0.1) 
                                  : Colors.grey.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.stars_rounded,
                                  size: 14,
                                  color: canRedeem ? _primaryColor : Colors.grey,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '$requiredPoints',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: canRedeem ? _primaryColor : Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                // Action
                Icon(
                  canRedeem ? Icons.arrow_forward_ios : Icons.block,
                  color: canRedeem ? _primaryColor : Colors.grey,
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyRewardsState() {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.card_giftcard_outlined,
            size: 60,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'لا توجد مكافآت متاحة',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'المكافآت المتاحة ستظهر هنا',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  IconData _getRewardIcon(String? category) {
    switch (category) {
      case 'discount':
        return Icons.percent;
      case 'delivery':
        return Icons.delivery_dining;
      case 'food':
        return Icons.restaurant;
      case 'premium':
        return Icons.star;
      default:
        return Icons.card_giftcard;
    }
  }

  Future<void> _redeemReward(Map<String, dynamic> reward) async {
    Navigator.pop(context); // إغلاق القائمة السفلية
    
    // عرض مؤشر التحميل
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      // استبدال المكافأة وإنشاء قسيمة
      final newCoupon = await _userService.redeemReward(reward['id']);
      
      Navigator.pop(context); // إغلاق مؤشر التحميل

      if (newCoupon != null) {
        // إضافة معاملة للاستبدال
        _addRedemptionTransaction(reward);
        
        // إعادة تحديث الرسوم المتحركة
        _updateAnimationsAfterRedemption();
        
        // عرض رسالة النجاح مع تفاصيل القسيمة
        _showSuccessDialog(newCoupon);
      } else {
        _showErrorSnackBar('فشل في استبدال المكافأة');
      }
    } catch (e) {
      Navigator.pop(context); // إغلاق مؤشر التحميل
      _showErrorSnackBar(e.toString());
    }
  }

  void _addRedemptionTransaction(Map<String, dynamic> reward) {
    setState(() {
      _allTransactions.insert(0, {
        'type': 'redeemed',
        'amount': reward['points'],
        'description': 'استبدال ${reward['title']}',
        'date': 'الآن',
        'time': '${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}',
        'icon': Icons.card_giftcard_outlined,
      });
    });
  }

  void _updateAnimationsAfterRedemption() {
    final currentPoints = _userService.currentPoints;
    
    _pointsCountAnimation = IntTween(
      begin: currentPoints + 100, // قيمة تقريبية للرسم المتحرك
      end: currentPoints,
    ).animate(CurvedAnimation(
      parent: _pointsAnimationController,
      curve: Curves.bounceOut,
    ));
    
    _progressAnimation = Tween<double>(
      begin: (currentPoints + 100) / _targetPoints,
      end: currentPoints / _targetPoints,
    ).animate(CurvedAnimation(
      parent: _progressAnimationController,
      curve: Curves.easeInOutCubic,
    ));

    _pointsAnimationController.reset();
    _progressAnimationController.reset();
    _pointsAnimationController.forward();
    _progressAnimationController.forward();
  }

  void _showSuccessDialog(Map<String, dynamic> coupon) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _successColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_circle,
                color: _successColor,
                size: 48,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'تم الاستبدال بنجاح!',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'تم إنشاء قسيمة خصم جديدة في محفظتك',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 20),
            
            // تفاصيل القسيمة
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('كود القسيمة:'),
                      Text(
                        coupon['code'] ?? '',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('قيمة الخصم:'),
                      Text(
                        coupon['discount'] ?? '',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: _successColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('رائع!'),
          ),
        ],
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: _dangerColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}
