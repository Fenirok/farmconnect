class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final String category;
  final int farmerId; // Maps to Java Long (64-bit integer)
  final String farmName;
  final double weight;
  final String unit; // kg, g, piece, etc.
  final bool isOrganic;
  final String location;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.category,
    required this.farmerId,
    required this.farmName,
    required this.weight,
    required this.unit,
    this.isOrganic = false,
    this.location = 'Unknown',
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'].toString(),
      name: json['name'],
      description: json['description'],
      price: (json['price'] as num).toDouble(),
      imageUrl: json['imageUrl'],
      category: json['category'],
      farmerId: json['farmerId'] as int, // Maps to Java Long
      farmName: json['farmName'],
      weight: (json['weight'] as num).toDouble(),
      unit: json['unit'],
      isOrganic: json['organic'] ?? false,
      location: json['location'] ?? 'Unknown',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'imageUrl': imageUrl,
      'category': category,
      'farmerId': farmerId, // Sends as int (maps to Java Long)
      'farmerName': farmName,
      'weight': weight,
      'unit': unit,
      'isOrganic': isOrganic,
      'location': location,
    };
  }
}
