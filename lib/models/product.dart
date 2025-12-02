class Product {
  final String id;
  final String name;
  final String category;
  final String color;
  final String description;
  final double price;
  final int quantity;
  final String image;
  final bool isBestSeller;

  Product({
    required this.id,
    required this.name,
    required this.category,
    required this.color,
    required this.description,
    required this.price,
    required this.quantity,
    required this.image,
    required this.isBestSeller,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'].toString(),
      name: json['name'] ?? '',
      category: json['category'] ?? '',
      color: json['color'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] is int)
          ? (json['price'] as int).toDouble()
          : (json['price'] ?? 0).toDouble(),
      quantity: json['quantity'] ?? 0,
      image: json['image'] ?? '', // Make sure this is like "assets/products/M6CBLACK.webp"
      isBestSeller: json['isBestSeller'] == 1 || json['isBestSeller'] == true,
    );
  }
}
