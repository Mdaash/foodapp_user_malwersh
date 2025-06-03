import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text('Test Category Images')),
        body: GridView.count(
          crossAxisCount: 3,
          children: [
            _buildCategoryItem('المطاعم', 'assets/icons/restaurant_category.png'),
            _buildCategoryItem('الوجبات السريعة', 'assets/icons/fast_food_category.png'),
            _buildCategoryItem('الفطور', 'assets/icons/breakfast_category.png'),
            _buildCategoryItem('البقالة', 'assets/icons/grocery_category.png'),
            _buildCategoryItem('اللحوم', 'assets/icons/meat_category.png'),
            _buildCategoryItem('الحلويات', 'assets/icons/desserts_category.png'),
            _buildCategoryItem('الخضار', 'assets/icons/vegetables_category.png'),
            _buildCategoryItem('المشروبات', 'assets/icons/beverages_category.png'),
            _buildCategoryItem('السوبرماركت', 'assets/icons/supermarket_category.png'),
            _buildCategoryItem('الزهور', 'assets/icons/flowers_category.png'),
            _buildCategoryItem('أخرى', 'assets/icons/others_category.png'),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryItem(String name, String imagePath) {
    return Container(
      margin: EdgeInsets.all(8),
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                imagePath,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(Icons.error, color: Colors.red);
                },
              ),
            ),
          ),
          SizedBox(height: 4),
          Text(
            name,
            style: TextStyle(fontSize: 10),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
