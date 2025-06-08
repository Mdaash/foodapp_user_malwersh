// lib/screens/home_screen_updated.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:foodapp_user/models/store.dart';
import 'package:foodapp_user/models/cart_model.dart';
import 'package:foodapp_user/models/favorites_model.dart';
import 'package:foodapp_user/screens/cart_screen.dart';
import 'package:foodapp_user/screens/favorites_screen_updated.dart';
import 'package:foodapp_user/screens/account_screen_new.dart';
import 'package:foodapp_user/screens/orders_screen.dart';
import 'package:foodapp_user/screens/coupons_screen.dart';
import 'package:foodapp_user/screens/rewards_screen.dart';
import 'package:foodapp_user/widgets/animated_cart_bar.dart';
import 'package:foodapp_user/widgets/modern_cart_icon.dart';

class HomeScreenUpdated extends StatefulWidget {
  const HomeScreenUpdated({super.key});

  @override
  State<HomeScreenUpdated> createState() => _HomeScreenUpdatedState();
}

class _HomeScreenUpdatedState extends State<HomeScreenUpdated> {
  // المتاجر
  final List<Store> _stores = [];
  final ScrollController _storesController = ScrollController();
  int _page = 0;
  bool _isLoadingStores = false;
  bool _hasMoreStores = true;

  // إعدادات البنر الأوتوماتيكي
  late final PageController _bannerController;
  Timer? _bannerTimer;
  int _bannerPage = 0;
  final List<String> _bannerImages = const [
    'assets/images/banner1.png',
    'assets/images/banner2.png',
    'assets/images/banner3.png',
  ];

  // التبويب المحدد في BottomNavigationBar
  int _selectedTabIndex = 0;

  // العنوان الافتراضي المحفوظ
  final String _savedAddress = 'بغداد، الكرادة، حي 123، قرب الجامعة';

  // أيقونات معبرة لكل فلتر (باستخدام أيقونات Flutter المدمجة)
  final Map<String, IconData> _filterIcons = {
    'أقل من ٣٠ دقيقة': Icons.timer_outlined,
    'رسوم التوصيل': Icons.local_shipping_outlined,
    'استلام مباشر': Icons.store_outlined,
    'مفتوح الآن': Icons.access_time_outlined,
    'خصومات': Icons.local_offer_outlined,
  };

  // قائمة الفلاتر المتاحة
  final List<String> _availableFilters = [
    'أقل من ٣٠ دقيقة',
    'رسوم التوصيل',
    'استلام مباشر',
    'مفتوح الآن',
    'خصومات',
  ];

  @override
  void initState() {
    super.initState();
    _loadMoreStores();
    _storesController.addListener(() {
      if (_storesController.position.pixels >=
              _storesController.position.maxScrollExtent - 200 &&
          !_isLoadingStores &&
          _hasMoreStores) {
        _loadMoreStores();
      }
    });

    _bannerController = PageController(viewportFraction: 0.9);
    _bannerTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (_bannerController.hasClients) {
        _bannerPage = (_bannerPage + 1) % _bannerImages.length;
        _bannerController.animateToPage(
          _bannerPage,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _storesController.dispose();
    _bannerTimer?.cancel();
    _bannerController.dispose();
    super.dispose();
  }

  Future<void> _loadMoreStores() async {
    setState(() => _isLoadingStores = true);
    await Future.delayed(const Duration(seconds: 1));

    final raw = List.generate(5, (i) => {
          "id": "${_page * 5 + i}",
          "image": "assets/images/food_placeholder.png",
          "logoUrl": "assets/images/food_placeholder.png",
          "isOpen": i % 2 == 0,
          "name": "مطعم مثال ${_page * 5 + i}",
          "rating": "4.${(i + _page) % 5}",
          "reviews": "${100 * (i + 1)}+",
          "distance": "${2 + i * 0.5} mi",
          "time": "${15 + i * 2} min",
          "fee": "${i % 2}\$",
          "promo": i % 3 == 0 ? "عرض خاص $i" : null,
          "tag": i % 2 == 0 ? "#Tag$i" : null,
          "category": i % 2 == 0 ? "Cat$i" : null,
          "sponsored": i % 4 == 0,
          "address": "العنوان مثال ${_page * 5 + i}",
          "combos": [],
          "sandwiches": [],
          "drinks": [],
          "extras": [],
          "specialties": [],
        });

    final fetched = raw.map((e) => Store.fromJson(e)).toList();
    setState(() {
      if (fetched.isEmpty) {
        _hasMoreStores = false;
      } else {
        _page++;
        _stores.addAll(fetched);
      }
      _isLoadingStores = false;
    });
  }

  void _openDetail(Store s) async {
    final result = await Navigator.push<int>(
      context,
      MaterialPageRoute(
        builder: (_) => StoreDetailScreenUpdated(store: s),
      ),
    );
    
    // إذا تم الإرجاع بتبويب محدد، قم بتغيير التبويب
    if (result != null && result != _selectedTabIndex) {
      setState(() {
        _selectedTabIndex = result;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Consumer<FavoritesModel>(
        builder: (context, favorites, child) {
          return Scaffold(
            backgroundColor: Colors.white,
            appBar: PreferredSize(
              preferredSize: const Size.fromHeight(180),
              child: SafeArea(
                top: false,
                bottom: false,
                child: _selectedTabIndex == 0 
                    ? _buildTopBar(context)
                    : _buildAccountTopBar(context),
              ),
            ),
            body: IndexedStack(
              index: _selectedTabIndex,
              children: [
                // الرئيسية
                Stack(
                  children: [
                    ListView(
                      controller: _storesController,
                      children: [
                        const SizedBox(height: 16),
                        _buildCategoriesCarousel(),
                        const SizedBox(height: 8),
                        _buildFilterRow(),
                        const SizedBox(height: 20),
                        _buildRewardsAndCouponsSection(),
                        const SizedBox(height: 20),
                        _buildSpecialOffersSection(),
                        const SizedBox(height: 20),
                        _buildBannerSliderSection(),
                        const SizedBox(height: 20),
                        _buildHorizontalStoreSection("وصل حديثًا إلى زاد", _stores),
                        const SizedBox(height: 20),
                        _buildHorizontalStoreSection("الأقرب إليك", _stores),
                        const SizedBox(height: 20),
                        _buildHorizontalStoreSection("الأكثر شهرة", _stores),
                        const SizedBox(height: 20),
                        _buildHorizontalStoreSection("المطاعم الأعلى تقييماً", _stores),
                        const SizedBox(height: 20),
                        _buildHorizontalStoreSection("جديد في منطقتك", _stores),
                        const SizedBox(height: 20),
                        _buildSectionTitle("جميع المتاجر"),
                        const SizedBox(height: 8),
                        ..._stores.map((s) => _buildVerticalStoreItem(s, favorites)),
                        if (_isLoadingStores)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            child: Center(child: CircularProgressIndicator()),
                          ),
                      ],
                    ),
                    Positioned(
                      left: 0,
                      bottom: kBottomNavigationBarHeight + 8,
                      child: AnimatedCartBar(
                        storeName: '',
                        isExpanded: false,
                      ),
                    ),
                  ],
                ),
                // المفضلة
                FavoritesScreenUpdated(stores: _stores),
                // الطلبات
                OrdersScreen(onBack: () => setState(() => _selectedTabIndex = 0)),
                // حسابي
                AccountScreen(onBack: () => setState(() => _selectedTabIndex = 0)),
              ],
            ),
            bottomNavigationBar: _buildBottomNavBar(),
          );
        },
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 8, 
        bottom: 8,
        left: 16,
        right: 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // أيقونة العربة
          Row(
            children: [
              const Spacer(),
              Consumer<CartModel>(
                builder: (context, cart, _) => Stack(
                  alignment: Alignment.topRight,
                  children: [
                    IconButton(
                      icon: ModernCartIcon(
                        color: const Color(0xFF00c1e8),
                        size: 24,
                        hasGlowEffect: true,
                        isGlassmorphic: true,
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => CartScreen(
                              storeId: cart.currentStoreId,
                              stores: _stores,
                            ),
                          ),
                        );
                      },
                    ),
                    if (cart.items.isNotEmpty)
                      Positioned(
                        right: 6,
                        top: 6,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFDF1067),
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            '${cart.items.length}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // العنوان + الموقع
          Row(
            children: [
              const Icon(Icons.location_on, color: Color(0xFF00c1e8)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _savedAddress,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.keyboard_arrow_down),
                onPressed: () {}, // يمكن إضافة وظيفة العنوان لاحقاً
              ),
            ],
          ),
          const SizedBox(height: 8),
          // شريط البحث وأيقونة الخريطة
          Row(
            children: [
              Expanded(
                child: SmartSearchBarUpdated(stores: _stores),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => MapScreenUpdated(stores: _stores),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF00c1e8).withValues(alpha: 0.15),
                        const Color(0xFF00c1e8).withValues(alpha: 0.08),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFF00c1e8).withValues(alpha: 0.3),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF00c1e8).withValues(alpha: 0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Icon(
                        Icons.map,
                        color: const Color(0xFF00c1e8),
                        size: 26,
                      ),
                      Positioned(
                        top: 2,
                        child: Icon(
                          Icons.location_on,
                          color: Colors.red,
                          size: 15,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAccountTopBar(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 4,
        bottom: 8,
        left: 16,
        right: 16,
      ),
      child: Row(
        children: [
          const Spacer(),
          Consumer<CartModel>(
            builder: (context, cart, _) => Stack(
              alignment: Alignment.topRight,
              children: [
                IconButton(
                  icon: ModernCartIcon(
                    color: const Color(0xFF00c1e8),
                    size: 24,
                    hasGlowEffect: true,
                    isGlassmorphic: true,
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CartScreen(
                          storeId: cart.currentStoreId,
                          stores: _stores,
                        ),
                      ),
                    );
                  },
                ),
                if (cart.items.isNotEmpty)
                  Positioned(
                    right: 6,
                    top: 6,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Color(0xFFDF1067),
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '${cart.items.length}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // باقي الدوال المساعدة...
  Widget _buildCategoriesCarousel() {
    final categories = [
      {"name": "المطاعم", "image": "assets/icons/cat_rest.png", "color": const Color(0xFFFF6B6B)},
      {"name": "سوبرماركت", "image": "assets/icons/cat_supermarket.png", "color": const Color(0xFF00B894)},
      {"name": "الوجبات السريعة", "image": "assets/icons/cat_fast.png", "color": const Color(0xFF4ECDC4)},
      {"name": "الفطور", "image": "assets/icons/cat_break.png", "color": const Color(0xFF45B7D1)},
      {"name": "البقالة", "image": "assets/icons/cat_groce.png", "color": const Color(0xFF96CEB4)},
      {"name": "اللحوم", "image": "assets/icons/cat_meat.png", "color": const Color(0xFFFF9F43)},
      {"name": "حلويات ومثلجات", "image": "assets/icons/cat_dessert.png", "color": const Color(0xFFE17055)},
      {"name": "المشروبات", "image": "assets/icons/cat_juice.png", "color": const Color(0xFFFD79A8)},
      {"name": "الزهور", "image": "assets/icons/cat_flowers.png", "color": const Color(0xFFFF7675)},
      {"name": "أخرى", "image": "assets/icons/cat_other.png", "color": const Color(0xFF74B9FF)},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: const Text(
            'تصفح حسب الفئة',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 130,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              final categoryName = category["name"] as String;
              
              return Container(
                width: 85,
                margin: const EdgeInsets.only(left: 12),
                child: GestureDetector(
                  onTap: () {
                    // يمكن إضافة منطق فلترة المتاجر حسب الفئة
                  },
                  child: Column(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              (category["color"] as Color).withValues(alpha: 0.15),
                              (category["color"] as Color).withValues(alpha: 0.05),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: (category["color"] as Color).withValues(alpha: 0.3),
                            width: 1.3,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: (category["color"] as Color).withValues(alpha: 0.22),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: Image.asset(
                            category["image"] as String,
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  color: (category["color"] as Color).withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Icon(
                                  Icons.category,
                                  color: category["color"] as Color,
                                  size: 28,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        categoryName,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFilterRow() {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF00c1e8).withValues(alpha: 0.18),
            const Color(0xFF00c1e8).withValues(alpha: 0.12),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border(
          top: BorderSide(color: const Color(0xFF00c1e8).withValues(alpha: 0.3), width: 0.5),
          bottom: BorderSide(color: const Color(0xFF00c1e8).withValues(alpha: 0.3), width: 0.5),
        ),
      ),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          ..._availableFilters.map((filter) => _buildFilterChip(filter)),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    return Container(
      margin: const EdgeInsets.only(left: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      constraints: const BoxConstraints(minHeight: 36),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white,
            Colors.grey[50]!,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: const Color(0xFF00c1e8).withValues(alpha: 0.15),
          width: 1.2,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (_filterIcons[label] != null)
            Container(
              width: 22,
              height: 22,
              margin: const EdgeInsets.only(left: 6),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF00c1e8).withValues(alpha: 0.15),
                    const Color(0xFF00c1e8).withValues(alpha: 0.08),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(11),
              ),
              child: Center(
                child: Icon(
                  _filterIcons[label]!,
                  size: 13,
                  color: const Color(0xFF00c1e8),
                ),
              ),
            ),
          Flexible(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2D3436),
                letterSpacing: 0.2,
                height: 1.2,
              ),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRewardsAndCouponsSection() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF00c1e8).withValues(alpha: 0.12),
            const Color(0xFF7C4DFF).withValues(alpha: 0.08),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFF00c1e8).withValues(alpha: 0.25),
          width: 1.5,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.white.withValues(alpha: 0.85),
                Colors.white.withValues(alpha: 0.65),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF00c1e8).withValues(alpha: 0.2),
                          const Color(0xFF7C4DFF).withValues(alpha: 0.15),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.card_giftcard_rounded,
                      color: Color(0xFF222B45),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'استخدم ووفر',
                          style: TextStyle(
                            color: Color(0xFF222B45),
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'احصل على خصومات واستبدل النقاط',
                          style: TextStyle(
                            color: const Color(0xFF222B45).withValues(alpha: 0.7),
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const CouponsScreen()),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              const Color(0xFF7C4DFF).withValues(alpha: 0.1),
                              const Color(0xFF7C4DFF).withValues(alpha: 0.05),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: const Color(0xFF7C4DFF).withValues(alpha: 0.25),
                            width: 1.5,
                          ),
                        ),
                        child: Column(
                          children: [
                            Container(
                              width: 54,
                              height: 54,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    const Color(0xFF7C4DFF).withValues(alpha: 0.15),
                                    Colors.white.withValues(alpha: 0.25),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: const Icon(
                                Icons.local_offer_rounded,
                                color: Color(0xFF7C4DFF),
                                size: 28,
                              ),
                            ),
                            const SizedBox(height: 14),
                            const Text(
                              'قسائم الخصم',
                              style: TextStyle(
                                color: Color(0xFF222B45),
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'أضف واستعرض قسائمك',
                              style: TextStyle(
                                color: const Color(0xFF222B45).withValues(alpha: 0.65),
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const RewardsScreen(),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              const Color(0xFF00c1e8).withValues(alpha: 0.1),
                              const Color(0xFF00c1e8).withValues(alpha: 0.05),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: const Color(0xFF00c1e8).withValues(alpha: 0.25),
                            width: 1.5,
                          ),
                        ),
                        child: Column(
                          children: [
                            Container(
                              width: 54,
                              height: 54,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    const Color(0xFF00c1e8).withValues(alpha: 0.15),
                                    Colors.white.withValues(alpha: 0.25),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: const Icon(
                                Icons.stars_rounded,
                                color: Color(0xFF00c1e8),
                                size: 28,
                              ),
                            ),
                            const SizedBox(height: 14),
                            const Text(
                              'مكافآتي',
                              style: TextStyle(
                                color: Color(0xFF222B45),
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'اكسب واستبدل النقاط',
                              style: TextStyle(
                                color: const Color(0xFF222B45).withValues(alpha: 0.65),
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSpecialOffersSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle("عروض مميزة لك"),
        const SizedBox(height: 8),
        SizedBox(
          height: 230,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _stores.take(6).length,
            itemBuilder: (context, i) {
              final store = _stores[i];
              return Container(
                width: 160,
                margin: const EdgeInsets.only(right: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
                ),
                child: GestureDetector(
                  onTap: () => _openDetail(store),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius:
                            const BorderRadius.vertical(top: Radius.circular(12)),
                        child: Image.asset(
                          store.image,
                          height: 110,
                          width: 160,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Text(store.name,
                            style: const TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(height: 4),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Text(
                          '⭐ ${store.rating} (${store.reviews}) · ${store.time}',
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ),
                      if (store.promo != null) ...[
                        const SizedBox(height: 4),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Text(
                            store.promo!,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.red,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildBannerSliderSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle("عروض على منتجاتك المفضلة"),
        const SizedBox(height: 8),
        SizedBox(
          height: 160,
          child: PageView.builder(
            controller: _bannerController,
            itemCount: _bannerImages.length,
            itemBuilder: (context, i) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  _bannerImages[i],
                  fit: BoxFit.cover,
                  width: double.infinity,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHorizontalStoreSection(String title, List<Store> list) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(title),
        const SizedBox(height: 8),
        SizedBox(
          height: 220,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: list.length,
            itemBuilder: (context, i) {
              final s = list[i];
              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: GestureDetector(
                  onTap: () => _openDetail(s),
                  child: Container(
                    width: 160,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius:
                              const BorderRadius.vertical(top: Radius.circular(12)),
                          child: Image.asset(
                            s.image,
                            height: 110,
                            width: 160,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Text(
                            s.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Text(
                            '⭐ ${s.rating} • ${s.time}',
                            style: const TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildVerticalStoreItem(Store s, FavoritesModel favorites) {
    return GestureDetector(
      onTap: () => _openDetail(s),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Stack(children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                s.image,
                width: double.infinity,
                height: 180,
                fit: BoxFit.cover,
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: Consumer<FavoritesModel>(
                builder: (context, favModel, child) {
                  return GestureDetector(
                    onTap: () => favModel.toggleStoreFavorite(s.id),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.9),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        favModel.isStoreFavorite(s.id) 
                            ? Icons.favorite 
                            : Icons.favorite_border,
                        color: favModel.isStoreFavorite(s.id) 
                            ? Colors.red 
                            : Colors.grey[600],
                        size: 20,
                      ),
                    ),
                  );
                },
              ),
            ),
          ]),
          const SizedBox(height: 8),
          Text(s.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 4),
          Text(
            '⭐ ${s.rating} (${s.reviews}) • ${s.distance} • ${s.time}',
            style: const TextStyle(fontSize: 13, color: Colors.grey),
          ),
          Text('رسوم التوصيل: ${s.fee}',
              style: const TextStyle(fontSize: 13, color: Colors.grey)),
          const SizedBox(height: 4),
          if (s.promo != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              margin: const EdgeInsets.only(bottom: 4),
              decoration: BoxDecoration(
                color: Colors.red.shade100,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(s.promo!, style: const TextStyle(fontSize: 12, color: Colors.red)),
            ),
        ]),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
    );
  }

  Widget _buildBottomNavBar() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Color(0xFF00c1e8), width: 1),
        ),
      ),
      child: BottomNavigationBar(
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFF00c1e8),
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        currentIndex: _selectedTabIndex,
        onTap: (i) {
          setState(() => _selectedTabIndex = i);
        },
        items: [
          const BottomNavigationBarItem(icon: Icon(Icons.home), label: 'الرئيسية'),
          BottomNavigationBarItem(
            icon: Consumer<FavoritesModel>(
              builder: (context, favorites, child) {
                return Stack(
                  children: [
                    const Icon(Icons.favorite_border),
                    if (favorites.totalFavoritesCount > 0)
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 12,
                            minHeight: 12,
                          ),
                          child: Text(
                            '${favorites.totalFavoritesCount}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 8,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
            label: 'المفضلة',
          ),
          const BottomNavigationBarItem(icon: Icon(Icons.receipt_long), label: 'طلبات'),
          const BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'حسابي'),
        ],
      ),
    );
  }
}

// ملفات مساعدة مؤقتة (يجب إنشاؤها لاحقاً)
class StoreDetailScreenUpdated extends StatelessWidget {
  final Store store;
  
  const StoreDetailScreenUpdated({super.key, required this.store});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(store.name)),
      body: Center(child: Text('تفاصيل المتجر: ${store.name}')),
    );
  }
}

class SmartSearchBarUpdated extends StatelessWidget {
  final List<Store> stores;
  
  const SmartSearchBarUpdated({super.key, required this.stores});
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(25),
      ),
      child: Row(
        children: [
          Icon(Icons.search, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'بحث عن مطعم أو صنف...',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
        ],
      ),
    );
  }
}

class MapScreenUpdated extends StatelessWidget {
  final List<Store> stores;
  
  const MapScreenUpdated({super.key, required this.stores});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('الخريطة')),
      body: const Center(child: Text('شاشة الخريطة المحدثة')),
    );
  }
}
