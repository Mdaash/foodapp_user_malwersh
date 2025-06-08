import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/menu_item.dart';
import '../models/store.dart';
import '../models/dish.dart';
import '../models/favorites_model.dart';
import '../models/cart_model.dart';
import 'dish_detail_screen.dart';

class StoreDetailScreenUpdated extends StatefulWidget {
  final Store store;

  const StoreDetailScreenUpdated({
    super.key,
    required this.store,
  });

  @override
  State<StoreDetailScreenUpdated> createState() => _StoreDetailScreenUpdatedState();
}

class _StoreDetailScreenUpdatedState extends State<StoreDetailScreenUpdated>
    with SingleTickerProviderStateMixin {
  final String _deliveryTime = '٢٣ دقيقة';
  late final TabController _tabController;
  final ScrollController _scrollCtrl = ScrollController();
  bool _collapsed = false;
  static const _primaryPink = Color(0xFF00c1e8);

  final Map<String, List<MenuItem>> _sections = {
    'عناصر مميزة':  List.generate(5,  (i) => MenuItem.placeholder(i)),
    'الأكثر طلباً': List.generate(4,  (i) => MenuItem.placeholder(i + 5)),
    'سندويشات':     List.generate(4,  (i) => MenuItem.placeholder(i + 9)),
    'مشروبات':      List.generate(4,  (i) => MenuItem.placeholder(i + 13)),
    'الإضافات':     List.generate(4,  (i) => MenuItem.placeholder(i + 17)),
  };
  final Map<String, GlobalKey> _keys = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _sections.length, vsync: this);
    for (final sectionName in _sections.keys) {
      _keys[sectionName] = GlobalKey();
    }
    _scrollCtrl.addListener(() {
      final isCollapsed = _scrollCtrl.hasClients && _scrollCtrl.offset > (200 - kToolbarHeight);
      if (isCollapsed != _collapsed) {
        setState(() => _collapsed = isCollapsed);
      }
    });
    
    // تبديل الشاشة عند النقر على tab
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        final index = _tabController.index;
        if (index >= 0 && index < _sections.length) {
          animateToSection(index);
        }
      }
    });
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _chooseDeliveryTime() {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Text(
              'وقت التوصيل',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ListTile(
              title: Text('$_deliveryTime (افتراضي)'),
              onTap: () => Navigator.pop(context),
            ),
            const ListTile(
              title: Text('اختيار وقت آخر'),
              onTap: null,
            ),
          ]),
        ),
      ),
    );
  }

  void animateToSection(int i) {
    final key = _keys[_sections.keys.elementAt(i)];
    final ctx = key?.currentContext;
    if (ctx != null) {
      Scrollable.ensureVisible(
        ctx,
        duration: const Duration(milliseconds: 350),
        alignment: 0.1,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Consumer2<FavoritesModel, CartModel>(
        builder: (context, favorites, cart, child) {
          final isFavorite = favorites.isStoreFavorite(widget.store.id);
          
          return Scaffold(
            backgroundColor: Colors.white,
            body: NestedScrollView(
              controller: _scrollCtrl,
              headerSliverBuilder: (context, innerBoxIsScrolled) => [
                SliverAppBar(
                  expandedHeight: 240,
                  pinned: true,
                  backgroundColor: _primaryPink,
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  actions: [
                    Consumer<CartModel>(
                      builder: (context, cart, _) => Stack(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.shopping_cart, color: Colors.white),
                            onPressed: () {
                              // فتح صفحة العربة
                            },
                          ),
                          if (cart.items.isNotEmpty)
                            Positioned(
                              right: 8,
                              top: 8,
                              child: Container(
                                padding: const EdgeInsets.all(2),
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                constraints: const BoxConstraints(
                                  minWidth: 16,
                                  minHeight: 16,
                                ),
                                child: Text(
                                  '${cart.items.length}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                  flexibleSpace: FlexibleSpaceBar(
                    background: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.asset(
                          widget.store.image,
                          fit: BoxFit.cover,
                        ),
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withValues(alpha: 0.7),
                              ],
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 16,
                          left: 16,
                          right: 16,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      widget.store.name,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: IconButton(
                                      icon: Icon(
                                        isFavorite ? Icons.favorite : Icons.favorite_border,
                                        color: isFavorite ? Colors.red : Colors.white,
                                        size: 24,
                                      ),
                                      onPressed: () {
                                        favorites.toggleStoreFavorite(widget.store.id);
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(Icons.star, color: Colors.amber, size: 16),
                                  const SizedBox(width: 4),
                                  Text(
                                    widget.store.rating,
                                    style: const TextStyle(color: Colors.white, fontSize: 14),
                                  ),
                                  const SizedBox(width: 16),
                                  Icon(Icons.access_time, color: Colors.white, size: 16),
                                  const SizedBox(width: 4),
                                  Text(
                                    widget.store.time,
                                    style: const TextStyle(color: Colors.white, fontSize: 14),
                                  ),
                                  const Spacer(),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: widget.store.isOpen ? Colors.green : Colors.red,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      widget.store.isOpen ? 'مفتوح' : 'مغلق',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
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
                ),
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _SliverTabBarDelegate(
                    TabBar(
                      controller: _tabController,
                      isScrollable: true,
                      labelColor: _primaryPink,
                      unselectedLabelColor: Colors.grey,
                      indicatorColor: _primaryPink,
                      tabs: _sections.keys.map((name) => Tab(text: name)).toList(),
                    ),
                    backgroundColor: Colors.white,
                  ),
                ),
              ],
              body: Column(
                children: [
                  // معلومات التوصيل
                  Container(
                    padding: const EdgeInsets.all(16),
                    color: Colors.white,
                    child: Row(
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Icon(Icons.delivery_dining, color: _primaryPink),
                              const SizedBox(width: 8),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'التوصيل',
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    _deliveryTime,
                                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        TextButton(
                          onPressed: _chooseDeliveryTime,
                          child: const Text('تغيير', style: TextStyle(color: _primaryPink)),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  
                  // قائمة الأقسام
                  Expanded(
                    child: ListView(
                      children: _sections.keys.map((title) => _buildSection(title, favorites)).toList(),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSection(String title, FavoritesModel favorites) {
    final items = _sections[title]!;
    return Container(
      key: _keys[title],
      margin: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(height: 4),
          const Divider(color: Colors.grey, thickness: 1),
          ...items.map((item) {
            final isFav = favorites.isDishFavorite(item.id);
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            item.description,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${item.price.toStringAsFixed(2)} ر.س',
                            style: const TextStyle(
                              color: _primaryPink,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.asset(
                            item.image,
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          top: 4,
                          left: 4,
                          child: GestureDetector(
                            onTap: () {
                              favorites.toggleDishFavorite(item.id);
                            },
                            child: Container(
                              width: 28,
                              height: 28,
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
                                isFav ? Icons.favorite : Icons.favorite_border,
                                color: isFav ? Colors.red : _primaryPink,
                                size: 18,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: _primaryPink.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        splashRadius: 20,
                        icon: const Icon(Icons.add, color: _primaryPink),
                        onPressed: () async {
                          final dish = Dish(
                            id: item.id,
                            name: item.name,
                            description: item.description,
                            imageUrls: [item.image],
                            likesPercent: item.likesPercent,
                            likesCount: item.likesCount,
                            basePrice: item.price,
                            optionGroups: [],
                          );
                          
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => DishDetailScreen(
                                dish: dish,
                                storeId: widget.store.id,
                                isInitiallyFav: isFav,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;
  final Color backgroundColor;

  _SliverTabBarDelegate(this.tabBar, {required this.backgroundColor});

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(color: backgroundColor, child: tabBar);
  }

  @override
  double get maxExtent => tabBar.preferredSize.height;
  @override
  double get minExtent => tabBar.preferredSize.height;
  @override
  bool shouldRebuild(covariant _SliverTabBarDelegate old) {
    return old.tabBar != tabBar || old.backgroundColor != backgroundColor;
  }
}
