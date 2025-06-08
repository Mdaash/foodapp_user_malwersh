// lib/screens/enhanced_search_screen_updated.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../models/store.dart';
import '../models/favorites_model.dart';
import '../services/search_service.dart';
import '../models/search_result.dart';
import 'store_detail_screen_updated.dart';
import 'dish_detail_screen.dart';

class EnhancedSearchScreenUpdated extends StatefulWidget {
  final List<Store> stores;
  final String? initialQuery;

  const EnhancedSearchScreenUpdated({
    super.key,
    required this.stores,
    this.initialQuery,
  });

  @override
  State<EnhancedSearchScreenUpdated> createState() => _EnhancedSearchScreenUpdatedState();
}

class _EnhancedSearchScreenUpdatedState extends State<EnhancedSearchScreenUpdated> with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  List<SearchResult> _searchResults = [];
  bool _isSearching = false;
  bool _isLoadingResults = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  Timer? _debounceTimer;

  // قائمة الكلمات الشائعة للبحث السريع
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
    
    if (widget.initialQuery != null && widget.initialQuery!.isNotEmpty) {
      _searchController.text = widget.initialQuery!;
      _performSearch(widget.initialQuery!);
    }
    
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
    _loadPopularSearches();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _animationController.dispose();
    _debounceTimer?.cancel();
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
      debugPrint('خطأ في تحميل البحث الشائع: $e');
    }
  }

  // البحث مع debouncing وتحسينات الأداء
  void _onSearchChanged(String query) {
    _debounceTimer?.cancel();
    
    if (query.trim().isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
        _isLoadingResults = false;
      });
      return;
    }

    setState(() {
      _isSearching = true;
      _isLoadingResults = true;
    });

    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      _performSearch(query.trim());
    });
  }

  // تنفيذ البحث
  Future<void> _performSearch(String query) async {
    if (!mounted) return;

    try {
      final results = await searchService.searchMixed(
        query,
        localStores: widget.stores,
      );

      if (mounted) {
        setState(() {
          _searchResults = results;
          _isLoadingResults = false;
        });

        // إضافة إلى البحث الحديث
        if (!_recentSearches.contains(query)) {
          _recentSearches.insert(0, query);
          if (_recentSearches.length > 10) {
            _recentSearches.removeLast();
          }
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingResults = false;
        });
        debugPrint('خطأ في البحث: $e');
      }
    }
  }

  // تنفيذ البحث المباشر
  void _executeSearch(String query) {
    _searchController.text = query;
    _searchFocusNode.unfocus();
    _performSearch(query);
    setState(() {
      _isSearching = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              children: [
                // شريط البحث العلوي
                _buildSearchHeader(),
                
                // المحتوى الرئيسي
                Expanded(
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

  // بناء شريط البحث العلوي
  Widget _buildSearchHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
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
          // زر الرجوع
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.grey),
            onPressed: () => Navigator.pop(context),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
          ),
          const SizedBox(width: 8),
          
          // حقل البحث
          Expanded(
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Row(
                children: [
                  const SizedBox(width: 16),
                  Icon(Icons.search, color: Colors.grey[600], size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      focusNode: _searchFocusNode,
                      onChanged: _onSearchChanged,
                      decoration: const InputDecoration(
                        hintText: 'ابحث عن متجر أو طبق...',
                        hintStyle: TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                      ),
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                  if (_searchController.text.isNotEmpty)
                    IconButton(
                      icon: Icon(Icons.clear, color: Colors.grey[600], size: 18),
                      onPressed: () {
                        _searchController.clear();
                        setState(() {
                          _isSearching = false;
                          _searchResults = [];
                        });
                      },
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                    ),
                  const SizedBox(width: 8),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // بناء اقتراحات البحث (قبل البحث)
  Widget _buildSearchSuggestions() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // البحث الحديث
          if (_recentSearches.isNotEmpty) ...[
            const Text(
              'البحث الحديث',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            ...(_recentSearches.take(5).map((search) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              child: InkWell(
                onTap: () => _executeSearch(search),
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
                  child: Row(
                    children: [
                      Icon(Icons.history, color: Colors.grey[600], size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          search,
                          style: const TextStyle(fontSize: 15),
                        ),
                      ),
                      Icon(Icons.north_west, color: Colors.grey[400], size: 16),
                    ],
                  ),
                ),
              ),
            ))),
            const SizedBox(height: 24),
          ],

          // البحث الشائع
          const Text(
            'البحث الشائع',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _popularSearches.map((search) => ActionChip(
              label: Text(
                search,
                style: const TextStyle(fontSize: 13),
              ),
              onPressed: () => _executeSearch(search),
              backgroundColor: Colors.grey[100],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(color: Colors.grey[300]!),
              ),
            )).toList(),
          ),
        ],
      ),
    );
  }

  // بناء نتائج البحث
  Widget _buildSearchResults() {
    if (_isLoadingResults) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00C1E8)),
            ),
            SizedBox(height: 16),
            Text(
              'جارٍ البحث...',
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
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'لا توجد نتائج للبحث',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'جرب البحث بكلمات مختلفة',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final result = _searchResults[index];
        return _buildSearchResultItem(result);
      },
    );
  }

  // بناء عنصر نتيجة البحث
  Widget _buildSearchResultItem(SearchResult result) {
    switch (result.type) {
      case SearchResultType.store:
        return _buildStoreResult(result);
      case SearchResultType.dish:
        return _buildDishResult(result);
      case SearchResultType.offer:
        return _buildOfferResult(result);
      default:
        return const SizedBox.shrink();
    }
  }

  // بناء نتيجة متجر
  Widget _buildStoreResult(SearchResult result) {
    final store = result.store!;
    
    return Consumer<FavoritesModel>(
      builder: (context, favoritesModel, child) {
        final isFavorite = favoritesModel.isStoreFavorite(store.id);
        
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: InkWell(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => StoreDetailScreenUpdated(
                  store: store,
                ),
              ),
            ),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  // صورة المتجر
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset(
                      store.image,
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 60,
                          height: 60,
                          color: Colors.grey[300],
                          child: const Icon(Icons.store, color: Colors.grey),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  
                  // معلومات المتجر
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
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            // زر المفضلة
                            IconButton(
                              icon: Icon(
                                isFavorite ? Icons.favorite : Icons.favorite_border,
                                color: isFavorite ? Colors.red : Colors.grey,
                              ),
                              onPressed: () {
                                if (isFavorite) {
                                  favoritesModel.removeStoreFavorite(store.id);
                                } else {
                                  favoritesModel.addStoreFavorite(store.id);
                                }
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.star, color: Colors.amber, size: 16),
                            const SizedBox(width: 4),
                            Text(
                              store.rating.toString(),
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Icon(Icons.access_time, color: Colors.grey, size: 16),
                            const SizedBox(width: 4),
                            Text(
                              '\${store.deliveryTime} دقيقة',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          store.category ?? 'No category',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // بناء نتيجة طبق
  Widget _buildDishResult(SearchResult result) {
    final dish = result.dish!;
    final store = result.store!;
    
    return Consumer<FavoritesModel>(
      builder: (context, favoritesModel, child) {
        final isFavorite = favoritesModel.isDishFavorite(dish.id);
        
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: InkWell(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DishDetailScreen(
                  dish: dish,
                  storeId: store.id,
                ),
              ),
            ),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  // صورة الطبق
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: dish.imageUrls.isNotEmpty
                        ? Image.asset(
                            dish.imageUrls.first,
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: 60,
                                height: 60,
                                color: Colors.grey[300],
                                child: const Icon(Icons.restaurant, color: Colors.grey),
                              );
                            },
                          )
                        : Container(
                            width: 60,
                            height: 60,
                            color: Colors.grey[300],
                            child: const Icon(Icons.restaurant, color: Colors.grey),
                          ),
                  ),
                  const SizedBox(width: 12),
                  
                  // معلومات الطبق
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                dish.name,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            // زر المفضلة
                            IconButton(
                              icon: Icon(
                                isFavorite ? Icons.favorite : Icons.favorite_border,
                                color: isFavorite ? Colors.red : Colors.grey,
                              ),
                              onPressed: () {
                                if (isFavorite) {
                                  favoritesModel.removeDishFavorite(dish.id);
                                } else {
                                  favoritesModel.addDishFavorite(dish.id);
                                }
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'من \${store.name}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '\${dish.basePrice.toStringAsFixed(2)} ر.س',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF00C1E8),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // بناء نتيجة عرض
  Widget _buildOfferResult(SearchResult result) {
    final offer = result.offer!;
    final store = result.store!;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => StoreDetailScreenUpdated(
              store: store,
            ),
          ),
        ),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // أيقونة العرض
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.local_offer,
                  color: Colors.red,
                  size: 30,
                ),
              ),
              const SizedBox(width: 12),
              
              // معلومات العرض
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      offer.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'من \${store.name}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      offer.description,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
