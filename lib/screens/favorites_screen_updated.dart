import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/store.dart';
import '../models/favorites_model.dart';
import 'store_detail_screen_updated.dart';

class FavoritesScreenUpdated extends StatefulWidget {
  final List<Store> stores;

  const FavoritesScreenUpdated({
    super.key,
    required this.stores,
  });

  @override
  State<FavoritesScreenUpdated> createState() => _FavoritesScreenUpdatedState();
}

class _FavoritesScreenUpdatedState extends State<FavoritesScreenUpdated> 
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
              preferredSize: Size.fromHeight(
                kToolbarHeight + MediaQuery.of(context).padding.top + 4
              ),
              child: Container(
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top + 4,
                  left: 16,
                  right: 16,
                ),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  border: Border(
                    bottom: BorderSide(
                      color: Color(0xFF00c1e8),
                      width: 1.5,
                    ),
                  ),
                ),
                child: AppBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  centerTitle: true,
                  title: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.favorite,
                        color: Color(0xFF00c1e8),
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'المفضلة',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                      if (favorites.totalFavoritesCount > 0) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF00c1e8),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${favorites.totalFavoritesCount}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  iconTheme: const IconThemeData(color: Colors.black),
                  automaticallyImplyLeading: false,
                  actions: [
                    if (favorites.totalFavoritesCount > 0)
                      PopupMenuButton<String>(
                        icon: const Icon(
                          Icons.more_vert,
                          color: Color(0xFF00c1e8),
                        ),
                        onSelected: (value) {
                          if (value == 'clear_all') {
                            _showClearAllDialog(context, favorites);
                          } else if (value == 'export') {
                            _exportFavorites(favorites);
                          }
                        },
                        itemBuilder: (BuildContext context) => [
                          const PopupMenuItem<String>(
                            value: 'export',
                            child: Row(
                              children: [
                                Icon(Icons.ios_share, color: Color(0xFF00c1e8)),
                                SizedBox(width: 8),
                                Text('تصدير المفضلة'),
                              ],
                            ),
                          ),
                          const PopupMenuItem<String>(
                            value: 'clear_all',
                            child: Row(
                              children: [
                                Icon(Icons.clear_all, color: Colors.red),
                                SizedBox(width: 8),
                                Text('مسح الكل'),
                              ],
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
            body: Column(
              children: [
                // إحصائيات سريعة
                if (favorites.totalFavoritesCount > 0)
                  Container(
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF00c1e8).withValues(alpha: 0.1),
                          const Color(0xFF00c1e8).withValues(alpha: 0.05),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFF00c1e8).withValues(alpha: 0.3),
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            'المتاجر',
                            favorites.favoriteStoreIds.length.toString(),
                            Icons.store,
                            const Color(0xFF00c1e8),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStatCard(
                            'الأطباق',
                            favorites.favoriteDishIds.length.toString(),
                            Icons.restaurant_menu,
                            const Color(0xFF7C4DFF),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStatCard(
                            'العروض',
                            favorites.favoriteOfferIds.length.toString(),
                            Icons.local_offer,
                            const Color(0xFFFF6B35),
                          ),
                        ),
                      ],
                    ),
                  ),

                // التبويبات
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TabBar(
                    controller: _tabController,
                    labelColor: const Color(0xFF00c1e8),
                    unselectedLabelColor: Colors.grey,
                    indicatorColor: const Color(0xFF00c1e8),
                    indicatorWeight: 3,
                    labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                    tabs: [
                      Tab(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.store, size: 18),
                            const SizedBox(width: 4),
                            Text('المتاجر (${favorites.favoriteStoreIds.length})'),
                          ],
                        ),
                      ),
                      Tab(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.restaurant_menu, size: 18),
                            const SizedBox(width: 4),
                            Text('الأطباق (${favorites.favoriteDishIds.length})'),
                          ],
                        ),
                      ),
                      Tab(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.local_offer, size: 18),
                            const SizedBox(width: 4),
                            Text('العروض (${favorites.favoriteOfferIds.length})'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // المحتوى
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildFavoriteStores(favorites),
                      _buildFavoriteDishes(favorites),
                      _buildFavoriteOffers(favorites),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatCard(String title, String count, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 4),
          Text(
            count,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFavoriteStores(FavoritesModel favorites) {
    final favoriteStoreIds = favorites.favoriteStoreIds;
    final favStores = widget.stores
        .where((s) => favoriteStoreIds.contains(s.id))
        .toList();

    if (favStores.isEmpty) {
      return _buildEmptyState(
        icon: Icons.store,
        title: 'لا يوجد متاجر مفضلة بعد',
        subtitle: 'ابدأ بإضافة متاجرك المفضلة من الصفحة الرئيسية',
        color: const Color(0xFF00c1e8),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: favStores.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, i) {
        final store = favStores[i];
        return _buildStoreCard(store, favorites);
      },
    );
  }

  Widget _buildStoreCard(Store store, FavoritesModel favorites) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => StoreDetailScreenUpdated(store: store),
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
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withValues(alpha: 0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(
                      store.image,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 16),

                // تفاصيل المتجر
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
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      if (store.category != null)
                        Text(
                          store.category!,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.star, color: Colors.amber, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            store.rating,
                            style: const TextStyle(fontSize: 14),
                          ),
                          const SizedBox(width: 16),
                          Icon(Icons.access_time, color: Colors.grey[600], size: 16),
                          const SizedBox(width: 4),
                          Text(
                            store.time,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // زر إزالة من المفضلة
                Container(
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: IconButton(
                    icon: const Icon(
                      Icons.favorite,
                      color: Colors.red,
                      size: 20,
                    ),
                    onPressed: () {
                      favorites.toggleStoreFavorite(store.id);
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFavoriteDishes(FavoritesModel favorites) {
    final favoriteDishIds = favorites.favoriteDishIds;
    
    // جمع جميع الأطباق من جميع المتاجر
    final allDishes = widget.stores.expand((store) => [
      ...store.combos,
      ...store.sandwiches,
      ...store.drinks,
      ...store.extras,
      ...store.specialties,
    ]).where((dish) => favoriteDishIds.contains(dish.id)).toList();

    if (allDishes.isEmpty) {
      return _buildEmptyState(
        icon: Icons.restaurant_menu,
        title: 'لا يوجد أطباق مفضلة بعد',
        subtitle: 'ابدأ بإضافة أطباقك المفضلة من تفاصيل المتاجر',
        color: const Color(0xFF7C4DFF),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: allDishes.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, i) {
        final dish = allDishes[i];
        return _buildDishCard(dish, favorites);
      },
    );
  }

  Widget _buildDishCard(dynamic dish, FavoritesModel favorites) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            // يمكن إضافة التنقل إلى تفاصيل الطبق هنا
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // صورة الطبق
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withValues(alpha: 0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(
                      dish.image,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 16),

                // تفاصيل الطبق
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        dish.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      if (dish.description != null)
                        Text(
                          dish.description!,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      const SizedBox(height: 8),
                      Text(
                        '${dish.price.toStringAsFixed(2)} ر.س',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF00c1e8),
                        ),
                      ),
                    ],
                  ),
                ),

                // زر إزالة من المفضلة
                Container(
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: IconButton(
                    icon: const Icon(
                      Icons.favorite,
                      color: Colors.red,
                      size: 20,
                    ),
                    onPressed: () {
                      favorites.toggleDishFavorite(dish.id);
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFavoriteOffers(FavoritesModel favorites) {
    final favoriteOfferIds = favorites.favoriteOfferIds;
    
    if (favoriteOfferIds.isEmpty) {
      return _buildEmptyState(
        icon: Icons.local_offer,
        title: 'لا يوجد عروض مفضلة بعد',
        subtitle: 'ابدأ بإضافة عروضك المفضلة',
        color: const Color(0xFFFF6B35),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: favoriteOfferIds.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, i) {
        final offerId = favoriteOfferIds.elementAt(i);
        return _buildOfferCard(offerId, favorites);
      },
    );
  }

  Widget _buildOfferCard(String offerId, FavoritesModel favorites) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            // يمكن إضافة التنقل إلى تفاصيل العرض هنا
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // أيقونة العرض
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFFFF6B35).withValues(alpha: 0.2),
                        const Color(0xFFFF6B35).withValues(alpha: 0.1),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.local_offer,
                    color: Color(0xFFFF6B35),
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),

                // تفاصيل العرض
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'عرض خاص #$offerId',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'وصف العرض الخاص',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF6B35).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'عرض نشط',
                          style: TextStyle(
                            color: Color(0xFFFF6B35),
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // زر إزالة من المفضلة
                Container(
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: IconButton(
                    icon: const Icon(
                      Icons.favorite,
                      color: Colors.red,
                      size: 20,
                    ),
                    onPressed: () {
                      favorites.toggleOfferFavorite(offerId);
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 64,
                color: color.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _showClearAllDialog(BuildContext context, FavoritesModel favorites) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('مسح جميع المفضلة'),
          content: const Text(
            'هل أنت متأكد من أنك تريد مسح جميع العناصر المفضلة؟ لا يمكن التراجع عن هذا الإجراء.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('إلغاء'),
            ),
            TextButton(
              onPressed: () {
                favorites.clearAllFavorites();
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('تم مسح جميع المفضلة بنجاح'),
                    backgroundColor: Colors.red,
                  ),
                );
              },
              child: const Text(
                'مسح الكل',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  void _exportFavorites(FavoritesModel favorites) {
    final stats = favorites.getFavoritesStats();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('تم تصدير ${stats['totalCount']} عنصر مفضل'),
        backgroundColor: const Color(0xFF00c1e8),
      ),
    );
  }
}
