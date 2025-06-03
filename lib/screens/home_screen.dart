// lib/screens/home_screen.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:foodapp_user/models/store.dart';
import 'package:foodapp_user/models/cart_model.dart';
import 'package:foodapp_user/screens/store_detail_screen.dart';
import 'package:foodapp_user/screens/cart_screen.dart';
import 'package:foodapp_user/screens/favorites_screen.dart';
import 'package:foodapp_user/screens/account_screen.dart';
import 'package:foodapp_user/screens/orders_screen.dart';
import 'package:foodapp_user/screens/map_screen.dart';
import 'package:foodapp_user/widgets/animated_cart_bar.dart';
import 'address_edit_sheet.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // المتاجر والمفضّلة
  final Set<String> favoriteStoreIds = {};
  final Set<String> favoriteDishIds = {};
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
  String _savedCity = 'بغداد';
  String _savedArea = 'الكرادة';
  String _savedDistrict = 'حي 123';
  String _savedLandmark = 'قرب الجامعة';
  String _savedAddress = 'بغداد، الكرادة، حي 123، قرب الجامعة';

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

  // إرجاع جميع المتاجر (الفلاتر تعرض في شاشات منفصلة)
  List<Store> get _filteredStores {
    return _stores;
  }

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
        builder: (_) => StoreDetailScreen(
          store: s,
          favoriteStoreIds: favoriteStoreIds,
          onFavoriteToggle: (fav) {
            setState(() {
              if (fav) {
                favoriteStoreIds.add(s.id);
              } else {
                favoriteStoreIds.remove(s.id);
              }
            });
          },
        ),
      ),
    );
    
    // إذا تم الإرجاع بتبويب محدد، قم بتغيير التبويب
    if (result != null && result != _selectedTabIndex) {
      setState(() {
        _selectedTabIndex = result;
      });
    }
  }

  Future<void> _showAddressSheet() async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: const [
                    Icon(Icons.location_on, color: Color(0xFF00c1e8)),
                    SizedBox(width: 8),
                    Text('عناويني', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  ],
                ),
              ),
              // العنوان المحفوظ
              ListTile(
                title: Text(_savedAddress, style: const TextStyle(fontWeight: FontWeight.bold)),
                trailing: IconButton(
                  icon: const Icon(Icons.edit, color: Color(0xFF00c1e8)), // رمز التعديل
                  onPressed: () async {
                    await showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      builder: (context) => AddressEditSheet(
                        city: _savedCity,
                        area: _savedArea,
                        district: _savedDistrict,
                        landmark: _savedLandmark,
                        onSave: (city, area, district, landmark) {
                          setState(() {
                            _savedCity = city;
                            _savedArea = area;
                            _savedDistrict = district;
                            _savedLandmark = landmark;
                            _savedAddress = '$city، $area، $district، $landmark';
                          });
                          Navigator.pop(context); // يغلق شاشة التعديل
                        },
                      ),
                    );
                  },
                ),
              ),
              const Divider(),
              // زر الموقع الحالي
              Padding(
                padding: const EdgeInsets.all(16),
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00c1e8)),
                  icon: const Icon(Icons.my_location, color: Colors.white),
                  label: const Text('استخدام موقعي الحالي', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  onPressed: () async {
                    final scaffoldMessenger = ScaffoldMessenger.of(context);
                    Navigator.pop(context);
                    try {
                      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
                      if (!serviceEnabled) {
                        if (mounted) {
                          scaffoldMessenger.showSnackBar(
                            const SnackBar(
                              content: Text('خدمات الموقع غير مفعلة. يرجى تفعيلها من الإعدادات.'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                        return;
                      }

                      LocationPermission permission = await Geolocator.checkPermission();
                      if (permission == LocationPermission.denied) {
                        permission = await Geolocator.requestPermission();
                        if (permission == LocationPermission.denied) {
                          if (mounted) {
                            scaffoldMessenger.showSnackBar(
                              const SnackBar(
                                content: Text('تم رفض إذن الموقع. يرجى السماح للتطبيق باستخدام الموقع.'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                          return;
                        }
                      }

                      if (permission == LocationPermission.deniedForever) {
                        if (mounted) {
                          scaffoldMessenger.showSnackBar(
                            const SnackBar(
                              content: Text('إذن الموقع مرفوض نهائياً. يرجى تفعيله من إعدادات النظام.'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                        return;
                      }

                      Position pos = await Geolocator.getCurrentPosition(
                        locationSettings: const LocationSettings(
                          accuracy: LocationAccuracy.high,
                          distanceFilter: 100,
                        ),
                      );
                      // print('الإحداثيات: ${pos.latitude}, ${pos.longitude}');

                      List<Placemark> placemarks = await placemarkFromCoordinates(pos.latitude, pos.longitude);
                      if (placemarks.isNotEmpty) {
                        final place = placemarks.first;
                        // print('العنوان النصي: ${place.country}, ${place.administrativeArea}, ${place.locality}, ${place.street}');
                        setState(() {
                          _savedAddress = '${place.country ?? ''}، ${place.administrativeArea ?? ''}، ${place.locality ?? ''}، ${place.street ?? ''}';
                        });
                      } else {
                        setState(() {
                          _savedAddress = 'موقعك الحالي: ${pos.latitude.toStringAsFixed(5)}, ${pos.longitude.toStringAsFixed(5)}';
                        });
                      }
                    } catch (e) {
                      // print('خطأ أثناء جلب الموقع: $e');
                      if (mounted) {
                        scaffoldMessenger.showSnackBar(
                          SnackBar(
                            content: Text('تعذر الحصول على الموقع الحالي: $e'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // معالج اختيار الفئة
  void _onCategorySelected(String categoryName) {
    // قائمة المتاجر المصفاة حسب الفئة
    final filteredStores = _stores.where((store) {
      switch (categoryName) {
        case "المطاعم":
          return store.category?.contains("مطعم") == true || 
                 store.name.contains("مطعم");
        case "الوجبات السريعة":
          return store.category?.contains("وجبات سريعة") == true ||
                 store.name.toLowerCase().contains("برجر") ||
                 store.name.toLowerCase().contains("بيتزا") ||
                 store.name.toLowerCase().contains("دجاج");
        case "الفطور":
          return store.category?.contains("فطور") == true ||
                 store.name.contains("فطور") ||
                 store.name.contains("كافيه");
        case "البقالة":
          return store.category?.contains("بقالة") == true ||
                 store.name.contains("بقالة");
        case "اللحوم":
          return store.category?.contains("لحوم") == true ||
                 store.name.contains("لحوم") ||
                 store.name.contains("جزارة");
        case "حلويات ومثلجات":
          return store.category?.contains("حلويات") == true ||
                 store.name.contains("حلويات") ||
                 store.name.contains("آيس كريم");
        case "الخضار":
          return store.category?.contains("خضار") == true ||
                 store.name.contains("خضار") ||
                 store.name.contains("فواكه");
        case "المشروبات":
          return store.category?.contains("مشروبات") == true ||
                 store.name.contains("عصير") ||
                 store.name.contains("قهوة");
        case "سوبرماركت":
          return store.category?.contains("سوبرماركت") == true ||
                 store.name.contains("سوبرماركت") ||
                 store.name.contains("هايبر");
        case "الزهور":
          return store.category?.contains("زهور") == true ||
                 store.name.contains("زهور") ||
                 store.name.contains("ورود");
        default:
          return true; // فئة "أخرى" تعرض جميع المتاجر
      }
    }).toList();

    // عرض نتائج البحث
    if (filteredStores.isNotEmpty) {
      _showCategoryResultsBottomSheet(categoryName, filteredStores);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('لا توجد متاجر متاحة في فئة "$categoryName" حالياً'),
          backgroundColor: Colors.orange,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  // عرض نتائج الفئة في bottom sheet
  void _showCategoryResultsBottomSheet(String categoryName, List<Store> stores) {
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
                  Expanded(
                    child: Text(
                      'متاجر فئة "$categoryName" (${stores.length})',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // قائمة المتاجر
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: stores.length,
                itemBuilder: (context, index) {
                  final store = stores[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _buildVerticalStoreItem(store),
                  );
                },
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
        backgroundColor: Colors.white,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(160), // Increased height further to prevent overflow
          child: SafeArea(
            top: false,
            bottom: false,
            child: _selectedTabIndex == 0 
                ? _buildTopBar(context)  // الرئيسية - شريط كامل
                : _buildAccountTopBar(context),  // باقي الشاشات - السلة فقط
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
                    const SizedBox(height: 20),
                    _buildFilterRow(),
                    const SizedBox(height: 20),
                    _buildSpecialOffersSection(),
                    const SizedBox(height: 20),
                    _buildBannerSliderSection(),
                    const SizedBox(height: 20),
                    _buildHorizontalStoreSection("وصل حديثًا إلى زاد", _filteredStores),
                    const SizedBox(height: 20),
                    _buildHorizontalStoreSection("الأقرب إليك", _filteredStores),
                    const SizedBox(height: 20),
                    _buildHorizontalStoreSection("الأكثر شهرة", _filteredStores),
                    const SizedBox(height: 20),
                    _buildHorizontalStoreSection("المطاعم الأعلى تقييماً", _filteredStores),
                    const SizedBox(height: 20),
                    _buildHorizontalStoreSection("جديد في منطقتك", _filteredStores),
                    const SizedBox(height: 20),
                    _buildSectionTitle("جميع المتاجر"),
                    const SizedBox(height: 8),
                    ..._filteredStores.map((s) => _buildVerticalStoreItem(s)),
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
            FavoritesScreen(
              stores: _stores,
              favoriteStoreIds: favoriteStoreIds,
              favoriteDishIds: favoriteDishIds,
              onToggleStoreFavorite: (id) => setState(() => favoriteStoreIds.remove(id)),
              onToggleDishFavorite: (id) => setState(() => favoriteDishIds.remove(id)),
              onBack: () => setState(() => _selectedTabIndex = 0),
            ),
            // الطلبات
            OrdersScreen(onBack: () => setState(() => _selectedTabIndex = 0)),
            // حسابي
            AccountScreen(onBack: () => setState(() => _selectedTabIndex = 0)),
          ],
        ),
        bottomNavigationBar: _buildBottomNavBar(),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.only(top: 12, bottom: 4), // Reduced bottom padding
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // الوقت + أيقونة العربة
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                const Icon(Icons.access_time, size: 18),
                const SizedBox(width: 4),
                const Text("21:39", style: TextStyle(fontSize: 16)),
                const Spacer(),
                Consumer<CartModel>(
                  builder: (context, cart, _) => Stack(
                    alignment: Alignment.topRight,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.shopping_cart_outlined),
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
          ),
          const SizedBox(height: 8),
          // العنوان + الموقع
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                const Icon(Icons.location_on, color: Color(0xFF00c1e8)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _savedAddress,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.keyboard_arrow_down),
                  onPressed: _showAddressSheet,
                ),
              ],
            ),
          ),
          const SizedBox(height: 4), // Reduced spacing
          // شريط البحث وأيقونة الخريطة
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2), // Further reduced vertical padding
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 40, // Reduced height to fit within the layout
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.search),
                        SizedBox(width: 8),
                        Text('بحث عن مطعم أو صنف...'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => MapScreen(
                          stores: _stores,
                          favoriteStoreIds: favoriteStoreIds,
                          onToggleStoreFavorite: (id) {
                            setState(() {
                              if (favoriteStoreIds.contains(id)) {
                                favoriteStoreIds.remove(id);
                              } else {
                                favoriteStoreIds.add(id);
                              }
                            });
                          },
                        ),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                        color: Colors.grey[200], shape: BoxShape.circle),
                    child: const Icon(Icons.map_outlined),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountTopBar(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.only(top: 12, bottom: 8),
      child: Row(
        children: [
          const Spacer(),
          Consumer<CartModel>(
            builder: (context, cart, _) => Stack(
              alignment: Alignment.topRight,
              children: [
                IconButton(
                  icon: const Icon(Icons.shopping_cart_outlined),
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

  // Carousel widget for categories using Flutter icons
  Widget _buildCategoriesCarousel() {
    final categories = [
      {"name": "المطاعم", "icon": Icons.restaurant, "color": const Color(0xFFFF6B6B)},
      {"name": "الوجبات السريعة", "icon": Icons.fastfood, "color": const Color(0xFF4ECDC4)},
      {"name": "الفطور", "icon": Icons.free_breakfast, "color": const Color(0xFF45B7D1)},
      {"name": "البقالة", "icon": Icons.local_grocery_store, "color": const Color(0xFF96CEB4)},
      {"name": "اللحوم", "icon": Icons.set_meal, "color": const Color(0xFFFF9F43)},
      {"name": "حلويات ومثلجات", "icon": Icons.icecream, "color": const Color(0xFFE17055)},
      {"name": "الخضار", "icon": Icons.eco, "color": const Color(0xFF6C5CE7)},
      {"name": "المشروبات", "icon": Icons.local_drink, "color": const Color(0xFFFD79A8)},
      {"name": "سوبرماركت", "icon": Icons.store, "color": const Color(0xFF00B894)},
      {"name": "الزهور", "icon": Icons.local_florist, "color": const Color(0xFFFF7675)},
      {"name": "أخرى", "icon": Icons.category, "color": const Color(0xFF74B9FF)},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              return Container(
                width: 90,
                margin: const EdgeInsets.only(right: 16),
                child: GestureDetector(
                  onTap: () {
                    _onCategorySelected(category["name"] as String);
                  },
                  child: Column(
                    children: [
                      Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: (category["color"] as Color).withValues(alpha: 0.3),
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: (category["color"] as Color).withValues(alpha: 0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(
                          category["icon"] as IconData,
                          color: category["color"] as Color,
                          size: 40,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        category["name"] as String,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
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

  // شريط الفلاتر مع تصميم محسّن
  Widget _buildFilterRow() => Container(
        height: 64, // تقليل الارتفاع قليلاً
        padding: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          border: Border(
            top: BorderSide(color: Colors.grey[200]!, width: 0.5),
            bottom: BorderSide(color: Colors.grey[200]!, width: 0.5),
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

  Widget _buildFilterChip(String label) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        _showFilterResultsBottomSheet(label);
      },
      child: Container(
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
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF00c1e8).withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, 3),
              spreadRadius: 0,
            ),
            BoxShadow(
              color: Colors.white.withValues(alpha: 0.8),
              blurRadius: 6,
              offset: const Offset(0, -1),
              spreadRadius: 0,
            ),
          ],
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
      ),
    );
  }

  // عرض نتائج الفلتر في bottom sheet
  void _showFilterResultsBottomSheet(String filterLabel) {
    List<Store> filteredStores = [];
    
    // تطبيق الفلتر حسب النوع
    switch (filterLabel) {
      case 'أقل من ٣٠ دقيقة':
        filteredStores = _stores.where((s) {
          final time = int.tryParse(s.time.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
          return time > 0 && time <= 30;
        }).toList();
        break;
      case 'رسوم التوصيل':
        _showDeliveryFeeBottomSheet();
        return;
      case 'استلام مباشر':
        filteredStores = _stores.where((s) => 
          s.fee == 'استلام فقط' || s.fee == 'استلام'
        ).toList();
        break;
      case 'مفتوح الآن':
        filteredStores = _stores.where((s) => s.isOpen == true).toList();
        break;
      case 'خصومات':
        filteredStores = _stores.where((s) => 
          s.promo != null && s.promo!.isNotEmpty
        ).toList();
        break;
    }

    // عرض النتائج
    if (filteredStores.isNotEmpty) {
      _showFilteredStoresBottomSheet(filterLabel, filteredStores);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('لا توجد متاجر متاحة في فلتر "$filterLabel" حالياً'),
          backgroundColor: Colors.orange,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  // عرض المتاجر المفلترة في bottom sheet مع تصميم محسن
  void _showFilteredStoresBottomSheet(String filterLabel, List<Store> stores) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: Container(
          height: MediaQuery.of(context).size.height * 0.8,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
          ),
          child: Column(
            children: [
              // Handle Bar
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Header مع تصميم محسن
              Container(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(
                    bottom: BorderSide(color: Colors.grey[100]!, width: 1),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF00c1e8).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        _filterIcons[filterLabel] ?? Icons.filter_alt,
                        size: 24,
                        color: const Color(0xFF00c1e8),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            filterLabel, // فقط اسم الفلتر
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2D3436),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${stores.length} متجر متاح',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Icon(Icons.close, size: 18),
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              // قائمة المتاجر
              Expanded(
                child: stores.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.grey[50],
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.search_off,
                                size: 48,
                                color: Colors.grey[400],
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'لا توجد متاجر متاحة',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'جرب فلتر آخر أو تصفح جميع المتاجر',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: stores.length,
                        itemBuilder: (context, index) {
                          final store = stores[index];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.grey[200]!, width: 1),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.04),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(16),
                                onTap: () {
                                  Navigator.pop(context);
                                  _openDetail(store);
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Row(
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child: Image.asset(
                                          store.image,
                                          width: 70,
                                          height: 70,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    store.name,
                                                    style: const TextStyle(
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 15,
                                                      color: Color(0xFF2D3436),
                                                    ),
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ),
                                                Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                  decoration: BoxDecoration(
                                                    color: store.isOpen ? Colors.green.withValues(alpha: 0.1) : Colors.red.withValues(alpha: 0.1),
                                                    borderRadius: BorderRadius.circular(12),
                                                  ),
                                                  child: Text(
                                                    store.isOpen ? 'مفتوح' : 'مغلق',
                                                    style: TextStyle(
                                                      color: store.isOpen ? Colors.green[700] : Colors.red[700],
                                                      fontSize: 11,
                                                      fontWeight: FontWeight.w600,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 6),
                                            Row(
                                              children: [
                                                Icon(Icons.star, color: Colors.amber[600], size: 16),
                                                const SizedBox(width: 4),
                                                Text(store.rating, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                                                const SizedBox(width: 8),
                                                Text('(${store.reviews})', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                                                const SizedBox(width: 12),
                                                Icon(Icons.access_time, size: 14, color: Colors.grey[600]),
                                                const SizedBox(width: 4),
                                                Text(store.time, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                                              ],
                                            ),
                                            const SizedBox(height: 4),
                                            Row(
                                              children: [
                                                Icon(Icons.location_on, size: 14, color: Colors.grey[600]),
                                                const SizedBox(width: 4),
                                                Text(store.distance, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                                                const SizedBox(width: 12),
                                                Text('رسوم التوصيل: ${store.fee}', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                                              ],
                                            ),
                                            if (store.promo != null)
                                              Padding(
                                                padding: const EdgeInsets.only(top: 4),
                                                child: Text(store.promo!, style: const TextStyle(fontSize: 12, color: Colors.red)),
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
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // قائمة سفلية لرسوم التوصيل
  Future<void> _showDeliveryFeeBottomSheet() async {
    double tempFee = 10; // الحد الأقصى الافتراضي
    bool tempFree = false;
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: MediaQuery.of(context).viewInsets,
              child: Container(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Icon(
                          _filterIcons['رسوم التوصيل'] ?? Icons.local_shipping_outlined,
                          size: 32,
                          color: const Color(0xFF00c1e8),
                        ),
                        const SizedBox(width: 12),
                        const Text('تصفية حسب رسوم التوصيل', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Checkbox(
                          value: tempFree,
                          onChanged: (v) => setModalState(() => tempFree = v ?? false),
                        ),
                        const Text('توصيل مجاني فقط', style: TextStyle(fontSize: 15)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Text('رسوم التوصيل', style: TextStyle(fontSize: 15)),
                        Expanded(
                          child: Slider(
                            value: tempFee,
                            min: 0,
                            max: 10,
                            divisions: 10,
                            label: tempFee == 0 ? 'مجاني' : '${tempFee.toInt()} د.ع',
                            onChanged: tempFree
                                ? null
                                : (v) => setModalState(() => tempFee = v),
                          ),
                        ),
                        Text(tempFee == 0 ? 'مجاني' : '${tempFee.toInt()} د.ع'),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF00c1e8),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            onPressed: () {
                              // تطبيق الفلتر وعرض النتائج
                              List<Store> filteredStores = [];
                              if (tempFree) {
                                filteredStores = _stores.where((s) => 
                                  s.fee == '0' || s.fee == '0\$'
                                ).toList();
                              } else {
                                filteredStores = _stores.where((s) {
                                  final fee = double.tryParse(s.fee.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0;
                                  return fee <= tempFee;
                                }).toList();
                              }
                              
                              Navigator.pop(context);
                              
                              if (filteredStores.isNotEmpty) {
                                _showFilteredStoresBottomSheet(
                                  tempFree ? 'توصيل مجاني' : 'رسوم التوصيل (حتى ${tempFee.toInt()} د.ع)',
                                  filteredStores
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('لا توجد متاجر متاحة بهذا الفلتر حالياً'),
                                    backgroundColor: Colors.orange,
                                    duration: Duration(seconds: 3),
                                  ),
                                );
                              }
                            },
                            child: const Text('عرض النتائج', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSpecialOffersSection() {
    final offers = [
      {
        "image": "assets/images/food_placeholder.png",
        "name": "مطعم الريف",
        "rating": "4.6",
        "reviews": "500+",
        "time": "25 دقيقة",
        "fee": "0\$",
        "promo": "خصم 20% حتى 5\$",
      },
      {
        "image": "assets/images/food_placeholder.png",
        "name": "مطعم الفخامة",
        "rating": "4.8",
        "reviews": "1k+",
        "time": "30 دقيقة",
        "fee": "1\$",
        "promo": "اشتر 1 واحصل على 1",
      },
      {
        "image": "assets/images/food_placeholder.png",
        "name": "برغر تايم",
        "rating": "4.5",
        "reviews": "400+",
        "time": "20 دقيقة",
        "fee": "0\$",
        "promo": null,
      },
      {
        "image": "assets/images/food_placeholder.png",
        "name": "مطعم الريف",
        "rating": "4.6",
        "reviews": "500+",
        "time": "25 دقيقة",
        "fee": "0\$",
        "promo": "خصم 20% حتى 5\$",
      },
      {
        "image": "assets/images/food_placeholder.png",
        "name": "مطعم الفخامة",
        "rating": "4.8",
        "reviews": "1k+",
        "time": "30 دقيقة",
        "fee": "1\$",
        "promo": "اشتر 1 واحصل على 1",
      },
      {
        "image": "assets/images/food_placeholder.png",
        "name": "برغر تايم",
        "rating": "4.5",
        "reviews": "400+",
        "time": "20 دقيقة",
        "fee": "0\$",
        "promo": null,
      },
    ];

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
            itemCount: offers.length,
            itemBuilder: (context, i) {
              final o = offers[i];
              return Container(
                width: 160,
                margin: const EdgeInsets.only(right: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
                ),
                child: GestureDetector(
                  onTap: () {
                    if (_stores.isNotEmpty) _openDetail(_stores.first);
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius:
                            const BorderRadius.vertical(top: Radius.circular(12)),
                        child: Image.asset(
                          o["image"]!,
                          height: 110,
                          width: 160,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Text(o["name"]!,
                            style: const TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(height: 4),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Text(
                          '⭐ ${o["rating"]!} (${o["reviews"]!}) · ${o["time"]!}',
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Text(
                          'رسوم التوصيل: ${o["fee"]!}',
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ),
                      const SizedBox(height: 4),
                      if (o["promo"] != null)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Text(
                            o["promo"]!,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.red,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
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

  Widget _buildBannerSliderSection() => Column(
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

  Widget _buildHorizontalStoreSection(String title, List<Store> list) =>
      Column(
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

  Widget _buildVerticalStoreItem(Store s) {
    final isFav = favoriteStoreIds.contains(s.id);
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
              child: GestureDetector(
                onTap: () => setState(() {
                  if (isFav) {
                    favoriteStoreIds.remove(s.id);
                  } else {
                    favoriteStoreIds.add(s.id);
                  }
                }),
                child: Icon(
                  isFav ? Icons.favorite : Icons.favorite_border,
                  color: Colors.red,
                  size: 28,
                ),
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
          Row(children: [
            if (s.sponsored)
              _buildBadge("مُموّل", Colors.grey.shade200, Colors.black54)
            else if (s.category != null)
              _buildBadge(s.category!, Colors.grey.shade200, Colors.black54),
            const SizedBox(width: 8),
            if (s.tag != null) _buildBadge(s.tag!, Colors.grey.shade300, Colors.red),
          ]),
        ]),
      ),
    );
  }

  // دالة عنوان القسم
  Widget _buildSectionTitle(String title) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
  );

  // دالة شارة (Badge)
  Widget _buildBadge(String text, Color bgColor, Color textColor) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(4)),
    child: Text(text, style: TextStyle(fontSize: 11, color: textColor, fontWeight: FontWeight.w500)),
  );

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
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'الرئيسية'),
          BottomNavigationBarItem(icon: Icon(Icons.favorite_border), label: 'المفضلة'),
          BottomNavigationBarItem(icon: Icon(Icons.receipt_long), label: 'طلبات'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'حسابي'),
        ],
      ),
    );
  }
}
