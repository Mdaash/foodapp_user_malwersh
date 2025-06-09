// lib/models/store.dart

import 'menu_item.dart';

class Store {
  final String id;
  final String name;
  final String image;     // صورة الغلاف
  final String logoUrl;   // شعار المتجر
  final bool isOpen;      // مفتوح أم مغلق
  final String fee;       // رسوم التوصيل أو أي معلومة مالية
  final String rating;    // تقييم النجوم
  final String reviews;   // عدد المراجعات
  final String distance;  // المسافة
  final String time;      // وقت التوصيل/العمل
  final String address;   // عنوان المتجر

  // خصائص إضافية للتوافق مع الشاشات
  String get imageUrl => image;  // alias للصورة الرئيسية
  double get ratingValue => double.tryParse(rating) ?? 0.0;  // التقييم كرقم
  String get deliveryTime => time;  // وقت التوصيل
  String get deliveryFee => fee;    // رسوم التوصيل

  // هذه الحقول كانت مفقودة في الكونستركتور
  final String? promo;
  final String? tag;
  final String? category;
  final bool sponsored;

  // قوائم الأصناف بحسب التبويبات
  final List<MenuItem> combos;
  final List<MenuItem> sandwiches;
  final List<MenuItem> drinks;
  final List<MenuItem> extras;
  final List<MenuItem> specialties; // أو أي تبويب إضافي

  Store({
    required this.id,
    required this.name,
    required this.image,
    required this.logoUrl,
    required this.isOpen,
    required this.fee,
    required this.rating,
    required this.reviews,
    required this.distance,
    required this.time,
    required this.address,
    this.promo,
    this.tag,
    this.category,
    this.sponsored = false,
    required this.combos,
    required this.sandwiches,
    required this.drinks,
    required this.extras,
    required this.specialties,
  });

  factory Store.fromJson(Map<String, dynamic> json) {
    List<MenuItem> listFromJson(List<dynamic>? arr) =>
        arr?.map((e) => MenuItem.fromJson(e as Map<String, dynamic>)).toList() ??
        [];

    return Store(
      id: json['id'] as String,
      name: json['name'] as String,
      image: json['image'] as String,
      logoUrl: json['logoUrl'] as String,
      isOpen: json['isOpen'] as bool,
      fee: json['fee'] as String,
      rating: json['rating'] as String,
      reviews: json['reviews'] as String,
      distance: json['distance'] as String,
      time: json['time'] as String,
      address: json['address'] as String,
      promo: json['promo'] as String?,
      tag: json['tag'] as String?,
      category: json['category'] as String?,
      sponsored: json['sponsored'] as bool? ?? false,
      combos: listFromJson(json['combos'] as List<dynamic>?),
      sandwiches: listFromJson(json['sandwiches'] as List<dynamic>?),
      drinks: listFromJson(json['drinks'] as List<dynamic>?),
      extras: listFromJson(json['extras'] as List<dynamic>?),
      specialties: listFromJson(json['specialties'] as List<dynamic>?),
    );
  }
}
