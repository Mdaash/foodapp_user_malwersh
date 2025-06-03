import 'package:flutter/material.dart';
import 'package:foodapp_user/models/menu_item.dart';
import 'package:foodapp_user/models/store.dart';
import 'package:foodapp_user/models/dish.dart';
import 'package:foodapp_user/screens/dish_detail_screen.dart';
import 'package:foodapp_user/widgets/animated_cart_bar.dart';
import 'package:provider/provider.dart';
import 'package:foodapp_user/models/cart_model.dart';

class StoreDetailScreen extends StatefulWidget {
  final Store store;
  final Set<String> favoriteStoreIds;
  final ValueChanged<bool> onFavoriteToggle;

  const StoreDetailScreen({
    super.key,
    required this.store,
    required this.favoriteStoreIds,
    required this.onFavoriteToggle,
  });

  @override
  State<StoreDetailScreen> createState() => _StoreDetailScreenState();
}

class _StoreDetailScreenState extends State<StoreDetailScreen>
    with SingleTickerProviderStateMixin {
  late bool _isFav;
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

  Set<String> favoriteDishIds = {};

  @override
  void initState() {
    super.initState();
    _isFav = widget.favoriteStoreIds.contains(widget.store.id);
    _tabController = TabController(length: _sections.length, vsync: this);
    for (final title in _sections.keys) {
      _keys[title] = GlobalKey();
    }
    _scrollCtrl.addListener(() {
      _handleScrollTabSync();
      _updateCollapsedState();
    });
  }

  void _updateCollapsedState() {
    final isCollapsed = _scrollCtrl.hasClients && _scrollCtrl.offset > 200;
    if (isCollapsed != _collapsed) {
      setState(() {
        _collapsed = isCollapsed;
      });
    }
  }

  void _handleScrollTabSync() {
    for (int i = 0; i < _sections.length; i++) {
      final key = _keys[_sections.keys.elementAt(i)];
      if (key?.currentContext != null) {
        final box = key!.currentContext!.findRenderObject() as RenderBox;
        final position = box.localToGlobal(Offset.zero, ancestor: null).dy;
        if (position >= 0 && position < 200) {
          if (_tabController.index != i) {
            _tabController.animateTo(i);
          }
          break;
        }
      }
    }
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _toggleFav() {
    setState(() => _isFav = !_isFav);
    widget.onFavoriteToggle(_isFav);
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
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء')),
          ]),
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
        body: NestedScrollView(
          controller: _scrollCtrl,
          headerSliverBuilder: (context, _) => [
            _buildSliverAppBar(),
            _buildStoreInfo(),
            _buildTabs(),
          ],
          body: ListView(
            padding: EdgeInsets.zero,
            children: _sections.keys.map((title) => _buildSection(title)).toList(),
          ),
        ),
        // شريط التنقل السفلي ثابت
        bottomNavigationBar: Container(
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
            currentIndex: 0,
            onTap: (i) {
              // إعادة السلوك السابق: pop مع إرجاع رقم التبويب
              Navigator.pop(context, i);
            },
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home), label: 'الرئيسية'),
              BottomNavigationBarItem(icon: Icon(Icons.favorite_border), label: 'المفضلة'),
              BottomNavigationBarItem(icon: Icon(Icons.receipt_long), label: 'طلبات'),
              BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'حسابي'),
            ],
          ),
        ),
        // السلة العائمة مع تباعد من الأسفل
        floatingActionButton: Consumer<CartModel>(
          builder: (context, cart, _) {
            if (cart.items.isEmpty || cart.currentStoreId != widget.store.id) {
              return const SizedBox.shrink();
            }
            return Padding(
              padding: const EdgeInsets.only(bottom: 15),
              child: AnimatedCartBar(
                storeName: widget.store.name,
                isExpanded: true,
              ),
            );
          },
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      ),
    );
  }

  // SliverAppBar كما في التصميم السابق:
  Widget _buildSliverAppBar() => SliverAppBar(
        pinned: true,
        expandedHeight: 300,
        backgroundColor: _collapsed ? _primaryPink : Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8),
          child: CircleAvatar(
            backgroundColor: Colors.white70,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.black),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: CircleAvatar(
              backgroundColor: Colors.white70,
              child: IconButton(
                icon: Icon(_isFav ? Icons.favorite : Icons.favorite_border, color: _primaryPink),
                onPressed: _toggleFav,
              ),
            ),
          ),
        ],
        flexibleSpace: LayoutBuilder(
          builder: (context, constraints) {
            // حساب نسبة التمرير (0 = مفتوح، 1 = مغلق)
            final double t = ((constraints.maxHeight - kToolbarHeight) / (300 - kToolbarHeight)).clamp(0.0, 1.0);
            return FlexibleSpaceBar(
              collapseMode: CollapseMode.parallax,
              titlePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              title: Text(
                'أهلاً بكم في ${widget.store.name}',
                style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Opacity(
                    opacity: t,
                    child: Image.asset(
                      widget.store.image.isNotEmpty ? widget.store.image : 'assets/images/food_placeholder.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.transparent, Colors.black26],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      );

  Widget _buildStoreInfo() => SliverToBoxAdapter(
        child: Column(children: [
          Container(
            color: _collapsed ? _primaryPink : Colors.transparent,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // اسم المطعم والعنوان (يمين)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.store.name,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: _collapsed ? Colors.white : Colors.black,
                        ),
                      ),
                      if (widget.store.address.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 2.0, bottom: 2.0),
                          child: Text(
                            widget.store.address,
                            style: TextStyle(
                              fontSize: 14,
                              color: _collapsed ? Colors.white70 : Colors.grey[700],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                    ],
                  ),
                ),
                // رسوم التوصيل (يسار)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      (widget.store.fee == '0' || widget.store.fee == '0.0' || widget.store.fee == '0ر.س' || widget.store.fee == 'مجاني')
                        ? 'التوصيل مجاني'
                        : 'رسوم التوصيل: ${widget.store.fee}',
                      style: TextStyle(
                        fontSize: 13,
                        color: _collapsed ? Colors.white70 : Colors.grey[700],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            color: _collapsed ? _primaryPink : Colors.transparent,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(children: [
              Icon(Icons.star,
                  color: _collapsed ? Colors.white : Colors.amber, size: 20),
              const SizedBox(width: 4),
              Text(widget.store.rating,
                  style:
                      TextStyle(color: _collapsed ? Colors.white : Colors.grey)),
              const SizedBox(width: 16),
              Icon(Icons.location_on,
                  color: _collapsed ? Colors.white : Colors.grey, size: 20),
              const SizedBox(width: 4),
              Text(widget.store.distance,
                  style:
                      TextStyle(color: _collapsed ? Colors.white : Colors.grey)),
              const SizedBox(width: 16),
              GestureDetector(
                onTap: _chooseDeliveryTime,
                child: Row(children: [
                  Icon(Icons.schedule,
                      color: _collapsed ? Colors.white : Colors.grey, size: 20),
                  const SizedBox(width: 4),
                  Text(_deliveryTime,
                      style:
                          TextStyle(color: _collapsed ? Colors.white : Colors.grey)),
                  Icon(Icons.keyboard_arrow_down,
                      color: _collapsed ? Colors.white : Colors.grey),
                ]),
              ),
            ]),
          ),
        ]),
      );

  Widget _buildTabs() => SliverPersistentHeader(
        pinned: true,
        delegate: _SliverTabBarDelegate(
          TabBar(
            controller: _tabController,
            isScrollable: true,
            labelColor: _collapsed ? Colors.white : Colors.black87,
            unselectedLabelColor: _collapsed ? Colors.white70 : Colors.grey,
            indicatorColor: _collapsed ? Colors.white : _primaryPink,
            indicatorWeight: 3,
            tabs: _sections.keys.map((t) => Tab(text: t)).toList(),
            onTap: (i) => animateToSection(i),
          ),
          backgroundColor: _collapsed ? _primaryPink : Colors.transparent,
        ),
      );

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

  Widget _buildSection(String title) {
    final items = _sections[title]!;
    return Container(
      key: _keys[title],
      margin: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          const Divider(color: Colors.grey, thickness: 1),
          ...items.map((item) {
            final isFav = favoriteDishIds.contains(item.id);
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.name,
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text('${item.price.toStringAsFixed(2)} ر.س',
                          style: const TextStyle(color: Colors.grey)),
                    ],
                  ),
                ),
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.asset(item.image, width: 80, height: 80, fit: BoxFit.cover),
                    ),
                    Positioned(
                      top: 4,
                      left: 4,
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            if (isFav) {
                              favoriteDishIds.remove(item.id);
                            } else {
                              favoriteDishIds.add(item.id);
                            }
                          });
                        },
                        child: Container(
                          width: 28,
                          height: 28,
                          decoration: const BoxDecoration(
                            color: Color(0xFFF0F0F0),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            isFav ? Icons.favorite : Icons.favorite_border,
                            color: _primaryPink,
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
                  decoration: BoxDecoration(color: Colors.grey[200], shape: BoxShape.circle),
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
                      final fav = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => DishDetailScreen(
                            dish: dish,
                            storeId: widget.store.id,
                            isInitiallyFav: isFav,
                          ),
                        ),
                      );
                      setState(() {
                        if (fav == true) {
                          favoriteDishIds.add(item.id);
                        } else if (fav == false) {
                          favoriteDishIds.remove(item.id);
                        }
                      });
                    },
                  ),
                ),
              ]),
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
