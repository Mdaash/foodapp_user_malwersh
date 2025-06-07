// lib/screens/home_screen.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:foodapp_user/models/store.dart';
import 'package:foodapp_user/models/cart_model.dart';
import 'package:foodapp_user/models/offer.dart';
import 'package:foodapp_user/screens/store_detail_screen.dart';
import 'package:foodapp_user/screens/dish_detail_screen.dart';
import 'package:foodapp_user/screens/cart_screen.dart';
import 'package:foodapp_user/screens/favorites_screen.dart';
import 'package:foodapp_user/screens/account_screen.dart';
import 'package:foodapp_user/screens/orders_screen.dart';
import 'package:foodapp_user/screens/map_screen.dart';
import 'package:foodapp_user/screens/coupons_screen.dart';
import 'package:foodapp_user/screens/rewards_screen.dart';
import 'package:foodapp_user/services/search_service.dart';
import 'package:foodapp_user/models/search_result.dart';
import 'package:foodapp_user/widgets/animated_cart_bar.dart';
import 'package:foodapp_user/widgets/modern_cart_icon.dart';
import 'package:foodapp_user/widgets/smart_search_bar.dart';
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

  // عرض نتائج الفلتر في bottom sheet
  void _showFilterResultsBottomSheet(String filterLabel) {
    // البحث عن المتاجر التي تحتوي على الفلتر المحدد
    List<Store> filteredStores = _stores.where((store) {
      switch (filterLabel) {
        case "توصيل سريع":
          return store.time.contains("20") || store.time.contains("15");
        case "عروض خاصة":
          return store.promo != null && store.promo!.isNotEmpty;
        case "تقييم عالي":
          double rating = double.tryParse(store.rating) ?? 0.0;
          return rating >= 4.0;
        case "مفتوح الآن":
          return store.isOpen;
        default:
          return store.name.toLowerCase().contains(filterLabel.toLowerCase()) ||
                 (store.category?.toLowerCase().contains(filterLabel.toLowerCase()) ?? false);
      }
    }).toList();

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
                      'متاجر "$filterLabel" (${filteredStores.length})',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Store List
            Expanded(
              child: filteredStores.isNotEmpty
                  ? ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: filteredStores.length,
                      itemBuilder: (context, index) {
                        final store = filteredStores[index];
                        return GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                            _openDetail(store);
                          },
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey[300]!),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withValues(alpha: 0.1),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.asset(
                                    store.image,
                                    width: 60,
                                    height: 60,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        store.name,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        store.category ?? '',
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 12,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Icon(Icons.star, color: Colors.orange, size: 14),
                                          Text(
                                            store.rating,
                                            style: const TextStyle(fontSize: 12),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            store.time,
                                            style: TextStyle(
                                              color: Colors.grey[600],
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    )
                  : const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search_off,
                            size: 64,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'لا توجد متاجر متاحة',
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

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(180), // زيادة الارتفاع لمنع overflow
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
                    _buildRewardsAndCouponsSection(),
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
                onPressed: _showAddressSheet,
              ),
            ],
          ),
          const SizedBox(height: 8),
          // شريط البحث وأيقونة الخريطة
          Row(
            children: [
              Expanded(
                child: SmartSearchBar(
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
                  hintText: 'بحث عن مطعم أو صنف...',
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
                      // خلفية الخريطة بلون التطبيق
                      Icon(
                        Icons.map,
                        color: const Color(0xFF00c1e8),
                        size: 20,
                      ),
                      // علامة الـ Pin الحمراء في الوسط
                      Positioned(
                        top: 2,
                        child: Icon(
                          Icons.location_on,
                          color: Colors.red,
                          size: 12,
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

  // قسم "استخدم ووفر" - المكافآت والقسائم (تصميم زجاجي عصري ومتناسق)
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
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00c1e8).withValues(alpha: 0.15),
            blurRadius: 16,
            offset: const Offset(0, 8),
            spreadRadius: 2,
          ),
          BoxShadow(
            color: Colors.white.withValues(alpha: 0.7),
            blurRadius: 6,
            offset: const Offset(0, -2),
            spreadRadius: 0,
          ),
        ],
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
              // العنوان الرئيسي مع أيقونة أنيقة
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
                      border: Border.all(
                        color: const Color(0xFF00c1e8).withValues(alpha: 0.3),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF00c1e8).withValues(alpha: 0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
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
              // البطاقتان بتصميم زجاجي متناسق
              Row(
                children: [
                  // بطاقة القسائم
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        HapticFeedback.lightImpact();
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
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF7C4DFF).withValues(alpha: 0.15),
                              blurRadius: 12,
                              offset: const Offset(0, 6),
                              spreadRadius: 0,
                            ),
                            BoxShadow(
                              color: Colors.white.withValues(alpha: 0.7),
                              blurRadius: 4,
                              offset: const Offset(0, -2),
                              spreadRadius: 0,
                            ),
                          ],
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
                                border: Border.all(
                                  color: const Color(0xFF7C4DFF).withValues(alpha: 0.2),
                                  width: 1.5,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF7C4DFF).withValues(alpha: 0.1),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
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
                  // بطاقة المكافآت
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        HapticFeedback.lightImpact();
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
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF00c1e8).withValues(alpha: 0.15),
                              blurRadius: 12,
                              offset: const Offset(0, 6),
                              spreadRadius: 0,
                            ),
                            BoxShadow(
                              color: Colors.white.withValues(alpha: 0.7),
                              blurRadius: 4,
                              offset: const Offset(0, -2),
                              spreadRadius: 0,
                            ),
                          ],
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
                                border: Border.all(
                                  color: const Color(0xFF00c1e8).withValues(alpha: 0.2),
                                  width: 1.5,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF00c1e8).withValues(alpha: 0.1),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
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

// SearchScreen class
class SearchScreen extends StatefulWidget {
  final List<Store> stores;
  final Set<String> favoriteStoreIds;
  final Function(String) onToggleStoreFavorite;

  const SearchScreen({
    super.key,
    required this.stores,
    required this.favoriteStoreIds,
    required this.onToggleStoreFavorite,
  });

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  List<SearchResult> _searchResults = [];
  bool _isSearching = false;
  bool _isLoadingResults = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  Timer? _debounceTimer;

  // قائمة الكلمات الشائعة للبحث السريع (سيتم تحديثها من الباك إند)
  List<String> _popularSearches = [
    'برجر',
    'بيتزا',
    'دجاج مقلي',
    'سوشي',
    'شاورما',
    'مشروبات',
    'حلويات',
    'مأكولات بحرية',
    'إفطار',
    'قهوة',
  ];

  // قائمة البحث الحديث
  final List<String> _recentSearches = [];

  @override
  void initState() {
    super.initState();
    _searchFocusNode.requestFocus();
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _animationController.forward();
    
    // تحميل البحث الشائع من الباك إند
    _loadPopularSearches();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _animationController.dispose();
    _debounceTimer?.cancel();
    searchService.dispose();
    super.dispose();
  }

  // تحميل البحث الشائع من الباك إند
  Future<void> _loadPopularSearches() async {
    try {
      final popularSearches = await searchService.getPopularSearches();
      if (mounted) {
        setState(() {
          _popularSearches = popularSearches;
        });
      }
    } catch (e) {
      print('خطأ في تحميل البحث الشائع: $e');
    }
  }

  // البحث مع debouncing وتحسينات الأداء
  void _performSearch(String query) {
    // إلغاء البحث السابق
    _debounceTimer?.cancel();
    
    setState(() {
      _isSearching = query.isNotEmpty;
      
      if (query.isEmpty) {
        _searchResults = [];
        _isLoadingResults = false;
        return;
      }
      
      _isLoadingResults = true;
    });

    // البحث المحلي الفوري (للتجربة السلسة)
    _performLocalSearch(query);
    
    // البحث المتقدم مع debouncing
    _debounceTimer = Timer(const Duration(milliseconds: 500), () async {
      await _performAdvancedSearch(query);
    });
  }

  // البحث المحلي الفوري
  void _performLocalSearch(String query) {
    // إضافة البحث إلى القائمة الحديثة
    if (!_recentSearches.contains(query)) {
      _recentSearches.insert(0, query);
      if (_recentSearches.length > 10) {
        _recentSearches.removeLast();
      }
    }

    // البحث المحلي المحسّن باستخدام البحث المختلط
    searchService.searchMixed(
      query,
      localStores: widget.stores,
      limit: 10,
    ).then((results) {
      if (mounted && _searchController.text == query) {
        setState(() {
          _searchResults = results;
        });
      }
    });
  }  // البحث المتقدم من الباك إند
  Future<void> _performAdvancedSearch(String query) async {
    try {
      // البحث المختلط من الباك إند مع معلومات إضافية
      final backendResults = await searchService.searchMixed(
        query,
        localStores: widget.stores,
        // يمكن إضافة المزيد من المعاملات حسب الحاجة
        // category: selectedCategory,
        // latitude: currentLatitude,
        // longitude: currentLongitude,
      );

      if (mounted) {
        setState(() {
          // دمج النتائج وإزالة المكررات
          final combinedResults = <SearchResult>[];
          final seenIds = <String>{};
          
          // إضافة النتائج المحلية أولاً
          for (final result in _searchResults) {
            if (!seenIds.contains(result.id)) {
              combinedResults.add(result);
              seenIds.add(result.id);
            }
          }
          
          // إضافة النتائج الجديدة من الباك إند
          for (final result in backendResults) {
            if (!seenIds.contains(result.id)) {
              combinedResults.add(result);
              seenIds.add(result.id);
            }
          }
          
          _searchResults = combinedResults;
          _isLoadingResults = false;
        });

        // تسجيل إحصائيات البحث
        searchService.logSearchEvent(query, _searchResults.length);
      }
    } catch (e) {
      print('خطأ في البحث المتقدم: $e');
      if (mounted) {
        setState(() {
          _isLoadingResults = false;
        });
      }
    }
  }



  void _onSearchTermSelected(String term) {
    _searchController.text = term;
    _performSearch(term);
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        body: SafeArea(
          bottom: true, // Respect bottom safe area
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: CustomScrollView(
              slivers: [
                // Fixed search header
                SliverToBoxAdapter(
                  child: _buildSearchHeader(),
                ),
                // Dynamic content that can scroll
                SliverFillRemaining(
                  hasScrollBody: true,
                  child: _isSearching 
                      ? _buildSearchResults() 
                      : _buildSearchSuggestions(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back, color: Colors.black87),
            style: IconButton.styleFrom(
              backgroundColor: Colors.grey[100],
              padding: const EdgeInsets.all(12),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.orange.withOpacity(0.1),
                    Colors.deepOrange.withOpacity(0.1),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(25),
                border: Border.all(
                  color: Colors.orange.withOpacity(0.3),
                  width: 1.5,
                ),
              ),
              child: TextField(
                controller: _searchController,
                focusNode: _searchFocusNode,
                onChanged: _performSearch,
                textInputAction: TextInputAction.search,
                onSubmitted: _performSearch,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
                decoration: InputDecoration(
                  hintText: 'ابحث عن مطعم أو نوع طعام...',
                  hintStyle: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 16,
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: Colors.orange[700],
                    size: 24,
                  ),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          onPressed: () {
                            _searchController.clear();
                            _performSearch('');
                          },
                          icon: Icon(
                            Icons.clear,
                            color: Colors.grey[600],
                          ),
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    if (_isLoadingResults && _searchResults.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
            ),
            SizedBox(height: 16),
            Text(
              'جاري البحث...',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    if (_searchResults.isEmpty) {
      return _buildEmptyResults();
    }

    return CustomScrollView(
      slivers: [
        // عداد النتائج وفلتر النوع
        SliverToBoxAdapter(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.orange[50],
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.orange[200]!),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.store,
                        size: 16,
                        color: Colors.orange[700],
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'المتاجر (${_searchResults.length})',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.orange[700],
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                if (_searchResults.isNotEmpty)
                  Text(
                    'اضغط على أي متجر لعرض التفاصيل',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
              ],
            ),
          ),
        ),
        
        // مؤشر التحميل أثناء البحث المتقدم
        if (_isLoadingResults)
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.orange[50],
                borderRadius: BorderRadius.circular(8),
              ),
              margin: const EdgeInsets.all(16),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.orange[700]!),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'البحث عن نتائج إضافية...',
                    style: TextStyle(
                      color: Colors.orange[700],
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        
        // النتائج
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final result = _searchResults[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _buildSearchResultCard(result),
              );
            },
            childCount: _searchResults.length,
          ),
        ),
        
        // Add some bottom padding for the last item
        const SliverToBoxAdapter(
          child: SizedBox(height: 20),
        ),
      ],
    );
  }

  Widget _buildSearchResultCard(SearchResult result) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => _handleResultTap(result),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // صورة النتيجة
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    image: DecorationImage(
                      image: AssetImage(result.imageUrl),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                
                // معلومات النتيجة
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          // أيقونة نوع النتيجة
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: result.type == SearchResultType.store 
                                  ? Colors.blue[50] 
                                  : Colors.green[50],
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Icon(
                              result.type == SearchResultType.store 
                                  ? Icons.store 
                                  : Icons.restaurant_menu,
                              size: 12,
                              color: result.type == SearchResultType.store 
                                  ? Colors.blue[700] 
                                  : Colors.green[700],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              result.title,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          // مؤشر قابلية النقر
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.orange[50],
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Icon(
                              Icons.arrow_forward_ios,
                              size: 12,
                              color: Colors.orange[700],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        result.subtitle,
                        style: TextStyle(
                          color: result.type == SearchResultType.store 
                              ? Colors.orange[700] 
                              : Colors.green[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (result.type == SearchResultType.store && result.store != null) ...[
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              Icons.star,
                              color: Colors.amber[600],
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              result.store!.rating,
                              style: const TextStyle(fontSize: 14),
                            ),
                            const SizedBox(width: 16),
                            Icon(
                              Icons.access_time,
                              color: Colors.grey[600],
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              result.store!.time,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                
                // أيقونة المفضلة (للمتاجر فقط)
                if (result.type == SearchResultType.store && result.store != null)
                  IconButton(
                    onPressed: () => widget.onToggleStoreFavorite(result.store!.id),
                    icon: Icon(
                      widget.favoriteStoreIds.contains(result.store!.id) 
                          ? Icons.favorite 
                          : Icons.favorite_border,
                      color: widget.favoriteStoreIds.contains(result.store!.id) 
                          ? Colors.red 
                          : Colors.grey,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleResultTap(SearchResult result) {
    if (result.type == SearchResultType.store && result.store != null) {
      // التنقل إلى صفحة تفاصيل المتجر
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => StoreDetailScreen(
            store: result.store!,
            favoriteStoreIds: widget.favoriteStoreIds,
            onFavoriteToggle: (isFavorite) {
              widget.onToggleStoreFavorite(result.store!.id);
            },
          ),
        ),
      );
    } else if (result.type == SearchResultType.dish && result.dish != null) {
      // التنقل إلى صفحة تفاصيل الطبق
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DishDetailScreen(
            dish: result.dish!,
            storeId: result.storeId!,
            isInitiallyFav: false,
          ),
        ),
      );
    } else if (result.type == SearchResultType.product && result.product != null) {
      // عرض snackbar للمنتج (للسوبرماركت)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('منتج: ${result.product!.name} - ${result.product!.finalPrice.toStringAsFixed(2)} ر.س'),
          backgroundColor: Colors.blue,
          duration: const Duration(seconds: 2),
          action: SnackBarAction(
            label: 'عرض التفاصيل',
            textColor: Colors.white,
            onPressed: () {
              // يمكن إضافة صفحة تفاصيل المنتج هنا لاحقاً
            },
          ),
        ),
      );
    } else if (result.type == SearchResultType.offer && result.offer != null) {
      // عرض تفاصيل العرض في dialog
      _showOfferDialog(result.offer!);
    } else if (result.type == SearchResultType.category) {
      // البحث عن جميع المتاجر في هذه الفئة
      final categoryName = result.title;
      final filteredStores = widget.stores.where((store) => 
        store.category?.toLowerCase() == categoryName.toLowerCase()
      ).toList();
      
      if (filteredStores.isNotEmpty) {
        // عرض المتاجر في الفئة
        _searchController.text = categoryName;
        setState(() {
          _searchResults = filteredStores.map((store) => 
            SearchResult.fromStore(store)).toList();
        });
      }
    }
  }

  // عرض تفاصيل العرض في dialog
  void _showOfferDialog(Offer offer) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          offer.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (offer.imageUrl.isNotEmpty)
              Container(
                height: 120,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  image: DecorationImage(
                    image: NetworkImage(offer.imageUrl),
                    fit: BoxFit.cover,
                  ),
                ),
                margin: const EdgeInsets.only(bottom: 16),
              ),
            Text(
              offer.description,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.local_offer, color: Colors.orange[700]),
                  const SizedBox(width: 8),
                  Text(
                    offer.formattedDiscount,
                    style: TextStyle(
                      color: Colors.orange[700],
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            if (offer.minOrderAmount != null && offer.minOrderAmount! > 0) ...[
              const SizedBox(height: 8),
              Text(
                'حد أدنى للطلب: ${offer.minOrderAmount!.toStringAsFixed(2)} ر.س',
                style: const TextStyle(color: Colors.grey),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('إغلاق'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // البحث عن المتجر المرتبط بالعرض
              final store = widget.stores.firstWhere(
                (s) => s.id == offer.storeId,
                orElse: () => widget.stores.first,
              );
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => StoreDetailScreen(
                    store: store,
                    favoriteStoreIds: widget.favoriteStoreIds,
                    onFavoriteToggle: (isFavorite) {
                      widget.onToggleStoreFavorite(store.id);
                    },
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange[700],
              foregroundColor: Colors.white,
            ),
            child: const Text('عرض المتجر'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyResults() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.orange[50],
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.search_off,
                size: 64,
                color: Colors.orange[300],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'لم يتم العثور على نتائج',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'جرب البحث بكلمات مختلفة',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchSuggestions() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 20), // Add extra bottom padding
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // البحث الحديث
          if (_recentSearches.isNotEmpty) ...[
            _buildSectionHeader('البحث الحديث', Icons.history),
            const SizedBox(height: 12),
            ..._recentSearches.map((search) => _buildSearchItem(
              search,
              Icons.history,
              () => _onSearchTermSelected(search),
            )),
            const SizedBox(height: 24),
          ],
          
          // البحث الشائع
          _buildSectionHeader('البحث الشائع', Icons.trending_up),
          const SizedBox(height: 12),
          ..._popularSearches.map((search) => _buildSearchItem(
            search,
            Icons.trending_up,
            () => _onSearchTermSelected(search),
          )),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.orange[50],
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: Colors.orange[700],
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildSearchItem(String text, IconData icon, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: Colors.grey[600],
          size: 20,
        ),
        title: Text(
          text,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.black87,
          ),
        ),
        trailing: Icon(
          Icons.north_west,
          color: Colors.grey[400],
          size: 16,
        ),
        onTap: onTap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
