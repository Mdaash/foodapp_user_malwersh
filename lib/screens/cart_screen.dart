import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/cart_model.dart';
import '../models/store.dart';
import '../models/menu_item.dart';
import '../models/dish.dart';
import '../models/cart_item.dart';
import 'dish_detail_screen.dart';
import 'store_detail_screen.dart';
import 'order_confirmation_screen.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class CartScreen extends StatefulWidget {
  final String? storeName;
  final String? storeId;
  final List<Store>? stores; // قائمة المتاجر للبحث عن اسم المطعم
  
  // إعدادات السلة
  static const double minimumOrderAmount = 150.0; // الحد الأدنى بالريال السعودي
  static const double deliveryFee = 10.0; // رسوم التوصيل الثابتة
  
  const CartScreen({super.key, this.storeName, this.storeId, this.stores});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {

  String? _resolveStoreName() {
    if (widget.storeName != null && widget.storeName!.isNotEmpty) return widget.storeName;
    if (widget.storeId != null && widget.stores != null) {
      final found = widget.stores!.firstWhere(
        (s) => s.id == widget.storeId,
        orElse: () => Store(
          id: '',
          name: 'المطعم',
          image: '',
          logoUrl: '',
          isOpen: true,
          fee: '',
          rating: '',
          reviews: '',
          distance: '',
          time: '',
          address: '',
          combos: const [],
          sandwiches: const [],
          drinks: const [],
          extras: const [],
          specialties: const [],
        ),
      );
      return found.name;
    }
    return 'عربة التسوق';
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFFAFAFA),
        body: Consumer<CartModel>(
          builder: (context, cart, child) {
            if (cart.items.isEmpty) {
              return _buildEmptyCart(context);
            }
            return _buildCartContent(context, cart);
          },
        ),
      ),
    );
  }

  // شاشة السلة الفارغة - تصميم جميل ومحسن
  Widget _buildEmptyCart(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          // هيدر مبسط
          Container(
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
                IconButton(
                  onPressed: () => _navigateBackToStore(context),
                  icon: const Icon(Icons.arrow_back_ios, color: Colors.black87, size: 20),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                const SizedBox(width: 12),
                const Text(
                  'سلة التسوق',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          // محتوى السلة الفارغة
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // تأثير السلة الفارغة مع أنيميشن
                  TweenAnimationBuilder(
                    duration: const Duration(milliseconds: 800),
                    tween: Tween<double>(begin: 0.0, end: 1.0),
                    builder: (context, double value, child) {
                      return Transform.scale(
                        scale: 0.8 + (0.2 * value),
                        child: Opacity(
                          opacity: value,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // دائرة خلفية بتدرج لوني
                              Container(
                                width: 160,
                                height: 160,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      const Color(0xFF00c1e8).withOpacity(0.1),
                                      const Color(0xFF00c1e8).withOpacity(0.05),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(80),
                                  border: Border.all(
                                    color: const Color(0xFF00c1e8).withOpacity(0.2),
                                    width: 2,
                                  ),
                                ),
                              ),
                              // أيقونة السلة الفارغة مع تأثير
                              Container(
                                width: 120,
                                height: 120,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(60),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF00c1e8).withOpacity(0.15),
                                      blurRadius: 20,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  Icons.shopping_cart_outlined,
                                  size: 60,
                                  color: const Color(0xFF00c1e8).withOpacity(0.7),
                                ),
                              ),
                              // نقاط متحركة للديكور
                              Positioned(
                                top: 20,
                                right: 20,
                                child: Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF00c1e8).withOpacity(0.4),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: 30,
                                left: 15,
                                child: Container(
                                  width: 12,
                                  height: 12,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF00c1e8).withOpacity(0.3),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 40,
                                left: 25,
                                child: Container(
                                  width: 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF00c1e8).withOpacity(0.5),
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 32),
                  // النصوص مع تأثير تدريجي
                  TweenAnimationBuilder(
                    duration: const Duration(milliseconds: 1000),
                    tween: Tween<double>(begin: 0.0, end: 1.0),
                    builder: (context, double value, child) {
                      return Transform.translate(
                        offset: Offset(0, 20 * (1 - value)),
                        child: Opacity(
                          opacity: value,
                          child: Column(
                            children: [
                              const Text(
                                'سلتك فارغة',
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.black87,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'أضف بعض الأطباق اللذيذة لتبدأ رحلتك',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[600],
                                  height: 1.4,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'اكتشف مئات الأطباق من مطاعمك المفضلة',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[500],
                                  height: 1.3,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 48),
                  // زر التصفح مع تصميم جديد
                  TweenAnimationBuilder(
                    duration: const Duration(milliseconds: 1200),
                    tween: Tween<double>(begin: 0.0, end: 1.0),
                    builder: (context, double value, child) {
                      return Transform.translate(
                        offset: Offset(0, 30 * (1 - value)),
                        child: Opacity(
                          opacity: value,
                          child: Container(
                            width: double.infinity,
                            margin: const EdgeInsets.symmetric(horizontal: 32),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  Color(0xFF00c1e8),
                                  Color(0xFF0099cc),
                                ],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF00c1e8).withOpacity(0.3),
                                  blurRadius: 12,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 18),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                elevation: 0,
                                shadowColor: Colors.transparent,
                              ),
                              onPressed: () => _navigateBackToStore(context),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.restaurant_menu,
                                    size: 22,
                                  ),
                                  SizedBox(width: 12),
                                  Text(
                                    'تصفح المطاعم',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 0.5,
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
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // محتوى السلة مع الأطباق - تصميم DoorDash
  Widget _buildCartContent(BuildContext context, CartModel cart) {
    return SafeArea(
      child: Column(
        children: [
          // هيدر مع اسم المطعم
          Container(
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
                IconButton(
                  onPressed: () => _navigateBackToStore(context),
                  icon: const Icon(Icons.arrow_back_ios, color: Colors.black87, size: 20),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'سلة التسوق',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      if (_resolveStoreName() != 'عربة التسوق')
                        Text(
                          _resolveStoreName() ?? '',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // قائمة الأطباق
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // عناصر السلة
                ...cart.items.map((item) => _buildCartItem(context, cart, item)),
                const SizedBox(height: 24),
                // قسم الاقتراحات من نفس المطعم
                _buildSuggestionsSection(context, cart),
                const SizedBox(height: 24),
                // زر إضافة المزيد من الأطباق
                _buildAddMoreDishesButton(context),
                const SizedBox(height: 24),
                // تفاصيل السلة
                _buildCartSummary(context, cart),
                const SizedBox(height: 100), // مساحة للزر السفلي
              ],
            ),
          ),
          // زر المتابعة المبسط
          _buildCheckoutButton(context, cart),
        ],
      ),
    );
  }

  // عنصر في السلة - تصميم DoorDash المبسط مع زر الحذف في الأعلى
  Widget _buildCartItem(BuildContext context, CartModel cart, dynamic item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          // الصف العلوي مع اسم الطبق وزر الحذف
          Row(
            children: [
              Expanded(
                child: Text(
                  item.dish.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              // زر حذف الطبق في الجهة اليسرى العليا
              GestureDetector(
                onTap: () => _showDeleteConfirmation(context, cart, item),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.withOpacity(0.3)),
                  ),
                  child: const Icon(
                    Icons.delete_outline,
                    color: Colors.red,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // الصف السفلي مع تفاصيل الطبق
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // صورة الطبق
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => DishDetailScreen(
                        dish: item.dish,
                        storeId: item.storeId,
                        isInitiallyFav: false,
                      ),
                    ),
                  );
                },
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.grey[100],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset(
                      item.dish.imageUrls.isNotEmpty
                          ? item.dish.imageUrls.first
                          : 'assets/images/food_placeholder.png',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[200],
                          child: Icon(
                            Icons.restaurant,
                            color: Colors.grey[400],
                            size: 24,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // تفاصيل الطبق
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // وصف مختصر أو سعر الوحدة
                    if (item.dish.description != null && item.dish.description.isNotEmpty)
                      Text(
                        item.dish.description,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                          height: 1.3,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    const SizedBox(height: 12),
                    // التحكم بالكمية والسعر
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // أدوات التحكم بالكمية
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.withOpacity(0.3)),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  if (item.quantity > 1) {
                                    cart.updateItemQuantity(item, item.quantity - 1);
                                  }
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  child: Icon(
                                    Icons.remove,
                                    color: Colors.grey[700],
                                    size: 18,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                child: Text(
                                  '${item.quantity}',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: () => cart.updateItemQuantity(item, item.quantity + 1),
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  child: const Icon(
                                    Icons.add,
                                    color: Color(0xFF00c1e8),
                                    size: 18,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // السعر الإجمالي للطبق
                        Text(
                          '${(item.unitPrice * item.quantity).toStringAsFixed(2)} ر.س',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // قسم الاقتراحات من نفس المطعم - محسن
  Widget _buildSuggestionsSection(BuildContext context, CartModel cart) {
    return Consumer<CartModel>(
      builder: (context, cart, child) {
        // الحصول على معرف المتجر من السلة الحالية
        final currentStoreId = cart.currentStoreId;
        if (currentStoreId == null) {
          // إذا لم يكن هناك متجر حالي في السلة، لا تظهر اقتراحات
          return const SizedBox.shrink();
        }
        
        // البحث عن المتجر الحالي في قائمة المتاجر
        List<MenuItem> suggestions = [];
        
        // إذا كانت قائمة المتاجر متوفرة، ابحث عن المتجر الحالي
        if (widget.stores != null) {
          final store = widget.stores!.firstWhere(
            (s) => s.id == currentStoreId,
            orElse: () => Store(
              id: '',
              name: '',
              image: '',
              logoUrl: '',
              isOpen: true,
              fee: '',
              rating: '',
              reviews: '',
              distance: '',
              time: '',
              address: '',
              combos: const [],
              sandwiches: const [],
              drinks: const [],
              extras: const [],
              specialties: const [],
            ),
          );
          
          // اجمع الأطباق الثانوية من المطعم (مشروبات، إضافات، مميزات)
          suggestions = [
            ...store.drinks,
            ...store.extras,
            ...store.specialties,
          ];
        }
        
        // إذا لم تتوفر اقتراحات من نفس المطعم، استخدم اقتراحات ثابتة
        if (suggestions.isEmpty) {
          // تحديد الاقتراحات الثابتة التي لم تُضاف بعد
          final List<Map<String, dynamic>> staticSuggestions = [
            {'name': 'بطاطس مقلية', 'image': 'assets/images/food_placeholder.png', 'price': 7.0},
            {'name': 'مشروب غازي', 'image': 'assets/images/food_placeholder.png', 'price': 5.0},
            {'name': 'سلطة طازجة', 'image': 'assets/images/food_placeholder.png', 'price': 6.0},
          ];
          
          // استبعد الاقتراحات الثابتة الموجودة في السلة
          final cartDishIds = cart.items.map((item) => item.dish.id).toSet();
          final availableStaticSuggestions = staticSuggestions.where((suggestion) {
            final suggestionId = 'suggestion_${suggestion['name'].toString().replaceAll(' ', '_')}';
            return !cartDishIds.contains(suggestionId);
          }).toList();
          
          // إذا لم تتبق اقتراحات، لا تظهر القسم
          if (availableStaticSuggestions.isEmpty) {
            return const SizedBox.shrink();
          }
          
          return Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.withOpacity(0.1)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF00c1e8).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Icon(
                        Icons.restaurant_menu,
                        color: Color(0xFF00c1e8),
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'قد يعجبك أيضاً',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: availableStaticSuggestions.map((suggestion) {
                      final index = availableStaticSuggestions.indexOf(suggestion);
                      return Padding(
                        padding: EdgeInsets.only(left: index < availableStaticSuggestions.length - 1 ? 12 : 0),
                        child: _buildSuggestionItem(
                          context, 
                          cart, 
                          suggestion['name'], 
                          suggestion['image'], 
                          suggestion['price']
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          );
        }
        
        // استبعد الأطباق الموجودة بالفعل في السلة
        final cartDishIds = cart.items.map((item) => item.dish.id).toSet();
        suggestions = suggestions.where((dish) => !cartDishIds.contains(dish.id)).toList();
        
        // خذ أقصى 6 اقتراحات
        if (suggestions.length > 6) {
          suggestions = suggestions.take(6).toList();
        }
        
        // إذا لم تتبق اقتراحات، لا تظهر القسم
        if (suggestions.isEmpty) {
          return const SizedBox.shrink();
        }
        
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.withOpacity(0.1)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF00c1e8).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Icon(
                      Icons.restaurant_menu,
                      color: Color(0xFF00c1e8),
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'قد يعجبك أيضاً',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        Text(
                          'من نفس المطعم',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: suggestions.map((suggestion) => Padding(
                    padding: const EdgeInsets.only(left: 12),
                    child: _buildSuggestionItem(
                      context,
                      cart,
                      suggestion.name,
                      suggestion.image,
                      suggestion.price,
                      dish: suggestion,
                    ),
                  )).toList(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // عنصر اقتراح محسن مع زر إضافة ديناميكي
  Widget _buildSuggestionItem(BuildContext context, CartModel cart, String name, String img, double price, {MenuItem? dish}) {
    final dishId = dish?.id ?? 'suggestion_${name.replaceAll(' ', '_')}';
    // التحقق من وجود العنصر في السلة
    final isInCart = cart.items.any((item) => item.dish.id == dishId);
    
    return Container(
      width: 140,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          // صورة الطبق
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.grey[200],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.asset(
                img,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[200],
                    child: Icon(
                      Icons.restaurant,
                      color: Colors.grey[400],
                      size: 30,
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 8),
          // اسم الطبق
          Text(
            name,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          // السعر
          Text(
            '${price.toStringAsFixed(2)} ر.س',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          // زر الإضافة
          GestureDetector(
            onTap: () {
              if (!isInCart) {
                if (dish != null) {
                  _addSuggestionToCart(context, cart, dish);
                } else {
                  _addStaticSuggestionToCart(context, cart, name, price, img);
                }
              }
            },
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: isInCart ? Colors.green : const Color(0xFF00c1e8),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: (isInCart ? Colors.green : const Color(0xFF00c1e8)).withOpacity(0.3),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                isInCart ? Icons.check : Icons.add,
                color: Colors.white,
                size: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // إضافة طبق من الاقتراحات للسلة
  void _addSuggestionToCart(BuildContext context, CartModel cart, MenuItem dish) {
    try {
      // تحويل MenuItem إلى Dish للتوافق مع CartItem
      final dishObj = Dish(
        id: dish.id,
        name: dish.name,
        imageUrls: [dish.image],
        description: dish.description,
        likesPercent: 85,
        likesCount: 120,
        basePrice: dish.price,
        optionGroups: [],
      );
      
      // إنشاء CartItem جديد
      final cartItem = CartItem(
        storeId: widget.storeId ?? cart.currentStoreId ?? '1',
        dish: dishObj,
        quantity: 1,
        unitPrice: dish.price,
        totalPrice: dish.price,
        selectedOptions: {},
      );
      
      // إضافة الطبق للسلة - سيتم تحديث الواجهة تلقائياً
      cart.addItem(cartItem);
      
      _showSnackBar(context, 'تم إضافة ${dish.name} للسلة', const Color(0xFF00c1e8));
    } catch (e) {
      _showSnackBar(context, 'حدث خطأ في إضافة الطبق', Colors.red);
    }
  }

  // إضافة اقتراح ثابت للسلة (للاقتراحات الثابتة)
  void _addStaticSuggestionToCart(BuildContext context, CartModel cart, String name, double price, String img) {
    try {
      // إنشاء طبق للاقتراح الثابت
      final dishObj = Dish(
        id: 'suggestion_${name.replaceAll(' ', '_')}',
        name: name,
        imageUrls: [img],
        description: 'اقتراح لذيذ',
        likesPercent: 85,
        likesCount: 120,
        basePrice: price,
        optionGroups: [],
      );
      
      // إنشاء CartItem جديد
      final cartItem = CartItem(
        storeId: widget.storeId ?? cart.currentStoreId ?? '1',
        dish: dishObj,
        quantity: 1,
        unitPrice: price,
        totalPrice: price,
        selectedOptions: {},
      );
      
      // إضافة الطبق للسلة - سيتم تحديث الواجهة تلقائياً
      cart.addItem(cartItem);
      
      _showSnackBar(context, 'تم إضافة $name للسلة', const Color(0xFF00c1e8));
    } catch (e) {
      _showSnackBar(context, 'حدث خطأ في إضافة الطبق', Colors.red);
    }
  }

  // زر إضافة المزيد من الأطباق
  Widget _buildAddMoreDishesButton(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFF00c1e8).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(
                  Icons.add_shopping_cart,
                  color: Color(0xFF00c1e8),
                  size: 16,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'تريد المزيد؟',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'استكشف المزيد من الأطباق اللذيذة من نفس المطعم',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00c1e8),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
              ),
              onPressed: () {
                // العودة لنفس المطعم
                _navigateBackToStore(context);
              },
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.restaurant_menu, size: 18),
                  SizedBox(width: 8),
                  Text(
                    'إضافة المزيد من الأطباق',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // تفاصيل السلة
  Widget _buildCartSummary(BuildContext context, CartModel cart) {
    final int totalDishes = cart.items.fold(0, (sum, item) => sum + item.quantity);
    final double subtotal = cart.totalAmount;
    final double delivery = CartScreen.deliveryFee;
    final double total = subtotal + delivery;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFF00c1e8).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(
                  Icons.receipt_long,
                  color: Color(0xFF00c1e8),
                  size: 16,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'تفاصيل السلة',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // عدد الأطباق
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'عدد الأطباق ($totalDishes)',
                style: const TextStyle(
                  fontSize: 15,
                  color: Colors.black87,
                ),
              ),
              Text(
                '${subtotal.toStringAsFixed(2)} ر.س',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // رسوم التوصيل
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'رسوم التوصيل',
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.black87,
                ),
              ),
              Text(
                '${delivery.toStringAsFixed(2)} ر.س',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1),
          ),
          // المجموع الكلي
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'المجموع الكلي',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              Text(
                '${total.toStringAsFixed(2)} ر.س',
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF00c1e8),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // زر المتابعة مع التحقق من الحد الأدنى
  Widget _buildCheckoutButton(BuildContext context, CartModel cart) {
    final double subtotal = cart.totalAmount;
    final double total = subtotal + CartScreen.deliveryFee;
    final bool isMinimumMet = subtotal >= CartScreen.minimumOrderAmount;
    final double remainingAmount = CartScreen.minimumOrderAmount - subtotal;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // تنبيه الحد الأدنى (إذا لم يتم الوصول إليه)
            if (!isMinimumMet)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.amber.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.amber.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.info_outline,
                        color: Colors.amber,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'الحد الأدنى للطلب',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.amber,
                            ),
                          ),
                          Text(
                            'أضف ${remainingAmount.toStringAsFixed(2)} ر.س إضافية للوصول للحد الأدنى (${CartScreen.minimumOrderAmount.toStringAsFixed(0)} ر.س)',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            // زر المتابعة
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: isMinimumMet 
                      ? const Color(0xFF00c1e8) 
                      : Colors.grey[400],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: isMinimumMet ? 2 : 0,
                ),
                onPressed: isMinimumMet ? () {
                  // التنقل لشاشة تأكيد الطلب
                  final int totalDishes = cart.items.fold(0, (sum, item) => sum + item.quantity);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => OrderConfirmationScreen(
                        address: 'بغداد، العراق',
                        city: 'بغداد',
                        area: 'الكرادة',
                        district: 'حي 123',
                        landmark: 'قرب الجامعة',
                        storeName: _resolveStoreName() ?? 'المطعم',
                        totalDishes: totalDishes,
                        subtotal: subtotal,
                        delivery: CartScreen.deliveryFee,
                        total: total,
                        mapAddress: 'بغداد، الكرادة، حي 123',
                        userLocation: const LatLng(33.3152, 44.3661), // إحداثيات بغداد
                      ),
                    ),
                  );
                } : () {
                  _showSnackBar(
                    context,
                    'الحد الأدنى للطلب ${CartScreen.minimumOrderAmount.toStringAsFixed(0)} ر.س. أضف ${remainingAmount.toStringAsFixed(2)} ر.س إضافية.',
                    Colors.amber,
                  );
                },
                child: Text(
                  isMinimumMet 
                      ? 'متابعة الطلب • ${total.toStringAsFixed(2)} ر.س'
                      : 'أضف ${remainingAmount.toStringAsFixed(2)} ر.س للمتابعة',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // عرض رسالة Snackbar
  void _showSnackBar(BuildContext context, String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // العودة لنفس المطعم أو الشاشة الرئيسية
  void _navigateBackToStore(BuildContext context) {
    final cart = Provider.of<CartModel>(context, listen: false);
    final currentStoreId = cart.currentStoreId;
    
    if (currentStoreId != null && widget.stores != null) {
      // البحث عن المطعم الحالي
      final store = widget.stores!.firstWhere(
        (s) => s.id == currentStoreId,
        orElse: () => widget.stores!.first,
      );
      
      // العودة للشاشة السابقة ثم الانتقال لشاشة المطعم
      Navigator.pop(context);
      
      // الانتقال لشاشة تفاصيل المطعم باستخدام pushReplacement
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => StoreDetailScreen(
            store: store,
            favoriteStoreIds: const <String>{}, // يمكن تمرير المفضلة الحقيقية هنا
            onFavoriteToggle: (bool isFavorite) {}, // دالة فارغة مؤقتة
          ),
        ),
      );
    } else {
      // العودة للشاشة السابقة إذا لم نجد معلومات المطعم
      Navigator.pop(context);
    }
  }

  // عرض رسالة تأكيد الحذف
  void _showDeleteConfirmation(BuildContext context, CartModel cart, dynamic item) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // مؤشر السحب
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 24),
                // أيقونة التحذير
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(40),
                  ),
                  child: const Icon(
                    Icons.delete_outline,
                    size: 40,
                    color: Colors.red,
                  ),
                ),
                const SizedBox(height: 20),
                // عنوان التأكيد
                const Text(
                  'حذف الطبق',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),
                // رسالة التأكيد
                Text(
                  'هل أنت متأكد من حذف "${item.dish.name}" من السلة؟',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 32),
                // أزرار التأكيد والإلغاء
                Row(
                  children: [
                    // زر الإلغاء
                    Expanded(
                      child: TextButton(
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.grey[100],
                          foregroundColor: Colors.grey[700],
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () => Navigator.pop(context),
                        child: const Text(
                          'إلغاء',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // زر التأكيد
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        onPressed: () {
                          // حذف الطبق من السلة
                          cart.removeItem(item);
                          // إغلاق النافذة
                          Navigator.pop(context);
                          // عرض رسالة تأكيد الحذف
                          _showSnackBar(
                            context, 
                            'تم حذف ${item.dish.name} من السلة', 
                            Colors.red,
                          );
                        },
                        child: const Text(
                          'حذف',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                // مساحة آمنة في الأسفل
                SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
              ],
            ),
          ),
        );
      },
    );
  }
}
