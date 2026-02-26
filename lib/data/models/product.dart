class Product {
  final String barcode;
  final String name;
  final double caloriesPer100g;
  final double proteinsPer100g;
  final double carbsPer100g;
  final double fatsPer100g;
  final String? servingSize;
  final String? imageUrl;

  Product({
    required this.barcode,
    required this.name,
    required this.caloriesPer100g,
    required this.proteinsPer100g,
    required this.carbsPer100g,
    required this.fatsPer100g,
    this.servingSize,
    this.imageUrl,
  });

  factory Product.fromOpenFoodFacts(Map<String, dynamic> json) {
    final product = json['product'] as Map<String, dynamic>? ?? {};
    final nutriments = product['nutriments'] as Map<String, dynamic>? ?? {};

    return Product(
      barcode: product['code']?.toString() ?? '',
      name: product['product_name']?.toString() ?? 'Producto desconocido',
      caloriesPer100g: (nutriments['energy-kcal_100g'] ?? 0).toDouble(),
      proteinsPer100g: (nutriments['proteins_100g'] ?? 0).toDouble(),
      carbsPer100g: (nutriments['carbohydrates_100g'] ?? 0).toDouble(),
      fatsPer100g: (nutriments['fat_100g'] ?? 0).toDouble(),
      servingSize: product['serving_size']?.toString(),
      imageUrl: product['image_url']?.toString(),
    );
  }
}
