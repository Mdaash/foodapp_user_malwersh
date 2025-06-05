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
import 'package:foodapp_user/screens/coupons_screen.dart';
import 'package:foodapp_user/screens/rewards_screen.dart';
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
            color: Colors.white.withValues(alpha: 0.8),
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
