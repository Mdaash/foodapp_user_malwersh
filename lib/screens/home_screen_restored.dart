// lib/screens/home_screen.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:foodapp_user/models/store.dart';
import 'package:foodapp_user/models/cart_model.dart';
import 'package:foodapp_user/screens/store_detail_screen.dart';
import 'package:foodapp_user/screens/cart_screen.dart';
import 'package:foodapp_user/screens/favorites_screen_updated.dart';
import 'package:foodapp_user/screens/account_screen.dart';
import 'package:foodapp_user/screens/orders_screen.dart';
import 'package:foodapp_user/widgets/animated_cart_bar.dart';
import 'package:foodapp_user/widgets/modern_cart_icon.dart';
import 'package:foodapp_user/models/favorites_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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
    'أقل من ٥٠ ألف دينار': Icons.attach_money_outlined,
    'مطاعم مشهورة': Icons.star_border,
    'مناسب للأطفال': Icons.child_friendly_outlined,
    'خدمة توصيل سريع': Icons.delivery_dining_outlined,
    'طعام صحي': Icons.health_and_safety_outlined,
    'مطاعم جديدة': Icons.new_releases_outlined,
    'وجبات بحرية': Icons.waves_outlined,
  };

  @override
  void initState() {
    super.initState();
    _bannerController = PageController();
    _setupBannerTimer();
    _loadStores();
    _storesController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _bannerController.dispose();
    _bannerTimer?.cancel();
    _storesController.dispose();
    super.dispose();
  }

  void _setupBannerTimer() {
    _bannerTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (_bannerController.hasClients) {
        _bannerPage = (_bannerPage + 1) % _bannerImages.length;
        _bannerController.animateToPage(
          _bannerPage,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  void _scrollListener() {
    if (_storesController.position.pixels ==
        _storesController.position.maxScrollExtent) {
      _loadStores();
    }
  }

  Future<void> _loadStores() async {
    if (_isLoadingStores || !_hasMoreStores) return;

    setState(() => _isLoadingStores = true);

    await Future.delayed(const Duration(seconds: 1));

    final List<Store> newStores = List.generate(5, (index) {
      final storeId = _stores.length + index + 1;
      return Store(
        id: storeId.toString(),
        name: 'مطعم رقم $storeId',
        image: 'assets/images/restaurant_${(storeId % 6) + 1}.jpg',
        logoUrl: 'assets/images/logo_${(storeId % 6) + 1}.jpg',
        isOpen: true,
        fee: '${5 + (storeId % 5)} آلاف',
        rating: '${4.0 + (storeId % 10) * 0.1}',
        reviews: '${100 + (storeId % 50)}',
        distance: '${1 + (storeId % 10)} كم',
        time: '${20 + (storeId % 15)} دقيقة',
        address: 'بغداد، الكرادة، شارع $storeId',
        category: ['مطاعم', 'وجبات سريعة'][storeId % 2],
        sponsored: false,
        combos: [],
        sandwiches: [],
        drinks: [],
        extras: [],
        specialties: [],
      );
    });

    setState(() {
      _stores.addAll(newStores);
      _page++;
      _isLoadingStores = false;
      if (_page >= 5) _hasMoreStores = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _selectedTabIndex == 0 ? _buildHomeContent() : _buildTabContent(),
      bottomNavigationBar: _buildBottomNavigation(),
      floatingActionButton: Consumer<CartModel>(
        builder: (context, cartModel, child) {
          return cartModel.itemCount > 0
              ? FloatingActionButton.extended(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const CartScreen()),
                  ),
                  backgroundColor: Colors.orange,
                  icon: const Icon(Icons.shopping_cart, color: Colors.white),
                  label: Text(
                    'السلة (${cartModel.itemCount})',
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                )
              : const SizedBox.shrink();
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      automaticallyImplyLeading: false,
      toolbarHeight: 80,
      title: Row(
        children: [
          Icon(Icons.location_on, color: Colors.orange, size: 28),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'توصيل إلى',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                Text(
                  _savedAddress,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Consumer<CartModel>(
            builder: (context, cartModel, child) {
              return ModernCartIcon(
                badgeCount: cartModel.itemCount,
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const CartScreen()),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildHomeContent() {
    return SingleChildScrollView(
      controller: _storesController,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSearchBar(),
          _buildBannerSection(),
          _buildCategoriesSection(),
          _buildFilterChips(),
          _buildStoresSection(),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.all(16),
      child: GestureDetector(
        onTap: () {
          // Navigate to search screen
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Row(
            children: [
              Icon(Icons.search, color: Colors.grey[600], size: 24),
              const SizedBox(width: 12),
              Text(
                'ابحث عن مطاعم أو أطباق...',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBannerSection() {
    return Container(
      height: 180,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: PageView.builder(
        controller: _bannerController,
        itemCount: _bannerImages.length,
        onPageChanged: (index) => setState(() => _bannerPage = index),
        itemBuilder: (context, index) {
          return Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              image: DecorationImage(
                image: AssetImage(_bannerImages[index]),
                fit: BoxFit.cover,
                onError: (exception, stackTrace) {},
              ),
            ),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.3),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCategoriesSection() {
    // قائمة الفئات مع صورها وألوانها المخصصة
    final categories = [
      {"name": "المطاعم", "image": "assets/icons/cat_rest.png", "color": const Color(0xFFFF6B6B)},
      {"name": "سوبرماركت", "image": "assets/icons/cat_supermarket.png", "color": const Color(0xFF00B894)},
      {"name": "الوجبات السريعة", "image": "assets/icons/cat_fast.png", "color": const Color(0xFF4ECDC4)},
      {"name": "الفطور", "image": "assets/icons/cat_break.png", "color": const Color(0xFF45B7D1)},
      {"name": "البقالة", "image": "assets/icons/cat_groce.png", "color": const Color(0xFF96CEB4)},
      {"name": "اللحوم", "image": "assets/icons/cat_meat.png", "color": const Color(0xFFFF9F43)},
      {"name": "حلويات ومثلجات", "image": "assets/icons/cat_dessert.png", "color": const Color(0xFFE17055)},
      {"name": "المشروبات", "image": "assets/icons/cat_juice.png", "color": const Color(0xFFFD79A8)},
      {"name": "الزهور", "image": "assets/icons/cat_flowers.png", "color": const Color(0xFF74B9FF)},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            'تصفح حسب الفئة',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),
        SizedBox(
          height: 140,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              return GestureDetector(
                onTap: () => _openCategoryBottomSheet(
                  category["name"] as String,
                  category["color"] as Color,
                ),
                child: Container(
                  width: 110,
                  margin: const EdgeInsets.only(right: 12),
                  child: Column(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
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
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  color: (category["color"] as Color).withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Icon(
                                  Icons.category,
                                  color: category["color"] as Color,
                                  size: 30,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        category["name"] as String,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        '${_getStoresInCategory(category["name"] as String).length} متجر',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
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

  Widget _buildFilterChips() {
    return Container(
      height: 50,
      margin: const EdgeInsets.only(top: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _filterIcons.keys.length,
        itemBuilder: (context, index) {
          final filterName = _filterIcons.keys.elementAt(index);
          final filterIcon = _filterIcons[filterName]!;

          return Container(
            margin: const EdgeInsets.only(right: 8),
            child: FilterChip(
              avatar: Icon(filterIcon, size: 18, color: Colors.orange),
              label: Text(
                filterName,
                style: const TextStyle(fontSize: 12),
              ),
              onSelected: (bool value) {},
              backgroundColor: Colors.grey[100],
              selectedColor: Colors.orange.withValues(alpha: 0.2),
              checkmarkColor: Colors.orange,
            ),
          );
        },
      ),
    );
  }

  Widget _buildStoresSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            'المطاعم المتاحة',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),
        Consumer<FavoritesModel>(
          builder: (context, favModel, child) {
            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _stores.length + (_isLoadingStores ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _stores.length) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                final store = _stores[index];
                return _buildStoreCard(store, favModel);
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildStoreCard(Store store, FavoritesModel favModel) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              Container(
                height: 150,
                decoration: BoxDecoration(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(12)),
                  image: DecorationImage(
                    image: AssetImage(store.imageUrl),
                    fit: BoxFit.cover,
                    onError: (exception, stackTrace) {},
                  ),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(12)),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.1),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: GestureDetector(
                  onTap: () => context
                      .read<FavoritesModel>()
                      .toggleStoreFavorite(store.id),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(
                      favModel.isStoreFavorite(store.id)
                          ? Icons.favorite
                          : Icons.favorite_border,
                      color: favModel.isStoreFavorite(store.id)
                          ? Colors.red
                          : Colors.grey,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        store.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          store.ratingValue.toStringAsFixed(1),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  store.category ?? 'مطعم',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.access_time, color: Colors.grey[600], size: 16),
                    const SizedBox(width: 4),
                    Text(
                      store.deliveryTime,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                    const SizedBox(width: 16),
                    Icon(Icons.delivery_dining,
                        color: Colors.grey[600], size: 16),
                    const SizedBox(width: 4),
                    Text(
                      store.deliveryFee,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                    const SizedBox(width: 16),
                    Icon(Icons.location_on, color: Colors.grey[600], size: 16),
                    const SizedBox(width: 4),
                    Text(
                      store.distance,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabContent() {
    switch (_selectedTabIndex) {
      case 1:
        return FavoritesScreenUpdated(stores: _stores);
      case 2:
        return _buildMapScreen();
      case 3:
        return const OrdersScreen();
      case 4:
        return const AccountScreen();
      default:
        return _buildHomeContent();
    }
  }

  Widget _buildMapScreen() {
    return const Scaffold(
      body: Center(child: Text('شاشة الخريطة المحدثة')),
    );
  }

  Widget _buildBottomNavigation() {
    return Consumer<CartModel>(
      builder: (context, cartModel, child) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (cartModel.itemCount > 0) 
              AnimatedCartBar(
                storeName: _stores.isNotEmpty ? _stores.first.name : 'متجر',
                isExpanded: false,
              ),
            BottomNavigationBar(
              currentIndex: _selectedTabIndex,
              onTap: (index) => setState(() => _selectedTabIndex = index),
              type: BottomNavigationBarType.fixed,
              selectedItemColor: Colors.orange,
              unselectedItemColor: Colors.grey,
              backgroundColor: Colors.white,
              elevation: 8,
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home),
                  label: 'الرئيسية',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.favorite),
                  label: 'المفضلة',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.map),
                  label: 'الخريطة',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.receipt_long),
                  label: 'طلباتي',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person),
                  label: 'حسابي',
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  // Helper methods
  List<Store> _getStoresInCategory(String categoryName) {
    return _stores.where((store) => 
      store.category?.toLowerCase() == categoryName.toLowerCase() ||
      (categoryName == "المطاعم" && (store.category == null || store.category!.isEmpty))
    ).toList();
  }

  void _openCategoryBottomSheet(String categoryName, Color categoryColor) {
    final stores = _getStoresInCategory(categoryName);
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
          ),
          child: Column(
            children: [
              // مؤشر الرقبة
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                height: 4,
                width: 40,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              
              // العنوان الرئيسي
              Container(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      categoryColor.withValues(alpha: 0.05),
                      Colors.transparent,
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  border: const Border(
                    bottom: BorderSide(
                      color: Color(0xFFE5E5E5),
                      width: 1,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    // صورة الفئة بدلاً من الأيقونة
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            categoryColor.withValues(alpha: 0.15),
                            categoryColor.withValues(alpha: 0.05),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: categoryColor.withValues(alpha: 0.3),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: categoryColor.withValues(alpha: 0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: Image.asset(
                          _getCategoryImage(categoryName),
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: categoryColor.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Icon(
                                _getCategoryIcon(categoryName),
                                color: categoryColor,
                                size: 24,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    
                    // تفاصيل الفئة
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            categoryName,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: categoryColor.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: categoryColor.withValues(alpha: 0.3),
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  '${stores.length} متجر متاح',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: categoryColor,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Icon(
                                Icons.storefront,
                                size: 16,
                                color: Colors.grey[600],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    
                    // زر الإغلاق
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.close, color: Colors.grey),
                        onPressed: () => Navigator.pop(context),
                        iconSize: 20,
                      ),
                    ),
                  ],
                ),
              ),
              
              // قائمة المتاجر
              Expanded(
                child: stores.isEmpty
                    ? _buildEmptyCategoryState(categoryName)
                    : ListView.builder(
                        controller: scrollController,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        itemCount: stores.length,
                        itemBuilder: (context, index) {
                          final store = stores[index];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withValues(alpha: 0.08),
                                  blurRadius: 10,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                              border: Border.all(
                                color: Colors.grey.withValues(alpha: 0.1),
                                width: 1,
                              ),
                            ),
                            child: _buildCategoryStoreItem(store),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper methods for category management
  String _getCategoryImage(String categoryName) {
    switch (categoryName) {
      case "المطاعم":
        return "assets/icons/cat_rest.png";
      case "سوبرماركت":
        return "assets/icons/cat_supermarket.png";
      case "الوجبات السريعة":
        return "assets/icons/cat_fast.png";
      case "الفطور":
        return "assets/icons/cat_break.png";
      case "البقالة":
        return "assets/icons/cat_groce.png";
      case "اللحوم":
        return "assets/icons/cat_meat.png";
      case "حلويات ومثلجات":
        return "assets/icons/cat_dessert.png";
      case "المشروبات":
        return "assets/icons/cat_juice.png";
      case "الزهور":
        return "assets/icons/cat_flowers.png";
      default:
        return "assets/icons/cat_other.png";
    }
  }

  IconData _getCategoryIcon(String categoryName) {
    switch (categoryName) {
      case "المطاعم":
        return Icons.restaurant;
      case "سوبرماركت":
        return Icons.store;
      case "الوجبات السريعة":
        return Icons.fastfood;
      case "الفطور":
        return Icons.breakfast_dining;
      case "البقالة":
        return Icons.local_grocery_store;
      case "اللحوم":
        return Icons.set_meal;
      case "حلويات ومثلجات":
        return Icons.cake;
      case "المشروبات":
        return Icons.local_drink;
      case "الزهور":
        return Icons.local_florist;
      default:
        return Icons.category;
    }
  }

  Widget _buildEmptyCategoryState(String categoryName) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.store_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'لا توجد متاجر متاحة',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'لا توجد متاجر في فئة "$categoryName" حالياً',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back, size: 18),
            label: const Text('العودة'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00c1e8),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryStoreItem(Store store) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => StoreDetailScreen(
              store: store,
              favoriteStoreIds: const {},
              onFavoriteToggle: (isFavorite) {
                // Handle favorite toggle
              },
            ),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // صورة المتجر
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Image.asset(
                  store.logoUrl.isNotEmpty ? store.logoUrl : 'assets/images/store_placeholder.png',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF00c1e8).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.store,
                        color: Color(0xFF00c1e8),
                        size: 30,
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(width: 16),
            
            // تفاصيل المتجر
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // اسم المتجر والتقييم
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          store.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.amber.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.star, color: Colors.amber, size: 14),
                            const SizedBox(width: 2),
                            Text(
                              store.rating,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  
                  // معلومات إضافية
                  Row(
                    children: [
                      Icon(Icons.access_time, size: 14, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        store.time,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Icon(Icons.delivery_dining, size: 14, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        store.fee,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  
                  // العنوان
                  if (store.address.isNotEmpty)
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 12,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(width: 2),
                        Expanded(
                          child: Text(
                            store.address,
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey[500],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
            
            // زر المفضلة
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Consumer<FavoritesModel>(
                builder: (context, favModel, child) {
                  return IconButton(
                    icon: Icon(
                      favModel.isStoreFavorite(store.id) ? Icons.favorite : Icons.favorite_border,
                      color: favModel.isStoreFavorite(store.id) ? Colors.red : Colors.grey[400],
                      size: 20,
                    ),
                    onPressed: () => favModel.toggleStoreFavorite(store.id),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
