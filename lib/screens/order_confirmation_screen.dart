import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'card_payment_screen.dart';
import 'coming_soon_screen.dart';

class OrderConfirmationScreen extends StatefulWidget {
  final String address;
  final String city;
  final String area;
  final String district;
  final String landmark;
  final String storeName;
  final int totalDishes;
  final double subtotal;
  final double delivery;
  final double total;
  final String mapAddress;
  final LatLng userLocation;

  const OrderConfirmationScreen({
    super.key,
    required this.address,
    required this.city,
    required this.area,
    required this.district,
    required this.landmark,
    required this.storeName,
    required this.totalDishes,
    required this.subtotal,
    required this.delivery,
    required this.total,
    required this.mapAddress,
    required this.userLocation,
  });

  @override
  State<OrderConfirmationScreen> createState() => _OrderConfirmationScreenState();
}

class _OrderConfirmationScreenState extends State<OrderConfirmationScreen> {
  late TextEditingController _cityController;
  late TextEditingController _areaController;
  late TextEditingController _districtController;
  late TextEditingController _landmarkController;
  late TextEditingController _promoController;
  late TextEditingController _phoneController; // رقم الهاتف
  double _discount = 0;
  String? _promoError;
  int _selectedPayment = 1; // نقداً عند التسليم افتراضي
  bool _cardAdded = false;
  String? _addedCardNumber;

  @override
  void initState() {
    super.initState();
    _cityController = TextEditingController(text: widget.city);
    _areaController = TextEditingController(text: widget.area);
    _districtController = TextEditingController(text: widget.district);
    _landmarkController = TextEditingController(text: widget.landmark);
    _promoController = TextEditingController();
    _phoneController = TextEditingController(); // رقم الهاتف
  }

  @override
  void dispose() {
    _cityController.dispose();
    _areaController.dispose();
    _districtController.dispose();
    _landmarkController.dispose();
    _promoController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _applyPromo() {
    setState(() {
      if (_promoController.text.trim() == 'PROMO10') {
        _discount = 0.1 * widget.total;
        _promoError = null;
      } else {
        _discount = 0;
        _promoError = 'رمز غير صالح';
      }
    });
  }

  bool _validateCardLuhn(String cardNumber) {
    cardNumber = cardNumber.replaceAll(' ', '');
    if (cardNumber.length < 12 || cardNumber.length > 19) return false;
    int sum = 0;
    bool alternate = false;
    for (int i = cardNumber.length - 1; i >= 0; i--) {
      int n = int.tryParse(cardNumber[i]) ?? 0;
      if (alternate) {
        n *= 2;
        if (n > 9) n -= 9;
      }
      sum += n;
      alternate = !alternate;
    }
    return sum % 10 == 0;
  }

  @override
  Widget build(BuildContext context) {
    final double finalTotal = widget.total - _discount;
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        extendBodyBehindAppBar: true,
        backgroundColor: Colors.white, // خلفية الشاشة بيضاء
        appBar: AppBar(
          title: const Text('مراجعة وتأكيد الطلب'),
          backgroundColor: const Color(0xFF00c1e8),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        body: ListView(
          padding: const EdgeInsets.only(bottom: 90), // مساحة للزر الثابت
          children: [
            // صورة الغلاف (خريطة) داخل بطاقة أوف وايت
            Padding(
              padding: const EdgeInsets.all(16),
              child: Card(
                color: const Color(0xFFF8F9FA),
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: SizedBox(
                  height: 180,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: GoogleMap(
                      initialCameraPosition: CameraPosition(
                        target: widget.userLocation,
                        zoom: 15,
                      ),
                      markers: {
                        Marker(
                          markerId: const MarkerId('user'),
                          position: widget.userLocation,
                          infoWindow: const InfoWindow(title: 'عنوانك'),
                        ),
                      },
                      zoomControlsEnabled: false,
                      myLocationButtonEnabled: false,
                      liteModeEnabled: true,
                    ),
                  ),
                ),
              ),
            ),
            // عنوان المستخدم
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Card(
                color: const Color(0xFFF8F9FA),
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.location_on, color: Color(0xFF00c1e8)),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(widget.address, style: const TextStyle(fontWeight: FontWeight.bold)),
                          ),
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.grey),
                            onPressed: () {
                              showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                builder: (context) => Padding(
                                  padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        TextField(
                                          controller: _cityController,
                                          decoration: const InputDecoration(labelText: 'المحافظة'),
                                        ),
                                        TextField(
                                          controller: _areaController,
                                          decoration: const InputDecoration(labelText: 'القضاء أو الناحية'),
                                        ),
                                        TextField(
                                          controller: _districtController,
                                          decoration: const InputDecoration(labelText: 'الحي'),
                                        ),
                                        TextField(
                                          controller: _landmarkController,
                                          decoration: const InputDecoration(labelText: 'أقرب نقطة دالة للسائق'),
                                        ),
                                        TextField(
                                          controller: _phoneController,
                                          keyboardType: TextInputType.phone,
                                          decoration: const InputDecoration(labelText: 'رقم الهاتف'),
                                        ),
                                        const SizedBox(height: 12),
                                        ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: const Color(0xFF00c1e8),
                                            textStyle: const TextStyle(fontWeight: FontWeight.bold),
                                          ),
                                          onPressed: () {
                                            setState(() {}); // تحديث القيم
                                            Navigator.pop(context);
                                          },
                                          child: const Text('حفظ', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text('المحافظة: ${_cityController.text}'),
                      Text('القضاء/الناحية: ${_areaController.text}'),
                      Text('الحي: ${_districtController.text}'),
                      Text('أقرب نقطة: ${_landmarkController.text}'),
                      Text('رقم الهاتف: ${_phoneController.text}'),
                    ],
                  ),
                ),
              ),
            ),
            // تفاصيل الطلب
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Card(
                color: const Color(0xFFF8F9FA),
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('اسم المطعم: ${widget.storeName}', style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text('عدد الأطباق: ${widget.totalDishes}'),
                      Text('سعر الطلب: ${widget.subtotal.toStringAsFixed(2)} ر.س'),
                      Text('سعر التوصيل: ${widget.delivery.toStringAsFixed(2)} ر.س'),
                      const Divider(),
                      Text('السعر الكلي: ${widget.total.toStringAsFixed(2)} ر.س', style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
            ),
            // بطاقة بروموكود
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Card(
                color: const Color(0xFFF8F9FA),
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('قسيمة الخصم (بروموكود)', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _promoController,
                              decoration: const InputDecoration(hintText: 'ادخل رمز الخصم'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF00c1e8),
                              textStyle: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            onPressed: _applyPromo,
                            child: const Text('تطبيق', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                      if (_promoError != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(_promoError!, style: const TextStyle(color: Colors.red)),
                        ),
                      if (_discount > 0)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text('تم تطبيق الخصم: -${_discount.toStringAsFixed(2)} ر.س', style: const TextStyle(color: Colors.green)),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            // بطاقة وسائل الدفع
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Card(
                color: const Color(0xFFF8F9FA),
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('وسيلة الدفع', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      RadioListTile<int>(
                        value: 0,
                        groupValue: _selectedPayment,
                        onChanged: (v) async {
                          setState(() => _selectedPayment = v!);
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => CardPaymentScreen(
                                onCardAdded: (card, expiry, cvv) {
                                  // تحقق محلي: رقم البطاقة (Luhn)، تاريخ الانتهاء، CVV
                                  final now = DateTime.now();
                                  final expParts = expiry.split('/');
                                  bool validExpiry = false;
                                  if (expParts.length == 2) {
                                    final mm = int.tryParse(expParts[0]);
                                    final yy = int.tryParse(expParts[1]);
                                    if (mm != null && yy != null && mm >= 1 && mm <= 12) {
                                      final expDate = DateTime(2000 + yy, mm + 1);
                                      validExpiry = expDate.isAfter(now);
                                    }
                                  }
                                  final validCard = _validateCardLuhn(card);
                                  final validCvv = cvv.length == 3 || cvv.length == 4;
                                  if (validCard && validExpiry && validCvv) {
                                    setState(() {
                                      _cardAdded = true;
                                      _addedCardNumber = card;
                                    });
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('تمت إضافة البطاقة بنجاح وجاهزة للدفع'),
                                        backgroundColor: Color(0xFF00c1e8),
                                      ),
                                    );
                                  } else {
                                    setState(() {
                                      _cardAdded = false;
                                      _addedCardNumber = null;
                                    });
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('معلومات البطاقة غير صحيحة'),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                },
                              ),
                            ),
                          );
                        },
                        title: Row(
                          children: [
                            const Text('بطاقة مصرفية'),
                            if (_cardAdded && _selectedPayment == 0 && _addedCardNumber != null)
                              const Padding(
                                padding: EdgeInsets.only(right: 8),
                                child: Icon(Icons.check_circle, color: Colors.green, size: 20),
                              ),
                          ],
                        ),
                      ),
                      RadioListTile<int>(
                        value: 1,
                        groupValue: _selectedPayment,
                        onChanged: (v) => setState(() => _selectedPayment = v!),
                        title: const Text('نقداً عند التسليم'),
                      ),
                      RadioListTile<int>(
                        value: 2,
                        groupValue: _selectedPayment,
                        onChanged: (v) async {
                          setState(() => _selectedPayment = v!);
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const ComingSoonScreen(title: 'زين كاش'),
                            ),
                          );
                        },
                        title: const Text('زين كاش'),
                      ),
                      RadioListTile<int>(
                        value: 3,
                        groupValue: _selectedPayment,
                        onChanged: (v) async {
                          setState(() => _selectedPayment = v!);
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const ComingSoonScreen(title: 'آسيا باي'),
                            ),
                          );
                        },
                        title: const Text('آسيا باي'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        bottomNavigationBar: Container(
          color: Colors.white,
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: SafeArea(
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00c1e8),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  textStyle: const TextStyle(fontWeight: FontWeight.bold),
                ),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Text('تم إرسال الطلب بنجاح!'),
                      content: const Text('سيتم التواصل معك قريباً.'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('حسناً'),
                        ),
                      ],
                    ),
                  );
                },
                child: Text('تأكيد الطلب • ${finalTotal.toStringAsFixed(2)} ر.س', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
