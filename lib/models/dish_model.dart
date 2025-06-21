class DishModel {
  final String id;
  final String name;
  final double price;
  final double rating;
  final String category;

  DishModel({
    required this.id,
    required this.name,
    required this.price,
    required this.rating,
    required this.category,
  });

  factory DishModel.fromJson(Map<String, dynamic> json) {
    return DishModel(
      id: json['id'],
      name: json['name'],
      price: json['price'],
      rating: json['rating'],
      category: json['category'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'rating': rating,
      'category': category,
    };
  }
}
