import 'package:flutter/material.dart';
import '../models/store.dart';

class FavoritesScreen extends StatefulWidget {
  final List<Store> stores;
  final Set<String> favoriteStoreIds;
  final Set<String> favoriteDishIds;
  final void Function(String storeId) onToggleStoreFavorite;
  final void Function(String dishId) onToggleDishFavorite;
  final VoidCallback? onBack;

  const FavoritesScreen({
    super.key,
    required this.stores,
    required this.favoriteStoreIds,
    required this.favoriteDishIds,
    required this.onToggleStoreFavorite,
    required this.onToggleDishFavorite,
    this.onBack,
  });

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Widget _buildFavoriteStores() {
    final favStores = widget.stores.where((s) => widget.favoriteStoreIds.contains(s.id)).toList();
    if (favStores.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.favorite_border, size: 80, color: Colors.grey),
            const SizedBox(height: 16),
            const Text('لا يوجد متاجر مفضلة بعد', 
              style: TextStyle(fontSize: 18, color: Colors.grey, fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            const Text('ابدأ بإضافة متاجرك المفضلة من الصفحة الرئيسية', 
              style: TextStyle(fontSize: 14, color: Colors.grey)),
          ],
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: favStores.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, i) {
        final s = favStores[i];
        return ListTile(
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset(s.image, width: 48, height: 48, fit: BoxFit.cover),
          ),
          title: Text(s.name),
          subtitle: Text('⭐ ${s.rating} • ${s.time}'),
          trailing: IconButton(
            icon: const Icon(Icons.favorite, color: Color(0xFF00c1e8)),
            onPressed: () => widget.onToggleStoreFavorite(s.id),
          ),
          onTap: () {
            // يمكنك فتح تفاصيل المتجر هنا
          },
        );
      },
    );
  }

  Widget _buildFavoriteDishes() {
    final favDishes = widget.stores.expand((store) => [
      ...store.combos,
      ...store.sandwiches,
      ...store.drinks,
      ...store.extras,
      ...store.specialties,
    ]).where((item) => widget.favoriteDishIds.contains(item.id)).toList();
    if (favDishes.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.restaurant_menu, size: 80, color: Colors.grey),
            const SizedBox(height: 16),
            const Text('لا يوجد أطباق مفضلة بعد', 
              style: TextStyle(fontSize: 18, color: Colors.grey, fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            const Text('ابدأ بإضافة أطباقك المفضلة من تفاصيل المتاجر', 
              style: TextStyle(fontSize: 14, color: Colors.grey)),
          ],
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: favDishes.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, i) {
        final item = favDishes[i];
        return ListTile(
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset(item.image, width: 48, height: 48, fit: BoxFit.cover),
          ),
          title: Text(item.name),
          subtitle: Text('${item.price.toStringAsFixed(2)} ر.س'),
          trailing: IconButton(
            icon: const Icon(Icons.favorite, color: Color(0xFF00c1e8)),
            onPressed: () => widget.onToggleDishFavorite(item.id),
          ),
          onTap: () {
            // يمكنك فتح تفاصيل الطبق هنا
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Column(
          children: [
            // عنوان الشاشة مع التبويبات
            Container(
              color: Colors.white,
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  const Text('المفضلة', 
                    style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18)),
                  const SizedBox(height: 16),
                  TabBar(
                    controller: _tabController,
                    labelColor: const Color(0xFF00c1e8),
                    unselectedLabelColor: Colors.grey,
                    indicatorColor: const Color(0xFF00c1e8),
                    tabs: const [
                      Tab(text: 'المتاجر'),
                      Tab(text: 'الأطباق'),
                    ],
                  ),
                ],
              ),
            ),
            // المحتوى
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildFavoriteStores(),
                  _buildFavoriteDishes(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
