import 'package:flutter/material.dart';
// import '../services/user_service.dart'; // سيُستخدم لاحقاً

class RewardsScreenWidget extends StatefulWidget {
  const RewardsScreenWidget({super.key});

  @override
  State<RewardsScreenWidget> createState() => _RewardsScreenWidgetState();
}

class _RewardsScreenWidgetState extends State<RewardsScreenWidget>
    with TickerProviderStateMixin {
  // final UserService _userService = UserService(); // سيُستخدم لاحقاً
  
  // Animation Controllers
  late AnimationController _pointsAnimationController;
  late AnimationController _progressAnimationController;
  late AnimationController _tabAnimationController;
  late AnimationController _buttonAnimationController;
  
  // Animations
  late Animation<int> _pointsAnimation;
  late Animation<double> _progressAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _buttonAnimation;
  
  // State Variables
  final int _currentPoints = 350; // النقاط الحالية
  final int _targetPoints = 500; // الهدف التالي
  int _selectedTab = 0; // 0: الكل, 1: المكتسبة, 2: المنفقة

  // ألوان التطبيق الأساسية المحسنة
  static const Color _primaryColor = Color(0xFF00c1e8); // اللون الأساسي للتطبيق
  static const Color _accentColor = Color(0xFF00a6cc); // لون مساعد أدكن
  static const Color _successColor = Color(0xFF28A745);
  static const Color _dangerColor = Color(0xFFDC3545);
  static const Color _redeemButtonColor = Color(0xFF00c1e8); // استخدام اللون الأساسي
  static const Color _textPrimary = Color(0xFF333333);
  static const Color _textSecondary = Color(0xFF666666);
  static const Color _textMuted = Color(0xFF999999);
  static const Color _dividerColor = Color(0xFFEEEEEE);
  static const Color _backgroundGradientStart = Color(0xFFF8FCFF);
  static const Color _backgroundGradientEnd = Color(0xFFE6F7FF);

  // بيانات تجريبية لمعاملات النقاط
  final List<Map<String, dynamic>> _allTransactions = [
    {
      'type': 'earned',
      'amount': 120,
      'description': 'عن الطلب #2345',
      'date': '2025-06-10',
      'time': '14:30',
    },
    {
      'type': 'spent',
      'amount': 100,
      'description': 'استبدال قسيمة خصم',
      'date': '2025-06-09',
      'time': '19:45',
    },
    {
      'type': 'earned',
      'amount': 75,
      'description': 'عن الطلب #2344',
      'date': '2025-06-08',
      'time': '12:15',
    },
    {
      'type': 'earned',
      'amount': 200,
      'description': 'مكافأة التسجيل',
      'date': '2025-06-07',
      'time': '10:00',
    },
    {
      'type': 'spent',
      'amount': 150,
      'description': 'استبدال توصيل مجاني',
      'date': '2025-06-06',
      'time': '16:20',
    },
  ];

  // حالة عرض Toast
  bool _isToastVisible = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimations();
  }

  void _initializeAnimations() {
    // Animation Controller للنقاط (1000ms مع bounceOut)
    _pointsAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    // Animation Controller للشريط التقدمي (800ms مع easeInOutCubic)
    _progressAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    // Animation Controller للتبويبات (200ms fade)
    _tabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    // Animation Controller للأزرار (100ms opacity)
    _buttonAnimationController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );

    // الرسوم المتحركة
    _pointsAnimation = IntTween(
      begin: 0,
      end: _currentPoints,
    ).animate(CurvedAnimation(
      parent: _pointsAnimationController,
      curve: Curves.bounceOut,
    ));

    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: _currentPoints / _targetPoints,
    ).animate(CurvedAnimation(
      parent: _progressAnimationController,
      curve: Curves.easeInOutCubic,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _tabAnimationController,
      curve: Curves.easeInOut,
    ));

    _buttonAnimation = Tween<double>(
      begin: 1.0,
      end: 0.8,
    ).animate(CurvedAnimation(
      parent: _buttonAnimationController,
      curve: Curves.easeInOut,
    ));
  }

  void _startAnimations() {
    // تشغيل جميع الرسوم المتحركة عند بداية الشاشة
    _pointsAnimationController.forward();
    _progressAnimationController.forward();
    _tabAnimationController.forward();
  }

  @override
  void dispose() {
    _pointsAnimationController.dispose();
    _progressAnimationController.dispose();
    _tabAnimationController.dispose();
    _buttonAnimationController.dispose();
    super.dispose();
  }

  // فلترة المعاملات حسب التبويب المحدد
  List<Map<String, dynamic>> get _filteredTransactions {
    switch (_selectedTab) {
      case 1: // المكتسبة
        return _allTransactions.where((t) => t['type'] == 'earned').toList();
      case 2: // المنفقة
        return _allTransactions.where((t) => t['type'] == 'spent').toList();
      default: // الكل
        return _allTransactions;
    }
  }

  // دالة تبديل التبويبات مع الرسوم المتحركة
  void _switchTab(int index) {
    setState(() {
      _selectedTab = index;
    });
    _tabAnimationController.reset();
    _tabAnimationController.forward();
  }

  // دالة الاستبدال مع رسوم متحركة
  void _redeemPoints() async {
    // رسوم متحركة للضغط على الزر
    await _buttonAnimationController.forward();
    await _buttonAnimationController.reverse();
    
    // عرض Toast مع رسوم متحركة
    _showToast('تم استبدال النقاط بنجاح!');
  }

  // دالة عرض Toast مع رسوم متحركة
  void _showToast(String message) {
    if (_isToastVisible) return;
    
    setState(() {
      _isToastVisible = true;
    });
    
    // إخفاء Toast بعد 3 ثوان
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _isToastVisible = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [_backgroundGradientStart, _backgroundGradientEnd],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              CustomScrollView(
                slivers: [
                  // AppBar مخصص مع تصميم تفاعلي
                  _buildCustomAppBar(),
                  
                  // محتوى الشاشة
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // قسم النقاط والتقدم
                          _buildPointsSection(),
                          
                          const SizedBox(height: 24),
                          
                          // قسم التبويبات
                          _buildTabSection(),
                          
                          const SizedBox(height: 16),
                          
                          // قائمة المعاملات
                          _buildTransactionsList(),
                          
                          const SizedBox(height: 100), // مساحة إضافية للزر العائم
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              
              // زر الاستبدال العائم
              _buildFloatingRedeemButton(),
              
              // Toast Message
              if (_isToastVisible) _buildToastMessage(),
            ],
          ),
        ),
      ),
    );
  }

  // AppBar مخصص مع تصميم تفاعلي
  Widget _buildCustomAppBar() {
    return SliverAppBar(
      expandedHeight: 120,
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: Colors.transparent,
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [_primaryColor, _accentColor],
          ),
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
        ),
        child: FlexibleSpaceBar(
          centerTitle: true,
          title: const Text(
            'المكافآت',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          background: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [_primaryColor, _accentColor],
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Center(
              child: Icon(
                Icons.stars_rounded,
                color: Colors.white.withOpacity(0.2),
                size: 80,
              ),
            ),
          ),
        ),
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
    );
  }

  // قسم النقاط مع الرسوم المتحركة
  Widget _buildPointsSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: _primaryColor.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          // عرض النقاط مع الرسوم المتحركة
          AnimatedBuilder(
            animation: _pointsAnimation,
            builder: (context, child) {
              return Text(
                '${_pointsAnimation.value}',
                style: const TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: _primaryColor,
                ),
              );
            },
          ),
          
          const Text(
            'نقطة متاحة',
            style: TextStyle(
              fontSize: 16,
              color: _textSecondary,
            ),
          ),
          
          const SizedBox(height: 20),
          
          // شريط التقدم مع الرسوم المتحركة
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'التقدم نحو الهدف التالي',
                    style: TextStyle(
                      fontSize: 14,
                      color: _textSecondary,
                    ),
                  ),
                  Text(
                    '$_currentPoints / $_targetPoints',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: _primaryColor,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 8),
              
              AnimatedBuilder(
                animation: _progressAnimation,
                builder: (context, child) {
                  return Container(
                    height: 8,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      color: _dividerColor,
                    ),
                    child: Stack(
                      children: [
                        Container(
                          width: MediaQuery.of(context).size.width * _progressAnimation.value * 0.85,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4),
                            gradient: const LinearGradient(
                              colors: [_primaryColor, _accentColor],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: _primaryColor.withOpacity(0.4),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  // قسم التبويبات مع الرسوم المتحركة
  Widget _buildTabSection() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: _dividerColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _buildTabButton('الكل', 0),
          _buildTabButton('المكتسبة', 1),
          _buildTabButton('المنفقة', 2),
        ],
      ),
    );
  }

  // زر التبويب مع الرسوم المتحركة
  Widget _buildTabButton(String title, int index) {
    final isSelected = _selectedTab == index;
    
    return Expanded(
      child: GestureDetector(
        onTap: () => _switchTab(index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? _primaryColor : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              title,
              style: TextStyle(
                color: isSelected ? Colors.white : _textSecondary,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // قائمة المعاملات مع الرسوم المتحركة
  Widget _buildTransactionsList() {
    final transactions = _filteredTransactions;
    
    if (transactions.isEmpty) {
      return _buildEmptyState();
    }
    
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Column(
        children: transactions.asMap().entries.map((entry) {
          final index = entry.key;
          final transaction = entry.value;
          
          return AnimatedContainer(
            duration: Duration(milliseconds: 200 + (index * 100)),
            margin: const EdgeInsets.only(bottom: 12),
            child: _buildTransactionItem(transaction),
          );
        }).toList(),
      ),
    );
  }

  // عنصر معاملة واحدة
  Widget _buildTransactionItem(Map<String, dynamic> transaction) {
    final isEarned = transaction['type'] == 'earned';
    final amount = transaction['amount'] as int;
    final description = transaction['description'] as String;
    final date = transaction['date'] as String;
    final time = transaction['time'] as String;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isEarned ? _successColor.withOpacity(0.2) : _dangerColor.withOpacity(0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // أيقونة المعاملة
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: (isEarned ? _successColor : _dangerColor).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isEarned ? Icons.add_circle_outline : Icons.remove_circle_outline,
              color: isEarned ? _successColor : _dangerColor,
              size: 24,
            ),
          ),
          
          const SizedBox(width: 12),
          
          // تفاصيل المعاملة
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: _textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$date - $time',
                  style: TextStyle(
                    fontSize: 12,
                    color: _textMuted,
                  ),
                ),
              ],
            ),
          ),
          
          // مبلغ النقاط
          Text(
            '${isEarned ? '+' : '-'}$amount',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isEarned ? _successColor : _dangerColor,
            ),
          ),
        ],
      ),
    );
  }

  // حالة فارغة
  Widget _buildEmptyState() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        padding: const EdgeInsets.all(40),
        child: Column(
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 64,
              color: _textMuted,
            ),
            const SizedBox(height: 16),
            Text(
              'لا توجد معاملات',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: _textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'ابدأ بتقديم طلبات لكسب النقاط',
              style: TextStyle(
                fontSize: 14,
                color: _textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // زر الاستبدال العائم
  Widget _buildFloatingRedeemButton() {
    return Positioned(
      bottom: 16,
      left: 16,
      right: 16,
      child: AnimatedBuilder(
        animation: _buttonAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _buttonAnimation.value,
            child: Container(
              width: double.infinity,
              height: 56,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [_redeemButtonColor, _accentColor],
                ),
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: _redeemButtonColor.withOpacity(0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: _redeemPoints,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                ),
                child: const Text(
                  'استبدال النقاط',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // رسالة Toast مع الرسوم المتحركة
  Widget _buildToastMessage() {
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      top: _isToastVisible ? 100 : -100,
      left: 16,
      right: 16,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: _successColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: _successColor.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            const Icon(
              Icons.check_circle,
              color: Colors.white,
              size: 24,
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'تم استبدال النقاط بنجاح!',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                setState(() {
                  _isToastVisible = false;
                });
              },
              child: const Icon(
                Icons.close,
                color: Colors.white,
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }
}