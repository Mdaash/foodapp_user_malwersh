import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'payment_screen.dart';

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
  late TextEditingController _notesController;
  late TextEditingController _phoneController;
  late TextEditingController _couponController;
  String _selectedPayment = 'cash';
  String _couponCode = '';
  int _pointsToUse = 0;
  final int _availablePoints = 125; // نقاط المستخدم المتاحة
  double _discount = 0.0;
  double _tip = 0.0;
  
  @override
  void initState() {
    super.initState();
    _notesController = TextEditingController();
    _phoneController = TextEditingController(text: '+964 770 123 4567');
    _couponController = TextEditingController();
  }

  @override
  void dispose() {
    _notesController.dispose();
    _phoneController.dispose();
    _couponController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFFAFAFA),
        body: CustomScrollView(
          slivers: [
            // AppBar مع الخريطة
            _buildMapAppBar(),
            // محتوى الشاشة
            SliverToBoxAdapter(
              child: Column(
                children: [
                  _buildDeliveryInfo(),
                  _buildAddressSection(),
                  _buildNotesSection(),
                  _buildPhoneSection(),
                  _buildPaymentMethods(),
                  _buildCouponsAndPoints(),
                  _buildTipSection(),
                  _buildOrderSummary(),
                  const SizedBox(height: 100), // مساحة للزر
                ],
              ),
            ),
          ],
        ),
        bottomNavigationBar: _buildCheckoutButton(),
      ),
    );
  }

  // AppBar مع الخريطة - تصميم DoorDash
  Widget _buildMapAppBar() {
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      backgroundColor: Colors.white,
      foregroundColor: Colors.black87,
      elevation: 0,
      title: const Text(
        'تأكيد الطلب',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          margin: const EdgeInsets.only(top: 80),
          child: GoogleMap(
            initialCameraPosition: CameraPosition(
              target: widget.userLocation,
              zoom: 15,
            ),
            markers: {
              Marker(
                markerId: const MarkerId('user_location'),
                position: widget.userLocation,
                icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
                infoWindow: const InfoWindow(title: 'موقع التسليم'),
              ),
            },
            zoomControlsEnabled: false,
            mapToolbarEnabled: false,
            myLocationButtonEnabled: false,
            liteModeEnabled: true,
          ),
        ),
      ),
    );
  }

  // معلومات التسليم - تصميم DoorDash
  Widget _buildDeliveryInfo() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF1976D2).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.access_time,
              color: Color(0xFF1976D2),
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'مدة التسليم المتوقعة',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '25-35 دقيقة',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'سريع',
              style: TextStyle(
                fontSize: 12,
                color: Colors.green,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // قسم العنوان - تصميم DoorDash
  Widget _buildAddressSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'عنوان التسليم',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              TextButton.icon(
                onPressed: () {
                  _showEditAddressDialog();
                },
                icon: const Icon(
                  Icons.edit,
                  size: 16,
                  color: Color(0xFF1976D2),
                ),
                label: const Text(
                  'تعديل',
                  style: TextStyle(
                    color: Color(0xFF1976D2),
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF1976D2).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.location_on,
                  color: Color(0xFF1976D2),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.mapAddress,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${widget.city}، ${widget.area}',
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
        ],
      ),
    );
  }

  // قسم الملاحظات - تصميم DoorDash
  Widget _buildNotesSection() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
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
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.note_alt,
                  color: Colors.orange,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'ملاحظات للسائق',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _notesController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'مثال: الرجاء الطرق على الباب، المنزل بجانب الصيدلية...',
              hintStyle: TextStyle(
                color: Colors.grey[500],
                fontSize: 14,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFF1976D2)),
              ),
              contentPadding: const EdgeInsets.all(12),
            ),
          ),
        ],
      ),
    );
  }

  // قسم رقم الهاتف - تصميم DoorDash
  Widget _buildPhoneSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
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
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.phone,
                  color: Colors.green,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'رقم الهاتف',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
              hintText: '+964 770 123 4567',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFF1976D2)),
              ),
              contentPadding: const EdgeInsets.all(12),
            ),
          ),
        ],
      ),
    );
  }

  // طرق الدفع - تصميم DoorDash
  Widget _buildPaymentMethods() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
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
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF1976D2).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.payment,
                  color: Color(0xFF1976D2),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'طريقة الدفع',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // نقداً عند التسليم
          _buildPaymentOption(
            'cash',
            'نقداً عند التسليم',
            Icons.money,
            Colors.green,
          ),
          const SizedBox(height: 8),
          // بطاقة مصرفية
          _buildPaymentOption(
            'card',
            'بطاقة مصرفية',
            Icons.credit_card,
            Colors.blue,
          ),
          const SizedBox(height: 8),
          // زين كاش
          _buildPaymentOption(
            'zain_cash',
            'زين كاش',
            Icons.phone_android,
            Colors.purple,
          ),
          const SizedBox(height: 8),
          // آسيا باي
          _buildPaymentOption(
            'asia_pay',
            'آسيا باي',
            Icons.account_balance_wallet,
            Colors.orange,
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentOption(String value, String title, IconData icon, Color color) {
    return GestureDetector(
      onTap: () => setState(() => _selectedPayment = value),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: _selectedPayment == value 
                ? const Color(0xFF1976D2) 
                : Colors.grey.withOpacity(0.3),
            width: 2,
          ),
          borderRadius: BorderRadius.circular(8),
          color: _selectedPayment == value 
              ? const Color(0xFF1976D2).withOpacity(0.05) 
              : Colors.transparent,
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: _selectedPayment == value 
                      ? const Color(0xFF1976D2) 
                      : Colors.black87,
                ),
              ),
            ),
            if (_selectedPayment == value)
              const Icon(
                Icons.check_circle,
                color: Color(0xFF1976D2),
                size: 20,
              ),
          ],
        ),
      ),
    );
  }

  // قسم القسائم والنقاط - تصميم DoorDash
  Widget _buildCouponsAndPoints() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
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
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.local_offer,
                  color: Colors.amber,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'القسائم والنقاط',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // حقل قسيمة الخصم
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _couponController,
                  decoration: InputDecoration(
                    hintText: 'أدخل رمز القسيمة',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Color(0xFF1976D2)),
                    ),
                    contentPadding: const EdgeInsets.all(12),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: () => _applyCoupon(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1976D2),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('تطبيق'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // استخدام النقاط
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.withOpacity(0.2)),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'النقاط المتاحة: $_availablePoints نقطة',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      '= ${(_availablePoints * 0.1).toStringAsFixed(1)} ر.س',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Slider(
                        value: _pointsToUse.toDouble(),
                        min: 0,
                        max: _availablePoints.toDouble(),
                        divisions: _availablePoints,
                        activeColor: const Color(0xFF1976D2),
                        onChanged: (value) {
                          setState(() {
                            _pointsToUse = value.round();
                            _discount = _pointsToUse * 0.1; // كل نقطة = 0.1 ر.س
                          });
                        },
                      ),
                    ),
                    Text(
                      '$_pointsToUse',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1976D2),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // قسم الإكرامية - تصميم DoorDash
  Widget _buildTipSection() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
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
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.thumb_up,
                  color: Colors.green,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'إكرامية السائق',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildTipOption(0, 'بدون'),
              const SizedBox(width: 8),
              _buildTipOption(2, '2 ر.س'),
              const SizedBox(width: 8),
              _buildTipOption(5, '5 ر.س'),
              const SizedBox(width: 8),
              _buildTipOption(10, '10 ر.س'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTipOption(double amount, String label) {
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _tip = amount),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            border: Border.all(
              color: _tip == amount 
                  ? Colors.green 
                  : Colors.grey.withOpacity(0.3),
              width: 2,
            ),
            borderRadius: BorderRadius.circular(8),
            color: _tip == amount 
                ? Colors.green.withOpacity(0.1) 
                : Colors.transparent,
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: _tip == amount ? Colors.green : Colors.black87,
            ),
          ),
        ),
      ),
    );
  }

  // ملخص الطلب - تصميم DoorDash
  Widget _buildOrderSummary() {
    final double finalTotal = widget.total - _discount + _tip;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
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
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF1976D2).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.receipt,
                  color: Color(0xFF1976D2),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'ملخص الطلب',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildSummaryRow('عدد الأطباق (${widget.totalDishes})', '${widget.subtotal.toStringAsFixed(2)} ر.س'),
          _buildSummaryRow('رسوم التوصيل', '${widget.delivery.toStringAsFixed(2)} ر.س'),
          if (_discount > 0)
            _buildSummaryRow('خصم النقاط', '-${_discount.toStringAsFixed(2)} ر.س', color: Colors.green),
          if (_tip > 0)
            _buildSummaryRow('إكرامية السائق', '+${_tip.toStringAsFixed(2)} ر.س', color: Colors.orange),
          const Divider(height: 24),
          _buildSummaryRow(
            'المجموع النهائي', 
            '${finalTotal.toStringAsFixed(2)} ر.س',
            isTotal: true,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {Color? color, bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.w600 : FontWeight.w500,
              color: color ?? Colors.black87,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.w600 : FontWeight.w500,
              color: color ?? (isTotal ? const Color(0xFF1976D2) : Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  // زر الدفع - تصميم DoorDash
  Widget _buildCheckoutButton() {
    final double finalTotal = widget.total - _discount + _tip;
    
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
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1976D2),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 0,
            ),
            onPressed: () {
              if (_phoneController.text.isEmpty) {
                _showSnackBar('يرجى إدخال رقم الهاتف', Colors.orange);
                return;
              }
              
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => PaymentScreen(
                    totalAmount: finalTotal,
                    orderSummary: _buildOrderSummaryText(),
                    onPaymentSuccess: () => _showOrderSuccessDialog(),
                  ),
                ),
              );
            },
            child: Text(
              'تأكيد الطلب • ${finalTotal.toStringAsFixed(2)} ر.س',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // وظائف مساعدة
  void _showEditAddressDialog() {
    // يمكن إضافة dialog لتعديل العنوان هنا
    _showSnackBar('ميزة تعديل العنوان قيد التطوير', Colors.blue);
  }

  void _applyCoupon() {
    if (_couponController.text.isEmpty) {
      _showSnackBar('يرجى إدخال رمز القسيمة', Colors.orange);
      return;
    }
    
    // محاكاة تطبيق القسيمة
    if (_couponController.text.toLowerCase() == 'save10') {
      setState(() {
        _discount += 10.0;
      });
      _showSnackBar('تم تطبيق القسيمة! خصم 10 ر.س', Colors.green);
    } else {
      _showSnackBar('رمز القسيمة غير صحيح', Colors.red);
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  String _buildOrderSummaryText() {
    return 'المطعم: ${widget.storeName}\n'
        'عدد الأطباق: ${widget.totalDishes}\n'
        'المجموع: ${(widget.total - _discount + _tip).toStringAsFixed(2)} ر.س\n'
        'العنوان: ${widget.mapAddress}\n'
        'الهاتف: ${_phoneController.text}\n'
        'طريقة الدفع: ${_getPaymentMethodName()}\n'
        'ملاحظات: ${_notesController.text.isEmpty ? 'لا توجد' : _notesController.text}';
  }

  String _getPaymentMethodName() {
    switch (_selectedPayment) {
      case 'cash': return 'نقداً عند التسليم';
      case 'card': return 'بطاقة مصرفية';
      case 'zain_cash': return 'زين كاش';
      case 'asia_pay': return 'آسيا باي';
      default: return 'نقداً عند التسليم';
    }
  }

  void _showOrderSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 28),
            SizedBox(width: 12),
            Text('تم تأكيد الطلب! 🎉'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('شكراً لك! تم استلام طلبك بنجاح.'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('رقم الطلب: #${DateTime.now().millisecondsSinceEpoch}'),
                  Text('المطعم: ${widget.storeName}'),
                  Text('مدة التسليم: 25-35 دقيقة'),
                  Text('المبلغ: ${(widget.total - _discount + _tip).toStringAsFixed(2)} ر.س'),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // إغلاق الـ dialog
              Navigator.of(context).pop(); // العودة للشاشة السابقة
              Navigator.of(context).pop(); // العودة للشاشة الرئيسية
            },
            child: const Text(
              'العودة للرئيسية',
              style: TextStyle(color: Color(0xFF1976D2)),
            ),
          ),
        ],
      ),
    );
  }
}
