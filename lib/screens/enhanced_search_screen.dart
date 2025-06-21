// lib/screens/enhanced_search_screen.dart

import 'package:flutter/material.dart';
import 'dart:async';
import '../models/store.dart';
import '../models/offer.dart';
import '../services/search_service.dart';
import '../models/search_result.dart';
import '../widgets/cached_image.dart';
import 'store_detail_screen.dart';
import 'dish_detail_screen.dart';

class EnhancedSearchScreen extends StatefulWidget {
  final List<Store> stores;
  final Set<String> favoriteStoreIds;
  final Function(String) onToggleStoreFavorite;

  const EnhancedSearchScreen({
    super.key,
    required this.stores,
    required this.favoriteStoreIds,
    required this.onToggleStoreFavorite,
  });

  @override
  State<EnhancedSearchScreen> createState() => _EnhancedSearchScreenState();
}

class _EnhancedSearchScreenState extends State<EnhancedSearchScreen> with TickerProviderStateMixin {
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

  // تم إزالة فلاتر البحث لتبسيط التجربة
  
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

    // البحث الشامل باستخدام searchUniversal
    searchService.searchUniversal(
      query,
      localStores: widget.stores,
      searchTypes: SearchResultType.values, // استخدام جميع الأنواع
      limit: 20,
    ).then((results) {
      if (mounted && _searchController.text == query) {
        setState(() {
          _searchResults = results;
        });
      }
    });
  }

  // البحث المتقدم من الباك إند
  Future<void> _performAdvancedSearch(String query) async {
    try {
      // البحث الشامل من الباك إند مع معلومات إضافية
      final backendResults = await searchService.searchUniversal(
        query,
        localStores: widget.stores,
        searchTypes: SearchResultType.values, // استخدام جميع الأنواع
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
      debugPrint('خطأ في البحث المتقدم: $e');
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
          bottom: true, // Ensure bottom safe area is respected
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
            color: Colors.black.withValues(alpha: 0.05),
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
                    const Color(0xFF00c1e8).withValues(alpha: 0.1),
                    const Color(0xFF0099d4).withValues(alpha: 0.1),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(25),
                border: Border.all(
                  color: const Color(0xFF00c1e8).withValues(alpha: 0.3),
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
                  hintText: 'ابحث في المتاجر، الأطباق، المنتجات والعروض...',
                  hintStyle: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 16,
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: const Color(0xFF00c1e8),
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
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00c1e8)),
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
                  color: Colors.black.withValues(alpha: 0.05),
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
                    color: const Color(0xFF00c1e8).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFF00c1e8).withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.search,
                        size: 16,
                        color: const Color(0xFF00c1e8),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'النتائج (${_searchResults.length})',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF00c1e8),
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                if (_isLoadingResults)
                  Row(
                    children: [
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(const Color(0xFF00c1e8)),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'يبحث...',
                        style: TextStyle(
                          color: const Color(0xFF00c1e8),
                          fontSize: 12,
                        ),
                      ),
                    ],
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
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
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
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
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
                              color: _getTypeColor(result.type),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Icon(
                              _getTypeIcon(result.type),
                              size: 12,
                              color: _getTypeIconColor(result.type),
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
                              color: const Color(0xFF00c1e8).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Icon(
                              Icons.arrow_forward_ios,
                              size: 12,
                              color: const Color(0xFF00c1e8),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        result.subtitle,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
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
              CachedImage(
                imageUrl: offer.imageUrl,
                height: 120,
                width: double.infinity,
                borderRadius: BorderRadius.circular(12),
              ),
            Text(
              offer.description,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF00c1e8).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.local_offer, color: const Color(0xFF00c1e8)),
                  const SizedBox(width: 8),
                  Text(
                    offer.formattedDiscount,
                    style: TextStyle(
                      color: const Color(0xFF00c1e8),
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
              backgroundColor: const Color(0xFF00c1e8),
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
                color: const Color(0xFF00c1e8).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.search_off,
                size: 64,
                color: const Color(0xFF00c1e8).withValues(alpha: 0.7),
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
              'جرب البحث بكلمات مختلفة أو تغيير الفلاتر',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
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
            color: const Color(0xFF00c1e8).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: const Color(0xFF00c1e8),
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
        border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
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

  IconData _getTypeIcon(SearchResultType type) {
    switch (type) {
      case SearchResultType.store:
        return Icons.store;
      case SearchResultType.dish:
        return Icons.restaurant_menu;
      case SearchResultType.offer:
        return Icons.local_offer;
      case SearchResultType.product:
        return Icons.shopping_cart;
      case SearchResultType.category:
        return Icons.category;
      case SearchResultType.coupon:
        return Icons.confirmation_number;
      case SearchResultType.combo:
        return Icons.set_meal;
    }
  }

  Color _getTypeColor(SearchResultType type) {
    switch (type) {
      case SearchResultType.store:
        return Colors.blue[50]!;
      case SearchResultType.dish:
        return Colors.green[50]!;
      case SearchResultType.offer:
        return const Color(0xFF00c1e8).withValues(alpha: 0.1);
      case SearchResultType.product:
        return Colors.purple[50]!;
      case SearchResultType.category:
        return Colors.teal[50]!;
      case SearchResultType.coupon:
        return Colors.red[50]!;
      case SearchResultType.combo:
        return Colors.indigo[50]!;
    }
  }

  Color _getTypeIconColor(SearchResultType type) {
    switch (type) {
      case SearchResultType.store:
        return Colors.blue[700]!;
      case SearchResultType.dish:
        return Colors.green[700]!;
      case SearchResultType.offer:
        return const Color(0xFF00c1e8);
      case SearchResultType.product:
        return Colors.purple[700]!;
      case SearchResultType.category:
        return Colors.teal[700]!;
      case SearchResultType.coupon:
        return Colors.red[700]!;
      case SearchResultType.combo:
        return Colors.indigo[700]!;
    }
  }
}
