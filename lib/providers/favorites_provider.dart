// lib/providers/favorites_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/favorites_model.dart';

// مزود المفضلة باستخدام Riverpod
final favoritesProvider = ChangeNotifierProvider<FavoritesModel>((ref) {
  return FavoritesModel();
});

// مزود لفحص ما إذا كان المتجر مفضلاً
final isStoreFavoriteProvider = Provider.family<bool, String>((ref, storeId) {
  final favorites = ref.watch(favoritesProvider);
  return favorites.isStoreFavorite(storeId);
});

// مزود لفحص ما إذا كان الطبق مفضلاً
final isDishFavoriteProvider = Provider.family<bool, String>((ref, dishId) {
  final favorites = ref.watch(favoritesProvider);
  return favorites.isDishFavorite(dishId);
});

// مزود لفحص ما إذا كان العرض مفضلاً
final isOfferFavoriteProvider = Provider.family<bool, String>((ref, offerId) {
  final favorites = ref.watch(favoritesProvider);
  return favorites.isOfferFavorite(offerId);
});

// مزود لعدد المفضلة الإجمالي
final favoritesCountProvider = Provider<int>((ref) {
  final favorites = ref.watch(favoritesProvider);
  return favorites.totalFavoritesCount;
});

// مزود لمعرفات المتاجر المفضلة
final favoriteStoreIdsProvider = Provider<Set<String>>((ref) {
  final favorites = ref.watch(favoritesProvider);
  return favorites.favoriteStoreIds;
});

// مزود لمعرفات الأطباق المفضلة
final favoriteDishIdsProvider = Provider<Set<String>>((ref) {
  final favorites = ref.watch(favoritesProvider);
  return favorites.favoriteDishIds;
});

// مزود لمعرفات العروض المفضلة
final favoriteOfferIdsProvider = Provider<Set<String>>((ref) {
  final favorites = ref.watch(favoritesProvider);
  return favorites.favoriteOfferIds;
});
