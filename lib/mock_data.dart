// lib/mock_data.dart

import 'models/dish.dart';
import 'models/dish.dart' show Dish, OptionGroup, Option;

/// قائمة بالأطباق التجريبية لاستخدامها في العرض والاختبار
final List<Dish> mockDishes = [
  // 1. بيتزا مارجريتا
  Dish(
    id: 'pizza1',
    name: 'بيتزا مارجريتا',
    imageUrls: [
      'https://via.placeholder.com/400x300.png?text=Margherita+Pizza'
    ],
    description:
        'بيتزا كلاسيكية بصلصة الطماطم والموزاريلا الطازجة والريحان الطازج. تُخبز على حجر حراري لقرمشة مثالية.',
    likesPercent: 95,
    likesCount: 230,
    basePrice: 25.00,
    optionGroups: [
      OptionGroup(
        id: 'size',
        title: 'الحجم',
        required: true,
        maxSelections: 1,
        options: [
          Option(id: 'small', name: 'صغير', extraPrice: 0),
          Option(id: 'medium', name: 'متوسط', extraPrice: 5),
          Option(id: 'large', name: 'كبير', extraPrice: 10),
        ],
      ),
      OptionGroup(
        id: 'crust',
        title: 'نوع العجينة',
        required: true,
        maxSelections: 1,
        options: [
          Option(id: 'classic', name: 'كلاسيكي', extraPrice: 0),
          Option(id: 'thin', name: 'رقيق', extraPrice: 2),
          Option(id: 'cheese_crust', name: 'عجينة بالجبن', extraPrice: 3),
        ],
      ),
    ],
  ),

  // 2. برغر لحم بقر
  Dish(
    id: 'burger1',
    name: 'برغر لحم بقر',
    imageUrls: [
      'https://via.placeholder.com/400x300.png?text=Beef+Burger'
    ],
    description:
        'برغر لحم بقر طازج 100%، يقدم مع خس وطماطم وبصل مكرمل وصلصة خاصة في خبز البريوش.',
    likesPercent: 90,
    likesCount: 185,
    basePrice: 30.00,
    optionGroups: [
      OptionGroup(
        id: 'cheese',
        title: 'اختيار الجبن',
        required: true,
        maxSelections: 1,
        options: [
          Option(id: 'american', name: 'أمريكان', extraPrice: 0),
          Option(id: 'cheddar', name: 'شيدر', extraPrice: 2),
          Option(id: 'no_cheese', name: 'بدون جبن', extraPrice: -2),
        ],
      ),
      OptionGroup(
        id: 'extras',
        title: 'إضافات',
        required: false,
        maxSelections: 3,
        options: [
          Option(id: 'bacon', name: 'بيكون', extraPrice: 4),
          Option(id: 'mushrooms', name: 'فطر', extraPrice: 2),
          Option(id: 'onion_rings', name: 'حلقات بصل', extraPrice: 3),
        ],
      ),
    ],
  ),

  // 3. سلطة سيزر
  Dish(
    id: 'salad1',
    name: 'سلطة سيزر',
    imageUrls: [
      'https://via.placeholder.com/400x300.png?text=Caesar+Salad'
    ],
    description:
        'خس روماني طازج مع شرائح بارميزان وصلصة سيزر الأصلية مع خبز محمص مقرمش.',
    likesPercent: 88,
    likesCount: 102,
    basePrice: 18.50,
    optionGroups: [
      OptionGroup(
        id: 'protein',
        title: 'إضافة بروتين',
        required: false,
        maxSelections: 1,
        options: [
          Option(id: 'chicken', name: 'صدور دجاج', extraPrice: 6),
          Option(id: 'shrimp', name: 'جمبري', extraPrice: 8),
        ],
      ),
    ],
  ),

  // 4. سباغيتي بولونيز
  Dish(
    id: 'pasta1',
    name: 'سباغيتي بولونيز',
    imageUrls: [
      'https://via.placeholder.com/400x300.png?text=Spaghetti+Bolognese'
    ],
    description:
        'سباغيتي مطهو "أل دينتي" مع صلصة بولونيز اللحم الغنية والمكثفة وتُزين بجبن بارميزان مبشور.',
    likesPercent: 92,
    likesCount: 150,
    basePrice: 27.00,
    optionGroups: [
      OptionGroup(
        id: 'pasta_size',
        title: 'كمية الباستا',
        required: true,
        maxSelections: 1,
        options: [
          Option(id: 'regular', name: 'عادية', extraPrice: 0),
          Option(id: 'large', name: 'كبيرة', extraPrice: 7),
        ],
      ),
    ],
  ),

  // 5. سوشي تشكيلة
  Dish(
    id: 'sushi1',
    name: 'تشكيلة سوشي',
    imageUrls: [
      'https://via.placeholder.com/400x300.png?text=Sushi+Platter'
    ],
    description:
        'تشكيلة فاخرة من الساشيمي والماكي والسوشي رولز مع صوص الصويا وصلصة الواسابي.',
    likesPercent: 97,
    likesCount: 88,
    basePrice: 45.00,
    optionGroups: [
      OptionGroup(
        id: 'pieces',
        title: 'عدد القطع',
        required: true,
        maxSelections: 1,
        options: [
          Option(id: '8pcs', name: '8 قطع', extraPrice: 0),
          Option(id: '12pcs', name: '12 قطعة', extraPrice: 12),
          Option(id: '16pcs', name: '16 قطعة', extraPrice: 20),
        ],
      ),
    ],
  ),

  // 6. تشيز كيك فراولة
  Dish(
    id: 'dessert1',
    name: 'تشيز كيك فراولة',
    imageUrls: [
      'https://via.placeholder.com/400x300.png?text=Strawberry+Cheesecake'
    ],
    description:
        'قطعة غنية من تشيز كيك مع طبقة من صوص الفراولة الطبيعية وقاعدة بسكويت مغطاة بالزبدة.',
    likesPercent: 85,
    likesCount: 70,
    basePrice: 15.00,
    optionGroups: [],
  ),

  // 7. كوكتيل موهيتو
  Dish(
    id: 'drink1',
    name: 'كوكتيل موهيتو',
    imageUrls: [
      'https://via.placeholder.com/400x300.png?text=Mojito+Cocktail'
    ],
    description:
        'كوكتيل منعش من النعناع والليمون واللومي مع لمسة من الروم والنعناع المفروم ومياه الصودا.',
    likesPercent: 91,
    likesCount: 55,
    basePrice: 12.00,
    optionGroups: [
      OptionGroup(
        id: 'sweetness',
        title: 'مستوى الحلاوة',
        required: false,
        maxSelections: 1,
        options: [
          Option(id: 'normal', name: 'عادي', extraPrice: 0),
          Option(id: 'less', name: 'أقل حلاوة', extraPrice: 0),
          Option(id: 'more', name: 'أكثر حلاوة', extraPrice: 0),
        ],
      ),
    ],
  ),
];
