import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/cart_model.dart';
import '../models/store.dart';
import '../models/menu_item.dart';
import 'dish_detail_screen.dart'; // تأكد من استيراد شاشة تفاصيل الطبق
import 'order_confirmation_screen.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class CartScreen extends StatelessWidget {
  final String? storeName;
  final String? storeId;
  final List<Store>? stores; // قائمة المتاجر للبحث عن اسم المطعم
  const CartScreen({super.key, this.storeName, this.storeId, this.stores});

  String? _resolveStoreName() {
    if (storeName != null && storeName!.isNotEmpty) return storeName;
    if (storeId != null && stores != null) {
      final found = stores!.firstWhere(
        (s) => s.id == storeId,
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
    // Debug: CartScreen build called
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        extendBodyBehindAppBar: true,
        backgroundColor: const Color(0xFFF8F9FA),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          ),
          title: Text(
            _resolveStoreName() ?? 'عربة التسوق',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          centerTitle: true,
        ),
        body: Consumer<CartModel>(
          builder: (context, cart, child) {
            // Debug: CartScreen Consumer builder called. cart.items.length = ${cart.items.length}
            if (cart.items.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/images/empty_cart.png',
                      width: 120,
                      height: 120,
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'عربتك فارغة',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'ابدأ بإضافة بعض الأطباق اللذيذة!',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00c1e8),
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        'تصفح المطاعم',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                  ],
                ),
              );
            }
            // قائمة السلة + قسم الاقتراحات + ملخص السعر
            return Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      // عناصر السلة
                      ...List.generate(cart.items.length, (index) {
                        final item = cart.items[index];
                        return _buildCartItem(context, cart, item);
                      }),
                      const SizedBox(height: 24),
                      // قسم الاقتراحات
                      _buildSuggestionsSection(),
                    ],
                  ),
                ),
                _buildSummarySection(context, cart),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildCartItem(BuildContext context, CartModel cart, dynamic item) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
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
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.asset(
                item.dish.imageUrls.isNotEmpty
                    ? item.dish.imageUrls.first
                    : 'assets/images/food_placeholder.png',
                width: 56,
                height: 56,
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 10),
          // Expanded للنصوص
          Expanded(
            child: GestureDetector(
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.dish.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 6),
                      // سعر الوحدة
                      Text(
                        '${item.unitPrice.toStringAsFixed(2)} ر.س/وحدة',
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.grey,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  if (item.dish.description != null && item.dish.description.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 2.0),
                      child: Text(
                        item.dish.description,
                        style: const TextStyle(fontSize: 13, color: Colors.grey),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline, color: Colors.grey, size: 22),
                        onPressed: () {
                          if (item.quantity > 1) {
                            cart.updateItemQuantity(item, item.quantity - 1);
                          } else {
                            cart.removeItem(item);
                          }
                        },
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${item.quantity}',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add_circle_outline, color: Color(0xFF00c1e8), size: 22),
                        onPressed: () => cart.updateItemQuantity(item, item.quantity + 1),
                      ),
                      const Spacer(),
                      // السعر الإجمالي لهذا الطبق
                      Text(
                        '${(item.unitPrice * item.quantity).toStringAsFixed(2)} ر.س',
                        style: const TextStyle(
                          fontSize: 15,
                          color: Color(0xFF00c1e8),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.red, size: 22),
                        onPressed: () => cart.removeItem(item),
                        tooltip: 'حذف',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // قسم الاقتراحات (ديناميكي)
  Widget _buildSuggestionsSection() {
    // ابحث عن أطباق المطعم الحالي
    List<MenuItem> suggestions = [];
    if (storeId != null && stores != null) {
      final store = stores!.firstWhere(
        (s) => s.id == storeId,
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
      // اجمع كل الأطباق من جميع الأقسام
      suggestions = [
        ...store.combos,
        ...store.sandwiches,
        ...store.drinks,
        ...store.extras,
        ...store.specialties,
      ];
      // استبعد الأطباق الموجودة بالفعل في السلة
      // (يفترض أن cart متاح عبر Provider في الأعلى)
      // إذا لم تتوفر اقتراحات، استخدم اقتراحات ثابتة
    }
    if (suggestions.isEmpty) {
      // fallback ثابت
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('قد يعجبك أيضًا', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildSuggestionItem('بطاطس', 'assets/fried-chicken.png', 7.0),
              const SizedBox(width: 12),
              _buildSuggestionItem('مشروب', 'assets/drink.png', 5.0),
              const SizedBox(width: 12),
              _buildSuggestionItem('سلطة', 'assets/salad.png', 6.0),
            ],
          ),
        ],
      );
    }
    // عرض اقتراحات ديناميكية (حتى 3)
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('قد يعجبك أيضًا', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Row(
          children: List.generate(3, (i) {
            if (i >= suggestions.length) return const SizedBox();
            final m = suggestions[i];
            return Expanded(
              child: _buildSuggestionItem(m.name, m.image, m.price),
            );
          }).where((w) => w is! SizedBox).toList(),
        ),
      ],
    );
  }

  Widget _buildSuggestionItem(String name, String img, double price) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.08),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(img, width: 56, height: 56, fit: BoxFit.cover),
            ),
            const SizedBox(height: 8),
            Text(name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
            const SizedBox(height: 4),
            Text('${price.toStringAsFixed(2)} ر.س', style: const TextStyle(fontSize: 13, color: Colors.grey)),
            const SizedBox(height: 4),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF00c1e8),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(Icons.add, color: Colors.white, size: 20),
            ),
          ],
        ),
      ),
    );
  }

  // ملخص السعر بأسفل الشاشة
  Widget _buildSummarySection(BuildContext context, CartModel cart) {
    final int totalDishes = cart.items.fold(0, (sum, item) => sum + item.quantity);
    final double subtotal = cart.totalAmount;
    final double delivery = 10.0; // ثابت مؤقتًا
    final double total = subtotal + delivery;
    final String storeName = _resolveStoreName() ?? 'المطعم';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE0E0E0))),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('عدد الأطباق: $totalDishes', style: const TextStyle(fontSize: 15)),
                Text('${subtotal.toStringAsFixed(2)} ر.س', style: const TextStyle(fontSize: 15)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('سعر التوصيل', style: TextStyle(fontSize: 15)),
                Text('${delivery.toStringAsFixed(2)} ر.س', style: const TextStyle(fontSize: 15)),
              ],
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('السعر الكلي', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Text('${total.toStringAsFixed(2)} ر.س', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF00c1e8))),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00c1e8),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => OrderConfirmationScreen(
                        address: 'بغداد، العراق',
                        city: 'بغداد',
                        area: 'الكرادة',
                        district: 'حي 123',
                        landmark: 'قرب الجامعة',
                        storeName: storeName,
                        totalDishes: totalDishes,
                        subtotal: subtotal,
                        delivery: delivery,
                        total: total,
                        mapAddress: 'بغداد، الكرادة، حي 123، قرب الجامعة',
                        userLocation: const LatLng(33.3152, 44.3661), // بغداد
                      ),
                    ),
                  );
                },
                child: Text(
                  'متابعة الطلب • ${total.toStringAsFixed(2)} ر.س',
                  style: const TextStyle(
                    color: Colors.white,
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
}
