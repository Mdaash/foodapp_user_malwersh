// Test script to validate filter functionality
import 'lib/models/store.dart';

void main() {
  print('Testing Filter Functionality...\n');
  
  // Create test stores
  final testStores = [
    Store(
      id: '1',
      name: 'مطعم البرجر السريع',
      specialty: 'البرجر الأمريكي',
      image: 'assets/images/burger_store.jpg',
      rating: 4.5,
      reviewCount: 120,
      deliveryTime: '20-30 دقيقة',
      deliveryFee: '5 ريال',
      hasDiscount: true,
      originalPrice: 25.0,
      discountedPrice: 20.0,
      tags: ['برجر', 'وجبات سريعة'],
      categories: ['وجبات سريعة'],
      menuItems: [],
    ),
    Store(
      id: '2',
      name: 'مطعم الصحة والعافية',
      specialty: 'الأطعمة الصحية',
      image: 'assets/images/healthy_store.jpg',
      rating: 4.8,
      reviewCount: 85,
      deliveryTime: '15-25 دقيقة',
      deliveryFee: 'مجاني',
      hasDiscount: false,
      originalPrice: 30.0,
      discountedPrice: 30.0,
      tags: ['صحي', 'خضار'],
      categories: ['صحي'],
      menuItems: [],
    ),
    Store(
      id: '3',
      name: 'مطعم المأكولات البحرية',
      specialty: 'الأسماك الطازجة',
      image: 'assets/images/seafood_store.jpg',
      rating: 4.3,
      reviewCount: 95,
      deliveryTime: '30-45 دقيقة',
      deliveryFee: '8 ريال',
      hasDiscount: true,
      originalPrice: 50.0,
      discountedPrice: 40.0,
      tags: ['مأكولات بحرية', 'أسماك'],
      categories: ['مأكولات بحرية'],
      menuItems: [],
    ),
  ];

  // Test time filter
  print('=== Testing Time Filter ===');
  final fastStores = testStores.where((store) {
    final timeText = store.deliveryTime;
    final numbers = RegExp(r'\d+').allMatches(timeText).map((e) => int.parse(e.group(0)!)).toList();
    if (numbers.isNotEmpty) {
      final avgTime = numbers.length == 1 ? numbers[0] : (numbers[0] + numbers[1]) / 2;
      return avgTime <= 25;
    }
    return false;
  }).toList();
  
  print('Fast delivery stores (≤25 min): ${fastStores.length}');
  for (var store in fastStores) {
    print('  - ${store.name} (${store.deliveryTime})');
  }

  // Test price filter
  print('\n=== Testing Price Filter ===');
  final freeDeliveryStores = testStores.where((store) => 
    store.deliveryFee.contains('مجاني') || store.deliveryFee.contains('0')
  ).toList();
  
  print('Free delivery stores: ${freeDeliveryStores.length}');
  for (var store in freeDeliveryStores) {
    print('  - ${store.name} (${store.deliveryFee})');
  }

  // Test rating filter
  print('\n=== Testing Rating Filter ===');
  final highRatedStores = testStores.where((store) => store.rating >= 4.5).toList();
  
  print('High rated stores (≥4.5): ${highRatedStores.length}');
  for (var store in highRatedStores) {
    print('  - ${store.name} (${store.rating} stars)');
  }

  // Test category filter
  print('\n=== Testing Category Filter ===');
  final healthyStores = testStores.where((store) => 
    store.categories.any((cat) => cat.contains('صحي')) ||
    store.tags.any((tag) => tag.contains('صحي')) ||
    store.specialty.contains('صحي')
  ).toList();
  
  print('Healthy food stores: ${healthyStores.length}');
  for (var store in healthyStores) {
    print('  - ${store.name} (${store.specialty})');
  }

  print('\n✅ Filter functionality validation complete!');
}
