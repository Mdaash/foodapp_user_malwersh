// اختبار بسيط لنظام النقاط والخصومات
import 'package:flutter/material.dart';

void main() {
  runApp(TestPointsSystem());
}

class TestPointsSystem extends StatefulWidget {
  @override
  _TestPointsSystemState createState() => _TestPointsSystemState();
}

class _TestPointsSystemState extends State<TestPointsSystem> {
  // محاكاة متغيرات النظام
  int _userPoints = 250;
  int _originalUserPoints = 250;
  bool _usePoints = false;
  double _pointsDiscount = 0;
  double _discount = 0;
  String? _selectedCoupon;
  
  void _applyPointsDiscount() {
    setState(() {
      if (_usePoints && _userPoints >= 100) {
        final pointsToUse = (_userPoints ~/ 100) * 100;
        _pointsDiscount = (pointsToUse / 100) * 5;
        _userPoints -= pointsToUse;
      }
    });
  }

  void _cancelPointsDiscount() {
    setState(() {
      _usePoints = false;
      _pointsDiscount = 0;
      _userPoints = _originalUserPoints;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('اختبار نظام النقاط'),
          backgroundColor: Color(0xFF00c1e8),
          foregroundColor: Colors.white,
        ),
        body: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // عرض المعلومات الحالية
              Card(
                color: Colors.blue.shade50,
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('الحالة الحالية:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                      SizedBox(height: 8),
                      Text('النقاط المتاحة: $_userPoints'),
                      Text('النقاط الأصلية: $_originalUserPoints'),
                      Text('استخدام النقاط: ${_usePoints ? "مفعل" : "غير مفعل"}'),
                      Text('خصم النقاط: ${_pointsDiscount.toStringAsFixed(2)} ريال'),
                      Text('خصم القسيمة: ${_discount.toStringAsFixed(2)} ريال'),
                      Text('إجمالي الخصم: ${(_pointsDiscount + _discount).toStringAsFixed(2)} ريال'),
                    ],
                  ),
                ),
              ),
              
              SizedBox(height: 20),
              
              // تحكم بالنقاط
              Card(
                color: Colors.green.shade50,
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.stars, color: Colors.blue),
                          SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('استخدم نقاطك', style: TextStyle(fontWeight: FontWeight.bold)),
                                Text('لديك $_userPoints نقطة • كل 100 نقطة = 5 ريال خصم', style: TextStyle(fontSize: 12)),
                              ],
                            ),
                          ),
                          Switch(
                            value: _usePoints,
                            onChanged: _userPoints >= 100 ? (value) {
                              setState(() {
                                if (value) {
                                  _usePoints = true;
                                  _applyPointsDiscount();
                                } else {
                                  _cancelPointsDiscount();
                                }
                              });
                            } : null,
                            activeColor: Color(0xFF00c1e8),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              
              SizedBox(height: 20),
              
              // أزرار اختبار إضافية
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _userPoints = _originalUserPoints;
                          _usePoints = false;
                          _pointsDiscount = 0;
                          _discount = 0;
                        });
                      },
                      child: Text('إعادة تعيين'),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _discount = 15.0; // محاكاة قسيمة خصم
                        });
                      },
                      child: Text('تطبيق قسيمة'),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                    ),
                  ),
                ],
              ),
              
              SizedBox(height: 20),
              
              // النتائج
              if (_pointsDiscount > 0 || _discount > 0)
                Card(
                  color: Colors.green.shade100,
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Text('تم تطبيق الخصومات بنجاح! 🎉', 
                             style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                        SizedBox(height: 8),
                        if (_pointsDiscount > 0)
                          Text('خصم النقاط: ${_pointsDiscount.toStringAsFixed(2)} ريال'),
                        if (_discount > 0)
                          Text('خصم القسيمة: ${_discount.toStringAsFixed(2)} ريال'),
                        Text('إجمالي المدخرات: ${(_pointsDiscount + _discount).toStringAsFixed(2)} ريال',
                             style: TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
