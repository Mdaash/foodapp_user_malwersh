// lib/screens/dish_detail_screen.dart

import 'dart:ui' as ui;
// lib/screens/dish_detail_screen.dart
// lib/screens/dish_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/dish.dart';
import '../models/cart_item.dart';
import '../models/cart_model.dart';
import '../widgets/modern_cart_icon.dart';
import 'cart_screen.dart';

class DishDetailScreen extends StatefulWidget {
  final Dish dish;
  final String storeId;
  final bool isInitiallyFav;

  const DishDetailScreen({
    super.key,
    required this.dish,
    required this.storeId,
    this.isInitiallyFav = false,
  });

  @override
  State<DishDetailScreen> createState() => _DishDetailScreenState();
}

class _DishDetailScreenState extends State<DishDetailScreen>
    with SingleTickerProviderStateMixin {
  static const _primaryPink = ui.Color(0xFF00C1E8);

  bool _isFav = false;

  late TabController _tabController;
  final Map<String, Set<String>> _selectedOptions = {};
  int _quantity = 1;
  String? _specialInstructions;
  final _arabicNumber = NumberFormat.decimalPattern('ar');

  @override
  void initState() {
    super.initState();
    _isFav = widget.isInitiallyFav;
    _tabController = TabController(length: 2, vsync: this);
    for (var g in widget.dish.optionGroups) {
      _selectedOptions[g.id] = <String>{};
    }
    // يمكنك هنا تحميل حالة التفضيل من مزود أو قاعدة بيانات إذا أردت
    // حالياً سنبقيها محلياً فقط
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  double _calculateTotal() {
    var total = widget.dish.basePrice;
    _selectedOptions.forEach((gid, opts) {
      final group = widget.dish.optionGroups.firstWhere((g) => g.id == gid);
      for (var o in group.options.where((o) => opts.contains(o.id))) {
        total += o.extraPrice;
      }
    });
    return total * _quantity;
  }

  void _showDifferentStoreDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
        child: Directionality(
          textDirection: ui.TextDirection.rtl,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              // أيقونة سلة مع علامة إلغاء
              Stack(alignment: Alignment.center, children: [
                Container(
                  width: 64, height: 64,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    shape: BoxShape.circle,
                  ),
                ),
                const ModernCartIcon(
                  color: Colors.grey,
                  size: 32,
                  isGlassmorphic: false,
                ),
                const Positioned(
                  right: 0, top: 0,
                  child: Icon(Icons.close, size: 20, color: Colors.redAccent),
                ),
              ]),
              const SizedBox(height: 16),
              const Text(
                'لا يمكن إضافة الطلب إلى السلة',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              const Text(
                'سلة التسوق تحتوي طلبات من متجر آخر.\n'
                'هل تريد تفريغ السلة والبدء من المتجر الحالي أم عرض السلة الحالية؟',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.black87),
              ),
              const SizedBox(height: 24),
              Row(children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      final cart = Provider.of<CartModel>(dialogContext, listen: false);
                      cart.clear();
                      cart.addItem(CartItem(
                        storeId: widget.storeId,
                        dish: widget.dish,
                        quantity: _quantity,
                        unitPrice: widget.dish.basePrice,
                        totalPrice: _calculateTotal(),
                        selectedOptions: _selectedOptions,
                        specialInstructions: _specialInstructions,
                      ));
                      Navigator.pop(dialogContext); // يغلق الـ Dialog فقط
                      if (mounted) Navigator.pop(context, _isFav); // يغلق شاشة الطبق
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _primaryPink,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('تفريغ السلة', style: TextStyle(color: Colors.white)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(dialogContext); // يغلق الـ Dialog فقط
                      if (mounted) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => CartScreen(
                              storeId: widget.storeId,
                              stores: null, // لا توجد قائمة متاجر هنا، سيظهر الاسم الافتراضي إذا لم يتم تمريره
                            ),
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _primaryPink,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('عرض السلة', style: TextStyle(color: Colors.white)),
                  ),
                ),
              ]),
            ]),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: ui.TextDirection.rtl,
      child: Scaffold(
        extendBodyBehindAppBar: true,
        backgroundColor: Colors.white,
        body: ListView(
          padding: EdgeInsets.zero,
          children: [
            // صورة الغلاف مع أزرار الخروج والتفضيل
            Stack(
              children: [
                widget.dish.imageUrls.isNotEmpty
                    ? Image.asset(widget.dish.imageUrls.first, height: 240, width: double.infinity, fit: BoxFit.cover)
                    : Container(height: 240, color: Colors.grey.shade300),
                Positioned(
                  top: 24, right: 16,
                  child: CircleAvatar(
                    backgroundColor: Colors.white,
                    child: IconButton(
                      icon: const Icon(Icons.close, color: _primaryPink),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ),
                Positioned(
                  top: 24, left: 16,
                  child: CircleAvatar(
                    backgroundColor: Colors.white,
                    child: IconButton(
                      icon: Icon(_isFav ? Icons.favorite : Icons.favorite_border, color: _primaryPink),
                      onPressed: () => setState(() => _isFav = !_isFav),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // اسم الطبق
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                widget.dish.name,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ),
            // وصف الطبق
            if (widget.dish.description.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Text(
                  widget.dish.description,
                  style: const TextStyle(fontSize: 15, color: Colors.grey),
                ),
              ),
            const SizedBox(height: 12),
            // التحكم في الكمية
            _buildQuantitySelector(),
            const SizedBox(height: 16),
            // الخيارات (نفس منطقك القديم)
            for (var g in widget.dish.optionGroups) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Text(
                  '${g.title} • ${g.required ? "مطلوب" : "اختياري"} • '
                  '${g.required ? "اختر 1" : "حتى ${_arabicNumber.format(g.maxSelections)}"}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ),
              for (var o in g.options)
                g.required
                    ? RadioListTile<String>(
                        title: Text(
                          '${o.name}${o.extraPrice != 0 ? " (+${_arabicNumber.format(o.extraPrice)})" : ""}',
                        ),
                        value: o.id,
                        groupValue: _selectedOptions[g.id]!.isEmpty
                            ? null
                            : _selectedOptions[g.id]!.first,
                        onChanged: (id) => setState(() => _selectedOptions[g.id] = {id!}),
                      )
                    : CheckboxListTile(
                        title: Text(
                          '${o.name}${o.extraPrice != 0 ? " (+${_arabicNumber.format(o.extraPrice)})" : ""}',
                        ),
                        value: _selectedOptions[g.id]!.contains(o.id),
                        onChanged: (chk) => setState(() {
                          if (chk! && _selectedOptions[g.id]!.length < g.maxSelections) {
                            _selectedOptions[g.id]!.add(o.id);
                          } else {
                            _selectedOptions[g.id]!.remove(o.id);
                          }
                        }),
                      ),
            ],
            // تعليمات خاصة
            ListTile(
              title: const Text('إضافة تعليمات خاصة'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () async {
                final txt = await showModalBottomSheet<String>(
                  context: context,
                  builder: (_) {
                    final ctrl = TextEditingController(text: _specialInstructions);
                    return Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(mainAxisSize: MainAxisSize.min, children: [
                        TextField(
                          controller: ctrl,
                          decoration: const InputDecoration(labelText: 'ملاحظات'),
                          textDirection: ui.TextDirection.rtl,
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: _primaryPink),
                          onPressed: () => Navigator.pop(context, ctrl.text),
                          child: const Text('حفظ', style: TextStyle(color: Colors.white)),
                        ),
                      ]),
                    );
                  },
                );
                if (txt != null) setState(() => _specialInstructions = txt);
              },
            ),
            const SizedBox(height: 24),
          ],
        ),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: _primaryPink,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                final cart = Provider.of<CartModel>(context, listen: false);
                if (cart.currentStoreId != null && cart.currentStoreId != widget.storeId) {
                  _showDifferentStoreDialog();
                  return;
                }
                cart.addItem(CartItem(
                  storeId: widget.storeId,
                  dish: widget.dish,
                  quantity: _quantity,
                  unitPrice: widget.dish.basePrice,
                  totalPrice: _calculateTotal(),
                  selectedOptions: _selectedOptions,
                  specialInstructions: _specialInstructions,
                ));
                if (mounted) Navigator.pop(context, _isFav);
              },
              child: Text(
                'إضافة إلى الطلب • ${_calculateTotal().toStringAsFixed(2)} ر.س',
                style: const TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuantitySelector() {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 2))],
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          GestureDetector(
            onTap: () {
              if (_quantity > 1) setState(() => _quantity--);
            },
            child: Container(
              width: 36, height: 36,
              decoration: BoxDecoration(color: Colors.grey[200], shape: BoxShape.circle),
              child: const Center(child: Text('−', style: TextStyle(fontSize: 20))),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(_arabicNumber.format(_quantity),
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
          GestureDetector(
            onTap: () => setState(() => _quantity++),
            child: Container(
              width: 36, height: 36,
              decoration: const BoxDecoration(color: _primaryPink, shape: BoxShape.circle),
              child: const Center(child: Icon(Icons.add, color: Colors.white)),
            ),
          ),
        ]),
      ),
    );
  }
}
