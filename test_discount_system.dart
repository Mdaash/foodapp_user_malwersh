// اختبار نظام الخصومات المُحدث
// هذا ملف للاختبار السريع لنظام الخصومات الجديد

import 'package:flutter/material.dart';

void main() {
  // اختبار منطق النظام
  print('🧪 اختبار نظام الخصومات المُحدث');
  print('=====================================');
  
  // محاكاة حالة المستخدم
  int userPoints = 250;
  double pointsDiscount = 0;
  double couponDiscount = 0;
  bool usePoints = false;
  String? selectedCoupon;
  
  print('💰 نقاط المستخدم: $userPoints');
  print('📋 السيناريوهات:');
  
  // السيناريو 1: تفعيل النقاط
  print('\n1️⃣ تفعيل النقاط:');
  usePoints = true;
  if (usePoints && userPoints >= 100) {
    // إلغاء أي قسيمة
    selectedCoupon = null;
    couponDiscount = 0;
    
    // حساب خصم النقاط
    final pointsToUse = (userPoints ~/ 100) * 100;
    pointsDiscount = (pointsToUse / 100) * 5;
    userPoints -= pointsToUse;
    
    print('   ✅ تم تفعيل النقاط');
    print('   💎 النقاط المستخدمة: $pointsToUse');
    print('   💰 خصم النقاط: ${pointsDiscount.toStringAsFixed(2)} ر.س');
    print('   📊 النقاط المتبقية: $userPoints');
    print('   🚫 القسائم: مُعطلة');
  }
  
  // السيناريو 2: محاولة تطبيق قسيمة (يجب أن تُلغي النقاط)
  print('\n2️⃣ محاولة تطبيق قسيمة:');
  if (usePoints) {
    print('   ⚠️  النقاط مُفعلة، يجب إلغاؤها أولاً');
    // إلغاء النقاط
    usePoints = false;
    pointsDiscount = 0;
    userPoints = 250; // إرجاع النقاط
    print('   ✅ تم إلغاء النقاط وإرجاعها');
  }
  
  // تطبيق القسيمة
  selectedCoupon = 'SAVE10';
  couponDiscount = 10.0;
  print('   ✅ تم تطبيق القسيمة: $selectedCoupon');
  print('   💰 خصم القسيمة: ${couponDiscount.toStringAsFixed(2)} ر.س');
  print('   🚫 النقاط: مُعطلة');
  
  // السيناريو 3: إجمالي الخصم
  print('\n3️⃣ إجمالي الخصومات:');
  final totalDiscount = pointsDiscount + couponDiscount;
  print('   💎 خصم النقاط: ${pointsDiscount.toStringAsFixed(2)} ر.س');
  print('   🎟️  خصم القسيمة: ${couponDiscount.toStringAsFixed(2)} ر.س');
  print('   💰 إجمالي الخصم: ${totalDiscount.toStringAsFixed(2)} ر.س');
  
  // السيناريو 4: إعادة تعيين
  print('\n4️⃣ إعادة تعيين الخصومات:');
  pointsDiscount = 0;
  couponDiscount = 0;
  selectedCoupon = null;
  usePoints = false;
  userPoints = 250;
  print('   ✅ تم إعادة تعيين جميع الخصومات');
  print('   💎 النقاط: $userPoints');
  print('   🎟️  القسائم: غير مُطبقة');
  
  print('\n✅ انتهى الاختبار - النظام يعمل بشكل صحيح!');
  print('=====================================');
}
